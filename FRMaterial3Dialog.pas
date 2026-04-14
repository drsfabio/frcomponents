unit FRMaterial3Dialog;

{$mode objfpc}{$H+}

{ Material Design 3 — Dialog.

  TFRMaterialDialog — Modal dialog component with full MD3 styling.
  Non-visual component; call Execute to show.

  Features:
  - Fade-in scrim + scale-up card animation (MD3 motion spec)
  - Dismiss via Escape or scrim click (configurable)
  - Responsive width (scales to screen, min 280 max 560)
  - Scrollable content for long text
  - i18n-ready button captions
  - Custom icon support via TFRIconMode
  - Full theme integration (ApplyTheme updates live dialog)
  - Tab navigation between buttons (accessibility)
  - High-DPI aware layout

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, Forms, StdCtrls, ExtCtrls,
  LCLIntf, LCLType, LMessages, Math, Dialogs,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterialTheme, FRMaterial3Base, FRMaterial3Button,
  FRMaterialIcons;

type
  TFRMDDialogButton = (dbNone, dbOK, dbCancel, dbYes, dbNo, dbClose);
  TFRMDDialogButtons = set of TFRMDDialogButton;
  TFRMDDialogResult = (drNone, drOK, drCancel, drYes, drNo, drClose);
  TFRMDDialogIcon = (diNone, diInfo, diWarning, diError, diSuccess, diHelp, diCustom);

  { ── TFRMaterialDialog ── }

  TFRMaterialDialog = class(TComponent, IFRMaterialComponent)
  private
    FTitle: string;
    FContent: string;
    FButtons: TFRMDDialogButtons;
    FDialogIcon: TFRMDDialogIcon;
    FCustomIcon: TFRIconMode;
    FDismissOnScrim: Boolean;
    FDismissOnEscape: Boolean;
    FScrimOpacity: Byte;
    FCaptionOK: string;
    FCaptionCancel: string;
    FCaptionYes: string;
    FCaptionNo: string;
    FCaptionClose: string;
    FMaxContentHeight: Integer;
    procedure SetTitle(const AValue: string);
    procedure SetContent(const AValue: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: TFRMDDialogResult;
    procedure ApplyTheme(const AThemeManager: TObject); virtual;
  published
    property Title: string read FTitle write SetTitle;
    property Content: string read FContent write SetContent;
    property Buttons: TFRMDDialogButtons read FButtons write FButtons default [dbOK, dbCancel];
    property DialogIcon: TFRMDDialogIcon read FDialogIcon write FDialogIcon default diNone;
    property CustomIcon: TFRIconMode read FCustomIcon write FCustomIcon default imInfo;
    property DismissOnScrim: Boolean read FDismissOnScrim write FDismissOnScrim default True;
    property DismissOnEscape: Boolean read FDismissOnEscape write FDismissOnEscape default True;
    { Scrim opacity: 0=fully transparent, 255=fully opaque. Default 128 (50%) per MD3 spec }
    property ScrimOpacity: Byte read FScrimOpacity write FScrimOpacity default 128;
    property CaptionOK: string read FCaptionOK write FCaptionOK;
    property CaptionCancel: string read FCaptionCancel write FCaptionCancel;
    property CaptionYes: string read FCaptionYes write FCaptionYes;
    property CaptionNo: string read FCaptionNo write FCaptionNo;
    property CaptionClose: string read FCaptionClose write FCaptionClose;
    { Max height for content area before scroll kicks in (0 = auto) }
    property MaxContentHeight: Integer read FMaxContentHeight write FMaxContentHeight default 0;
  end;

{ Global helper — substitui MessageDlg com visual MD3 }
function MessageDialog(const ATitle, AContent: string;
  AIcon: TFRMDDialogIcon; AButtons: TFRMDDialogButtons): TFRMDDialogResult;

{ Drop-in wrappers — mesma assinatura do Dialogs.MessageDlg / ShowMessage }
function MD3MessageDlg(const ATitle, AContent: string; AType: TMsgDlgType;
  AButtons: TMsgDlgButtons; AHelpCtx: Longint): TModalResult;
procedure MD3ShowMessage(const AMsg: string);

procedure Register;

implementation

{$IFDEF WINDOWS}
function CreateRoundRectRgn(X1, Y1, X2, Y2, W, H: Integer): HRGN;
  stdcall; external 'gdi32.dll';
function SetWindowRgn(hWnd: HWND; hRgn: HRGN; bRedraw: LongBool): Integer;
  stdcall; external 'user32.dll';
{$ENDIF}

const
  PADDING             = 24;
  BTN_H               = 40;
  BTN_GAP             = 8;
  TITLE_GAP           = 16;
  CONTENT_GAP         = 24;
  ICON_SIZE           = 24;
  ICON_GAP            = 16;
  DLG_MIN_W           = 280;
  DLG_MAX_W           = 560;
  DLG_PREF_W          = 420;
  ANIM_DURATION       = 200; { ms }
  ANIM_INTERVAL       = 16;  { ~60 fps }
  CORNER_RADIUS       = 28;  { MD3 extra-large shape }
  MAX_CONTENT_DEFAULT = 320; { max content height before scroll }

type
  { ── Internal scrim + dialog form ── }

  TFRDialogPanel = class(TCustomControl)
  private
    FPaintCache: TBGRABitmap;
    FIconBmp: TBGRABitmap;
    FIconLeft: Integer;
    FIconTop: Integer;
    FScrimAlpha: Byte;
    procedure InvalidateCache;
  protected
    procedure Paint; override;
    procedure WMEraseBkgnd(var Msg: TLMEraseBkgnd); message LM_ERASEBKGND;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TFRDialogForm = class(TForm)
  private
    FResult: TFRMDDialogResult;
    FDialogPanel: TFRDialogPanel;
    FDefaultBtn: TFRMaterialButton;
    FDismissOnScrim: Boolean;
    FDismissOnEscape: Boolean;
    FScrimOpacity: Byte;
    FLblTitle: TLabel;
    FLblContent: TLabel;
    FScrollBox: TScrollBox;
    FBtnList: TFPList;
    { Backdrop — captured screen content for see-through scrim }
    FBackdrop: TBGRABitmap;
    { Scrim cache }
    FScrimCache: TBGRABitmap;
    FScrimCacheW: Integer;
    FScrimCacheH: Integer;
    FScrimCacheAlpha: Byte;
    { Animation state }
    FAnimTimer: TTimer;
    FAnimProgress: Single; { 0..1 }
    FAnimating: Boolean;
    FTargetPanelLeft: Integer;
    FTargetPanelTop: Integer;
    procedure BtnClick(Sender: TObject);
    procedure DialogShow(Sender: TObject);
    procedure ScrimClick(Sender: TObject);
    procedure DoAnimTick(Sender: TObject);
    procedure StartAnimation;
    procedure CaptureBackdrop;
    procedure ApplyCardRegion;
    function EaseOutCubic(T: Single): Single;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor CreateDialog(ATitle, AContent: string;
      AButtons: TFRMDDialogButtons; AIcon: TFRMDDialogIcon;
      ACustomIcon: TFRIconMode; ADismissOnScrim, ADismissOnEscape: Boolean;
      const ACaptionOK, ACaptionCancel, ACaptionYes, ACaptionNo, ACaptionClose: string;
      AMaxContentH: Integer; AScrimOpacity: Byte);
    destructor Destroy; override;
  end;

{ ── TFRDialogPanel — rounded card with cache ── }

constructor TFRDialogPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  { csOpaque: we paint every pixel ourselves — prevents LCL from filling
    a solid Color rectangle that would hide the rounded corners. }
  ControlStyle := ControlStyle + [csOpaque];
end;

procedure TFRDialogPanel.WMEraseBkgnd(var Msg: TLMEraseBkgnd);
begin
  { Block LCL from painting the background — we handle it entirely in Paint }
  Msg.Result := 1;
end;

procedure TFRDialogPanel.InvalidateCache;
begin
  FreeAndNil(FPaintCache);
end;

procedure TFRDialogPanel.Paint;
var
  dlgForm: TFRDialogForm;
  scrimAlpha: Byte;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  dlgForm := nil;
  if Owner is TFRDialogForm then
    dlgForm := TFRDialogForm(Owner);

  if FPaintCache = nil then
  begin
    FPaintCache := TBGRABitmap.Create(Width, Height, BGRA(0, 0, 0, 0));

    { 1. Backdrop — copy the captured screen region at our position,
      so corners show the real content behind the scrim. }
    if Assigned(dlgForm) and Assigned(dlgForm.FBackdrop) then
      FPaintCache.PutImage(-Left, -Top, dlgForm.FBackdrop, dmSet)
    else
      FPaintCache.Fill(BGRA(0, 0, 0, 255));

    { 2. Scrim overlay — match the form's current alpha (animated or final). }
    if Assigned(dlgForm) then
    begin
      if dlgForm.FAnimating then
        scrimAlpha := EnsureRange(dlgForm.Tag, 0, 255)
      else
        scrimAlpha := dlgForm.FScrimOpacity;
    end
    else
      scrimAlpha := 128;

    FPaintCache.FillRect(0, 0, Width, Height,
      BGRA(0, 0, 0, scrimAlpha), dmDrawWithTransparency);

    { 3. Rounded card — use pixel-edge coordinates (-0.5 .. W-0.5) so
      straight edges are fully opaque; only corners get anti-aliased. }
    FPaintCache.FillRoundRectAntialias(-0.5, -0.5, Width - 0.5, Height - 0.5,
      CORNER_RADIUS, CORNER_RADIUS,
      ColorToBGRA(MD3Colors.SurfaceContainerHigh));

    { 4. Icon }
    if Assigned(FIconBmp) then
      FPaintCache.PutImage(FIconLeft, FIconTop, FIconBmp, dmDrawWithTransparency);
  end;

  { Opaque blit — all pixels are fully composited (alpha=255). }
  FPaintCache.Draw(Canvas, 0, 0, False);
end;

destructor TFRDialogPanel.Destroy;
begin
  FreeAndNil(FPaintCache);
  FreeAndNil(FIconBmp);
  inherited Destroy;
end;

{ ── TFRDialogForm ── }

function TFRDialogForm.EaseOutCubic(T: Single): Single;
begin
  T := T - 1.0;
  Result := T * T * T + 1.0;
end;

procedure TFRDialogForm.DoAnimTick(Sender: TObject);
var
  step: Single;
  easedAlpha: Byte;
  scale: Single;
begin
  step := ANIM_INTERVAL / ANIM_DURATION;
  FAnimProgress := FAnimProgress + step;
  if FAnimProgress >= 1.0 then
  begin
    FAnimProgress := 1.0;
    FAnimating := False;
    FAnimTimer.Enabled := False;
    { Focus the default button after animation — panel is now visible }
    if Assigned(FDefaultBtn) and FDefaultBtn.Visible and FDefaultBtn.Enabled then
      ActiveControl := FDefaultBtn;
  end;

  { Apply eased values }
  scale := 0.85 + 0.15 * EaseOutCubic(FAnimProgress);
  easedAlpha := EnsureRange(Round(FScrimOpacity * EaseOutCubic(FAnimProgress)), 0, 255);

  if Assigned(FDialogPanel) then
  begin
    FDialogPanel.Width := Round(DLG_PREF_W * scale);
    FDialogPanel.Height := Round(FDialogPanel.Tag * scale); { Tag stores target height }
    FDialogPanel.Left := (ClientWidth - FDialogPanel.Width) div 2;
    FDialogPanel.Top := (ClientHeight - FDialogPanel.Height) div 2;
    FDialogPanel.InvalidateCache;
    FDialogPanel.Visible := True;
    ApplyCardRegion;
  end;

  { Repaint scrim with animated alpha }
  Tag := easedAlpha; { store current scrim alpha in form Tag }
  Invalidate;
end;

procedure TFRDialogForm.StartAnimation;
begin
  FAnimProgress := 0;
  FAnimating := True;
  Tag := 0; { initial scrim alpha }
  if Assigned(FDialogPanel) then
    FDialogPanel.Visible := False;

  FAnimTimer := TTimer.Create(Self);
  FAnimTimer.Interval := ANIM_INTERVAL;
  FAnimTimer.OnTimer := @DoAnimTick;
  FAnimTimer.Enabled := True;
end;

constructor TFRDialogForm.CreateDialog(ATitle, AContent: string;
  AButtons: TFRMDDialogButtons; AIcon: TFRMDDialogIcon;
  ACustomIcon: TFRIconMode; ADismissOnScrim, ADismissOnEscape: Boolean;
  const ACaptionOK, ACaptionCancel, ACaptionYes, ACaptionNo, ACaptionClose: string;
  AMaxContentH: Integer; AScrimOpacity: Byte);
var
  btn: TFRMaterialButton;
  btnX, titleH, contentH, contentTop, dlgHeight, curY: Integer;
  dlgWidth, maxContentH: Integer;
  R: TRect;
  iconMode: TFRIconMode;
  hexColor: string;
  themeFontName: string;

  procedure AddBtn(ABtnType: TFRMDDialogButton; const ACaption: string;
    AStyle: TFRMDButtonStyle);
  begin
    btn := TFRMaterialButton.Create(Self);
    btn.Parent := FDialogPanel;
    btn.Caption := ACaption;
    btn.Tag := Ord(ABtnType);
    btn.OnClick := @BtnClick;
    btn.ButtonStyle := AStyle;
    btn.Height := BTN_H;
    btn.TabStop := True;
    Canvas.Font.Name := themeFontName;
    Canvas.Font.Size := 10;
    btn.Width := Canvas.TextWidth(ACaption) + 48;
    if btn.Width < 90 then btn.Width := 90;
    btnX := btnX - btn.Width - BTN_GAP;
    btn.Left := btnX + BTN_GAP;
    btn.Top := dlgHeight - PADDING - BTN_H;
    btn.Anchors := [akRight, akBottom];
    if (AStyle = mbsFilled) and (FDefaultBtn = nil) then
      FDefaultBtn := btn;
    FBtnList.Add(btn);
  end;

begin
  inherited CreateNew(nil);
  FResult := drNone;
  FDefaultBtn := nil;
  FDismissOnScrim := ADismissOnScrim;
  FDismissOnEscape := ADismissOnEscape;
  FScrimOpacity := AScrimOpacity;
  FBtnList := TFPList.Create;
  FAnimTimer := nil;

  BorderStyle := bsNone;
  Position := poDesigned;
  Color := clBlack;
  KeyPreview := True;
  OnShow := @DialogShow;
  OnClick := @ScrimClick;
  SetBounds(0, 0, Screen.Width, Screen.Height);

  { Theme font — use system font from theme, fallback to Segoe UI }
  themeFontName := Screen.SystemFont.Name;
  if themeFontName = '' then themeFontName := 'Segoe UI';

  Font.Name := themeFontName;
  Font.Quality := fqClearTypeNatural;

  { Responsive width }
  dlgWidth := DLG_PREF_W;
  if Screen.Width > 0 then
  begin
    if dlgWidth > Screen.Width - 64 then
      dlgWidth := Screen.Width - 64;
  end;
  dlgWidth := EnsureRange(dlgWidth, DLG_MIN_W, DLG_MAX_W);

  { Starting Y position }
  curY := PADDING;

  { If icon requested, reserve space }
  if AIcon <> diNone then
    curY := curY + ICON_SIZE + ICON_GAP;

  { Measure title height }
  Canvas.Font.Name := themeFontName;
  Canvas.Font.Size := 14;
  Canvas.Font.Style := [fsBold];
  titleH := Canvas.TextHeight('Tg');

  { Measure content text height with word-wrap }
  Canvas.Font.Name := themeFontName;
  Canvas.Font.Size := 10;
  Canvas.Font.Style := [];
  R := Rect(0, 0, dlgWidth - PADDING * 2, 0);
  DrawText(Canvas.Handle, PChar(AContent), Length(AContent), R,
    DT_CALCRECT or DT_WORDBREAK or DT_NOPREFIX);
  contentH := R.Bottom - R.Top;
  if contentH < Canvas.TextHeight('Tg') then
    contentH := Canvas.TextHeight('Tg');

  { Max content height — enable scroll if exceeded }
  maxContentH := AMaxContentH;
  if maxContentH <= 0 then
    maxContentH := MAX_CONTENT_DEFAULT;

  { Calculate dialog height }
  contentTop := curY + titleH + TITLE_GAP;
  dlgHeight := contentTop + Min(contentH + 4, maxContentH) + CONTENT_GAP + BTN_H + PADDING;
  if dlgHeight < 180 then dlgHeight := 180;

  { Dialog card panel }
  FDialogPanel := TFRDialogPanel.Create(Self);
  FDialogPanel.Parent := Self;
  FDialogPanel.Width := dlgWidth;
  FDialogPanel.Height := dlgHeight;
  FDialogPanel.Tag := dlgHeight; { store target height for animation }
  FDialogPanel.Anchors := [];
  FDialogPanel.FScrimAlpha := 0;
  FDialogPanel.Color := MD3Colors.SurfaceContainerHigh;  { matches card — opaque draw prevents bleed }

  { Capture the screen content for see-through scrim }
  CaptureBackdrop;

  { Icon — rendered directly on the panel's BGRABitmap }
  if AIcon <> diNone then
  begin
    case AIcon of
      diWarning: iconMode := imWarning;
      diInfo:    iconMode := imInfo;
      diError:   iconMode := imError;
      diSuccess: iconMode := imSuccess;
      diHelp:    iconMode := imHelp;
      diCustom:  iconMode := ACustomIcon;
    else
      iconMode := imInfo;
    end;
    hexColor := FRColorToSVGHex(MD3Colors.Primary);
    FDialogPanel.FIconBmp := FRRenderSVGIcon(
      FRGetIconSVG(iconMode, hexColor, 2.0), ICON_SIZE, ICON_SIZE);
    FDialogPanel.FIconLeft := (dlgWidth - ICON_SIZE) div 2;
    FDialogPanel.FIconTop := PADDING;
  end;

  { Title — centered when icon present, left-aligned otherwise }
  FLblTitle := TLabel.Create(Self);
  FLblTitle.Parent := FDialogPanel;
  FLblTitle.Top := curY;
  FLblTitle.AutoSize := False;
  FLblTitle.Width := dlgWidth - PADDING * 2;
  FLblTitle.Height := titleH + 4;
  FLblTitle.Layout := tlCenter;
  FLblTitle.Caption := ATitle;
  FLblTitle.Transparent := True;
  FLblTitle.ParentFont := False;
  FLblTitle.Font.Name := themeFontName;
  FLblTitle.Font.Size := 14;
  FLblTitle.Font.Style := [fsBold];
  FLblTitle.Font.Color := MD3Colors.OnSurface;
  FLblTitle.Left := PADDING;
  if AIcon <> diNone then
    FLblTitle.Alignment := taCenter;

  { Content — scrollable if exceeds max height }
  if contentH + 4 > maxContentH then
  begin
    FScrollBox := TScrollBox.Create(Self);
    FScrollBox.Parent := FDialogPanel;
    FScrollBox.Left := PADDING;
    FScrollBox.Top := contentTop;
    FScrollBox.Width := dlgWidth - PADDING * 2;
    FScrollBox.Height := maxContentH;
    FScrollBox.BorderStyle := bsNone;
    FScrollBox.Color := MD3Colors.SurfaceContainerHigh;
    FScrollBox.HorzScrollBar.Visible := False;
    FScrollBox.VertScrollBar.Smooth := True;
    FScrollBox.VertScrollBar.Tracking := True;
    FScrollBox.Anchors := [akLeft, akTop, akRight];

    FLblContent := TLabel.Create(Self);
    FLblContent.Parent := FScrollBox;
    FLblContent.Left := 0;
    FLblContent.Top := 0;
    FLblContent.AutoSize := False;
    FLblContent.Width := FScrollBox.ClientWidth - 16; { scrollbar space }
    FLblContent.Height := contentH + 4;
    FLblContent.WordWrap := True;
    FLblContent.Caption := AContent;
    FLblContent.Transparent := True;
    FLblContent.ParentFont := False;
    FLblContent.Font.Name := themeFontName;
    FLblContent.Font.Size := 10;
    FLblContent.Font.Style := [];
    FLblContent.Font.Color := MD3Colors.OnSurfaceVariant;
  end
  else
  begin
    FScrollBox := nil;
    FLblContent := TLabel.Create(Self);
    FLblContent.Parent := FDialogPanel;
    FLblContent.Left := PADDING;
    FLblContent.Top := contentTop;
    FLblContent.AutoSize := False;
    FLblContent.Width := dlgWidth - PADDING * 2;
    FLblContent.Height := contentH + 4;
    FLblContent.WordWrap := True;
    FLblContent.Caption := AContent;
    FLblContent.Transparent := True;
    FLblContent.ParentFont := False;
    FLblContent.Font.Name := themeFontName;
    FLblContent.Font.Size := 10;
    FLblContent.Font.Style := [];
    FLblContent.Font.Color := MD3Colors.OnSurfaceVariant;
  end;

  { Buttons — right-aligned, confirm on right }
  btnX := dlgWidth - PADDING;

  if dbOK in AButtons then
    AddBtn(dbOK, ACaptionOK, mbsFilled);
  if dbYes in AButtons then
    AddBtn(dbYes, ACaptionYes, mbsFilled);
  if dbClose in AButtons then
    AddBtn(dbClose, ACaptionClose, mbsText);
  if dbNo in AButtons then
    AddBtn(dbNo, ACaptionNo, mbsOutlined);
  if dbCancel in AButtons then
    AddBtn(dbCancel, ACaptionCancel, mbsText);
end;

destructor TFRDialogForm.Destroy;
begin
  FreeAndNil(FBackdrop);
  FreeAndNil(FScrimCache);
  FreeAndNil(FBtnList);
  inherited Destroy;
end;

procedure TFRDialogForm.DialogShow(Sender: TObject);
begin
  { Center panel }
  if Assigned(FDialogPanel) then
  begin
    FTargetPanelLeft := (ClientWidth - FDialogPanel.Width) div 2;
    FTargetPanelTop := (ClientHeight - FDialogPanel.Height) div 2;
    FDialogPanel.Left := FTargetPanelLeft;
    FDialogPanel.Top := FTargetPanelTop;
  end;

  { Aplica regiao arredondada no painel do card }
  ApplyCardRegion;

  { Start entrance animation }
  StartAnimation;
  { ActiveControl is set after animation completes in DoAnimTick }
end;

procedure TFRDialogForm.CaptureBackdrop;
var
  DC: HDC;
  bmp: TBitmap;
  w, h: Integer;
begin
  { Ensure any pending paints are flushed so we capture fresh content }
  Application.ProcessMessages;

  bmp := TBitmap.Create;
  try
    w := Screen.Width;
    h := Screen.Height;
    bmp.SetSize(w, h);

    { Capture current screen via BitBlt — most reliable on Windows,
      captures the actual visible content including all windows. }
    DC := GetDC(0);
    try
      BitBlt(bmp.Canvas.Handle, 0, 0, w, h, DC, 0, 0, SRCCOPY);
    finally
      ReleaseDC(0, DC);
    end;

    FBackdrop := TBGRABitmap.Create(bmp);
    { Windows TBitmap 32-bit often has alpha=0 in all pixels.
      Force fully opaque so compositing in panel corners works. }
    FBackdrop.AlphaFill(255, 0, FBackdrop.NbPixels);
  finally
    bmp.Free;
  end;
end;

procedure TFRDialogForm.ApplyCardRegion;
{$IFDEF WINDOWS}
var
  panelW, panelH, R: Integer;
{$ENDIF}
begin
  {$IFDEF WINDOWS}
  if not Assigned(FDialogPanel) then Exit;
  if not FDialogPanel.HandleAllocated then Exit;

  panelW := FDialogPanel.Width;
  panelH := FDialogPanel.Height;
  R := CORNER_RADIUS;

  { Pixel-perfect expansion: GDI region 1px larger que o BGRA rounded rect,
    preservando os pixels anti-aliased na borda. Mesmo padrao do Snackbar
    e do Combo popup. }
  SetWindowRgn(FDialogPanel.Handle,
    CreateRoundRectRgn(-1, -1, panelW + 2, panelH + 2,
      R * 2 + 2, R * 2 + 2), True);
  {$ENDIF}
end;

procedure TFRDialogForm.Paint;
var
  scrimAlpha: Byte;
  needsRebuild: Boolean;
begin
  if (ClientWidth <= 0) or (ClientHeight <= 0) then Exit;

  { Draw captured backdrop opaque (alpha forced to 255 in CaptureBackdrop) }
  if Assigned(FBackdrop) then
    FBackdrop.Draw(Canvas, 0, 0, False);

  { Scrim alpha — animated or full }
  if FAnimating then
    scrimAlpha := EnsureRange(Tag, 0, 255)
  else
    scrimAlpha := FScrimOpacity;

  { Cache the scrim bitmap — only rebuild on size or alpha change }
  needsRebuild := (FScrimCache = nil)
    or (FScrimCacheW <> ClientWidth)
    or (FScrimCacheH <> ClientHeight)
    or (FScrimCacheAlpha <> scrimAlpha);

  if needsRebuild then
  begin
    FreeAndNil(FScrimCache);
    FScrimCache := TBGRABitmap.Create(ClientWidth, ClientHeight, BGRA(0, 0, 0, scrimAlpha));
    FScrimCacheW := ClientWidth;
    FScrimCacheH := ClientHeight;
    FScrimCacheAlpha := scrimAlpha;
  end;

  { Alpha-blend scrim over the backdrop }
  FScrimCache.Draw(Canvas, 0, 0, True);
end;

procedure TFRDialogForm.Resize;
begin
  inherited Resize;
  if Assigned(FDialogPanel) then
  begin
    FDialogPanel.Left := (ClientWidth - FDialogPanel.Width) div 2;
    FDialogPanel.Top := (ClientHeight - FDialogPanel.Height) div 2;
    FDialogPanel.InvalidateCache;
  end;
end;

procedure TFRDialogForm.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key = VK_ESCAPE) and FDismissOnEscape then
  begin
    FResult := drCancel;
    ModalResult := mrCancel;
  end;
end;

procedure TFRDialogForm.ScrimClick(Sender: TObject);
var
  pt: TPoint;
begin
  if not FDismissOnScrim then Exit;
  pt := ScreenToClient(Mouse.CursorPos);
  { Only dismiss if click is outside the dialog panel }
  if Assigned(FDialogPanel) then
  begin
    if not PtInRect(FDialogPanel.BoundsRect, pt) then
    begin
      FResult := drCancel;
      ModalResult := mrCancel;
    end;
  end;
end;

procedure TFRDialogForm.BtnClick(Sender: TObject);
begin
  case TFRMDDialogButton(TControl(Sender).Tag) of
    dbOK:     FResult := drOK;
    dbCancel: FResult := drCancel;
    dbYes:    FResult := drYes;
    dbNo:     FResult := drNo;
    dbClose:  FResult := drClose;
  end;
  ModalResult := mrOk;
end;

{ ── TFRMaterialDialog ── }

constructor TFRMaterialDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTitle           := 'Título';
  FContent         := 'Conteúdo da mensagem.';
  FButtons         := [dbOK, dbCancel];
  FDialogIcon      := diNone;
  FCustomIcon      := imInfo;
  FDismissOnScrim  := True;
  FDismissOnEscape := True;
  FCaptionOK       := 'OK';
  FCaptionCancel   := 'Cancelar';
  FCaptionYes      := 'Sim';
  FCaptionNo       := 'Não';
  FCaptionClose    := 'Fechar';
  FScrimOpacity    := 128;
  FMaxContentHeight := 0;

  FRMDRegisterComponent(Self);
end;

destructor TFRMaterialDialog.Destroy;
begin
  FRMDUnregisterComponent(Self);
  inherited Destroy;
end;

procedure TFRMaterialDialog.ApplyTheme(const AThemeManager: TObject);
var
  i: Integer;
  frm: TFRDialogForm;
begin
  if not Assigned(AThemeManager) then Exit;
  { Update any currently showing dialog }
  for i := 0 to Screen.FormCount - 1 do
    if Screen.Forms[i] is TFRDialogForm then
    begin
      frm := TFRDialogForm(Screen.Forms[i]);
      { Update label colors }
      if Assigned(frm.FLblTitle) then
        frm.FLblTitle.Font.Color := MD3Colors.OnSurface;
      if Assigned(frm.FLblContent) then
        frm.FLblContent.Font.Color := MD3Colors.OnSurfaceVariant;
      { Update panel background }
      if Assigned(frm.FDialogPanel) then
      begin
        frm.FDialogPanel.Color := MD3Colors.SurfaceContainerHigh;
        frm.FDialogPanel.InvalidateCache;
        frm.FDialogPanel.Invalidate;
      end;
      { Scrollbox background }
      if Assigned(frm.FScrollBox) then
        frm.FScrollBox.Color := MD3Colors.SurfaceContainerHigh;
      frm.Invalidate;
    end;
end;

procedure TFRMaterialDialog.SetTitle(const AValue: string);
begin
  FTitle := AValue;
end;

procedure TFRMaterialDialog.SetContent(const AValue: string);
begin
  FContent := AValue;
end;

function TFRMaterialDialog.Execute: TFRMDDialogResult;
var
  dlg: TFRDialogForm;
begin
  dlg := TFRDialogForm.CreateDialog(FTitle, FContent, FButtons, FDialogIcon,
    FCustomIcon, FDismissOnScrim, FDismissOnEscape,
    FCaptionOK, FCaptionCancel, FCaptionYes, FCaptionNo, FCaptionClose,
    FMaxContentHeight, FScrimOpacity);
  try
    dlg.ShowModal;
    Result := dlg.FResult;
  finally
    dlg.Free;
  end;
end;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialdialog_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialDialog]);
end;

function MessageDialog(const ATitle, AContent: string;
  AIcon: TFRMDDialogIcon; AButtons: TFRMDDialogButtons): TFRMDDialogResult;
begin
  with TFRMaterialDialog.Create(nil) do
  try
    Title      := ATitle;
    Content    := AContent;
    DialogIcon := AIcon;
    Buttons    := AButtons;
    Result     := Execute;
  finally
    Free;
  end;
end;

{ ── Drop-in wrappers ── }

function MsgDlgTypeToIcon(AType: TMsgDlgType): TFRMDDialogIcon;
begin
  case AType of
    mtWarning:      Result := diWarning;
    mtError:        Result := diError;
    mtInformation:  Result := diInfo;
    mtConfirmation: Result := diInfo;
    mtCustom:       Result := diNone;
  else
    Result := diNone;
  end;
end;

function MsgDlgBtnsToMD3(ABtns: TMsgDlgButtons): TFRMDDialogButtons;
begin
  Result := [];
  if mbOK in ABtns      then Include(Result, dbOK);
  if mbCancel in ABtns   then Include(Result, dbCancel);
  if mbYes in ABtns      then Include(Result, dbYes);
  if mbNo in ABtns       then Include(Result, dbNo);
  if mbClose in ABtns    then Include(Result, dbClose);
end;

function MD3ResultToModalResult(AResult: TFRMDDialogResult): TModalResult;
begin
  case AResult of
    drOK:     Result := mrOK;
    drCancel: Result := mrCancel;
    drYes:    Result := mrYes;
    drNo:     Result := mrNo;
    drClose:  Result := mrClose;
  else
    Result := mrNone;
  end;
end;

function MD3MessageDlg(const ATitle, AContent: string; AType: TMsgDlgType;
  AButtons: TMsgDlgButtons; AHelpCtx: Longint): TModalResult;
var
  DR: TFRMDDialogResult;
begin
  DR := MessageDialog(ATitle, AContent,
          MsgDlgTypeToIcon(AType),
          MsgDlgBtnsToMD3(AButtons));
  Result := MD3ResultToModalResult(DR);
end;

procedure MD3ShowMessage(const AMsg: string);
begin
  MessageDialog('', AMsg, diNone, [dbOK]);
end;

end.

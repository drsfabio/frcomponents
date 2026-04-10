unit FRMaterial3Snackbar;

{$mode objfpc}{$H+}

{ Material Design 3 — Snackbar.

  TFRMaterialSnackbar — Non-visual component for showing snackbar notifications.
  Call Show to display at the bottom (or top) of the parent form.

  Features:
    • Slide-up / slide-down entrance animation with EaseOutCubic
    • Fade-out exit animation
    • Multiline support with dynamic height
    • Optional close (X) button
    • Optional leading icon
    • Configurable position (top / bottom)
    • Snackbar types with MD3 color mapping (Default, Info, Success, Warning, Error)
    • OnShow / OnHide events

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, Forms, ExtCtrls,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterialTheme, FRMaterial3Base,
  FRMaterialIcons;

type
  { Snackbar position }
  TFRMDSnackbarPosition = (spBottom, spTop);

  { Snackbar type — controls color scheme }
  TFRMDSnackbarType = (
    stDefault,   // InverseSurface / InverseOnSurface (MD3 standard)
    stInfo,      // Primary container colors
    stSuccess,   // Tertiary container colors (green-ish)
    stWarning,   // Secondary container colors (amber-ish)
    stError      // Error container colors
  );

  TFRMaterialSnackbar = class(TComponent, IFRMaterialComponent)
  private
    FMessage: string;
    FActionText: string;
    FDuration: Integer;
    FShowCloseButton: Boolean;
    FLeadingIcon: TFRIconMode;
    FPosition: TFRMDSnackbarPosition;
    FSnackbarType: TFRMDSnackbarType;
    FOnAction: TNotifyEvent;
    FOnShow: TNotifyEvent;
    FOnHide: TNotifyEvent;
    FPanel: TCustomControl;
    FTimer: TTimer;
    FAnimTimer: TTimer;
    FAnimProgress: Single;
    FAnimClosing: Boolean;
    procedure OnTimerFire(Sender: TObject);
    procedure OnActionClick(Sender: TObject);
    procedure OnCloseClick(Sender: TObject);
    procedure DoAnimTick(Sender: TObject);
    procedure StartEntranceAnim;
    procedure StartExitAnim;
    function EaseOutCubic(T: Single): Single;
    function EaseInCubic(T: Single): Single;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Show; overload;
    procedure Show(const AMessage: string); overload;
    procedure Show(const AMessage, AAction: string); overload;
    procedure Show(const AMessage: string; AType: TFRMDSnackbarType); overload;
    procedure Show(const AMessage, AAction: string; AType: TFRMDSnackbarType); overload;
    procedure Hide;
    procedure ApplyTheme(const AThemeManager: TObject); virtual;
  published
    property Message: string read FMessage write FMessage;
    property ActionText: string read FActionText write FActionText;
    property Duration: Integer read FDuration write FDuration default 4000;
    property ShowCloseButton: Boolean read FShowCloseButton write FShowCloseButton default False;
    property LeadingIcon: TFRIconMode read FLeadingIcon write FLeadingIcon default imClear;
    property Position: TFRMDSnackbarPosition read FPosition write FPosition default spBottom;
    property SnackbarType: TFRMDSnackbarType read FSnackbarType write FSnackbarType default stDefault;
    property OnAction: TNotifyEvent read FOnAction write FOnAction;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnHide: TNotifyEvent read FOnHide write FOnHide;
  end;

procedure Register;

implementation

uses Math, StdCtrls, LCLType, LCLIntf;

const
  ANIM_DURATION = 250; { ms — MD3 standard duration }
  ANIM_INTERVAL = 16;  { ~60 fps }
  EXIT_DURATION = 200;  { ms — slightly faster exit }
  SNACKBAR_MARGIN = 16;
  SNACKBAR_PADDING_H = 16;
  SNACKBAR_PADDING_V = 14;
  SNACKBAR_MIN_H = 48;
  SNACKBAR_RADIUS = 4;
  ICON_SIZE = 24;
  CLOSE_BTN_SIZE = 24;
  ACTION_GAP = 8;

type
  TSnackbarPanel = class(TCustomControl)
  private
    FSnackbar: TFRMaterialSnackbar;
    FPaintCache: TBGRABitmap;
    FPaintCacheW: Integer;
    FPaintCacheH: Integer;
    FIconCache: TBGRABitmap;
    FCloseIconCache: TBGRABitmap;
    FAlpha: Byte;
    procedure InvalidatePaintCache;
    procedure GetTypeColors(out ABg, AText, AAction, AIconColor: TColor);
    function CalcContentHeight(AMaxTextW: Integer): Integer;
  protected
    function PaintCached(ABmp: TBGRABitmap): Boolean; virtual;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    destructor Destroy; override;
  end;

{ ── Color helpers ── }

procedure TSnackbarPanel.GetTypeColors(out ABg, AText, AAction, AIconColor: TColor);
begin
  case FSnackbar.FSnackbarType of
    stInfo:
    begin
      ABg := MD3Colors.PrimaryContainer;
      AText := MD3Colors.OnPrimaryContainer;
      AAction := MD3Colors.Primary;
      AIconColor := MD3Colors.Primary;
    end;
    stSuccess:
    begin
      ABg := MD3Colors.TertiaryContainer;
      AText := MD3Colors.OnTertiaryContainer;
      AAction := MD3Colors.Tertiary;
      AIconColor := MD3Colors.Tertiary;
    end;
    stWarning:
    begin
      ABg := MD3Colors.SecondaryContainer;
      AText := MD3Colors.OnSecondaryContainer;
      AAction := MD3Colors.Secondary;
      AIconColor := MD3Colors.Secondary;
    end;
    stError:
    begin
      ABg := MD3Colors.ErrorContainer;
      AText := MD3Colors.OnErrorContainer;
      AAction := MD3Colors.Error;
      AIconColor := MD3Colors.Error;
    end;
  else { stDefault }
    ABg := MD3Colors.InverseSurface;
    AText := MD3Colors.InverseOnSurface;
    AAction := MD3Colors.InversePrimary;
    AIconColor := MD3Colors.InverseOnSurface;
  end;
end;

function TSnackbarPanel.CalcContentHeight(AMaxTextW: Integer): Integer;
var
  R: TRect;
  flags: Cardinal;
begin
  R := Rect(0, 0, AMaxTextW, 0);
  Canvas.Font.Size := 10;
  flags := DT_CALCRECT or DT_WORDBREAK or DT_LEFT;
  DrawText(Canvas.Handle, PChar(FSnackbar.FMessage), Length(FSnackbar.FMessage), R, flags);
  Result := Max(SNACKBAR_MIN_H, R.Bottom - R.Top + SNACKBAR_PADDING_V * 2);
end;

destructor TSnackbarPanel.Destroy;
begin
  FreeAndNil(FPaintCache);
  FreeAndNil(FIconCache);
  FreeAndNil(FCloseIconCache);
  inherited Destroy;
end;

procedure TSnackbarPanel.InvalidatePaintCache;
begin
  FreeAndNil(FPaintCache);
  FPaintCacheW := 0;
  FPaintCacheH := 0;
end;

function TSnackbarPanel.PaintCached(ABmp: TBGRABitmap): Boolean;
var
  bgColor, txtColor, actColor, icoColor: TColor;
begin
  Result := True;
  GetTypeColors(bgColor, txtColor, actColor, icoColor);
  MD3DrawShadow(ABmp, 0, 0, Width - 1, Height - 1, SNACKBAR_RADIUS, elLevel3);
  MD3FillRoundRect(ABmp, 0, 0, Width - 1, Height - 1, SNACKBAR_RADIUS, bgColor);
end;

procedure TSnackbarPanel.Paint;
var
  aRect: TRect;
  textLeft, textRight: Integer;
  bgColor, txtColor, actColor, icoColor: TColor;
  hexColor: string;
  actionW: Integer;
  bmp: TBGRABitmap;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  GetTypeColors(bgColor, txtColor, actColor, icoColor);

  { Use paint cache if available and valid }
  if (FPaintCache = nil) or (FPaintCacheW <> Width) or (FPaintCacheH <> Height) then
  begin
    FreeAndNil(FPaintCache);
    FPaintCache := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
    FPaintCacheW := Width;
    FPaintCacheH := Height;
    PaintCached(FPaintCache);
  end;

  { Apply alpha for animation }
  if FAlpha < 255 then
  begin
    bmp := FPaintCache.Duplicate as TBGRABitmap;
    try
      bmp.ApplyGlobalOpacity(FAlpha);
      bmp.Draw(Canvas, 0, 0, False);
    finally
      bmp.Free;
    end;
  end
  else
    FPaintCache.Draw(Canvas, 0, 0, False);

  { Calculate text area }
  textLeft := SNACKBAR_PADDING_H;
  textRight := Width - SNACKBAR_PADDING_H;

  { Leading icon }
  if FSnackbar.FLeadingIcon <> imClear then
  begin
    hexColor := FRColorToSVGHex(icoColor);
    if FIconCache = nil then
      FIconCache := FRGetCachedIcon(FSnackbar.FLeadingIcon, hexColor, 2.0, ICON_SIZE, ICON_SIZE);
    if Assigned(FIconCache) then
      FIconCache.Draw(Canvas, textLeft, (Height - ICON_SIZE) div 2, False);
    textLeft := textLeft + ICON_SIZE + 12;
  end;

  { Close button — draw X with canvas lines }
  if FSnackbar.FShowCloseButton then
  begin
    Canvas.Pen.Color := txtColor;
    Canvas.Pen.Width := 2;
    Canvas.Pen.Style := psSolid;
    Canvas.Line(
      textRight - CLOSE_BTN_SIZE + 6, (Height - CLOSE_BTN_SIZE) div 2 + 6,
      textRight - 6, (Height + CLOSE_BTN_SIZE) div 2 - 6
    );
    Canvas.Line(
      textRight - 6, (Height - CLOSE_BTN_SIZE) div 2 + 6,
      textRight - CLOSE_BTN_SIZE + 6, (Height + CLOSE_BTN_SIZE) div 2 - 6
    );
    textRight := textRight - CLOSE_BTN_SIZE - ACTION_GAP;
  end;

  { Action text }
  if FSnackbar.FActionText <> '' then
  begin
    Canvas.Font.Size := 10;
    actionW := Canvas.TextWidth(FSnackbar.FActionText) + 24;
    aRect := Rect(textRight - actionW, 0, textRight, Height);
    MD3DrawText(Canvas, FSnackbar.FActionText, aRect, actColor, taRightJustify, True);
    textRight := textRight - actionW - ACTION_GAP;
  end;

  { Message text — multiline uses DrawText with DT_WORDBREAK,
    single-line uses MD3DrawText with vertical centering }
  aRect := Rect(textLeft, SNACKBAR_PADDING_V, textRight, Height - SNACKBAR_PADDING_V);
  if Height > SNACKBAR_MIN_H then
  begin
    Canvas.Font.Size := 10;
    Canvas.Font.Color := txtColor;
    Canvas.Brush.Style := bsClear;
    DrawText(Canvas.Handle, PChar(FSnackbar.FMessage), Length(FSnackbar.FMessage),
      aRect, DT_LEFT or DT_WORDBREAK);
  end
  else
    MD3DrawText(Canvas, FSnackbar.FMessage, aRect, txtColor, taLeftJustify, True);
end;

procedure TSnackbarPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  bgColor, txtColor, actColor, icoColor: TColor;
  closeLeft, actionLeft, actionW: Integer;
begin
  inherited;
  if Button <> mbLeft then Exit;

  GetTypeColors(bgColor, txtColor, actColor, icoColor);

  { Check close button hit }
  closeLeft := Width - SNACKBAR_PADDING_H - CLOSE_BTN_SIZE;
  if FSnackbar.FShowCloseButton and (X >= closeLeft) then
  begin
    FSnackbar.OnCloseClick(Self);
    Exit;
  end;

  { Check action text hit }
  if FSnackbar.FActionText <> '' then
  begin
    Canvas.Font.Size := 10;
    actionW := Canvas.TextWidth(FSnackbar.FActionText) + 24;
    if FSnackbar.FShowCloseButton then
      actionLeft := closeLeft - ACTION_GAP - actionW
    else
      actionLeft := Width - SNACKBAR_PADDING_H - actionW;
    if X >= actionLeft then
      FSnackbar.OnActionClick(Self);
  end;
end;

{ ── TFRMaterialSnackbar ── }

constructor TFRMaterialSnackbar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMessage := '';
  FActionText := '';
  FDuration := 4000;
  FShowCloseButton := False;
  FLeadingIcon := imClear;
  FPosition := spBottom;
  FSnackbarType := stDefault;
  FPanel := nil;

  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.OnTimer := @OnTimerFire;

  FAnimTimer := TTimer.Create(Self);
  FAnimTimer.Interval := ANIM_INTERVAL;
  FAnimTimer.Enabled := False;
  FAnimTimer.OnTimer := @DoAnimTick;

  FAnimProgress := 0;
  FAnimClosing := False;

  FRMDRegisterComponent(Self);
end;

destructor TFRMaterialSnackbar.Destroy;
begin
  FAnimTimer.Enabled := False;
  FTimer.Enabled := False;
  if Assigned(FPanel) then
  begin
    FPanel.Free;
    FPanel := nil;
  end;
  FAnimTimer.Free;
  FTimer.Free;

  FRMDUnregisterComponent(Self);

  inherited Destroy;
end;

procedure TFRMaterialSnackbar.ApplyTheme(const AThemeManager: TObject);
begin
  if not Assigned(AThemeManager) then Exit;
  if Assigned(FPanel) then
  begin
    TSnackbarPanel(FPanel).InvalidatePaintCache;
    FreeAndNil(TSnackbarPanel(FPanel).FIconCache);
    FreeAndNil(TSnackbarPanel(FPanel).FCloseIconCache);
    FPanel.Invalidate;
  end;
end;

function TFRMaterialSnackbar.EaseOutCubic(T: Single): Single;
begin
  T := T - 1.0;
  Result := T * T * T + 1.0;
end;

function TFRMaterialSnackbar.EaseInCubic(T: Single): Single;
begin
  Result := T * T * T;
end;

procedure TFRMaterialSnackbar.DoAnimTick(Sender: TObject);
var
  step: Single;
  eased: Single;
  targetTop, startTop: Integer;
  ownerForm: TCustomForm;
  snkPanel: TSnackbarPanel;
begin
  if not Assigned(FPanel) then
  begin
    FAnimTimer.Enabled := False;
    Exit;
  end;

  snkPanel := TSnackbarPanel(FPanel);
  ownerForm := snkPanel.Parent as TCustomForm;

  if FAnimClosing then
  begin
    { Exit animation — fade out + slide away }
    step := ANIM_INTERVAL / EXIT_DURATION;
    FAnimProgress := FAnimProgress + step;
    if FAnimProgress >= 1.0 then
    begin
      FAnimProgress := 1.0;
      FAnimTimer.Enabled := False;
      { Actually destroy the panel }
      FPanel.Free;
      FPanel := nil;
      if Assigned(FOnHide) then
        FOnHide(Self);
      Exit;
    end;
    eased := EaseInCubic(FAnimProgress);
    snkPanel.FAlpha := EnsureRange(Round(255 * (1.0 - eased)), 0, 255);

    if FPosition = spBottom then
    begin
      startTop := ownerForm.ClientHeight - SNACKBAR_MARGIN - snkPanel.Height;
      targetTop := ownerForm.ClientHeight;
      snkPanel.Top := startTop + Round((targetTop - startTop) * eased);
    end
    else
    begin
      startTop := SNACKBAR_MARGIN;
      targetTop := -snkPanel.Height;
      snkPanel.Top := startTop + Round((targetTop - startTop) * eased);
    end;
    snkPanel.Invalidate;
  end
  else
  begin
    { Entrance animation — slide in + fade in }
    step := ANIM_INTERVAL / ANIM_DURATION;
    FAnimProgress := FAnimProgress + step;
    if FAnimProgress >= 1.0 then
    begin
      FAnimProgress := 1.0;
      FAnimTimer.Enabled := False;
      { Start auto-hide timer }
      FTimer.Interval := FDuration;
      FTimer.Enabled := True;
      if Assigned(FOnShow) then
        FOnShow(Self);
    end;
    eased := EaseOutCubic(FAnimProgress);
    snkPanel.FAlpha := EnsureRange(Round(255 * eased), 0, 255);

    if FPosition = spBottom then
    begin
      startTop := ownerForm.ClientHeight;
      targetTop := ownerForm.ClientHeight - SNACKBAR_MARGIN - snkPanel.Height;
      snkPanel.Top := startTop + Round((targetTop - startTop) * eased);
    end
    else
    begin
      startTop := -snkPanel.Height;
      targetTop := SNACKBAR_MARGIN;
      snkPanel.Top := startTop + Round((targetTop - startTop) * eased);
    end;
    snkPanel.Invalidate;
  end;
end;

procedure TFRMaterialSnackbar.StartEntranceAnim;
begin
  FAnimProgress := 0;
  FAnimClosing := False;
  FAnimTimer.Enabled := True;
end;

procedure TFRMaterialSnackbar.StartExitAnim;
begin
  FTimer.Enabled := False;
  FAnimProgress := 0;
  FAnimClosing := True;
  FAnimTimer.Enabled := True;
end;

procedure TFRMaterialSnackbar.Show;
var
  ownerForm: TCustomForm;
  snkPanel: TSnackbarPanel;
  panelW, panelH: Integer;
  maxTextW: Integer;
begin
  { If already showing, hide without animation first }
  if Assigned(FPanel) then
  begin
    FAnimTimer.Enabled := False;
    FTimer.Enabled := False;
    FPanel.Free;
    FPanel := nil;
  end;

  ownerForm := nil;
  if Owner is TCustomForm then
    ownerForm := TCustomForm(Owner)
  else if (Owner is TControl) and Assigned(TControl(Owner).Parent) then
    ownerForm := GetParentForm(TControl(Owner));
  if ownerForm = nil then Exit;

  snkPanel := TSnackbarPanel.Create(ownerForm);
  snkPanel.FSnackbar := Self;
  snkPanel.FAlpha := 0;
  snkPanel.Parent := ownerForm;

  { Calculate width }
  panelW := ownerForm.ClientWidth - SNACKBAR_MARGIN * 2;

  { Calculate available text width for multiline measurement }
  maxTextW := panelW - SNACKBAR_PADDING_H * 2;
  if FLeadingIcon <> imClear then
    maxTextW := maxTextW - ICON_SIZE - 12;
  if FShowCloseButton then
    maxTextW := maxTextW - CLOSE_BTN_SIZE - ACTION_GAP;
  if FActionText <> '' then
  begin
    snkPanel.Canvas.Font.Size := 10;
    maxTextW := maxTextW - snkPanel.Canvas.TextWidth(FActionText) - 24 - ACTION_GAP;
  end;

  { Calculate height based on text }
  panelH := snkPanel.CalcContentHeight(maxTextW);

  snkPanel.Width := panelW;
  snkPanel.Height := panelH;
  snkPanel.Left := SNACKBAR_MARGIN;

  { Start off-screen for animation }
  if FPosition = spBottom then
    snkPanel.Top := ownerForm.ClientHeight  { below screen }
  else
    snkPanel.Top := -panelH;  { above screen }

  snkPanel.Anchors := [akLeft, akRight, akBottom];
  snkPanel.BringToFront;
  FPanel := snkPanel;
  FPanel.FreeNotification(Self);

  { Start entrance animation }
  StartEntranceAnim;
end;

procedure TFRMaterialSnackbar.Show(const AMessage: string);
begin
  FMessage := AMessage;
  Show;
end;

procedure TFRMaterialSnackbar.Show(const AMessage, AAction: string);
begin
  FMessage := AMessage;
  FActionText := AAction;
  Show;
end;

procedure TFRMaterialSnackbar.Show(const AMessage: string; AType: TFRMDSnackbarType);
begin
  FMessage := AMessage;
  FSnackbarType := AType;
  Show;
end;

procedure TFRMaterialSnackbar.Show(const AMessage, AAction: string; AType: TFRMDSnackbarType);
begin
  FMessage := AMessage;
  FActionText := AAction;
  FSnackbarType := AType;
  Show;
end;

procedure TFRMaterialSnackbar.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FPanel) then
    FPanel := nil;
end;

procedure TFRMaterialSnackbar.Hide;
begin
  if Assigned(FPanel) and not FAnimClosing then
    StartExitAnim
  else if Assigned(FPanel) then
  begin
    { Force hide if already animating out }
    FAnimTimer.Enabled := False;
    FTimer.Enabled := False;
    FPanel.Free;
    FPanel := nil;
    if Assigned(FOnHide) then
      FOnHide(Self);
  end;
end;

procedure TFRMaterialSnackbar.OnTimerFire(Sender: TObject);
begin
  FTimer.Enabled := False;
  Hide;
end;

procedure TFRMaterialSnackbar.OnActionClick(Sender: TObject);
begin
  if Assigned(FOnAction) then
    FOnAction(Self);
  Hide;
end;

procedure TFRMaterialSnackbar.OnCloseClick(Sender: TObject);
begin
  Hide;
end;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialsnackbar_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialSnackbar]);
end;

end.

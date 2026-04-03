unit FRMaterial3Dialog;

{$mode objfpc}{$H+}

{ Material Design 3 — Dialog.

  TFRMaterialDialog — Modal dialog component with MD3 styling.
  Non-visual component; call Execute to show.

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, Forms, StdCtrls, ExtCtrls,
  LCLIntf, LCLType,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterial3Button,
  FRMaterialIcons;

type
  TFRMDDialogButton = (dbNone, dbOK, dbCancel, dbYes, dbNo, dbClose);
  TFRMDDialogButtons = set of TFRMDDialogButton;
  TFRMDDialogResult = (drNone, drOK, drCancel, drYes, drNo, drClose);
  TFRMDDialogIcon = (diNone, diInfo, diWarning, diError, diSuccess, diHelp);

  { ── TFRMaterialDialog ── }

  TFRMaterialDialog = class(TComponent)
  private
    FTitle: string;
    FContent: string;
    FButtons: TFRMDDialogButtons;
    FDialogIcon: TFRMDDialogIcon;
    procedure SetTitle(const AValue: string);
    procedure SetContent(const AValue: string);
  public
    constructor Create(AOwner: TComponent); override;
    function Execute: TFRMDDialogResult;
  published
    property Title: string read FTitle write SetTitle;
    property Content: string read FContent write SetContent;
    property Buttons: TFRMDDialogButtons read FButtons write FButtons default [dbOK, dbCancel];
    property DialogIcon: TFRMDDialogIcon read FDialogIcon write FDialogIcon default diNone;
  end;

{ Global helper — substitui MessageDlg com visual MD3 }
function MessageDialog(const ATitle, AContent: string;
  AIcon: TFRMDDialogIcon; AButtons: TFRMDDialogButtons): TFRMDDialogResult;

procedure Register;

implementation

type
  { Internal scrim + dialog form }

  TFRDialogPanel = class(TCustomControl)
  private
    FIconBmp: TBGRABitmap;
    FIconLeft: Integer;
    FIconTop: Integer;
  protected
    procedure Paint; override;
  public
    procedure EraseBackground(DC: HDC); override;
    destructor Destroy; override;
  end;

  TFRDialogForm = class(TForm)
  private
    FResult: TFRMDDialogResult;
    FDialogPanel: TFRDialogPanel;
    FDefaultBtn: TFRMaterialButton;
    procedure BtnClick(Sender: TObject);
    procedure DialogShow(Sender: TObject);
  protected
    procedure Paint; override;
    procedure Resize; override;
  public
    constructor CreateDialog(ATitle, AContent: string;
      AButtons: TFRMDDialogButtons; AIcon: TFRMDDialogIcon);
  end;

{ ── TFRDialogPanel — rounded card ── }

procedure TFRDialogPanel.EraseBackground(DC: HDC);
begin
  if DC = 0 then ; { suppress hint }
end;

procedure TFRDialogPanel.Paint;
var
  bmp: TBGRABitmap;
begin
  bmp := TBGRABitmap.Create(Width, Height, BGRA(0, 0, 0, 255));
  try
    bmp.FillRoundRectAntialias(0, 0, Width, Height, 28, 28,
      ColorToBGRA(MD3Colors.SurfaceContainerHigh));
    if Assigned(FIconBmp) then
      bmp.PutImage(FIconLeft, FIconTop, FIconBmp, dmDrawWithTransparency);
    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;
end;

destructor TFRDialogPanel.Destroy;
begin
  FreeAndNil(FIconBmp);
  inherited Destroy;
end;

{ ── TFRDialogForm ── }

constructor TFRDialogForm.CreateDialog(ATitle, AContent: string;
  AButtons: TFRMDDialogButtons; AIcon: TFRMDDialogIcon);
const
  DLG_WIDTH = 420;
  PADDING = 24;
  BTN_H = 40;
  BTN_GAP = 8;
  TITLE_GAP = 16;
  CONTENT_GAP = 24;
  ICON_SIZE = 24;
  ICON_GAP = 16;
var
  lblTitle, lblContent: TLabel;
  btn: TFRMaterialButton;
  btnX, titleH, contentH, contentTop, dlgHeight, curY: Integer;
  R: TRect;
  iconMode: TFRIconMode;
  hexColor: string;

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
    Canvas.Font.Assign(btn.Font);
    btn.Width := Canvas.TextWidth(ACaption) + 48;
    if btn.Width < 90 then btn.Width := 90;
    btnX := btnX - btn.Width - BTN_GAP;
    btn.Left := btnX + BTN_GAP;
    btn.Top := dlgHeight - PADDING - BTN_H;
    if (AStyle = mbsFilled) and (FDefaultBtn = nil) then
      FDefaultBtn := btn;
  end;

begin
  inherited CreateNew(nil);
  FResult := drNone;
  FDefaultBtn := nil;
  BorderStyle := bsNone;
  Position := poScreenCenter;
  Color := clBlack;
  Font.Name := 'Segoe UI';
  Font.Quality := fqClearTypeNatural;
  OnShow := @DialogShow;
  { Full screen scrim — painted via BGRABitmap in Paint }
  WindowState := wsMaximized;

  { Starting Y position }
  curY := PADDING;

  { If icon requested, reserve space }
  if AIcon <> diNone then
    curY := curY + ICON_SIZE + ICON_GAP;

  { Measure title height }
  Canvas.Font.Name := 'Segoe UI';
  Canvas.Font.Size := 14;
  Canvas.Font.Style := [fsBold];
  titleH := Canvas.TextHeight('Tg');

  { Measure content text height with proper word-wrap }
  Canvas.Font.Name := 'Segoe UI';
  Canvas.Font.Size := 10;
  Canvas.Font.Style := [];
  R := Rect(0, 0, DLG_WIDTH - PADDING * 2, 0);
  DrawText(Canvas.Handle, PChar(AContent), Length(AContent), R,
    DT_CALCRECT or DT_WORDBREAK or DT_NOPREFIX);
  contentH := R.Bottom - R.Top;
  if contentH < Canvas.TextHeight('Tg') then
    contentH := Canvas.TextHeight('Tg');

  { Calculate dialog height from measured sizes }
  contentTop := curY + titleH + TITLE_GAP;
  dlgHeight := contentTop + contentH + CONTENT_GAP + BTN_H + PADDING;
  if dlgHeight < 180 then dlgHeight := 180;

  { Dialog card panel }
  FDialogPanel := TFRDialogPanel.Create(Self);
  FDialogPanel.Parent := Self;
  FDialogPanel.Width := DLG_WIDTH;
  FDialogPanel.Height := dlgHeight;
  { Centralizado via Anchors — funciona em qualquer monitor/resolução }
  FDialogPanel.Anchors := [];
  FDialogPanel.Color := MD3Colors.SurfaceContainerHigh;

  { Icon — rendered directly on the panel's BGRABitmap }
  if AIcon <> diNone then
  begin
    case AIcon of
      diWarning: iconMode := imWarning;
      diInfo:    iconMode := imInfo;
      diError:   iconMode := imError;
      diSuccess: iconMode := imSuccess;
      diHelp:    iconMode := imHelp;
    else
      iconMode := imInfo;
    end;
    hexColor := FRColorToSVGHex(MD3Colors.Primary);
    FDialogPanel.FIconBmp := FRRenderSVGIcon(
      FRGetIconSVG(iconMode, hexColor, 2.0), ICON_SIZE, ICON_SIZE);
    FDialogPanel.FIconLeft := (DLG_WIDTH - ICON_SIZE) div 2;
    FDialogPanel.FIconTop := PADDING;
  end;

  { Title — centered when icon present, left-aligned otherwise }
  lblTitle := TLabel.Create(Self);
  lblTitle.Parent := FDialogPanel;
  lblTitle.Top := curY;
  lblTitle.AutoSize := False;
  lblTitle.Width := DLG_WIDTH - PADDING * 2;
  lblTitle.Height := titleH + 4;
  lblTitle.Layout := tlCenter;
  lblTitle.Caption := ATitle;
  lblTitle.Transparent := True;
  lblTitle.ParentFont := False;
  lblTitle.Font.Name := 'Segoe UI';
  lblTitle.Font.Size := 14;
  lblTitle.Font.Style := [fsBold];
  lblTitle.Font.Color := MD3Colors.OnSurface;
  if AIcon <> diNone then
  begin
    lblTitle.Left := PADDING;
    lblTitle.Alignment := taCenter;
  end
  else
    lblTitle.Left := PADDING;

  { Content — word-wrap with properly measured height }
  lblContent := TLabel.Create(Self);
  lblContent.Parent := FDialogPanel;
  lblContent.Left := PADDING;
  lblContent.Top := contentTop;
  lblContent.AutoSize := False;
  lblContent.Width := DLG_WIDTH - PADDING * 2;
  lblContent.Height := contentH + 4;
  lblContent.WordWrap := True;
  lblContent.Caption := AContent;
  lblContent.Transparent := True;
  lblContent.ParentFont := False;
  lblContent.Font.Name := 'Segoe UI';
  lblContent.Font.Size := 10;
  lblContent.Font.Style := [];
  lblContent.Font.Color := MD3Colors.OnSurfaceVariant;

  { Buttons — right-aligned, confirm on right }
  btnX := DLG_WIDTH - PADDING;

  if dbOK in AButtons then AddBtn(dbOK, 'OK', mbsFilled);
  if dbYes in AButtons then AddBtn(dbYes, 'Sim', mbsFilled);
  if dbClose in AButtons then AddBtn(dbClose, 'Fechar', mbsText);
  if dbNo in AButtons then AddBtn(dbNo, 'Não', mbsOutlined);
  if dbCancel in AButtons then AddBtn(dbCancel, 'Cancelar', mbsText);
end;

procedure TFRDialogForm.DialogShow(Sender: TObject);
begin
  if Assigned(FDefaultBtn) then
    ActiveControl := FDefaultBtn;
end;

procedure TFRDialogForm.Paint;
var
  bmp: TBGRABitmap;
begin
  { Scrim — semi-transparent dark overlay }
  bmp := TBGRABitmap.Create(ClientWidth, ClientHeight, BGRA(0, 0, 0, 128));
  try
    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;
end;

procedure TFRDialogForm.Resize;
begin
  inherited Resize;
  if Assigned(FDialogPanel) then
  begin
    FDialogPanel.Left := (ClientWidth - FDialogPanel.Width) div 2;
    FDialogPanel.Top := (ClientHeight - FDialogPanel.Height) div 2;
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
  FTitle := 'Título';
  FContent := 'Conteúdo da mensagem.';
  FButtons := [dbOK, dbCancel];
  FDialogIcon := diNone;
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
  dlg := TFRDialogForm.CreateDialog(FTitle, FContent, FButtons, FDialogIcon);
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

end.

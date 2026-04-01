unit FRMaterial3Button;

{$mode objfpc}{$H+}

{ Material Design 3 — Buttons.

  TFRMaterialButton     — 5 style variants (Filled, Outlined, Text, Elevated, Tonal)
  TFRMaterialButtonIcon — Icon-only button (Standard, Filled, FilledTonal, Outlined)
  TFRMaterialSplitButton— Main button + dropdown arrow

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, Menus,
  {$IFDEF FPC} LCLType, LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialIcons, FRMaterialTheme;

type
  { Button style variants per MD3 spec }
  TFRMDButtonStyle = (mbsFilled, mbsOutlined, mbsText, mbsElevated, mbsTonal);

  { Icon button style variants }
  TFRMDIconButtonStyle = (ibsStandard, ibsFilled, ibsFilledTonal, ibsOutlined);

  { ── TFRMaterialButton ── }

  TFRMaterialButton = class(TFRMaterial3Control)
  private
    FButtonStyle: TFRMDButtonStyle;
    FIconMode: TFRIconMode;
    FShowIcon: Boolean;
    FDensity: TFRMDDensity;
    procedure SetButtonStyle(AValue: TFRMDButtonStyle);
    procedure SetShowIcon(AValue: Boolean);
    procedure SetIconMode(AValue: TFRIconMode);
    procedure SetDensity(AValue: TFRMDDensity);
    procedure GetStyleColors(out ABg, AText, ABorder: TColor);
  protected
    procedure Paint; override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property ButtonStyle: TFRMDButtonStyle read FButtonStyle write SetButtonStyle default mbsFilled;
    property IconMode: TFRIconMode read FIconMode write SetIconMode default imSearch;
    property ShowIcon: Boolean read FShowIcon write SetShowIcon default False;
    { Densidade visual: Normal (40px), Compact (36px), Dense (32px), UltraDense (28px) }
    property Density: TFRMDDensity read FDensity write SetDensity default ddNormal;
    property Anchors;
    property Caption;
    property Enabled;
    property Font;
    property Visible;
    property OnClick;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseEnter;
    property OnMouseLeave;
  end;

  { ── TFRMaterialButtonIcon ── }

  TFRMaterialButtonIcon = class(TFRMaterial3Control)
  private
    FIconStyle: TFRMDIconButtonStyle;
    FIconMode: TFRIconMode;
    FToggle: Boolean;
    FToggled: Boolean;
    procedure SetIconStyle(AValue: TFRMDIconButtonStyle);
    procedure SetIconMode(AValue: TFRIconMode);
    procedure SetToggle(AValue: Boolean);
    procedure SetToggled(AValue: Boolean);
    procedure GetStyleColors(out ABg, AIcon, ABorder: TColor);
  protected
    procedure Paint; override;
    procedure Click; override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property IconStyle: TFRMDIconButtonStyle read FIconStyle write SetIconStyle default ibsStandard;
    property IconMode: TFRIconMode read FIconMode write SetIconMode default imSearch;
    property Toggle: Boolean read FToggle write SetToggle default False;
    property Toggled: Boolean read FToggled write SetToggled default False;
    property Anchors;
    property Enabled;
    property Visible;
    property OnClick;
  end;

  { ── TFRMaterialSplitButton ── }

  TFRMaterialSplitButton = class(TFRMaterial3Control)
  private
    FButtonStyle: TFRMDButtonStyle;
    FDropDownMenu: TPopupMenu;
    FArrowHovered: Boolean;
    FArrowPressed: Boolean;
    function GetArrowRect: TRect;
    function GetMainRect: TRect;
    procedure SetButtonStyle(AValue: TFRMDButtonStyle);
    procedure SetDropDownMenu(AValue: TPopupMenu);
    procedure GetStyleColors(out ABg, AText, ABorder: TColor);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseLeave; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property ButtonStyle: TFRMDButtonStyle read FButtonStyle write SetButtonStyle default mbsFilled;
    property DropDownMenu: TPopupMenu read FDropDownMenu write SetDropDownMenu;
    property Anchors;
    property Caption;
    property Enabled;
    property Font;
    property Visible;
    property OnClick;
  end;

procedure Register;

implementation

uses Math;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialbutton_icon.lrs}
    {$I icons\frmaterialbuttonicon_icon.lrs}
    {$I icons\frmaterialsplitbutton_icon.lrs}
  {$ENDIF}
  RegisterComponents('BGRA Controls', [TFRMaterialButton, TFRMaterialButtonIcon, TFRMaterialSplitButton]);
end;

{ ── Helpers for resolving MD3 colors by style ── }

procedure TFRMaterialButton.GetStyleColors(out ABg, AText, ABorder: TColor);
begin
  ABorder := clNone;
  case FButtonStyle of
    mbsFilled:
    begin
      ABg := MD3Colors.Primary;
      AText := MD3Colors.OnPrimary;
    end;
    mbsOutlined:
    begin
      ABg := clNone;
      AText := MD3Colors.Primary;
      ABorder := MD3Colors.Outline;
    end;
    mbsText:
    begin
      ABg := clNone;
      AText := MD3Colors.Primary;
    end;
    mbsElevated:
    begin
      ABg := MD3Colors.SurfaceContainerLow;
      AText := MD3Colors.Primary;
    end;
    mbsTonal:
    begin
      ABg := MD3Colors.SecondaryContainer;
      AText := MD3Colors.OnSecondaryContainer;
    end;
  end;
  if not Enabled then
  begin
    ABg   := MD3Colors.OnSurface;
    AText := MD3Colors.OnSurface;
    { Outlined keeps its border at reduced opacity per MD3 spec }
    if FButtonStyle <> mbsOutlined then
      ABorder := clNone;
  end;
end;

{ ── TFRMaterialButton ── }

constructor TFRMaterialButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButtonStyle := mbsFilled;
  FIconMode := imSearch;
  FShowIcon := False;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
  Font.Size := 10;
  Font.Style := [fsBold];
end;

class function TFRMaterialButton.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 120;
  Result.cy := 40;
end;

procedure TFRMaterialButton.SetDensity(AValue: TFRMDDensity);
begin
  if FDensity = AValue then Exit;
  FDensity := AValue;
  { Ajusta a altura do botão conforme a densidade }
  Height := 40 + MD3DensityDelta(AValue);
  Invalidate;
end;

procedure TFRMaterialButton.SetButtonStyle(AValue: TFRMDButtonStyle);
begin
  if FButtonStyle = AValue then Exit;
  FButtonStyle := AValue;
  Invalidate;
end;

procedure TFRMaterialButton.SetShowIcon(AValue: Boolean);
begin
  if FShowIcon = AValue then Exit;
  FShowIcon := AValue;
  Invalidate;
end;

procedure TFRMaterialButton.SetIconMode(AValue: TFRIconMode);
begin
  if FIconMode = AValue then Exit;
  FIconMode := AValue;
  Invalidate;
end;

procedure TFRMaterialButton.Paint;
var
  bmp: TBGRABitmap;
  bgColor, textColor, borderColor: TColor;
  r: Integer;
  iconSize, iconX, textX, totalW, tw: Integer;
  iconBmp: TBGRABitmap;
  aRect: TRect;
  bgAlpha: Byte;
begin
  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    r := Height div 2; { MD3 buttons use full rounding }
    GetStyleColors(bgColor, textColor, borderColor);

    bgAlpha := 255;
    if not Enabled then
      bgAlpha := 30; { 12% opacity for disabled bg }

    { Shadow for elevated style }
    if (FButtonStyle = mbsElevated) and Enabled then
      MD3FillRoundRect(bmp, 1, 2, Width - 1, Height, r, MD3Colors.OnSurface, 20);

    { Background }
    if bgColor <> clNone then
      MD3FillRoundRect(bmp, 0, 0, Width - 1, Height - 1, r, bgColor, bgAlpha);

    { Border for outlined — reduced opacity when disabled per MD3 spec }
    if borderColor <> clNone then
    begin
      if Enabled then
        MD3RoundRect(bmp, 0.5, 0.5, Width - 1.5, Height - 1.5, r, borderColor, 1.0)
      else
        MD3RoundRect(bmp, 0.5, 0.5, Width - 1.5, Height - 1.5, r, borderColor, 1.0, 30);
    end;

    { State layer }
    if Enabled then
      MD3StateLayer(bmp, 0, 0, Width - 1, Height - 1, r, textColor, InteractionState);

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { Text + optional icon }
  Canvas.Font := Self.Font;
  tw := Canvas.TextWidth(Caption);
  iconSize := 0;
  if FShowIcon then
    iconSize := 18;
  totalW := iconSize + tw;
  if FShowIcon and (tw > 0) then
    totalW := totalW + 8; { gap }

  if not Enabled then
    textColor := MD3Blend(MD3Colors.Surface, MD3Colors.OnSurface, 97); { 38% }

  iconX := (Width - totalW) div 2;
  textX := iconX + iconSize;
  if FShowIcon and (tw > 0) then
    textX := textX + 8;

  { Draw icon via SVG rendering }
  if FShowIcon and (iconSize > 0) then
  begin
    iconBmp := FRRenderSVGIcon(
      FRGetIconSVG(FIconMode, FRColorToSVGHex(textColor), 2.0),
      iconSize, iconSize);
    try
      iconBmp.Draw(Canvas, iconX, (Height - iconSize) div 2, False);
    finally
      iconBmp.Free;
    end;
  end;

  aRect := Rect(textX, 0, Width, Height);
  MD3DrawText(Canvas, Caption, aRect, textColor, taLeftJustify, True);
end;

{ ── TFRMaterialButtonIcon ── }

constructor TFRMaterialButtonIcon.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIconStyle := ibsStandard;
  FIconMode := imSearch;
  FToggle := False;
  FToggled := False;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
end;

class function TFRMaterialButtonIcon.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 48;
  Result.cy := 48;
end;

procedure TFRMaterialButtonIcon.SetIconStyle(AValue: TFRMDIconButtonStyle);
begin
  if FIconStyle = AValue then Exit;
  FIconStyle := AValue;
  Invalidate;
end;

procedure TFRMaterialButtonIcon.SetIconMode(AValue: TFRIconMode);
begin
  if FIconMode = AValue then Exit;
  FIconMode := AValue;
  Invalidate;
end;

procedure TFRMaterialButtonIcon.SetToggle(AValue: Boolean);
begin
  if FToggle = AValue then Exit;
  FToggle := AValue;
  Invalidate;
end;

procedure TFRMaterialButtonIcon.SetToggled(AValue: Boolean);
begin
  if FToggled = AValue then Exit;
  FToggled := AValue;
  Invalidate;
end;

procedure TFRMaterialButtonIcon.Click;
begin
  if FToggle then
    FToggled := not FToggled;
  inherited;
end;

procedure TFRMaterialButtonIcon.GetStyleColors(out ABg, AIcon, ABorder: TColor);
begin
  ABorder := clNone;
  if FToggle and FToggled then
  begin
    { Toggled-on state }
    case FIconStyle of
      ibsStandard:
      begin
        ABg := clNone;
        AIcon := MD3Colors.Primary;
      end;
      ibsFilled:
      begin
        ABg := MD3Colors.Primary;
        AIcon := MD3Colors.OnPrimary;
      end;
      ibsFilledTonal:
      begin
        ABg := MD3Colors.SecondaryContainer;
        AIcon := MD3Colors.OnSecondaryContainer;
      end;
      ibsOutlined:
      begin
        ABg := MD3Colors.InverseSurface;
        AIcon := MD3Colors.InverseOnSurface;
        ABorder := clNone;
      end;
    end;
  end
  else
  begin
    { Normal / toggled-off state }
    case FIconStyle of
      ibsStandard:
      begin
        ABg := clNone;
        AIcon := MD3Colors.OnSurfaceVariant;
      end;
      ibsFilled:
      begin
        ABg := MD3Colors.Primary;
        AIcon := MD3Colors.OnPrimary;
      end;
      ibsFilledTonal:
      begin
        ABg := MD3Colors.SecondaryContainer;
        AIcon := MD3Colors.OnSecondaryContainer;
      end;
      ibsOutlined:
      begin
        ABg := clNone;
        AIcon := MD3Colors.OnSurfaceVariant;
        ABorder := MD3Colors.Outline;
      end;
    end;
  end;
end;

procedure TFRMaterialButtonIcon.Paint;
var
  bmp, iconBmp: TBGRABitmap;
  bgColor, iconColor, borderColor: TColor;
  r, iconSize: Integer;
begin
  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    r := Height div 2;
    GetStyleColors(bgColor, iconColor, borderColor);

    if bgColor <> clNone then
      MD3FillRoundRect(bmp, 0, 0, Width - 1, Height - 1, r, bgColor);

    if borderColor <> clNone then
      MD3RoundRect(bmp, 0.5, 0.5, Width - 1.5, Height - 1.5, r, borderColor, 1.0);

    if Enabled then
      MD3StateLayer(bmp, 0, 0, Width - 1, Height - 1, r, iconColor, InteractionState);

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { Icon }
  iconSize := Min(Width, Height) div 2;
  iconBmp := FRRenderSVGIcon(
    FRGetIconSVG(FIconMode, FRColorToSVGHex(iconColor), 2.0),
    iconSize, iconSize);
  try
    iconBmp.Draw(Canvas, (Width - iconSize) div 2, (Height - iconSize) div 2, False);
  finally
    iconBmp.Free;
  end;
end;

{ ── TFRMaterialSplitButton ── }

constructor TFRMaterialSplitButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButtonStyle := mbsFilled;
  FDropDownMenu := nil;
  FArrowHovered := False;
  FArrowPressed := False;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
  Font.Size := 10;
  Font.Style := [fsBold];
end;

class function TFRMaterialSplitButton.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 160;
  Result.cy := 40;
end;

procedure TFRMaterialSplitButton.SetButtonStyle(AValue: TFRMDButtonStyle);
begin
  if FButtonStyle = AValue then Exit;
  FButtonStyle := AValue;
  Invalidate;
end;

procedure TFRMaterialSplitButton.SetDropDownMenu(AValue: TPopupMenu);
begin
  if FDropDownMenu = AValue then Exit;
  if Assigned(FDropDownMenu) then
    FDropDownMenu.RemoveFreeNotification(Self);
  FDropDownMenu := AValue;
  if Assigned(FDropDownMenu) then
    FDropDownMenu.FreeNotification(Self);
end;

procedure TFRMaterialSplitButton.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDropDownMenu) then
    FDropDownMenu := nil;
end;

function TFRMaterialSplitButton.GetArrowRect: TRect;
begin
  Result := Rect(Width - 40, 0, Width, Height);
end;

function TFRMaterialSplitButton.GetMainRect: TRect;
begin
  Result := Rect(0, 0, Width - 40, Height);
end;

procedure TFRMaterialSplitButton.GetStyleColors(out ABg, AText, ABorder: TColor);
begin
  ABorder := clNone;
  case FButtonStyle of
    mbsFilled:   begin ABg := MD3Colors.Primary; AText := MD3Colors.OnPrimary; end;
    mbsOutlined: begin ABg := clNone; AText := MD3Colors.Primary; ABorder := MD3Colors.Outline; end;
    mbsText:     begin ABg := clNone; AText := MD3Colors.Primary; end;
    mbsElevated: begin ABg := MD3Colors.SurfaceContainerLow; AText := MD3Colors.Primary; end;
    mbsTonal:    begin ABg := MD3Colors.SecondaryContainer; AText := MD3Colors.OnSecondaryContainer; end;
  end;
end;

procedure TFRMaterialSplitButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ar: TRect;
  P: TPoint;
begin
  ar := GetArrowRect;
  if (Button = mbLeft) and PtInRect(Point(X, Y), ar) then
  begin
    FArrowPressed := True;
    Invalidate;
    if Assigned(FDropDownMenu) then
    begin
      P := ClientToScreen(Point(ar.Left, Height));
      FDropDownMenu.PopUp(P.X, P.Y);
      FArrowPressed := False;
      Invalidate;
    end;
  end
  else
    inherited;
end;

procedure TFRMaterialSplitButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FArrowPressed := False;
  inherited;
end;

procedure TFRMaterialSplitButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  ar: TRect;
  inArrow: Boolean;
begin
  ar := GetArrowRect;
  inArrow := PtInRect(Point(X, Y), ar);
  if inArrow <> FArrowHovered then
  begin
    FArrowHovered := inArrow;
    Invalidate;
  end;
  inherited;
end;

procedure TFRMaterialSplitButton.MouseLeave;
begin
  if FArrowHovered then
  begin
    FArrowHovered := False;
    Invalidate;
  end;
  inherited;
end;

procedure TFRMaterialSplitButton.Paint;
var
  bmp, iconBmp: TBGRABitmap;
  bgColor, textColor, borderColor: TColor;
  r, sep: Integer;
  mainR, arrowR: TRect;
begin
  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    r := Height div 2;
    GetStyleColors(bgColor, textColor, borderColor);
    mainR := GetMainRect;
    arrowR := GetArrowRect;
    sep := arrowR.Left;

    { Full background }
    if bgColor <> clNone then
      MD3FillRoundRect(bmp, 0, 0, Width - 1, Height - 1, r, bgColor);

    if borderColor <> clNone then
      MD3RoundRect(bmp, 0.5, 0.5, Width - 1.5, Height - 1.5, r, borderColor, 1.0);

    { Divider line between main and arrow }
    bmp.DrawLineAntialias(sep, 4, sep, Height - 4,
      ColorToBGRA(ColorToRGB(textColor), 60), 1.0);

    { State layers (separate for main and arrow areas) }
    if Enabled then
    begin
      if FArrowHovered or FArrowPressed then
      begin
        if FArrowPressed then
          MD3StateLayer(bmp, arrowR.Left, 0, Width - 1, Height - 1, r, textColor, isPressed)
        else
          MD3StateLayer(bmp, arrowR.Left, 0, Width - 1, Height - 1, r, textColor, isHovered);
      end;
      if Hovered and not FArrowHovered then
        MD3StateLayer(bmp, 0, 0, sep, Height - 1, r, textColor, InteractionState);
    end;

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { Main text }
  MD3DrawText(Canvas, Caption, mainR, textColor, taCenter, True);

  { Arrow icon — chevron down (expand_more) per MD3 spec }
  iconBmp := FRRenderSVGIcon(
    FRGetIconSVG(imExpandMore, FRColorToSVGHex(textColor), 2.5), 18, 18);
  try
    iconBmp.Draw(Canvas, arrowR.Left + (arrowR.Right - arrowR.Left - 18) div 2,
      (Height - 18) div 2, False);
  finally
    iconBmp.Free;
  end;
end;

end.

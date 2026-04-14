unit FRMaterial3Card;

{$mode objfpc}{$H+}

{ Material Design 3 — Cards.

  TFRMaterialCard — Container surface with MD3 styling.
    Three variants per spec:
      • Filled   — SurfaceContainerHighest background, no border
      • Outlined — Surface background, Outline border
      • Elevated — SurfaceContainerLow background, Level1 shadow

  Supports:
    • Drag-and-drop child controls in IDE (csAcceptsControls)
    • Click + ripple interaction
    • Optional header image (top area)
    • Content padding via AdjustClientRect
    • MD3 shape scale for corner radius
    • Elevation and state-layer on hover/press

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, ExtCtrls,
  {$IFDEF FPC} LCLType, LCLIntf, LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialTheme;

type
  TFRMDCardStyle = (cssFilled, cssOutlined, cssElevated);

  { ── TFRMaterialCard ── }

  TFRMaterialCard = class(TCustomControl, IFRMaterialComponent)
  private
    FCardStyle: TFRMDCardStyle;
    FBorderRadius: Integer;
    FContentPadding: Integer;
    FHeaderImage: TPicture;
    FHeaderHeight: Integer;
    FClickable: Boolean;
    FHovered: Boolean;
    FPressed: Boolean;
    FOnCardClick: TNotifyEvent;
    FSubTitle: string;
    { Ripple }
    FRippleX: Integer;
    FRippleY: Integer;
    FRippleProgress: Single;
    FRippleFading: Boolean;
    FRippleFadeProgress: Single;
    FRippleTimer: TTimer;
    procedure SetCardStyle(AValue: TFRMDCardStyle);
    procedure SetBorderRadius(AValue: Integer);
    procedure SetContentPadding(AValue: Integer);
    procedure SetHeaderHeight(AValue: Integer);
    procedure SetClickable(AValue: Boolean);
    procedure SetSubTitle(const AValue: string);
    procedure HeaderImageChanged(Sender: TObject);
    procedure DoRippleTick(Sender: TObject);
    procedure GetStyleColors(out ABg, ABorder: TColor; out AElevation: TFRMDElevation);
  protected
    procedure Paint; override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure AdjustClientRect(var ARect: TRect); override;
    procedure EraseBackground({%H-}DC: HDC); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const AThemeManager: TObject); virtual;
  published
    property CardStyle: TFRMDCardStyle read FCardStyle write SetCardStyle default cssFilled;
    property BorderRadius: Integer read FBorderRadius write SetBorderRadius default 12;
    property ContentPadding: Integer read FContentPadding write SetContentPadding default 16;
    property HeaderImage: TPicture read FHeaderImage write FHeaderImage;
    property HeaderHeight: Integer read FHeaderHeight write SetHeaderHeight default 0;
    property Clickable: Boolean read FClickable write SetClickable default False;
    property SubTitle: string read FSubTitle write SetSubTitle;
    property OnCardClick: TNotifyEvent read FOnCardClick write FOnCardClick;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Caption;
    property Color;
    property Constraints;
    property Cursor;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnResize;
  end;

procedure Register;

implementation

uses Math;

{ ── TFRMaterialCard ── }

constructor TFRMaterialCard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FRMDRegisterComponent(Self);

  ControlStyle        := ControlStyle + [csAcceptsControls, csClickEvents, csCaptureMouse];
  FCardStyle          := cssFilled;
  FBorderRadius       := 12;
  FContentPadding     := 16;
  FHeaderHeight       := 0;
  FClickable          := False;
  FHovered            := False;
  FPressed            := False;
  FRippleProgress     := 0;
  FRippleFading       := False;
  FRippleFadeProgress := 0;
  FRippleTimer        := nil;

  FHeaderImage := TPicture.Create;
  FHeaderImage.OnChange := @HeaderImageChanged;

  { BorderWidth offsets ALL child controls (absolute + aligned) }
  BorderWidth := FContentPadding;

  { Cores MD3 default para que filhos (TLabel etc.) herdem via ParentFont/ParentColor.
    OnSurface garante contraste correto sobre qualquer CardStyle. }
  Font.Color := MD3Colors.OnSurface;

  Width := 300;
  Height := 200;
end;

destructor TFRMaterialCard.Destroy;
begin
  FreeAndNil(FRippleTimer);
  FreeAndNil(FHeaderImage);
  FRMDUnregisterComponent(Self);
  inherited Destroy;
end;

procedure TFRMaterialCard.ApplyTheme(const AThemeManager: TObject);
begin
  if not Assigned(AThemeManager) then Exit;
  Font.Color := MD3Colors.OnSurface;
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialCard.EraseBackground(DC: HDC);
var
  ARect: TRect;
begin
  if DC = 0 then Exit;
  ARect := Rect(0, 0, Width, Height);
  if Parent <> nil then
    Brush.Color := Parent.Brush.Color
  else
    Brush.Color := MD3Colors.Surface;
  LCLIntf.FillRect(DC, ARect, HBRUSH(Brush.Reference.Handle));
end;

procedure TFRMaterialCard.SetCardStyle(AValue: TFRMDCardStyle);
begin
  if FCardStyle = AValue then Exit;
  FCardStyle := AValue;
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialCard.SetBorderRadius(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if FBorderRadius = AValue then Exit;
  FBorderRadius := AValue;
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialCard.SetContentPadding(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if FContentPadding = AValue then Exit;
  FContentPadding := AValue;
  BorderWidth := AValue;
  ReAlign;
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialCard.SetHeaderHeight(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if FHeaderHeight = AValue then Exit;
  FHeaderHeight := AValue;
  ReAlign;
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialCard.SetSubTitle(const AValue: string);
begin
  if FSubTitle = AValue then Exit;
  FSubTitle := AValue;
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialCard.SetClickable(AValue: Boolean);
begin
  if FClickable = AValue then Exit;
  FClickable := AValue;
  if FClickable then
    Cursor := crHandPoint
  else
    Cursor := crDefault;
end;

procedure TFRMaterialCard.HeaderImageChanged(Sender: TObject);
begin
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialCard.GetStyleColors(out ABg, ABorder: TColor;
  out AElevation: TFRMDElevation);
begin
  case FCardStyle of
    cssFilled:
    begin
      ABg := MD3Colors.SurfaceContainerHighest;
      ABorder := clNone;
      AElevation := elLevel0;
    end;
    cssOutlined:
    begin
      ABg := MD3Colors.Surface;
      ABorder := MD3Colors.OutlineVariant;
      AElevation := elLevel0;
    end;
    cssElevated:
    begin
      ABg := MD3Colors.SurfaceContainerLow;
      ABorder := clNone;
      if FHovered and FClickable then
        AElevation := elLevel2
      else
        AElevation := elLevel1;
    end;
  end;
end;

procedure TFRMaterialCard.AdjustClientRect(var ARect: TRect);
begin
  inherited AdjustClientRect(ARect);
  { BorderWidth already offsets all 4 sides by ContentPadding.
    Only add HeaderHeight to top for the image area. }
  if FHeaderHeight > 0 then
    ARect.Top := ARect.Top + FHeaderHeight;
end;

procedure TFRMaterialCard.MouseEnter;
begin
  FHovered := True;
  FRMDSafeInvalidate(Self);
  inherited;
end;

procedure TFRMaterialCard.MouseLeave;
begin
  FHovered := False;
  FPressed := False;
  FRMDSafeInvalidate(Self);
  inherited;
end;

procedure TFRMaterialCard.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and FClickable then
  begin
    FPressed := True;
    FRippleX := X;
    FRippleY := Y;
    FRippleProgress := 0;
    FRippleFading := False;
    FRippleFadeProgress := 0;
    if FRippleTimer = nil then
    begin
      FRippleTimer := TTimer.Create(Self);
      FRippleTimer.Interval := 16;
      FRippleTimer.OnTimer := @DoRippleTick;
    end;
    FRippleTimer.Enabled := True;
    FRMDSafeInvalidate(Self);
  end;
  inherited;
end;

procedure TFRMaterialCard.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and FPressed then
  begin
    FPressed := False;
    FRippleFading := True;
    FRMDSafeInvalidate(Self);
    if FClickable and Assigned(FOnCardClick) then
      FOnCardClick(Self);
  end;
  inherited;
end;

procedure TFRMaterialCard.DoRippleTick(Sender: TObject);
begin
  if FRippleFading then
  begin
    FRippleFadeProgress := FRippleFadeProgress + 0.08;
    if FRippleFadeProgress >= 1.0 then
    begin
      FRippleFadeProgress := 1.0;
      FRippleProgress := 0;
      FRippleFading := False;
      if Assigned(FRippleTimer) then
        FRippleTimer.Enabled := False;
    end;
  end
  else
  begin
    FRippleProgress := FRippleProgress + 0.06;
    if FRippleProgress > 1.0 then
      FRippleProgress := 1.0;
  end;
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialCard.Paint;
var
  ABmp: TBGRABitmap;
  bgColor, borderColor, stateColor: TColor;
  elev: TFRMDElevation;
  r: Integer;
  interState: TFRMDInteractionState;
  maxRad: Single;
  ripAlpha: Byte;
  parentBg: TColor;
  captionY: Integer;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  { Pre-fill with parent background so corners blend naturally AND the
    canvas DC stays fully opaque after BitBlt.  Without this, AlphaBlend
    corrupts the DC alpha channel and child TGraphicControls (TLabel etc.)
    become invisible because GDI text output does not set per-pixel alpha. }
  if Parent <> nil then
    parentBg := Parent.Brush.Color
  else
    parentBg := MD3Colors.Surface;

  ABmp := TBGRABitmap.Create(Width, Height, ColorToBGRA(parentBg, 255));
  try

  GetStyleColors(bgColor, borderColor, elev);
  r := FBorderRadius;

  { Shadow for elevated variant }
  if elev > elLevel0 then
    MD3DrawShadow(ABmp, 1, 1, Width - 2, Height - 2, r, elev);

  { Background }
  MD3FillRoundRect(ABmp, 0, 0, Width - 1, Height - 1, r, bgColor);

  { Header image }
  if (FHeaderHeight > 0) and Assigned(FHeaderImage.Graphic) and
     (not FHeaderImage.Graphic.Empty) then
  begin
    { Clip image into top rounded area using a mask approach }
    ABmp.Canvas.ClipRect := Rect(0, 0, Width, FHeaderHeight);
    ABmp.Canvas.StretchDraw(Rect(0, 0, Width, FHeaderHeight), FHeaderImage.Graphic);
    ABmp.Canvas.ClipRect := Rect(0, 0, Width, Height);
  end;

  { State layer (hover/press) for clickable cards }
  if FClickable then
  begin
    if FPressed then
      interState := isPressed
    else if FHovered then
      interState := isHovered
    else
      interState := isNormal;

    stateColor := MD3Colors.OnSurface;
    MD3StateLayer(ABmp, 0, 0, Width - 1, Height - 1, r, stateColor, interState);
  end;

  { Ripple effect }
  if FClickable and ((FRippleProgress > 0) or FRippleFading) then
  begin
    maxRad := Sqrt(Sqr(Single(Width)) + Sqr(Single(Height)));
    if FRippleFading then
      ripAlpha := EnsureRange(Round(20 * (1.0 - FRippleFadeProgress)), 0, 255)
    else
      ripAlpha := 20;
    ABmp.FillEllipseAntialias(
      FRippleX, FRippleY,
      maxRad * FRippleProgress, maxRad * FRippleProgress,
      ColorToBGRA(MD3Colors.OnSurface, ripAlpha));
  end;

  { Border for outlined variant }
  if borderColor <> clNone then
    MD3RoundRect(ABmp, 0.5, 0.5, Width - 1.5, Height - 1.5, r,
      borderColor, 1.0);

  { Caption + SubTitle — rendered on BGRA bitmap for alpha-correct DWM
    compositing.  GDI TextOut (used by TLabel/TGraphicControl) does NOT set
    per-pixel alpha, so text becomes invisible on borderless/composited
    windows.  BGRA text rendering sets alpha=255 correctly. }
  if (Caption <> '') or (FSubTitle <> '') then
  begin
    captionY := FHeaderHeight + 12;

    if Caption <> '' then
    begin
      ABmp.FontName   := Font.Name;
      ABmp.FontStyle  := [fsBold];
      ABmp.FontHeight := Abs(Font.Size * 96 div 72);
      ABmp.FontQuality := fqFineAntialiasing;
      MD3DrawTextBGRA(ABmp, Caption,
        Rect(16, captionY, Width - 16, captionY + ABmp.TextSize('Áy').cy),
        MD3Colors.OnSurface, taLeftJustify, False, False);
      captionY := captionY + ABmp.TextSize('Áy').cy + 4;
    end;

    if FSubTitle <> '' then
    begin
      ABmp.FontStyle  := [];
      ABmp.FontHeight := Abs(9 * 96 div 72);
      ABmp.FontQuality := fqFineAntialiasing;
      MD3DrawTextBGRA(ABmp, FSubTitle,
        Rect(16, captionY, Width - 16, captionY + ABmp.TextSize('Áy').cy),
        MD3Colors.OnSurfaceVariant, taLeftJustify, False, False);
    end;
  end;

  ABmp.Draw(Canvas, 0, 0, True);
  finally
    ABmp.Free;
  end;
end;

{ ── Registration ── }

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialcard_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialCard]);
end;

end.

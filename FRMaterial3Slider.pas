unit FRMaterial3Slider;

{$mode objfpc}{$H+}

{ Material Design 3 — Slider.

  TFRMaterialSlider — Continuous or discrete slider with thumb and track.

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base;

type
  TFRMaterialSlider = class(TFRMaterial3Control)
  private
    FValue: Double;
    FMin: Double;
    FMax: Double;
    FDiscrete: Boolean;
    FSteps: Integer;
    FDragging: Boolean;
    FShowValueLabel: Boolean;
    FOnChange: TNotifyEvent;
    procedure SetValue(AValue: Double);
    procedure SetMin(AValue: Double);
    procedure SetMax(AValue: Double);
    procedure SetDiscrete(AValue: Boolean);
    procedure SetSteps(AValue: Integer);
    procedure SetShowValueLabel(AValue: Boolean);
    function ValueToX(AVal: Double): Integer;
    function XToValue(AX: Integer): Double;
    procedure ClampValue;
  protected
    function PaintCached(ABmp: TBGRABitmap): Boolean; override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Value: Double read FValue write SetValue;
    property Min: Double read FMin write SetMin;
    property Max: Double read FMax write SetMax;
    property Discrete: Boolean read FDiscrete write SetDiscrete default False;
    property Steps: Integer read FSteps write SetSteps default 10;
    property ShowValueLabel: Boolean read FShowValueLabel write SetShowValueLabel default False;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
    property Cursor;
    property Enabled;
    property PopupMenu;
    property ShowHint;
    property ParentShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

procedure Register;

implementation

uses Math;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialslider_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialSlider]);
end;

constructor TFRMaterialSlider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FValue := 0;
  FMin := 0;
  FMax := 100;
  FDiscrete := False;
  FSteps := 10;
  FDragging := False;
  FShowValueLabel := False;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
end;

class function TFRMaterialSlider.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 200;
  Result.cy := 40;
end;

procedure TFRMaterialSlider.SetValue(AValue: Double);
begin
  AValue := Math.Max(FMin, Math.Min(FMax, AValue));
  if FDiscrete and (FSteps > 0) and (FMax > FMin) then
  begin
    AValue := FMin + Round((AValue - FMin) / ((FMax - FMin) / FSteps)) * ((FMax - FMin) / FSteps);
    AValue := Math.Max(FMin, Math.Min(FMax, AValue));
  end;
  if FValue = AValue then Exit;
  FValue := AValue;
  InvalidatePaintCache;
  Invalidate;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TFRMaterialSlider.SetMin(AValue: Double);
begin
  if FMin = AValue then Exit;
  FMin := AValue;
  ClampValue;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialSlider.SetMax(AValue: Double);
begin
  if FMax = AValue then Exit;
  FMax := AValue;
  ClampValue;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialSlider.SetDiscrete(AValue: Boolean);
begin
  if FDiscrete = AValue then Exit;
  FDiscrete := AValue;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialSlider.SetSteps(AValue: Integer);
begin
  if AValue < 1 then AValue := 1;
  if FSteps = AValue then Exit;
  FSteps := AValue;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialSlider.SetShowValueLabel(AValue: Boolean);
begin
  if FShowValueLabel = AValue then Exit;
  FShowValueLabel := AValue;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialSlider.ClampValue;
begin
  if FValue < FMin then FValue := FMin;
  if FValue > FMax then FValue := FMax;
end;

function TFRMaterialSlider.ValueToX(AVal: Double): Integer;
var
  pad: Integer;
begin
  pad := Height div 2;
  if FMax <= FMin then
    Result := pad
  else
    Result := pad + Round((AVal - FMin) / (FMax - FMin) * (Width - 2 * pad));
end;

function TFRMaterialSlider.XToValue(AX: Integer): Double;
var
  pad: Integer;
begin
  pad := Height div 2;
  if Width <= 2 * pad then
    Result := FMin
  else
    Result := FMin + (AX - pad) / (Width - 2 * pad) * (FMax - FMin);
  Result := Math.Max(FMin, Math.Min(FMax, Result));
end;

procedure TFRMaterialSlider.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FDragging := True;
    Value := XToValue(X);
  end;
  inherited;
end;

procedure TFRMaterialSlider.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if FDragging then
    Value := XToValue(X);
  inherited;
end;

procedure TFRMaterialSlider.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
  inherited;
end;

function TFRMaterialSlider.PaintCached(ABmp: TBGRABitmap): Boolean;
var
  trackY, thumbX, pad, i, stepX: Integer;
  activeColor, inactiveColor, thumbColor: TColor;
  thumbR, trackH, stateR, dotR: Integer;
begin
  Result := True;
  { Proportional metrics based on Height (reference = 40) }
  pad := Height div 2;
  thumbR := Height * 10 div 40;
  if thumbR < 6 then thumbR := 6;
  trackH := Height * 2 div 40;
  if trackH < 1 then trackH := 1;
  stateR := Height div 2;
  dotR := Height * 2 div 40;
  if dotR < 1 then dotR := 1;

  trackY := Height div 2;
  thumbX := ValueToX(FValue);
  activeColor := MD3Colors.Primary;
  inactiveColor := MD3Colors.SurfaceContainerHighest;
  thumbColor := MD3Colors.Primary;

  { Inactive track }
  ABmp.FillRoundRectAntialias(pad, trackY - trackH, Width - pad, trackY + trackH,
    trackH, trackH, ColorToBGRA(ColorToRGB(inactiveColor)));

  { Active track }
  if thumbX > pad then
    ABmp.FillRoundRectAntialias(pad, trackY - trackH, thumbX, trackY + trackH,
      trackH, trackH, ColorToBGRA(ColorToRGB(activeColor)));

  { Discrete step dots }
  if FDiscrete and (FSteps > 0) then
  begin
    for i := 0 to FSteps do
    begin
      stepX := pad + Round(i / FSteps * (Width - 2 * pad));
      if stepX <= thumbX then
        ABmp.FillEllipseAntialias(stepX, trackY, dotR, dotR,
          ColorToBGRA(ColorToRGB(MD3Colors.OnPrimary)))
      else
        ABmp.FillEllipseAntialias(stepX, trackY, dotR, dotR,
          ColorToBGRA(ColorToRGB(activeColor)));
    end;
  end;

  { State layer on thumb }
  if Enabled then
    MD3StateLayer(ABmp, thumbX - stateR, trackY - stateR, thumbX + stateR, trackY + stateR,
      stateR, activeColor, InteractionState);

  { Thumb }
  ABmp.FillEllipseAntialias(thumbX, trackY, thumbR, thumbR,
    ColorToBGRA(ColorToRGB(thumbColor)));

  PaintRipple(ABmp, thumbColor);
end;

procedure TFRMaterialSlider.Paint;
var
  thumbX, stateR, pad: Integer;
  labelRect: TRect;
  labelText: string;
begin
  { Call inherited Paint which handles PaintCached and ripple }
  inherited Paint;

  { Value label tooltip — drawn on Canvas after bitmap }
  if FShowValueLabel and (FDragging or Hovered) then
  begin
    pad := Height div 2;
    stateR := Height div 2;
    thumbX := ValueToX(FValue);
    labelText := FormatFloat('0.#', FValue);
    Canvas.Font.Size := Height * 8 div 40;
    if Canvas.Font.Size < 7 then Canvas.Font.Size := 7;
    Canvas.Font.Color := MD3Colors.OnPrimary;
    labelRect := Rect(thumbX - stateR, 2, thumbX + stateR, Height * 18 div 40);
    Canvas.Brush.Color := MD3Colors.Primary;
    Canvas.RoundRect(labelRect, 4, 4);
    MD3DrawText(Canvas, labelText, labelRect, MD3Colors.OnPrimary, taCenter, True);
    Canvas.Brush.Style := bsClear;
  end;
end;

end.

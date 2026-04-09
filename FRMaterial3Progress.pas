unit FRMaterial3Progress;

{$mode objfpc}{$H+}

{ Material Design 3 — Progress indicators.

  TFRMaterialLinearProgress   — Linear progress bar (determinate/indeterminate)
  TFRMaterialCircularProgress — Circular progress spinner (determinate/indeterminate)
  TFRMaterialLoadingIndicator — Animated loading dots

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, ExtCtrls,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base;

type
  { ── TFRMaterialLinearProgress ── }

  TFRMaterialLinearProgress = class(TFRMaterial3Graphic)
  private
    FValue: Double;
    FIndeterminate: Boolean;
    FAnimTimer: TTimer;
    FAnimPos: Double;
    procedure SetValue(AValue: Double);
    procedure SetIndeterminate(AValue: Boolean);
    procedure OnAnimTimer(Sender: TObject);
  protected
    procedure Paint; override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Value: Double read FValue write SetValue;
    property Indeterminate: Boolean read FIndeterminate write SetIndeterminate default False;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
    property Cursor;
    property Enabled;
    property Visible;
  end;

  { ── TFRMaterialCircularProgress ── }

  TFRMaterialCircularProgress = class(TFRMaterial3Graphic)
  private
    FValue: Double;
    FIndeterminate: Boolean;
    FAnimTimer: TTimer;
    FAnimAngle: Double;
    FStrokeWidth: Integer;
    procedure SetValue(AValue: Double);
    procedure SetIndeterminate(AValue: Boolean);
    procedure SetStrokeWidth(AValue: Integer);
    procedure OnAnimTimer(Sender: TObject);
  protected
    procedure Paint; override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Value: Double read FValue write SetValue;
    property Indeterminate: Boolean read FIndeterminate write SetIndeterminate default True;
    property StrokeWidth: Integer read FStrokeWidth write SetStrokeWidth default 4;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
    property Cursor;
    property Enabled;
    property Visible;
  end;

  { ── TFRMaterialLoadingIndicator ── }

  TFRMaterialLoadingIndicator = class(TFRMaterial3Graphic)
  private
    FAnimTimer: TTimer;
    FAnimStep: Integer;
    FDotCount: Integer;
    procedure SetDotCount(AValue: Integer);
    procedure OnAnimTimer(Sender: TObject);
  protected
    procedure Paint; override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property DotCount: Integer read FDotCount write SetDotCount default 3;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
    property Cursor;
    property Enabled;
    property Visible;
  end;

procedure Register;

implementation

uses Math;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmateriallinearprogress_icon.lrs}
    {$I icons\frmaterialcircularprogress_icon.lrs}
    {$I icons\frmaterialloadingindicator_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialLinearProgress,
    TFRMaterialCircularProgress, TFRMaterialLoadingIndicator]);
end;

{ ── TFRMaterialLinearProgress ── }

constructor TFRMaterialLinearProgress.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FValue := 0;
  FIndeterminate := False;
  FAnimPos := 0;
  FAnimTimer := TTimer.Create(Self);
  FAnimTimer.Enabled := False;
  FAnimTimer.Interval := 16;
  FAnimTimer.OnTimer := @OnAnimTimer;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
end;

destructor TFRMaterialLinearProgress.Destroy;
begin
  FAnimTimer.Free;
  inherited Destroy;
end;

class function TFRMaterialLinearProgress.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 200;
  Result.cy := 4;
end;

procedure TFRMaterialLinearProgress.SetValue(AValue: Double);
begin
  AValue := Max(0, Min(1, AValue));
  if FValue = AValue then Exit;
  FValue := AValue;
  Invalidate;
end;

procedure TFRMaterialLinearProgress.SetIndeterminate(AValue: Boolean);
begin
  if FIndeterminate = AValue then Exit;
  FIndeterminate := AValue;
  FAnimTimer.Enabled := AValue and not (csDesigning in ComponentState);
  FAnimPos := 0;
  Invalidate;
end;

procedure TFRMaterialLinearProgress.OnAnimTimer(Sender: TObject);
begin
  FAnimPos := FAnimPos + 0.02;
  if FAnimPos > 2.0 then FAnimPos := 0;
  Invalidate;
end;

procedure TFRMaterialLinearProgress.Paint;
var
  bmp: TBGRABitmap;
  r, barX1, barX2: Integer;
begin
  if (Width <= 0) or (Height <= 0) then Exit;
  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    r := Height div 2;

    { Track background }
    MD3FillRoundRect(bmp, 0, 0, Width - 1, Height - 1, r,
      MD3Colors.SurfaceContainerHighest);

    if FIndeterminate then
    begin
      { Sliding bar }
      barX1 := Round((FAnimPos - 0.4) * Width);
      barX2 := Round(FAnimPos * Width);
      barX1 := Max(0, barX1);
      barX2 := Min(Width - 1, barX2);
      if barX2 > barX1 then
        MD3FillRoundRect(bmp, barX1, 0, barX2, Height - 1, r, MD3Colors.Primary);
    end
    else
    begin
      { Determinate bar }
      if FValue > 0 then
      begin
        barX2 := Round(FValue * (Width - 1));
        MD3FillRoundRect(bmp, 0, 0, barX2, Height - 1, r, MD3Colors.Primary);
      end;
    end;

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;
end;

{ ── TFRMaterialCircularProgress ── }

constructor TFRMaterialCircularProgress.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FValue := 0;
  FIndeterminate := True;
  FAnimAngle := 0;
  FStrokeWidth := 4;
  FAnimTimer := TTimer.Create(Self);
  FAnimTimer.Enabled := not (csDesigning in ComponentState);
  FAnimTimer.Interval := 16;
  FAnimTimer.OnTimer := @OnAnimTimer;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
end;

destructor TFRMaterialCircularProgress.Destroy;
begin
  FAnimTimer.Free;
  inherited Destroy;
end;

class function TFRMaterialCircularProgress.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 48;
  Result.cy := 48;
end;

procedure TFRMaterialCircularProgress.SetValue(AValue: Double);
begin
  AValue := Max(0, Min(1, AValue));
  if FValue = AValue then Exit;
  FValue := AValue;
  Invalidate;
end;

procedure TFRMaterialCircularProgress.SetIndeterminate(AValue: Boolean);
begin
  if FIndeterminate = AValue then Exit;
  FIndeterminate := AValue;
  FAnimTimer.Enabled := AValue and not (csDesigning in ComponentState);
  FAnimAngle := 0;
  Invalidate;
end;

procedure TFRMaterialCircularProgress.SetStrokeWidth(AValue: Integer);
begin
  if AValue < 1 then AValue := 1;
  if FStrokeWidth = AValue then Exit;
  FStrokeWidth := AValue;
  Invalidate;
end;

procedure TFRMaterialCircularProgress.OnAnimTimer(Sender: TObject);
begin
  FAnimAngle := FAnimAngle + 6;
  if FAnimAngle >= 360 then FAnimAngle := FAnimAngle - 360;
  Invalidate;
end;

procedure TFRMaterialCircularProgress.Paint;
var
  bmp: TBGRABitmap;
  cx, cy: Single;
  r: Single;
  startAngle, sweepAngle: Single;
  arcColor: TBGRAPixel;
  i: Integer;
  angle, px, py: Single;
begin
  if (Width <= 0) or (Height <= 0) then Exit;
  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    cx := Width / 2.0;
    cy := Height / 2.0;
    r := Min(cx, cy) - FStrokeWidth;
    if r <= 0 then Exit;
    arcColor := ColorToBGRA(ColorToRGB(MD3Colors.Primary));

    { Track circle }
    bmp.EllipseAntialias(cx, cy, r, r,
      ColorToBGRA(ColorToRGB(MD3Colors.SurfaceContainerHighest)),
      FStrokeWidth);

    if FIndeterminate then
    begin
      { Spinning arc — draw as series of short lines }
      startAngle := FAnimAngle;
      sweepAngle := 270;
      for i := 0 to 60 do
      begin
        angle := (startAngle + sweepAngle * i / 60) * Pi / 180;
        px := cx + r * Cos(angle);
        py := cy + r * Sin(angle);
        if i > 0 then
        begin
          bmp.DrawLineAntialias(
            cx + r * Cos((startAngle + sweepAngle * (i-1) / 60) * Pi / 180),
            cy + r * Sin((startAngle + sweepAngle * (i-1) / 60) * Pi / 180),
            px, py, arcColor, FStrokeWidth);
        end;
      end;
    end
    else if FValue > 0 then
    begin
      { Determinate arc }
      startAngle := -90;
      sweepAngle := FValue * 360;
      for i := 0 to Round(sweepAngle) do
      begin
        angle := (startAngle + i) * Pi / 180;
        px := cx + r * Cos(angle);
        py := cy + r * Sin(angle);
        if i > 0 then
        begin
          bmp.DrawLineAntialias(
            cx + r * Cos((startAngle + i - 1) * Pi / 180),
            cy + r * Sin((startAngle + i - 1) * Pi / 180),
            px, py, arcColor, FStrokeWidth);
        end;
      end;
    end;

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;
end;

{ ── TFRMaterialLoadingIndicator ── }

constructor TFRMaterialLoadingIndicator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAnimStep := 0;
  FDotCount := 3;
  FAnimTimer := TTimer.Create(Self);
  FAnimTimer.Enabled := not (csDesigning in ComponentState);
  FAnimTimer.Interval := 300;
  FAnimTimer.OnTimer := @OnAnimTimer;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
end;

destructor TFRMaterialLoadingIndicator.Destroy;
begin
  FAnimTimer.Free;
  inherited Destroy;
end;

class function TFRMaterialLoadingIndicator.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 60;
  Result.cy := 20;
end;

procedure TFRMaterialLoadingIndicator.SetDotCount(AValue: Integer);
begin
  if AValue < 2 then AValue := 2;
  if AValue > 8 then AValue := 8;
  if FDotCount = AValue then Exit;
  FDotCount := AValue;
  Invalidate;
end;

procedure TFRMaterialLoadingIndicator.OnAnimTimer(Sender: TObject);
begin
  FAnimStep := (FAnimStep + 1) mod FDotCount;
  Invalidate;
end;

procedure TFRMaterialLoadingIndicator.Paint;
var
  bmp: TBGRABitmap;
  i, cx, cy, dotR, spacing: Integer;
  alpha: Byte;
begin
  if (Width <= 0) or (Height <= 0) then Exit;
  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    cy := Height div 2;
    dotR := Min(Height div 4, 5);
    spacing := Width div (FDotCount + 1);

    for i := 0 to FDotCount - 1 do
    begin
      cx := spacing * (i + 1);
      if i = FAnimStep then
        alpha := 255
      else
        alpha := 80;
      bmp.FillEllipseAntialias(cx, cy, dotR, dotR,
        ColorToBGRA(ColorToRGB(MD3Colors.Primary), alpha));
    end;

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;
end;

end.

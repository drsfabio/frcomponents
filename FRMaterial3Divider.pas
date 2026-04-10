unit FRMaterial3Divider;

{$mode objfpc}{$H+}

{ Material Design 3 — Divider and GroupBox.

  TFRMaterialDivider  — Simple 1dp line divider
  TFRMaterialGroupBox — Container with MD3 styling, rounded corners, title

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, ExtCtrls,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterialTheme, FRMaterial3Base;

type
  TFRMDDividerOrientation = (doHorizontal, doVertical);

  { ── TFRMaterialDivider ── }

  TFRMaterialDivider = class(TFRMaterial3Graphic)
  private
    FOrientation: TFRMDDividerOrientation;
    FInsetStart: Integer;
    FInsetEnd: Integer;
    procedure SetOrientation(AValue: TFRMDDividerOrientation);
    procedure SetInsetStart(AValue: Integer);
    procedure SetInsetEnd(AValue: Integer);
  protected
    function PaintCached(ABmp: TBGRABitmap): Boolean; override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Orientation: TFRMDDividerOrientation read FOrientation write SetOrientation default doHorizontal;
    property InsetStart: Integer read FInsetStart write SetInsetStart default 0;
    property InsetEnd: Integer read FInsetEnd write SetInsetEnd default 0;
    property Align;
    property Visible;
  end;

  { ── TFRMaterialGroupBox ── }

  TFRMaterialGroupBox = class(TCustomPanel, IFRMaterialComponent)
  private
    FBorderRadius: Integer;
    FShowBorder: Boolean;
    FContentPadding: Integer;
    FPaintCache: TBGRABitmap;
    FPaintCacheW: Integer;
    FPaintCacheH: Integer;
    procedure SetBorderRadius(AValue: Integer);
    procedure SetShowBorder(AValue: Boolean);
    procedure SetContentPadding(AValue: Integer);
    function GetCaptionHeight: Integer;
    procedure InvalidatePaintCache;
  protected
    function PaintCached(ABmp: TBGRABitmap): Boolean; virtual;
    procedure Paint; override;
    procedure AdjustClientRect(var ARect: TRect); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const AThemeManager: TObject); virtual;
    property CaptionHeight: Integer read GetCaptionHeight;
  published
    property BorderRadius: Integer read FBorderRadius write SetBorderRadius default 12;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder default True;
    { Padding interno aplicado aos 4 lados (top inclui altura da caption) }
    property ContentPadding: Integer read FContentPadding write SetContentPadding default 16;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Caption;
    property ChildSizing;
    property ClientHeight;
    property ClientWidth;
    property Color;
    property Constraints;
    property Enabled;
    property Font;
    property ParentBackground;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnResize;
  end;

procedure Register;

implementation

uses Math;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialdivider_icon.lrs}
    {$I icons\frmaterialgroupbox_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialDivider, TFRMaterialGroupBox]);
end;

{ ── TFRMaterialDivider ── }

constructor TFRMaterialDivider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOrientation := doHorizontal;
  FInsetStart := 0;
  FInsetEnd := 0;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
end;

class function TFRMaterialDivider.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 200;
  Result.cy := 1;
end;

procedure TFRMaterialDivider.SetOrientation(AValue: TFRMDDividerOrientation);
begin
  if FOrientation = AValue then Exit;
  FOrientation := AValue;
  if AValue = doHorizontal then
    Height := 1
  else
    Width := 1;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialDivider.SetInsetStart(AValue: Integer);
begin
  if FInsetStart = AValue then Exit;
  FInsetStart := AValue;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialDivider.SetInsetEnd(AValue: Integer);
begin
  if FInsetEnd = AValue then Exit;
  FInsetEnd := AValue;
  InvalidatePaintCache;
  Invalidate;
end;

function TFRMaterialDivider.PaintCached(ABmp: TBGRABitmap): Boolean;
var
  c: TBGRAPixel;
begin
  Result := True;
  c := ColorToBGRA(ColorToRGB(MD3Colors.OutlineVariant));
  if FOrientation = doHorizontal then
    ABmp.DrawLineAntialias(FInsetStart, 0, Width - FInsetEnd, 0, c, 1.0)
  else
    ABmp.DrawLineAntialias(0, FInsetStart, 0, Height - FInsetEnd, c, 1.0);
end;

{ ── TFRMaterialGroupBox ── }

constructor TFRMaterialGroupBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBorderRadius := 12;
  FShowBorder := True;
  FContentPadding := 16;
  Width := 250;
  Height := 150;
  BevelOuter := bvNone;
  BevelInner := bvNone;
  
  FRMDRegisterComponent(Self);
    
  Color := MD3Colors.SurfaceContainerLow;
  Font.Size := 10;
  Font.Color := MD3Colors.OnSurface;
end;

destructor TFRMaterialGroupBox.Destroy;
begin
  FRMDUnregisterComponent(Self);
  if Assigned(FPaintCache) then
    FPaintCache.Free;
  inherited Destroy;
end;

procedure TFRMaterialGroupBox.ApplyTheme(const AThemeManager: TObject);
begin
  if not Assigned(AThemeManager) then Exit;
  Color := MD3Colors.SurfaceContainerLow;
  Font.Color := MD3Colors.OnSurface;
  Invalidate;
end;

procedure TFRMaterialGroupBox.InvalidatePaintCache;
begin
  if Assigned(FPaintCache) then
  begin
    FPaintCache.Free;
    FPaintCache := nil;
  end;
  FPaintCacheW := 0;
  FPaintCacheH := 0;
end;

procedure TFRMaterialGroupBox.SetBorderRadius(AValue: Integer);
begin
  if FBorderRadius = AValue then Exit;
  FBorderRadius := AValue;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialGroupBox.SetShowBorder(AValue: Boolean);
begin
  if FShowBorder = AValue then Exit;
  FShowBorder := AValue;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialGroupBox.SetContentPadding(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if FContentPadding = AValue then Exit;
  FContentPadding := AValue;
  InvalidatePaintCache;
  ReAlign;
  Invalidate;
end;

function TFRMaterialGroupBox.GetCaptionHeight: Integer;
begin
  if Caption <> '' then
  begin
    Canvas.Font := Self.Font;
    Canvas.Font.Style := [fsBold];
    Result := Canvas.TextHeight('Áy') + 12; { text height + top margin }
  end
  else
    Result := 0;
end;

procedure TFRMaterialGroupBox.AdjustClientRect(var ARect: TRect);
var
  topOffset: Integer;
begin
  inherited AdjustClientRect(ARect);
  topOffset := FContentPadding;
  if Caption <> '' then
    topOffset := GetCaptionHeight + 8; { caption area + gap below caption }
  ARect.Left := ARect.Left + FContentPadding;
  ARect.Top := ARect.Top + topOffset;
  ARect.Right := ARect.Right - FContentPadding;
  ARect.Bottom := ARect.Bottom - FContentPadding;
end;

function TFRMaterialGroupBox.PaintCached(ABmp: TBGRABitmap): Boolean;
begin
  Result := True;
  { Background }
  MD3FillRoundRect(ABmp, 0, 0, Width - 1, Height - 1, FBorderRadius, Color);

  { Border }
  if FShowBorder then
    MD3RoundRect(ABmp, 0.5, 0.5, Width - 1.5, Height - 1.5, FBorderRadius,
      MD3Colors.OutlineVariant, 1.0);
end;

procedure TFRMaterialGroupBox.Paint;
var
  capH, capW: Integer;
  aRect: TRect;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  { Use paint cache if available and valid }
  if (FPaintCache = nil) or (FPaintCacheW <> Width) or (FPaintCacheH <> Height) then
  begin
    if Assigned(FPaintCache) then
      FPaintCache.Free;
    FPaintCache := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
    FPaintCacheW := Width;
    FPaintCacheH := Height;
    PaintCached(FPaintCache);
  end;

  FPaintCache.Draw(Canvas, 0, 0, False);

  { Caption }
  if Caption <> '' then
  begin
    Canvas.Font := Self.Font;
    Canvas.Font.Style := [fsBold];
    capH := Canvas.TextHeight(Caption);
    capW := Canvas.TextWidth(Caption);
    aRect := Rect(16, 12, 16 + capW, 12 + capH);
    MD3DrawText(Canvas, Caption, aRect, MD3Colors.OnSurface, taLeftJustify, False);
  end;
end;

end.

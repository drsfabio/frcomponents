unit FRMaterial3Badge;

{$mode objfpc}{$H+}

{ Material Design 3 — Badge.

  TFRMaterialBadge — Small status indicator attached to another control.
    • Dot mode  — 6×6 circle, no text (notification indicator)
    • Count mode — pill-shaped with number (e.g. "3", "99+")

  Usage:
    Badge := TFRMaterialBadge.Create(Self);
    Badge.AttachTo := MyButtonIcon;
    Badge.Value := 5;

  Automatically positions itself at the top-right corner of the target
  control and stays attached when the target moves/resizes.

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialTheme;

type
  TFRMDBadgeMode = (bmDot, bmCount);

  { ── TFRMaterialBadge ── }

  TFRMaterialBadge = class(TFRMaterial3Graphic)
  private
    FBadgeMode: TFRMDBadgeMode;
    FValue: Integer;
    FMaxValue: Integer;
    FAttachTo: TControl;
    FOffsetX: Integer;
    FOffsetY: Integer;
    procedure SetBadgeMode(AValue: TFRMDBadgeMode);
    procedure SetValue(AValue: Integer);
    procedure SetMaxValue(AValue: Integer);
    procedure SetAttachTo(AValue: TControl);
    procedure SetOffsetX(AValue: Integer);
    procedure SetOffsetY(AValue: Integer);
    procedure UpdatePosition;
  protected
    function PaintCached(ABmp: TBGRABitmap): Boolean; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetParent(NewParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const AThemeManager: TObject); virtual;
    function GetDisplayText: string;
  published
    property BadgeMode: TFRMDBadgeMode read FBadgeMode write SetBadgeMode default bmCount;
    property Value: Integer read FValue write SetValue default 0;
    property MaxValue: Integer read FMaxValue write SetMaxValue default 99;
    property AttachTo: TControl read FAttachTo write SetAttachTo;
    property OffsetX: Integer read FOffsetX write SetOffsetX default 0;
    property OffsetY: Integer read FOffsetY write SetOffsetY default 0;
    property Constraints;
    property Visible;
  end;

procedure Register;

implementation

uses Math;

{ ── TFRMaterialBadge ── }

constructor TFRMaterialBadge.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FRMDRegisterComponent(Self);

  FBadgeMode := bmCount;
  FValue := 0;
  FMaxValue := 99;
  FAttachTo := nil;
  FOffsetX := 0;
  FOffsetY := 0;
  Width := 16;
  Height := 16;
end;

destructor TFRMaterialBadge.Destroy;
begin
  if Assigned(FAttachTo) then
    FAttachTo.RemoveFreeNotification(Self);
  FRMDUnregisterComponent(Self);
  inherited Destroy;
end;

procedure TFRMaterialBadge.ApplyTheme(const AThemeManager: TObject);
begin
  if not Assigned(AThemeManager) then Exit;
  Invalidate;
end;

procedure TFRMaterialBadge.SetBadgeMode(AValue: TFRMDBadgeMode);
begin
  if FBadgeMode = AValue then Exit;
  FBadgeMode := AValue;
  UpdatePosition;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialBadge.SetValue(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if FValue = AValue then Exit;
  FValue := AValue;
  UpdatePosition;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialBadge.SetMaxValue(AValue: Integer);
begin
  if AValue < 1 then AValue := 1;
  if FMaxValue = AValue then Exit;
  FMaxValue := AValue;
  UpdatePosition;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialBadge.SetAttachTo(AValue: TControl);
begin
  if FAttachTo = AValue then Exit;
  if Assigned(FAttachTo) then
    FAttachTo.RemoveFreeNotification(Self);
  FAttachTo := AValue;
  if Assigned(FAttachTo) then
    FAttachTo.FreeNotification(Self);
  UpdatePosition;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialBadge.SetOffsetX(AValue: Integer);
begin
  if FOffsetX = AValue then Exit;
  FOffsetX := AValue;
  UpdatePosition;
end;

procedure TFRMaterialBadge.SetOffsetY(AValue: Integer);
begin
  if FOffsetY = AValue then Exit;
  FOffsetY := AValue;
  UpdatePosition;
end;

procedure TFRMaterialBadge.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FAttachTo) then
  begin
    FAttachTo := nil;
    Invalidate;
  end;
end;

procedure TFRMaterialBadge.SetParent(NewParent: TWinControl);
begin
  inherited SetParent(NewParent);
  UpdatePosition;
end;

function TFRMaterialBadge.GetDisplayText: string;
begin
  if FBadgeMode = bmDot then
    Result := ''
  else if FValue > FMaxValue then
    Result := IntToStr(FMaxValue) + '+'
  else
    Result := IntToStr(FValue);
end;

procedure TFRMaterialBadge.UpdatePosition;
var
  txt: string;
  bw, bh: Integer;
  tmp: TBGRABitmap;
begin
  if FBadgeMode = bmDot then
  begin
    bw := 8;
    bh := 8;
  end
  else
  begin
    txt := GetDisplayText;
    bh := 18;
    { Use temporary BGRABitmap for text measurement — avoids Canvas handle issues }
    tmp := TBGRABitmap.Create(1, 1);
    try
      tmp.FontFullHeight := 11;
      tmp.FontStyle := [fsBold];
      tmp.FontQuality := fqFineAntialiasing;
      bw := Max(bh, tmp.TextSize(txt).cx + 10);
    finally
      tmp.Free;
    end;
  end;

  Width := bw;
  Height := bh;

  if Assigned(FAttachTo) and Assigned(Parent) and Assigned(FAttachTo.Parent) then
  begin
    { Position at top-right corner of target control }
    if FAttachTo.Parent = Parent then
    begin
      Left := FAttachTo.Left + FAttachTo.Width - (bw * 2 div 3) + FOffsetX;
      Top := FAttachTo.Top - (bh div 3) + FOffsetY;
    end;
  end;
end;

function TFRMaterialBadge.PaintCached(ABmp: TBGRABitmap): Boolean;
var
  badgeColor, textColor: TColor;
  txt: string;
  tw, th: Integer;
begin
  Result := True;

  UpdatePosition;

  badgeColor := MD3Colors.Error;
  textColor := MD3Colors.OnError;

  if FBadgeMode = bmDot then
  begin
    ABmp.FillEllipseAntialias(Width / 2, Height / 2,
      Width / 2 - 0.5, Height / 2 - 0.5,
      ColorToBGRA(badgeColor));
  end
  else
  begin
    { Pill shape }
    MD3FillRoundRect(ABmp, 0, 0, Width - 1, Height - 1, Height div 2, badgeColor);

    { Text — centered in pill }
    if FValue > 0 then
    begin
      txt := GetDisplayText;
      ABmp.FontFullHeight := 10;
      ABmp.FontStyle := [fsBold];
      ABmp.FontQuality := fqFineAntialiasing;
      tw := ABmp.TextSize(txt).cx;
      th := ABmp.TextSize(txt).cy;
      ABmp.TextOut((Width - tw) div 2, (Height - th) div 2,
        txt, ColorToBGRA(textColor));
    end;
  end;
end;

{ ── Registration ── }

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialbadge_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialBadge]);
end;

end.

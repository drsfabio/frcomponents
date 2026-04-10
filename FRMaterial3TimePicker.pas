unit FRMaterial3TimePicker;

{$mode objfpc}{$H+}

{ Material Design 3 — Time Picker.

  TFRMaterialTimePicker — Input-style time picker with
  hour/minute fields and AM/PM toggle.

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialTheme;

type
  TFRMDTimeFormat = (tfHour12, tfHour24);

  TFRMaterialTimePicker = class(TFRMaterial3Control)
  private
    FHour: Integer;
    FMinute: Integer;
    FTimeFormat: TFRMDTimeFormat;
    FIsAM: Boolean;
    FActiveField: Integer; { 0=hour, 1=minute }
    FOnChange: TNotifyEvent;
    procedure SetHour(AValue: Integer);
    procedure SetMinute(AValue: Integer);
    procedure SetTimeFormat(AValue: TFRMDTimeFormat);
    function GetTimeStr: string;
  protected
    function PaintCached(ABmp: TBGRABitmap): Boolean; override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure DoOnResize; override;
  public
    constructor Create(AOwner: TComponent); override;
    property TimeStr: string read GetTimeStr;
  published
    property Hour: Integer read FHour write SetHour default 0;
    property Minute: Integer read FMinute write SetMinute default 0;
    property TimeFormat: TFRMDTimeFormat read FTimeFormat write SetTimeFormat default tfHour24;
    property IsAM: Boolean read FIsAM write FIsAM default True;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
    property Cursor;
    property Enabled;
    property Font;
    property ParentFont;
    property PopupMenu;
    property ShowHint;
    property ParentShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
  end;

procedure Register;

implementation

uses Math, LCLType;

constructor TFRMaterialTimePicker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHour := 0;
  FMinute := 0;
  FTimeFormat := tfHour24;
  FIsAM := True;
  FActiveField := 0;
  Width := 220;
  Height := 72;
  TabStop := True;
end;

procedure TFRMaterialTimePicker.DoOnResize;
begin
  inherited DoOnResize;
  if not (csLoading in ComponentState) then
    Height := 72 + MD3DensityDelta(Density);
end;

procedure TFRMaterialTimePicker.SetHour(AValue: Integer);
var
  maxH: Integer;
begin
  if FTimeFormat = tfHour24 then maxH := 23 else maxH := 12;
  AValue := Max(0, Min(AValue, maxH));
  if FHour <> AValue then
  begin
    FHour := AValue;
    InvalidatePaintCache;
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TFRMaterialTimePicker.SetMinute(AValue: Integer);
begin
  AValue := Max(0, Min(AValue, 59));
  if FMinute <> AValue then
  begin
    FMinute := AValue;
    InvalidatePaintCache;
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TFRMaterialTimePicker.SetTimeFormat(AValue: TFRMDTimeFormat);
begin
  if FTimeFormat <> AValue then
  begin
    FTimeFormat := AValue;
    if FTimeFormat = tfHour12 then
    begin
      if FHour = 0 then
      begin
        FHour := 12;
        FIsAM := True;
      end
      else if FHour <= 12 then
        FIsAM := True
      else
      begin
        FHour := FHour - 12;
        FIsAM := False;
      end;
    end;
    InvalidatePaintCache;
    Invalidate;
  end;
end;

function TFRMaterialTimePicker.GetTimeStr: string;
begin
  if FTimeFormat = tfHour24 then
    Result := Format('%.2d:%.2d', [FHour, FMinute])
  else
  begin
    if FIsAM then
      Result := Format('%.2d:%.2d AM', [FHour, FMinute])
    else
      Result := Format('%.2d:%.2d PM', [FHour, FMinute]);
  end;
end;

function TFRMaterialTimePicker.PaintCached(ABmp: TBGRABitmap): Boolean;
var
  padY, fW, colW, r: Integer;
  hBg, mBg: TColor;
begin
  Result := False; { Cannot fully cache - has complex Canvas text rendering }

  { Proportional metrics based on Width (reference = 220) and Height (reference = 72) }
  padY := Height * 8 div 72;
  fW := Width * 80 div 220;       { hour/minute field width }
  colW := Width * 16 div 220;     { colon width }
  r := Height * 8 div 72;
  if r < 4 then r := 4;

  { hour field }
  if FActiveField = 0 then
    hBg := MD3Colors.PrimaryContainer
  else
    hBg := MD3Colors.SurfaceContainerHighest;

  { minute field }
  if FActiveField = 1 then
    mBg := MD3Colors.PrimaryContainer
  else
    mBg := MD3Colors.SurfaceContainerHighest;

  MD3FillRoundRect(ABmp, 0, padY, fW, Height - padY, r, hBg);
  MD3FillRoundRect(ABmp, fW + colW, padY, fW + colW + fW, Height - padY, r, mBg);
end;

procedure TFRMaterialTimePicker.Paint;
var
  padY, fW, colW, r, ampmX: Integer;
  aRect: TRect;
begin
  { Proportional metrics based on Width (reference = 220) and Height (reference = 72) }
  padY := Height * 8 div 72;
  fW := Width * 80 div 220;       { hour/minute field width }
  colW := Width * 16 div 220;     { colon width }
  r := Height * 8 div 72;
  if r < 4 then r := 4;

  { Call PaintCached for bitmap rendering (though it returns False, we still draw it) }
  inherited Paint;

  { colon text }
  Canvas.Font.Size := Height * 20 div 72;
  if Canvas.Font.Size < 10 then Canvas.Font.Size := 10;
  Canvas.Font.Style := [];
  aRect := Rect(fW, 0, fW + colW, Height);
  MD3DrawText(Canvas, ':', aRect, MD3Colors.OnSurface, taCenter, True);

  { hour text }
  aRect := Rect(0, padY, fW, Height - padY);
  if FActiveField = 0 then
    MD3DrawText(Canvas, Format('%.2d', [FHour]), aRect, MD3Colors.OnPrimaryContainer, taCenter, True)
  else
    MD3DrawText(Canvas, Format('%.2d', [FHour]), aRect, MD3Colors.OnSurface, taCenter, True);

  { minute text }
  aRect := Rect(fW + colW, padY, fW + colW + fW, Height - padY);
  if FActiveField = 1 then
    MD3DrawText(Canvas, Format('%.2d', [FMinute]), aRect, MD3Colors.OnPrimaryContainer, taCenter, True)
  else
    MD3DrawText(Canvas, Format('%.2d', [FMinute]), aRect, MD3Colors.OnSurface, taCenter, True);

  { AM/PM toggle }
  if FTimeFormat = tfHour12 then
  begin
    ampmX := fW + colW + fW + Width * 8 div 220;
    Canvas.Font.Size := Height * 10 div 72;
    if Canvas.Font.Size < 7 then Canvas.Font.Size := 7;

    { AM }
    if FIsAM then
    begin
      Canvas.Brush.Color := MD3Colors.TertiaryContainer;
      Canvas.Font.Color := MD3Colors.OnTertiaryContainer;
    end
    else
    begin
      Canvas.Brush.Color := MD3Colors.SurfaceContainerHighest;
      Canvas.Font.Color := MD3Colors.OnSurface;
    end;
    aRect := Rect(ampmX, padY, Width, Height div 2);
    Canvas.FillRect(aRect);
    MD3DrawText(Canvas, 'AM', aRect, Canvas.Font.Color, taCenter, True);

    { PM }
    if not FIsAM then
    begin
      Canvas.Brush.Color := MD3Colors.TertiaryContainer;
      Canvas.Font.Color := MD3Colors.OnTertiaryContainer;
    end
    else
    begin
      Canvas.Brush.Color := MD3Colors.SurfaceContainerHighest;
      Canvas.Font.Color := MD3Colors.OnSurface;
    end;
    aRect := Rect(ampmX, Height div 2, Width, Height - padY);
    Canvas.FillRect(aRect);
    MD3DrawText(Canvas, 'PM', aRect, Canvas.Font.Color, taCenter, True);
  end;

  Canvas.Font.Size := 10;
end;

procedure TFRMaterialTimePicker.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  fW, colW: Integer;
begin
  inherited;
  if Button <> mbLeft then Exit;
  SetFocus;

  fW := Width * 80 div 220;
  colW := Width * 16 div 220;

  if X < fW + colW div 2 then
    FActiveField := 0
  else if X < fW + colW + fW + colW div 2 then
    FActiveField := 1
  else if (FTimeFormat = tfHour12) then
  begin
    if Y < Height div 2 then
      FIsAM := True
    else
      FIsAM := False;
  end;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialTimePicker.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  case Key of
    VK_TAB:
    begin
      if FActiveField = 0 then
        FActiveField := 1
      else
        FActiveField := 0;
      Key := 0;
      InvalidatePaintCache;
      Invalidate;
    end;
    VK_UP:
    begin
      if FActiveField = 0 then
        SetHour(FHour + 1)
      else
        SetMinute(FMinute + 1);
    end;
    VK_DOWN:
    begin
      if FActiveField = 0 then
        SetHour(FHour - 1)
      else
        SetMinute(FMinute - 1);
    end;
  end;
end;

procedure TFRMaterialTimePicker.KeyPress(var Key: Char);
var
  d: Integer;
begin
  inherited;
  if Key in ['0'..'9'] then
  begin
    d := Ord(Key) - Ord('0');
    if FActiveField = 0 then
      SetHour((FHour mod 10) * 10 + d)
    else
      SetMinute((FMinute mod 10) * 10 + d);
  end;
end;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialtimepicker_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialTimePicker]);
end;

end.

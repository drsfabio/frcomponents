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
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base;

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
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
  public
    constructor Create(AOwner: TComponent); override;
    property TimeStr: string read GetTimeStr;
  published
    property Hour: Integer read FHour write SetHour default 0;
    property Minute: Integer read FMinute write SetMinute default 0;
    property TimeFormat: TFRMDTimeFormat read FTimeFormat write SetTimeFormat default tfHour24;
    property IsAM: Boolean read FIsAM write FIsAM default True;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Anchors;
    property Visible;
    property Enabled;
    property TabStop;
    property TabOrder;
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

procedure TFRMaterialTimePicker.SetHour(AValue: Integer);
var
  maxH: Integer;
begin
  if FTimeFormat = tfHour24 then maxH := 23 else maxH := 12;
  AValue := Max(0, Min(AValue, maxH));
  if FHour <> AValue then
  begin
    FHour := AValue;
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

procedure TFRMaterialTimePicker.Paint;
var
  bmp: TBGRABitmap;
  hBg, mBg: TColor;
  aRect: TRect;
  ampmX: Integer;
begin
  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
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

    MD3FillRoundRect(bmp, 0, 8, 80, Height - 8, 8, hBg);
    MD3FillRoundRect(bmp, 96, 8, 176, Height - 8, 8, mBg);

    { colon }
    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { colon text }
  Canvas.Font.Size := 20;
  Canvas.Font.Style := [];
  aRect := Rect(80, 0, 96, Height);
  MD3DrawText(Canvas, ':', aRect, MD3Colors.OnSurface, taCenter, True);

  { hour text }
  aRect := Rect(0, 8, 80, Height - 8);
  if FActiveField = 0 then
    MD3DrawText(Canvas, Format('%.2d', [FHour]), aRect, MD3Colors.OnPrimaryContainer, taCenter, True)
  else
    MD3DrawText(Canvas, Format('%.2d', [FHour]), aRect, MD3Colors.OnSurface, taCenter, True);

  { minute text }
  aRect := Rect(96, 8, 176, Height - 8);
  if FActiveField = 1 then
    MD3DrawText(Canvas, Format('%.2d', [FMinute]), aRect, MD3Colors.OnPrimaryContainer, taCenter, True)
  else
    MD3DrawText(Canvas, Format('%.2d', [FMinute]), aRect, MD3Colors.OnSurface, taCenter, True);

  { AM/PM toggle }
  if FTimeFormat = tfHour12 then
  begin
    ampmX := 184;
    Canvas.Font.Size := 10;

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
    aRect := Rect(ampmX, 8, ampmX + 36, 36);
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
    aRect := Rect(ampmX, 36, ampmX + 36, Height - 8);
    Canvas.FillRect(aRect);
    MD3DrawText(Canvas, 'PM', aRect, Canvas.Font.Color, taCenter, True);
  end;

  Canvas.Font.Size := 10;
end;

procedure TFRMaterialTimePicker.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button <> mbLeft then Exit;
  SetFocus;

  if X < 88 then
    FActiveField := 0
  else if X < 180 then
    FActiveField := 1
  else if (FTimeFormat = tfHour12) then
  begin
    if Y < Height div 2 then
      FIsAM := True
    else
      FIsAM := False;
  end;
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
  RegisterComponents('BGRA Controls', [TFRMaterialTimePicker]);
end;

end.

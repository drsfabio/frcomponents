unit FRMaterial3DatePicker;

{$mode objfpc}{$H+}

{ Material Design 3 — Date Picker.

  TFRMaterialDatePicker — Calendar-based date picker with MD3 styling.
    • Full month calendar grid
    • Month/year navigation
    • Today highlight
    • Selected date highlight with circle
    • Range-aware min/max dates
    • Integrates with global theme

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics,
  {$IFDEF FPC} LCLType, LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialTheme, FRMaterialIcons;

type
  TFRMaterialDatePicker = class(TFRMaterial3Control)
  private
    FDate: TDate;
    FViewYear: Integer;
    FViewMonth: Integer;
    FMinDate: TDate;
    FMaxDate: TDate;
    FShowToday: Boolean;
    FOnChange: TNotifyEvent;
    FHoverDay: Integer;
    FHoverNav: Integer; { -1=prev, 0=none, 1=next }
    function GetYear: Integer;
    function GetMonth: Integer;
    function GetDay: Integer;
    procedure SetDate(AValue: TDate);
    procedure SetMinDate(AValue: TDate);
    procedure SetMaxDate(AValue: TDate);
    procedure SetShowToday(AValue: Boolean);
    function DaysInViewMonth: Integer;
    function FirstDayOfWeek: Integer; { 0=Sun..6=Sat }
    function DayCellRect(ADay: Integer): TRect;
    function NavPrevRect: TRect;
    function NavNextRect: TRect;
    function IsDayEnabled(ADay: Integer): Boolean;
    procedure DoNavigate(ADir: Integer);
  protected
    function PaintCached(ABmp: TBGRABitmap): Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseLeave; override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Year: Integer read GetYear;
    property Month: Integer read GetMonth;
    property Day: Integer read GetDay;
  published
    property Date: TDate read FDate write SetDate;
    property MinDate: TDate read FMinDate write SetMinDate;
    property MaxDate: TDate read FMaxDate write SetMaxDate;
    property ShowToday: Boolean read FShowToday write SetShowToday default True;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Align;
    property Anchors;
    property BorderSpacing;
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

uses DateUtils, Math;

const
  HEADER_H   = 56;   { month/year header height }
  DOW_H      = 32;   { day-of-week header }
  CELL_SIZE  = 40;   { day cell size }
  GRID_COLS  = 7;
  GRID_ROWS  = 6;

{ ── TFRMaterialDatePicker ── }

constructor TFRMaterialDatePicker.Create(AOwner: TComponent);
var
  y, m, d: Word;
begin
  inherited Create(AOwner);
  FDate := SysUtils.Date;
  DecodeDate(FDate, y, m, d);
  FViewYear := y;
  FViewMonth := m;
  FMinDate := 0;
  FMaxDate := 0;
  FShowToday := True;
  FHoverDay := 0;
  FHoverNav := 0;

  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
  TabStop := True;
end;

class function TFRMaterialDatePicker.GetControlClassDefaultSize: TSize;
begin
  Result.cx := CELL_SIZE * GRID_COLS + 16; { 7 cols + padding }
  Result.cy := HEADER_H + DOW_H + CELL_SIZE * GRID_ROWS + 8;
end;

function TFRMaterialDatePicker.GetYear: Integer;
var
  y, m, d: Word;
begin
  DecodeDate(FDate, y, m, d);
  Result := y;
end;

function TFRMaterialDatePicker.GetMonth: Integer;
var
  y, m, d: Word;
begin
  DecodeDate(FDate, y, m, d);
  Result := m;
end;

function TFRMaterialDatePicker.GetDay: Integer;
var
  y, m, d: Word;
begin
  DecodeDate(FDate, y, m, d);
  Result := d;
end;

procedure TFRMaterialDatePicker.SetDate(AValue: TDate);
var
  y, m, d: Word;
begin
  if FDate = AValue then Exit;
  FDate := AValue;
  DecodeDate(FDate, y, m, d);
  FViewYear := y;
  FViewMonth := m;
  InvalidatePaintCache;
  Invalidate;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TFRMaterialDatePicker.SetMinDate(AValue: TDate);
begin
  if FMinDate = AValue then Exit;
  FMinDate := AValue;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialDatePicker.SetMaxDate(AValue: TDate);
begin
  if FMaxDate = AValue then Exit;
  FMaxDate := AValue;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialDatePicker.SetShowToday(AValue: Boolean);
begin
  if FShowToday = AValue then Exit;
  FShowToday := AValue;
  InvalidatePaintCache;
  Invalidate;
end;

function TFRMaterialDatePicker.DaysInViewMonth: Integer;
begin
  Result := MonthDays[IsLeapYear(FViewYear), FViewMonth];
end;

function TFRMaterialDatePicker.FirstDayOfWeek: Integer;
begin
  Result := DayOfWeek(EncodeDate(FViewYear, FViewMonth, 1)) - 1; { 0=Sun }
end;

function TFRMaterialDatePicker.DayCellRect(ADay: Integer): TRect;
var
  idx, col, row, gridLeft, gridTop: Integer;
begin
  idx := (ADay - 1) + FirstDayOfWeek;
  col := idx mod GRID_COLS;
  row := idx div GRID_COLS;
  gridLeft := (Width - CELL_SIZE * GRID_COLS) div 2;
  gridTop := HEADER_H + DOW_H;
  Result := Rect(
    gridLeft + col * CELL_SIZE,
    gridTop + row * CELL_SIZE,
    gridLeft + (col + 1) * CELL_SIZE,
    gridTop + (row + 1) * CELL_SIZE
  );
end;

function TFRMaterialDatePicker.NavPrevRect: TRect;
begin
  Result := Rect(8, 8, 48, 48);
end;

function TFRMaterialDatePicker.NavNextRect: TRect;
begin
  Result := Rect(Width - 48, 8, Width - 8, 48);
end;

function TFRMaterialDatePicker.IsDayEnabled(ADay: Integer): Boolean;
var
  dt: TDate;
begin
  Result := True;
  dt := EncodeDate(FViewYear, FViewMonth, ADay);
  if (FMinDate > 0) and (dt < FMinDate) then Result := False;
  if (FMaxDate > 0) and (dt > FMaxDate) then Result := False;
end;

procedure TFRMaterialDatePicker.DoNavigate(ADir: Integer);
begin
  FViewMonth := FViewMonth + ADir;
  if FViewMonth > 12 then
  begin
    FViewMonth := 1;
    Inc(FViewYear);
  end
  else if FViewMonth < 1 then
  begin
    FViewMonth := 12;
    Dec(FViewYear);
  end;
  FHoverDay := 0;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialDatePicker.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  r: TRect;
begin
  inherited;
  if Button <> mbLeft then Exit;

  { Navigation arrows }
  if PtInRect(Point(X, Y), NavPrevRect) then
  begin
    DoNavigate(-1);
    Exit;
  end;
  if PtInRect(Point(X, Y), NavNextRect) then
  begin
    DoNavigate(1);
    Exit;
  end;

  { Day cells }
  for i := 1 to DaysInViewMonth do
  begin
    r := DayCellRect(i);
    if PtInRect(Point(X, Y), r) and IsDayEnabled(i) then
    begin
      FDate := EncodeDate(FViewYear, FViewMonth, i);
      InvalidatePaintCache;
      Invalidate;
      if Assigned(FOnChange) then
        FOnChange(Self);
      Exit;
    end;
  end;
end;

procedure TFRMaterialDatePicker.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  i, newHover, newNav: Integer;
  r: TRect;
begin
  inherited;
  newHover := 0;
  newNav := 0;

  if PtInRect(Point(X, Y), NavPrevRect) then
    newNav := -1
  else if PtInRect(Point(X, Y), NavNextRect) then
    newNav := 1;

  for i := 1 to DaysInViewMonth do
  begin
    r := DayCellRect(i);
    if PtInRect(Point(X, Y), r) then
    begin
      newHover := i;
      Break;
    end;
  end;

  if (newHover <> FHoverDay) or (newNav <> FHoverNav) then
  begin
    FHoverDay := newHover;
    FHoverNav := newNav;
    InvalidatePaintCache;
    Invalidate;
  end;
end;

procedure TFRMaterialDatePicker.MouseLeave;
begin
  inherited;
  if (FHoverDay <> 0) or (FHoverNav <> 0) then
  begin
    FHoverDay := 0;
    FHoverNav := 0;
    InvalidatePaintCache;
    Invalidate;
  end;
end;

function TFRMaterialDatePicker.PaintCached(ABmp: TBGRABitmap): Boolean;
var
  i, gridLeft, gridTop, cx, cy, col, row, idx: Integer;
  dayStr, monthTitle: string;
  selY, selM, selD: Word;
  todayY, todayM, todayD: Word;
  isSelected, isToday, dayEnabled: Boolean;
  textColor: TColor;
  navIcon: TBGRABitmap;
  dayNames: array[0..6] of string;
begin
  Result := True;

  DecodeDate(FDate, selY, selM, selD);
  DecodeDate(SysUtils.Date, todayY, todayM, todayD);

  dayNames[0] := 'Su';
  dayNames[1] := 'Mo';
  dayNames[2] := 'Tu';
  dayNames[3] := 'We';
  dayNames[4] := 'Th';
  dayNames[5] := 'Fr';
  dayNames[6] := 'Sa';

  gridLeft := (Width - CELL_SIZE * GRID_COLS) div 2;
  gridTop := HEADER_H + DOW_H;

  ABmp.Fill(ColorToBGRA(MD3Colors.Surface));

  { ── Header: Month Year ── }
  monthTitle := FormatSettings.LongMonthNames[FViewMonth] + ' ' + IntToStr(FViewYear);
  ABmp.FontFullHeight := 18;
  ABmp.FontStyle := [fsBold];
  ABmp.FontQuality := fqFineAntialiasing;
  ABmp.TextOut(
    (Width - ABmp.TextSize(monthTitle).cx) div 2,
    (HEADER_H - 18) div 2,
    monthTitle,
    ColorToBGRA(MD3Colors.OnSurface));

  { Navigation arrows }
  { Prev }
  if FHoverNav = -1 then
    ABmp.FillEllipseAntialias(28, 28, 18, 18,
      ColorToBGRA(MD3Colors.OnSurface, 12));
  navIcon := FRGetCachedIcon(imArrowBack,
    FRColorToSVGHex(MD3Colors.OnSurfaceVariant), 2.0, 24, 24);
  ABmp.PutImage(16, 16, navIcon, dmDrawWithTransparency);

  { Next }
  if FHoverNav = 1 then
    ABmp.FillEllipseAntialias(Width - 28, 28, 18, 18,
      ColorToBGRA(MD3Colors.OnSurface, 12));
  navIcon := FRGetCachedIcon(imArrowForward,
    FRColorToSVGHex(MD3Colors.OnSurfaceVariant), 2.0, 24, 24);
  ABmp.PutImage(Width - 40, 16, navIcon, dmDrawWithTransparency);

  { ── Day-of-week headers ── }
  ABmp.FontFullHeight := 12;
  ABmp.FontStyle := [];
  for i := 0 to 6 do
  begin
    cx := gridLeft + i * CELL_SIZE + CELL_SIZE div 2;
    cy := HEADER_H + (DOW_H - 12) div 2;
    ABmp.TextOut(
      cx - ABmp.TextSize(dayNames[i]).cx div 2,
      cy,
      dayNames[i],
      ColorToBGRA(MD3Colors.OnSurfaceVariant));
  end;

  { ── Day cells ── }
  ABmp.FontFullHeight := 14;
  ABmp.FontStyle := [];
  for i := 1 to DaysInViewMonth do
  begin
    idx := (i - 1) + FirstDayOfWeek;
    col := idx mod GRID_COLS;
    row := idx div GRID_COLS;
    cx := gridLeft + col * CELL_SIZE + CELL_SIZE div 2;
    cy := gridTop + row * CELL_SIZE + CELL_SIZE div 2;

    isSelected := (FViewYear = selY) and (FViewMonth = selM) and (i = Integer(selD));
    isToday := FShowToday and (FViewYear = todayY) and
               (FViewMonth = todayM) and (i = Integer(todayD));
    dayEnabled := IsDayEnabled(i);

    dayStr := IntToStr(i);

    { Background }
    if isSelected then
    begin
      ABmp.FillEllipseAntialias(cx, cy, 18, 18,
        ColorToBGRA(MD3Colors.Primary));
      textColor := MD3Colors.OnPrimary;
    end
    else if (FHoverDay = i) and dayEnabled then
    begin
      ABmp.FillEllipseAntialias(cx, cy, 18, 18,
        ColorToBGRA(MD3Colors.OnSurface, 12));
      textColor := MD3Colors.OnSurface;
    end
    else if isToday then
    begin
      ABmp.EllipseAntialias(cx, cy, 18, 18,
        ColorToBGRA(MD3Colors.Primary), 1.5);
      textColor := MD3Colors.Primary;
    end
    else
    begin
      if dayEnabled then
        textColor := MD3Colors.OnSurface
      else
        textColor := MD3Colors.OnSurfaceVariant;
    end;

    { Day number }
    if not dayEnabled then
      textColor := MD3Blend(MD3Colors.Surface, MD3Colors.OnSurface, 80);

    ABmp.TextOut(
      cx - ABmp.TextSize(dayStr).cx div 2,
      cy - ABmp.TextSize(dayStr).cy div 2,
      dayStr,
      ColorToBGRA(textColor));
  end;
end;

{ ── Registration ── }

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialdatepicker_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialDatePicker]);
end;

end.

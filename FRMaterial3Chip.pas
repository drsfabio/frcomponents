unit FRMaterial3Chip;

{$mode objfpc}{$H+}

{ Material Design 3 — Chips and Segmented Buttons.

  TFRMaterialChip            — Chip (Assist, Filter, Input, Suggestion)
  TFRMaterialSegmentedButton — Connected segmented button group

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialIcons, FRMaterialTheme;

type
  TFRMDChipStyle = (csAssist, csFilter, csInput, csSuggestion);

  { ── TFRMaterialChip ── }

  TFRMaterialChip = class(TFRMaterial3Control)
  private
    FChipStyle: TFRMDChipStyle;
    FSelected: Boolean;
    FDeletable: Boolean;
    FIconMode: TFRIconMode;
    FShowIcon: Boolean;
    FOnDelete: TNotifyEvent;
    procedure SetChipStyle(AValue: TFRMDChipStyle);
    procedure SetSelected(AValue: Boolean);
    procedure SetDeletable(AValue: Boolean);
    procedure SetShowIcon(AValue: Boolean);
    procedure SetIconMode(AValue: TFRIconMode);
  protected
    procedure Paint; override;
    procedure DoOnResize; override;
    procedure Click; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property ChipStyle: TFRMDChipStyle read FChipStyle write SetChipStyle default csAssist;
    property Selected: Boolean read FSelected write SetSelected default False;
    property Deletable: Boolean read FDeletable write SetDeletable default False;
    property ShowIcon: Boolean read FShowIcon write SetShowIcon default False;
    property IconMode: TFRIconMode read FIconMode write SetIconMode default imSearch;
    property Caption;
    property Font;
    property Enabled;
    property Visible;
    property OnClick;
    property OnDelete: TNotifyEvent read FOnDelete write FOnDelete;
  end;

  { ── TFRMaterialSegmentedButton ── }

  TFRMaterialSegmentedButton = class(TFRMaterial3Control)
  private
    FItems: TStrings;
    FItemIndex: Integer;
    FMultiSelect: Boolean;
    FSelectedItems: array of Boolean;
    FOnChange: TNotifyEvent;
    procedure SetItems(AValue: TStrings);
    procedure SetItemIndex(AValue: Integer);
    procedure SetMultiSelect(AValue: Boolean);
    procedure ItemsChanged(Sender: TObject);
    function GetSegmentWidth: Integer;
    function GetItemSelected(Index: Integer): Boolean;
    procedure SetItemSelected(Index: Integer; AValue: Boolean);
  protected
    procedure Paint; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property ItemSelected[Index: Integer]: Boolean read GetItemSelected write SetItemSelected;
  published
    property Items: TStrings read FItems write SetItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
    property MultiSelect: Boolean read FMultiSelect write SetMultiSelect default False;
    property Font;
    property Enabled;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialchip_icon.lrs}
    {$I icons\frmaterialsegmentedbutton_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialChip, TFRMaterialSegmentedButton]);
end;

{ ── TFRMaterialChip ── }

constructor TFRMaterialChip.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FChipStyle := csAssist;
  FSelected := False;
  FDeletable := False;
  FShowIcon := False;
  FIconMode := imSearch;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
  Font.Size := 9;
end;

class function TFRMaterialChip.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 100;
  Result.cy := 32;
end;

procedure TFRMaterialChip.SetChipStyle(AValue: TFRMDChipStyle);
begin
  if FChipStyle = AValue then Exit;
  FChipStyle := AValue;
  Invalidate;
end;

procedure TFRMaterialChip.SetSelected(AValue: Boolean);
begin
  if FSelected = AValue then Exit;
  FSelected := AValue;
  Invalidate;
end;

procedure TFRMaterialChip.SetDeletable(AValue: Boolean);
begin
  if FDeletable = AValue then Exit;
  FDeletable := AValue;
  Invalidate;
end;

procedure TFRMaterialChip.SetShowIcon(AValue: Boolean);
begin
  if FShowIcon = AValue then Exit;
  FShowIcon := AValue;
  Invalidate;
end;

procedure TFRMaterialChip.SetIconMode(AValue: TFRIconMode);
begin
  if FIconMode = AValue then Exit;
  FIconMode := AValue;
  Invalidate;
end;

procedure TFRMaterialChip.Click;
begin
  if FChipStyle = csFilter then
    Selected := not Selected;
  inherited;
end;

procedure TFRMaterialChip.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  { Check if clicked on delete area (rightmost 24px) }
  if FDeletable and (X >= Width - 28) and (Button = mbLeft) then
  begin
    if Assigned(FOnDelete) then
      FOnDelete(Self);
  end;
  inherited;
end;

procedure TFRMaterialChip.DoOnResize;
begin
  inherited DoOnResize;
  if not (csLoading in ComponentState) then
    Height := 32 + MD3DensityDelta(Density);
end;

procedure TFRMaterialChip.Paint;
var
  bmp, iconBmp: TBGRABitmap;
  r: Integer;
  bgColor, textColor, borderColor: TColor;
  icoSz, textX, delX: Integer;
  aRect: TRect;
begin
  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    r := Height div 4;
    if r < 4 then r := 4;

    if FSelected and (FChipStyle = csFilter) then
    begin
      bgColor := MD3Colors.SecondaryContainer;
      textColor := MD3Colors.OnSecondaryContainer;
      borderColor := clNone;
    end
    else
    begin
      bgColor := clNone;
      textColor := MD3Colors.OnSurfaceVariant;
      borderColor := MD3Colors.Outline;
    end;

    { Background }
    if bgColor <> clNone then
      MD3FillRoundRect(bmp, 0, 0, Width - 1, Height - 1, r, bgColor);

    { Border }
    if borderColor <> clNone then
      MD3RoundRect(bmp, 0.5, 0.5, Width - 1.5, Height - 1.5, r, borderColor, 1.0);

    { State layer }
    if Enabled then
      MD3StateLayer(bmp, 0, 0, Width - 1, Height - 1, r, textColor, InteractionState);

    PaintRipple(bmp, textColor);
    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { Content layout }
  Canvas.Font := Self.Font;
  Canvas.Font.Size := Height * 9 div 32;
  if Canvas.Font.Size < 7 then Canvas.Font.Size := 7;
  textX := Height div 2;
  icoSz := Height * 18 div 32;
  if icoSz < 12 then icoSz := 12;

  { Leading icon or check (for filter chips when selected) }
  if FSelected and (FChipStyle = csFilter) then
  begin
    iconBmp := FRGetCachedIcon(imSearch, FRColorToSVGHex(textColor), 2.0, icoSz, icoSz);
    iconBmp.Draw(Canvas, Height div 4, (Height - icoSz) div 2, False);
    textX := Height div 4 + icoSz + Height div 4;
  end
  else if FShowIcon then
  begin
    iconBmp := FRGetCachedIcon(FIconMode, FRColorToSVGHex(textColor), 2.0, icoSz, icoSz);
    iconBmp.Draw(Canvas, Height div 4, (Height - icoSz) div 2, False);
    textX := Height div 4 + icoSz + Height div 4;
  end;

  { Caption }
  delX := Width;
  if FDeletable then
    delX := Width - Height * 28 div 32;
  aRect := Rect(textX, 0, delX, Height);
  MD3DrawText(Canvas, Caption, aRect, textColor, taLeftJustify, True);

  { Delete icon }
  if FDeletable then
  begin
    iconBmp := FRGetCachedIcon(imClear, FRColorToSVGHex(textColor), 2.0, icoSz, icoSz);
    iconBmp.Draw(Canvas, Width - Height div 4 - icoSz, (Height - icoSz) div 2, False);
  end;
end;

{ ── TFRMaterialSegmentedButton ── }

constructor TFRMaterialSegmentedButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TStringList.Create;
  TStringList(FItems).OnChange := @ItemsChanged;
  FItemIndex := -1;
  FMultiSelect := False;
  SetLength(FSelectedItems, 0);
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
  Font.Size := 10;
end;

destructor TFRMaterialSegmentedButton.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

class function TFRMaterialSegmentedButton.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 300;
  Result.cy := 40;
end;

procedure TFRMaterialSegmentedButton.SetItems(AValue: TStrings);
begin
  FItems.Assign(AValue);
end;

procedure TFRMaterialSegmentedButton.SetItemIndex(AValue: Integer);
begin
  if FItemIndex = AValue then Exit;
  FItemIndex := AValue;
  Invalidate;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TFRMaterialSegmentedButton.SetMultiSelect(AValue: Boolean);
begin
  if FMultiSelect = AValue then Exit;
  FMultiSelect := AValue;
  Invalidate;
end;

procedure TFRMaterialSegmentedButton.ItemsChanged(Sender: TObject);
begin
  SetLength(FSelectedItems, FItems.Count);
  Invalidate;
end;

function TFRMaterialSegmentedButton.GetSegmentWidth: Integer;
begin
  if FItems.Count > 0 then
    Result := Width div FItems.Count
  else
    Result := Width;
end;

function TFRMaterialSegmentedButton.GetItemSelected(Index: Integer): Boolean;
begin
  if (Index >= 0) and (Index < Length(FSelectedItems)) then
    Result := FSelectedItems[Index]
  else
    Result := False;
end;

procedure TFRMaterialSegmentedButton.SetItemSelected(Index: Integer; AValue: Boolean);
begin
  if (Index >= 0) and (Index < Length(FSelectedItems)) then
  begin
    FSelectedItems[Index] := AValue;
    Invalidate;
  end;
end;

procedure TFRMaterialSegmentedButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  idx, sw: Integer;
begin
  if (Button = mbLeft) and (FItems.Count > 0) then
  begin
    sw := GetSegmentWidth;
    if sw <= 0 then Exit;
    idx := X div sw;
    if idx >= FItems.Count then
      idx := FItems.Count - 1;

    if FMultiSelect then
    begin
      if (idx >= 0) and (idx < Length(FSelectedItems)) then
      begin
        FSelectedItems[idx] := not FSelectedItems[idx];
        Invalidate;
        if Assigned(FOnChange) then FOnChange(Self);
      end;
    end
    else
      ItemIndex := idx;
  end;
  inherited;
end;

procedure TFRMaterialSegmentedButton.Paint;
var
  bmp: TBGRABitmap;
  i, sw, x1, x2, r: Integer;
  bgColor, textColor, borderColor: TColor;
  isSel: Boolean;
  aRect: TRect;
begin
  if FItems.Count = 0 then Exit;

  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    r := Height div 2;
    sw := GetSegmentWidth;
    borderColor := MD3Colors.Outline;

    { Full outline }
    MD3RoundRect(bmp, 0.5, 0.5, Width - 1.5, Height - 1.5, r, borderColor, 1.0);

    { Segment fills }
    for i := 0 to FItems.Count - 1 do
    begin
      x1 := i * sw;
      x2 := x1 + sw;
      if i = FItems.Count - 1 then
        x2 := Width;

      if FMultiSelect then
        isSel := GetItemSelected(i)
      else
        isSel := (i = FItemIndex);

      if isSel then
      begin
        bgColor := MD3Colors.SecondaryContainer;
        { Only round the first/last segments }
        if (i = 0) and (i = FItems.Count - 1) then
          MD3FillRoundRect(bmp, x1, 0, x2 - 1, Height - 1, r, bgColor)
        else if i = 0 then
          MD3FillRoundRect(bmp, x1, 0, x2, Height - 1, r, bgColor)
        else if i = FItems.Count - 1 then
          MD3FillRoundRect(bmp, x1, 0, x2 - 1, Height - 1, r, bgColor)
        else
          MD3FillRoundRect(bmp, x1, 0, x2, Height - 1, 0, bgColor);
      end;

      { Divider between segments }
      if i > 0 then
        bmp.DrawLineAntialias(x1, 0, x1, Height,
          ColorToBGRA(ColorToRGB(borderColor)), 1.0);
    end;

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { Text labels }
  Canvas.Font := Self.Font;
  for i := 0 to FItems.Count - 1 do
  begin
    x1 := i * sw;
    x2 := x1 + sw;
    if i = FItems.Count - 1 then
      x2 := Width;

    if FMultiSelect then
      isSel := GetItemSelected(i)
    else
      isSel := (i = FItemIndex);

    if isSel then
      textColor := MD3Colors.OnSecondaryContainer
    else
      textColor := MD3Colors.OnSurface;

    aRect := Rect(x1, 0, x2, Height);
    MD3DrawText(Canvas, FItems[i], aRect, textColor, taCenter, True);
  end;
end;

end.

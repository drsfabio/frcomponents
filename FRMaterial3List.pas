unit FRMaterial3List;

{$mode objfpc}{$H+}

{ Material Design 3 — List.

  TFRMaterialListView — Material 3 list with 1/2/3-line items,
  leading/trailing elements, selection support.

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, Forms,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialIcons, FRMaterialTheme;

type
  TFRMDListItemType = (litOneLine, litTwoLine, litThreeLine);

  TFRMaterialListItem = class(TCollectionItem)
  private
    FHeadline: string;
    FSupportText: string;
    FLeadingIcon: TFRIconMode;
    FTrailingText: string;
    FTag: PtrInt;
  published
    property Headline: string read FHeadline write FHeadline;
    property SupportText: string read FSupportText write FSupportText;
    property LeadingIcon: TFRIconMode read FLeadingIcon write FLeadingIcon;
    property TrailingText: string read FTrailingText write FTrailingText;
    property Tag: PtrInt read FTag write FTag default 0;
  end;

  TFRMaterialListItems = class(TCollection)
  private
    FOwner: TComponent;
    function GetItem(Index: Integer): TFRMaterialListItem;
    procedure SetItem(Index: Integer; AValue: TFRMaterialListItem);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TComponent);
    function Add: TFRMaterialListItem;
    property Items[Index: Integer]: TFRMaterialListItem read GetItem write SetItem; default;
  end;

  TFRMaterialListView = class(TFRMaterial3Control)
  private
    FItems: TFRMaterialListItems;
    FItemIndex: Integer;
    FItemType: TFRMDListItemType;
    FOnSelectionChange: TNotifyEvent;
    FScrollOffset: Integer;
    FShowDividers: Boolean;
    function GetItemHeight: Integer;
    procedure SetItemIndex(AValue: Integer);
    procedure SetItemType(AValue: TFRMDListItemType);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Items: TFRMaterialListItems read FItems write FItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
    property ItemType: TFRMDListItemType read FItemType write SetItemType default litOneLine;
    property ShowDividers: Boolean read FShowDividers write FShowDividers default False;
    property OnSelectionChange: TNotifyEvent read FOnSelectionChange write FOnSelectionChange;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
    property Cursor;
    property Enabled;
    property Font;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
  end;

procedure Register;

implementation

uses Math;

{ ── TFRMaterialListItems ── }

constructor TFRMaterialListItems.Create(AOwner: TComponent);
begin
  inherited Create(TFRMaterialListItem);
  FOwner := AOwner;
end;

function TFRMaterialListItems.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TFRMaterialListItems.GetItem(Index: Integer): TFRMaterialListItem;
begin
  Result := TFRMaterialListItem(inherited Items[Index]);
end;

procedure TFRMaterialListItems.SetItem(Index: Integer; AValue: TFRMaterialListItem);
begin
  inherited Items[Index] := AValue;
end;

function TFRMaterialListItems.Add: TFRMaterialListItem;
begin
  Result := TFRMaterialListItem(inherited Add);
end;

{ ── TFRMaterialListView ── }

constructor TFRMaterialListView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TFRMaterialListItems.Create(Self);
  FItemIndex := -1;
  FItemType := litOneLine;
  FScrollOffset := 0;
  FShowDividers := False;
  Width := 280;
  Height := 300;
end;

destructor TFRMaterialListView.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TFRMaterialListView.GetItemHeight: Integer;
begin
  case FItemType of
    litOneLine: Result := 56 + MD3DensityDelta(Density);
    litTwoLine: Result := 72 + MD3DensityDelta(Density);
    litThreeLine: Result := 88 + MD3DensityDelta(Density);
  else
    Result := 56 + MD3DensityDelta(Density);
  end;
end;

procedure TFRMaterialListView.SetItemIndex(AValue: Integer);
begin
  if AValue < -1 then AValue := -1;
  if AValue >= FItems.Count then AValue := FItems.Count - 1;
  if FItemIndex <> AValue then
  begin
    FItemIndex := AValue;
    Invalidate;
    if Assigned(FOnSelectionChange) then
      FOnSelectionChange(Self);
  end;
end;

procedure TFRMaterialListView.SetItemType(AValue: TFRMDListItemType);
begin
  if FItemType <> AValue then
  begin
    FItemType := AValue;
    Invalidate;
  end;
end;

procedure TFRMaterialListView.Paint;
var
  bmp: TBGRABitmap;
  i, yPos, ih: Integer;
  item: TFRMaterialListItem;
  aRect: TRect;
  iconBmp: TBGRABitmap;
  svg: string;
  textLeft: Integer;
  icoSz, padX, trailW: Integer;
begin
  if (Width <= 0) or (Height <= 0) then Exit;
  bmp := TBGRABitmap.Create(Width, Height, ColorToBGRA(MD3Colors.Surface));
  try
    ih := GetItemHeight;
    { proportional metrics }
    icoSz := ih * 24 div 56;
    if icoSz < 16 then icoSz := 16;
    padX := Width * 16 div 360;
    if padX < 4 then padX := 4;
    trailW := Width * 60 div 360;

    for i := 0 to FItems.Count - 1 do
    begin
      yPos := i * ih - FScrollOffset;
      if (yPos + ih < 0) or (yPos > Height) then Continue;

      item := FItems[i];

      { selection highlight }
      if i = FItemIndex then
        bmp.FillRect(0, yPos, Width, yPos + ih,
          ColorToBGRA(MD3Colors.SecondaryContainer), dmDrawWithTransparency);

      { leading icon }
      if item.FLeadingIcon <> imClear then
      begin
        iconBmp := FRGetCachedIcon(item.FLeadingIcon, FRColorToSVGHex(MD3Colors.OnSurfaceVariant), 2.0, icoSz, icoSz);
        if iconBmp <> nil then
          bmp.PutImage(padX, yPos + (ih - icoSz) div 2, iconBmp, dmDrawWithTransparency);
      end;

      { divider }
      if FShowDividers and (i < FItems.Count - 1) then
        bmp.DrawLineAntialias(padX, yPos + ih - 1, Width - 1, yPos + ih - 1,
          ColorToBGRA(MD3Colors.OutlineVariant), 1);
    end;

    PaintRipple(bmp, MD3Colors.OnSurface);
    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { text labels — second pass on Canvas after bmp.Draw }
  ih := GetItemHeight;
  icoSz := ih * 24 div 56;
  if icoSz < 16 then icoSz := 16;
  padX := Width * 16 div 360;
  if padX < 4 then padX := 4;
  trailW := Width * 60 div 360;

  for i := 0 to FItems.Count - 1 do
  begin
    yPos := i * ih - FScrollOffset;
    if (yPos + ih < 0) or (yPos > Height) then Continue;

    item := FItems[i];

    if item.FLeadingIcon <> imClear then
      textLeft := padX + icoSz + padX
    else
      textLeft := padX;

    { headline }
    aRect := Rect(textLeft, yPos + ih * 8 div 56, Width - trailW, yPos + ih * 28 div 56);
    MD3DrawText(Canvas, item.FHeadline, aRect, MD3Colors.OnSurface, taLeftJustify, True);

    { support text }
    if (FItemType >= litTwoLine) and (item.FSupportText <> '') then
    begin
      aRect := Rect(textLeft, yPos + ih * 28 div 56, Width - trailW, yPos + ih - ih * 8 div 56);
      Canvas.Font.Size := ih * 8 div 56;
      if Canvas.Font.Size < 7 then Canvas.Font.Size := 7;
      MD3DrawText(Canvas, item.FSupportText, aRect, MD3Colors.OnSurfaceVariant, taLeftJustify, True);
      Canvas.Font.Size := 10;
    end;

    { trailing text }
    if item.FTrailingText <> '' then
    begin
      aRect := Rect(Width - trailW, yPos + ih * 8 div 56, Width - padX, yPos + ih * 28 div 56);
      Canvas.Font.Size := ih * 8 div 56;
      if Canvas.Font.Size < 7 then Canvas.Font.Size := 7;
      MD3DrawText(Canvas, item.FTrailingText, aRect, MD3Colors.OnSurfaceVariant, taRightJustify, True);
      Canvas.Font.Size := 10;
    end;
  end;
end;

procedure TFRMaterialListView.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  idx: Integer;
begin
  inherited;
  if Button = mbLeft then
  begin
    idx := (Y + FScrollOffset) div GetItemHeight;
    if (idx >= 0) and (idx < FItems.Count) then
      SetItemIndex(idx);
  end;
end;

function TFRMaterialListView.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
var
  maxScroll: Integer;
begin
  Result := inherited;
  maxScroll := Max(0, FItems.Count * GetItemHeight - Height);
  FScrollOffset := Max(0, Min(FScrollOffset - (WheelDelta div 3), maxScroll));
  Invalidate;
  Result := True;
end;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmateriallistview_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialListView]);
end;

end.

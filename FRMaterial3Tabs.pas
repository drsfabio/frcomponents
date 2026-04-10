unit FRMaterial3Tabs;

{$mode objfpc}{$H+}

{ Material Design 3 — Tabs.

  TFRMaterialTabs — Primary / secondary tab bar with indicator.

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialIcons, FRMaterialTheme;

type
  TFRMDTabStyle = (tsFixed, tsScrollable);
  TFRMDTabAlignment = (taSpread, taLeading);

  TFRMaterialTabItem = class(TCollectionItem)
  private
    FCaption: string;
    FIconMode: TFRIconMode;
    FBadge: string;
  published
    property Caption: string read FCaption write FCaption;
    property IconMode: TFRIconMode read FIconMode write FIconMode;
    property Badge: string read FBadge write FBadge;
  end;

  TFRMaterialTabItems = class(TCollection)
  private
    FOwner: TComponent;
    function GetItem(Index: Integer): TFRMaterialTabItem;
    procedure SetItem(Index: Integer; AValue: TFRMaterialTabItem);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TComponent);
    function Add: TFRMaterialTabItem;
    property Items[Index: Integer]: TFRMaterialTabItem read GetItem write SetItem; default;
  end;

  TFRMaterialTabs = class(TFRMaterial3Control)
  private
    FTabs: TFRMaterialTabItems;
    FTabIndex: Integer;
    FTabStyle: TFRMDTabStyle;
    FTabAlignment: TFRMDTabAlignment;
    FBackgroundImage: TPicture;
    FOnChange: TNotifyEvent;
    procedure SetTabIndex(AValue: Integer);
    procedure SetTabAlignment(AValue: TFRMDTabAlignment);
    function GetTabWidth: Integer;
    function MeasureTabWidth(AIndex: Integer): Integer;
    function GetTabLeft(AIndex: Integer): Integer;
    procedure BackgroundImageChanged(Sender: TObject);
  protected
    function PaintCached(ABmp: TBGRABitmap): Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DoOnResize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Tabs: TFRMaterialTabItems read FTabs write FTabs;
    property TabIndex: Integer read FTabIndex write SetTabIndex default 0;
    property TabStyle: TFRMDTabStyle read FTabStyle write FTabStyle default tsFixed;
    property TabAlignment: TFRMDTabAlignment read FTabAlignment write SetTabAlignment default taSpread;
    property BackgroundImage: TPicture read FBackgroundImage write FBackgroundImage;
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
    property Visible;
  end;

procedure Register;

implementation

{ ── TFRMaterialTabItems ── }

constructor TFRMaterialTabItems.Create(AOwner: TComponent);
begin
  inherited Create(TFRMaterialTabItem);
  FOwner := AOwner;
end;

function TFRMaterialTabItems.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TFRMaterialTabItems.GetItem(Index: Integer): TFRMaterialTabItem;
begin
  Result := TFRMaterialTabItem(inherited Items[Index]);
end;

procedure TFRMaterialTabItems.SetItem(Index: Integer; AValue: TFRMaterialTabItem);
begin
  inherited Items[Index] := AValue;
end;

function TFRMaterialTabItems.Add: TFRMaterialTabItem;
begin
  Result := TFRMaterialTabItem(inherited Add);
end;

{ ── TFRMaterialTabs ── }

constructor TFRMaterialTabs.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTabs := TFRMaterialTabItems.Create(Self);
  FTabIndex := 0;
  FTabStyle := tsFixed;
  FTabAlignment := taSpread;
  FBackgroundImage := TPicture.Create;
  FBackgroundImage.OnChange := @BackgroundImageChanged;
  Width := 400;
  Height := 48;
end;

destructor TFRMaterialTabs.Destroy;
begin
  FBackgroundImage.Free;
  FTabs.Free;
  inherited Destroy;
end;

function TFRMaterialTabs.GetTabWidth: Integer;
begin
  if (FTabStyle = tsFixed) and (FTabs.Count > 0) then
    Result := Width div FTabs.Count
  else
    Result := 90;
end;

function TFRMaterialTabs.MeasureTabWidth(AIndex: Integer): Integer;
const
  PAD = 32; { 16px padding each side }
var
  iconW: Integer;
begin
  Canvas.Font.Assign(Font);
  Canvas.Font.Size := 10;
  Result := Canvas.TextWidth(FTabs[AIndex].FCaption) + PAD;
  if FTabs[AIndex].FIconMode <> imClear then
  begin
    iconW := 20 + 6; { icon + gap }
    Result := Result + iconW;
  end;
  if Result < 72 then Result := 72; { MD3 min tab width }
end;

function TFRMaterialTabs.GetTabLeft(AIndex: Integer): Integer;
var
  j: Integer;
begin
  if FTabAlignment = taSpread then
  begin
    Result := AIndex * GetTabWidth;
  end
  else
  begin
    Result := 0;
    for j := 0 to AIndex - 1 do
      Result := Result + MeasureTabWidth(j);
  end;
end;

procedure TFRMaterialTabs.SetTabAlignment(AValue: TFRMDTabAlignment);
begin
  if FTabAlignment <> AValue then
  begin
    FTabAlignment := AValue;
    Invalidate;
  end;
end;

procedure TFRMaterialTabs.SetTabIndex(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if (FTabs.Count > 0) and (AValue >= FTabs.Count) then
    AValue := FTabs.Count - 1;
  if FTabIndex <> AValue then
  begin
    FTabIndex := AValue;
    Invalidate;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

function TFRMaterialTabs.PaintCached(ABmp: TBGRABitmap): Boolean;
var
  i, tw, xPos: Integer;
  tab: TFRMaterialTabItem;
  aRect: TRect;
  textColor: TColor;
  iconBmp: TBGRABitmap;
  textY: Integer;
  clipText: string;
  icoSz, indH: Integer;
begin
  Result := True;
  { Proportional metrics based on Height (reference = 48) }
  icoSz := Height * 20 div 48;
  if icoSz < 12 then icoSz := 12;
  if icoSz > 28 then icoSz := 28;
  indH := Height * 3 div 48;
  if indH < 2 then indH := 2;

  ABmp.Fill(ColorToBGRA(MD3Colors.Surface));
  { Background image }
  if Assigned(FBackgroundImage.Graphic) and (not FBackgroundImage.Graphic.Empty) then
  begin
    ABmp.Canvas.StretchDraw(Rect(0, 0, Width, Height), FBackgroundImage.Graphic);
  end;

  { bottom line }
  ABmp.DrawLineAntialias(0, Height - 1, Width, Height - 1,
    ColorToBGRA(MD3Colors.SurfaceContainerHighest), 1);

  for i := 0 to FTabs.Count - 1 do
  begin
    tab := FTabs[i];
    xPos := GetTabLeft(i);
    if FTabAlignment = taLeading then
      tw := MeasureTabWidth(i)
    else
      tw := GetTabWidth;

    if i = FTabIndex then
    begin
      { indicator }
      ABmp.FillRect(xPos + tw div 4, Height - indH, xPos + tw - tw div 4, Height,
        ColorToBGRA(MD3Colors.Primary), dmDrawWithTransparency);
    end;

    { icon }
    if tab.FIconMode <> imClear then
    begin
      if i = FTabIndex then
        textColor := MD3Colors.Primary
      else
        textColor := MD3Colors.OnSurfaceVariant;
      iconBmp := FRGetCachedIcon(tab.FIconMode, FRColorToSVGHex(textColor), 2.0, icoSz, icoSz);
      ABmp.PutImage(xPos + (tw - icoSz) div 2, Height * 8 div 48, iconBmp, dmDrawWithTransparency);
    end;
  end;

  { text labels — second pass on Canvas after bitmap done }
  for i := 0 to FTabs.Count - 1 do
  begin
    tab := FTabs[i];
    xPos := GetTabLeft(i);
    if FTabAlignment = taLeading then
      tw := MeasureTabWidth(i)
    else
      tw := GetTabWidth;

    if i = FTabIndex then
      textColor := MD3Colors.Primary
    else
      textColor := MD3Colors.OnSurfaceVariant;

    if tab.FIconMode <> imClear then
      textY := Height * 30 div 48
    else
      textY := 0;

    aRect := Rect(xPos + 4, textY, xPos + tw - 4, Height - 4);

    { Clipping: truncar texto com ellipsis se não couber }
    ABmp.FontHeight := Abs((Height * 10 div 48) * 96 div 72);
    if ABmp.FontHeight < 7 then ABmp.FontHeight := 7;
    clipText := tab.FCaption;
    if ABmp.TextSize(clipText).cx > (aRect.Right - aRect.Left) then
    begin
      while (Length(clipText) > 1) and (ABmp.TextSize(clipText + '...').cx > (aRect.Right - aRect.Left)) do
        Delete(clipText, Length(clipText), 1);
      clipText := clipText + '...';
    end;

    MD3DrawTextBGRA(ABmp, clipText, aRect, textColor, taCenter, True);
  end;
end;

procedure TFRMaterialTabs.BackgroundImageChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TFRMaterialTabs.DoOnResize;
begin
  inherited DoOnResize;
  if not (csLoading in ComponentState) then
    Height := 48 + MD3DensityDelta(Density);
end;

procedure TFRMaterialTabs.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  tw, idx, accX: Integer;
begin
  inherited;
  if Button = mbLeft then
  begin
    if FTabAlignment = taLeading then
    begin
      { hit test por acumulação de larguras }
      accX := 0;
      for idx := 0 to FTabs.Count - 1 do
      begin
        tw := MeasureTabWidth(idx);
        if (X >= accX) and (X < accX + tw) then
        begin
          SetTabIndex(idx);
          Break;
        end;
        accX := accX + tw;
      end;
    end
    else
    begin
      tw := GetTabWidth;
      if tw > 0 then
      begin
        idx := X div tw;
        if (idx >= 0) and (idx < FTabs.Count) then
          SetTabIndex(idx);
      end;
    end;
  end;
end;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialtabs_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialTabs]);
end;

end.

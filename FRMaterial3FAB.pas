unit FRMaterial3FAB;

{$mode objfpc}{$H+}

{ Material Design 3 — Floating Action Buttons.

  TFRMaterialFAB         — Standard FAB (Small 40dp, Regular 56dp, Large 96dp)
  TFRMaterialExtendedFAB — Extended FAB with text label
  TFRMaterialFABMenu     — Speed-dial FAB that expands to show action items

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialIcons, FRMaterialTheme;

type
  TFRMDFABSize = (fsSmall, fsRegular, fsLarge);

  { ── TFRMaterialFAB ── }

  TFRMaterialFAB = class(TFRMaterial3Control)
  private
    FFABSize: TFRMDFABSize;
    FIconMode: TFRIconMode;
    procedure SetFABSize(AValue: TFRMDFABSize);
    procedure SetIconMode(AValue: TFRIconMode);
    function GetFABDimension: Integer;
    function GetIconSize: Integer;
    function GetRadius: Integer;
  protected
    procedure Paint; override;
    procedure DoOnResize; override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property FABSize: TFRMDFABSize read FFABSize write SetFABSize default fsRegular;
    property IconMode: TFRIconMode read FIconMode write SetIconMode default imPlus;
    property Anchors;
    property Enabled;
    property Visible;
    property OnClick;
  end;

  { ── TFRMaterialExtendedFAB ── }

  TFRMaterialExtendedFAB = class(TFRMaterial3Control)
  private
    FIconMode: TFRIconMode;
    FShowIcon: Boolean;
    procedure SetIconMode(AValue: TFRIconMode);
    procedure SetShowIcon(AValue: Boolean);
  protected
    procedure Paint; override;
    procedure DoOnResize; override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property IconMode: TFRIconMode read FIconMode write SetIconMode default imPlus;
    property ShowIcon: Boolean read FShowIcon write SetShowIcon default True;
    property Anchors;
    property Caption;
    property Font;
    property Enabled;
    property Visible;
    property OnClick;
  end;

  { ── TFRMaterialFABMenuItem ── }

  TFRMaterialFABMenuItem = class(TCollectionItem)
  private
    FCaption: string;
    FIconMode: TFRIconMode;
    FOnClick: TNotifyEvent;
  published
    property Caption: string read FCaption write FCaption;
    property IconMode: TFRIconMode read FIconMode write FIconMode default imSearch;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

  { ── TFRMaterialFABMenuItems ── }

  TFRMaterialFABMenuItems = class(TCollection)
  private
    FOwner: TComponent;
    function GetItem(Index: Integer): TFRMaterialFABMenuItem;
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TComponent);
    function Add: TFRMaterialFABMenuItem;
    property Items[Index: Integer]: TFRMaterialFABMenuItem read GetItem; default;
  end;

  { ── TFRMaterialFABMenu ── }

  TFRMaterialFABMenu = class(TFRMaterial3Control)
  private
    FIconMode: TFRIconMode;
    FExpanded: Boolean;
    FItems: TFRMaterialFABMenuItems;
    FOnExpand: TNotifyEvent;
    FOnCollapse: TNotifyEvent;
    procedure SetIconMode(AValue: TFRIconMode);
    procedure SetExpanded(AValue: Boolean);
    procedure SetItems(AValue: TFRMaterialFABMenuItems);
  protected
    procedure Paint; override;
    procedure Click; override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property IconMode: TFRIconMode read FIconMode write SetIconMode default imPlus;
    property Expanded: Boolean read FExpanded write SetExpanded default False;
    property Items: TFRMaterialFABMenuItems read FItems write SetItems;
    property Anchors;
    property Visible;
    property OnClick;
    property OnExpand: TNotifyEvent read FOnExpand write FOnExpand;
    property OnCollapse: TNotifyEvent read FOnCollapse write FOnCollapse;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialfab_icon.lrs}
    {$I icons\frmaterialextendedfab_icon.lrs}
    {$I icons\frmaterialfabmenu_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialFAB, TFRMaterialExtendedFAB, TFRMaterialFABMenu]);
end;

{ ── TFRMaterialFAB ── }

constructor TFRMaterialFAB.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFABSize := fsRegular;
  FIconMode := imPlus;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
end;

class function TFRMaterialFAB.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 56;
  Result.cy := 56;
end;

procedure TFRMaterialFAB.SetFABSize(AValue: TFRMDFABSize);
begin
  if FFABSize = AValue then Exit;
  FFABSize := AValue;
  SetBounds(Left, Top, GetFABDimension, GetFABDimension);
  Invalidate;
end;

procedure TFRMaterialFAB.SetIconMode(AValue: TFRIconMode);
begin
  if FIconMode = AValue then Exit;
  FIconMode := AValue;
  Invalidate;
end;

function TFRMaterialFAB.GetFABDimension: Integer;
begin
  case FFABSize of
    fsSmall:   Result := 40;
    fsRegular: Result := 56;
    fsLarge:   Result := 96;
  else
    Result := 56;
  end;
end;

function TFRMaterialFAB.GetIconSize: Integer;
begin
  case FFABSize of
    fsSmall:   Result := 24;
    fsRegular: Result := 24;
    fsLarge:   Result := 36;
  else
    Result := 24;
  end;
end;

function TFRMaterialFAB.GetRadius: Integer;
begin
  { Proportional: roughly 28% of dimension }
  Result := GetFABDimension * 28 div 100;
end;

procedure TFRMaterialFAB.Paint;
var
  bmp, iconBmp: TBGRABitmap;
  r, icoSz: Integer;
  bgColor, icoColor: TColor;
begin
  if (Width <= 0) or (Height <= 0) then Exit;
  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    r := GetRadius;
    bgColor := MD3Colors.PrimaryContainer;
    icoColor := MD3Colors.OnPrimaryContainer;

    { Shadow }
    MD3DrawShadow(bmp, 0, 0, Width - 1, Height - 1, r, elLevel2);

    { Background }
    MD3FillRoundRect(bmp, 0, 0, Width - 1, Height - 1, r, bgColor);

    { State layer }
    if Enabled then
      MD3StateLayer(bmp, 0, 0, Width - 1, Height - 1, r, icoColor, InteractionState);

    PaintRipple(bmp, icoColor);
    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { Icon }
  icoSz := GetIconSize;
  iconBmp := FRGetCachedIcon(FIconMode, FRColorToSVGHex(icoColor), 2.5, icoSz, icoSz);
  iconBmp.Draw(Canvas, (Width - icoSz) div 2, (Height - icoSz) div 2, False);
end;

procedure TFRMaterialFAB.DoOnResize;
begin
  inherited DoOnResize;
  if not (csLoading in ComponentState) then
  begin
    Width := GetFABDimension + MD3DensityDelta(Density);
    Height := GetFABDimension + MD3DensityDelta(Density);
  end;
end;

{ ── TFRMaterialExtendedFAB ── }

constructor TFRMaterialExtendedFAB.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIconMode := imPlus;
  FShowIcon := True;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
  Font.Size := 10;
  Font.Style := [fsBold];
end;

class function TFRMaterialExtendedFAB.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 160;
  Result.cy := 56;
end;

procedure TFRMaterialExtendedFAB.SetIconMode(AValue: TFRIconMode);
begin
  if FIconMode = AValue then Exit;
  FIconMode := AValue;
  Invalidate;
end;

procedure TFRMaterialExtendedFAB.SetShowIcon(AValue: Boolean);
begin
  if FShowIcon = AValue then Exit;
  FShowIcon := AValue;
  Invalidate;
end;

procedure TFRMaterialExtendedFAB.DoOnResize;
begin
  inherited DoOnResize;
  if not (csLoading in ComponentState) then
    Height := 56 + MD3DensityDelta(Density);
end;

procedure TFRMaterialExtendedFAB.Paint;
var
  bmp, iconBmp: TBGRABitmap;
  r, icoSz, textX, totalW, tw: Integer;
  bgColor, contentColor: TColor;
  aRect: TRect;
begin
  if (Width <= 0) or (Height <= 0) then Exit;
  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    r := Height * 16 div 56;
    if r < 8 then r := 8;
    bgColor := MD3Colors.PrimaryContainer;
    contentColor := MD3Colors.OnPrimaryContainer;

    { Shadow }
    MD3DrawShadow(bmp, 0, 0, Width - 1, Height - 1, r, elLevel2);

    { Background }
    MD3FillRoundRect(bmp, 0, 0, Width - 1, Height - 1, r, bgColor);

    { State layer }
    if Enabled then
      MD3StateLayer(bmp, 0, 0, Width - 1, Height - 1, r, contentColor, InteractionState);

    PaintRipple(bmp, contentColor);
    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { Icon + Text layout }
  Canvas.Font := Self.Font;
  Canvas.Font.Size := Height * 10 div 56;
  if Canvas.Font.Size < 8 then Canvas.Font.Size := 8;
  tw := Canvas.TextWidth(Caption);
  icoSz := Height * 24 div 56;
  if icoSz < 16 then icoSz := 16;

  if FShowIcon then
  begin
    totalW := icoSz + 12 + tw;
    textX := (Width - totalW) div 2;

    iconBmp := FRGetCachedIcon(FIconMode, FRColorToSVGHex(contentColor), 2.5, icoSz, icoSz);
    iconBmp.Draw(Canvas, textX, (Height - icoSz) div 2, False);

    aRect := Rect(textX + icoSz + 12, 0, Width, Height);
    MD3DrawText(Canvas, Caption, aRect, contentColor, taLeftJustify, True);
  end
  else
  begin
    aRect := Rect(0, 0, Width, Height);
    MD3DrawText(Canvas, Caption, aRect, contentColor, taCenter, True);
  end;
end;

{ ── TFRMaterialFABMenuItems ── }

constructor TFRMaterialFABMenuItems.Create(AOwner: TComponent);
begin
  inherited Create(TFRMaterialFABMenuItem);
  FOwner := AOwner;
end;

function TFRMaterialFABMenuItems.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TFRMaterialFABMenuItems.Add: TFRMaterialFABMenuItem;
begin
  Result := TFRMaterialFABMenuItem(inherited Add);
end;

function TFRMaterialFABMenuItems.GetItem(Index: Integer): TFRMaterialFABMenuItem;
begin
  Result := TFRMaterialFABMenuItem(inherited Items[Index]);
end;

{ ── TFRMaterialFABMenu ── }

constructor TFRMaterialFABMenu.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIconMode := imPlus;
  FExpanded := False;
  FItems := TFRMaterialFABMenuItems.Create(Self);
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
end;

destructor TFRMaterialFABMenu.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

class function TFRMaterialFABMenu.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 56;
  Result.cy := 56;
end;

procedure TFRMaterialFABMenu.SetIconMode(AValue: TFRIconMode);
begin
  if FIconMode = AValue then Exit;
  FIconMode := AValue;
  Invalidate;
end;

procedure TFRMaterialFABMenu.SetExpanded(AValue: Boolean);
begin
  if FExpanded = AValue then Exit;
  FExpanded := AValue;
  if FExpanded then
  begin
    { Resize to show items above the FAB }
    Height := 56 + FItems.Count * 52;
    if Assigned(FOnExpand) then FOnExpand(Self);
  end
  else
  begin
    Height := 56;
    if Assigned(FOnCollapse) then FOnCollapse(Self);
  end;
  Invalidate;
end;

procedure TFRMaterialFABMenu.SetItems(AValue: TFRMaterialFABMenuItems);
begin
  FItems.Assign(AValue);
end;

procedure TFRMaterialFABMenu.Click;
begin
  Expanded := not Expanded;
  inherited;
end;

procedure TFRMaterialFABMenu.Paint;
var
  bmp, iconBmp: TBGRABitmap;
  r, i, yOff, icoSz: Integer;
  bgColor, contentColor, itemBg, itemContent: TColor;
  fabY: Integer;
  aRect: TRect;
begin
  if (Width <= 0) or (Height <= 0) then Exit;
  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    r := 16;
    bgColor := MD3Colors.PrimaryContainer;
    contentColor := MD3Colors.OnPrimaryContainer;
    itemBg := MD3Colors.SurfaceContainerHigh;
    itemContent := MD3Colors.OnSurface;
    icoSz := 24;

    { Draw expanded items above main FAB }
    if FExpanded then
    begin
      for i := 0 to FItems.Count - 1 do
      begin
        yOff := i * 52;
        MD3FillRoundRect(bmp, 4, yOff + 2, 52, yOff + 46, 12, itemBg);
      end;
    end;

    { Main FAB at bottom }
    fabY := Height - 56;
    MD3DrawShadow(bmp, 0, fabY, 55, fabY + 55, r, elLevel2);
    MD3FillRoundRect(bmp, 0, fabY, 55, fabY + 55, r, bgColor);

    if Enabled then
      MD3StateLayer(bmp, 0, fabY, 55, fabY + 55, r, contentColor, InteractionState);

    PaintRipple(bmp, contentColor);

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { Main FAB icon }
  fabY := Height - 56;
  iconBmp := FRGetCachedIcon(FIconMode, FRColorToSVGHex(contentColor), 2.5, icoSz, icoSz);
  iconBmp.Draw(Canvas, (56 - icoSz) div 2, fabY + (56 - icoSz) div 2, False);

  { Item icons and labels }
  if FExpanded then
  begin
    for i := 0 to FItems.Count - 1 do
    begin
      yOff := i * 52;
      iconBmp := FRGetCachedIcon(FItems[i].IconMode, FRColorToSVGHex(itemContent), 2.0, icoSz, icoSz);
      iconBmp.Draw(Canvas, (56 - icoSz) div 2, yOff + (48 - icoSz) div 2, False);
      if FItems[i].Caption <> '' then
      begin
        aRect := Rect(60, yOff, Width, yOff + 48);
        MD3DrawText(Canvas, FItems[i].Caption, aRect, itemContent, taLeftJustify, True);
      end;
    end;
  end;
end;

end.

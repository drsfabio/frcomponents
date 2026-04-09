unit FRMaterial3Nav;

{$mode objfpc}{$H+}

{ Material Design 3 — Navigation components.

  TFRMaterialNavBar     — Bottom navigation bar (80dp, 3-5 items).
  TFRMaterialNavDrawer  — Side navigation drawer (360dp).
  TFRMaterialNavRail    — Vertical navigation rail (80dp width).

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialIcons,
  FRMaterial3PageControl, FRMaterialTheme;

type
  TFRMaterialNavItem = class(TCollectionItem)
  private
    FCaption: string;
    FIconMode: TFRIconMode;
    FBadge: string;
  published
    property Caption: string read FCaption write FCaption;
    property IconMode: TFRIconMode read FIconMode write FIconMode;
    property Badge: string read FBadge write FBadge;
  end;

  TFRMaterialNavItems = class(TCollection)
  private
    FOwner: TComponent;
    function GetItem(Index: Integer): TFRMaterialNavItem;
    procedure SetItem(Index: Integer; AValue: TFRMaterialNavItem);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TComponent);
    function Add: TFRMaterialNavItem;
    procedure Update(AItem: TCollectionItem); override;
    property Items[Index: Integer]: TFRMaterialNavItem read GetItem write SetItem; default;
  end;

  { ── Bottom Navigation Bar ── }
  TFRMaterialNavBar = class(TFRMaterial3Control)
  private
    FItems: TFRMaterialNavItems;
    FItemIndex: Integer;
    FPageControl: TFRMaterialPageControl;
    FOnChange: TNotifyEvent;
    procedure SetItemIndex(AValue: Integer);
    procedure SetItems(AValue: TFRMaterialNavItems);
    procedure SetPageControl(AValue: TFRMaterialPageControl);
  protected
    procedure Paint; override;
    procedure DoOnResize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Items: TFRMaterialNavItems read FItems write SetItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default 0;
    property PageControl: TFRMaterialPageControl read FPageControl write SetPageControl;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
    property Cursor;
    property Enabled;
    property Font;
    property PopupMenu;
    property ShowHint;
    property Visible;
  end;

  { ── Navigation Drawer ── }
  TFRMaterialNavDrawer = class(TFRMaterial3Control)
  private
    FItems: TFRMaterialNavItems;
    FItemIndex: Integer;
    FHeaderTitle: string;
    FPageControl: TFRMaterialPageControl;
    FOnChange: TNotifyEvent;
    procedure SetItemIndex(AValue: Integer);
    procedure SetItems(AValue: TFRMaterialNavItems);
    procedure SetPageControl(AValue: TFRMaterialPageControl);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Items: TFRMaterialNavItems read FItems write SetItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default 0;
    property HeaderTitle: string read FHeaderTitle write FHeaderTitle;
    property PageControl: TFRMaterialPageControl read FPageControl write SetPageControl;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
    property Cursor;
    property Enabled;
    property Font;
    property PopupMenu;
    property ShowHint;
    property Visible;
  end;

  { ── Navigation Rail ── }
  TFRMaterialNavRail = class(TFRMaterial3Control)
  private
    FItems: TFRMaterialNavItems;
    FItemIndex: Integer;
    FPageControl: TFRMaterialPageControl;
    FOnChange: TNotifyEvent;
    FMenuIcon: TFRIconMode;
    FFabIcon: TFRIconMode;
    FOnMenuClick: TNotifyEvent;
    FOnFabClick: TNotifyEvent;
    procedure SetItemIndex(AValue: Integer);
    procedure SetItems(AValue: TFRMaterialNavItems);
    procedure SetPageControl(AValue: TFRMaterialPageControl);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Items: TFRMaterialNavItems read FItems write SetItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default 0;
    property MenuIcon: TFRIconMode read FMenuIcon write FMenuIcon;
    property FabIcon: TFRIconMode read FFabIcon write FFabIcon;
    property PageControl: TFRMaterialPageControl read FPageControl write SetPageControl;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnMenuClick: TNotifyEvent read FOnMenuClick write FOnMenuClick;
    property OnFabClick: TNotifyEvent read FOnFabClick write FOnFabClick;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
    property Cursor;
    property Enabled;
    property Font;
    property PopupMenu;
    property ShowHint;
    property Visible;
  end;

procedure Register;

implementation

{ ── TFRMaterialNavItems ── }

constructor TFRMaterialNavItems.Create(AOwner: TComponent);
begin
  inherited Create(TFRMaterialNavItem);
  FOwner := AOwner;
end;

function TFRMaterialNavItems.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TFRMaterialNavItems.GetItem(Index: Integer): TFRMaterialNavItem;
begin
  Result := TFRMaterialNavItem(inherited Items[Index]);
end;

procedure TFRMaterialNavItems.SetItem(Index: Integer; AValue: TFRMaterialNavItem);
begin
  inherited Items[Index] := AValue;
end;

function TFRMaterialNavItems.Add: TFRMaterialNavItem;
begin
  Result := TFRMaterialNavItem(inherited Add);
end;

procedure TFRMaterialNavItems.Update(AItem: TCollectionItem);
begin
  inherited Update(AItem);
  { Notifica o componente pai para redesenhar quando itens mudam em design-time }
  if FOwner is TControl then
    TControl(FOwner).Invalidate;
end;

{ ══════════════════════════════════════════════════════════════
  TFRMaterialNavBar — bottom 80dp bar
  ══════════════════════════════════════════════════════════════ }

{ Desenha um badge MD3 sobre um bitmap.
  AX, AY = canto superior esquerdo do ícone (24x24).
  ABadge  = texto do badge ('' = não exibe; '' sem número = ponto).
  Regras MD3:
    - Texto vazio  → ponto vermelho 6x6 no canto superior direito
    - Texto curto  → pílula vermelha com número centralizado
    - Texto > 3 digs → '999+' truncado }
procedure DrawMD3Badge(ABmp: TBGRABitmap; ACanvas: TCanvas;
  AX, AY: Integer; const ABadge: string);
var
  BadgeText: string;
  tw, bw, bh, bx, by: Integer;
  bc: TBGRAPixel;
begin
  if ABadge = '' then Exit;

  { Cor do badge = MD3 Error }
  bc := ColorToBGRA(ColorToRGB(MD3Colors.Error));

  if ABadge = ' ' then
  begin
    { Dot badge — 6x6 }
    ABmp.FillEllipseAntialias(AX + 20, AY + 2, 4, 4, bc);
    Exit;
  end;

  { Limita a 3 dígitos + '+' }
  if Length(ABadge) > 3 then
    BadgeText := '999+'
  else
    BadgeText := ABadge;

  { Mede o texto no canvas para calcular a pílula }
  ACanvas.Font.Size := 7;
  tw := ACanvas.TextWidth(BadgeText);
  bw := tw + 8;   { padding horizontal }
  if bw < 16 then bw := 16;
  bh := 16;
  bx := AX + 18 - bw div 2;     { centraliza sobre o canto direito do ícone }
  by := AY - 4;

  { Pílula }
  ABmp.FillRoundRectAntialias(bx, by, bx + bw, by + bh, 7.9, 7.9, bc);

  { Texto branco centralizado — desenhado depois no Canvas }
  ACanvas.Font.Size   := 7;
  ACanvas.Font.Color  := ColorToRGB(MD3Colors.OnError);
  ACanvas.Brush.Style := bsClear;
  ACanvas.TextOut(bx + (bw - tw) div 2, by + 1, BadgeText);
  ACanvas.Brush.Style := bsSolid;
end;

constructor TFRMaterialNavBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TFRMaterialNavItems.Create(Self);
  FItemIndex := 0;
  Width := 400;
  Height := 80;
  Align := alBottom;
end;

destructor TFRMaterialNavBar.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TFRMaterialNavBar.SetItemIndex(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if (FItems.Count > 0) and (AValue >= FItems.Count) then
    AValue := FItems.Count - 1;
  if FItemIndex <> AValue then
  begin
    FItemIndex := AValue;
    Invalidate;
    if Assigned(FPageControl) then
      FPageControl.ActivePageIndex := FItemIndex;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TFRMaterialNavBar.SetItems(AValue: TFRMaterialNavItems);
begin
  FItems.Assign(AValue);
end;

procedure TFRMaterialNavBar.SetPageControl(AValue: TFRMaterialPageControl);
begin
  if FPageControl <> AValue then
  begin
    if Assigned(FPageControl) then
      FPageControl.RemoveFreeNotification(Self);
    FPageControl := AValue;
    if Assigned(FPageControl) then
      FPageControl.FreeNotification(Self);
  end;
end;

procedure TFRMaterialNavBar.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FPageControl) then
    FPageControl := nil;
end;

procedure TFRMaterialNavBar.DoOnResize;
begin
  inherited DoOnResize;
  if not (csLoading in ComponentState) then
    Height := 80 + MD3DensityDelta(Density);
end;

procedure TFRMaterialNavBar.Paint;
var
  bmp: TBGRABitmap;
  i, iw, xPos: Integer;
  item: TFRMaterialNavItem;
  iconBmp: TBGRABitmap;
  aRect: TRect;
  clr: TColor;
  icoSz, icoY, pillY1, pillY2, pillR, pillHW: Integer;
  lblY1, lblY2: Integer;
begin
  { Proportional metrics based on Height (reference = 80) }
  icoSz := Height * 24 div 80;
  if icoSz < 16 then icoSz := 16;
  icoY := Height * 16 div 80;
  pillY1 := Height * 12 div 80;
  pillY2 := Height * 44 div 80;
  pillR := Height * 16 div 80;
  pillHW := Height * 32 div 80;
  lblY1 := Height * 48 div 80;
  lblY2 := Height * 72 div 80;

  if (Width <= 0) or (Height <= 0) then Exit;
  bmp := TBGRABitmap.Create(Width, Height, ColorToBGRA(MD3Colors.SurfaceContainer));
  try
    if FItems.Count > 0 then
    begin
      iw := Width div FItems.Count;
      for i := 0 to FItems.Count - 1 do
      begin
        item := FItems[i];
        xPos := i * iw;

        if i = FItemIndex then
        begin
          { active indicator pill }
          MD3FillRoundRect(bmp, xPos + iw div 2 - pillHW, pillY1,
            xPos + iw div 2 + pillHW, pillY2, pillR, MD3Colors.PrimaryContainer);
          clr := MD3Colors.OnPrimaryContainer;
        end
        else
          clr := MD3Colors.OnSurfaceVariant;

        { icon }
        if item.FIconMode <> imClear then
        begin
          iconBmp := FRGetCachedIcon(item.FIconMode, FRColorToSVGHex(clr), 2.0, icoSz, icoSz);
          bmp.PutImage(xPos + (iw - icoSz) div 2, icoY, iconBmp, dmDrawWithTransparency);
        end;

        { badge }
        if item.FBadge <> '' then
          DrawMD3Badge(bmp, Canvas, xPos + (iw - 24) div 2, icoY, item.FBadge);
      end;
    end;
    PaintRipple(bmp, MD3Colors.OnSurface);
    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { labels }
  if FItems.Count > 0 then
  begin
    iw := Width div FItems.Count;
    Canvas.Font.Size := Height * 8 div 80;
    if Canvas.Font.Size < 7 then Canvas.Font.Size := 7;
    for i := 0 to FItems.Count - 1 do
    begin
      xPos := i * iw;
      if i = FItemIndex then
        clr := MD3Colors.OnSurface
      else
        clr := MD3Colors.OnSurfaceVariant;
      aRect := Rect(xPos, lblY1, xPos + iw, lblY2);
      MD3DrawText(Canvas, FItems[i].FCaption, aRect, clr, taCenter, True);
    end;
    Canvas.Font.Size := 10;
  end;
end;

procedure TFRMaterialNavBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  iw, idx: Integer;
begin
  inherited;
  if (Button = mbLeft) and (FItems.Count > 0) then
  begin
    iw := Width div FItems.Count;
    idx := X div iw;
    if (idx >= 0) and (idx < FItems.Count) then
      SetItemIndex(idx);
  end;
end;

{ ══════════════════════════════════════════════════════════════
  TFRMaterialNavDrawer — side drawer 360dp
  ══════════════════════════════════════════════════════════════ }

constructor TFRMaterialNavDrawer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TFRMaterialNavItems.Create(Self);
  FItemIndex := 0;
  FHeaderTitle := '';
  Width := 360;
  Height := 600;
  Align := alLeft;
end;

destructor TFRMaterialNavDrawer.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TFRMaterialNavDrawer.SetItemIndex(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if (FItems.Count > 0) and (AValue >= FItems.Count) then
    AValue := FItems.Count - 1;
  if FItemIndex <> AValue then
  begin
    FItemIndex := AValue;
    Invalidate;
    if Assigned(FPageControl) then
      FPageControl.ActivePageIndex := FItemIndex;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TFRMaterialNavDrawer.SetItems(AValue: TFRMaterialNavItems);
begin
  FItems.Assign(AValue);
end;

procedure TFRMaterialNavDrawer.SetPageControl(AValue: TFRMaterialPageControl);
begin
  if FPageControl <> AValue then
  begin
    if Assigned(FPageControl) then
      FPageControl.RemoveFreeNotification(Self);
    FPageControl := AValue;
    if Assigned(FPageControl) then
      FPageControl.FreeNotification(Self);
  end;
end;

procedure TFRMaterialNavDrawer.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FPageControl) then
    FPageControl := nil;
end;

procedure TFRMaterialNavDrawer.Paint;
var
  bmp: TBGRABitmap;
  i, yPos: Integer;
  item: TFRMaterialNavItem;
  iconBmp: TBGRABitmap;
  aRect: TRect;
  clr: TColor;
  padX, icoSz, icoX, ih, pillR: Integer;
begin
  { Proportional metrics based on Width (reference = 360) }
  padX := Width * 12 div 360;
  if padX < 4 then padX := 4;
  icoSz := Width * 24 div 360;
  if icoSz < 16 then icoSz := 16;
  if icoSz > 32 then icoSz := 32;
  icoX := Width * 28 div 360;
  ih := 56 + MD3DensityDelta(Density);
  pillR := Width * 28 div 360;

  if (Width <= 0) or (Height <= 0) then Exit;
  bmp := TBGRABitmap.Create(Width, Height, ColorToBGRA(MD3Colors.SurfaceContainerLow));
  try
    yPos := padX + 4;

    { header }
    if FHeaderTitle <> '' then
      Inc(yPos, ih);

    { items + badges }
    for i := 0 to FItems.Count - 1 do
    begin
      item := FItems[i];
      if i = FItemIndex then
      begin
        MD3FillRoundRect(bmp, padX, yPos, Width - padX, yPos + ih, pillR,
          MD3Colors.PrimaryContainer);
        clr := MD3Colors.OnPrimaryContainer;
      end
      else
        clr := MD3Colors.OnSurfaceVariant;

      { icon }
      if item.FIconMode <> imClear then
      begin
        iconBmp := FRGetCachedIcon(item.FIconMode, FRColorToSVGHex(clr), 2.0, icoSz, icoSz);
        bmp.PutImage(icoX, yPos + (ih - icoSz) div 2, iconBmp, dmDrawWithTransparency);
      end;

      { badge }
      if item.FBadge <> '' then
        DrawMD3Badge(bmp, Canvas, Width - 44, yPos + (ih - 24) div 2, item.FBadge);

      Inc(yPos, ih);
    end;

    PaintRipple(bmp, MD3Colors.OnSurface);
    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { text labels }
  if FHeaderTitle <> '' then
  begin
    Canvas.Font.Size := Width * 12 div 360;
    if Canvas.Font.Size < 9 then Canvas.Font.Size := 9;
    Canvas.Font.Style := [fsBold];
    aRect := Rect(icoX, padX + 4, Width - padX, padX + 4 + ih);
    MD3DrawText(Canvas, FHeaderTitle, aRect, MD3Colors.OnSurfaceVariant, taLeftJustify, True);
    Canvas.Font.Style := [];
    Canvas.Font.Size := 10;
  end;

  yPos := padX + 4;
  if FHeaderTitle <> '' then Inc(yPos, ih);
  for i := 0 to FItems.Count - 1 do
  begin
    if i = FItemIndex then
      clr := MD3Colors.OnPrimaryContainer
    else
      clr := MD3Colors.OnSurfaceVariant;
    aRect := Rect(icoX + icoSz + padX, yPos, Width - padX, yPos + ih);
    MD3DrawText(Canvas, FItems[i].FCaption, aRect, clr, taLeftJustify, True);
    Inc(yPos, ih);
  end;
end;

procedure TFRMaterialNavDrawer.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  yStart, idx, ih, padX: Integer;
begin
  inherited;
  if Button <> mbLeft then Exit;
  padX := Width * 12 div 360;
  if padX < 4 then padX := 4;
  ih := 56 + MD3DensityDelta(Density);
  yStart := padX + 4;
  if FHeaderTitle <> '' then Inc(yStart, ih);
  idx := (Y - yStart) div ih;
  if (idx >= 0) and (idx < FItems.Count) then
    SetItemIndex(idx);
end;

{ ══════════════════════════════════════════════════════════════
  TFRMaterialNavRail — 80dp vertical rail
  ══════════════════════════════════════════════════════════════ }

constructor TFRMaterialNavRail.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TFRMaterialNavItems.Create(Self);
  FItemIndex := 0;
  FMenuIcon := imClear;
  FFabIcon := imClear;
  Width := 80;
  Height := 400;
  Align := alLeft;
end;

destructor TFRMaterialNavRail.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TFRMaterialNavRail.SetItemIndex(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if (FItems.Count > 0) and (AValue >= FItems.Count) then
    AValue := FItems.Count - 1;
  if FItemIndex <> AValue then
  begin
    FItemIndex := AValue;
    Invalidate;
    if Assigned(FPageControl) then
      FPageControl.ActivePageIndex := FItemIndex;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TFRMaterialNavRail.SetItems(AValue: TFRMaterialNavItems);
begin
  FItems.Assign(AValue);
end;

procedure TFRMaterialNavRail.SetPageControl(AValue: TFRMaterialPageControl);
begin
  if FPageControl <> AValue then
  begin
    if Assigned(FPageControl) then
      FPageControl.RemoveFreeNotification(Self);
    FPageControl := AValue;
    if Assigned(FPageControl) then
      FPageControl.FreeNotification(Self);
  end;
end;

procedure TFRMaterialNavRail.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FPageControl) then
    FPageControl := nil;
end;

procedure TFRMaterialNavRail.Paint;
var
  bmp: TBGRABitmap;
  i, yPos: Integer;
  item: TFRMaterialNavItem;
  iconBmp: TBGRABitmap;
  aRect: TRect;
  clr: TColor;
  icoSz, icoX, padX, ih, fabH, pillR, pillX1, pillX2: Integer;
begin
  { Proportional metrics based on Width (reference = 80) }
  icoSz := Width * 24 div 80;
  if icoSz < 16 then icoSz := 16;
  if icoSz > 32 then icoSz := 32;
  icoX := (Width - icoSz) div 2;
  padX := Width * 12 div 80;
  ih := 56 + MD3DensityDelta(Density);
  fabH := Width * 56 div 80;
  pillR := Width * 16 div 80;
  pillX1 := Width * 12 div 80;
  pillX2 := Width * 68 div 80;

  if (Width <= 0) or (Height <= 0) then Exit;
  bmp := TBGRABitmap.Create(Width, Height, ColorToBGRA(MD3Colors.Surface));
  try
    yPos := padX + 4;

    { optional menu icon }
    if FMenuIcon <> imClear then
    begin
      iconBmp := FRGetCachedIcon(FMenuIcon, FRColorToSVGHex(MD3Colors.OnSurface), 2.0, icoSz, icoSz);
      bmp.PutImage(icoX, yPos + (ih - icoSz) div 2, iconBmp, dmDrawWithTransparency);
      Inc(yPos, ih);
    end;

    { optional FAB }
    if FFabIcon <> imClear then
    begin
      MD3FillRoundRect(bmp, pillX1, yPos, pillX2, yPos + fabH, pillR, MD3Colors.PrimaryContainer);
      iconBmp := FRGetCachedIcon(FFabIcon, FRColorToSVGHex(MD3Colors.OnPrimaryContainer), 2.0, icoSz, icoSz);
      bmp.PutImage(icoX, yPos + (fabH - icoSz) div 2, iconBmp, dmDrawWithTransparency);
      Inc(yPos, fabH + padX + 4);
    end;

    { nav items }
    for i := 0 to FItems.Count - 1 do
    begin
      item := FItems[i];
      if i = FItemIndex then
      begin
        MD3FillRoundRect(bmp, pillX1, yPos + ih * 4 div 56, pillX2, yPos + ih * 36 div 56, pillR,
          MD3Colors.PrimaryContainer);
        clr := MD3Colors.OnPrimaryContainer;
      end
      else
        clr := MD3Colors.OnSurfaceVariant;

      { icon }
      if item.FIconMode <> imClear then
      begin
        iconBmp := FRGetCachedIcon(item.FIconMode, FRColorToSVGHex(clr), 2.0, icoSz, icoSz);
        bmp.PutImage(icoX, yPos + ih * 8 div 56, iconBmp, dmDrawWithTransparency);
      end;

      { badge }
      if item.FBadge <> '' then
        DrawMD3Badge(bmp, Canvas, icoX, yPos + ih * 8 div 56, item.FBadge);

      Inc(yPos, ih);
    end;

    PaintRipple(bmp, MD3Colors.OnSurface);
    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { labels under nav items }
  yPos := padX + 4;
  if FMenuIcon <> imClear then Inc(yPos, ih);
  if FFabIcon <> imClear then Inc(yPos, fabH + padX + 4);

  Canvas.Font.Size := Width * 8 div 80;
  if Canvas.Font.Size < 7 then Canvas.Font.Size := 7;
  for i := 0 to FItems.Count - 1 do
  begin
    if i = FItemIndex then
      clr := MD3Colors.Primary
    else
      clr := MD3Colors.OnSurfaceVariant;
    aRect := Rect(0, yPos + ih * 36 div 56, Width, yPos + ih);
    MD3DrawText(Canvas, FItems[i].FCaption, aRect, clr, taCenter, True);
    Inc(yPos, ih);
  end;
  Canvas.Font.Size := 10;
end;

procedure TFRMaterialNavRail.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  yStart, idx, ih, padX, fabH: Integer;
begin
  inherited;
  if Button <> mbLeft then Exit;

  padX := Width * 12 div 80;
  if padX < 4 then padX := 4;
  ih := 56 + MD3DensityDelta(Density);
  fabH := Width * 56 div 80;
  yStart := padX + 4;

  { menu icon area }
  if FMenuIcon <> imClear then
  begin
    if Y < yStart + ih then
    begin
      if Assigned(FOnMenuClick) then FOnMenuClick(Self);
      Exit;
    end;
    Inc(yStart, ih);
  end;
  { FAB area }
  if FFabIcon <> imClear then
  begin
    if Y < yStart + fabH then
    begin
      if Assigned(FOnFabClick) then FOnFabClick(Self);
      Exit;
    end;
    Inc(yStart, fabH + padX + 4);
  end;
  { items }
  idx := (Y - yStart) div ih;
  if (idx >= 0) and (idx < FItems.Count) then
    SetItemIndex(idx);
end;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialnavbar_icon.lrs}
    {$I icons\frmaterialnavdrawer_icon.lrs}
    {$I icons\frmaterialnavrail_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialNavBar, TFRMaterialNavDrawer, TFRMaterialNavRail]);
end;

end.

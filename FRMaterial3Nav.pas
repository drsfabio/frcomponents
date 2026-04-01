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
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialIcons;

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
    FOnChange: TNotifyEvent;
    procedure SetItemIndex(AValue: Integer);
    procedure SetItems(AValue: TFRMaterialNavItems);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Items: TFRMaterialNavItems read FItems write SetItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default 0;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Align;
    property Anchors;
    property Visible;
    property Enabled;
  end;

  { ── Navigation Drawer ── }
  TFRMaterialNavDrawer = class(TFRMaterial3Control)
  private
    FItems: TFRMaterialNavItems;
    FItemIndex: Integer;
    FHeaderTitle: string;
    FOnChange: TNotifyEvent;
    procedure SetItemIndex(AValue: Integer);
    procedure SetItems(AValue: TFRMaterialNavItems);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Items: TFRMaterialNavItems read FItems write SetItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default 0;
    property HeaderTitle: string read FHeaderTitle write FHeaderTitle;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Align;
    property Anchors;
    property Visible;
    property Enabled;
  end;

  { ── Navigation Rail ── }
  TFRMaterialNavRail = class(TFRMaterial3Control)
  private
    FItems: TFRMaterialNavItems;
    FItemIndex: Integer;
    FOnChange: TNotifyEvent;
    FMenuIcon: TFRIconMode;
    FFabIcon: TFRIconMode;
    FOnMenuClick: TNotifyEvent;
    FOnFabClick: TNotifyEvent;
    procedure SetItemIndex(AValue: Integer);
    procedure SetItems(AValue: TFRMaterialNavItems);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Items: TFRMaterialNavItems read FItems write SetItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default 0;
    property MenuIcon: TFRIconMode read FMenuIcon write FMenuIcon;
    property FabIcon: TFRIconMode read FFabIcon write FFabIcon;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnMenuClick: TNotifyEvent read FOnMenuClick write FOnMenuClick;
    property OnFabClick: TNotifyEvent read FOnFabClick write FOnFabClick;
    property Align;
    property Anchors;
    property Visible;
    property Enabled;
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
const
  BADGE_R = $002196F3;   { não — usa Error do MD3 }
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
    BadgeText := '9+'
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
  ABmp.FillRoundRectAntialias(bx, by, bx + bw, by + bh, 8, 8, bc);

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
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TFRMaterialNavBar.SetItems(AValue: TFRMaterialNavItems);
begin
  FItems.Assign(AValue);
end;

procedure TFRMaterialNavBar.Paint;
var
  bmp: TBGRABitmap;
  i, iw, xPos: Integer;
  item: TFRMaterialNavItem;
  svg: string;
  iconBmp: TBGRABitmap;
  aRect: TRect;
  clr: TColor;
begin
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
          MD3FillRoundRect(bmp, xPos + iw div 2 - 32, 12,
            xPos + iw div 2 + 32, 44, 16, MD3Colors.SecondaryContainer);
          clr := MD3Colors.OnSecondaryContainer;
        end
        else
          clr := MD3Colors.OnSurfaceVariant;

        { icon }
        if item.FIconMode <> imClear then
        begin
          svg := FRGetIconSVG(item.FIconMode, FRColorToSVGHex(clr), 2.0);
          if svg <> '' then
          begin
            iconBmp := FRRenderSVGIcon(svg, 24, 24);
            try
              bmp.PutImage(xPos + (iw - 24) div 2, 16, iconBmp, dmDrawWithTransparency);
            finally
              iconBmp.Free;
            end;
          end;
        end;

        { badge }
        if item.FBadge <> '' then
          DrawMD3Badge(bmp, Canvas, xPos + (iw - 24) div 2, 16, item.FBadge);
      end;
    end;
    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { labels }
  if FItems.Count > 0 then
  begin
    iw := Width div FItems.Count;
    Canvas.Font.Size := 8;
    for i := 0 to FItems.Count - 1 do
    begin
      xPos := i * iw;
      if i = FItemIndex then
        clr := MD3Colors.OnSurface
      else
        clr := MD3Colors.OnSurfaceVariant;
      aRect := Rect(xPos, 48, xPos + iw, 72);
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
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TFRMaterialNavDrawer.SetItems(AValue: TFRMaterialNavItems);
begin
  FItems.Assign(AValue);
end;

procedure TFRMaterialNavDrawer.Paint;
var
  bmp: TBGRABitmap;
  i, yPos: Integer;
  item: TFRMaterialNavItem;
  svg: string;
  iconBmp: TBGRABitmap;
  aRect: TRect;
  clr: TColor;
begin
  bmp := TBGRABitmap.Create(Width, Height, ColorToBGRA(MD3Colors.SurfaceContainerLow));
  try
    yPos := 16;

    { header }
    if FHeaderTitle <> '' then
      Inc(yPos, 56);

    { items }
    for i := 0 to FItems.Count - 1 do
    begin
      item := FItems[i];
      if i = FItemIndex then
      begin
        MD3FillRoundRect(bmp, 12, yPos, Width - 12, yPos + 56, 28,
          MD3Colors.SecondaryContainer);
        clr := MD3Colors.OnSecondaryContainer;
      end
      else
        clr := MD3Colors.OnSurfaceVariant;

      { icon }
      if item.FIconMode <> imClear then
      begin
        svg := FRGetIconSVG(item.FIconMode, FRColorToSVGHex(clr), 2.0);
        if svg <> '' then
        begin
          iconBmp := FRRenderSVGIcon(svg, 24, 24);
          try
            bmp.PutImage(28, yPos + 16, iconBmp, dmDrawWithTransparency);
          finally
            iconBmp.Free;
          end;
        end;
      end;

      Inc(yPos, 56);
    end;

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { text labels }
  if FHeaderTitle <> '' then
  begin
    Canvas.Font.Size := 12;
    Canvas.Font.Style := [fsBold];
    aRect := Rect(28, 16, Width - 16, 56);
    MD3DrawText(Canvas, FHeaderTitle, aRect, MD3Colors.OnSurfaceVariant, taLeftJustify, True);
    Canvas.Font.Style := [];
    Canvas.Font.Size := 10;
  end;

  yPos := 16;
  if FHeaderTitle <> '' then Inc(yPos, 56);
  for i := 0 to FItems.Count - 1 do
  begin
    if i = FItemIndex then
      clr := MD3Colors.OnSecondaryContainer
    else
      clr := MD3Colors.OnSurfaceVariant;
    aRect := Rect(68, yPos, Width - 16, yPos + 56);
    MD3DrawText(Canvas, FItems[i].FCaption, aRect, clr, taLeftJustify, True);

    { badge }
    if FItems[i].FBadge <> '' then
    begin
      { Pílula MD3 no lado direito da linha }
      DrawMD3Badge(bmp, Canvas, Width - 44, yPos + 16, FItems[i].FBadge);
    end;

    Inc(yPos, 56);
  end;
end;

procedure TFRMaterialNavDrawer.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  yStart, idx: Integer;
begin
  inherited;
  if Button <> mbLeft then Exit;
  yStart := 16;
  if FHeaderTitle <> '' then Inc(yStart, 56);
  idx := (Y - yStart) div 56;
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
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TFRMaterialNavRail.SetItems(AValue: TFRMaterialNavItems);
begin
  FItems.Assign(AValue);
end;

procedure TFRMaterialNavRail.Paint;
var
  bmp: TBGRABitmap;
  i, yPos: Integer;
  item: TFRMaterialNavItem;
  svg: string;
  iconBmp: TBGRABitmap;
  aRect: TRect;
  clr: TColor;
begin
  bmp := TBGRABitmap.Create(Width, Height, ColorToBGRA(MD3Colors.Surface));
  try
    yPos := 16;

    { optional menu icon }
    if FMenuIcon <> imClear then
    begin
      svg := FRGetIconSVG(FMenuIcon, FRColorToSVGHex(MD3Colors.OnSurface), 2.0);
      if svg <> '' then
      begin
        iconBmp := FRRenderSVGIcon(svg, 24, 24);
        try
          bmp.PutImage(28, yPos, iconBmp, dmDrawWithTransparency);
        finally
          iconBmp.Free;
        end;
      end;
      Inc(yPos, 56);
    end;

    { optional FAB }
    if FFabIcon <> imClear then
    begin
      MD3FillRoundRect(bmp, 12, yPos, 68, yPos + 56, 16, MD3Colors.PrimaryContainer);
      svg := FRGetIconSVG(FFabIcon, FRColorToSVGHex(MD3Colors.OnPrimaryContainer), 2.0);
      if svg <> '' then
      begin
        iconBmp := FRRenderSVGIcon(svg, 24, 24);
        try
          bmp.PutImage(28, yPos + 16, iconBmp, dmDrawWithTransparency);
        finally
          iconBmp.Free;
        end;
      end;
      Inc(yPos, 72);
    end;

    { nav items }
    for i := 0 to FItems.Count - 1 do
    begin
      item := FItems[i];
      if i = FItemIndex then
      begin
        MD3FillRoundRect(bmp, 12, yPos + 4, 68, yPos + 36, 16,
          MD3Colors.SecondaryContainer);
        clr := MD3Colors.OnSecondaryContainer;
      end
      else
        clr := MD3Colors.OnSurfaceVariant;

      { icon }
      if item.FIconMode <> imClear then
      begin
        svg := FRGetIconSVG(item.FIconMode, FRColorToSVGHex(clr), 2.0);
        if svg <> '' then
        begin
          iconBmp := FRRenderSVGIcon(svg, 24, 24);
          try
            bmp.PutImage(28, yPos + 8, iconBmp, dmDrawWithTransparency);
          finally
            iconBmp.Free;
          end;
        end;
      end;

      { badge }
      if item.FBadge <> '' then
        DrawMD3Badge(bmp, Canvas, 28, yPos + 8, item.FBadge);

      Inc(yPos, 56);
    end;

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { labels under nav items }
  yPos := 16;
  if FMenuIcon <> imClear then Inc(yPos, 56);
  if FFabIcon <> imClear then Inc(yPos, 72);

  Canvas.Font.Size := 8;
  for i := 0 to FItems.Count - 1 do
  begin
    if i = FItemIndex then
      clr := MD3Colors.OnSurface
    else
      clr := MD3Colors.OnSurfaceVariant;
    aRect := Rect(0, yPos + 36, 80, yPos + 56);
    MD3DrawText(Canvas, FItems[i].FCaption, aRect, clr, taCenter, True);
    Inc(yPos, 56);
  end;
  Canvas.Font.Size := 10;
end;

procedure TFRMaterialNavRail.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  yStart, idx: Integer;
begin
  inherited;
  if Button <> mbLeft then Exit;

  yStart := 16;
  { menu icon area }
  if FMenuIcon <> imClear then
  begin
    if Y < yStart + 56 then
    begin
      if Assigned(FOnMenuClick) then FOnMenuClick(Self);
      Exit;
    end;
    Inc(yStart, 56);
  end;
  { FAB area }
  if FFabIcon <> imClear then
  begin
    if Y < yStart + 56 then
    begin
      if Assigned(FOnFabClick) then FOnFabClick(Self);
      Exit;
    end;
    Inc(yStart, 72);
  end;
  { items }
  idx := (Y - yStart) div 56;
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
  RegisterComponents('BGRA Controls', [TFRMaterialNavBar, TFRMaterialNavDrawer, TFRMaterialNavRail]);
end;

end.

unit FRMaterial3AppBar;

{$mode objfpc}{$H+}

{ Material Design 3 — App Bar + Toolbar.

  TFRMaterialAppBar   — Top app bar (64dp) with nav icon, title, actions.
  TFRMaterialToolbar   — Generic toolbar with action buttons.

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, Menus,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialIcons, FRMaterialTheme;

type
  TFRMDAppBarSize = (absSmall, absMedium, absLarge);

  TFRMaterialAppBarAction = class(TCollectionItem)
  private
    FIconMode: TFRIconMode;
    FHint: string;
    FBadge: string;
    FOnClick: TNotifyEvent;
  published
    property IconMode: TFRIconMode read FIconMode write FIconMode;
    property Hint: string read FHint write FHint;
    property Badge: string read FBadge write FBadge;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

  TFRMaterialAppBarActions = class(TCollection)
  private
    FOwner: TComponent;
    function GetItem(Index: Integer): TFRMaterialAppBarAction;
    procedure SetItem(Index: Integer; AValue: TFRMaterialAppBarAction);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TComponent);
    function Add: TFRMaterialAppBarAction;
    property Items[Index: Integer]: TFRMaterialAppBarAction read GetItem write SetItem; default;
  end;

  TFRMaterialAppBar = class(TFRMaterial3Control)
  private
    FTitle: string;
    FNavIcon: TFRIconMode;
    FActions: TFRMaterialAppBarActions;
    FBarSize: TFRMDAppBarSize;
    FOnNavClick: TNotifyEvent;
    procedure SetTitle(const AValue: string);
    procedure SetBarSize(AValue: TFRMDAppBarSize);
    procedure SetActions(AValue: TFRMaterialAppBarActions);
    function GetBarHeight: Integer;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DoOnResize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Title: string read FTitle write SetTitle;
    property NavIcon: TFRIconMode read FNavIcon write FNavIcon;
    property Actions: TFRMaterialAppBarActions read FActions write SetActions;
    property BarSize: TFRMDAppBarSize read FBarSize write SetBarSize default absSmall;
    property OnNavClick: TNotifyEvent read FOnNavClick write FOnNavClick;
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

  TFRMaterialToolbar = class(TFRMaterial3Control)
  private
    FActions: TFRMaterialAppBarActions;
    procedure SetActions(AValue: TFRMaterialAppBarActions);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DoOnResize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Actions: TFRMaterialAppBarActions read FActions write SetActions;
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

{ ── TFRMaterialAppBarActions ── }

constructor TFRMaterialAppBarActions.Create(AOwner: TComponent);
begin
  inherited Create(TFRMaterialAppBarAction);
  FOwner := AOwner;
end;

function TFRMaterialAppBarActions.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TFRMaterialAppBarActions.GetItem(Index: Integer): TFRMaterialAppBarAction;
begin
  Result := TFRMaterialAppBarAction(inherited Items[Index]);
end;

procedure TFRMaterialAppBarActions.SetItem(Index: Integer; AValue: TFRMaterialAppBarAction);
begin
  inherited Items[Index] := AValue;
end;

function TFRMaterialAppBarActions.Add: TFRMaterialAppBarAction;
begin
  Result := TFRMaterialAppBarAction(inherited Add);
end;

{ ── TFRMaterialAppBar ── }

constructor TFRMaterialAppBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTitle := 'Title';
  //FNavIcon := nil;
  FActions := TFRMaterialAppBarActions.Create(Self);
  FBarSize := absSmall;
  Width := 400;
  Height := GetBarHeight;
  Align := alTop;
end;

destructor TFRMaterialAppBar.Destroy;
begin
  FActions.Free;
  inherited Destroy;
end;

function TFRMaterialAppBar.GetBarHeight: Integer;
begin
  case FBarSize of
    absSmall:  Result := 64;
    absMedium: Result := 112;
    absLarge:  Result := 152;
  else
    Result := 64;
  end;
end;

procedure TFRMaterialAppBar.SetTitle(const AValue: string);
begin
  if FTitle <> AValue then
  begin
    FTitle := AValue;
    Invalidate;
  end;
end;

procedure TFRMaterialAppBar.SetBarSize(AValue: TFRMDAppBarSize);
begin
  if FBarSize <> AValue then
  begin
    FBarSize := AValue;
    Height := GetBarHeight;
    Invalidate;
  end;
end;

procedure TFRMaterialAppBar.SetActions(AValue: TFRMaterialAppBarActions);
begin
  FActions.Assign(AValue);
end;

procedure TFRMaterialAppBar.Paint;
var
  bmp: TBGRABitmap;
  aRect: TRect;
  iconBmp: TBGRABitmap;
  i, xAct: Integer;
  titleLeft: Integer;
  baseH, padX, icoY, icoSz: Integer;
begin
  baseH := GetBarHeight;
  padX := Width * 16 div 400;
  if padX < 8 then padX := 8;
  icoY := Height * 20 div baseH;
  icoSz := Height * 24 div baseH;
  if icoSz < 16 then icoSz := 16;
  if icoSz > 36 then icoSz := 36;

  if (Width <= 0) or (Height <= 0) then Exit;
  bmp := TBGRABitmap.Create(Width, Height, ColorToBGRA(MD3Colors.Surface));
  try
    { nav icon — Primary tint for theme integration }
    titleLeft := padX;
    if FNavIcon <> imClear then
    begin
      iconBmp := FRGetCachedIcon(FNavIcon, FRColorToSVGHex(MD3Colors.Primary), 2.0, icoSz, icoSz);
      bmp.PutImage(padX, icoY, iconBmp, dmDrawWithTransparency);
      titleLeft := padX + icoSz + padX;
    end;

    { actions from right — Primary tint }
    xAct := Width - padX;
    for i := FActions.Count - 1 downto 0 do
    begin
      iconBmp := FRGetCachedIcon(FActions[i].FIconMode, FRColorToSVGHex(MD3Colors.Primary), 2.0, icoSz, icoSz);
      Dec(xAct, icoSz);
      bmp.PutImage(xAct, icoY, iconBmp, dmDrawWithTransparency);
      Dec(xAct, padX);
    end;

    { bottom accent line }
    bmp.DrawLineAntialias(0, Height - 1, Width, Height - 1,
      ColorToBGRA(MD3Colors.Primary), 2);

    PaintRipple(bmp, MD3Colors.OnSurface);
    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { title text }
  Canvas.Font.Style := [fsBold];
  case FBarSize of
    absSmall:
    begin
      aRect := Rect(titleLeft, 0, xAct, Height - 1);
      Canvas.Font.Size := Height * 12 div baseH;
    end;
    absMedium:
    begin
      aRect := Rect(padX, Height * 64 div baseH, Width - padX, Height);
      Canvas.Font.Size := Height * 14 div baseH;
    end;
    absLarge:
    begin
      aRect := Rect(padX, Height * 104 div baseH, Width - padX, Height);
      Canvas.Font.Size := Height * 16 div baseH;
    end;
  end;
  MD3DrawText(Canvas, FTitle, aRect, MD3Colors.OnSurface, taLeftJustify, True);
  Canvas.Font.Style := [];
  Canvas.Font.Size := 10;
end;

procedure TFRMaterialAppBar.DoOnResize;
begin
  inherited DoOnResize;
  if not (csLoading in ComponentState) then
    Height := GetBarHeight + MD3DensityDelta(Density);
end;

procedure TFRMaterialAppBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, xAct: Integer;
  baseH, padX, icoSz, icoY, hitH: Integer;
begin
  inherited;
  if Button <> mbLeft then Exit;

  baseH := GetBarHeight;
  padX := Width * 16 div 400;
  if padX < 8 then padX := 8;
  icoSz := Height * 24 div baseH;
  if icoSz < 16 then icoSz := 16;
  if icoSz > 36 then icoSz := 36;
  icoY := Height * 20 div baseH;
  hitH := icoY + icoSz;

  { check nav icon click }
  if (FNavIcon <> imClear) and (X < padX + icoSz + 8) and (Y >= icoY - 4) and (Y <= hitH + 4) then
  begin
    if Assigned(FOnNavClick) then
      FOnNavClick(Self);
    Exit;
  end;

  { check action clicks }
  xAct := Width - padX;
  for i := FActions.Count - 1 downto 0 do
  begin
    Dec(xAct, icoSz);
    if (X >= xAct) and (X <= xAct + icoSz) and (Y >= icoY - 4) and (Y <= hitH + 4) then
    begin
      if Assigned(FActions[i].FOnClick) then
        FActions[i].FOnClick(FActions[i]);
      Exit;
    end;
    Dec(xAct, padX);
  end;
end;

{ ── TFRMaterialToolbar ── }

constructor TFRMaterialToolbar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FActions := TFRMaterialAppBarActions.Create(Self);
  Width := 400;
  Height := 64;
end;

destructor TFRMaterialToolbar.Destroy;
begin
  FActions.Free;
  inherited Destroy;
end;

procedure TFRMaterialToolbar.SetActions(AValue: TFRMaterialAppBarActions);
begin
  FActions.Assign(AValue);
end;

procedure TFRMaterialToolbar.Paint;
var
  bmp: TBGRABitmap;
  i, xPos: Integer;
  iconBmp: TBGRABitmap;
  icoSz, icoY, cellW: Integer;
begin
  icoSz := Height * 24 div 64;
  if icoSz < 16 then icoSz := 16;
  icoY := (Height - icoSz) div 2;
  cellW := Height * 48 div 64;

  if (Width <= 0) or (Height <= 0) then Exit;
  bmp := TBGRABitmap.Create(Width, Height, ColorToBGRA(MD3Colors.SurfaceContainer));
  try
    xPos := (Width - FActions.Count * cellW) div 2;
    for i := 0 to FActions.Count - 1 do
    begin
      iconBmp := FRGetCachedIcon(FActions[i].FIconMode, FRColorToSVGHex(MD3Colors.OnSurface), 2.0, icoSz, icoSz);
      bmp.PutImage(xPos + (cellW - icoSz) div 2, icoY, iconBmp, dmDrawWithTransparency);
      Inc(xPos, cellW);
    end;
    PaintRipple(bmp, MD3Colors.OnSurface);
    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;
end;

procedure TFRMaterialToolbar.DoOnResize;
begin
  inherited DoOnResize;
  if not (csLoading in ComponentState) then
    Height := 64 + MD3DensityDelta(Density);
end;

procedure TFRMaterialToolbar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, xStart, xPos, cellW: Integer;
begin
  inherited;
  if Button <> mbLeft then Exit;
  cellW := Height * 48 div 64;
  xStart := (Width - FActions.Count * cellW) div 2;
  for i := 0 to FActions.Count - 1 do
  begin
    xPos := xStart + i * cellW;
    if (X >= xPos) and (X < xPos + cellW) then
    begin
      if Assigned(FActions[i].FOnClick) then
        FActions[i].FOnClick(FActions[i]);
      Exit;
    end;
  end;
end;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialappbar_icon.lrs}
    {$I icons\frmaterialtoolbar_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialAppBar, TFRMaterialToolbar]);
end;

end.

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
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialIcons;

type
  TFRMDAppBarSize = (absSmall, absMedium, absLarge);

  TFRMaterialAppBarAction = class(TCollectionItem)
  private
    FIconMode: TFRIconMode;
    FHint: string;
    FOnClick: TNotifyEvent;
  published
    property IconMode: TFRIconMode read FIconMode write FIconMode;
    property Hint: string read FHint write FHint;
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
    property Visible;
    property Enabled;
  end;

  TFRMaterialToolbar = class(TFRMaterial3Control)
  private
    FActions: TFRMaterialAppBarActions;
    procedure SetActions(AValue: TFRMaterialAppBarActions);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Actions: TFRMaterialAppBarActions read FActions write SetActions;
    property Align;
    property Anchors;
    property Visible;
    property Enabled;
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
  svg: string;
  i, xAct: Integer;
  titleLeft: Integer;
begin
  bmp := TBGRABitmap.Create(Width, Height, ColorToBGRA(MD3Colors.Surface));
  try
    { nav icon }
    titleLeft := 16;
    if FNavIcon <> imClear then
    begin
      svg := FRGetIconSVG(FNavIcon, FRColorToSVGHex(MD3Colors.OnSurface), 2.0);
      if svg <> '' then
      begin
        iconBmp := FRRenderSVGIcon(svg, 24, 24);
        try
          bmp.PutImage(16, 20, iconBmp, dmDrawWithTransparency);
        finally
          iconBmp.Free;
        end;
      end;
      titleLeft := 56;
    end;

    { actions from right }
    xAct := Width - 16;
    for i := FActions.Count - 1 downto 0 do
    begin
      svg := FRGetIconSVG(FActions[i].FIconMode, FRColorToSVGHex(MD3Colors.OnSurfaceVariant), 2.0);
      if svg <> '' then
      begin
        iconBmp := FRRenderSVGIcon(svg, 24, 24);
        try
          Dec(xAct, 24);
          bmp.PutImage(xAct, 20, iconBmp, dmDrawWithTransparency);
          Dec(xAct, 16);
        finally
          iconBmp.Free;
        end;
      end;
    end;

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { title text }
  case FBarSize of
    absSmall:
    begin
      aRect := Rect(titleLeft, 0, xAct, 64);
      Canvas.Font.Size := 12;
    end;
    absMedium:
    begin
      aRect := Rect(16, 64, Width - 16, 112);
      Canvas.Font.Size := 14;
    end;
    absLarge:
    begin
      aRect := Rect(16, 104, Width - 16, 152);
      Canvas.Font.Size := 16;
    end;
  end;
  Canvas.Font.Style := [fsBold];
  MD3DrawText(Canvas, FTitle, aRect, MD3Colors.OnSurface, taLeftJustify, True);
  Canvas.Font.Style := [];
  Canvas.Font.Size := 10;
end;

procedure TFRMaterialAppBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, xAct: Integer;
begin
  inherited;
  if Button <> mbLeft then Exit;

  { check nav icon click }
  if (FNavIcon <> imClear) and (X < 48) and (Y >= 12) and (Y <= 52) then
  begin
    if Assigned(FOnNavClick) then
      FOnNavClick(Self);
    Exit;
  end;

  { check action clicks }
  xAct := Width - 16;
  for i := FActions.Count - 1 downto 0 do
  begin
    Dec(xAct, 24);
    if (X >= xAct) and (X <= xAct + 24) and (Y >= 12) and (Y <= 52) then
    begin
      if Assigned(FActions[i].FOnClick) then
        FActions[i].FOnClick(FActions[i]);
      Exit;
    end;
    Dec(xAct, 16);
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
  svg: string;
  iconBmp: TBGRABitmap;
begin
  bmp := TBGRABitmap.Create(Width, Height, ColorToBGRA(MD3Colors.SurfaceContainer));
  try
    xPos := (Width - FActions.Count * 48) div 2;
    for i := 0 to FActions.Count - 1 do
    begin
      svg := FRGetIconSVG(FActions[i].FIconMode, FRColorToSVGHex(MD3Colors.OnSurface), 2.0);
      if svg <> '' then
      begin
        iconBmp := FRRenderSVGIcon(svg, 24, 24);
        try
          bmp.PutImage(xPos + 12, 20, iconBmp, dmDrawWithTransparency);
        finally
          iconBmp.Free;
        end;
      end;
      Inc(xPos, 48);
    end;
    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;
end;

procedure TFRMaterialToolbar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, xStart, xPos: Integer;
begin
  inherited;
  if Button <> mbLeft then Exit;
  xStart := (Width - FActions.Count * 48) div 2;
  for i := 0 to FActions.Count - 1 do
  begin
    xPos := xStart + i * 48;
    if (X >= xPos) and (X < xPos + 48) then
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
  RegisterComponents('BGRA Controls', [TFRMaterialAppBar, TFRMaterialToolbar]);
end;

end.

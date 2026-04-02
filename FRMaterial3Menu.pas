unit FRMaterial3Menu;

{$mode objfpc}{$H+}

{ Material Design 3 — Menu.

  TFRMaterialMenu — Material 3 popup menu rendered with BGRABitmap.

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, Forms, Menus,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialIcons;

type
  TFRMaterialMenuItem = class(TCollectionItem)
  private
    FCaption: string;
    FIconMode: TFRIconMode;
    FEnabled: Boolean;
    FIsSeparator: Boolean;
    FIsHeader: Boolean;
    FOnClick: TNotifyEvent;
  public
    constructor Create(ACollection: TCollection); override;
  published
    property Caption: string read FCaption write FCaption;
    property IconMode: TFRIconMode read FIconMode write FIconMode;
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property IsSeparator: Boolean read FIsSeparator write FIsSeparator default False;
    property IsHeader: Boolean read FIsHeader write FIsHeader default False;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

  TFRMaterialMenuItems = class(TCollection)
  private
    FOwner: TComponent;
    function GetItem(Index: Integer): TFRMaterialMenuItem;
    procedure SetItem(Index: Integer; AValue: TFRMaterialMenuItem);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TComponent);
    function Add: TFRMaterialMenuItem;
    property Items[Index: Integer]: TFRMaterialMenuItem read GetItem write SetItem; default;
  end;

  TFRMaterialMenu = class(TComponent)
  private
    FItems: TFRMaterialMenuItems;
    FMinWidth: Integer;
    procedure SetItems(AValue: TFRMaterialMenuItems);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Popup(X, Y: Integer);
  published
    property Items: TFRMaterialMenuItems read FItems write SetItems;
    property MinWidth: Integer read FMinWidth write FMinWidth default 112;
  end;

procedure Register;

implementation

uses Math;

type
  TMenuForm = class(TForm)
  private
    FMenu: TFRMaterialMenu;
    FHoverIndex: Integer;
    procedure FormDeactivate(Sender: TObject);
  protected
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor CreateMenu(AMenu: TFRMaterialMenu; AX, AY: Integer);
  end;

{ ── TFRMaterialMenuItem ── }

constructor TFRMaterialMenuItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FEnabled := True;
  FIsSeparator := False;
  FIsHeader := False;
end;

{ ── TFRMaterialMenuItems ── }

constructor TFRMaterialMenuItems.Create(AOwner: TComponent);
begin
  inherited Create(TFRMaterialMenuItem);
  FOwner := AOwner;
end;

function TFRMaterialMenuItems.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TFRMaterialMenuItems.GetItem(Index: Integer): TFRMaterialMenuItem;
begin
  Result := TFRMaterialMenuItem(inherited Items[Index]);
end;

procedure TFRMaterialMenuItems.SetItem(Index: Integer; AValue: TFRMaterialMenuItem);
begin
  inherited Items[Index] := AValue;
end;

function TFRMaterialMenuItems.Add: TFRMaterialMenuItem;
begin
  Result := TFRMaterialMenuItem(inherited Add);
end;

{ ── TFRMaterialMenu ── }

constructor TFRMaterialMenu.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TFRMaterialMenuItems.Create(Self);
  FMinWidth := 112;
end;

destructor TFRMaterialMenu.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TFRMaterialMenu.SetItems(AValue: TFRMaterialMenuItems);
begin
  FItems.Assign(AValue);
end;

procedure TFRMaterialMenu.Popup(X, Y: Integer);
var
  frm: TMenuForm;
begin
  frm := TMenuForm.CreateMenu(Self, X, Y);
  frm.Show;
end;

{ ── TMenuForm ── }

constructor TMenuForm.CreateMenu(AMenu: TFRMaterialMenu; AX, AY: Integer);
var
  i, h, maxW: Integer;
  item: TFRMaterialMenuItem;
begin
  inherited CreateNew(nil);
  FMenu := AMenu;
  FHoverIndex := -1;
  BorderStyle := bsNone;
  FormStyle := fsStayOnTop;
  ShowInTaskBar := stNever;
  OnDeactivate := @FormDeactivate;

  { compute width }
  Canvas.Font.Size := 10;
  maxW := AMenu.FMinWidth;
  for i := 0 to AMenu.FItems.Count - 1 do
  begin
    item := AMenu.FItems[i];
    if not item.FIsSeparator then
      maxW := Max(maxW, Canvas.TextWidth(item.FCaption) + 60);
  end;

  { compute height }
  h := 8;
  for i := 0 to AMenu.FItems.Count - 1 do
  begin
    if AMenu.FItems[i].FIsSeparator then
      Inc(h, 9)
    else if AMenu.FItems[i].FIsHeader then
      Inc(h, 36)
    else
      Inc(h, 48);
  end;
  Inc(h, 8);

  Left := AX;
  Top := AY;
  Width := maxW;
  Height := h;
end;

procedure TMenuForm.Paint;
var
  bmp: TBGRABitmap;
  i, yPos, itemH: Integer;
  item: TFRMaterialMenuItem;
  aRect: TRect;
  iconBmp: TBGRABitmap;
begin
  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    MD3FillRoundRect(bmp, 0, 0, Width - 1, Height - 1, 4, MD3Colors.SurfaceContainer);

    yPos := 8;
    for i := 0 to FMenu.FItems.Count - 1 do
    begin
      item := FMenu.FItems[i];
      if item.FIsSeparator then
      begin
        bmp.DrawLineAntialias(0, yPos + 4, Width, yPos + 4,
          ColorToBGRA(MD3Colors.OutlineVariant), 1);
        Inc(yPos, 9);
        Continue;
      end;

      if item.FIsHeader then
        itemH := 36
      else
        itemH := 48;

      { hover highlight — only for normal items }
      if (i = FHoverIndex) and (not item.FIsHeader) then
        bmp.FillRect(0, yPos, Width, yPos + itemH,
          ColorToBGRA(MD3Colors.OnSurface, 20), dmDrawWithTransparency);

      { icon }
      if (not item.FIsHeader) and (item.FIconMode <> imClear) then
      begin
        iconBmp := FRGetCachedIcon(item.FIconMode, FRColorToSVGHex(MD3Colors.OnSurfaceVariant), 2.0, 24, 24);
        bmp.PutImage(12, yPos + (itemH - 24) div 2, iconBmp, dmDrawWithTransparency);
      end;

      Inc(yPos, itemH);
    end;

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { draw text on Canvas }
  yPos := 8;
  for i := 0 to FMenu.FItems.Count - 1 do
  begin
    item := FMenu.FItems[i];
    if item.FIsSeparator then
    begin
      Inc(yPos, 9);
      Continue;
    end;

    if item.FIsHeader then
    begin
      aRect := Rect(12, yPos, Width - 12, yPos + 36);
      Canvas.Font.Style := [fsBold];
      Canvas.Font.Size := 9;
      MD3DrawText(Canvas, item.FCaption, aRect, MD3Colors.OnSurfaceVariant, taLeftJustify, True);
      Canvas.Font.Style := [];
      Canvas.Font.Size := 10;
      Inc(yPos, 36);
      Continue;
    end;

    if item.FIconMode <> imClear then
      aRect := Rect(48, yPos, Width - 12, yPos + 48)
    else
      aRect := Rect(24, yPos, Width - 12, yPos + 48);
    if item.FEnabled then
      MD3DrawText(Canvas, item.FCaption, aRect, MD3Colors.OnSurface, taLeftJustify, True)
    else
      MD3DrawText(Canvas, item.FCaption, aRect, MD3Colors.OnSurface and $00AAAAAA, taLeftJustify, True);
    Inc(yPos, 48);
  end;
end;

procedure TMenuForm.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  i, yPos, itemH: Integer;
  newHover: Integer;
  item: TFRMaterialMenuItem;
begin
  inherited;
  newHover := -1;
  yPos := 8;
  for i := 0 to FMenu.FItems.Count - 1 do
  begin
    item := FMenu.FItems[i];
    if item.FIsSeparator then
    begin
      Inc(yPos, 9);
      Continue;
    end;
    if item.FIsHeader then
      itemH := 36
    else
      itemH := 48;
    if (not item.FIsHeader) and (Y >= yPos) and (Y < yPos + itemH) then
    begin
      newHover := i;
      Break;
    end;
    Inc(yPos, itemH);
  end;
  if newHover <> FHoverIndex then
  begin
    FHoverIndex := newHover;
    Invalidate;
  end;
end;

procedure TMenuForm.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  item: TFRMaterialMenuItem;
begin
  inherited;
  if (FHoverIndex >= 0) and (FHoverIndex < FMenu.FItems.Count) then
  begin
    item := FMenu.FItems[FHoverIndex];
    if item.FEnabled and (not item.FIsHeader) and Assigned(item.FOnClick) then
      item.FOnClick(item);
  end;
  Release;
end;

procedure TMenuForm.FormDeactivate(Sender: TObject);
begin
  Release;
end;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialmenu_icon.lrs}
  {$ENDIF}
  RegisterComponents('BGRA Controls', [TFRMaterialMenu]);
end;

end.

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
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialIcons;

type
  TFRMDTabStyle = (tsFixed, tsScrollable);

  TFRMaterialTabItem = class(TCollectionItem)
  private
    FCaption: string;
    FIconMode: TFRIconMode;
  published
    property Caption: string read FCaption write FCaption;
    property IconMode: TFRIconMode read FIconMode write FIconMode;
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
    FOnChange: TNotifyEvent;
    procedure SetTabIndex(AValue: Integer);
    function GetTabWidth: Integer;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Tabs: TFRMaterialTabItems read FTabs write FTabs;
    property TabIndex: Integer read FTabIndex write SetTabIndex default 0;
    property TabStyle: TFRMDTabStyle read FTabStyle write FTabStyle default tsFixed;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Align;
    property Anchors;
    property Visible;
    property Enabled;
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
  Width := 400;
  Height := 48;
end;

destructor TFRMaterialTabs.Destroy;
begin
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

procedure TFRMaterialTabs.Paint;
var
  bmp: TBGRABitmap;
  i, tw, xPos: Integer;
  tab: TFRMaterialTabItem;
  aRect: TRect;
  textColor: TColor;
  iconBmp: TBGRABitmap;
  textY: Integer;
begin
  bmp := TBGRABitmap.Create(Width, Height, ColorToBGRA(MD3Colors.Surface));
  try
    { bottom line }
    bmp.DrawLineAntialias(0, Height - 1, Width, Height - 1,
      ColorToBGRA(MD3Colors.SurfaceContainerHighest), 1);

    tw := GetTabWidth;
    for i := 0 to FTabs.Count - 1 do
    begin
      tab := FTabs[i];
      xPos := i * tw;

      if i = FTabIndex then
      begin
        { indicator }
        bmp.FillRect(xPos + tw div 4, Height - 3, xPos + tw - tw div 4, Height,
          ColorToBGRA(MD3Colors.Primary), dmDrawWithTransparency);
      end;

      { icon }
      if tab.FIconMode <> imClear then
      begin
        if i = FTabIndex then
          textColor := MD3Colors.Primary
        else
          textColor := MD3Colors.OnSurfaceVariant;
        iconBmp := FRGetCachedIcon(tab.FIconMode, FRColorToSVGHex(textColor), 2.0, 20, 20);
        bmp.PutImage(xPos + (tw - 20) div 2, 8, iconBmp, dmDrawWithTransparency);
      end;
    end;

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { text labels — second pass on Canvas after bmp.Draw }
  tw := GetTabWidth;
  for i := 0 to FTabs.Count - 1 do
  begin
    tab := FTabs[i];
    xPos := i * tw;

    if i = FTabIndex then
      textColor := MD3Colors.Primary
    else
      textColor := MD3Colors.OnSurfaceVariant;

    if tab.FIconMode <> imClear then
      textY := 30
    else
      textY := 0;

    aRect := Rect(xPos, textY, xPos + tw, Height - 4);
    MD3DrawText(Canvas, tab.FCaption, aRect, textColor, taCenter, True);
  end;
end;

procedure TFRMaterialTabs.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  tw, idx: Integer;
begin
  inherited;
  if Button = mbLeft then
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

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialtabs_icon.lrs}
  {$ENDIF}
  RegisterComponents('BGRA Controls', [TFRMaterialTabs]);
end;

end.

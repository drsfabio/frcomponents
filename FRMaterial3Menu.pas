unit FRMaterial3Menu;

{$mode objfpc}{$H+}

{ Material Design 3 — Menu.

  TFRMaterialMenu — Material 3 popup menu rendered with BGRABitmap.
  Supports cascading submenus via TFRMaterialMenuItem.SubItems.

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, Forms, Menus, ExtCtrls, ActnList,
  {$IFDEF FPC} LCLType, LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterialTheme, FRMaterial3Base, FRMaterialIcons;

type
  TFRMaterialMenuItem = class;
  TFRMaterialMenuItems = class;

  { How submenus are triggered }
  TFRMDSubMenuTrigger = (smtHover, smtClick);

  TFRMaterialMenuItem = class(TCollectionItem)
  private
    FCaption: string;
    FIconMode: TFRIconMode;
    FEnabled: Boolean;
    FIsSeparator: Boolean;
    FSubItems: TFRMaterialMenuItems;
    FAction: TBasicAction;
    FOnClick: TNotifyEvent;
    function GetHasSubItems: Boolean;
    procedure SetSubItems(AValue: TFRMaterialMenuItems);
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure ExecuteAction;
    property HasSubItems: Boolean read GetHasSubItems;
  published
    property Caption: string read FCaption write FCaption;
    property IconMode: TFRIconMode read FIconMode write FIconMode;
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property IsSeparator: Boolean read FIsSeparator write FIsSeparator default False;
    property SubItems: TFRMaterialMenuItems read FSubItems write SetSubItems;
    property Action: TBasicAction read FAction write FAction;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

  TFRMaterialMenuItems = class(TCollection)
  private
    FOwner: TPersistent;
    function GetItem(Index: Integer): TFRMaterialMenuItem;
    procedure SetItem(Index: Integer; AValue: TFRMaterialMenuItem);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TFRMaterialMenuItem;
    property Items[Index: Integer]: TFRMaterialMenuItem read GetItem write SetItem; default;
  end;

  TFRMaterialMenu = class(TComponent, IFRMaterialComponent)
  private
    FItems: TFRMaterialMenuItems;
    FMinWidth: Integer;
    FSubMenuTrigger: TFRMDSubMenuTrigger;
    FRootForm: TCustomForm;
    procedure SetItems(AValue: TFRMaterialMenuItems);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Popup(X, Y: Integer);
    procedure CloseAll;
    procedure ApplyTheme(const AThemeManager: TObject); virtual;
  published
    property Items: TFRMaterialMenuItems read FItems write SetItems;
    property MinWidth: Integer read FMinWidth write FMinWidth default 112;
    property SubMenuTrigger: TFRMDSubMenuTrigger read FSubMenuTrigger write FSubMenuTrigger default smtHover;
  end;

procedure Register;

implementation

uses Math;

{ Returns the accelerator character from a caption containing '&'.
  E.g. '&Arquivo' → 'A', 'A&rquivo' → 'R'. Returns #0 if none. }
function ExtractAccelChar(const ACaption: string): Char;
var
  i: Integer;
begin
  Result := #0;
  for i := 1 to Length(ACaption) - 1 do
  begin
    if (ACaption[i] = '&') and (ACaption[i + 1] <> '&') then
    begin
      Result := UpCase(ACaption[i + 1]);
      Exit;
    end;
  end;
end;

{ Strips single '&' from caption for display, converts '&&' to '&'. }
function StripAccelChar(const ACaption: string): string;
var
  i: Integer;
begin
  Result := '';
  i := 1;
  while i <= Length(ACaption) do
  begin
    if (ACaption[i] = '&') and (i < Length(ACaption)) then
    begin
      Inc(i); { skip the '&', take next char }
      Result := Result + ACaption[i];
    end
    else
      Result := Result + ACaption[i];
    Inc(i);
  end;
end;

{ Returns the character index (0-based) of the accelerator in the stripped string,
  or -1 if none. }
function AccelCharIndex(const ACaption: string): Integer;
var
  i, pos: Integer;
begin
  Result := -1;
  pos := 0;
  i := 1;
  while i <= Length(ACaption) do
  begin
    if (ACaption[i] = '&') and (i < Length(ACaption)) and (ACaption[i + 1] <> '&') then
    begin
      Result := pos;
      Exit;
    end;
    if (ACaption[i] = '&') and (i < Length(ACaption)) and (ACaption[i + 1] = '&') then
    begin
      Inc(i); { skip doubled '&' }
    end;
    Inc(pos);
    Inc(i);
  end;
end;

type

  { TMenuForm — popup form for a single menu level }

  TMenuForm = class(TForm)
  private
    FItems: TFRMaterialMenuItems;
    FMinWidth: Integer;
    FRootMenu: TFRMaterialMenu;
    FParentMenuForm: TMenuForm;
    FChildMenuForm: TMenuForm;
    FHoverIndex: Integer;
    FSubMenuIndex: Integer;
    FSubMenuTrigger: TFRMDSubMenuTrigger;
    FHoverTimer: TTimer;
    FClosingChild: Boolean;
    procedure HoverTimerFire(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure ShowSubMenu(AIndex: Integer);
    procedure CloseChildMenu;
    function ItemYPos(AIndex: Integer): Integer;
    function FindNextItem(AFrom, ADir: Integer): Integer;
    function RootForm: TMenuForm;
    function IsInChain(AForm: TCustomForm): Boolean;
  protected
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor CreateMenu(AItems: TFRMaterialMenuItems; AMinWidth: Integer;
      ARootMenu: TFRMaterialMenu; AParentForm: TMenuForm;
      ATrigger: TFRMDSubMenuTrigger; AX, AY: Integer);
    destructor Destroy; override;
    procedure CloseAll;
  end;

{ ── TFRMaterialMenuItem ── }

constructor TFRMaterialMenuItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FEnabled := True;
  FIsSeparator := False;
  FAction := nil;
  FSubItems := TFRMaterialMenuItems.Create(Self);
end;

destructor TFRMaterialMenuItem.Destroy;
begin
  FSubItems.Free;
  inherited Destroy;
end;

function TFRMaterialMenuItem.GetHasSubItems: Boolean;
begin
  Result := FSubItems.Count > 0;
end;

procedure TFRMaterialMenuItem.ExecuteAction;
begin
  if Assigned(FAction) then
    FAction.Execute
  else if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TFRMaterialMenuItem.SetSubItems(AValue: TFRMaterialMenuItems);
begin
  FSubItems.Assign(AValue);
end;

{ ── TFRMaterialMenuItems ── }

constructor TFRMaterialMenuItems.Create(AOwner: TPersistent);
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
  FSubMenuTrigger := smtHover;
  
  FRMDRegisterComponent(Self);
end;

destructor TFRMaterialMenu.Destroy;
begin
  CloseAll;
  FItems.Free;
  
  FRMDUnregisterComponent(Self);
    
  inherited Destroy;
end;

procedure TFRMaterialMenu.ApplyTheme(const AThemeManager: TObject);
var
  i: Integer;
begin
  if not Assigned(AThemeManager) then Exit;
  { If a menu form is currently showing, we might find it in Screen.Forms }
  for i := 0 to Screen.FormCount - 1 do
    if Screen.Forms[i] is TMenuForm then
      Screen.Forms[i].Invalidate;
end;

procedure TFRMaterialMenu.SetItems(AValue: TFRMaterialMenuItems);
begin
  FItems.Assign(AValue);
end;

procedure TFRMaterialMenu.Popup(X, Y: Integer);
var
  frm: TMenuForm;
begin
  CloseAll;
  frm := TMenuForm.CreateMenu(FItems, FMinWidth, Self, nil, FSubMenuTrigger, X, Y);
  FRootForm := frm;
  frm.Show;
  frm.SetFocus;
end;

procedure TFRMaterialMenu.CloseAll;
begin
  if Assigned(FRootForm) and (FRootForm is TMenuForm) then
  begin
    TMenuForm(FRootForm).CloseChildMenu;
    FRootForm.Release;
    FRootForm := nil;
  end;
end;

{ ── TMenuForm ── }

constructor TMenuForm.CreateMenu(AItems: TFRMaterialMenuItems; AMinWidth: Integer;
  ARootMenu: TFRMaterialMenu; AParentForm: TMenuForm;
  ATrigger: TFRMDSubMenuTrigger; AX, AY: Integer);
var
  i, h, maxW: Integer;
  item: TFRMaterialMenuItem;
  Mon: TMonitor;
  MonRect: TRect;
begin
  inherited CreateNew(nil);
  FItems := AItems;
  FMinWidth := AMinWidth;
  FRootMenu := ARootMenu;
  FParentMenuForm := AParentForm;
  FChildMenuForm := nil;
  FHoverIndex := -1;
  FSubMenuIndex := -1;
  FClosingChild := False;
  FSubMenuTrigger := ATrigger;
  BorderStyle := bsNone;
  FormStyle := fsStayOnTop;
  ShowInTaskBar := stNever;
  KeyPreview := True;
  PopupMode := pmExplicit;
  PopupParent := Screen.ActiveForm;

  { All popups in the chain get deactivate handler }
  OnDeactivate := @FormDeactivate;

  FHoverTimer := TTimer.Create(Self);
  FHoverTimer.Interval := 300;
  FHoverTimer.Enabled := False;
  FHoverTimer.OnTimer := @HoverTimerFire;

  { compute width }
  Canvas.Font.Size := 10;
  maxW := AMinWidth;
  for i := 0 to AItems.Count - 1 do
  begin
    item := AItems[i];
    if not item.FIsSeparator then
    begin
      { extra space for submenu arrow }
      if item.HasSubItems then
        maxW := Max(maxW, Canvas.TextWidth(StripAccelChar(item.FCaption)) + 80)
      else
        maxW := Max(maxW, Canvas.TextWidth(StripAccelChar(item.FCaption)) + 60);
    end;
  end;

  { compute height }
  h := 8;
  for i := 0 to AItems.Count - 1 do
  begin
    if AItems[i].FIsSeparator then
      Inc(h, 9)
    else
      Inc(h, 48);
  end;
  Inc(h, 8);

  { Clamp to correct monitor bounds }
  Mon := Screen.MonitorFromPoint(Point(AX, AY));
  if Assigned(Mon) then
    MonRect := Mon.WorkareaRect
  else
    MonRect := Rect(0, 0, Screen.Width, Screen.Height);

  if AX + maxW > MonRect.Right then
    AX := AX - maxW;
  if AX < MonRect.Left then AX := MonRect.Left;
  if AY + h > MonRect.Bottom then
    AY := MonRect.Bottom - h;
  if AY < MonRect.Top then AY := MonRect.Top;

  Left := AX;
  Top := AY;
  Width := maxW;
  Height := h;
end;

destructor TMenuForm.Destroy;
begin
  CloseChildMenu;
  inherited Destroy;
end;

function TMenuForm.ItemYPos(AIndex: Integer): Integer;
var
  i: Integer;
begin
  Result := 8;
  for i := 0 to AIndex - 1 do
  begin
    if FItems[i].FIsSeparator then
      Inc(Result, 9)
    else
      Inc(Result, 48);
  end;
end;

function TMenuForm.FindNextItem(AFrom, ADir: Integer): Integer;
var
  idx: Integer;
begin
  Result := AFrom;
  idx := AFrom + ADir;
  while (idx >= 0) and (idx < FItems.Count) do
  begin
    if not FItems[idx].FIsSeparator then
    begin
      Result := idx;
      Exit;
    end;
    Inc(idx, ADir);
  end;
end;

function TMenuForm.RootForm: TMenuForm;
begin
  Result := Self;
  while Result.FParentMenuForm <> nil do
    Result := Result.FParentMenuForm;
end;

function TMenuForm.IsInChain(AForm: TCustomForm): Boolean;
var
  f: TMenuForm;
begin
  if not (AForm is TMenuForm) then Exit(False);
  f := RootForm;
  while f <> nil do
  begin
    if f = AForm then Exit(True);
    f := f.FChildMenuForm;
  end;
  Result := False;
end;

procedure TMenuForm.ShowSubMenu(AIndex: Integer);
var
  item: TFRMaterialMenuItem;
  subX, subY: Integer;
  Mon: TMonitor;
  MonRect: TRect;
begin
  if AIndex = FSubMenuIndex then Exit;

  CloseChildMenu;
  FSubMenuIndex := AIndex;

  if (AIndex < 0) or (AIndex >= FItems.Count) then Exit;

  item := FItems[AIndex];
  if not item.HasSubItems then Exit;

  subX := Self.Left + Self.Width - 4;
  subY := Self.Top + ItemYPos(AIndex);

  { Flip to left if overflows on current monitor }
  Mon := Screen.MonitorFromPoint(Point(subX, subY));
  if Assigned(Mon) then
    MonRect := Mon.WorkareaRect
  else
    MonRect := Rect(0, 0, Screen.Width, Screen.Height);

  if subX + FMinWidth > MonRect.Right then
    subX := Self.Left - FMinWidth + 4;

  FChildMenuForm := TMenuForm.CreateMenu(item.FSubItems, FMinWidth,
    FRootMenu, Self, FSubMenuTrigger, subX, subY);
  FChildMenuForm.Show;
end;

procedure TMenuForm.CloseChildMenu;
begin
  if Assigned(FChildMenuForm) then
  begin
    { Flag prevents FormDeactivate from closing the entire chain during
      the transient focus change caused by the child form being released. }
    RootForm.FClosingChild := True;
    try
      FChildMenuForm.CloseChildMenu;
      FChildMenuForm.Release;
      FChildMenuForm := nil;
      if Visible and HandleAllocated then
        SetFocus;
    finally
      RootForm.FClosingChild := False;
    end;
  end;
  FSubMenuIndex := -1;
end;

procedure TMenuForm.CloseAll;
var
  root: TMenuForm;
begin
  root := RootForm;
  root.CloseChildMenu;
  if Assigned(root.FRootMenu) then
    root.FRootMenu.FRootForm := nil;
  root.Release;
end;

procedure TMenuForm.HoverTimerFire(Sender: TObject);
begin
  FHoverTimer.Enabled := False;
  if FSubMenuTrigger <> smtHover then Exit;

  if (FHoverIndex >= 0) and (FHoverIndex < FItems.Count) then
  begin
    if FItems[FHoverIndex].HasSubItems then
      ShowSubMenu(FHoverIndex)
    else
      CloseChildMenu;
  end
  else
    CloseChildMenu;
end;

procedure TMenuForm.Paint;
var
  ABmp: TBGRABitmap;
  i, yPos: Integer;
  item: TFRMaterialMenuItem;
  aRect: TRect;
  iconBmp: TBGRABitmap;
  txtLeft: Integer;
  displayText: string;
  accelIdx: Integer;
  clr: TColor;
  tx, ty, uw, uy: Integer;
begin
  ABmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    MD3FillRoundRect(ABmp, 0, 0, Width - 1, Height - 1, 4, MD3Colors.SurfaceContainer);

  yPos := 8;
  for i := 0 to FItems.Count - 1 do
  begin
    item := FItems[i];
    if item.FIsSeparator then
    begin
      ABmp.DrawLineAntialias(0, yPos + 4, Width, yPos + 4,
        ColorToBGRA(MD3Colors.OutlineVariant), 1);
      Inc(yPos, 9);
      Continue;
    end;

    { hover highlight }
    if (i = FHoverIndex) and item.FEnabled then
      ABmp.FillRect(0, yPos, Width, yPos + 48,
        ColorToBGRA(MD3Colors.PrimaryContainer), dmDrawWithTransparency);

    { icon }
    if item.FIconMode <> imClear then
    begin
      iconBmp := FRGetCachedIcon(item.FIconMode, FRColorToSVGHex(MD3Colors.OnSurfaceVariant), 2.0, 24, 24);
      ABmp.PutImage(12, yPos + (48 - 24) div 2, iconBmp, dmDrawWithTransparency);
    end;

    { submenu arrow indicator "›" }
    if item.HasSubItems then
    begin
      iconBmp := FRGetCachedIcon(imArrowForward, FRColorToSVGHex(MD3Colors.OnSurfaceVariant), 2.0, 20, 20);
      ABmp.PutImage(Width - 28, yPos + (48 - 20) div 2, iconBmp, dmDrawWithTransparency);
    end;

    Inc(yPos, 48);
  end;

  ABmp.Draw(Canvas, 0, 0, False);

  { draw text on Canvas with accelerator underline }
  Canvas.Font.Size := 10;
  Canvas.Font.Style := [];
  yPos := 8;
  for i := 0 to FItems.Count - 1 do
  begin
    item := FItems[i];
    if item.FIsSeparator then
    begin
      Inc(yPos, 9);
      Continue;
    end;

    if item.FIconMode <> imClear then
      txtLeft := 48
    else
      txtLeft := 24;

    aRect := Rect(txtLeft, yPos, Width - 12, yPos + 48);
    if item.HasSubItems then
      aRect.Right := Width - 32; { leave space for arrow }

    displayText := StripAccelChar(item.FCaption);
    accelIdx := AccelCharIndex(item.FCaption);

    if item.FEnabled then
      clr := MD3Colors.OnSurface
    else
      clr := MD3Colors.OnSurface and $00AAAAAA;

    { draw full text }
    MD3DrawText(Canvas, displayText, aRect, clr, taLeftJustify, True);

    { draw underline for accelerator character }
    if accelIdx >= 0 then
    begin
      Canvas.Font.Color := clr;
      tx := aRect.Left + Canvas.TextWidth(Copy(displayText, 1, accelIdx));
      uw := Canvas.TextWidth(displayText[accelIdx + 1]);
      ty := aRect.Top + (aRect.Bottom - aRect.Top - Canvas.TextHeight('A')) div 2;
      uy := ty + Canvas.TextHeight('A') + 1;
      Canvas.Pen.Color := clr;
      Canvas.Pen.Width := 1;
      Canvas.Line(tx, uy, tx + uw, uy);
    end;

    Inc(yPos, 48);
  end;
  finally
    ABmp.Free;
  end;
end;

procedure TMenuForm.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  i, yPos: Integer;
  newHover: Integer;
  item: TFRMaterialMenuItem;
begin
  inherited;
  newHover := -1;
  yPos := 8;
  for i := 0 to FItems.Count - 1 do
  begin
    item := FItems[i];
    if item.FIsSeparator then
    begin
      Inc(yPos, 9);
      Continue;
    end;
    if (Y >= yPos) and (Y < yPos + 48) then
    begin
      newHover := i;
      Break;
    end;
    Inc(yPos, 48);
  end;

  if newHover <> FHoverIndex then
  begin
    FHoverIndex := newHover;
    Invalidate;

    if FSubMenuTrigger = smtHover then
    begin
      FHoverTimer.Enabled := False;
      FHoverTimer.Enabled := True;
    end;
  end;
end;

procedure TMenuForm.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  item: TFRMaterialMenuItem;
  SavedAction: TBasicAction;
  SavedOnClick: TNotifyEvent;
begin
  inherited;
  if (FHoverIndex >= 0) and (FHoverIndex < FItems.Count) then
  begin
    item := FItems[FHoverIndex];
    if not item.FEnabled then Exit;

    { If item has subitems, toggle submenu immediately on click }
    if item.HasSubItems then
    begin
      FHoverTimer.Enabled := False;
      if FSubMenuIndex = FHoverIndex then
        CloseChildMenu
      else
        ShowSubMenu(FHoverIndex);
      Exit;
    end;

    { Normal item — close menu first, then fire action/click }
    SavedAction  := item.FAction;
    SavedOnClick := item.FOnClick;
    CloseAll;
    if Assigned(SavedAction) then
      SavedAction.Execute
    else if Assigned(SavedOnClick) then
      SavedOnClick(item);
  end
  else
    CloseAll;
end;

procedure TMenuForm.KeyDown(var Key: Word; Shift: TShiftState);
var
  item: TFRMaterialMenuItem;
  ch: Char;
  idx: Integer;
begin
  case Key of
    VK_UP:
      begin
        FHoverIndex := FindNextItem(FHoverIndex, -1);
        Invalidate;
        Key := 0;
      end;
    VK_DOWN:
      begin
        if FHoverIndex < 0 then
          FHoverIndex := FindNextItem(-1, 1)
        else
          FHoverIndex := FindNextItem(FHoverIndex, 1);
        Invalidate;
        Key := 0;
      end;
    VK_RIGHT:
      begin
        if (FHoverIndex >= 0) and (FHoverIndex < FItems.Count) and
           FItems[FHoverIndex].HasSubItems then
        begin
          ShowSubMenu(FHoverIndex);
          if Assigned(FChildMenuForm) then
          begin
            FChildMenuForm.FHoverIndex := FChildMenuForm.FindNextItem(-1, 1);
            FChildMenuForm.Invalidate;
            FChildMenuForm.SetFocus;
          end;
        end;
        Key := 0;
      end;
    VK_LEFT:
      begin
        if Assigned(FParentMenuForm) then
        begin
          FParentMenuForm.CloseChildMenu;
          FParentMenuForm.SetFocus;
        end;
        Key := 0;
      end;
    VK_RETURN:
      begin
        if (FHoverIndex >= 0) and (FHoverIndex < FItems.Count) then
        begin
          item := FItems[FHoverIndex];
          if item.FEnabled then
          begin
            if item.HasSubItems then
            begin
              ShowSubMenu(FHoverIndex);
              if Assigned(FChildMenuForm) then
              begin
                FChildMenuForm.FHoverIndex := FChildMenuForm.FindNextItem(-1, 1);
                FChildMenuForm.Invalidate;
                FChildMenuForm.SetFocus;
              end;
            end
            else
            begin
              CloseAll;
              item.ExecuteAction;
            end;
          end;
        end;
        Key := 0;
      end;
    VK_ESCAPE:
      begin
        if Assigned(FParentMenuForm) then
        begin
          FParentMenuForm.CloseChildMenu;
          FParentMenuForm.SetFocus;
        end
        else
          CloseAll;
        Key := 0;
      end;
  else
    { Accelerator key: match letter to '&X' in captions }
    if (Key >= VK_A) and (Key <= VK_Z) then
    begin
      ch := Chr(Key); { VK_A..VK_Z map to 'A'..'Z' }
      for idx := 0 to FItems.Count - 1 do
      begin
        if FItems[idx].FIsSeparator then Continue;
        if not FItems[idx].FEnabled then Continue;
        if ExtractAccelChar(FItems[idx].FCaption) = ch then
        begin
          FHoverIndex := idx;
          Invalidate;
          if FItems[idx].HasSubItems then
          begin
            ShowSubMenu(idx);
            if Assigned(FChildMenuForm) then
            begin
              FChildMenuForm.FHoverIndex := FChildMenuForm.FindNextItem(-1, 1);
              FChildMenuForm.Invalidate;
              FChildMenuForm.SetFocus;
            end;
          end
          else
          begin
            CloseAll;
            FItems[idx].ExecuteAction;
          end;
          Key := 0;
          Break;
        end;
      end;
    end;
  end;
  if Key <> 0 then
    inherited;
end;

procedure TMenuForm.FormDeactivate(Sender: TObject);
var
  root: TMenuForm;
begin
  { Ignore transient deactivation caused by child submenu closing }
  if FClosingChild then Exit;
  { If focus moved to another form in the same menu chain, ignore }
  if IsInChain(Screen.ActiveCustomForm) then Exit;

  { Delegate to root form to close the entire chain }
  root := RootForm;
  if root <> Self then
  begin
    if root.FClosingChild then Exit;
    root.CloseChildMenu;
    if Assigned(root.FRootMenu) then
      root.FRootMenu.FRootForm := nil;
    root.Release;
  end
  else
  begin
    CloseChildMenu;
    if Assigned(FRootMenu) then
      FRootMenu.FRootForm := nil;
    Release;
  end;
end;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialmenu_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialMenu]);
end;

end.

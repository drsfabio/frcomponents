unit FRMaterial3TitleBar;

{$mode objfpc}{$H+}

{ Material Design 3 ? Custom TitleBar + Borderless Form.

  TFRMaterialTitleBar  ? Standalone titlebar component with window buttons,
                          leading icon, title, and custom action buttons.
                          Can be placed on any form.

  TFRMaterialForm      ? Base form class that removes native borders,
                          hosts TFRMaterialTitleBar, handles WM_NCHITTEST
                          for drag/resize/Aero Snap, and manages DWM shadow.

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, Forms, Menus,
  {$IFDEF FPC} LResources, LCLType, LMessages, {$ENDIF}
  BGRABitmap, BGRABitmapTypes,
  FRMaterial3Base, FRMaterialIcons, FRMaterialTheme;

type
  TFRTitleBarButton = (tbbMinimize, tbbMaximize, tbbClose);
  TFRTitleBarButtons = set of TFRTitleBarButton;

  { TFRMaterialTitleBarAction ? single action button for the titlebar }

  TFRMaterialTitleBarAction = class(TCollectionItem)
  private
    FIconMode: TFRIconMode;
    FHint: string;
    FOnClick: TNotifyEvent;
    procedure SetIconMode(AValue: TFRIconMode);
    procedure SetHint(const AValue: string);
  published
    property IconMode: TFRIconMode read FIconMode write SetIconMode;
    property Hint: string read FHint write SetHint;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

  { TFRMaterialTitleBarActions ? collection of action buttons }

  TFRMaterialTitleBarActions = class(TCollection)
  private
    FOwner: TComponent;
    function GetItem(Index: Integer): TFRMaterialTitleBarAction;
    procedure SetItem(Index: Integer; AValue: TFRMaterialTitleBarAction);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TComponent);
    function Add: TFRMaterialTitleBarAction;
    property Items[Index: Integer]: TFRMaterialTitleBarAction read GetItem write SetItem; default;
  end;

  { TFRMaterialTitleBar ? custom MD3 titlebar component }

  TFRMaterialTitleBar = class(TFRMaterial3Control)
  private
    FTitle: string;
    FButtons: TFRTitleBarButtons;
    FLeadingIcon: TFRIconMode;
    FActions: TFRMaterialTitleBarActions;
    FHoveredButton: Integer;   // -1=none, 0=min, 1=max, 2=close
    FPressedButton: Integer;
    FHoveredAction: Integer;   // -1=none, 0..N-1
    FDragging: Boolean;
    FDragStart: TPoint;
    FOnLeadingIconClick: TNotifyEvent;
    procedure SetTitle(const AValue: string);
    procedure SetButtons(AValue: TFRTitleBarButtons);
    procedure SetLeadingIcon(AValue: TFRIconMode);
    procedure SetActions(AValue: TFRMaterialTitleBarActions);
    function GetButtonRect(ABtn: TFRTitleBarButton): TRect;
    function GetActionRect(AIndex: Integer): TRect;
    function GetTitleAreaRight: Integer;
    function ButtonAtPos(X, Y: Integer): Integer;
    function ActionAtPos(X, Y: Integer): Integer;
    procedure DoWindowAction(ABtn: TFRTitleBarButton);
    procedure StartDragMove;
  protected
    function PaintCached(ABmp: TBGRABitmap): Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseLeave; override;
    procedure DblClick; override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function FindParentForm: TCustomForm;
  published
    property Title: string read FTitle write SetTitle;
    property Buttons: TFRTitleBarButtons read FButtons write SetButtons
      default [tbbMinimize, tbbMaximize, tbbClose];
    property LeadingIcon: TFRIconMode read FLeadingIcon write SetLeadingIcon;
    property Actions: TFRMaterialTitleBarActions read FActions write SetActions;
    property OnLeadingIconClick: TNotifyEvent read FOnLeadingIconClick write FOnLeadingIconClick;
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property PopupMenu;
    property ShowHint;
    property ParentShowHint;
    property Visible;
  end;

  { TFRMaterialForm ? borderless form with custom titlebar + resize/snap }

  TFRMaterialForm = class(TForm)
  private
    FTitleBar: TFRMaterialTitleBar;
    FResizeBorderWidth: Integer;
    procedure SetupDWMShadow;
    procedure TitleBarDblClick(Sender: TObject);
  protected
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure DoShow; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateNew(AOwner: TComponent; Num: Integer = 0); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    property TitleBar: TFRMaterialTitleBar read FTitleBar;
  published
    property ResizeBorderWidth: Integer read FResizeBorderWidth write FResizeBorderWidth default 6;
  end;

procedure Register;

{ Enables DWM shadow on a borderless form window (Windows only). }
procedure FRSetupDWMShadow(AForm: TCustomForm);

implementation

uses Math
  {$IFDEF FPC}, LCLIntf{$ENDIF}
  {$IFDEF MSWINDOWS}, Windows{$ENDIF};

function MkRect(ALeft, ATop, ARight, ABottom: Integer): TRect; inline;
begin
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Right := ARight;
  Result.Bottom := ABottom;
end;

function MkPoint(AX, AY: Integer): TPoint; inline;
begin
  Result.X := AX;
  Result.Y := AY;
end;

{$IFDEF MSWINDOWS}
type
  TDWMMargins = record
    cxLeftWidth: Integer;
    cxRightWidth: Integer;
    cyTopHeight: Integer;
    cyBottomHeight: Integer;
  end;

const
  DWMWA_NCRENDERING_POLICY = 2;

  { Hit test constants — defined here, used below outside {$IFDEF} too }

function DwmExtendFrameIntoClientArea(hWnd: HWND; const pMarInset: Pointer): HRESULT;
  stdcall; external 'dwmapi.dll';
function DwmSetWindowAttribute(hWnd: HWND; dwAttribute: DWORD;
  pvAttribute: Pointer; cbAttribute: DWORD): HRESULT;
  stdcall; external 'dwmapi.dll';

const
  { Borderless-window constants }
  FR_SM_CXPADDEDBORDER = 92;  { SM_CXPADDEDBORDERTHICKNESS }
  FR_SUBCLASS_ID = 1;
  FR_MONITOR_NEAREST = 2;     { MONITOR_DEFAULTTONEAREST }

type
  PFRNCCalcSizeParams = ^TFRNCCalcSizeParams;
  TFRNCCalcSizeParams = record
    rgrc: array[0..2] of TRect;
    lppos: Pointer;
  end;

  PFRMinMaxInfo = ^TFRMinMaxInfo;
  TFRMinMaxInfo = record
    ptReserved: TPoint;
    ptMaxSize: TPoint;
    ptMaxPosition: TPoint;
    ptMinTrackSize: TPoint;
    ptMaxTrackSize: TPoint;
  end;

  TFRMonitorInfo = record
    cbSize: DWORD;
    rcMonitor: TRect;
    rcWork: TRect;
    dwFlags: DWORD;
  end;

{ ComCtl32 v6 subclassing — chains safely with LCL's own WindowProc }
function SetWindowSubclass(hWnd: HWND; pfnSubclass: Pointer;
  uIdSubclass: PtrUInt; dwRefData: PtrUInt): BOOL;
  stdcall; external 'comctl32.dll';
function RemoveWindowSubclass(hWnd: HWND; pfnSubclass: Pointer;
  uIdSubclass: PtrUInt): BOOL;
  stdcall; external 'comctl32.dll';
function DefSubclassProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT;
  stdcall; external 'comctl32.dll';
function FRMonitorFromWindow(hWnd: HWND; dwFlags: DWORD): THandle;
  stdcall; external 'user32.dll' name 'MonitorFromWindow';
function FRGetMonitorInfo(hMonitor: THandle; lpmi: Pointer): BOOL;
  stdcall; external 'user32.dll' name 'GetMonitorInfoW';
{$ENDIF}

const
  { Hit test constants (used by BorderHitTest and subclass) }
  HTCLIENT      = 1;
  HTCAPTION     = 2;
  HTLEFT        = 10;
  HTRIGHT       = 11;
  HTTOP         = 12;
  HTTOPLEFT     = 13;
  HTTOPRIGHT    = 14;
  HTBOTTOM      = 15;
  HTBOTTOMLEFT  = 16;
  HTBOTTOMRIGHT = 17;

  TITLEBAR_HEIGHT = 40;
  BTN_WIDTH = 46;
  ICON_SIZE = 18;
  PAD_H = 12;
  ACTION_WIDTH = 40;

  // Internal button indices for hover/press tracking
  BTN_NONE  = -1;
  BTN_MIN   = 0;
  BTN_MAX   = 1;
  BTN_CLOSE = 2;

{ ?? TFRMaterialTitleBarAction ?? }

procedure TFRMaterialTitleBarAction.SetIconMode(AValue: TFRIconMode);
begin
  if FIconMode <> AValue then
  begin
    FIconMode := AValue;
    Changed(False);
  end;
end;

procedure TFRMaterialTitleBarAction.SetHint(const AValue: string);
begin
  if FHint <> AValue then
  begin
    FHint := AValue;
    Changed(False);
  end;
end;

{ ?? TFRMaterialTitleBarActions ?? }

constructor TFRMaterialTitleBarActions.Create(AOwner: TComponent);
begin
  inherited Create(TFRMaterialTitleBarAction);
  FOwner := AOwner;
end;

function TFRMaterialTitleBarActions.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TFRMaterialTitleBarActions.GetItem(Index: Integer): TFRMaterialTitleBarAction;
begin
  Result := TFRMaterialTitleBarAction(inherited Items[Index]);
end;

procedure TFRMaterialTitleBarActions.SetItem(Index: Integer; AValue: TFRMaterialTitleBarAction);
begin
  inherited Items[Index] := AValue;
end;

function TFRMaterialTitleBarActions.Add: TFRMaterialTitleBarAction;
begin
  Result := TFRMaterialTitleBarAction(inherited Add);
end;

procedure TFRMaterialTitleBarActions.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOwner) and (FOwner is TControl) then
  begin
    if FOwner is TFRMaterialTitleBar then
      TFRMaterialTitleBar(FOwner).InvalidatePaintCache;
    TControl(FOwner).Invalidate;
  end;
end;

{ ?? TFRMaterialTitleBar ?? }

constructor TFRMaterialTitleBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTitle := '';
  FButtons := [tbbMinimize, tbbMaximize, tbbClose];
  FLeadingIcon := imClear;
  FActions := TFRMaterialTitleBarActions.Create(Self);
  FHoveredButton := BTN_NONE;
  FPressedButton := BTN_NONE;
  FHoveredAction := -1;
  FDragging := False;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, CX, CY);
  Align := alTop;
  ControlStyle := ControlStyle - [csClickEvents]; // we handle clicks manually
end;

destructor TFRMaterialTitleBar.Destroy;
begin
  FreeAndNil(FActions);
  inherited Destroy;
end;

class function TFRMaterialTitleBar.GetControlClassDefaultSize: TSize;
begin
  Result.CX := 600;
  Result.CY := TITLEBAR_HEIGHT;
end;

function TFRMaterialTitleBar.FindParentForm: TCustomForm;
var
  p: TWinControl;
begin
  Result := nil;
  p := Parent;
  while Assigned(p) do
  begin
    if p is TCustomForm then
      Exit(TCustomForm(p));
    p := p.Parent;
  end;
end;

procedure TFRMaterialTitleBar.SetTitle(const AValue: string);
begin
  if FTitle <> AValue then
  begin
    FTitle := AValue;
    InvalidatePaintCache;
    Invalidate;
  end;
end;

procedure TFRMaterialTitleBar.SetButtons(AValue: TFRTitleBarButtons);
begin
  if FButtons <> AValue then
  begin
    FButtons := AValue;
    InvalidatePaintCache;
    Invalidate;
  end;
end;

procedure TFRMaterialTitleBar.SetLeadingIcon(AValue: TFRIconMode);
begin
  if FLeadingIcon <> AValue then
  begin
    FLeadingIcon := AValue;
    InvalidatePaintCache;
    Invalidate;
  end;
end;

procedure TFRMaterialTitleBar.SetActions(AValue: TFRMaterialTitleBarActions);
begin
  FActions.Assign(AValue);
end;

function TFRMaterialTitleBar.GetButtonRect(ABtn: TFRTitleBarButton): TRect;
var
  x: Integer;
begin
  Result := MkRect(0, 0, 0, 0);
  x := Width;

  { Layout from right: Close | Maximize | Minimize }
  if tbbClose in FButtons then
  begin
    Dec(x, BTN_WIDTH);
    if ABtn = tbbClose then
      Exit(MkRect(x, 0, x + BTN_WIDTH, Height));
  end;
  if tbbMaximize in FButtons then
  begin
    Dec(x, BTN_WIDTH);
    if ABtn = tbbMaximize then
      Exit(MkRect(x, 0, x + BTN_WIDTH, Height));
  end;
  if tbbMinimize in FButtons then
  begin
    Dec(x, BTN_WIDTH);
    if ABtn = tbbMinimize then
      Exit(MkRect(x, 0, x + BTN_WIDTH, Height));
  end;
end;

function TFRMaterialTitleBar.GetActionRect(AIndex: Integer): TRect;
var
  x, i, btnCount: Integer;
begin
  Result := MkRect(0, 0, 0, 0);
  if not Assigned(FActions) then Exit;
  if (AIndex < 0) or (AIndex >= FActions.Count) then Exit;

  { Actions sit left of window buttons }
  x := Width;
  btnCount := 0;
  if tbbClose in FButtons then Inc(btnCount);
  if tbbMaximize in FButtons then Inc(btnCount);
  if tbbMinimize in FButtons then Inc(btnCount);
  Dec(x, btnCount * BTN_WIDTH);

  { Actions laid right-to-left }
  for i := FActions.Count - 1 downto 0 do
  begin
    Dec(x, ACTION_WIDTH);
    if i = AIndex then
      Exit(MkRect(x, 0, x + ACTION_WIDTH, Height));
  end;
end;

function TFRMaterialTitleBar.GetTitleAreaRight: Integer;
var
  btnCount: Integer;
begin
  Result := Width;
  btnCount := 0;
  if tbbClose in FButtons then Inc(btnCount);
  if tbbMaximize in FButtons then Inc(btnCount);
  if tbbMinimize in FButtons then Inc(btnCount);
  Dec(Result, btnCount * BTN_WIDTH);
  if Assigned(FActions) then
    Dec(Result, FActions.Count * ACTION_WIDTH);
  Dec(Result, 8); // gap
end;

function TFRMaterialTitleBar.ButtonAtPos(X, Y: Integer): Integer;
var
  btn: TFRTitleBarButton;
  r: TRect;
begin
  Result := BTN_NONE;
  for btn := Low(TFRTitleBarButton) to High(TFRTitleBarButton) do
  begin
    if not (btn in FButtons) then Continue;
    r := GetButtonRect(btn);
    if (r.Right > r.Left) and PtInRect(r, MkPoint(X, Y)) then
      Exit(Ord(btn));
  end;
end;

function TFRMaterialTitleBar.ActionAtPos(X, Y: Integer): Integer;
var
  i: Integer;
  r: TRect;
begin
  Result := -1;
  if not Assigned(FActions) then Exit;
  for i := 0 to FActions.Count - 1 do
  begin
    r := GetActionRect(i);
    if (r.Right > r.Left) and PtInRect(r, MkPoint(X, Y)) then
      Exit(i);
  end;
end;

procedure TFRMaterialTitleBar.DoWindowAction(ABtn: TFRTitleBarButton);
var
  frm: TCustomForm;
begin
  frm := FindParentForm;
  if not Assigned(frm) then Exit;

  case ABtn of
    tbbMinimize:
      begin
        {$IFDEF MSWINDOWS}
        { SC_MINIMIZE animates to taskbar even without WS_CAPTION }
        if frm.HandleAllocated then
          SendMessage(frm.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0)
        else
        {$ENDIF}
          Application.Minimize;
      end;
    tbbMaximize:
      begin
        if frm is TForm then
        begin
          if TForm(frm).WindowState = wsMaximized then
            TForm(frm).WindowState := wsNormal
          else
            TForm(frm).WindowState := wsMaximized;
        end;
      end;
    tbbClose:
      frm.Close;
  end;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialTitleBar.StartDragMove;
{$IFDEF MSWINDOWS}
var
  frm: TCustomForm;
{$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  frm := FindParentForm;
  if Assigned(frm) and frm.HandleAllocated then
  begin
    ReleaseCapture;
    SendMessage(frm.Handle, WM_SYSCOMMAND, SC_MOVE or HTCAPTION, 0);
  end;
  {$ENDIF}
end;

function TFRMaterialTitleBar.PaintCached(ABmp: TBGRABitmap): Boolean;
var
  r: TRect;
  iconBmp: TBGRABitmap;
  titleLeft: Integer;
  btnIdx: Integer;
  bgColor, txtColor, btnBg, btnFg: TBGRAPixel;
  cx, cy: Integer;
  frm: TCustomForm;
  isMaximized: Boolean;
  actIdx: Integer;
  icoSz, icoY: Integer;
begin
  Result := True;
  bgColor := ColorToBGRA(MD3Colors.SurfaceContainerHigh);
  txtColor := ColorToBGRA(MD3Colors.OnSurface);

  ABmp.Fill(bgColor);

  titleLeft := PAD_H;
  icoSz := ICON_SIZE;
  icoY := (Height - icoSz) div 2;

  { Leading icon }
  if FLeadingIcon <> imClear then
  begin
    iconBmp := FRGetCachedIcon(FLeadingIcon, FRColorToSVGHex(MD3Colors.OnSurface), 2.0, icoSz, icoSz);
    if Assigned(iconBmp) then
      ABmp.PutImage(PAD_H, icoY, iconBmp, dmDrawWithTransparency);
    titleLeft := PAD_H + icoSz + 12;
  end;

  { Window buttons: Min, Max, Close (right to left) }
  for btnIdx := BTN_CLOSE downto BTN_MIN do
  begin
    if not (TFRTitleBarButton(btnIdx) in FButtons) then Continue;

    r := GetButtonRect(TFRTitleBarButton(btnIdx));
    if r.Right <= r.Left then Continue;

    { Button hover/press background }
    if btnIdx = FPressedButton then
    begin
      if btnIdx = BTN_CLOSE then
        btnBg := BGRA(232, 17, 35, 200)
      else
        btnBg := ColorToBGRA(MD3Blend(MD3Colors.SurfaceContainerHigh,
                   MD3Colors.OnSurface, 30));
    end
    else if btnIdx = FHoveredButton then
    begin
      if btnIdx = BTN_CLOSE then
        btnBg := BGRA(232, 17, 35, 160)
      else
        btnBg := ColorToBGRA(MD3Blend(MD3Colors.SurfaceContainerHigh,
                   MD3Colors.OnSurface, 20));
    end
    else
      btnBg := bgColor;

    ABmp.FillRect(r.Left, r.Top, r.Right, r.Bottom, btnBg, dmSet);

    { Button icon color: white on red (Close hovered/pressed), or OnSurface }
    if (btnIdx = BTN_CLOSE) and
       ((btnIdx = FHoveredButton) or (btnIdx = FPressedButton)) then
      btnFg := BGRA(255, 255, 255)
    else
      btnFg := txtColor;

    cx := (r.Left + r.Right) div 2;
    cy := (r.Top + r.Bottom) div 2;

    case TFRTitleBarButton(btnIdx) of
      tbbMinimize:
        { Horizontal line }
        ABmp.DrawLineAntialias(cx - 5, cy, cx + 5, cy, btnFg, 1.2);
      tbbMaximize:
        begin
          frm := FindParentForm;
          isMaximized := Assigned(frm) and (frm is TForm) and
                         (TForm(frm).WindowState = wsMaximized);
          if isMaximized then
          begin
            { Restore icon: two overlapping rectangles }
            ABmp.RectangleAntialias(cx - 2, cy - 5, cx + 5, cy + 2, btnFg, 1.0);
            ABmp.FillRect(cx - 4, cy - 2, cx + 3, cy + 5, btnBg, dmSet);
            ABmp.RectangleAntialias(cx - 4, cy - 2, cx + 3, cy + 5, btnFg, 1.0);
          end
          else
            { Maximize icon: single rectangle }
            ABmp.RectangleAntialias(cx - 5, cy - 4, cx + 5, cy + 4, btnFg, 1.2);
        end;
      tbbClose:
        begin
          { X icon }
          ABmp.DrawLineAntialias(cx - 5, cy - 5, cx + 5, cy + 5, btnFg, 1.2);
          ABmp.DrawLineAntialias(cx + 5, cy - 5, cx - 5, cy + 5, btnFg, 1.2);
        end;
    end;
  end;

  { Custom action buttons (left of window buttons) }
  if Assigned(FActions) then
    for actIdx := 0 to FActions.Count - 1 do
    begin
      r := GetActionRect(actIdx);
      if r.Right <= r.Left then Continue;

      { Action hover background }
      if actIdx = FHoveredAction then
        ABmp.FillRect(r.Left, r.Top, r.Right, r.Bottom,
          ColorToBGRA(MD3Blend(MD3Colors.SurfaceContainerHigh,
            MD3Colors.OnSurface, 20)), dmSet);

      { Action icon }
      iconBmp := FRGetCachedIcon(FActions[actIdx].IconMode,
        FRColorToSVGHex(MD3Colors.OnSurfaceVariant), 2.0, icoSz, icoSz);
      if Assigned(iconBmp) then
        ABmp.PutImage(r.Left + (ACTION_WIDTH - icoSz) div 2, icoY,
          iconBmp, dmDrawWithTransparency);
    end;

  { Title text }
  if FTitle <> '' then
  begin
    r := MkRect(titleLeft, 0, GetTitleAreaRight, Height);
    MD3DrawTextBGRA(ABmp, FTitle, r, MD3Colors.OnSurface, taLeftJustify, True);
  end;
end;

procedure TFRMaterialTitleBar.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  btn, act: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button <> mbLeft then Exit;

  btn := ButtonAtPos(X, Y);
  if btn <> BTN_NONE then
  begin
    FPressedButton := btn;
    InvalidatePaintCache;
    Invalidate;
    Exit;
  end;

  act := ActionAtPos(X, Y);
  if act >= 0 then
    Exit;

  { Check leading icon click }
  if (FLeadingIcon <> imClear) and (X < PAD_H + ICON_SIZE + 12) then
  begin
    if Assigned(FOnLeadingIconClick) then
      FOnLeadingIconClick(Self);
    Exit;
  end;

  { Start drag-move on title area }
  if not (csDesigning in ComponentState) then
    StartDragMove;
end;

procedure TFRMaterialTitleBar.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  btn, act: Integer;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button <> mbLeft then Exit;

  btn := ButtonAtPos(X, Y);
  if (FPressedButton <> BTN_NONE) and (btn = FPressedButton) then
    DoWindowAction(TFRTitleBarButton(FPressedButton));

  act := ActionAtPos(X, Y);
  if (act >= 0) and Assigned(FActions) and (act < FActions.Count) then
    if Assigned(FActions[act].OnClick) then
      FActions[act].OnClick(FActions[act]);

  FPressedButton := BTN_NONE;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterialTitleBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  btn, act: Integer;
  bChanged: Boolean;
begin
  inherited MouseMove(Shift, X, Y);
  bChanged := False;

  btn := ButtonAtPos(X, Y);
  if btn <> FHoveredButton then
  begin
    FHoveredButton := btn;
    bChanged := True;
  end;

  act := ActionAtPos(X, Y);
  if act <> FHoveredAction then
  begin
    FHoveredAction := act;
    bChanged := True;
  end;

  if bChanged then
  begin
    InvalidatePaintCache;
    Invalidate;
  end;
end;

procedure TFRMaterialTitleBar.MouseLeave;
begin
  inherited MouseLeave;
  if (FHoveredButton <> BTN_NONE) or (FPressedButton <> BTN_NONE) or
     (FHoveredAction >= 0) then
  begin
    FHoveredButton := BTN_NONE;
    FPressedButton := BTN_NONE;
    FHoveredAction := -1;
    InvalidatePaintCache;
    Invalidate;
  end;
end;

procedure TFRMaterialTitleBar.DblClick;
var
  pt: TPoint;
  btn: Integer;
begin
  inherited DblClick;
  pt := ScreenToClient(Mouse.CursorPos);
  btn := ButtonAtPos(pt.X, pt.Y);
  if (btn = BTN_NONE) and (ActionAtPos(pt.X, pt.Y) < 0) then
  begin
    { Double-click on title area: toggle maximize }
    if tbbMaximize in FButtons then
      DoWindowAction(tbbMaximize);
  end;
end;

{$IFDEF MSWINDOWS}
{ ComCtl32 subclass: handles WM_NCCALCSIZE (zeros NC area) and
  WM_GETMINMAXINFO (constrains maximize to work area).
  NOTE: WM_NCHITTEST never reaches subclass or LCL handlers when
  WS_THICKFRAME is present — resize is handled via BorderWidth +
  MouseMove/MouseDown instead. }
function FRMaterialFormSubclassProc(hWnd: HWND; uMsg: UINT; wp: WPARAM;
  lp: LPARAM; {%H-}uIdSubclass: PtrUInt; {%H-}dwRefData: PtrUInt): LRESULT; stdcall;
var
  MMI: PFRMinMaxInfo;
  Mon: THandle;
  MI: TFRMonitorInfo;
begin
  case uMsg of
    WM_NCCALCSIZE:
      if wp <> 0 then
      begin
        Result := 0;
        Exit;
      end;

    WM_GETMINMAXINFO:
      begin
        MMI := PFRMinMaxInfo(lp);
        Mon := FRMonitorFromWindow(hWnd, FR_MONITOR_NEAREST);
        FillChar(MI, SizeOf(MI), 0);
        MI.cbSize := SizeOf(MI);
        if FRGetMonitorInfo(Mon, @MI) then
        begin
          MMI^.ptMaxPosition.X := MI.rcWork.Left - MI.rcMonitor.Left;
          MMI^.ptMaxPosition.Y := MI.rcWork.Top  - MI.rcMonitor.Top;
          MMI^.ptMaxSize.X     := MI.rcWork.Right  - MI.rcWork.Left;
          MMI^.ptMaxSize.Y     := MI.rcWork.Bottom - MI.rcWork.Top;
        end;
        Result := 0;
        Exit;
      end;

    WM_NCACTIVATE:
      begin
        Result := 1;
        Exit;
      end;
  end;
  Result := DefSubclassProc(hWnd, uMsg, wp, lp);
end;
{$ENDIF}

{ ?? TFRMaterialForm ?? }

constructor TFRMaterialForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FResizeBorderWidth := 6;
end;

constructor TFRMaterialForm.CreateNew(AOwner: TComponent; Num: Integer);
begin
  inherited CreateNew(AOwner, Num);
  FResizeBorderWidth := 6;
  { bsSizeable preserves WS_OVERLAPPEDWINDOW (resize, minimize, maximize,
    Aero Snap). CreateWnd removes WS_CAPTION to hide the native titlebar. }
  BorderStyle := bsSizeable;
  Color := MD3Colors.Surface;
  FTitleBar := TFRMaterialTitleBar.Create(Self);
  FTitleBar.Parent := Self;
  FTitleBar.Align := alTop;
  FTitleBar.Height := TITLEBAR_HEIGHT;
  FTitleBar.Title := Caption;
end;

destructor TFRMaterialForm.Destroy;
begin
  { TitleBar is owned by Self ? freed automatically by inherited }
  FTitleBar := nil;
  inherited Destroy;
end;

procedure TFRMaterialForm.AfterConstruction;
begin
  inherited AfterConstruction;
  Color := MD3Colors.Surface;
  { TitleBar already created in CreateNew }
end;

procedure TFRMaterialForm.CreateWnd;
{$IFDEF MSWINDOWS}
var
  Style: LONG_PTR;
{$ENDIF}
begin
  inherited CreateWnd;
  {$IFDEF MSWINDOWS}
  if HandleAllocated then
  begin
    { Remove WS_CAPTION to hide native titlebar.  KEEP WS_THICKFRAME —
      it gives us DWM rounded corners (Win11), native resize cursors,
      and Aero Snap support.  The visible thick-frame border is eliminated
      by the WM_NCCALCSIZE handler in the subclass below. }
    Style := GetWindowLongPtr(Handle, GWL_STYLE);
    Style := (Style and not WS_CAPTION)
             or WS_THICKFRAME or WS_MINIMIZEBOX or WS_MAXIMIZEBOX or WS_SYSMENU;
    SetWindowLongPtr(Handle, GWL_STYLE, Style);

    { Install ComCtl32 subclass — handles WM_NCCALCSIZE + WM_GETMINMAXINFO }
    if not SetWindowSubclass(Handle, @FRMaterialFormSubclassProc,
      FR_SUBCLASS_ID, PtrUInt(Self)) then
    begin
      if Assigned(FTitleBar) then
        FTitleBar.Title := 'SUBCLASS FAILED';
    end
    else
    begin
      if Assigned(FTitleBar) then
        FTitleBar.Title := 'SUBCLASS OK';
    end;

    SetWindowPos(Handle, 0, 0, 0, 0, 0,
      SWP_FRAMECHANGED or SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER);
  end;
  {$ENDIF}
  SetupDWMShadow;
end;

procedure TFRMaterialForm.DestroyWnd;
begin
  {$IFDEF MSWINDOWS}
  if HandleAllocated then
    RemoveWindowSubclass(Handle, @FRMaterialFormSubclassProc, FR_SUBCLASS_ID);
  {$ENDIF}
  inherited DestroyWnd;
end;

procedure TFRMaterialForm.DoShow;
begin
  inherited DoShow;
  if Assigned(FTitleBar) then
    FTitleBar.Title := Caption;
end;

procedure TFRMaterialForm.Resize;
begin
  inherited Resize;
  if Assigned(FTitleBar) then
  begin
    FTitleBar.InvalidatePaintCache;
    FTitleBar.Invalidate;
  end;
end;

procedure TFRMaterialForm.SetupDWMShadow;
{$IFDEF MSWINDOWS}
var
  Margins: TDWMMargins;
begin
  if not HandleAllocated then Exit;
  try
    { 1px on all sides activates DWM shadow + rounded corners.
      Child controls paint over these pixels, so no glass shows. }
    Margins.cxLeftWidth := 1;
    Margins.cxRightWidth := 1;
    Margins.cyTopHeight := 1;
    Margins.cyBottomHeight := 1;
    DwmExtendFrameIntoClientArea(Handle, @Margins);
  except
  end;
end;
{$ELSE}
begin
end;
{$ENDIF}

procedure TFRMaterialForm.TitleBarDblClick(Sender: TObject);
begin
  if WindowState = wsMaximized then
    WindowState := wsNormal
  else
    WindowState := wsMaximized;
end;

{ ?? Registration ?? }

procedure Register;
begin
  RegisterComponents('Material Design 3', [TFRMaterialTitleBar]);
end;

procedure FRSetupDWMShadow(AForm: TCustomForm);
{$IFDEF MSWINDOWS}
var
  Margins: TDWMMargins;
begin
  if not Assigned(AForm) then Exit;
  if not AForm.HandleAllocated then Exit;
  try
    Margins.cxLeftWidth := 1;
    Margins.cxRightWidth := 1;
    Margins.cyTopHeight := 1;
    Margins.cyBottomHeight := 1;
    DwmExtendFrameIntoClientArea(AForm.Handle, @Margins);
  except
  end;
end;
{$ELSE}
begin
end;
{$ENDIF}

end.

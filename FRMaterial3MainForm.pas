unit FRMaterial3MainForm;

{$mode objfpc}{$H+}

{ Material Design 3 — Main Application Form.

  TFRMaterialMainForm — Borderless main form with built-in MD3 shell.
    Provides out-of-the-box:
      • Borderless window with DWM shadow + Aero Snap (resize/maximize)
      • TFRMaterialAppBar as custom titlebar (with window controls)
      • TFRMaterialNavRail for module navigation
      • TFRMaterialSearchEdit for global search
      • TFRMaterialPageControl with tab support
      • TFRMaterialSnackbar for notifications
      • TStatusBar with MD3 colors
      • Home screen with greeting, filter chips, and card grid
      • FAB (Floating Action Button) for quick search
      • User menu with virtual methods
      • Full IFRMaterialComponent support (theme auto-update)

  Usage (minimal):

    TMyMain = class(TFRMaterialMainForm)
    protected
      procedure RegisterModules; override;
      procedure RegisterUserMenu; override;    // optional
      procedure DoSearch(const AText: string); override;
    end;

    procedure TMyMain.RegisterModules;
    begin
      AddModule('Estoque',    imWarehouse,    MenuEstoque);
      AddModule('Vendas',     imShoppingCart, MenuVendas);
      AddModule('Financeiro', imAccountBalance, MenuFinanceiro);
    end;

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Types, Forms, Controls, Graphics, Menus, StdCtrls, ExtCtrls,
  ComCtrls, ActnList, Generics.Collections,
  {$IFDEF FPC} LCLType, LCLIntf, {$ENDIF}
  FRMaterial3AppBar, FRMaterial3Nav, FRMaterial3Menu, FRMaterial3Base,
  FRMaterial3PageControl, FRMaterial3Card, FRMaterial3FAB, FRMaterial3Chip,
  FRMaterial3Divider, FRMaterial3GridPanel, FRMaterial3Snackbar,
  FRMaterialSearchEdit, FRMaterialTheme, FRMaterialIcons,
  FRMaterialThemeManager, FRMaterial3TitleBar;

type

  { ── TFRMaterialMainForm ── }

  TFRMaterialMainForm = class(TForm, IFRMaterialComponent)
  private
    { Infrastructure }
    FThemeManager: TFRMaterialThemeManager;
    FMaterialReady: Boolean;

    { Shell components }
    FPnFundo: TPanel;
    FAppBar: TFRMaterialAppBar;
    FNavRail: TFRMaterialNavRail;
    FSearchPanel: TPanel;
    FSearchEdit: TFRMaterialSearchEdit;
    FPageControl: TFRMaterialPageControl;
    FStatusBar: TStatusBar;
    FSnackbar: TFRMaterialSnackbar;
    FUserMenu: TFRMaterialMenu;

    { Home screen }
    FHomePage: TFRMaterialTabPage;
    FMainScroll: TScrollBox;
    FPnGreeting: TPanel;
    FPnChips: TPanel;
    FGreetingLabel: TLabel;
    FDateLabel: TLabel;
    FSectionLabel: TLabel;
    FCardGrid: TFRMaterialGridPanel;
    FFab: TFRMaterialFAB;
    FChipRecentes: TFRMaterialChip;
    FChipFavoritas: TFRMaterialChip;
    FChipTodas: TFRMaterialChip;
    FHomeFilter: Integer;

    { Internal handlers }
    procedure DoAppBarNavClick(Sender: TObject);
    procedure DoSearchActionClick(Sender: TObject);
    procedure DoUserActionClick(Sender: TObject);
    procedure DoWindowMinimizeClick(Sender: TObject);
    procedure DoWindowMaximizeClick(Sender: TObject);
    procedure DoWindowCloseClick(Sender: TObject);
    procedure DoSearchPerformed(Sender: TObject; const ASearchText: string);
    procedure DoNavRailChange(Sender: TObject);
    procedure DoChipClick(Sender: TObject);
    procedure DoCardClick(Sender: TObject);
    procedure DoFabClick(Sender: TObject);
    procedure DoPageCloseTab(Sender: TObject; APage: TFRMaterialTabPage;
      var AllowClose: Boolean);
    procedure DoUserMenuAlterarSenha(Sender: TObject);
    procedure DoUserMenuBloquear(Sender: TObject);
    procedure DoUserMenuDesconectar(Sender: TObject);
    procedure DoUserMenuSair(Sender: TObject);

    { Internal builders }
    procedure BuildShell;
    procedure BuildHomeScreen;
    procedure BuildUserMenu;
    function ConvertMenuToMaterial(AMenuItem: TMenuItem): TFRMaterialMenu;
    function GetGreeting: string;

  protected
    { Borderless window }
    procedure CreateWnd; override;
    procedure DestroyWnd; override;

    { ── Override points for subclasses ── }

    { Called once during BuildShell. Add modules here with AddModule(). }
    procedure RegisterModules; virtual; abstract;

    { Called once during BuildShell. Override to add custom user menu items.
      Default creates: Alterar Senha, Bloquear, Desconectar, Sair. }
    procedure RegisterUserMenu; virtual;

    { Called once during BuildShell. Override to add custom AppBar actions
      (search, refresh, user are already added by default). }
    procedure RegisterAppBarActions; virtual;

    { Called when search is performed. Override to implement global search. }
    procedure DoSearch(const AText: string); virtual;

    { Called to populate home screen cards. Override to provide card data.
      Default implementation does nothing (empty home). }
    procedure PopulateCards; virtual;

    { Called when a card is clicked. ATag holds the card's Tag value. }
    procedure CardClicked(ATag: Integer); virtual;

    { Called when the home screen FAB is clicked.
      Default toggles the search panel. }
    procedure FabClicked; virtual;

    { User menu virtual handlers (override instead of assigning events) }
    procedure OnAlterarSenha; virtual;
    procedure OnBloquearSistema; virtual;
    procedure OnDesconectar; virtual;

    { Called by ApplyTheme. Override to apply additional colors. }
    procedure ApplyMD3Colors; virtual;

    { Map ImageIndex to TFRIconMode. Override to customize. }
    function ImageIndexToIconMode(AIdx: Integer): TFRIconMode; virtual;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    { ── Public API ── }

    { Register a navigation module. Converts TMenuItem tree to
      TFRMaterialMenu automatically. Call from RegisterModules(). }
    procedure AddModule(const ACaption: string; AIcon: TFRIconMode;
      AMenuItems: TMenuItem);

    { Register a navigation module with a pre-built Material menu. }
    procedure AddModule(const ACaption: string; AIcon: TFRIconMode;
      AMenu: TFRMaterialMenu);

    { Display a snackbar notification. }
    procedure ShowSnackbar(const AMsg: string);

    { Build the Material UI shell. Call from FormShow or FormCreate AFTER
      all LFM components are loaded and the ActionList is ready. }
    procedure InitMaterialShell;

    { IFRMaterialComponent }
    procedure ApplyTheme(const AThemeManager: TObject);

    { ── Properties ── }
    property ThemeManager: TFRMaterialThemeManager read FThemeManager;
    property AppBar: TFRMaterialAppBar read FAppBar;
    property NavRail: TFRMaterialNavRail read FNavRail;
    property PageControl: TFRMaterialPageControl read FPageControl;
    property StatusBar: TStatusBar read FStatusBar;
    property Snackbar: TFRMaterialSnackbar read FSnackbar;
    property SearchEdit: TFRMaterialSearchEdit read FSearchEdit;
    property HomePage: TFRMaterialTabPage read FHomePage;
    property CardGrid: TFRMaterialGridPanel read FCardGrid;
    property UserMenu: TFRMaterialMenu read FUserMenu;
    property MaterialReady: Boolean read FMaterialReady;
  end;

implementation

{$IFDEF MSWINDOWS}
uses Windows;
{$ENDIF}

const
  SUBCLASS_ID = 1;
  RESIZE_BORDER = 6;

{$IFDEF MSWINDOWS}
type
  PMinMaxInfoRec = ^TMinMaxInfoRec;
  TMinMaxInfoRec = record
    ptReserved: TPoint;
    ptMaxSize: TPoint;
    ptMaxPosition: TPoint;
    ptMinTrackSize: TPoint;
    ptMaxTrackSize: TPoint;
  end;

{ comctl32 Subclass API }
function SetWindowSubclass(hWnd: THandle; pfnSubclass: Pointer;
  uIdSubclass: PtrUInt; dwRefData: PtrUInt): LongBool; stdcall;
  external 'comctl32.dll' name 'SetWindowSubclass';
function DefSubclassProc(hWnd: THandle; uMsg: Cardinal;
  wP: PtrUInt; lP: PtrInt): PtrInt; stdcall;
  external 'comctl32.dll' name 'DefSubclassProc';
function RemoveWindowSubclass(hWnd: THandle; pfnSubclass: Pointer;
  uIdSubclass: PtrUInt): LongBool; stdcall;
  external 'comctl32.dll' name 'RemoveWindowSubclass';

function User32_GetClientRect(hWnd: THandle; out R: TRect): LongBool; stdcall;
  external 'user32.dll' name 'GetClientRect';
function User32_ClientToScreen(hWnd: THandle; var P: TPoint): LongBool; stdcall;
  external 'user32.dll' name 'ClientToScreen';
function User32_SetWindowPos(hWnd: THandle; hWndInsertAfter: THandle;
  X, Y, cx, cy: Integer; uFlags: Cardinal): LongBool; stdcall;
  external 'user32.dll' name 'SetWindowPos';

function MainFormSubclassProc(hWnd: THandle; uMsg: Cardinal; wP: PtrUInt;
  lP: PtrInt; {%H-}uIdSubclass: PtrUInt; dwRefData: PtrUInt): PtrInt; stdcall;
var
  R: TRect;
  pt, Origin: TPoint;
  w, h: Integer;
  MMI: PMinMaxInfoRec;
  WorkArea: TRect;
begin
  case uMsg of
    WM_NCHITTEST:
    begin
      if IsZoomed(hWnd) then
      begin
        Result := HTCLIENT;
        Exit;
      end;
      User32_GetClientRect(hWnd, R);
      Origin.X := 0;
      Origin.Y := 0;
      User32_ClientToScreen(hWnd, Origin);
      pt.X := SmallInt(Word(lP))        - Origin.X;
      pt.Y := SmallInt(Word(lP shr 16)) - Origin.Y;
      w := R.Right;
      h := R.Bottom;

      if (pt.Y < RESIZE_BORDER) and (pt.X < RESIZE_BORDER) then
        Result := HTTOPLEFT
      else if (pt.Y < RESIZE_BORDER) and (pt.X >= w - RESIZE_BORDER) then
        Result := HTTOPRIGHT
      else if (pt.Y >= h - RESIZE_BORDER) and (pt.X < RESIZE_BORDER) then
        Result := HTBOTTOMLEFT
      else if (pt.Y >= h - RESIZE_BORDER) and (pt.X >= w - RESIZE_BORDER) then
        Result := HTBOTTOMRIGHT
      else if pt.Y < RESIZE_BORDER then
        Result := HTTOP
      else if pt.Y >= h - RESIZE_BORDER then
        Result := HTBOTTOM
      else if pt.X < RESIZE_BORDER then
        Result := HTLEFT
      else if pt.X >= w - RESIZE_BORDER then
        Result := HTRIGHT
      else
        Result := HTCLIENT;
      Exit;
    end;

    WM_SETCURSOR:
    begin
      case Word(lP) of
        HTLEFT, HTRIGHT:
        begin
          SetCursor(LoadCursorW(0, PWideChar(PtrUInt(32644))));
          Result := 1;
          Exit;
        end;
        HTTOP, HTBOTTOM:
        begin
          SetCursor(LoadCursorW(0, PWideChar(PtrUInt(32645))));
          Result := 1;
          Exit;
        end;
        HTTOPLEFT, HTBOTTOMRIGHT:
        begin
          SetCursor(LoadCursorW(0, PWideChar(PtrUInt(32642))));
          Result := 1;
          Exit;
        end;
        HTTOPRIGHT, HTBOTTOMLEFT:
        begin
          SetCursor(LoadCursorW(0, PWideChar(PtrUInt(32643))));
          Result := 1;
          Exit;
        end;
      end;
    end;

    WM_NCCALCSIZE:
    begin
      if wP = 1 then
      begin
        Result := 0;
        Exit;
      end;
    end;

    WM_GETMINMAXINFO:
    begin
      Result := DefSubclassProc(hWnd, uMsg, wP, lP);
      WorkArea := Screen.WorkAreaRect;
      MMI := PMinMaxInfoRec(lP);
      MMI^.ptMaxPosition.X := WorkArea.Left;
      MMI^.ptMaxPosition.Y := WorkArea.Top;
      MMI^.ptMaxSize.X := WorkArea.Right - WorkArea.Left;
      MMI^.ptMaxSize.Y := WorkArea.Bottom - WorkArea.Top;
      Exit;
    end;
  end;

  Result := DefSubclassProc(hWnd, uMsg, wP, lP);
end;
{$ENDIF}

{ ══════════════════════════════════════════════════════════════
  TFRMaterialMainForm
  ══════════════════════════════════════════════════════════════ }

constructor TFRMaterialMainForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMaterialReady := False;
  FHomeFilter := 0;
  FThemeManager := TFRMaterialThemeManager.Create(Self);
end;

destructor TFRMaterialMainForm.Destroy;
begin
  FThemeManager := nil; { owned by Self }
  inherited Destroy;
end;

procedure TFRMaterialMainForm.AfterConstruction;
begin
  inherited AfterConstruction;
  FRMDRegisterComponent(Self);
end;

procedure TFRMaterialMainForm.BeforeDestruction;
begin
  FRMDUnregisterComponent(Self);
  inherited BeforeDestruction;
end;

{ ── Borderless window ── }

procedure TFRMaterialMainForm.CreateWnd;
begin
  inherited CreateWnd;
  {$IFDEF MSWINDOWS}
  if HandleAllocated then
  begin
    SetWindowSubclass(Handle, @MainFormSubclassProc, SUBCLASS_ID, PtrUInt(Self));
    User32_SetWindowPos(Handle, 0, 0, 0, 0, 0,
      SWP_FRAMECHANGED or SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER);
  end;
  {$ENDIF}
end;

procedure TFRMaterialMainForm.DestroyWnd;
begin
  {$IFDEF MSWINDOWS}
  if HandleAllocated then
    RemoveWindowSubclass(Handle, @MainFormSubclassProc, SUBCLASS_ID);
  {$ENDIF}
  inherited DestroyWnd;
end;

{ ── IFRMaterialComponent ── }

procedure TFRMaterialMainForm.ApplyTheme(const AThemeManager: TObject);
begin
  ApplyMD3Colors;
end;

procedure TFRMaterialMainForm.ApplyMD3Colors;
var
  i, j: Integer;
  Lbl: TLabel;
begin
  Color := MD3Colors.Surface;
  if Assigned(FPnFundo) then FPnFundo.Color := MD3Colors.Surface;

  if Assigned(FSearchPanel) then
    FSearchPanel.Color := MD3Colors.SurfaceContainerLow;

  if Assigned(FStatusBar) then
  begin
    FStatusBar.Color      := MD3Colors.SurfaceContainerLow;
    FStatusBar.Font.Color := MD3Colors.OnSurfaceVariant;
  end;

  { Home screen }
  if Assigned(FHomePage)      then FHomePage.Color      := MD3Colors.Surface;
  if Assigned(FMainScroll)    then FMainScroll.Color    := MD3Colors.Surface;
  if Assigned(FCardGrid)      then FCardGrid.Color      := MD3Colors.Surface;
  if Assigned(FPnGreeting)    then FPnGreeting.Color    := MD3Colors.Surface;
  if Assigned(FPnChips)       then FPnChips.Color       := MD3Colors.Surface;
  if Assigned(FGreetingLabel) then FGreetingLabel.Font.Color := MD3Colors.OnSurface;
  if Assigned(FDateLabel)     then FDateLabel.Font.Color     := MD3Colors.OnSurfaceVariant;
  if Assigned(FSectionLabel)  then FSectionLabel.Font.Color  := MD3Colors.OnSurface;

  { Card label colors }
  if Assigned(FCardGrid) then
  begin
    for i := 0 to FCardGrid.ControlCount - 1 do
      if FCardGrid.Controls[i] is TFRMaterialCard then
        for j := 0 to FCardGrid.Controls[i].ComponentCount - 1 do
          if FCardGrid.Controls[i].Components[j] is TLabel then
          begin
            Lbl := TLabel(FCardGrid.Controls[i].Components[j]);
            if fsBold in Lbl.Font.Style then
              Lbl.Font.Color := MD3Colors.OnSurface
            else
              Lbl.Font.Color := MD3Colors.OnSurfaceVariant;
          end;
    FCardGrid.Invalidate;
  end;

  Invalidate;
end;

{ ── Shell Builder ── }

procedure TFRMaterialMainForm.InitMaterialShell;
begin
  if FMaterialReady then Exit;
  FMaterialReady := True;

  BuildShell;
  ApplyMD3Colors;
  FRSetupDWMShadow(Self);
end;

procedure TFRMaterialMainForm.BuildShell;
begin
  { Hide legacy menu if present }
  Menu := nil;

  { ── Background panel ── }
  FPnFundo := TPanel.Create(Self);
  FPnFundo.Parent      := Self;
  FPnFundo.Align       := alClient;
  FPnFundo.BevelOuter  := bvNone;
  FPnFundo.Color       := MD3Colors.Surface;

  { ── AppBar ── }
  FAppBar := TFRMaterialAppBar.Create(Self);
  FAppBar.Parent    := FPnFundo;
  FAppBar.Align     := alTop;
  FAppBar.NavIcon   := imMenu;
  FAppBar.BarSize   := absSmall;
  FAppBar.OnNavClick := @DoAppBarNavClick;

  RegisterAppBarActions;

  { Separator + window controls }
  with TFRMaterialAppBarAction(FAppBar.Actions.Add) do
    IsSeparator := True;

  with TFRMaterialAppBarAction(FAppBar.Actions.Add) do
  begin
    IconMode := imWindowMinimize;
    Hint     := 'Minimizar';
    OnClick  := @DoWindowMinimizeClick;
  end;
  with TFRMaterialAppBarAction(FAppBar.Actions.Add) do
  begin
    if WindowState = wsMaximized then
      IconMode := imWindowRestore
    else
      IconMode := imWindowMaximize;
    Hint     := 'Maximizar/Restaurar';
    OnClick  := @DoWindowMaximizeClick;
  end;
  with TFRMaterialAppBarAction(FAppBar.Actions.Add) do
  begin
    IconMode := imWindowClose;
    Hint     := 'Fechar';
    OnClick  := @DoWindowCloseClick;
  end;

  { ── Search panel ── }
  FSearchPanel := TPanel.Create(Self);
  FSearchPanel.Parent      := FPnFundo;
  FSearchPanel.Align       := alTop;
  FSearchPanel.Height      := 48;
  FSearchPanel.BevelOuter  := bvNone;
  FSearchPanel.Visible     := False;
  FSearchPanel.Color       := MD3Colors.SurfaceContainerLow;

  FSearchEdit := TFRMaterialSearchEdit.Create(Self);
  FSearchEdit.Parent   := FSearchPanel;
  FSearchEdit.Align    := alClient;
  FSearchEdit.OnSearch := @DoSearchPerformed;

  { ── NavRail ── }
  FNavRail := TFRMaterialNavRail.Create(Self);
  FNavRail.Parent      := FPnFundo;
  FNavRail.Align       := alLeft;
  FNavRail.OnMenuClick := @DoAppBarNavClick;
  FNavRail.OnChange    := @DoNavRailChange;

  RegisterModules;

  if FNavRail.Items.Count > 0 then
    FNavRail.ItemIndex := 0;

  { ── PageControl ── }
  FPageControl := TFRMaterialPageControl.Create(Self);
  FPageControl.Parent          := FPnFundo;
  FPageControl.Align           := alClient;
  FPageControl.ShowCloseButton := True;
  FPageControl.TabPosition     := tpBottom;
  FPageControl.OnCloseTab      := @DoPageCloseTab;

  { ── StatusBar ── }
  FStatusBar := TStatusBar.Create(Self);
  FStatusBar.Parent     := Self;
  FStatusBar.Align      := alBottom;
  FStatusBar.SimplePanel := True;
  FStatusBar.Color      := MD3Colors.SurfaceContainerLow;
  FStatusBar.Font.Color := MD3Colors.OnSurfaceVariant;
  FStatusBar.Font.Size  := 9;

  { ── Snackbar ── }
  FSnackbar := TFRMaterialSnackbar.Create(Self);

  { ── User menu ── }
  BuildUserMenu;

  { ── Home screen ── }
  BuildHomeScreen;
end;

procedure TFRMaterialMainForm.RegisterAppBarActions;
begin
  with TFRMaterialAppBarAction(FAppBar.Actions.Add) do
  begin
    IconMode := imSearch;
    Hint     := 'Buscar';
    OnClick  := @DoSearchActionClick;
  end;
end;

procedure TFRMaterialMainForm.RegisterUserMenu;
begin
  { Default: standard user menu items.
    Override to add custom items or replace entirely. }
end;

procedure TFRMaterialMainForm.BuildUserMenu;
begin
  FUserMenu := TFRMaterialMenu.Create(Self);

  with TFRMaterialMenuItem(FUserMenu.Items.Add) do
  begin
    Caption  := 'Alterar Senha';
    IconMode := imEdit;
    OnClick  := @DoUserMenuAlterarSenha;
  end;
  with TFRMaterialMenuItem(FUserMenu.Items.Add) do
  begin
    Caption  := 'Bloquear Sistema';
    IconMode := imNightlight;
    OnClick  := @DoUserMenuBloquear;
  end;
  with TFRMaterialMenuItem(FUserMenu.Items.Add) do
    IsSeparator := True;
  with TFRMaterialMenuItem(FUserMenu.Items.Add) do
  begin
    Caption  := 'Desconectar Conta';
    IconMode := imPerson;
    OnClick  := @DoUserMenuDesconectar;
  end;
  with TFRMaterialMenuItem(FUserMenu.Items.Add) do
    IsSeparator := True;
  with TFRMaterialMenuItem(FUserMenu.Items.Add) do
  begin
    Caption  := 'Sair do Sistema';
    IconMode := imClear;
    OnClick  := @DoUserMenuSair;
  end;

  { Let subclass add/replace items }
  RegisterUserMenu;
end;

{ ── Home Screen ── }

procedure TFRMaterialMainForm.BuildHomeScreen;
var
  Divider: TFRMaterialDivider;
begin
  FHomePage := TFRMaterialTabPage.Create(FPageControl);
  FHomePage.Caption      := 'INÍCIO';
  FHomePage.IconMode     := imHome;
  FHomePage.Color        := MD3Colors.Surface;
  FHomePage.PageControl  := FPageControl;
  FPageControl.ActivePage := FHomePage;

  FMainScroll := TScrollBox.Create(Self);
  FMainScroll.Parent      := FHomePage;
  FMainScroll.Align       := alClient;
  FMainScroll.BorderStyle := bsNone;
  FMainScroll.Color       := MD3Colors.Surface;
  FMainScroll.HorzScrollBar.Visible := False;

  { Greeting }
  FPnGreeting := TPanel.Create(Self);
  FPnGreeting.Parent     := FMainScroll;
  FPnGreeting.Left       := 0;
  FPnGreeting.Top        := 0;
  FPnGreeting.Width      := FMainScroll.ClientWidth;
  FPnGreeting.Height     := 64;
  FPnGreeting.Anchors    := [akTop, akLeft, akRight];
  FPnGreeting.BevelOuter := bvNone;
  FPnGreeting.Color      := MD3Colors.Surface;

  FGreetingLabel := TLabel.Create(Self);
  FGreetingLabel.Parent     := FPnGreeting;
  FGreetingLabel.Left       := 24;
  FGreetingLabel.Top        := 8;
  FGreetingLabel.AutoSize   := True;
  FGreetingLabel.Font.Size  := 16;
  FGreetingLabel.Font.Style := [fsBold];
  FGreetingLabel.Font.Color := MD3Colors.OnSurface;
  FGreetingLabel.Caption    := GetGreeting;

  FDateLabel := TLabel.Create(Self);
  FDateLabel.Parent     := FPnGreeting;
  FDateLabel.Left       := 24;
  FDateLabel.Top        := 36;
  FDateLabel.AutoSize   := True;
  FDateLabel.Font.Size  := 10;
  FDateLabel.Font.Color := MD3Colors.OnSurfaceVariant;
  FDateLabel.Caption    := FormatDateTime('dddd", "d" de "mmmm" de "yyyy', Now);

  { Filter chips }
  FPnChips := TPanel.Create(Self);
  FPnChips.Parent     := FMainScroll;
  FPnChips.Left       := 0;
  FPnChips.Top        := 68;
  FPnChips.Width      := FMainScroll.ClientWidth;
  FPnChips.Height     := 48;
  FPnChips.Anchors    := [akTop, akLeft, akRight];
  FPnChips.BevelOuter := bvNone;
  FPnChips.Color      := MD3Colors.Surface;

  FChipRecentes := TFRMaterialChip.Create(Self);
  FChipRecentes.Parent    := FPnChips;
  FChipRecentes.Left      := 24;
  FChipRecentes.Top       := 8;
  FChipRecentes.Width     := 110;
  FChipRecentes.Height    := 32;
  FChipRecentes.Caption   := 'Recentes';
  FChipRecentes.ChipStyle := csFilter;
  FChipRecentes.Selected  := True;
  FChipRecentes.ShowIcon  := True;
  FChipRecentes.IconMode  := imRefresh;
  FChipRecentes.OnClick   := @DoChipClick;

  FChipFavoritas := TFRMaterialChip.Create(Self);
  FChipFavoritas.Parent    := FPnChips;
  FChipFavoritas.Left      := 144;
  FChipFavoritas.Top       := 8;
  FChipFavoritas.Width     := 110;
  FChipFavoritas.Height    := 32;
  FChipFavoritas.Caption   := 'Favoritas';
  FChipFavoritas.ChipStyle := csFilter;
  FChipFavoritas.Selected  := False;
  FChipFavoritas.ShowIcon  := True;
  FChipFavoritas.IconMode  := imStar;
  FChipFavoritas.OnClick   := @DoChipClick;

  FChipTodas := TFRMaterialChip.Create(Self);
  FChipTodas.Parent    := FPnChips;
  FChipTodas.Left      := 264;
  FChipTodas.Top       := 8;
  FChipTodas.Width     := 100;
  FChipTodas.Height    := 32;
  FChipTodas.Caption   := 'Todas';
  FChipTodas.ChipStyle := csFilter;
  FChipTodas.Selected  := False;
  FChipTodas.ShowIcon  := True;
  FChipTodas.IconMode  := imDashboard;
  FChipTodas.OnClick   := @DoChipClick;

  { Divider }
  Divider := TFRMaterialDivider.Create(Self);
  Divider.Parent  := FMainScroll;
  Divider.Left    := 24;
  Divider.Top     := 120;
  Divider.Width   := FMainScroll.ClientWidth - 48;
  Divider.Height  := 1;
  Divider.Anchors := [akTop, akLeft, akRight];

  { Section label }
  FSectionLabel := TLabel.Create(Self);
  FSectionLabel.Parent     := FMainScroll;
  FSectionLabel.Left       := 24;
  FSectionLabel.Top        := 130;
  FSectionLabel.AutoSize   := True;
  FSectionLabel.Font.Size  := 12;
  FSectionLabel.Font.Style := [fsBold];
  FSectionLabel.Font.Color := MD3Colors.OnSurface;
  FSectionLabel.Caption    := 'ROTINAS MAIS ACESSADAS';

  { Card grid }
  FCardGrid := TFRMaterialGridPanel.Create(Self);
  FCardGrid.Parent      := FMainScroll;
  FCardGrid.Left        := 24;
  FCardGrid.Top         := 156;
  FCardGrid.Width       := FMainScroll.ClientWidth - 48;
  FCardGrid.Height      := 200;
  FCardGrid.Anchors     := [akTop, akLeft, akRight];
  FCardGrid.Color       := MD3Colors.Surface;
  FCardGrid.GapH        := 16;
  FCardGrid.GapV        := 16;
  FCardGrid.AutoHeight  := True;
  FCardGrid.FlexItemWidth := 200;

  { FAB }
  FFab := TFRMaterialFAB.Create(Self);
  FFab.Parent   := FHomePage;
  FFab.IconMode := imSearch;
  FFab.Anchors  := [akRight, akBottom];
  FFab.Left     := FHomePage.ClientWidth - 72;
  FFab.Top      := FHomePage.ClientHeight - 72;
  FFab.OnClick  := @DoFabClick;

  FHomeFilter := 0;

  PopulateCards;
end;

{ ── Public API ── }

procedure TFRMaterialMainForm.AddModule(const ACaption: string;
  AIcon: TFRIconMode; AMenuItems: TMenuItem);
var
  MatMenu: TFRMaterialMenu;
begin
  MatMenu := ConvertMenuToMaterial(AMenuItems);
  AddModule(ACaption, AIcon, MatMenu);
end;

procedure TFRMaterialMainForm.AddModule(const ACaption: string;
  AIcon: TFRIconMode; AMenu: TFRMaterialMenu);
begin
  with TFRMaterialNavItem(FNavRail.Items.Add) do
  begin
    Caption  := ACaption;
    IconMode := AIcon;
    Menu     := AMenu;
  end;
end;

procedure TFRMaterialMainForm.ShowSnackbar(const AMsg: string);
begin
  if Assigned(FSnackbar) then
    FSnackbar.Show(AMsg);
end;

{ ── Menu conversion ── }

function TFRMaterialMainForm.ConvertMenuToMaterial(AMenuItem: TMenuItem): TFRMaterialMenu;

  procedure AddItems(AParent: TMenuItem; ATarget: TFRMaterialMenuItems);
  var
    i: Integer;
    MI: TMenuItem;
    MdItem: TFRMaterialMenuItem;
  begin
    for i := 0 to AParent.Count - 1 do
    begin
      MI := AParent.Items[i];

      if MI.Caption = '-' then
      begin
        MdItem := ATarget.Add;
        MdItem.IsSeparator := True;
        Continue;
      end;

      MdItem := ATarget.Add;
      MdItem.Caption := MI.Caption;
      MdItem.Enabled := MI.Enabled;
      MdItem.IconMode := ImageIndexToIconMode(MI.ImageIndex);

      if MI.Count > 0 then
        AddItems(MI, MdItem.SubItems)
      else
      begin
        if Assigned(MI.Action) then
          MdItem.Action := MI.Action
        else
          MdItem.OnClick := MI.OnClick;
      end;
    end;
  end;

begin
  if not Assigned(AMenuItem) then
  begin
    Result := nil;
    Exit;
  end;
  Result := TFRMaterialMenu.Create(Self);
  Result.MinWidth := 280;
  AddItems(AMenuItem, Result.Items);
end;

{ ── Internal event handlers ── }

procedure TFRMaterialMainForm.DoAppBarNavClick(Sender: TObject);
begin
  FNavRail.Visible := not FNavRail.Visible;
end;

procedure TFRMaterialMainForm.DoSearchActionClick(Sender: TObject);
begin
  FSearchPanel.Visible := not FSearchPanel.Visible;
  if FSearchPanel.Visible then
    FSearchEdit.Edit.SetFocus;
end;

procedure TFRMaterialMainForm.DoUserActionClick(Sender: TObject);
var
  P: TPoint;
begin
  P.X := FAppBar.ClientWidth;
  P.Y := FAppBar.Height;
  P := FAppBar.ClientToScreen(P);
  FUserMenu.Popup(P.X - 200, P.Y);
end;

procedure TFRMaterialMainForm.DoWindowMinimizeClick(Sender: TObject);
begin
  WindowState := wsMinimized;
end;

procedure TFRMaterialMainForm.DoWindowMaximizeClick(Sender: TObject);
var
  i: Integer;
begin
  if WindowState = wsMaximized then
    WindowState := wsNormal
  else
    WindowState := wsMaximized;

  for i := 0 to FAppBar.Actions.Count - 1 do
    if (FAppBar.Actions[i].IconMode = imWindowMaximize) or
       (FAppBar.Actions[i].IconMode = imWindowRestore) then
    begin
      if WindowState = wsMaximized then
        FAppBar.Actions[i].IconMode := imWindowRestore
      else
        FAppBar.Actions[i].IconMode := imWindowMaximize;
      Break;
    end;
  FAppBar.Invalidate;
end;

procedure TFRMaterialMainForm.DoWindowCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFRMaterialMainForm.DoSearchPerformed(Sender: TObject;
  const ASearchText: string);
begin
  if Trim(ASearchText) <> '' then
    DoSearch(Trim(ASearchText));
end;

procedure TFRMaterialMainForm.DoNavRailChange(Sender: TObject);
begin
  if (FNavRail.ItemIndex >= 0) and (FNavRail.ItemIndex < FNavRail.Items.Count) then
    FStatusBar.SimpleText := 'Módulo: ' +
      TFRMaterialNavItem(FNavRail.Items[FNavRail.ItemIndex]).Caption;
end;

procedure TFRMaterialMainForm.DoChipClick(Sender: TObject);
begin
  FChipRecentes.Selected  := (Sender = FChipRecentes);
  FChipFavoritas.Selected := (Sender = FChipFavoritas);
  FChipTodas.Selected     := (Sender = FChipTodas);

  if Sender = FChipRecentes then
  begin
    FHomeFilter := 0;
    FSectionLabel.Caption := 'ROTINAS MAIS ACESSADAS';
  end
  else if Sender = FChipFavoritas then
  begin
    FHomeFilter := 1;
    FSectionLabel.Caption := 'ROTINAS FAVORITAS';
  end
  else
  begin
    FHomeFilter := 2;
    FSectionLabel.Caption := 'TODAS AS ROTINAS';
  end;

  PopulateCards;
end;

procedure TFRMaterialMainForm.DoCardClick(Sender: TObject);
begin
  if Sender is TFRMaterialCard then
    CardClicked(TFRMaterialCard(Sender).Tag);
end;

procedure TFRMaterialMainForm.DoFabClick(Sender: TObject);
begin
  FabClicked;
end;

procedure TFRMaterialMainForm.DoPageCloseTab(Sender: TObject;
  APage: TFRMaterialTabPage; var AllowClose: Boolean);
var
  Form: TForm;
begin
  { Home tab is not closeable }
  if APage = FHomePage then
  begin
    AllowClose := False;
    Exit;
  end;

  if APage.Tag <> 0 then
  begin
    Form := TForm(APage.Tag);
    if Assigned(Form) then
    begin
      AllowClose := False;
      Form.Close;
    end;
  end;
end;

procedure TFRMaterialMainForm.DoUserMenuAlterarSenha(Sender: TObject);
begin
  OnAlterarSenha;
end;

procedure TFRMaterialMainForm.DoUserMenuBloquear(Sender: TObject);
begin
  OnBloquearSistema;
end;

procedure TFRMaterialMainForm.DoUserMenuDesconectar(Sender: TObject);
begin
  OnDesconectar;
end;

procedure TFRMaterialMainForm.DoUserMenuSair(Sender: TObject);
begin
  Close;
end;

{ ── Virtual methods (defaults) ── }

procedure TFRMaterialMainForm.DoSearch(const AText: string);
begin
  { Override in subclass to implement search }
end;

procedure TFRMaterialMainForm.PopulateCards;
begin
  { Override in subclass to populate FCardGrid with cards }
end;

procedure TFRMaterialMainForm.CardClicked(ATag: Integer);
begin
  { Override in subclass to handle card click }
end;

procedure TFRMaterialMainForm.FabClicked;
begin
  DoSearchActionClick(nil);
end;

procedure TFRMaterialMainForm.OnAlterarSenha;
begin
  { Override in subclass }
end;

procedure TFRMaterialMainForm.OnBloquearSistema;
begin
  { Override in subclass }
end;

procedure TFRMaterialMainForm.OnDesconectar;
begin
  { Override in subclass }
end;

function TFRMaterialMainForm.GetGreeting: string;
var
  H, M, S, MS: Word;
begin
  DecodeTime(Now, H, M, S, MS);
  if H < 12 then
    Result := 'Bom dia'
  else if H < 18 then
    Result := 'Boa tarde'
  else
    Result := 'Boa noite';
end;

function TFRMaterialMainForm.ImageIndexToIconMode(AIdx: Integer): TFRIconMode;
begin
  case AIdx of
    2:  Result := imFile;
    3:  Result := imPerson;
    5:  Result := imWallet;
    6:  Result := imMoney;
    7:  Result := imCheck;
    8:  Result := imBox;
    9:  Result := imSettings;
    10: Result := imStore;
    11: Result := imInvoice;
    13: Result := imAssignment;
    15: Result := imLock;
    16: Result := imReceipt;
    17: Result := imLocalShipping;
    18: Result := imTag;
    19: Result := imTrendUp;
    20: Result := imLink;
    22: Result := imRefresh;
    23: Result := imRoute;
    24: Result := imBank;
    25: Result := imBarChart;
    27: Result := imBank;
    28: Result := imShoppingCart;
    29: Result := imCashFlow;
    31: Result := imTag;
    32: Result := imSearch;
    33: Result := imDownload;
    34: Result := imEdit;
    35: Result := imInventory;
    36: Result := imFile;
    37: Result := imWarehouse;
    38: Result := imReport;
    39: Result := imHandshake;
  else
    Result := imClear;
  end;
end;

end.

unit uFmDemo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, LCLType, ComCtrls, StdCtrls,
  ExtCtrls, Menus, StrUtils, Math, Grids,
  laz.VirtualTrees,
  FRMaterial3Base,
  FRMaterial3Button,
  FRMaterial3FAB,
  FRMaterial3Toggle,
  FRMaterial3Chip,
  FRMaterial3Slider,
  FRMaterial3Progress,
  FRMaterial3Divider,
  FRMaterial3Dialog,
  FRMaterial3Snackbar,
  FRMaterial3Tooltip,
  FRMaterial3List,
  FRMaterial3Menu,
  FRMaterial3Tabs,
  FRMaterial3AppBar,
  FRMaterial3Nav,
  FRMaterial3TimePicker,
  FRMaterial3Sheet,
  FRMaterial3TreeView,
  FRMaterial3DataGrid,
  FRMaterial3PageControl,
  FRMaterial3VirtualDataGrid,
  FRMaterialEdit,
  FRMaterialComboEdit,
  FRMaterialCheckComboEdit,
  FRMaterialCurrencyEdit,
  FRMaterialDateEdit,
  FRMaterialMaskEdit,
  FRMaterialMemoEdit,
  FRMaterialSearchEdit,
  FRMaterialSpinEdit,
  FRMaterialTheme,
  FRMaterialThemeManager,
  FRMaterialMasks,
  FRMaterialIcons;

type

  { TFmDemo }

  TFmDemo = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    FMainAppBar: TFRMaterialAppBar;
    FMainTabs: TFRMaterialTabs;
    FMainNavBar: TFRMaterialNavBar;
    FContentPanels: array[0..12] of TScrollBox;
    FDarkMode: Boolean;
    FDarkAction: TFRMaterialAppBarAction;
    FPaletteMenu: TPopupMenu;
    FCurrentPalette: TFRMDPalette;
    FThemeManager: TFRMaterialThemeManager;
    FStatusBar: TStatusBar;

    { Component refs for interactions }
    FSnackbar: TFRMaterialSnackbar;
    FDialog: TFRMaterialDialog;
    FMenu: TFRMaterialMenu;
    FTooltip: TFRMaterialTooltip;
    FBottomSheet: TFRMaterialBottomSheet;
    FSideSheet: TFRMaterialSideSheet;
    FSliderValueLbl: TLabel;
    FTimePickerLbl: TLabel;
    FTimePicker: TFRMaterialTimePicker;
    FLinearProgress: TFRMaterialLinearProgress;
    FCircularProgress: TFRMaterialCircularProgress;
    FProgressTimer: TTimer;
    FTreeView: TFRMaterialTreeView;
    FTreeEdit: TFRMaterialEdit;
    FTreeSelLabel: TLabel;
    FDataGrid: TFRMaterialDataGrid;
    FPageControl: TFRMaterialPageControl;
    FVirtualGrid: TFRMaterialVirtualDataGrid;

    procedure CreatePageButtons(APage: TWinControl);
    procedure CreatePageFABs(APage: TWinControl);
    procedure CreatePageToggles(APage: TWinControl);
    procedure CreatePageChips(APage: TWinControl);
    procedure CreatePageEdits(APage: TWinControl);
    procedure CreatePageInputs(APage: TWinControl);
    procedure CreatePageProgress(APage: TWinControl);
    procedure CreatePageListTabs(APage: TWinControl);
    procedure CreatePageTreeData(APage: TWinControl);
    procedure CreatePageNavigation(APage: TWinControl);
    procedure CreatePageSurfaces(APage: TWinControl);
    procedure CreatePagePageControl(APage: TWinControl);
    procedure CreatePageVirtualGrid(APage: TWinControl);

    function AddLabel(AParent: TWinControl; X, Y: Integer; const AText: string;
      ABold: Boolean = False): TLabel;
    function AddSection(AParent: TWinControl; Y: Integer;
      const ATitle: string): Integer;
    function ContentW(AParent: TWinControl): Integer;

    { Navigation helpers }
    procedure UpdateMainTabs;
    procedure ShowPage(AIndex: Integer);

    { Event handlers }
    procedure OnMainDarkToggle(Sender: TObject);
    procedure OnMainTabChange(Sender: TObject);
    procedure OnMainNavChange(Sender: TObject);
    procedure OnMainNavClick(Sender: TObject);
    procedure OnPaletteClick(Sender: TObject);
    procedure OnPaletteMenuAction(Sender: TObject);
    procedure ApplyTheme;
    procedure OnButtonClick(Sender: TObject);
    procedure OnIconButtonClick(Sender: TObject);
    procedure OnIconToggle(Sender: TObject);
    procedure OnSplitClick(Sender: TObject);
    procedure OnFABClick(Sender: TObject);
    procedure OnExtFABClick(Sender: TObject);
    procedure OnSwitchChange(Sender: TObject);
    procedure OnCheckChange(Sender: TObject);
    procedure OnRadioChange(Sender: TObject);
    procedure OnChipClick(Sender: TObject);
    procedure OnChipDelete(Sender: TObject);
    procedure OnSegmentChange(Sender: TObject);
    procedure OnDialogClick(Sender: TObject);
    procedure OnSnackbarClick(Sender: TObject);
    procedure OnSnackbarAction(Sender: TObject);
    procedure OnMenuClick(Sender: TObject);
    procedure OnMenuItemClick(Sender: TObject);
    procedure OnSliderChange(Sender: TObject);
    procedure OnTimePickerChange(Sender: TObject);
    procedure OnProgressTimer(Sender: TObject);
    procedure OnBottomSheetClick(Sender: TObject);
    procedure OnSideSheetClick(Sender: TObject);
    procedure OnListSelect(Sender: TObject);
    procedure OnTabChange(Sender: TObject);
    procedure OnNavBarChange(Sender: TObject);
    procedure OnAppBarNav(Sender: TObject);
    procedure OnAppBarAction(Sender: TObject);
    procedure OnToolbarAction(Sender: TObject);
    procedure OnTreeAddRoot(Sender: TObject);
    procedure OnTreeAddChild(Sender: TObject);
    procedure OnTreeDelete(Sender: TObject);
    procedure OnTreeRename(Sender: TObject);
    procedure OnTreeExpandAll(Sender: TObject);
    procedure OnTreeCollapseAll(Sender: TObject);
    procedure OnTreeSelChange(Sender: TObject);
    procedure OnPageControlChange(Sender: TObject);
    procedure OnVGridSortColumn(Sender: TObject; ACol: Integer;
      var ADirection: TFRMDSortDirection);
  public
  end;

var
  FmDemo: TFmDemo;

implementation

{$R *.lfm}

const
  PAGE_COUNT = 13;
  PAD = 16;
  GAP_Y = 12;
  ROW_H = 56;
  BTN_W = 130;
  BTN_H = 40;

{ ----- Helpers ----- }

function TFmDemo.ContentW(AParent: TWinControl): Integer;
begin
  Result := AParent.ClientWidth - PAD * 2;
  if Result < 200 then Result := 200;
end;

function TFmDemo.AddLabel(AParent: TWinControl; X, Y: Integer;
  const AText: string; ABold: Boolean): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.Parent := AParent;
  Result.Left := X;
  Result.Top := Y;
  Result.Caption := AText;
  Result.Transparent := True;
  Result.Font.Color := MD3Colors.OnSurface;
  if ABold then
    Result.Font.Style := [fsBold];
end;

function TFmDemo.AddSection(AParent: TWinControl; Y: Integer;
  const ATitle: string): Integer;
var
  Lbl: TLabel;
  Div1: TFRMaterialDivider;
begin
  if Y > PAD then
  begin
    Div1 := TFRMaterialDivider.Create(Self);
    Div1.Parent := AParent;
    Div1.SetBounds(PAD, Y, ContentW(AParent), 1);
    Div1.Anchors := [akLeft, akTop, akRight];
    Y := Y + GAP_Y;
  end;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := AParent;
  Lbl.Left := PAD;
  Lbl.Top := Y;
  Lbl.Caption := ATitle;
  Lbl.Font.Size := 12;
  Lbl.Font.Style := [fsBold];
  Lbl.Font.Color := MD3Colors.Primary;
  Lbl.Transparent := True;
  Result := Y + Lbl.Height + GAP_Y;
end;

{ ----- Main ----- }

procedure TFmDemo.FormCreate(Sender: TObject);
const
  CPageNames: array[0..PAGE_COUNT-1] of string = (
    'Buttons', 'FABs', 'Toggles', 'Chips', 'Edits',
    'Inputs', 'Progress', 'Listas & Tabs', 'Tree & DataGrid',
    'Navegação', 'Superfícies', 'PageControl', 'VirtualDataGrid');
var
  I: Integer;
  NI: TFRMaterialNavItem;
  MI: TMenuItem;
begin
 try
  Color := MD3Colors.Surface;
  FDarkMode := False;
  FCurrentPalette := mpBaseline;

  FThemeManager := TFRMaterialThemeManager.Create(Self);
  FThemeManager.Palette := mpBaseline;
  FThemeManager.DarkMode := False;

  { === Palette popup menu === }
  FPaletteMenu := TPopupMenu.Create(Self);
  for I := 0 to MD3PaletteCount - 1 do
  begin
    MI := TMenuItem.Create(FPaletteMenu);
    MI.Caption := MD3PaletteName(TFRMDPalette(I));
    MI.Tag := I;
    MI.OnClick := @OnPaletteMenuAction;
    MI.RadioItem := True;
    MI.GroupIndex := 99;
    if I = 0 then MI.Checked := True;
    FPaletteMenu.Items.Add(MI);
  end;

  { === Top App Bar === }
  FMainAppBar := TFRMaterialAppBar.Create(Self);
  FMainAppBar.Parent := Self;
  FMainAppBar.Align := alTop;
  FMainAppBar.Title := 'Material Design 3';
  FMainAppBar.NavIcon := imMenu;
  FMainAppBar.BarSize := absSmall;
  FMainAppBar.OnNavClick := @OnMainNavClick;

  with TFRMaterialAppBarAction(FMainAppBar.Actions.Add) do
  begin
    IconMode := imStar;
    Hint := 'Paleta de cores';
    OnClick := @OnPaletteClick;
  end;

  FDarkAction := TFRMaterialAppBarAction(FMainAppBar.Actions.Add);
  FDarkAction.IconMode := imNightlight;
  FDarkAction.Hint := 'Alternar tema';
  FDarkAction.OnClick := @OnMainDarkToggle;

  { === Tabs (below AppBar) === }
  FMainTabs := TFRMaterialTabs.Create(Self);
  FMainTabs.Parent := Self;
  FMainTabs.Align := alTop;
  FMainTabs.Height := 48;
  FMainTabs.TabStyle := tsScrollable;
  FMainTabs.OnChange := @OnMainTabChange;

  { === Status bar (bottom) === }
  FStatusBar := TStatusBar.Create(Self);
  FStatusBar.Parent := Self;
  FStatusBar.SimplePanel := True;
  FStatusBar.SimpleText := 'Material Design 3 Component Library — Demo';

  { === NavBar (above status bar) === }
  FMainNavBar := TFRMaterialNavBar.Create(Self);
  FMainNavBar.Parent := Self;
  FMainNavBar.Align := alBottom;
  FMainNavBar.Height := 80;
  FMainNavBar.OnChange := @OnMainNavChange;

  NI := TFRMaterialNavItem(FMainNavBar.Items.Add);
  NI.Caption := 'Botões';
  NI.IconMode := imStar;
  NI := TFRMaterialNavItem(FMainNavBar.Items.Add);
  NI.Caption := 'Controles';
  NI.IconMode := imSettings;
  NI := TFRMaterialNavItem(FMainNavBar.Items.Add);
  NI.Caption := 'Entrada';
  NI.IconMode := imEdit;
  NI := TFRMaterialNavItem(FMainNavBar.Items.Add);
  NI.Caption := 'Dados';
  NI.IconMode := imList;
  NI := TFRMaterialNavItem(FMainNavBar.Items.Add);
  NI.Caption := 'Layout';
  NI.IconMode := imDashboard;
  FMainNavBar.ItemIndex := 0;

  { === Content panels === }
  for I := PAGE_COUNT - 1 downto 0 do
  begin
    FContentPanels[I] := TScrollBox.Create(Self);
    FContentPanels[I].Parent := Self;
    FContentPanels[I].Align := alClient;
    FContentPanels[I].BorderStyle := bsNone;
    FContentPanels[I].Color := MD3Colors.Surface;
    FContentPanels[I].Visible := (I = 0);
    FContentPanels[I].Hint := CPageNames[I];
    FContentPanels[I].HorzScrollBar.Visible := False;
    FContentPanels[I].AutoScroll := True;
  end;

  { Create pages }
  CreatePageButtons(FContentPanels[0]);
  CreatePageFABs(FContentPanels[1]);
  CreatePageToggles(FContentPanels[2]);
  CreatePageChips(FContentPanels[3]);
  CreatePageEdits(FContentPanels[4]);
  CreatePageInputs(FContentPanels[5]);
  CreatePageProgress(FContentPanels[6]);
  CreatePageListTabs(FContentPanels[7]);
  CreatePageTreeData(FContentPanels[8]);
  CreatePageNavigation(FContentPanels[9]);
  CreatePageSurfaces(FContentPanels[10]);
  CreatePagePageControl(FContentPanels[11]);
  CreatePageVirtualGrid(FContentPanels[12]);

  { Initialize tabs for first nav group }
  UpdateMainTabs;

  { Non-visual components }
  FSnackbar := TFRMaterialSnackbar.Create(Self);
  FSnackbar.OnAction := @OnSnackbarAction;

  FDialog := TFRMaterialDialog.Create(Self);
  FDialog.Title := 'Confirmar exclusão';
  FDialog.Content := 'O pedido #1042 (João Silva — R$ 3.487,50) será removido permanentemente. Esta ação não pode ser desfeita.';
  FDialog.Buttons := [dbYes, dbNo, dbCancel];

  FMenu := TFRMaterialMenu.Create(Self);
  with TFRMaterialMenuItem(FMenu.Items.Add) do begin Caption := 'Copiar'; IconMode := imCopy; OnClick := @OnMenuItemClick; end;
  with TFRMaterialMenuItem(FMenu.Items.Add) do begin Caption := 'Editar'; IconMode := imEdit; OnClick := @OnMenuItemClick; end;
  with TFRMaterialMenuItem(FMenu.Items.Add) do begin Caption := 'Compartilhar'; IconMode := imShare; OnClick := @OnMenuItemClick; end;
  with TFRMaterialMenuItem(FMenu.Items.Add) do begin Caption := 'Favoritar'; IconMode := imStar; OnClick := @OnMenuItemClick; end;
  with TFRMaterialMenuItem(FMenu.Items.Add) do begin IsSeparator := True; end;
  with TFRMaterialMenuItem(FMenu.Items.Add) do begin Caption := 'Baixar PDF'; IconMode := imDownload; OnClick := @OnMenuItemClick; end;
  with TFRMaterialMenuItem(FMenu.Items.Add) do begin Caption := 'Anexar arquivo'; IconMode := imAttach; OnClick := @OnMenuItemClick; end;
  with TFRMaterialMenuItem(FMenu.Items.Add) do begin IsSeparator := True; end;
  with TFRMaterialMenuItem(FMenu.Items.Add) do begin Caption := 'Excluir'; IconMode := imDelete; OnClick := @OnMenuItemClick; end;

  FTooltip := TFRMaterialTooltip.Create(Self);
  FTooltip.Text := 'Tooltip de demonstração';
 except
   on E: Exception do
     Application.MessageBox(PChar('Erro no FormCreate: ' + E.Message), 'Erro', 0);
 end;
end;

procedure TFmDemo.FormDestroy(Sender: TObject);
begin
  if Assigned(FProgressTimer) then
    FProgressTimer.Enabled := False;
end;

procedure TFmDemo.FormResize(Sender: TObject);
begin
  if Assigned(FBottomSheet) and (not FBottomSheet.Visible) then
  begin
    FBottomSheet.Width := ClientWidth;
    FBottomSheet.Top := ClientHeight;
  end;
  if Assigned(FSideSheet) and (not FSideSheet.Visible) then
  begin
    FSideSheet.Height := ClientHeight;
    FSideSheet.Left := ClientWidth;
  end;
end;

{ ===== Page: Buttons ===== }

procedure TFmDemo.CreatePageButtons(APage: TWinControl);
var
  Y, X: Integer;
  Btn: TFRMaterialButton;
  BtnI: TFRMaterialButtonIcon;
  Split: TFRMaterialSplitButton;
  Style: TFRMDButtonStyle;
  IStyle: TFRMDIconButtonStyle;
  StyleNames: array[TFRMDButtonStyle] of string = ('Filled', 'Outlined', 'Text', 'Elevated', 'Tonal');
  IStyleNames: array[TFRMDIconButtonStyle] of string = ('Standard', 'Filled', 'FilledTonal', 'Outlined');
begin
  Y := AddSection(APage, PAD, 'TFRMaterialButton (5 styles)');
  X := PAD;
  for Style := Low(TFRMDButtonStyle) to High(TFRMDButtonStyle) do
  begin
    Btn := TFRMaterialButton.Create(Self);
    Btn.Parent := APage;
    Btn.SetBounds(X, Y, BTN_W, BTN_H);
    Btn.Caption := StyleNames[Style];
    Btn.ButtonStyle := Style;
    Btn.OnClick := @OnButtonClick;
    X := X + BTN_W + GAP_Y;
  end;

  Y := Y + ROW_H;
  Y := AddSection(APage, Y, 'TFRMaterialButton with Icon');
  X := PAD;
  for Style := Low(TFRMDButtonStyle) to High(TFRMDButtonStyle) do
  begin
    Btn := TFRMaterialButton.Create(Self);
    Btn.Parent := APage;
    Btn.SetBounds(X, Y, 145, BTN_H);
    Btn.Caption := StyleNames[Style];
    Btn.ButtonStyle := Style;
    Btn.ShowIcon := True;
    Btn.IconMode := imStar;
    Btn.OnClick := @OnButtonClick;
    X := X + 157;
  end;

  Y := Y + ROW_H;
  Y := AddSection(APage, Y, 'TFRMaterialButtonIcon (4 styles)');
  X := PAD;
  for IStyle := Low(TFRMDIconButtonStyle) to High(TFRMDIconButtonStyle) do
  begin
    AddLabel(APage, X, Y, IStyleNames[IStyle]);
    BtnI := TFRMaterialButtonIcon.Create(Self);
    BtnI.Parent := APage;
    BtnI.SetBounds(X, Y + 18, 48, 48);
    BtnI.IconStyle := IStyle;
    BtnI.IconMode := imFavorite;
    BtnI.OnClick := @OnIconButtonClick;
    X := X + 80;
  end;

  Y := Y + 82;
  Y := AddSection(APage, Y, 'TFRMaterialButtonIcon — Toggle');
  X := PAD;
  for IStyle := Low(TFRMDIconButtonStyle) to High(TFRMDIconButtonStyle) do
  begin
    BtnI := TFRMaterialButtonIcon.Create(Self);
    BtnI.Parent := APage;
    BtnI.SetBounds(X, Y, 48, 48);
    BtnI.IconStyle := IStyle;
    BtnI.IconMode := imStar;
    BtnI.Toggle := True;
    BtnI.OnClick := @OnIconToggle;
    X := X + 80;
  end;

  Y := Y + 64;
  Y := AddSection(APage, Y, 'TFRMaterialSplitButton');
  Split := TFRMaterialSplitButton.Create(Self);
  Split.Parent := APage;
  Split.SetBounds(PAD, Y, 180, BTN_H);
  Split.Caption := 'Ações';
  Split.ButtonStyle := mbsFilled;
  Split.OnClick := @OnSplitClick;

  Split := TFRMaterialSplitButton.Create(Self);
  Split.Parent := APage;
  Split.SetBounds(PAD + 196, Y, 180, BTN_H);
  Split.Caption := 'Opções';
  Split.ButtonStyle := mbsOutlined;
  Split.OnClick := @OnSplitClick;

  Y := Y + ROW_H;
  Y := AddSection(APage, Y, 'Disabled');
  Btn := TFRMaterialButton.Create(Self);
  Btn.Parent := APage;
  Btn.SetBounds(PAD, Y, BTN_W, BTN_H);
  Btn.Caption := 'Disabled';
  Btn.Enabled := False;

  BtnI := TFRMaterialButtonIcon.Create(Self);
  BtnI.Parent := APage;
  BtnI.SetBounds(PAD + BTN_W + GAP_Y, Y, 48, 48);
  BtnI.IconMode := imSettings;
  BtnI.Enabled := False;
end;

{ ===== Page: FABs ===== }

procedure TFmDemo.CreatePageFABs(APage: TWinControl);
var
  Y, X: Integer;
  FAB: TFRMaterialFAB;
  EFAB: TFRMaterialExtendedFAB;
  Sz: TFRMDFABSize;
  SzNames: array[TFRMDFABSize] of string = ('Small', 'Regular', 'Large');
  SzWidths: array[TFRMDFABSize] of Integer = (40, 56, 96);
begin
  Y := AddSection(APage, PAD, 'TFRMaterialFAB (3 sizes)');
  X := PAD;
  for Sz := Low(TFRMDFABSize) to High(TFRMDFABSize) do
  begin
    AddLabel(APage, X, Y, SzNames[Sz]);
    FAB := TFRMaterialFAB.Create(Self);
    FAB.Parent := APage;
    FAB.SetBounds(X, Y + 20, SzWidths[Sz], SzWidths[Sz]);
    FAB.FABSize := Sz;
    FAB.IconMode := imPlus;
    FAB.OnClick := @OnFABClick;
    X := X + SzWidths[Sz] + 40;
  end;

  Y := Y + 130;
  Y := AddSection(APage, Y, 'TFRMaterialFAB — Different Icons');
  X := PAD;
  FAB := TFRMaterialFAB.Create(Self);
  FAB.Parent := APage;
  FAB.SetBounds(X, Y, 56, 56);
  FAB.IconMode := imEdit;
  FAB.OnClick := @OnFABClick;

  FAB := TFRMaterialFAB.Create(Self);
  FAB.Parent := APage;
  FAB.SetBounds(X + 76, Y, 56, 56);
  FAB.IconMode := imShare;
  FAB.OnClick := @OnFABClick;

  FAB := TFRMaterialFAB.Create(Self);
  FAB.Parent := APage;
  FAB.SetBounds(X + 152, Y, 56, 56);
  FAB.IconMode := imArrowForward;
  FAB.OnClick := @OnFABClick;

  Y := Y + 76;
  Y := AddSection(APage, Y, 'TFRMaterialExtendedFAB');
  EFAB := TFRMaterialExtendedFAB.Create(Self);
  EFAB.Parent := APage;
  EFAB.SetBounds(PAD, Y, 180, 56);
  EFAB.Caption := 'Novo item';
  EFAB.IconMode := imPlus;
  EFAB.ShowIcon := True;
  EFAB.OnClick := @OnExtFABClick;

  EFAB := TFRMaterialExtendedFAB.Create(Self);
  EFAB.Parent := APage;
  EFAB.SetBounds(PAD + 196, Y, 180, 56);
  EFAB.Caption := 'Compor';
  EFAB.IconMode := imEdit;
  EFAB.ShowIcon := True;
  EFAB.OnClick := @OnExtFABClick;

  EFAB := TFRMaterialExtendedFAB.Create(Self);
  EFAB.Parent := APage;
  EFAB.SetBounds(PAD + 392, Y, 160, 56);
  EFAB.Caption := 'Sem ícone';
  EFAB.ShowIcon := False;
  EFAB.OnClick := @OnExtFABClick;

  Y := Y + 76;
  Y := AddSection(APage, Y, 'TFRMaterialFABMenu (Speed Dial)');
  with TFRMaterialFABMenu.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD, Y, 56, 250);
    IconMode := imPlus;
    with TFRMaterialFABMenuItem(Items.Add) do begin Caption := 'Novo pedido'; IconMode := imEdit; end;
    with TFRMaterialFABMenuItem(Items.Add) do begin Caption := 'Novo cliente'; IconMode := imPerson; end;
    with TFRMaterialFABMenuItem(Items.Add) do begin Caption := 'Importar'; IconMode := imUpload; end;
  end;
end;

{ ===== Page: Toggles ===== }

procedure TFmDemo.CreatePageToggles(APage: TWinControl);
var
  Y: Integer;
  SW: TFRMaterialSwitch;
  CB: TFRMaterialCheckBox;
  RB: TFRMaterialRadioButton;
begin
  Y := AddSection(APage, PAD, 'TFRMaterialSwitch');

  SW := TFRMaterialSwitch.Create(Self);
  SW.Parent := APage;
  SW.SetBounds(PAD, Y, 52, 32);
  SW.OnChange := @OnSwitchChange;
  AddLabel(APage, 84, Y + 6, 'Notificações por e-mail');

  SW := TFRMaterialSwitch.Create(Self);
  SW.Parent := APage;
  SW.SetBounds(PAD, Y + 42, 52, 32);
  SW.Checked := True;
  SW.OnChange := @OnSwitchChange;
  AddLabel(APage, 84, Y + 48, 'Atualização automática de estoque');

  SW := TFRMaterialSwitch.Create(Self);
  SW.Parent := APage;
  SW.SetBounds(PAD, Y + 84, 52, 32);
  SW.Checked := True;
  SW.OnChange := @OnSwitchChange;
  AddLabel(APage, 84, Y + 90, 'Backup diário às 03:00');

  SW := TFRMaterialSwitch.Create(Self);
  SW.Parent := APage;
  SW.SetBounds(PAD, Y + 126, 52, 32);
  SW.Enabled := False;
  AddLabel(APage, 84, Y + 132, 'Modo manutenção (bloqueado)');

  Y := Y + 172;
  Y := AddSection(APage, Y, 'TFRMaterialCheckBox');

  CB := TFRMaterialCheckBox.Create(Self);
  CB.Parent := APage;
  CB.SetBounds(PAD, Y, 280, 24);
  CB.Caption := 'Emitir NF-e automaticamente';
  CB.OnChange := @OnCheckChange;

  CB := TFRMaterialCheckBox.Create(Self);
  CB.Parent := APage;
  CB.SetBounds(PAD, Y + 30, 280, 24);
  CB.Caption := 'Incluir impostos no preço final';
  CB.Checked := True;
  CB.OnChange := @OnCheckChange;

  CB := TFRMaterialCheckBox.Create(Self);
  CB.Parent := APage;
  CB.SetBounds(PAD, Y + 60, 280, 24);
  CB.Caption := 'Enviar comprovante por e-mail';
  CB.Checked := True;
  CB.OnChange := @OnCheckChange;

  CB := TFRMaterialCheckBox.Create(Self);
  CB.Parent := APage;
  CB.SetBounds(PAD, Y + 90, 280, 24);
  CB.Caption := 'Permissões parciais (tri-state)';
  CB.AllowGrayed := True;
  CB.State := cbGrayed;
  CB.OnChange := @OnCheckChange;

  CB := TFRMaterialCheckBox.Create(Self);
  CB.Parent := APage;
  CB.SetBounds(PAD, Y + 120, 280, 24);
  CB.Caption := 'Integração legada (indisponível)';
  CB.Enabled := False;

  Y := Y + 160;
  Y := AddSection(APage, Y, 'TFRMaterialRadioButton');

  RB := TFRMaterialRadioButton.Create(Self);
  RB.Parent := APage;
  RB.SetBounds(PAD, Y, 280, 24);
  RB.Caption := 'À vista (5% desconto)';
  RB.GroupIndex := 1;
  RB.Checked := True;
  RB.OnChange := @OnRadioChange;

  RB := TFRMaterialRadioButton.Create(Self);
  RB.Parent := APage;
  RB.SetBounds(PAD, Y + 30, 280, 24);
  RB.Caption := '30/60/90 dias — Boleto';
  RB.GroupIndex := 1;
  RB.OnChange := @OnRadioChange;

  RB := TFRMaterialRadioButton.Create(Self);
  RB.Parent := APage;
  RB.SetBounds(PAD, Y + 60, 280, 24);
  RB.Caption := 'Cartão de crédito — até 12x';
  RB.GroupIndex := 1;
  RB.OnChange := @OnRadioChange;

  RB := TFRMaterialRadioButton.Create(Self);
  RB.Parent := APage;
  RB.SetBounds(PAD, Y + 90, 280, 24);
  RB.Caption := 'PIX — Pagamento instantâneo';
  RB.GroupIndex := 1;
  RB.OnChange := @OnRadioChange;
end;

{ ===== Page: Chips ===== }

procedure TFmDemo.CreatePageChips(APage: TWinControl);
var
  Y, X: Integer;
  Ch: TFRMaterialChip;
  Seg: TFRMaterialSegmentedButton;
  Style: TFRMDChipStyle;
  StyleNames: array[TFRMDChipStyle] of string = ('Assist', 'Filter', 'Input', 'Suggestion');
begin
  Y := AddSection(APage, PAD, 'TFRMaterialChip (4 styles)');
  X := PAD;
  for Style := Low(TFRMDChipStyle) to High(TFRMDChipStyle) do
  begin
    Ch := TFRMaterialChip.Create(Self);
    Ch.Parent := APage;
    Ch.SetBounds(X, Y, 110, 32);
    Ch.Caption := StyleNames[Style];
    Ch.ChipStyle := Style;
    Ch.OnClick := @OnChipClick;
    X := X + 122;
  end;

  Y := Y + 48;
  Y := AddSection(APage, Y, 'Chips with icon');
  X := PAD;
  Ch := TFRMaterialChip.Create(Self);
  Ch.Parent := APage;
  Ch.SetBounds(X, Y, 130, 32);
  Ch.Caption := 'Calendário';
  Ch.ChipStyle := csAssist;
  Ch.ShowIcon := True;
  Ch.IconMode := imCalendar;
  Ch.OnClick := @OnChipClick;

  Ch := TFRMaterialChip.Create(Self);
  Ch.Parent := APage;
  Ch.SetBounds(X + 142, Y, 120, 32);
  Ch.Caption := 'Download';
  Ch.ChipStyle := csSuggestion;
  Ch.ShowIcon := True;
  Ch.IconMode := imDownload;
  Ch.OnClick := @OnChipClick;

  Ch := TFRMaterialChip.Create(Self);
  Ch.Parent := APage;
  Ch.SetBounds(X + 274, Y, 120, 32);
  Ch.Caption := 'Filtro';
  Ch.ChipStyle := csFilter;
  Ch.Selected := True;
  Ch.ShowIcon := True;
  Ch.IconMode := imFilter;
  Ch.OnClick := @OnChipClick;

  Ch := TFRMaterialChip.Create(Self);
  Ch.Parent := APage;
  Ch.SetBounds(X + 406, Y, 130, 32);
  Ch.Caption := 'Anexo';
  Ch.ChipStyle := csAssist;
  Ch.ShowIcon := True;
  Ch.IconMode := imAttach;
  Ch.OnClick := @OnChipClick;

  Y := Y + 48;
  Y := AddSection(APage, Y, 'Input Chips (deletáveis)');
  Ch := TFRMaterialChip.Create(Self);
  Ch.Parent := APage;
  Ch.SetBounds(PAD, Y, 130, 32);
  Ch.Caption := 'São Paulo';
  Ch.ChipStyle := csInput;
  Ch.Deletable := True;
  Ch.ShowIcon := True;
  Ch.IconMode := imPerson;
  Ch.OnClick := @OnChipClick;
  Ch.OnDelete := @OnChipDelete;

  Ch := TFRMaterialChip.Create(Self);
  Ch.Parent := APage;
  Ch.SetBounds(PAD + 142, Y, 150, 32);
  Ch.Caption := 'Rio de Janeiro';
  Ch.ChipStyle := csInput;
  Ch.Deletable := True;
  Ch.ShowIcon := True;
  Ch.IconMode := imPerson;
  Ch.OnClick := @OnChipClick;
  Ch.OnDelete := @OnChipDelete;

  Ch := TFRMaterialChip.Create(Self);
  Ch.Parent := APage;
  Ch.SetBounds(PAD + 304, Y, 120, 32);
  Ch.Caption := 'Curitiba';
  Ch.ChipStyle := csInput;
  Ch.Deletable := True;
  Ch.ShowIcon := True;
  Ch.IconMode := imPerson;
  Ch.OnClick := @OnChipClick;
  Ch.OnDelete := @OnChipDelete;

  Y := Y + 48;
  Y := AddSection(APage, Y, 'Filter Chips (selecionáveis)');
  Ch := TFRMaterialChip.Create(Self);
  Ch.Parent := APage;
  Ch.SetBounds(PAD, Y, 100, 32);
  Ch.Caption := 'Aberto';
  Ch.ChipStyle := csFilter;
  Ch.Selected := True;
  Ch.OnClick := @OnChipClick;

  Ch := TFRMaterialChip.Create(Self);
  Ch.Parent := APage;
  Ch.SetBounds(PAD + 112, Y, 120, 32);
  Ch.Caption := 'Em análise';
  Ch.ChipStyle := csFilter;
  Ch.OnClick := @OnChipClick;

  Ch := TFRMaterialChip.Create(Self);
  Ch.Parent := APage;
  Ch.SetBounds(PAD + 244, Y, 110, 32);
  Ch.Caption := 'Fechado';
  Ch.ChipStyle := csFilter;
  Ch.OnClick := @OnChipClick;

  Ch := TFRMaterialChip.Create(Self);
  Ch.Parent := APage;
  Ch.SetBounds(PAD + 366, Y, 120, 32);
  Ch.Caption := 'Cancelado';
  Ch.ChipStyle := csFilter;
  Ch.OnClick := @OnChipClick;

  Y := Y + 48;
  Y := AddSection(APage, Y, 'TFRMaterialSegmentedButton');
  Seg := TFRMaterialSegmentedButton.Create(Self);
  Seg.Parent := APage;
  Seg.SetBounds(PAD, Y, 360, BTN_H);
  Seg.Items.Add('Dia');
  Seg.Items.Add('Semana');
  Seg.Items.Add('Mês');
  Seg.ItemIndex := 0;
  Seg.OnChange := @OnSegmentChange;

  Y := Y + ROW_H;
  Seg := TFRMaterialSegmentedButton.Create(Self);
  Seg.Parent := APage;
  Seg.SetBounds(PAD, Y, Min(ContentW(APage), 600), BTN_H);
  Seg.Anchors := [akLeft, akTop, akRight];
  Seg.Items.Add('Matriz');
  Seg.Items.Add('Filial SP');
  Seg.Items.Add('Filial RJ');
  Seg.Items.Add('Filial BH');
  Seg.Items.Add('CD Curitiba');
  Seg.MultiSelect := True;
  Seg.OnChange := @OnSegmentChange;
end;

{ ===== Page: Edits ===== }

procedure TFmDemo.CreatePageEdits(APage: TWinControl);
var
  Y, ColW: Integer;
begin
  ColW := (ContentW(APage) - GAP_Y * 2) div 3;
  if ColW < 180 then ColW := 180;

  Y := AddSection(APage, PAD, 'TFRMaterialEdit — Standard / Filled / Outlined');
  with TFRMaterialEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD, Y, ColW, ROW_H);
    Caption := 'Nome do cliente';
    TextHint := 'Digite o nome completo';
    Variant := mvStandard;
    ShowClearButton := True;
  end;

  with TFRMaterialEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD + ColW + GAP_Y, Y, ColW, ROW_H);
    Caption := 'E-mail';
    TextHint := 'usuario@dominio.com';
    Variant := mvFilled;
    ShowLeadingIcon := True;
    LeadingIconMode := imMail;
  end;

  with TFRMaterialEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD + (ColW + GAP_Y) * 2, Y, ColW, ROW_H);
    Caption := 'CPF/CNPJ';
    TextHint := '00.000.000/0000-00';
    Variant := mvOutlined;
    TextMask := tmtCpfCnpj;
  end;

  Y := Y + 72;
  Y := AddSection(APage, Y, 'TFRMaterialEdit — Validation');
  with TFRMaterialEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD, Y, ColW, 70);
    Caption := 'Campo obrigatório';
    Required := True;
    HelperText := 'Preencha este campo';
    ErrorText := 'Campo obrigatório';
    ValidationState := vsInvalid;
    Variant := mvOutlined;
  end;

  with TFRMaterialEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD + ColW + GAP_Y, Y, ColW, 70);
    Caption := 'Campo validado';
    Text := 'Dados corretos';
    ValidationState := vsValid;
    Variant := mvOutlined;
  end;

  with TFRMaterialEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD + (ColW + GAP_Y) * 2, Y, ColW, 70);
    Caption := 'Senha';
    PasswordMode := True;
    TextHint := '********';
    Variant := mvFilled;
  end;

  { --- TFRMaterialComboEdit --- }
  ColW := (ContentW(APage) - GAP_Y) div 2;
  if ColW < 200 then ColW := 200;

  Y := Y + 86;
  Y := AddSection(APage, Y, 'TFRMaterialComboEdit');
  with TFRMaterialComboEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD, Y, ColW, ROW_H);
    Caption := 'Estado (UF)';
    Variant := mvOutlined;
    Items.Add('Acre'); Items.Add('Bahia'); Items.Add('Ceará');
    Items.Add('Minas Gerais'); Items.Add('Paraná');
    Items.Add('Rio de Janeiro'); Items.Add('São Paulo');
    Items.Add('Santa Catarina');
    Sorted := True;
  end;

  with TFRMaterialComboEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD + ColW + GAP_Y, Y, ColW, ROW_H);
    Caption := 'Forma de pagamento';
    Variant := mvFilled;
    Style := csDropDownList;
    Items.Add('À vista'); Items.Add('Boleto 30/60/90');
    Items.Add('Cartão de crédito'); Items.Add('PIX');
    ItemIndex := 0;
  end;

  { --- TFRMaterialCheckComboEdit --- }
  Y := Y + 72;
  Y := AddSection(APage, Y, 'TFRMaterialCheckComboEdit');
  with TFRMaterialCheckComboEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD, Y, ContentW(APage), ROW_H);
    Anchors := [akLeft, akTop, akRight];
    Caption := 'Categorias do produto';
    Variant := mvOutlined;
    Items.Add('Eletrônicos'); Items.Add('Ferramentas');
    Items.Add('Material elétrico'); Items.Add('Hidráulica');
    Items.Add('Pintura'); Items.Add('Iluminação');
    EmptyText := 'Selecione as categorias';
  end;

  { --- TFRMaterialCurrencyEdit --- }
  Y := Y + 72;
  Y := AddSection(APage, Y, 'TFRMaterialCurrencyEdit');
  with TFRMaterialCurrencyEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD, Y, ColW, ROW_H);
    Caption := 'Valor do pedido';
    Variant := mvOutlined;
    Value := 3487.50;
  end;

  with TFRMaterialCurrencyEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD + ColW + GAP_Y, Y, ColW, ROW_H);
    Caption := 'Desconto';
    Variant := mvFilled;
    Value := 0;
    ShowClearButton := True;
  end;

  { --- TFRMaterialDateEdit --- }
  ColW := (ContentW(APage) - GAP_Y * 2) div 3;
  if ColW < 180 then ColW := 180;

  Y := Y + 72;
  Y := AddSection(APage, Y, 'TFRMaterialDateEdit');
  with TFRMaterialDateEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD, Y, ColW, ROW_H);
    Caption := 'Data de emissão';
    Variant := mvOutlined;
    Date := Now;
  end;

  with TFRMaterialDateEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD + ColW + GAP_Y, Y, ColW, ROW_H);
    Caption := 'Data de vencimento';
    Variant := mvFilled;
    ShowClearButton := True;
  end;

  with TFRMaterialDateEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD + (ColW + GAP_Y) * 2, Y, ColW, ROW_H);
    Caption := 'Competência';
    Variant := mvOutlined;
    DateFormat := dfMMYYYY;
    TextHint := 'mm/aaaa';
  end;

  { --- TFRMaterialMaskEdit --- }
  ColW := (ContentW(APage) - GAP_Y) div 2;

  Y := Y + 72;
  Y := AddSection(APage, Y, 'TFRMaterialMaskEdit');
  with TFRMaterialMaskEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD, Y, ColW, ROW_H);
    Caption := 'Telefone';
    EditMask := '(99) 99999-9999;1;_';
    Variant := mvOutlined;
  end;

  with TFRMaterialMaskEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD + ColW + GAP_Y, Y, ColW, ROW_H);
    Caption := 'CEP';
    EditMask := '99999-999;1;_';
    Variant := mvFilled;
  end;

  { --- TFRMaterialSearchEdit --- }
  Y := Y + 72;
  Y := AddSection(APage, Y, 'TFRMaterialSearchEdit');
  with TFRMaterialSearchEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD, Y, ContentW(APage), ROW_H);
    Anchors := [akLeft, akTop, akRight];
    Caption := 'Buscar produto';
    TextHint := 'Nome, código ou descrição...';
    Variant := mvOutlined;
    DebounceInterval := 400;
  end;

  { --- TFRMaterialSpinEdit --- }
  Y := Y + 72;
  Y := AddSection(APage, Y, 'TFRMaterialSpinEdit');
  with TFRMaterialSpinEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD, Y, 200, ROW_H);
    Caption := 'Quantidade';
    Variant := mvOutlined;
    MinValue := 1; MaxValue := 999; Value := 10; Increment := 1;
  end;

  with TFRMaterialSpinEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD + 216, Y, 200, ROW_H);
    Caption := 'Parcelas';
    Variant := mvFilled;
    MinValue := 1; MaxValue := 12; Value := 3; Increment := 1;
  end;

  { --- TFRMaterialMemoEdit --- }
  Y := Y + 72;
  Y := AddSection(APage, Y, 'TFRMaterialMemoEdit');
  with TFRMaterialMemoEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD, Y, ContentW(APage), 160);
    Anchors := [akLeft, akTop, akRight];
    Caption := 'Observações do pedido';
    TextHint := 'Informações adicionais para entrega, faturamento etc.';
    Variant := mvOutlined;
    WordWrap := True;
    MaxLength := 500;
    ShowCharCounter := True;
    ScrollBars := ssAutoVertical;
  end;
end;

{ ===== Page: Inputs ===== }

procedure TFmDemo.CreatePageInputs(APage: TWinControl);
var
  Y: Integer;
  Sl: TFRMaterialSlider;
begin
  Y := AddSection(APage, PAD, 'TFRMaterialSlider — Continuous');
  Sl := TFRMaterialSlider.Create(Self);
  Sl.Parent := APage;
  Sl.SetBounds(PAD, Y, ContentW(APage) - 120, 40);
  Sl.Anchors := [akLeft, akTop, akRight];
  Sl.Min := 0; Sl.Max := 100; Sl.Value := 35;
  Sl.OnChange := @OnSliderChange;
  FSliderValueLbl := AddLabel(APage, ContentW(APage) - 80, Y + 10, 'Valor: 35');

  Y := Y + ROW_H;
  Y := AddSection(APage, Y, 'TFRMaterialSlider — Discrete (steps=5)');
  Sl := TFRMaterialSlider.Create(Self);
  Sl.Parent := APage;
  Sl.SetBounds(PAD, Y, ContentW(APage), 40);
  Sl.Anchors := [akLeft, akTop, akRight];
  Sl.Min := 0; Sl.Max := 100;
  Sl.Discrete := True; Sl.Steps := 5;
  Sl.ShowValueLabel := True; Sl.Value := 40;

  Y := Y + ROW_H;
  Y := AddSection(APage, Y, 'TFRMaterialSlider — Disabled');
  Sl := TFRMaterialSlider.Create(Self);
  Sl.Parent := APage;
  Sl.SetBounds(PAD, Y, ContentW(APage), 40);
  Sl.Anchors := [akLeft, akTop, akRight];
  Sl.Value := 60; Sl.Enabled := False;

  Y := Y + ROW_H;
  Y := AddSection(APage, Y, 'TFRMaterialTimePicker — 24h');
  FTimePicker := TFRMaterialTimePicker.Create(Self);
  FTimePicker.Parent := APage;
  FTimePicker.SetBounds(PAD, Y, 220, 72);
  FTimePicker.TimeFormat := tfHour24;
  FTimePicker.Hour := 14; FTimePicker.Minute := 30;
  FTimePicker.OnChange := @OnTimePickerChange;
  FTimePickerLbl := AddLabel(APage, PAD + 240, Y + 26, 'Hora: 14:30');

  Y := Y + 90;
  Y := AddSection(APage, Y, 'TFRMaterialTimePicker — 12h');
  with TFRMaterialTimePicker.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD, Y, 220, 72);
    TimeFormat := tfHour12;
    Hour := 3; Minute := 45; IsAM := False;
  end;
end;

{ ===== Page: Progress ===== }

procedure TFmDemo.CreatePageProgress(APage: TWinControl);
var
  Y: Integer;
  LP: TFRMaterialLinearProgress;
  CP: TFRMaterialCircularProgress;
  LI: TFRMaterialLoadingIndicator;
begin
  Y := AddSection(APage, PAD, 'TFRMaterialLinearProgress — Determinate');
  FLinearProgress := TFRMaterialLinearProgress.Create(Self);
  FLinearProgress.Parent := APage;
  FLinearProgress.SetBounds(PAD, Y, ContentW(APage), 4);
  FLinearProgress.Anchors := [akLeft, akTop, akRight];
  FLinearProgress.Value := 0;

  Y := Y + 24;
  Y := AddSection(APage, Y, 'TFRMaterialLinearProgress — Indeterminate');
  LP := TFRMaterialLinearProgress.Create(Self);
  LP.Parent := APage;
  LP.SetBounds(PAD, Y, ContentW(APage), 4);
  LP.Anchors := [akLeft, akTop, akRight];
  LP.Indeterminate := True;

  Y := Y + 24;
  Y := AddSection(APage, Y, 'TFRMaterialCircularProgress — Determinate');
  FCircularProgress := TFRMaterialCircularProgress.Create(Self);
  FCircularProgress.Parent := APage;
  FCircularProgress.SetBounds(PAD, Y, 48, 48);
  FCircularProgress.Indeterminate := False;
  FCircularProgress.Value := 0;
  AddLabel(APage, PAD + 60, Y + 14, 'Progresso animado');

  Y := Y + 64;
  Y := AddSection(APage, Y, 'TFRMaterialCircularProgress — Indeterminate');
  CP := TFRMaterialCircularProgress.Create(Self);
  CP.Parent := APage;
  CP.SetBounds(PAD, Y, 48, 48);
  CP.Indeterminate := True;

  CP := TFRMaterialCircularProgress.Create(Self);
  CP.Parent := APage;
  CP.SetBounds(PAD + 64, Y, 64, 64);
  CP.Indeterminate := True;
  CP.StrokeWidth := 6;

  Y := Y + 80;
  Y := AddSection(APage, Y, 'TFRMaterialLoadingIndicator');
  LI := TFRMaterialLoadingIndicator.Create(Self);
  LI.Parent := APage;
  LI.SetBounds(PAD, Y, 60, 20);

  LI := TFRMaterialLoadingIndicator.Create(Self);
  LI.Parent := APage;
  LI.SetBounds(PAD + 80, Y, 80, 20);
  LI.DotCount := 5;

  FProgressTimer := TTimer.Create(Self);
  FProgressTimer.Interval := 80;
  FProgressTimer.OnTimer := @OnProgressTimer;
  FProgressTimer.Enabled := True;
end;

{ ===== Page: List & Tabs ===== }

procedure TFmDemo.CreatePageListTabs(APage: TWinControl);
var
  Y: Integer;
  LV: TFRMaterialListView;
  Tabs: TFRMaterialTabs;
  Item: TFRMaterialListItem;
  TabItem: TFRMaterialTabItem;
begin
  Y := AddSection(APage, PAD, 'TFRMaterialTabs — Fixed');
  Tabs := TFRMaterialTabs.Create(Self);
  Tabs.Parent := APage;
  Tabs.SetBounds(PAD, Y, ContentW(APage), 48);
  Tabs.Anchors := [akLeft, akTop, akRight];
  Tabs.TabStyle := tsFixed;
  TabItem := TFRMaterialTabItem(Tabs.Tabs.Add);
  TabItem.Caption := 'Recentes'; TabItem.IconMode := imHome;
  TabItem := TFRMaterialTabItem(Tabs.Tabs.Add);
  TabItem.Caption := 'Favoritos'; TabItem.IconMode := imFavorite;
  TabItem := TFRMaterialTabItem(Tabs.Tabs.Add);
  TabItem.Caption := 'Compartilhados'; TabItem.IconMode := imShare;
  TabItem := TFRMaterialTabItem(Tabs.Tabs.Add);
  TabItem.Caption := 'Configurações'; TabItem.IconMode := imSettings;
  Tabs.TabIndex := 0;
  Tabs.OnChange := @OnTabChange;

  Y := Y + 64;
  Y := AddSection(APage, Y, 'TFRMaterialListView — TwoLine');
  LV := TFRMaterialListView.Create(Self);
  LV.Parent := APage;
  LV.SetBounds(PAD, Y, ContentW(APage), 420);
  LV.Anchors := [akLeft, akTop, akRight];
  LV.ItemType := litTwoLine;
  LV.ShowDividers := True;
  LV.OnSelectionChange := @OnListSelect;

  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'João Silva'; Item.SupportText := 'Pedido #1042 — Aguardando aprovação'; Item.LeadingIcon := imPerson; Item.TrailingText := '10:32';
  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Maria Oliveira'; Item.SupportText := 'NF-e 000.142.857 emitida com sucesso'; Item.LeadingIcon := imMail; Item.TrailingText := '09:15';
  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Estoque Baixo'; Item.SupportText := 'Produto "Parafuso M6x20" abaixo do mínimo (23 un.)'; Item.LeadingIcon := imNotification; Item.TrailingText := 'Ontem';
  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Relatório Mensal'; Item.SupportText := 'Faturamento de março disponível para download'; Item.LeadingIcon := imDownload; Item.TrailingText := '28/03';
  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Carlos Ferreira'; Item.SupportText := 'Orçamento #387 — Revisão solicitada'; Item.LeadingIcon := imEdit; Item.TrailingText := '27/03';
  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Backup Concluído'; Item.SupportText := 'Backup automático realizado às 03:00 — 2.4 GB'; Item.LeadingIcon := imCheck; Item.TrailingText := '27/03';
  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Ana Costa'; Item.SupportText := 'Devolução #089 — Produto com defeito'; Item.LeadingIcon := imRefresh; Item.TrailingText := '26/03';
  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Promoção Ativa'; Item.SupportText := '15% desconto em ferramentas'; Item.LeadingIcon := imStar; Item.TrailingText := '25/03';
  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Licença Expirando'; Item.SupportText := 'Certificado A1 vence em 12 dias'; Item.LeadingIcon := imSettings; Item.TrailingText := '24/03';
  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Pedro Santos'; Item.SupportText := 'Transferência R$ 4.750,00 confirmada'; Item.LeadingIcon := imFavorite; Item.TrailingText := '23/03';
end;

{ ===== Page: Tree & DataGrid ===== }

procedure TFmDemo.CreatePageTreeData(APage: TWinControl);
var
  Y: Integer;
begin
  Y := AddSection(APage, PAD, 'TFRMaterialTreeView');

  FTreeEdit := TFRMaterialEdit.Create(Self);
  FTreeEdit.Parent := APage;
  FTreeEdit.SetBounds(PAD, Y, 260, ROW_H);
  FTreeEdit.Caption := 'Nome do nó';
  FTreeEdit.TextHint := 'Digite o texto do nó';
  FTreeEdit.Variant := mvOutlined;
  FTreeEdit.ShowClearButton := True;

  with TFRMaterialButton.Create(Self) do begin Parent := APage; SetBounds(PAD + 276, Y, BTN_W, BTN_H); Caption := 'Adicionar raiz'; ButtonStyle := mbsFilled; OnClick := @OnTreeAddRoot; end;
  with TFRMaterialButton.Create(Self) do begin Parent := APage; SetBounds(PAD + 276 + BTN_W + GAP_Y, Y, BTN_W, BTN_H); Caption := 'Adicionar filho'; ButtonStyle := mbsOutlined; OnClick := @OnTreeAddChild; end;
  with TFRMaterialButton.Create(Self) do begin Parent := APage; SetBounds(PAD + 276, Y + 48, BTN_W, BTN_H); Caption := 'Renomear'; ButtonStyle := mbsOutlined; OnClick := @OnTreeRename; end;
  with TFRMaterialButton.Create(Self) do begin Parent := APage; SetBounds(PAD + 276 + BTN_W + GAP_Y, Y + 48, BTN_W, BTN_H); Caption := 'Excluir'; ButtonStyle := mbsText; OnClick := @OnTreeDelete; end;
  with TFRMaterialButton.Create(Self) do begin Parent := APage; SetBounds(PAD + 276, Y + 96, BTN_W, BTN_H); Caption := 'Expandir tudo'; ButtonStyle := mbsText; OnClick := @OnTreeExpandAll; end;
  with TFRMaterialButton.Create(Self) do begin Parent := APage; SetBounds(PAD + 276 + BTN_W + GAP_Y, Y + 96, BTN_W, BTN_H); Caption := 'Recolher tudo'; ButtonStyle := mbsText; OnClick := @OnTreeCollapseAll; end;

  FTreeSelLabel := TLabel.Create(Self);
  FTreeSelLabel.Parent := APage;
  FTreeSelLabel.SetBounds(PAD + 276, Y + 144, 280, 20);
  FTreeSelLabel.Font.Size := 9;
  FTreeSelLabel.Font.Color := MD3Colors.OnSurfaceVariant;
  FTreeSelLabel.Caption := 'Nenhum nó selecionado';
  FTreeSelLabel.Transparent := True;

  Y := Y + 170;
  FTreeView := TFRMaterialTreeView.Create(Self);
  with FTreeView do
  begin
    Parent := APage;
    SetBounds(PAD, Y, ContentW(APage), 320);
    Anchors := [akLeft, akTop, akRight];
    ShowIcons := True;
    ShowDividers := True;
    OnSelectionChange := @OnTreeSelChange;
    with TFRMaterialTreeNode(Nodes.Add) do
    begin
      Caption := 'Cadastros'; IconMode := imFolder;
      with TFRMaterialTreeNode(Children.Add) do begin Caption := 'Clientes'; IconMode := imPerson; end;
      with TFRMaterialTreeNode(Children.Add) do begin Caption := 'Fornecedores'; IconMode := imPerson; end;
      with TFRMaterialTreeNode(Children.Add) do begin Caption := 'Produtos'; IconMode := imList; end;
      Expanded := True;
    end;
    with TFRMaterialTreeNode(Nodes.Add) do
    begin
      Caption := 'Financeiro'; IconMode := imFolder;
      with TFRMaterialTreeNode(Children.Add) do begin Caption := 'Contas a Pagar'; IconMode := imDownload; end;
      with TFRMaterialTreeNode(Children.Add) do begin Caption := 'Contas a Receber'; IconMode := imUpload; end;
    end;
    with TFRMaterialTreeNode(Nodes.Add) do
    begin
      Caption := 'Relatórios'; IconMode := imFolder;
      with TFRMaterialTreeNode(Children.Add) do begin Caption := 'Vendas'; IconMode := imStar; end;
      with TFRMaterialTreeNode(Children.Add) do begin Caption := 'Estoque'; IconMode := imDashboard; end;
    end;
  end;

  Y := Y + 340;
  Y := AddSection(APage, Y, 'TFRMaterialDataGrid');
  FDataGrid := TFRMaterialDataGrid.Create(Self);
  with FDataGrid do
  begin
    Parent := APage;
    SetBounds(PAD, Y, ContentW(APage), 240);
    Anchors := [akLeft, akTop, akRight];
    ColCount := 4; RowCount := 5; DefaultColWidth := 130;
    Cells[0, 0] := 'Código'; Cells[1, 0] := 'Descrição'; Cells[2, 0] := 'Estoque'; Cells[3, 0] := 'Preço Unitário';
    Cells[0, 1] := '001'; Cells[1, 1] := 'Monitor LCD 24"'; Cells[2, 1] := '12 un'; Cells[3, 1] := 'R$ 850,00';
    Cells[0, 2] := '002'; Cells[1, 2] := 'Teclado Mecânico'; Cells[2, 2] := '45 un'; Cells[3, 2] := 'R$ 250,00';
    Cells[0, 3] := '003'; Cells[1, 3] := 'Mouse Óptico'; Cells[2, 3] := '89 un'; Cells[3, 3] := 'R$ 85,00';
    Cells[0, 4] := '004'; Cells[1, 4] := 'Cabo HDMI 2m'; Cells[2, 4] := '120 un'; Cells[3, 4] := 'R$ 25,00';
    Density := ddNormal; ZebraStripes := True;
    Options := Options + [goEditing] - [goRowSelect];
  end;
end;

{ ===== Page: Navigation ===== }

procedure TFmDemo.CreatePageNavigation(APage: TWinControl);
var
  Y: Integer;
  AppBar: TFRMaterialAppBar;
  Toolbar: TFRMaterialToolbar;
  NavBar: TFRMaterialNavBar;
  NavItem: TFRMaterialNavItem;
  Act: TFRMaterialAppBarAction;
  GBox: TFRMaterialGroupBox;
begin
  Y := AddSection(APage, PAD, 'TFRMaterialAppBar — Small');
  GBox := TFRMaterialGroupBox.Create(Self);
  GBox.Parent := APage;
  GBox.SetBounds(PAD, Y, ContentW(APage), 68);
  GBox.Anchors := [akLeft, akTop, akRight];
  GBox.Caption := ''; GBox.ShowBorder := True;
  AppBar := TFRMaterialAppBar.Create(Self);
  AppBar.Parent := GBox; AppBar.Align := alClient;
  AppBar.Title := 'Meu Aplicativo'; AppBar.NavIcon := imMenu; AppBar.BarSize := absSmall;
  AppBar.OnNavClick := @OnAppBarNav;
  Act := TFRMaterialAppBarAction(AppBar.Actions.Add); Act.IconMode := imSearch; Act.Hint := 'Buscar'; Act.OnClick := @OnAppBarAction;
  Act := TFRMaterialAppBarAction(AppBar.Actions.Add); Act.IconMode := imMoreVert; Act.Hint := 'Mais opções'; Act.OnClick := @OnAppBarAction;

  Y := Y + 84;
  Y := AddSection(APage, Y, 'TFRMaterialAppBar — Medium');
  GBox := TFRMaterialGroupBox.Create(Self);
  GBox.Parent := APage;
  GBox.SetBounds(PAD, Y, ContentW(APage), 112);
  GBox.Anchors := [akLeft, akTop, akRight];
  GBox.Caption := ''; GBox.ShowBorder := True;
  AppBar := TFRMaterialAppBar.Create(Self);
  AppBar.Parent := GBox; AppBar.Align := alClient;
  AppBar.Title := 'Página de Detalhes'; AppBar.NavIcon := imArrowBack; AppBar.BarSize := absMedium;
  AppBar.OnNavClick := @OnAppBarNav;
  Act := TFRMaterialAppBarAction(AppBar.Actions.Add); Act.IconMode := imShare; Act.OnClick := @OnAppBarAction;

  Y := Y + 128;
  Y := AddSection(APage, Y, 'TFRMaterialToolbar');
  GBox := TFRMaterialGroupBox.Create(Self);
  GBox.Parent := APage;
  GBox.SetBounds(PAD, Y, ContentW(APage), 64);
  GBox.Anchors := [akLeft, akTop, akRight];
  GBox.Caption := ''; GBox.ShowBorder := True;
  Toolbar := TFRMaterialToolbar.Create(Self);
  Toolbar.Parent := GBox; Toolbar.Align := alClient;
  Act := TFRMaterialAppBarAction(Toolbar.Actions.Add); Act.IconMode := imCopy; Act.Hint := 'Copiar'; Act.OnClick := @OnToolbarAction;
  Act := TFRMaterialAppBarAction(Toolbar.Actions.Add); Act.IconMode := imEdit; Act.Hint := 'Editar'; Act.OnClick := @OnToolbarAction;
  Act := TFRMaterialAppBarAction(Toolbar.Actions.Add); Act.IconMode := imDelete; Act.Hint := 'Excluir'; Act.OnClick := @OnToolbarAction;
  Act := TFRMaterialAppBarAction(Toolbar.Actions.Add); Act.IconMode := imShare; Act.Hint := 'Compartilhar'; Act.OnClick := @OnToolbarAction;

  Y := Y + 80;
  Y := AddSection(APage, Y, 'TFRMaterialNavBar');
  GBox := TFRMaterialGroupBox.Create(Self);
  GBox.Parent := APage;
  GBox.SetBounds(PAD, Y, Min(ContentW(APage), 500), 80);
  GBox.Anchors := [akLeft, akTop, akRight];
  GBox.Caption := ''; GBox.ShowBorder := True;
  NavBar := TFRMaterialNavBar.Create(Self);
  NavBar.Parent := GBox; NavBar.Align := alClient;
  NavItem := TFRMaterialNavItem(NavBar.Items.Add); NavItem.Caption := 'Início'; NavItem.IconMode := imHome;
  NavItem := TFRMaterialNavItem(NavBar.Items.Add); NavItem.Caption := 'Buscar'; NavItem.IconMode := imSearch;
  NavItem := TFRMaterialNavItem(NavBar.Items.Add); NavItem.Caption := 'Favoritos'; NavItem.IconMode := imFavorite; NavItem.Badge := '3';
  NavItem := TFRMaterialNavItem(NavBar.Items.Add); NavItem.Caption := 'Perfil'; NavItem.IconMode := imPerson;
  NavBar.ItemIndex := 0; NavBar.OnChange := @OnNavBarChange;

  Y := Y + 96;
  Y := AddSection(APage, Y, 'TFRMaterialNavDrawer');
  GBox := TFRMaterialGroupBox.Create(Self);
  GBox.Parent := APage;
  GBox.SetBounds(PAD, Y, Min(ContentW(APage), 360), 280);
  GBox.Caption := ''; GBox.ShowBorder := True;
  with TFRMaterialNavDrawer.Create(Self) do
  begin
    Parent := GBox; Align := alClient;
    HeaderTitle := 'ERP System';
    with TFRMaterialNavItem(Items.Add) do begin Caption := 'Dashboard'; IconMode := imDashboard; end;
    with TFRMaterialNavItem(Items.Add) do begin Caption := 'Pedidos'; IconMode := imEdit; Badge := '12'; end;
    with TFRMaterialNavItem(Items.Add) do begin Caption := 'Clientes'; IconMode := imPerson; end;
    with TFRMaterialNavItem(Items.Add) do begin Caption := 'Estoque'; IconMode := imList; end;
    with TFRMaterialNavItem(Items.Add) do begin Caption := 'Configurações'; IconMode := imSettings; end;
    ItemIndex := 0;
  end;

  Y := Y + 296;
  Y := AddSection(APage, Y, 'TFRMaterialNavRail');
  GBox := TFRMaterialGroupBox.Create(Self);
  GBox.Parent := APage;
  GBox.SetBounds(PAD, Y, 80, 360);
  GBox.Caption := ''; GBox.ShowBorder := True;
  with TFRMaterialNavRail.Create(Self) do
  begin
    Parent := GBox; Align := alClient;
    MenuIcon := imMenu; FabIcon := imPlus;
    with TFRMaterialNavItem(Items.Add) do begin Caption := 'Início'; IconMode := imHome; end;
    with TFRMaterialNavItem(Items.Add) do begin Caption := 'Buscar'; IconMode := imSearch; end;
    with TFRMaterialNavItem(Items.Add) do begin Caption := 'Alertas'; IconMode := imNotification; Badge := '5'; end;
    with TFRMaterialNavItem(Items.Add) do begin Caption := 'Perfil'; IconMode := imPerson; end;
    ItemIndex := 0;
  end;
end;

{ ===== Page: Surfaces ===== }

procedure TFmDemo.CreatePageSurfaces(APage: TWinControl);
var
  Y: Integer;
  Btn: TFRMaterialButton;
  GBox: TFRMaterialGroupBox;
  Div1: TFRMaterialDivider;
begin
  Y := AddSection(APage, PAD, 'TFRMaterialDialog');
  Btn := TFRMaterialButton.Create(Self);
  Btn.Parent := APage;
  Btn.SetBounds(PAD, Y, 180, BTN_H);
  Btn.Caption := 'Abrir Dialog';
  Btn.ButtonStyle := mbsFilled;
  Btn.ShowIcon := True; Btn.IconMode := imSettings;
  Btn.OnClick := @OnDialogClick;

  Y := Y + ROW_H;
  Y := AddSection(APage, Y, 'TFRMaterialSnackbar');
  Btn := TFRMaterialButton.Create(Self);
  Btn.Parent := APage;
  Btn.SetBounds(PAD, Y, 200, BTN_H);
  Btn.Caption := 'Mostrar Snackbar';
  Btn.ButtonStyle := mbsTonal;
  Btn.OnClick := @OnSnackbarClick;

  Y := Y + ROW_H;
  Y := AddSection(APage, Y, 'TFRMaterialMenu');
  Btn := TFRMaterialButton.Create(Self);
  Btn.Parent := APage;
  Btn.SetBounds(PAD, Y, 180, BTN_H);
  Btn.Caption := 'Abrir Menu';
  Btn.ButtonStyle := mbsOutlined;
  Btn.ShowIcon := True; Btn.IconMode := imMoreVert;
  Btn.OnClick := @OnMenuClick;

  Y := Y + ROW_H;
  Y := AddSection(APage, Y, 'TFRMaterialTooltip');
  Btn := TFRMaterialButton.Create(Self);
  Btn.Parent := APage;
  Btn.SetBounds(PAD, Y, 200, BTN_H);
  Btn.Caption := 'Passe o mouse aqui';
  Btn.ButtonStyle := mbsText;
  Btn.Hint := 'Tooltip de demonstração';
  Btn.ShowHint := True;

  Y := Y + ROW_H;
  Y := AddSection(APage, Y, 'TFRMaterialGroupBox + Divider');
  GBox := TFRMaterialGroupBox.Create(Self);
  GBox.Parent := APage;
  GBox.SetBounds(PAD, Y, Min(ContentW(APage), 400), 100);
  GBox.Anchors := [akLeft, akTop, akRight];
  GBox.Caption := 'Configurações'; GBox.BorderRadius := 12; GBox.ShowBorder := True;
  AddLabel(GBox, PAD, 28, 'Conteúdo dentro do GroupBox');
  Div1 := TFRMaterialDivider.Create(Self);
  Div1.Parent := GBox;
  Div1.SetBounds(PAD, 52, 368, 1);
  Div1.Anchors := [akLeft, akTop, akRight];
  AddLabel(GBox, PAD, 64, 'Separado por um TFRMaterialDivider');

  Y := Y + 116;
  Y := AddSection(APage, Y, 'TFRMaterialBottomSheet / SideSheet');
  Btn := TFRMaterialButton.Create(Self);
  Btn.Parent := APage;
  Btn.SetBounds(PAD, Y, 200, BTN_H);
  Btn.Caption := 'Bottom Sheet';
  Btn.ButtonStyle := mbsElevated;
  Btn.OnClick := @OnBottomSheetClick;

  Btn := TFRMaterialButton.Create(Self);
  Btn.Parent := APage;
  Btn.SetBounds(PAD + 216, Y, 200, BTN_H);
  Btn.Caption := 'Side Sheet';
  Btn.ButtonStyle := mbsElevated;
  Btn.OnClick := @OnSideSheetClick;

  FBottomSheet := TFRMaterialBottomSheet.Create(Self);
  FBottomSheet.Parent := Self;
  FBottomSheet.SheetHeight := 200; FBottomSheet.Height := 200;
  FBottomSheet.Left := 0; FBottomSheet.Width := ClientWidth;
  FBottomSheet.Top := ClientHeight;
  FBottomSheet.DragHandle := True;
  FBottomSheet.Visible := False;
  FBottomSheet.BringToFront;
  AddLabel(FBottomSheet, PAD, 28, 'Detalhes do Pedido #1042', True);
  AddLabel(FBottomSheet, PAD, 56, 'Cliente: João Silva — CNPJ 12.345.678/0001-90');
  AddLabel(FBottomSheet, PAD, 78, 'Valor total: R$ 3.487,50 — 12 itens');
  AddLabel(FBottomSheet, PAD, 100, 'Status: Aguardando aprovação do financeiro');
  AddLabel(FBottomSheet, PAD, 130, 'Prazo de entrega: 05/04/2026 — Transportadora XYZ');
  AddLabel(FBottomSheet, PAD, 160, 'Arraste o handle ou clique para fechar.');

  FSideSheet := TFRMaterialSideSheet.Create(Self);
  FSideSheet.Parent := Self;
  FSideSheet.SheetWidth := 300; FSideSheet.Width := 300;
  FSideSheet.Top := 0; FSideSheet.Height := ClientHeight;
  FSideSheet.Left := ClientWidth;
  FSideSheet.Visible := False;
  FSideSheet.BringToFront;
  AddLabel(FSideSheet, PAD, 24, 'Filtros Avançados', True);
  AddLabel(FSideSheet, PAD, 56, 'Período:');
  AddLabel(FSideSheet, PAD, 76, '  01/03/2026 a 31/03/2026');
  AddLabel(FSideSheet, PAD, 108, 'Vendedor:');
  AddLabel(FSideSheet, PAD, 128, '  Carlos Ferreira');
  AddLabel(FSideSheet, PAD, 160, 'Situação:');
  AddLabel(FSideSheet, PAD, 180, '  Pendentes e Em análise');
  AddLabel(FSideSheet, PAD, 212, 'Valor mínimo:');
  AddLabel(FSideSheet, PAD, 232, '  R$ 500,00');
  AddLabel(FSideSheet, PAD, 264, 'Forma de pagamento:');
  AddLabel(FSideSheet, PAD, 284, '  Boleto, PIX');
  AddLabel(FSideSheet, PAD, 320, 'Clique "Side Sheet" para fechar.');
end;

{ ===== Page: PageControl ===== }

procedure TFmDemo.CreatePagePageControl(APage: TWinControl);
var
  Y: Integer;
  Page: TFRMaterialTabPage;
  Lbl: TLabel;
begin
  Y := AddSection(APage, PAD, 'TFRMaterialPageControl — Tabs with content pages');

  FPageControl := TFRMaterialPageControl.Create(Self);
  FPageControl.Parent := APage;
  FPageControl.SetBounds(PAD, Y, ContentW(APage), 380);
  FPageControl.Anchors := [akLeft, akTop, akRight];
  FPageControl.OnChange := @OnPageControlChange;

  { Page 1: Dashboard }
  Page := TFRMaterialTabPage.Create(Self);
  Page.PageControl := FPageControl;
  Page.Caption := 'Dashboard';
  Page.IconMode := imDashboard;
  Page.ShowIcon := True;
  Lbl := TLabel.Create(Self);
  Lbl.Parent := Page;
  Lbl.SetBounds(PAD, PAD, 300, 20);
  Lbl.Caption := 'Resumo geral do sistema ERP';
  Lbl.Font.Size := 11; Lbl.Font.Style := [fsBold]; Lbl.Font.Color := MD3Colors.Primary; Lbl.Transparent := True;
  AddLabel(Page, PAD, 50, 'Vendas do mês: R$ 142.350,80');
  AddLabel(Page, PAD, 72, 'Pedidos pendentes: 23');
  AddLabel(Page, PAD, 94, 'Clientes ativos: 1.247');
  AddLabel(Page, PAD, 116, 'Produtos em estoque: 8.432 itens');
  with TFRMaterialLinearProgress.Create(Self) do
  begin
    Parent := Page;
    SetBounds(PAD, 150, 400, 4);
    Anchors := [akLeft, akTop, akRight];
    Value := 0.72;
  end;
  AddLabel(Page, PAD, 162, 'Meta mensal: 72% atingida');

  { Page 2: Cadastros }
  Page := TFRMaterialTabPage.Create(Self);
  Page.PageControl := FPageControl;
  Page.Caption := 'Cadastros';
  Page.IconMode := imPerson;
  Page.ShowIcon := True;
  Lbl := TLabel.Create(Self);
  Lbl.Parent := Page;
  Lbl.SetBounds(PAD, PAD, 300, 20);
  Lbl.Caption := 'Gerenciamento de cadastros';
  Lbl.Font.Size := 11; Lbl.Font.Style := [fsBold]; Lbl.Font.Color := MD3Colors.Primary; Lbl.Transparent := True;
  with TFRMaterialEdit.Create(Self) do
  begin
    Parent := Page;
    SetBounds(PAD, 50, 300, ROW_H);
    Caption := 'Buscar cadastro'; TextHint := 'Nome ou código...';
    Variant := mvOutlined; ShowClearButton := True;
  end;
  with TFRMaterialButton.Create(Self) do
  begin
    Parent := Page;
    SetBounds(PAD + 316, 58, BTN_W, BTN_H);
    Caption := 'Novo cliente'; ButtonStyle := mbsFilled; ShowIcon := True; IconMode := imPlus;
  end;
  with TFRMaterialCheckBox.Create(Self) do begin Parent := Page; SetBounds(PAD, 120, 220, 24); Caption := 'Apenas ativos'; Checked := True; end;
  with TFRMaterialCheckBox.Create(Self) do begin Parent := Page; SetBounds(PAD + 230, 120, 220, 24); Caption := 'Com pendências'; end;

  { Page 3: Financeiro }
  Page := TFRMaterialTabPage.Create(Self);
  Page.PageControl := FPageControl;
  Page.Caption := 'Financeiro';
  Page.IconMode := imStar;
  Page.ShowIcon := True;
  Lbl := TLabel.Create(Self);
  Lbl.Parent := Page;
  Lbl.SetBounds(PAD, PAD, 300, 20);
  Lbl.Caption := 'Controle financeiro';
  Lbl.Font.Size := 11; Lbl.Font.Style := [fsBold]; Lbl.Font.Color := MD3Colors.Primary; Lbl.Transparent := True;
  with TFRMaterialCurrencyEdit.Create(Self) do begin Parent := Page; SetBounds(PAD, 50, 220, ROW_H); Caption := 'Valor total'; Variant := mvOutlined; Value := 15780.90; end;
  with TFRMaterialDateEdit.Create(Self) do begin Parent := Page; SetBounds(PAD + 236, 50, 200, ROW_H); Caption := 'Vencimento'; Variant := mvOutlined; Date := Now + 30; end;
  with TFRMaterialSwitch.Create(Self) do begin Parent := Page; SetBounds(PAD, 130, 52, 32); Checked := True; end;
  AddLabel(Page, PAD + 64, 136, 'Gerar boleto automaticamente');

  FPageControl.ActivePageIndex := 0;
end;

{ ===== Page: VirtualDataGrid ===== }

procedure TFmDemo.CreatePageVirtualGrid(APage: TWinControl);
var
  Y: Integer;
  Node: PVirtualNode;
begin
  Y := AddSection(APage, PAD, 'TFRMaterialVirtualDataGrid — Sort, Filter, ZebraStripes');

  FVirtualGrid := TFRMaterialVirtualDataGrid.Create(Self);
  FVirtualGrid.Parent := APage;
  FVirtualGrid.SetBounds(PAD, Y, ContentW(APage), 420);
  FVirtualGrid.Anchors := [akLeft, akTop, akRight];
  FVirtualGrid.Density := ddNormal;
  FVirtualGrid.ZebraStripes := True;
  FVirtualGrid.AutoSort := True;
  FVirtualGrid.FilterEnabled := True;
  FVirtualGrid.OnSortColumn := @OnVGridSortColumn;

  with FVirtualGrid.Header.Columns.Add do begin Text := 'Código'; Width := 80; end;
  with FVirtualGrid.Header.Columns.Add do begin Text := 'Produto'; Width := 220; end;
  with FVirtualGrid.Header.Columns.Add do begin Text := 'Categoria'; Width := 140; end;
  with FVirtualGrid.Header.Columns.Add do begin Text := 'Estoque'; Width := 90; Alignment := taRightJustify; end;
  with FVirtualGrid.Header.Columns.Add do begin Text := 'Preço Unit.'; Width := 100; Alignment := taRightJustify; end;

  FVirtualGrid.Header.Options := FVirtualGrid.Header.Options + [hoVisible];
  FVirtualGrid.TreeOptions.PaintOptions := FVirtualGrid.TreeOptions.PaintOptions + [toShowRoot];

  FVirtualGrid.BeginUpdate;
  try
    Node := FVirtualGrid.AddChild(nil); FVirtualGrid.Text[Node, 0] := '001'; FVirtualGrid.Text[Node, 1] := 'Monitor LCD 24"'; FVirtualGrid.Text[Node, 2] := 'Informática'; FVirtualGrid.Text[Node, 3] := '12'; FVirtualGrid.Text[Node, 4] := 'R$ 850,00';
    Node := FVirtualGrid.AddChild(nil); FVirtualGrid.Text[Node, 0] := '002'; FVirtualGrid.Text[Node, 1] := 'Teclado Mecânico RGB'; FVirtualGrid.Text[Node, 2] := 'Informática'; FVirtualGrid.Text[Node, 3] := '45'; FVirtualGrid.Text[Node, 4] := 'R$ 250,00';
    Node := FVirtualGrid.AddChild(nil); FVirtualGrid.Text[Node, 0] := '003'; FVirtualGrid.Text[Node, 1] := 'Mouse Óptico 3200DPI'; FVirtualGrid.Text[Node, 2] := 'Informática'; FVirtualGrid.Text[Node, 3] := '89'; FVirtualGrid.Text[Node, 4] := 'R$ 85,00';
    Node := FVirtualGrid.AddChild(nil); FVirtualGrid.Text[Node, 0] := '004'; FVirtualGrid.Text[Node, 1] := 'Cabo HDMI 2m'; FVirtualGrid.Text[Node, 2] := 'Cabos'; FVirtualGrid.Text[Node, 3] := '120'; FVirtualGrid.Text[Node, 4] := 'R$ 25,00';
    Node := FVirtualGrid.AddChild(nil); FVirtualGrid.Text[Node, 0] := '005'; FVirtualGrid.Text[Node, 1] := 'Parafuso M6x20'; FVirtualGrid.Text[Node, 2] := 'Ferramentas'; FVirtualGrid.Text[Node, 3] := '23'; FVirtualGrid.Text[Node, 4] := 'R$ 0,50';
    Node := FVirtualGrid.AddChild(nil); FVirtualGrid.Text[Node, 0] := '006'; FVirtualGrid.Text[Node, 1] := 'Chave Phillips #2'; FVirtualGrid.Text[Node, 2] := 'Ferramentas'; FVirtualGrid.Text[Node, 3] := '67'; FVirtualGrid.Text[Node, 4] := 'R$ 12,90';
    Node := FVirtualGrid.AddChild(nil); FVirtualGrid.Text[Node, 0] := '007'; FVirtualGrid.Text[Node, 1] := 'Lâmpada LED 12W'; FVirtualGrid.Text[Node, 2] := 'Iluminação'; FVirtualGrid.Text[Node, 3] := '200'; FVirtualGrid.Text[Node, 4] := 'R$ 8,50';
    Node := FVirtualGrid.AddChild(nil); FVirtualGrid.Text[Node, 0] := '008'; FVirtualGrid.Text[Node, 1] := 'Tinta Acrílica 3.6L'; FVirtualGrid.Text[Node, 2] := 'Pintura'; FVirtualGrid.Text[Node, 3] := '34'; FVirtualGrid.Text[Node, 4] := 'R$ 89,90';
    Node := FVirtualGrid.AddChild(nil); FVirtualGrid.Text[Node, 0] := '009'; FVirtualGrid.Text[Node, 1] := 'Fita Isolante 20m'; FVirtualGrid.Text[Node, 2] := 'Material Elétrico'; FVirtualGrid.Text[Node, 3] := '150'; FVirtualGrid.Text[Node, 4] := 'R$ 5,90';
    Node := FVirtualGrid.AddChild(nil); FVirtualGrid.Text[Node, 0] := '010'; FVirtualGrid.Text[Node, 1] := 'Webcam Full HD'; FVirtualGrid.Text[Node, 2] := 'Informática'; FVirtualGrid.Text[Node, 3] := '28'; FVirtualGrid.Text[Node, 4] := 'R$ 189,00';
    Node := FVirtualGrid.AddChild(nil); FVirtualGrid.Text[Node, 0] := '011'; FVirtualGrid.Text[Node, 1] := 'Mangueira 30m'; FVirtualGrid.Text[Node, 2] := 'Hidráulica'; FVirtualGrid.Text[Node, 3] := '15'; FVirtualGrid.Text[Node, 4] := 'R$ 45,00';
    Node := FVirtualGrid.AddChild(nil); FVirtualGrid.Text[Node, 0] := '012'; FVirtualGrid.Text[Node, 1] := 'Nobreak 1200VA'; FVirtualGrid.Text[Node, 2] := 'Informática'; FVirtualGrid.Text[Node, 3] := '8'; FVirtualGrid.Text[Node, 4] := 'R$ 620,00';
  finally
    FVirtualGrid.EndUpdate;
  end;

  Y := Y + 440;
  Y := AddSection(APage, Y, 'Density Controls');
  with TFRMaterialSegmentedButton.Create(Self) do
  begin
    Parent := APage;
    SetBounds(PAD, Y, 360, BTN_H);
    Items.Add('Compact'); Items.Add('Normal'); Items.Add('Dense');
    ItemIndex := 1;
    OnChange := @OnSegmentChange;
    Tag := 999;
  end;
end;

{ ===== Event Handlers ===== }

procedure TFmDemo.UpdateMainTabs;
const
  CTabNames: array[0..4, 0..2] of string = (
    ('Buttons', 'FABs', ''),
    ('Toggles', 'Chips', ''),
    ('Edits', 'Inputs', 'Progress'),
    ('Listas & Tabs', 'Tree & Data', 'VirtualDataGrid'),
    ('Navegação', 'Superfícies', 'PageControl'));
  CTabCount: array[0..4] of Integer = (2, 2, 3, 3, 3);
var
  Nav, I: Integer;
  OldHandler: TNotifyEvent;
begin
  Nav := FMainNavBar.ItemIndex;
  if (Nav < 0) or (Nav > 4) then Nav := 0;
  OldHandler := FMainTabs.OnChange;
  FMainTabs.OnChange := nil;
  FMainTabs.Tabs.Clear;
  for I := 0 to CTabCount[Nav] - 1 do
    FMainTabs.Tabs.Add.Caption := CTabNames[Nav, I];
  FMainTabs.TabIndex := 0;
  FMainTabs.OnChange := OldHandler;
  FMainTabs.Invalidate;
end;

procedure TFmDemo.ShowPage(AIndex: Integer);
var
  I: Integer;
begin
  if (AIndex < 0) or (AIndex > PAGE_COUNT - 1) then AIndex := 0;
  for I := 0 to PAGE_COUNT - 1 do
    FContentPanels[I].Visible := (I = AIndex);
  FStatusBar.SimpleText := FContentPanels[AIndex].Hint;
end;

procedure TFmDemo.ApplyTheme;
var
  I: Integer;
begin
  FThemeManager.DarkMode := FDarkMode;
  FThemeManager.Palette := FCurrentPalette;
  Color := MD3Colors.Surface;
  for I := 0 to PAGE_COUNT - 1 do
    FContentPanels[I].Color := MD3Colors.Surface;
end;

procedure TFmDemo.OnMainDarkToggle(Sender: TObject);
begin
  FDarkMode := not FDarkMode;
  if FDarkMode then FDarkAction.IconMode := imLightMode
  else FDarkAction.IconMode := imNightlight;
  ApplyTheme;
  FStatusBar.SimpleText := MD3PaletteName(FCurrentPalette) + ' — ' + IfThen(FDarkMode, 'Dark', 'Light');
end;

procedure TFmDemo.OnMainTabChange(Sender: TObject);
const
  CPageBase: array[0..4] of Integer = (0, 2, 4, 7, 10);
var
  Nav, PageIdx: Integer;
begin
  Nav := FMainNavBar.ItemIndex;
  if (Nav < 0) or (Nav > 4) then Nav := 0;
  PageIdx := CPageBase[Nav] + FMainTabs.TabIndex;
  if PageIdx > PAGE_COUNT - 1 then PageIdx := PAGE_COUNT - 1;
  ShowPage(PageIdx);
end;

procedure TFmDemo.OnMainNavChange(Sender: TObject);
const
  CPageBase: array[0..4] of Integer = (0, 2, 4, 7, 10);
var
  Nav: Integer;
begin
  Nav := FMainNavBar.ItemIndex;
  if (Nav < 0) or (Nav > 4) then Nav := 0;
  UpdateMainTabs;
  ShowPage(CPageBase[Nav]);
end;

procedure TFmDemo.OnMainNavClick(Sender: TObject);
begin
  FSnackbar.Show('Menu de navegação', '');
  FStatusBar.SimpleText := 'AppBar: Menu';
end;

procedure TFmDemo.OnPaletteClick(Sender: TObject);
var Pt: TPoint;
begin
  Pt := FMainAppBar.ClientToScreen(Point(FMainAppBar.Width - 120, FMainAppBar.Height));
  FPaletteMenu.Popup(Pt.X, Pt.Y);
end;

procedure TFmDemo.OnPaletteMenuAction(Sender: TObject);
var MI: TMenuItem;
begin
  MI := TMenuItem(Sender);
  FCurrentPalette := TFRMDPalette(MI.Tag);
  MI.Checked := True;
  ApplyTheme;
  FStatusBar.SimpleText := 'Paleta: ' + MD3PaletteName(FCurrentPalette) + ' — ' + IfThen(FDarkMode, 'Dark', 'Light');
end;

procedure TFmDemo.OnButtonClick(Sender: TObject);
begin
  if Sender is TFRMaterialButton then
    FStatusBar.SimpleText := 'Clicou: ' + TFRMaterialButton(Sender).Caption
  else
    FStatusBar.SimpleText := 'Clicou: Button';
end;

procedure TFmDemo.OnDialogClick(Sender: TObject);
var R: TFRMDDialogResult;
begin
  R := FDialog.Execute;
  case R of
    drYes:    FStatusBar.SimpleText := 'Dialog → Sim';
    drNo:     FStatusBar.SimpleText := 'Dialog → Não';
    drCancel: FStatusBar.SimpleText := 'Dialog → Cancelar';
  else        FStatusBar.SimpleText := 'Dialog → Fechado';
  end;
end;

procedure TFmDemo.OnSnackbarClick(Sender: TObject);
begin
  FSnackbar.Show('Operação realizada com sucesso!', 'DESFAZER');
end;

procedure TFmDemo.OnSnackbarAction(Sender: TObject);
begin
  FStatusBar.SimpleText := 'Snackbar: Ação acionada!';
end;

procedure TFmDemo.OnMenuClick(Sender: TObject);
var Pt: TPoint;
begin
  Pt := TFRMaterialButton(Sender).ClientToScreen(Point(0, TFRMaterialButton(Sender).Height));
  FMenu.Popup(Pt.X, Pt.Y);
end;

procedure TFmDemo.OnMenuItemClick(Sender: TObject);
begin
  if Sender is TFRMaterialMenuItem then
    FStatusBar.SimpleText := 'Menu: ' + TFRMaterialMenuItem(Sender).Caption;
end;

procedure TFmDemo.OnSliderChange(Sender: TObject);
begin
  if Assigned(FSliderValueLbl) then
    FSliderValueLbl.Caption := Format('Valor: %.0f', [TFRMaterialSlider(Sender).Value]);
end;

procedure TFmDemo.OnTimePickerChange(Sender: TObject);
begin
  if Assigned(FTimePickerLbl) and Assigned(FTimePicker) then
    FTimePickerLbl.Caption := 'Hora: ' + FTimePicker.TimeStr;
end;

procedure TFmDemo.OnProgressTimer(Sender: TObject);
var V: Double;
begin
  if not Assigned(FLinearProgress) then Exit;
  V := FLinearProgress.Value + 0.01;
  if V > 1.0 then V := 0;
  FLinearProgress.Value := V;
  if Assigned(FCircularProgress) then FCircularProgress.Value := V;
end;

procedure TFmDemo.OnBottomSheetClick(Sender: TObject);
begin
  if Assigned(FBottomSheet) then FBottomSheet.Toggle;
end;

procedure TFmDemo.OnSideSheetClick(Sender: TObject);
begin
  if Assigned(FSideSheet) then FSideSheet.Toggle;
end;

procedure TFmDemo.OnListSelect(Sender: TObject);
var LV: TFRMaterialListView;
begin
  LV := TFRMaterialListView(Sender);
  if (LV.ItemIndex >= 0) and (LV.ItemIndex < LV.Items.Count) then
    FStatusBar.SimpleText := 'Selecionou: ' + TFRMaterialListItem(LV.Items[LV.ItemIndex]).Headline;
end;

procedure TFmDemo.OnTabChange(Sender: TObject);
var T: TFRMaterialTabs;
begin
  T := TFRMaterialTabs(Sender);
  if (T.TabIndex >= 0) and (T.TabIndex < T.Tabs.Count) then
    FStatusBar.SimpleText := 'Tab: ' + TFRMaterialTabItem(T.Tabs[T.TabIndex]).Caption;
end;

procedure TFmDemo.OnIconButtonClick(Sender: TObject);
begin
  if Sender is TFRMaterialButtonIcon then
    FStatusBar.SimpleText := 'IconButton: ' + TFRMaterialButtonIcon(Sender).Hint
  else
    FStatusBar.SimpleText := 'IconButton clicado';
end;

procedure TFmDemo.OnIconToggle(Sender: TObject);
begin
  if Sender is TFRMaterialButtonIcon then
    FStatusBar.SimpleText := 'Toggle: ' + IfThen(TFRMaterialButtonIcon(Sender).Toggled, 'Ativado', 'Desativado');
end;

procedure TFmDemo.OnSplitClick(Sender: TObject);
begin
  if Sender is TFRMaterialButton then
    FStatusBar.SimpleText := 'SplitButton: ' + TFRMaterialButton(Sender).Caption;
end;

procedure TFmDemo.OnFABClick(Sender: TObject);
begin
  FSnackbar.Show('FAB acionado!', 'OK');
  FStatusBar.SimpleText := 'FAB clicado';
end;

procedure TFmDemo.OnExtFABClick(Sender: TObject);
begin
  if Sender is TFRMaterialExtendedFAB then
    FStatusBar.SimpleText := 'ExtFAB: ' + TFRMaterialExtendedFAB(Sender).Caption
  else
    FStatusBar.SimpleText := 'Extended FAB clicado';
end;

procedure TFmDemo.OnSwitchChange(Sender: TObject);
begin
  FStatusBar.SimpleText := 'Switch → ' + IfThen(TFRMaterialSwitch(Sender).Checked, 'Ligado', 'Desligado');
end;

procedure TFmDemo.OnCheckChange(Sender: TObject);
begin
  FStatusBar.SimpleText := 'CheckBox "' + TFRMaterialCheckBox(Sender).Caption + '" → ' +
    IfThen(TFRMaterialCheckBox(Sender).Checked, 'Marcado', 'Desmarcado');
end;

procedure TFmDemo.OnRadioChange(Sender: TObject);
begin
  if TFRMaterialRadioButton(Sender).Checked then
    FStatusBar.SimpleText := 'Pagamento: ' + TFRMaterialRadioButton(Sender).Caption;
end;

procedure TFmDemo.OnChipClick(Sender: TObject);
var Ch: TFRMaterialChip;
begin
  Ch := TFRMaterialChip(Sender);
  FStatusBar.SimpleText := 'Chip "' + Ch.Caption + '" → ' + IfThen(Ch.Selected, 'Selecionado', 'Desmarcado');
end;

procedure TFmDemo.OnChipDelete(Sender: TObject);
var Ch: TFRMaterialChip; Nome: string;
begin
  Ch := TFRMaterialChip(Sender);
  Nome := Ch.Caption;
  Ch.Visible := False;
  FSnackbar.Show('Chip "' + Nome + '" removido', 'DESFAZER');
  FStatusBar.SimpleText := 'Chip removido: ' + Nome;
end;

procedure TFmDemo.OnSegmentChange(Sender: TObject);
var Seg: TFRMaterialSegmentedButton;
begin
  Seg := TFRMaterialSegmentedButton(Sender);
  if (Seg.Tag = 999) and Assigned(FVirtualGrid) then
  begin
    case Seg.ItemIndex of
      0: FVirtualGrid.Density := ddCompact;
      1: FVirtualGrid.Density := ddNormal;
      2: FVirtualGrid.Density := ddDense;
    end;
    FStatusBar.SimpleText := 'VirtualGrid Density: ' + Seg.Items[Seg.ItemIndex];
    Exit;
  end;
  if (Seg.ItemIndex >= 0) and (Seg.ItemIndex < Seg.Items.Count) then
    FStatusBar.SimpleText := 'Segmento: ' + Seg.Items[Seg.ItemIndex]
  else
    FStatusBar.SimpleText := 'Segmento alterado';
end;

procedure TFmDemo.OnNavBarChange(Sender: TObject);
var Nav: TFRMaterialNavBar;
begin
  Nav := TFRMaterialNavBar(Sender);
  if (Nav.ItemIndex >= 0) and (Nav.ItemIndex < Nav.Items.Count) then
    FStatusBar.SimpleText := 'NavBar: ' + TFRMaterialNavItem(Nav.Items[Nav.ItemIndex]).Caption;
end;

procedure TFmDemo.OnAppBarNav(Sender: TObject);
begin
  FSnackbar.Show('Navegação do AppBar acionada', '');
  FStatusBar.SimpleText := 'AppBar: Nav icon clicado';
end;

procedure TFmDemo.OnAppBarAction(Sender: TObject);
begin
  if Sender is TFRMaterialAppBarAction then
    FStatusBar.SimpleText := 'AppBar Action: ' + TFRMaterialAppBarAction(Sender).Hint
  else
    FStatusBar.SimpleText := 'AppBar Action clicada';
end;

procedure TFmDemo.OnToolbarAction(Sender: TObject);
begin
  if Sender is TFRMaterialAppBarAction then
    FStatusBar.SimpleText := 'Toolbar: ' + TFRMaterialAppBarAction(Sender).Hint
  else
    FStatusBar.SimpleText := 'Toolbar Action clicada';
end;

procedure TFmDemo.OnPageControlChange(Sender: TObject);
begin
  if Assigned(FPageControl) and (FPageControl.ActivePageIndex >= 0) then
    FStatusBar.SimpleText := 'PageControl: ' + FPageControl.ActivePage.Caption;
end;

procedure TFmDemo.OnVGridSortColumn(Sender: TObject; ACol: Integer;
  var ADirection: TFRMDSortDirection);
begin
  FStatusBar.SimpleText := Format('VirtualGrid: Sort col %d', [ACol]);
end;

{ ===== TreeView event handlers ===== }

procedure ExpandCollapseAll(ANodes: TFRMaterialTreeNodes; AExpand: Boolean);
var I: Integer; Node: TFRMaterialTreeNode;
begin
  for I := 0 to ANodes.Count - 1 do
  begin
    Node := ANodes[I];
    Node.Expanded := AExpand;
    if Node.Children.Count > 0 then
      ExpandCollapseAll(Node.Children, AExpand);
  end;
end;

procedure TFmDemo.OnTreeAddRoot(Sender: TObject);
var S: string; Node: TFRMaterialTreeNode;
begin
  S := Trim(FTreeEdit.Text);
  if S = '' then begin FStatusBar.SimpleText := 'Digite um nome para o nó.'; Exit; end;
  Node := TFRMaterialTreeNode(FTreeView.Nodes.Add);
  Node.Caption := S; Node.IconMode := imFolder;
  FTreeEdit.Text := '';
  FTreeView.Invalidate;
  FStatusBar.SimpleText := 'Nó raiz "' + S + '" adicionado.';
end;

procedure TFmDemo.OnTreeAddChild(Sender: TObject);
var S: string; Node: TFRMaterialTreeNode;
begin
  S := Trim(FTreeEdit.Text);
  if S = '' then begin FStatusBar.SimpleText := 'Digite um nome para o nó filho.'; Exit; end;
  if FTreeView.SelectedNode = nil then begin FStatusBar.SimpleText := 'Selecione um nó pai primeiro.'; Exit; end;
  Node := TFRMaterialTreeNode(FTreeView.SelectedNode.Children.Add);
  Node.Caption := S; Node.IconMode := imList;
  FTreeView.SelectedNode.Expanded := True;
  FTreeEdit.Text := '';
  FTreeView.Invalidate;
  FStatusBar.SimpleText := 'Nó filho "' + S + '" adicionado em "' + FTreeView.SelectedNode.Caption + '".';
end;

procedure TFmDemo.OnTreeDelete(Sender: TObject);
var Sel: TFRMaterialTreeNode; Nodes: TFRMaterialTreeNodes; S: string;
begin
  Sel := FTreeView.SelectedNode;
  if Sel = nil then begin FStatusBar.SimpleText := 'Selecione um nó para excluir.'; Exit; end;
  S := Sel.Caption;
  Nodes := TFRMaterialTreeNodes(Sel.Collection);
  FTreeView.SelectedNode := nil;
  Nodes.Delete(Sel.Index);
  FTreeView.Invalidate;
  FTreeSelLabel.Caption := 'Nenhum nó selecionado';
  FStatusBar.SimpleText := 'Nó "' + S + '" excluído.';
end;

procedure TFmDemo.OnTreeRename(Sender: TObject);
var S: string;
begin
  S := Trim(FTreeEdit.Text);
  if S = '' then begin FStatusBar.SimpleText := 'Digite o novo nome.'; Exit; end;
  if FTreeView.SelectedNode = nil then begin FStatusBar.SimpleText := 'Selecione um nó para renomear.'; Exit; end;
  FStatusBar.SimpleText := 'Nó "' + FTreeView.SelectedNode.Caption + '" renomeado para "' + S + '".';
  FTreeView.SelectedNode.Caption := S;
  FTreeEdit.Text := '';
  FTreeView.Invalidate;
  FTreeSelLabel.Caption := 'Selecionado: ' + S;
end;

procedure TFmDemo.OnTreeExpandAll(Sender: TObject);
begin
  ExpandCollapseAll(FTreeView.Nodes, True);
  FTreeView.Invalidate;
  FStatusBar.SimpleText := 'Todos os nós expandidos.';
end;

procedure TFmDemo.OnTreeCollapseAll(Sender: TObject);
begin
  ExpandCollapseAll(FTreeView.Nodes, False);
  FTreeView.Invalidate;
  FStatusBar.SimpleText := 'Todos os nós recolhidos.';
end;

procedure TFmDemo.OnTreeSelChange(Sender: TObject);
begin
  if FTreeView.SelectedNode <> nil then
  begin
    FTreeSelLabel.Caption := 'Selecionado: ' + FTreeView.SelectedNode.Caption;
    FTreeEdit.Text := FTreeView.SelectedNode.Caption;
  end
  else
    FTreeSelLabel.Caption := 'Nenhum nó selecionado';
end;

end.

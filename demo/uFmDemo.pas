unit uFmDemo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ComCtrls, StdCtrls, ExtCtrls,
  Menus, StrUtils,
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
  FRMaterialMasks,
  FRMaterialIcons;

type

  { TFmDemo }

  TFmDemo = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    FMainAppBar: TFRMaterialAppBar;
    FMainTabs: TFRMaterialTabs;
    FMainNavBar: TFRMaterialNavBar;
    FContentPanels: array[0..10] of TScrollBox;
    FDarkMode: Boolean;
    FDarkAction: TFRMaterialAppBarAction;
    FPaletteMenu: TPopupMenu;
    FCurrentPalette: TFRMDPalette;
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

    procedure CreatePageButtons(APage: TWinControl);
    procedure CreatePageFABs(APage: TWinControl);
    procedure CreatePageToggles(APage: TWinControl);
    procedure CreatePageChips(APage: TWinControl);
    procedure CreatePageEdits(APage: TWinControl);
    procedure CreatePageInputs(APage: TWinControl);
    procedure CreatePageProgress(APage: TWinControl);
    procedure CreatePageListTabs(APage: TWinControl);
    procedure CreatePageNavigation(APage: TWinControl);
    procedure CreatePageSurfaces(APage: TWinControl);
    procedure CreatePageDocs(APage: TWinControl);

    function AddLabel(AParent: TWinControl; X, Y: Integer; const AText: string;
      ABold: Boolean = False): TLabel;
    function AddSection(AParent: TWinControl; Y: Integer;
      const ATitle: string): Integer;

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
  public
  end;

var
  FmDemo: TFmDemo;

implementation

{$R *.lfm}

{ ----- Helpers ----- }

function TFmDemo.AddLabel(AParent: TWinControl; X, Y: Integer;
  const AText: string; ABold: Boolean): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.Parent := AParent;
  Result.Left := X;
  Result.Top := Y;
  Result.Caption := AText;
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
  if Y > 16 then
  begin
    Div1 := TFRMaterialDivider.Create(Self);
    Div1.Parent := AParent;
    Div1.SetBounds(16, Y, AParent.ClientWidth - 32, 1);
    Div1.Anchors := [akLeft, akTop, akRight];
    Y := Y + 12;
  end;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := AParent;
  Lbl.Left := 16;
  Lbl.Top := Y;
  Lbl.Caption := ATitle;
  Lbl.Font.Size := 12;
  Lbl.Font.Style := [fsBold];
  Lbl.Font.Color := MD3Colors.Primary;
  Result := Y + Lbl.Height + 12;
end;

{ ----- Main ----- }

procedure TFmDemo.FormCreate(Sender: TObject);
const
  CPageNames: array[0..10] of string = (
    'Buttons', 'FABs', 'Toggles', 'Chips', 'Edits',
    'Inputs', 'Progress', 'Listas & Tabs', 'Navegação',
    'Superfícies', 'Documentação');
var
  I: Integer;
  NI: TFRMaterialNavItem;
  MI: TMenuItem;
begin
 try
  Color := MD3Colors.Surface;
  FDarkMode := False;
  FCurrentPalette := mpBaseline;

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
  for I := 10 downto 0 do
  begin
    FContentPanels[I] := TScrollBox.Create(Self);
    FContentPanels[I].Parent := Self;
    FContentPanels[I].Align := alClient;
    FContentPanels[I].BorderStyle := bsNone;
    FContentPanels[I].Color := MD3Colors.Surface;
    FContentPanels[I].Visible := (I = 0);
    FContentPanels[I].Hint := CPageNames[I];
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
  CreatePageNavigation(FContentPanels[8]);
  CreatePageSurfaces(FContentPanels[9]);
  CreatePageDocs(FContentPanels[10]);

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
  with TFRMaterialMenuItem(FMenu.Items.Add) do
  begin
    Caption := 'Copiar';
    IconMode := imCopy;
    OnClick := @OnMenuItemClick;
  end;
  with TFRMaterialMenuItem(FMenu.Items.Add) do
  begin
    Caption := 'Editar';
    IconMode := imEdit;
    OnClick := @OnMenuItemClick;
  end;
  with TFRMaterialMenuItem(FMenu.Items.Add) do
  begin
    Caption := 'Compartilhar';
    IconMode := imShare;
    OnClick := @OnMenuItemClick;
  end;
  with TFRMaterialMenuItem(FMenu.Items.Add) do
  begin
    Caption := 'Favoritar';
    IconMode := imStar;
    OnClick := @OnMenuItemClick;
  end;
  with TFRMaterialMenuItem(FMenu.Items.Add) do
  begin
    IsSeparator := True;
  end;
  with TFRMaterialMenuItem(FMenu.Items.Add) do
  begin
    Caption := 'Baixar PDF';
    IconMode := imDownload;
    OnClick := @OnMenuItemClick;
  end;
  with TFRMaterialMenuItem(FMenu.Items.Add) do
  begin
    Caption := 'Anexar arquivo';
    IconMode := imAttach;
    OnClick := @OnMenuItemClick;
  end;
  with TFRMaterialMenuItem(FMenu.Items.Add) do
  begin
    IsSeparator := True;
  end;
  with TFRMaterialMenuItem(FMenu.Items.Add) do
  begin
    Caption := 'Excluir';
    IconMode := imDelete;
    OnClick := @OnMenuItemClick;
  end;

  FTooltip := TFRMaterialTooltip.Create(Self);
  FTooltip.Text := 'Tooltip de demonstração';
 except
   on E: Exception do
     Application.MessageBox(PChar('Erro no FormCreate: ' + E.Message), 'Erro', 0);
 end;
end;

{ ===== Page: Buttons ===== }

procedure TFmDemo.CreatePageButtons(APage: TWinControl);
var
  Y: Integer;
  Btn: TFRMaterialButton;
  BtnI: TFRMaterialButtonIcon;
  Split: TFRMaterialSplitButton;
  Style: TFRMDButtonStyle;
  IStyle: TFRMDIconButtonStyle;
  StyleNames: array[TFRMDButtonStyle] of string = ('Filled', 'Outlined', 'Text', 'Elevated', 'Tonal');
  IStyleNames: array[TFRMDIconButtonStyle] of string = ('Standard', 'Filled', 'FilledTonal', 'Outlined');
  X: Integer;
begin
  Y := AddSection(APage, 16, 'TFRMaterialButton (5 styles)');
  X := 24;
  for Style := Low(TFRMDButtonStyle) to High(TFRMDButtonStyle) do
  begin
    Btn := TFRMaterialButton.Create(Self);
    Btn.Parent := APage;
    Btn.SetBounds(X, Y, 120, 40);
    Btn.Caption := StyleNames[Style];
    Btn.ButtonStyle := Style;
    Btn.OnClick := @OnButtonClick;
    X := X + 132;
  end;

  Y := Y + 56;
  Y := AddSection(APage, Y, 'TFRMaterialButton with Icon');
  X := 24;
  for Style := Low(TFRMDButtonStyle) to High(TFRMDButtonStyle) do
  begin
    Btn := TFRMaterialButton.Create(Self);
    Btn.Parent := APage;
    Btn.SetBounds(X, Y, 140, 40);
    Btn.Caption := StyleNames[Style];
    Btn.ButtonStyle := Style;
    Btn.ShowIcon := True;
    Btn.IconMode := imStar;
    Btn.OnClick := @OnButtonClick;
    X := X + 152;
  end;

  Y := Y + 56;
  Y := AddSection(APage, Y, 'TFRMaterialButtonIcon (4 styles)');
  X := 24;
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
  X := 24;
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
  Split.SetBounds(24, Y, 180, 40);
  Split.Caption := 'Ações';
  Split.ButtonStyle := mbsFilled;
  Split.OnClick := @OnSplitClick;

  Split := TFRMaterialSplitButton.Create(Self);
  Split.Parent := APage;
  Split.SetBounds(220, Y, 180, 40);
  Split.Caption := 'Opções';
  Split.ButtonStyle := mbsOutlined;
  Split.OnClick := @OnSplitClick;

  Y := Y + 56;
  Y := AddSection(APage, Y, 'Disabled');
  Btn := TFRMaterialButton.Create(Self);
  Btn.Parent := APage;
  Btn.SetBounds(24, Y, 120, 40);
  Btn.Caption := 'Disabled';
  Btn.Enabled := False;

  BtnI := TFRMaterialButtonIcon.Create(Self);
  BtnI.Parent := APage;
  BtnI.SetBounds(160, Y, 48, 48);
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
  Y := AddSection(APage, 16, 'TFRMaterialFAB (3 sizes)');
  X := 24;
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
  X := 24;
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
  EFAB.SetBounds(24, Y, 180, 56);
  EFAB.Caption := 'Novo item';
  EFAB.IconMode := imPlus;
  EFAB.ShowIcon := True;
  EFAB.OnClick := @OnExtFABClick;

  EFAB := TFRMaterialExtendedFAB.Create(Self);
  EFAB.Parent := APage;
  EFAB.SetBounds(220, Y, 180, 56);
  EFAB.Caption := 'Compor';
  EFAB.IconMode := imEdit;
  EFAB.ShowIcon := True;
  EFAB.OnClick := @OnExtFABClick;

  EFAB := TFRMaterialExtendedFAB.Create(Self);
  EFAB.Parent := APage;
  EFAB.SetBounds(416, Y, 160, 56);
  EFAB.Caption := 'Sem ícone';
  EFAB.ShowIcon := False;
  EFAB.OnClick := @OnExtFABClick;

  Y := Y + 76;
  Y := AddSection(APage, Y, 'TFRMaterialFABMenu (Speed Dial)');
  with TFRMaterialFABMenu.Create(Self) do
  begin
    Parent := APage;
    SetBounds(24, Y, 56, 250);
    IconMode := imPlus;
    with TFRMaterialFABMenuItem(Items.Add) do
    begin
      Caption := 'Novo pedido';
      IconMode := imEdit;
    end;
    with TFRMaterialFABMenuItem(Items.Add) do
    begin
      Caption := 'Novo cliente';
      IconMode := imPerson;
    end;
    with TFRMaterialFABMenuItem(Items.Add) do
    begin
      Caption := 'Importar';
      IconMode := imUpload;
    end;
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
  Y := AddSection(APage, 16, 'TFRMaterialSwitch');

  SW := TFRMaterialSwitch.Create(Self);
  SW.Parent := APage;
  SW.SetBounds(24, Y, 52, 32);
  SW.OnChange := @OnSwitchChange;
  AddLabel(APage, 84, Y + 6, 'Notificações por e-mail');

  SW := TFRMaterialSwitch.Create(Self);
  SW.Parent := APage;
  SW.SetBounds(24, Y + 42, 52, 32);
  SW.Checked := True;
  SW.OnChange := @OnSwitchChange;
  AddLabel(APage, 84, Y + 48, 'Atualização automática de estoque');

  SW := TFRMaterialSwitch.Create(Self);
  SW.Parent := APage;
  SW.SetBounds(24, Y + 84, 52, 32);
  SW.Checked := True;
  SW.OnChange := @OnSwitchChange;
  AddLabel(APage, 84, Y + 90, 'Backup diário às 03:00');

  SW := TFRMaterialSwitch.Create(Self);
  SW.Parent := APage;
  SW.SetBounds(24, Y + 126, 52, 32);
  SW.Enabled := False;
  AddLabel(APage, 84, Y + 132, 'Modo manutenção (bloqueado)');

  Y := Y + 172;
  Y := AddSection(APage, Y, 'TFRMaterialCheckBox');

  CB := TFRMaterialCheckBox.Create(Self);
  CB.Parent := APage;
  CB.SetBounds(24, Y, 200, 24);
  CB.Caption := 'Emitir NF-e automaticamente';
  CB.OnChange := @OnCheckChange;

  CB := TFRMaterialCheckBox.Create(Self);
  CB.Parent := APage;
  CB.SetBounds(24, Y + 30, 280, 24);
  CB.Caption := 'Incluir impostos no preço final';
  CB.Checked := True;
  CB.OnChange := @OnCheckChange;

  CB := TFRMaterialCheckBox.Create(Self);
  CB.Parent := APage;
  CB.SetBounds(24, Y + 60, 280, 24);
  CB.Caption := 'Enviar comprovante por e-mail';
  CB.Checked := True;
  CB.OnChange := @OnCheckChange;

  CB := TFRMaterialCheckBox.Create(Self);
  CB.Parent := APage;
  CB.SetBounds(24, Y + 90, 280, 24);
  CB.Caption := 'Permissões parciais (tri-state)';
  CB.AllowGrayed := True;
  CB.State := cbGrayed;
  CB.OnChange := @OnCheckChange;

  CB := TFRMaterialCheckBox.Create(Self);
  CB.Parent := APage;
  CB.SetBounds(24, Y + 120, 280, 24);
  CB.Caption := 'Integração legada (indisponível)';
  CB.Enabled := False;

  Y := Y + 160;
  Y := AddSection(APage, Y, 'TFRMaterialRadioButton');

  RB := TFRMaterialRadioButton.Create(Self);
  RB.Parent := APage;
  RB.SetBounds(24, Y, 200, 24);
  RB.Caption := 'À vista (5% desconto)';
  RB.GroupIndex := 1;
  RB.Checked := True;
  RB.OnChange := @OnRadioChange;

  RB := TFRMaterialRadioButton.Create(Self);
  RB.Parent := APage;
  RB.SetBounds(24, Y + 30, 280, 24);
  RB.Caption := '30/60/90 dias — Boleto';
  RB.GroupIndex := 1;
  RB.OnChange := @OnRadioChange;

  RB := TFRMaterialRadioButton.Create(Self);
  RB.Parent := APage;
  RB.SetBounds(24, Y + 60, 280, 24);
  RB.Caption := 'Cartão de crédito — até 12x';
  RB.GroupIndex := 1;
  RB.OnChange := @OnRadioChange;

  RB := TFRMaterialRadioButton.Create(Self);
  RB.Parent := APage;
  RB.SetBounds(24, Y + 90, 280, 24);
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
  Y := AddSection(APage, 16, 'TFRMaterialChip (4 styles)');
  X := 24;
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
  X := 24;
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
  Ch.SetBounds(24, Y, 130, 32);
  Ch.Caption := 'São Paulo';
  Ch.ChipStyle := csInput;
  Ch.Deletable := True;
  Ch.ShowIcon := True;
  Ch.IconMode := imPerson;
  Ch.OnClick := @OnChipClick;
  Ch.OnDelete := @OnChipDelete;

  Ch := TFRMaterialChip.Create(Self);
  Ch.Parent := APage;
  Ch.SetBounds(166, Y, 150, 32);
  Ch.Caption := 'Rio de Janeiro';
  Ch.ChipStyle := csInput;
  Ch.Deletable := True;
  Ch.ShowIcon := True;
  Ch.IconMode := imPerson;
  Ch.OnClick := @OnChipClick;
  Ch.OnDelete := @OnChipDelete;

  Ch := TFRMaterialChip.Create(Self);
  Ch.Parent := APage;
  Ch.SetBounds(328, Y, 120, 32);
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
  Ch.SetBounds(24, Y, 100, 32);
  Ch.Caption := 'Aberto';
  Ch.ChipStyle := csFilter;
  Ch.Selected := True;
  Ch.OnClick := @OnChipClick;

  Ch := TFRMaterialChip.Create(Self);
  Ch.Parent := APage;
  Ch.SetBounds(136, Y, 120, 32);
  Ch.Caption := 'Em análise';
  Ch.ChipStyle := csFilter;
  Ch.Selected := False;
  Ch.OnClick := @OnChipClick;

  Ch := TFRMaterialChip.Create(Self);
  Ch.Parent := APage;
  Ch.SetBounds(268, Y, 110, 32);
  Ch.Caption := 'Fechado';
  Ch.ChipStyle := csFilter;
  Ch.Selected := False;
  Ch.OnClick := @OnChipClick;

  Ch := TFRMaterialChip.Create(Self);
  Ch.Parent := APage;
  Ch.SetBounds(390, Y, 120, 32);
  Ch.Caption := 'Cancelado';
  Ch.ChipStyle := csFilter;
  Ch.Selected := False;
  Ch.OnClick := @OnChipClick;

  Y := Y + 48;
  Y := AddSection(APage, Y, 'TFRMaterialSegmentedButton');
  Seg := TFRMaterialSegmentedButton.Create(Self);
  Seg.Parent := APage;
  Seg.SetBounds(24, Y, 360, 40);
  Seg.Items.Add('Dia');
  Seg.Items.Add('Semana');
  Seg.Items.Add('Mês');
  Seg.ItemIndex := 0;
  Seg.OnChange := @OnSegmentChange;

  Y := Y + 56;
  Seg := TFRMaterialSegmentedButton.Create(Self);
  Seg.Parent := APage;
  Seg.SetBounds(24, Y, 600, 40);
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
  Y: Integer;
begin
  { --- TFRMaterialEdit --- }
  Y := AddSection(APage, 16, 'TFRMaterialEdit — Standard / Filled / Outlined');
  with TFRMaterialEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(24, Y, 260, 56);
    Caption := 'Nome do cliente';
    TextHint := 'Digite o nome completo';
    Variant := mvStandard;
    ShowClearButton := True;
  end;

  with TFRMaterialEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(300, Y, 260, 56);
    Caption := 'E-mail';
    TextHint := 'usuario@dominio.com';
    Variant := mvFilled;
    ShowLeadingIcon := True;
    LeadingIconMode := imMail;
  end;

  with TFRMaterialEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(576, Y, 260, 56);
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
    SetBounds(24, Y, 260, 70);
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
    SetBounds(300, Y, 260, 70);
    Caption := 'Campo validado';
    Text := 'Dados corretos';
    ValidationState := vsValid;
    Variant := mvOutlined;
  end;

  with TFRMaterialEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(576, Y, 260, 70);
    Caption := 'Senha';
    PasswordMode := True;
    TextHint := '********';
    Variant := mvFilled;
  end;

  { --- TFRMaterialComboEdit --- }
  Y := Y + 86;
  Y := AddSection(APage, Y, 'TFRMaterialComboEdit');
  with TFRMaterialComboEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(24, Y, 260, 56);
    Caption := 'Estado (UF)';
    Variant := mvOutlined;
    Items.Add('Acre');
    Items.Add('Bahia');
    Items.Add('Ceará');
    Items.Add('Minas Gerais');
    Items.Add('Paraná');
    Items.Add('Rio de Janeiro');
    Items.Add('São Paulo');
    Items.Add('Santa Catarina');
    Sorted := True;
  end;

  with TFRMaterialComboEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(300, Y, 260, 56);
    Caption := 'Forma de pagamento';
    Variant := mvFilled;
    Style := csDropDownList;
    Items.Add('À vista');
    Items.Add('Boleto 30/60/90');
    Items.Add('Cartão de crédito');
    Items.Add('PIX');
    ItemIndex := 0;
  end;

  { --- TFRMaterialCheckComboEdit --- }
  Y := Y + 72;
  Y := AddSection(APage, Y, 'TFRMaterialCheckComboEdit');
  with TFRMaterialCheckComboEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(24, Y, 300, 56);
    Caption := 'Categorias do produto';
    Variant := mvOutlined;
    Items.Add('Eletrônicos');
    Items.Add('Ferramentas');
    Items.Add('Material elétrico');
    Items.Add('Hidráulica');
    Items.Add('Pintura');
    Items.Add('Iluminação');
    EmptyText := 'Selecione as categorias';
  end;

  { --- TFRMaterialCurrencyEdit --- }
  Y := Y + 72;
  Y := AddSection(APage, Y, 'TFRMaterialCurrencyEdit');
  with TFRMaterialCurrencyEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(24, Y, 220, 56);
    Caption := 'Valor do pedido';
    Variant := mvOutlined;
    Value := 3487.50;
  end;

  with TFRMaterialCurrencyEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(260, Y, 220, 56);
    Caption := 'Desconto';
    Variant := mvFilled;
    Value := 0;
    ShowClearButton := True;
  end;

  { --- TFRMaterialDateEdit --- }
  Y := Y + 72;
  Y := AddSection(APage, Y, 'TFRMaterialDateEdit');
  with TFRMaterialDateEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(24, Y, 220, 56);
    Caption := 'Data de emissão';
    Variant := mvOutlined;
    Date := Now;
  end;

  with TFRMaterialDateEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(260, Y, 220, 56);
    Caption := 'Data de vencimento';
    Variant := mvFilled;
    ShowClearButton := True;
  end;

  { --- TFRMaterialMaskEdit --- }
  Y := Y + 72;
  Y := AddSection(APage, Y, 'TFRMaterialMaskEdit');
  with TFRMaterialMaskEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(24, Y, 220, 56);
    Caption := 'Telefone';
    EditMask := '(99) 99999-9999;1;_';
    Variant := mvOutlined;
  end;

  with TFRMaterialMaskEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(260, Y, 220, 56);
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
    SetBounds(24, Y, 400, 56);
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
    SetBounds(24, Y, 180, 56);
    Caption := 'Quantidade';
    Variant := mvOutlined;
    MinValue := 1;
    MaxValue := 999;
    Value := 10;
    Increment := 1;
  end;

  with TFRMaterialSpinEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(220, Y, 180, 56);
    Caption := 'Parcelas';
    Variant := mvFilled;
    MinValue := 1;
    MaxValue := 12;
    Value := 3;
    Increment := 1;
  end;

  { --- TFRMaterialMemoEdit --- }
  Y := Y + 72;
  Y := AddSection(APage, Y, 'TFRMaterialMemoEdit');
  with TFRMaterialMemoEdit.Create(Self) do
  begin
    Parent := APage;
    SetBounds(24, Y, 500, 160);
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
  TP: TFRMaterialTimePicker;
begin
  Y := AddSection(APage, 16, 'TFRMaterialSlider — Continuous');
  Sl := TFRMaterialSlider.Create(Self);
  Sl.Parent := APage;
  Sl.SetBounds(24, Y, 400, 40);
  Sl.Min := 0;
  Sl.Max := 100;
  Sl.Value := 35;
  Sl.OnChange := @OnSliderChange;

  FSliderValueLbl := AddLabel(APage, 440, Y + 10, 'Valor: 35');

  Y := Y + 56;
  Y := AddSection(APage, Y, 'TFRMaterialSlider — Discrete (steps=5)');
  Sl := TFRMaterialSlider.Create(Self);
  Sl.Parent := APage;
  Sl.SetBounds(24, Y, 400, 40);
  Sl.Min := 0;
  Sl.Max := 100;
  Sl.Discrete := True;
  Sl.Steps := 5;
  Sl.ShowValueLabel := True;
  Sl.Value := 40;

  Y := Y + 56;
  Y := AddSection(APage, Y, 'TFRMaterialSlider — Disabled');
  Sl := TFRMaterialSlider.Create(Self);
  Sl.Parent := APage;
  Sl.SetBounds(24, Y, 400, 40);
  Sl.Value := 60;
  Sl.Enabled := False;

  Y := Y + 56;
  Y := AddSection(APage, Y, 'TFRMaterialTimePicker — 24h');
  TP := TFRMaterialTimePicker.Create(Self);
  TP.Parent := APage;
  TP.SetBounds(24, Y, 220, 72);
  TP.TimeFormat := tfHour24;
  TP.Hour := 14;
  TP.Minute := 30;
  TP.OnChange := @OnTimePickerChange;
  FTimePicker := TP;
  FTimePickerLbl := AddLabel(APage, 260, Y + 26, 'Hora: 14:30');

  Y := Y + 90;
  Y := AddSection(APage, Y, 'TFRMaterialTimePicker — 12h');
  TP := TFRMaterialTimePicker.Create(Self);
  TP.Parent := APage;
  TP.SetBounds(24, Y, 220, 72);
  TP.TimeFormat := tfHour12;
  TP.Hour := 3;
  TP.Minute := 45;
  TP.IsAM := False;
end;

{ ===== Page: Progress ===== }

procedure TFmDemo.CreatePageProgress(APage: TWinControl);
var
  Y: Integer;
  LP: TFRMaterialLinearProgress;
  CP: TFRMaterialCircularProgress;
  LI: TFRMaterialLoadingIndicator;
begin
  Y := AddSection(APage, 16, 'TFRMaterialLinearProgress — Determinate');
  FLinearProgress := TFRMaterialLinearProgress.Create(Self);
  FLinearProgress.Parent := APage;
  FLinearProgress.SetBounds(24, Y, 500, 4);
  FLinearProgress.Value := 0;

  Y := Y + 24;
  Y := AddSection(APage, Y, 'TFRMaterialLinearProgress — Indeterminate');
  LP := TFRMaterialLinearProgress.Create(Self);
  LP.Parent := APage;
  LP.SetBounds(24, Y, 500, 4);
  LP.Indeterminate := True;

  Y := Y + 24;
  Y := AddSection(APage, Y, 'TFRMaterialCircularProgress — Determinate');
  FCircularProgress := TFRMaterialCircularProgress.Create(Self);
  FCircularProgress.Parent := APage;
  FCircularProgress.SetBounds(24, Y, 48, 48);
  FCircularProgress.Indeterminate := False;
  FCircularProgress.Value := 0;

  AddLabel(APage, 84, Y + 14, 'Progresso animado');

  Y := Y + 64;
  Y := AddSection(APage, Y, 'TFRMaterialCircularProgress — Indeterminate');
  CP := TFRMaterialCircularProgress.Create(Self);
  CP.Parent := APage;
  CP.SetBounds(24, Y, 48, 48);
  CP.Indeterminate := True;

  CP := TFRMaterialCircularProgress.Create(Self);
  CP.Parent := APage;
  CP.SetBounds(88, Y, 64, 64);
  CP.Indeterminate := True;
  CP.StrokeWidth := 6;

  Y := Y + 80;
  Y := AddSection(APage, Y, 'TFRMaterialLoadingIndicator');
  LI := TFRMaterialLoadingIndicator.Create(Self);
  LI.Parent := APage;
  LI.SetBounds(24, Y, 60, 20);

  LI := TFRMaterialLoadingIndicator.Create(Self);
  LI.Parent := APage;
  LI.SetBounds(100, Y, 80, 20);
  LI.DotCount := 5;

  { Timer for animating determinate progress }
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
  Y := AddSection(APage, 16, 'TFRMaterialTabs — Fixed');
  Tabs := TFRMaterialTabs.Create(Self);
  Tabs.Parent := APage;
  Tabs.SetBounds(24, Y, 600, 48);
  Tabs.TabStyle := tsFixed;
  TabItem := TFRMaterialTabItem(Tabs.Tabs.Add);
  TabItem.Caption := 'Recentes';
  TabItem.IconMode := imHome;
  TabItem := TFRMaterialTabItem(Tabs.Tabs.Add);
  TabItem.Caption := 'Favoritos';
  TabItem.IconMode := imFavorite;
  TabItem := TFRMaterialTabItem(Tabs.Tabs.Add);
  TabItem.Caption := 'Compartilhados';
  TabItem.IconMode := imShare;
  TabItem := TFRMaterialTabItem(Tabs.Tabs.Add);
  TabItem.Caption := 'Configurações';
  TabItem.IconMode := imSettings;
  Tabs.TabIndex := 0;
  Tabs.OnChange := @OnTabChange;

  Y := Y + 64;
  Y := AddSection(APage, Y, 'TFRMaterialListView — TwoLine');
  LV := TFRMaterialListView.Create(Self);
  LV.Parent := APage;
  LV.SetBounds(24, Y, 520, 420);
  LV.ItemType := litTwoLine;
  LV.ShowDividers := True;
  LV.OnSelectionChange := @OnListSelect;

  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'João Silva';
  Item.SupportText := 'Pedido #1042 — Aguardando aprovação';
  Item.LeadingIcon := imPerson;
  Item.TrailingText := '10:32';

  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Maria Oliveira';
  Item.SupportText := 'NF-e 000.142.857 emitida com sucesso';
  Item.LeadingIcon := imMail;
  Item.TrailingText := '09:15';

  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Estoque Baixo';
  Item.SupportText := 'Produto "Parafuso M6x20" abaixo do mínimo (23 un.)';
  Item.LeadingIcon := imNotification;
  Item.TrailingText := 'Ontem';

  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Relatório Mensal';
  Item.SupportText := 'Faturamento de março disponível para download';
  Item.LeadingIcon := imDownload;
  Item.TrailingText := '28/03';

  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Carlos Ferreira';
  Item.SupportText := 'Orçamento #387 — Revisão solicitada pelo cliente';
  Item.LeadingIcon := imEdit;
  Item.TrailingText := '27/03';

  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Backup Concluído';
  Item.SupportText := 'Backup automático realizado às 03:00 — 2.4 GB';
  Item.LeadingIcon := imCheck;
  Item.TrailingText := '27/03';

  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Ana Costa';
  Item.SupportText := 'Devolução #089 — Produto com defeito de fábrica';
  Item.LeadingIcon := imRefresh;
  Item.TrailingText := '26/03';

  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Promoção Ativa';
  Item.SupportText := '15% de desconto em toda a linha de ferramentas';
  Item.LeadingIcon := imStar;
  Item.TrailingText := '25/03';

  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Licença Expirando';
  Item.SupportText := 'Certificado digital A1 vence em 12 dias';
  Item.LeadingIcon := imSettings;
  Item.TrailingText := '24/03';

  Item := TFRMaterialListItem(LV.Items.Add);
  Item.Headline := 'Pedro Santos';
  Item.SupportText := 'Transferência bancária de R$ 4.750,00 confirmada';
  Item.LeadingIcon := imFavorite;
  Item.TrailingText := '23/03';

  Y := Y + 440;
  Y := AddSection(APage, Y, 'TFRMaterialTreeView');

  { Edit field for node name }
  FTreeEdit := TFRMaterialEdit.Create(Self);
  FTreeEdit.Parent := APage;
  FTreeEdit.SetBounds(24, Y, 260, 56);
  FTreeEdit.Caption := 'Nome do nó';
  FTreeEdit.TextHint := 'Digite o texto do nó';
  FTreeEdit.Variant := mvOutlined;
  FTreeEdit.ShowClearButton := True;

  { Action buttons row 1 }
  with TFRMaterialButton.Create(Self) do
  begin
    Parent := APage;
    SetBounds(300, Y, 130, 40);
    Caption := 'Adicionar raiz';
    ButtonStyle := mbsFilled;
    OnClick := @OnTreeAddRoot;
  end;

  with TFRMaterialButton.Create(Self) do
  begin
    Parent := APage;
    SetBounds(440, Y, 130, 40);
    Caption := 'Adicionar filho';
    ButtonStyle := mbsOutlined;
    OnClick := @OnTreeAddChild;
  end;

  { Action buttons row 2 }
  with TFRMaterialButton.Create(Self) do
  begin
    Parent := APage;
    SetBounds(300, Y + 48, 130, 40);
    Caption := 'Renomear';
    ButtonStyle := mbsOutlined;
    OnClick := @OnTreeRename;
  end;

  with TFRMaterialButton.Create(Self) do
  begin
    Parent := APage;
    SetBounds(440, Y + 48, 130, 40);
    Caption := 'Excluir';
    ButtonStyle := mbsText;
    OnClick := @OnTreeDelete;
  end;

  { Expand/Collapse all }
  with TFRMaterialButton.Create(Self) do
  begin
    Parent := APage;
    SetBounds(300, Y + 96, 130, 40);
    Caption := 'Expandir tudo';
    ButtonStyle := mbsText;
    OnClick := @OnTreeExpandAll;
  end;

  with TFRMaterialButton.Create(Self) do
  begin
    Parent := APage;
    SetBounds(440, Y + 96, 130, 40);
    Caption := 'Recolher tudo';
    ButtonStyle := mbsText;
    OnClick := @OnTreeCollapseAll;
  end;

  { Selection label }
  FTreeSelLabel := TLabel.Create(Self);
  FTreeSelLabel.Parent := APage;
  FTreeSelLabel.SetBounds(300, Y + 144, 270, 20);
  FTreeSelLabel.Font.Size := 9;
  FTreeSelLabel.Font.Color := MD3Colors.OnSurfaceVariant;
  FTreeSelLabel.Caption := 'Nenhum nó selecionado';
  FTreeSelLabel.Transparent := True;

  Y := Y + 170;

  { TreeView }
  FTreeView := TFRMaterialTreeView.Create(Self);
  with FTreeView do
  begin
    Parent := APage;
    SetBounds(24, Y, 550, 320);
    ShowIcons := True;
    ShowDividers := True;
    OnSelectionChange := @OnTreeSelChange;
    with TFRMaterialTreeNode(Nodes.Add) do
    begin
      Caption := 'Cadastros';
      IconMode := imFolder;
      with TFRMaterialTreeNode(Children.Add) do
      begin
        Caption := 'Clientes';
        IconMode := imPerson;
      end;
      with TFRMaterialTreeNode(Children.Add) do
      begin
        Caption := 'Fornecedores';
        IconMode := imPerson;
      end;
      with TFRMaterialTreeNode(Children.Add) do
      begin
        Caption := 'Produtos';
        IconMode := imList;
      end;
      Expanded := True;
    end;
    with TFRMaterialTreeNode(Nodes.Add) do
    begin
      Caption := 'Financeiro';
      IconMode := imFolder;
      with TFRMaterialTreeNode(Children.Add) do
      begin
        Caption := 'Contas a Pagar';
        IconMode := imDownload;
      end;
      with TFRMaterialTreeNode(Children.Add) do
      begin
        Caption := 'Contas a Receber';
        IconMode := imUpload;
      end;
    end;
    with TFRMaterialTreeNode(Nodes.Add) do
    begin
      Caption := 'Relatórios';
      IconMode := imFolder;
      with TFRMaterialTreeNode(Children.Add) do
      begin
        Caption := 'Vendas';
        IconMode := imStar;
      end;
      with TFRMaterialTreeNode(Children.Add) do
      begin
        Caption := 'Estoque';
        IconMode := imDashboard;
      end;
    end;
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
  Y := AddSection(APage, 16, 'TFRMaterialAppBar — Small');
  GBox := TFRMaterialGroupBox.Create(Self);
  GBox.Parent := APage;
  GBox.SetBounds(24, Y, 700, 68);
  GBox.Caption := '';
  GBox.ShowBorder := True;

  AppBar := TFRMaterialAppBar.Create(Self);
  AppBar.Parent := GBox;
  AppBar.Align := alClient;
  AppBar.Title := 'Meu Aplicativo';
  AppBar.NavIcon := imMenu;
  AppBar.BarSize := absSmall;
  AppBar.OnNavClick := @OnAppBarNav;
  Act := TFRMaterialAppBarAction(AppBar.Actions.Add);
  Act.IconMode := imSearch;
  Act.Hint := 'Buscar';
  Act.OnClick := @OnAppBarAction;
  Act := TFRMaterialAppBarAction(AppBar.Actions.Add);
  Act.IconMode := imMoreVert;
  Act.Hint := 'Mais opções';
  Act.OnClick := @OnAppBarAction;

  Y := Y + 84;
  Y := AddSection(APage, Y, 'TFRMaterialAppBar — Medium');
  GBox := TFRMaterialGroupBox.Create(Self);
  GBox.Parent := APage;
  GBox.SetBounds(24, Y, 700, 112);
  GBox.Caption := '';
  GBox.ShowBorder := True;

  AppBar := TFRMaterialAppBar.Create(Self);
  AppBar.Parent := GBox;
  AppBar.Align := alClient;
  AppBar.Title := 'Página de Detalhes';
  AppBar.NavIcon := imArrowBack;
  AppBar.BarSize := absMedium;
  AppBar.OnNavClick := @OnAppBarNav;
  Act := TFRMaterialAppBarAction(AppBar.Actions.Add);
  Act.IconMode := imShare;
  Act.OnClick := @OnAppBarAction;

  Y := Y + 128;
  Y := AddSection(APage, Y, 'TFRMaterialToolbar');
  GBox := TFRMaterialGroupBox.Create(Self);
  GBox.Parent := APage;
  GBox.SetBounds(24, Y, 700, 64);
  GBox.Caption := '';
  GBox.ShowBorder := True;

  Toolbar := TFRMaterialToolbar.Create(Self);
  Toolbar.Parent := GBox;
  Toolbar.Align := alClient;
  Act := TFRMaterialAppBarAction(Toolbar.Actions.Add);
  Act.IconMode := imCopy;
  Act.Hint := 'Copiar';
  Act.OnClick := @OnToolbarAction;
  Act := TFRMaterialAppBarAction(Toolbar.Actions.Add);
  Act.IconMode := imEdit;
  Act.Hint := 'Editar';
  Act.OnClick := @OnToolbarAction;
  Act := TFRMaterialAppBarAction(Toolbar.Actions.Add);
  Act.IconMode := imDelete;
  Act.Hint := 'Excluir';
  Act.OnClick := @OnToolbarAction;
  Act := TFRMaterialAppBarAction(Toolbar.Actions.Add);
  Act.IconMode := imShare;
  Act.Hint := 'Compartilhar';
  Act.OnClick := @OnToolbarAction;

  Y := Y + 80;
  Y := AddSection(APage, Y, 'TFRMaterialNavBar');
  GBox := TFRMaterialGroupBox.Create(Self);
  GBox.Parent := APage;
  GBox.SetBounds(24, Y, 500, 80);
  GBox.Caption := '';
  GBox.ShowBorder := True;

  NavBar := TFRMaterialNavBar.Create(Self);
  NavBar.Parent := GBox;
  NavBar.Align := alClient;
  NavItem := TFRMaterialNavItem(NavBar.Items.Add);
  NavItem.Caption := 'Início';
  NavItem.IconMode := imHome;
  NavItem := TFRMaterialNavItem(NavBar.Items.Add);
  NavItem.Caption := 'Buscar';
  NavItem.IconMode := imSearch;
  NavItem := TFRMaterialNavItem(NavBar.Items.Add);
  NavItem.Caption := 'Favoritos';
  NavItem.IconMode := imFavorite;
  NavItem.Badge := '3';
  NavItem := TFRMaterialNavItem(NavBar.Items.Add);
  NavItem.Caption := 'Perfil';
  NavItem.IconMode := imPerson;
  NavBar.ItemIndex := 0;
  NavBar.OnChange := @OnNavBarChange;

  Y := Y + 96;
  Y := AddSection(APage, Y, 'TFRMaterialNavDrawer');
  GBox := TFRMaterialGroupBox.Create(Self);
  GBox.Parent := APage;
  GBox.SetBounds(24, Y, 360, 280);
  GBox.Caption := '';
  GBox.ShowBorder := True;

  with TFRMaterialNavDrawer.Create(Self) do
  begin
    Parent := GBox;
    Align := alClient;
    HeaderTitle := 'ERP System';
    with TFRMaterialNavItem(Items.Add) do
    begin
      Caption := 'Dashboard';
      IconMode := imDashboard;
    end;
    with TFRMaterialNavItem(Items.Add) do
    begin
      Caption := 'Pedidos';
      IconMode := imEdit;
      Badge := '12';
    end;
    with TFRMaterialNavItem(Items.Add) do
    begin
      Caption := 'Clientes';
      IconMode := imPerson;
    end;
    with TFRMaterialNavItem(Items.Add) do
    begin
      Caption := 'Estoque';
      IconMode := imList;
    end;
    with TFRMaterialNavItem(Items.Add) do
    begin
      Caption := 'Configurações';
      IconMode := imSettings;
    end;
    ItemIndex := 0;
  end;

  Y := Y + 296;
  Y := AddSection(APage, Y, 'TFRMaterialNavRail');
  GBox := TFRMaterialGroupBox.Create(Self);
  GBox.Parent := APage;
  GBox.SetBounds(24, Y, 80, 360);
  GBox.Caption := '';
  GBox.ShowBorder := True;

  with TFRMaterialNavRail.Create(Self) do
  begin
    Parent := GBox;
    Align := alClient;
    MenuIcon := imMenu;
    FabIcon := imPlus;
    with TFRMaterialNavItem(Items.Add) do
    begin
      Caption := 'Início';
      IconMode := imHome;
    end;
    with TFRMaterialNavItem(Items.Add) do
    begin
      Caption := 'Buscar';
      IconMode := imSearch;
    end;
    with TFRMaterialNavItem(Items.Add) do
    begin
      Caption := 'Alertas';
      IconMode := imNotification;
      Badge := '5';
    end;
    with TFRMaterialNavItem(Items.Add) do
    begin
      Caption := 'Perfil';
      IconMode := imPerson;
    end;
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
  Y := AddSection(APage, 16, 'TFRMaterialDialog');
  Btn := TFRMaterialButton.Create(Self);
  Btn.Parent := APage;
  Btn.SetBounds(24, Y, 180, 40);
  Btn.Caption := 'Abrir Dialog';
  Btn.ButtonStyle := mbsFilled;
  Btn.ShowIcon := True;
  Btn.IconMode := imSettings;
  Btn.OnClick := @OnDialogClick;

  Y := Y + 56;
  Y := AddSection(APage, Y, 'TFRMaterialSnackbar');
  Btn := TFRMaterialButton.Create(Self);
  Btn.Parent := APage;
  Btn.SetBounds(24, Y, 200, 40);
  Btn.Caption := 'Mostrar Snackbar';
  Btn.ButtonStyle := mbsTonal;
  Btn.OnClick := @OnSnackbarClick;

  Y := Y + 56;
  Y := AddSection(APage, Y, 'TFRMaterialMenu');
  Btn := TFRMaterialButton.Create(Self);
  Btn.Parent := APage;
  Btn.SetBounds(24, Y, 180, 40);
  Btn.Caption := 'Abrir Menu';
  Btn.ButtonStyle := mbsOutlined;
  Btn.ShowIcon := True;
  Btn.IconMode := imMoreVert;
  Btn.OnClick := @OnMenuClick;

  Y := Y + 56;
  Y := AddSection(APage, Y, 'TFRMaterialGroupBox');
  GBox := TFRMaterialGroupBox.Create(Self);
  GBox.Parent := APage;
  GBox.SetBounds(24, Y, 400, 100);
  GBox.Caption := 'Configurações';
  GBox.BorderRadius := 12;
  GBox.ShowBorder := True;

  AddLabel(GBox, 16, 28, 'Conteúdo dentro do GroupBox');

  Div1 := TFRMaterialDivider.Create(Self);
  Div1.Parent := GBox;
  Div1.SetBounds(16, 52, 368, 1);

  AddLabel(GBox, 16, 64, 'Separado por um TFRMaterialDivider');

  Y := Y + 116;
  Y := AddSection(APage, Y, 'TFRMaterialBottomSheet / SideSheet');
  Btn := TFRMaterialButton.Create(Self);
  Btn.Parent := APage;
  Btn.SetBounds(24, Y, 200, 40);
  Btn.Caption := 'Bottom Sheet';
  Btn.ButtonStyle := mbsElevated;
  Btn.OnClick := @OnBottomSheetClick;

  Btn := TFRMaterialButton.Create(Self);
  Btn.Parent := APage;
  Btn.SetBounds(240, Y, 200, 40);
  Btn.Caption := 'Side Sheet';
  Btn.ButtonStyle := mbsElevated;
  Btn.OnClick := @OnSideSheetClick;

  { Create sheets (initially collapsed / hidden) }
  FBottomSheet := TFRMaterialBottomSheet.Create(Self);
  FBottomSheet.Parent := Self;
  FBottomSheet.SheetHeight := 200;
  FBottomSheet.Height := 200;
  FBottomSheet.Left := 0;
  FBottomSheet.Width := ClientWidth;
  FBottomSheet.Top := ClientHeight; { start off-screen }
  FBottomSheet.DragHandle := True;
  FBottomSheet.Visible := False;
  FBottomSheet.BringToFront;

  AddLabel(FBottomSheet, 24, 28, 'Detalhes do Pedido #1042', True);
  AddLabel(FBottomSheet, 24, 56, 'Cliente: João Silva — CNPJ 12.345.678/0001-90');
  AddLabel(FBottomSheet, 24, 78, 'Valor total: R$ 3.487,50 — 12 itens');
  AddLabel(FBottomSheet, 24, 100, 'Status: Aguardando aprovação do financeiro');
  AddLabel(FBottomSheet, 24, 130, 'Prazo de entrega: 05/04/2026 — Transportadora XYZ');
  AddLabel(FBottomSheet, 24, 160, 'Arraste o handle ou clique para fechar.');

  FSideSheet := TFRMaterialSideSheet.Create(Self);
  FSideSheet.Parent := Self;
  FSideSheet.SheetWidth := 300;
  FSideSheet.Width := 300;
  FSideSheet.Top := 0;
  FSideSheet.Height := ClientHeight;
  FSideSheet.Left := ClientWidth; { start off-screen }
  FSideSheet.Visible := False;
  FSideSheet.BringToFront;

  AddLabel(FSideSheet, 24, 24, 'Filtros Avançados', True);
  AddLabel(FSideSheet, 24, 56, 'Período:');
  AddLabel(FSideSheet, 24, 76, '  01/03/2026 a 31/03/2026');
  AddLabel(FSideSheet, 24, 108, 'Vendedor:');
  AddLabel(FSideSheet, 24, 128, '  Carlos Ferreira');
  AddLabel(FSideSheet, 24, 160, 'Situação:');
  AddLabel(FSideSheet, 24, 180, '  Pendentes e Em análise');
  AddLabel(FSideSheet, 24, 212, 'Valor mínimo:');
  AddLabel(FSideSheet, 24, 232, '  R$ 500,00');
  AddLabel(FSideSheet, 24, 264, 'Forma de pagamento:');
  AddLabel(FSideSheet, 24, 284, '  Boleto, PIX');
  AddLabel(FSideSheet, 24, 320, 'Clique "Side Sheet" para fechar.');
end;

{ ===== Page: Documentação ===== }

procedure TFmDemo.CreatePageDocs(APage: TWinControl);
var
  Y: Integer;
  Memo: TFRMaterialMemoEdit;
begin
  Y := AddSection(APage, 16, 'Documentação — Material Design 3 Components');
  Memo := TFRMaterialMemoEdit.Create(Self);
  Memo.Parent := APage;
  Memo.SetBounds(24, Y, APage.ClientWidth - 48, 800);
  Memo.Anchors := [akLeft, akTop, akRight];
  Memo.Caption := 'README';
  Memo.Variant := mvOutlined;
  Memo.ReadOnly := True;
  Memo.WordWrap := True;
  Memo.ScrollBars := ssAutoVertical;
  Memo.Memo.Lines.Clear;
  Memo.Memo.Lines.Add('=== Material Design 3 Component Library for Lazarus ===');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('Pacote: materialdesign.lpk | Licença: LGPL v3');
  Memo.Memo.Lines.Add('Dependências: BGRABitmap, LCL');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('--- BOTÕES ---');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialButton — Botão MD3 com 5 estilos: Filled, Outlined, Text, Elevated, Tonal.');
  Memo.Memo.Lines.Add('  Propriedades: ButtonStyle, Caption, ShowIcon, IconMode, Enabled.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialButtonIcon — Botão de ícone MD3: Standard, Filled, FilledTonal, Outlined.');
  Memo.Memo.Lines.Add('  Propriedades: IconStyle, IconMode, Toggle, Toggled.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialSplitButton — Botão dividido com ação principal e menu secundário.');
  Memo.Memo.Lines.Add('  Propriedades: ButtonStyle (mbsFilled, mbsOutlined), Caption.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialFAB — Floating Action Button: Small (40px), Regular (56px), Large (96px).');
  Memo.Memo.Lines.Add('  Propriedades: FABSize, IconMode.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialExtendedFAB — FAB estendido com texto.');
  Memo.Memo.Lines.Add('  Propriedades: Caption, IconMode, ShowIcon.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialFABMenu — Speed Dial: FAB expansível com sub-itens.');
  Memo.Memo.Lines.Add('  Propriedades: IconMode, Expanded, Items (Caption, IconMode, OnClick).');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('--- CONTROLES ---');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialSwitch — Toggle switch on/off com estado tátil.');
  Memo.Memo.Lines.Add('  Propriedades: Checked, Enabled.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialCheckBox — CheckBox MD3 com suporte a tri-state.');
  Memo.Memo.Lines.Add('  Propriedades: Checked, State, AllowGrayed, Caption.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialRadioButton — RadioButton MD3 com GroupIndex.');
  Memo.Memo.Lines.Add('  Propriedades: Checked, GroupIndex, Caption.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialChip — Chip MD3: Assist, Filter, Input, Suggestion.');
  Memo.Memo.Lines.Add('  Propriedades: ChipStyle, Selected, Deletable, ShowIcon, IconMode.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialSegmentedButton — Botão segmentado com seleção única ou múltipla.');
  Memo.Memo.Lines.Add('  Propriedades: Items, ItemIndex, MultiSelect.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('--- CAMPOS DE ENTRADA ---');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialEdit — Input de texto com floating label, ícones, validação, máscara e autocomplete.');
  Memo.Memo.Lines.Add('  Variantes: mvStandard, mvFilled, mvOutlined.');
  Memo.Memo.Lines.Add('  Propriedades: Caption, Text, TextHint, Variant, ShowClearButton, ShowLeadingIcon,');
  Memo.Memo.Lines.Add('    LeadingIconMode, PasswordMode, Required, ValidationState, HelperText, ErrorText,');
  Memo.Memo.Lines.Add('    EditMask, TextMask (tmtCPF, tmtCNPJ, tmtPhone...), PrefixText, SuffixText.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialComboEdit — ComboBox com floating label e estilo MD3.');
  Memo.Memo.Lines.Add('  Propriedades: Caption, Items, ItemIndex, Style (csDropDown, csDropDownList),');
  Memo.Memo.Lines.Add('    Variant, AutoComplete, Sorted.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialCheckComboEdit — Multi-select dropdown com checkboxes.');
  Memo.Memo.Lines.Add('  Propriedades: Caption, Items, Checked[i], CheckedCount, DisplayFormat, EmptyText.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialCurrencyEdit — Campo de moeda formatado (R$).');
  Memo.Memo.Lines.Add('  Propriedades: Caption, Value, CurrencySymbol, DecimalPlaces, AllowNegative.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialDateEdit — Seletor de data com calendário popup.');
  Memo.Memo.Lines.Add('  Propriedades: Caption, Date, DateOrder, ShowClearButton, Variant.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialMaskEdit — Input com máscara (telefone, CEP, CPF etc.).');
  Memo.Memo.Lines.Add('  Propriedades: Caption, EditMask, Text, MaskedText, CharCase, Variant.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialSearchEdit — Campo de busca com debounce e ícone.');
  Memo.Memo.Lines.Add('  Propriedades: Caption, Text, DebounceInterval (ms), Variant.');
  Memo.Memo.Lines.Add('  Evento: OnSearch.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialSpinEdit — Stepper numérico com botões +/-.');
  Memo.Memo.Lines.Add('  Propriedades: Caption, Value, MinValue, MaxValue, Increment, Variant.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialMemoEdit — Editor multilinha com char counter e validação.');
  Memo.Memo.Lines.Add('  Propriedades: Caption, Lines, WordWrap, MaxLength, ShowCharCounter,');
  Memo.Memo.Lines.Add('    ReadOnly, ScrollBars, ValidationState.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('--- SLIDERS / TIME ---');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialSlider — Slider contínuo ou discreto (com steps).');
  Memo.Memo.Lines.Add('  Propriedades: Min, Max, Value, Discrete, Steps, ShowValueLabel.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialTimePicker — Seletor de hora 24h ou 12h AM/PM.');
  Memo.Memo.Lines.Add('  Propriedades: Hour, Minute, TimeFormat (tfHour24, tfHour12), IsAM, TimeStr.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('--- PROGRESSO ---');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialLinearProgress — Barra de progresso linear.');
  Memo.Memo.Lines.Add('  Propriedades: Value (0-100), Indeterminate.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialCircularProgress — Indicador circular de progresso.');
  Memo.Memo.Lines.Add('  Propriedades: Value, Indeterminate, StrokeWidth.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialLoadingIndicator — Animação de pontos pulsantes.');
  Memo.Memo.Lines.Add('  Propriedades: DotCount.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('--- DADOS ---');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialTabs — Tabs fixas ou scrollable com ícones.');
  Memo.Memo.Lines.Add('  Propriedades: TabStyle (tsFixed, tsScrollable), Tabs [], TabIndex.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialListView — Lista MD3: OneLine, TwoLine, ThreeLine.');
  Memo.Memo.Lines.Add('  Propriedades: ItemType, ShowDividers, Items (Headline, SupportText, LeadingIcon, TrailingText).');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialTreeView — Árvore hierárquica com expand/collapse, ícones e seleção.');
  Memo.Memo.Lines.Add('  Propriedades: Nodes (Caption, IconMode, Children, Expanded), ShowIcons, ShowDividers, ItemHeight, Indent.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('--- NAVEGAÇÃO ---');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialAppBar — Top App Bar: Small, Medium (com back), Large.');
  Memo.Memo.Lines.Add('  Propriedades: Title, NavIcon, BarSize, Actions [].');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialToolbar — Barra de ferramentas com ações de ícones.');
  Memo.Memo.Lines.Add('  Propriedades: Actions [] (IconMode, Hint, OnClick).');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialNavBar — Barra de navegação inferior com badges.');
  Memo.Memo.Lines.Add('  Propriedades: Items (Caption, IconMode, Badge), ItemIndex.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialNavDrawer — Drawer lateral de navegação (360dp).');
  Memo.Memo.Lines.Add('  Propriedades: Items, ItemIndex, HeaderTitle.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialNavRail — Rail vertical de navegação (80dp).');
  Memo.Memo.Lines.Add('  Propriedades: Items, ItemIndex, MenuIcon, FabIcon.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('--- SUPERFÍCIES ---');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialDialog — Diálogo modal com título, conteúdo e botões.');
  Memo.Memo.Lines.Add('  Propriedades: Title, Content, Buttons (dbYes, dbNo, dbCancel).');
  Memo.Memo.Lines.Add('  Método: Execute → TFRMDDialogResult.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialSnackbar — Toast/Snackbar temporário com ação.');
  Memo.Memo.Lines.Add('  Método: Show(Message, ActionText).');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialTooltip — Tooltip flutuante.');
  Memo.Memo.Lines.Add('  Propriedades: Text.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialMenu — Menu popup com ícones e separadores.');
  Memo.Memo.Lines.Add('  Propriedades: Items (Caption, IconMode, IsSeparator). Método: Popup(X, Y).');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialGroupBox — Container com borda arredondada.');
  Memo.Memo.Lines.Add('  Propriedades: Caption, BorderRadius, ShowBorder.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialDivider — Linha divisória horizontal.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialBottomSheet — Painel deslizante inferior com drag handle.');
  Memo.Memo.Lines.Add('  Propriedades: SheetHeight, DragHandle. Método: Toggle.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• TFRMaterialSideSheet — Painel deslizante lateral.');
  Memo.Memo.Lines.Add('  Propriedades: SheetWidth. Método: Toggle.');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('--- UTILITÁRIOS ---');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('• FRMaterialIcons — 50+ ícones SVG vetoriais (imHome, imSearch, imEdit, etc.).');
  Memo.Memo.Lines.Add('• FRMaterialTheme — Sistema de cores MD3 com 12 paletas pré-definidas.');
  Memo.Memo.Lines.Add('• FRMaterialMasks — Máscaras de entrada PT-BR (CPF, CNPJ, Telefone, CEP, etc.).');
  Memo.Memo.Lines.Add('');
  Memo.Memo.Lines.Add('Total: 41 componentes visuais + 3 unidades utilitárias.');
end;

{ ===== Event Handlers ===== }

procedure TFmDemo.UpdateMainTabs;
const
  CTabNames: array[0..4, 0..2] of string = (
    ('Buttons', 'FABs', ''),
    ('Toggles', 'Chips', ''),
    ('Edits', 'Inputs', 'Progress'),
    ('Listas & Tabs', 'Navegação', ''),
    ('Superfícies', 'Documentação', ''));
  CTabCount: array[0..4] of Integer = (2, 2, 3, 2, 2);
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
  if (AIndex < 0) or (AIndex > 10) then AIndex := 0;
  for I := 0 to 10 do
    FContentPanels[I].Visible := (I = AIndex);
  FStatusBar.SimpleText := FContentPanels[AIndex].Hint;
end;

procedure TFmDemo.ApplyTheme;
var
  I: Integer;
begin
  MD3LoadPalette(FCurrentPalette, FDarkMode);
  Color := MD3Colors.Surface;
  FMainAppBar.Invalidate;
  FMainTabs.Invalidate;
  FMainNavBar.Invalidate;
  for I := 0 to 10 do
    FContentPanels[I].Color := MD3Colors.Surface;
  Invalidate;
end;

procedure TFmDemo.OnMainDarkToggle(Sender: TObject);
begin
  FDarkMode := not FDarkMode;
  if FDarkMode then
    FDarkAction.IconMode := imLightMode
  else
    FDarkAction.IconMode := imNightlight;
  ApplyTheme;
  FStatusBar.SimpleText := MD3PaletteName(FCurrentPalette) +
    ' — ' + IfThen(FDarkMode, 'Dark', 'Light');
end;

procedure TFmDemo.OnMainTabChange(Sender: TObject);
const
  CPageBase: array[0..4] of Integer = (0, 2, 4, 7, 9);
var
  Nav, PageIdx: Integer;
begin
  Nav := FMainNavBar.ItemIndex;
  if (Nav < 0) or (Nav > 4) then Nav := 0;
  PageIdx := CPageBase[Nav] + FMainTabs.TabIndex;
  if PageIdx > 10 then PageIdx := 10;
  ShowPage(PageIdx);
end;

procedure TFmDemo.OnMainNavChange(Sender: TObject);
const
  CPageBase: array[0..4] of Integer = (0, 2, 4, 7, 9);
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
var
  Pt: TPoint;
begin
  Pt := FMainAppBar.ClientToScreen(Point(FMainAppBar.Width - 120, FMainAppBar.Height));
  FPaletteMenu.Popup(Pt.X, Pt.Y);
end;

procedure TFmDemo.OnPaletteMenuAction(Sender: TObject);
var
  MI: TMenuItem;
begin
  MI := TMenuItem(Sender);
  FCurrentPalette := TFRMDPalette(MI.Tag);
  MI.Checked := True;
  ApplyTheme;
  FStatusBar.SimpleText := 'Paleta: ' + MD3PaletteName(FCurrentPalette) +
    ' — ' + IfThen(FDarkMode, 'Dark', 'Light');
end;

procedure TFmDemo.OnButtonClick(Sender: TObject);
begin
  if Sender is TFRMaterialButton then
    FStatusBar.SimpleText := 'Clicou: ' + TFRMaterialButton(Sender).Caption
  else
    FStatusBar.SimpleText := 'Clicou: IconButton';
end;

procedure TFmDemo.OnDialogClick(Sender: TObject);
var
  R: TFRMDDialogResult;
begin
  R := FDialog.Execute;
  case R of
    drYes:    FStatusBar.SimpleText := 'Dialog → Sim';
    drNo:     FStatusBar.SimpleText := 'Dialog → Não';
    drCancel: FStatusBar.SimpleText := 'Dialog → Cancelar';
  else
    FStatusBar.SimpleText := 'Dialog → Fechado';
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
var
  Pt: TPoint;
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
  FSliderValueLbl.Caption := Format('Valor: %.0f', [TFRMaterialSlider(Sender).Value]);
end;

procedure TFmDemo.OnTimePickerChange(Sender: TObject);
begin
  FTimePickerLbl.Caption := 'Hora: ' + FTimePicker.TimeStr;
end;

procedure TFmDemo.OnProgressTimer(Sender: TObject);
var
  V: Double;
begin
  V := FLinearProgress.Value + 1;
  if V > 100 then V := 0;
  FLinearProgress.Value := V;
  FCircularProgress.Value := V;
end;

procedure TFmDemo.OnBottomSheetClick(Sender: TObject);
begin
  FBottomSheet.Toggle;
end;

procedure TFmDemo.OnSideSheetClick(Sender: TObject);
begin
  FSideSheet.Toggle;
end;

procedure TFmDemo.OnListSelect(Sender: TObject);
var
  LV: TFRMaterialListView;
begin
  LV := TFRMaterialListView(Sender);
  if (LV.ItemIndex >= 0) and (LV.ItemIndex < LV.Items.Count) then
    FStatusBar.SimpleText := 'Selecionou: ' + TFRMaterialListItem(LV.Items[LV.ItemIndex]).Headline;
end;

procedure TFmDemo.OnTabChange(Sender: TObject);
var
  T: TFRMaterialTabs;
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
    FStatusBar.SimpleText := 'Toggle: ' + TFRMaterialButtonIcon(Sender).Hint +
      ' → ' + IfThen(TFRMaterialButtonIcon(Sender).Toggled, 'Ativado', 'Desativado');
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
var
  Sw: TFRMaterialSwitch;
begin
  Sw := TFRMaterialSwitch(Sender);
  FStatusBar.SimpleText := 'Switch → ' + IfThen(Sw.Checked, 'Ligado', 'Desligado');
end;

procedure TFmDemo.OnCheckChange(Sender: TObject);
var
  Cb: TFRMaterialCheckBox;
begin
  Cb := TFRMaterialCheckBox(Sender);
  FStatusBar.SimpleText := 'CheckBox "' + Cb.Caption + '" → ' +
    IfThen(Cb.Checked, 'Marcado', 'Desmarcado');
end;

procedure TFmDemo.OnRadioChange(Sender: TObject);
var
  Rb: TFRMaterialRadioButton;
begin
  Rb := TFRMaterialRadioButton(Sender);
  if Rb.Checked then
    FStatusBar.SimpleText := 'Pagamento: ' + Rb.Caption;
end;

procedure TFmDemo.OnChipClick(Sender: TObject);
var
  Ch: TFRMaterialChip;
begin
  Ch := TFRMaterialChip(Sender);
  FStatusBar.SimpleText := 'Chip "' + Ch.Caption + '" → ' +
    IfThen(Ch.Selected, 'Selecionado', 'Desmarcado');
end;

procedure TFmDemo.OnChipDelete(Sender: TObject);
var
  Ch: TFRMaterialChip;
  Nome: string;
begin
  Ch := TFRMaterialChip(Sender);
  Nome := Ch.Caption;
  Ch.Visible := False;
  FSnackbar.Show('Chip "' + Nome + '" removido', 'DESFAZER');
  FStatusBar.SimpleText := 'Chip removido: ' + Nome;
end;

procedure TFmDemo.OnSegmentChange(Sender: TObject);
var
  Seg: TFRMaterialSegmentedButton;
begin
  Seg := TFRMaterialSegmentedButton(Sender);
  if (Seg.ItemIndex >= 0) and (Seg.ItemIndex < Seg.Items.Count) then
    FStatusBar.SimpleText := 'Segmento: ' + Seg.Items[Seg.ItemIndex]
  else
    FStatusBar.SimpleText := 'Segmento alterado';
end;

procedure TFmDemo.OnNavBarChange(Sender: TObject);
var
  Nav: TFRMaterialNavBar;
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

{ ===== TreeView event handlers ===== }

procedure ExpandCollapseAll(ANodes: TFRMaterialTreeNodes; AExpand: Boolean);
var
  I: Integer;
  Node: TFRMaterialTreeNode;
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
var
  S: string;
  Node: TFRMaterialTreeNode;
begin
  S := Trim(FTreeEdit.Text);
  if S = '' then
  begin
    FStatusBar.SimpleText := 'Digite um nome para o nó.';
    Exit;
  end;
  Node := TFRMaterialTreeNode(FTreeView.Nodes.Add);
  Node.Caption := S;
  Node.IconMode := imFolder;
  FTreeEdit.Text := '';
  FTreeView.Invalidate;
  FStatusBar.SimpleText := 'Nó raiz "' + S + '" adicionado.';
end;

procedure TFmDemo.OnTreeAddChild(Sender: TObject);
var
  S: string;
  Node: TFRMaterialTreeNode;
begin
  S := Trim(FTreeEdit.Text);
  if S = '' then
  begin
    FStatusBar.SimpleText := 'Digite um nome para o nó filho.';
    Exit;
  end;
  if FTreeView.SelectedNode = nil then
  begin
    FStatusBar.SimpleText := 'Selecione um nó pai primeiro.';
    Exit;
  end;
  Node := TFRMaterialTreeNode(FTreeView.SelectedNode.Children.Add);
  Node.Caption := S;
  Node.IconMode := imList;
  FTreeView.SelectedNode.Expanded := True;
  FTreeEdit.Text := '';
  FTreeView.Invalidate;
  FStatusBar.SimpleText := 'Nó filho "' + S + '" adicionado em "' + FTreeView.SelectedNode.Caption + '".';
end;

procedure TFmDemo.OnTreeDelete(Sender: TObject);
var
  Sel: TFRMaterialTreeNode;
  Nodes: TFRMaterialTreeNodes;
  S: string;
begin
  Sel := FTreeView.SelectedNode;
  if Sel = nil then
  begin
    FStatusBar.SimpleText := 'Selecione um nó para excluir.';
    Exit;
  end;
  S := Sel.Caption;
  Nodes := TFRMaterialTreeNodes(Sel.Collection);
  FTreeView.SelectedNode := nil;
  Nodes.Delete(Sel.Index);
  FTreeView.Invalidate;
  FTreeSelLabel.Caption := 'Nenhum nó selecionado';
  FStatusBar.SimpleText := 'Nó "' + S + '" excluído.';
end;

procedure TFmDemo.OnTreeRename(Sender: TObject);
var
  S: string;
begin
  S := Trim(FTreeEdit.Text);
  if S = '' then
  begin
    FStatusBar.SimpleText := 'Digite o novo nome.';
    Exit;
  end;
  if FTreeView.SelectedNode = nil then
  begin
    FStatusBar.SimpleText := 'Selecione um nó para renomear.';
    Exit;
  end;
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

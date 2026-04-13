unit ufm_showcase;

{$mode objfpc}{$H+}

{ FRComponents Showcase — OPM submission screenshot demo.

  This standalone form presents a dense, realistic-looking dashboard
  exercising ~20 MD3 components in a single screen. Ideal for taking
  one-shot screenshots for package submissions and marketing material.

  Layout (1280 x 800):
    ┌───────────────────────────────────────────────────────────┐
    │ AppBar: title + subtitle + search + theme toggle + user   │
    ├─────────┬─────────────────────────────────────────────────┤
    │         │ KPI row (3 cards with metrics + badges)         │
    │         │                                                 │
    │ NavRail │ Form row (GridPanel 12-col: 4 inputs + combo)   │
    │         │                                                 │
    │         │ VirtualDataGrid (hero component) — populated    │
    │         │ with 10 sample rows                             │
    │         │                                                 │
    │         │ Controls row: Switch, Slider, Chips, Segmented  │
    │         │                                                 │
    │         │ Button row: Filled / Tonal / Outlined / Text    │
    └─────────┴─────────────────────────────────────────────────┘
                                                            [FAB]
}

interface

uses
  Classes, SysUtils, Math, Windows, Forms, Controls, Graphics, ExtCtrls, StdCtrls,
  laz.VirtualTrees,
  FRMaterial3Base, FRMaterialTheme, FRMaterialThemeManager, FRMaterialIcons,
  FRMaterialMasks,
  FRMaterial3Label,
  FRMaterial3AppBar, FRMaterial3Nav, FRMaterial3Card, FRMaterial3Badge,
  FRMaterial3GridPanel, FRMaterial3Divider, FRMaterial3Button,
  FRMaterial3FAB, FRMaterial3Toggle, FRMaterial3Chip, FRMaterial3Slider,
  FRMaterial3Progress, FRMaterial3VirtualDataGrid, FRMaterial3Snackbar,
  FRMaterialEdit, FRMaterial3Combo, FRMaterialDateEdit,
  FRMaterial3TitleBar;

type

  { TFmShowcase }

  TFmShowcase = class(TFRMaterialForm)
  private
    FThemeManager: TFRMaterialThemeManager;
    FSnackbar: TFRMaterialSnackbar;
    FDarkMode: Boolean;

    { Layout }
    FPnFundo: TPanel;
    { AppBar removido — ações migradas para TitleBar do TFRMaterialForm }
    FNavRail: TFRMaterialNavRail;
    FPnContent: TScrollBox;
    FContentHeight: Integer;

    { Row 1 — KPI cards }
    FCardRevenue: TFRMaterialCard;
    FCardUsers: TFRMaterialCard;
    FCardGrowth: TFRMaterialCard;

    { Row 2 — Form fields }
    FLblForm: TFRMaterialLabel;
    FGridForm: TFRMaterialGridPanel;
    FEdName: TFRMaterialEdit;
    FEdEmail: TFRMaterialEdit;
    FEdCity: TFRMaterialCombo;
    FEdBirth: TFRMaterialDateEdit;
    FEdBudget: TFRMaterialEdit;

    { Row 3 — VirtualDataGrid }
    FLblGrid: TFRMaterialLabel;
    FGrid: TFRMaterialVirtualDataGrid;

    { Row 4 — Controls }
    FLblControls: TFRMaterialLabel;
    FPnControls: TPanel;
    FSwitch: TFRMaterialSwitch;
    FSwitchLabel: TFRMaterialLabel;
    FChipAssist: TFRMaterialChip;
    FChipFilter: TFRMaterialChip;
    FChipInput: TFRMaterialChip;
    FSegmented: TFRMaterialSegmentedButton;
    FSlider: TFRMaterialSlider;
    FSliderLabel: TFRMaterialLabel;
    FProgress: TFRMaterialCircularProgress;

    { Row 5 — Theme customization: color swatches + dark toggle + variant buttons }
    FLblTheme: TFRMaterialLabel;
    FPnTheme: TPanel;
    FColorSwatches: array[0..5] of TPanel;
    FDarkToggle: TFRMaterialSwitch;
    FDarkToggleLabel: TFRMaterialLabel;
    FBtnVariants: array[0..3] of TFRMaterialButton;

    { Row 6 — Buttons grid: 5 styles (col) × 3 densities (row) + icon/split }
    FLblButtons: TFRMaterialLabel;
    FPnButtons: TPanel;
    FBtnRows: array[0..2, 0..4] of TFRMaterialButton; { [density][style] }
    FBtnIconStd: TFRMaterialButtonIcon;
    FBtnIconFilled: TFRMaterialButtonIcon;
    FBtnIconTonal: TFRMaterialButtonIcon;
    FBtnIconOutlined: TFRMaterialButtonIcon;
    FBtnSplit: TFRMaterialSplitButton;
    FBtnSnack: TFRMaterialButton;

    { Floating FAB }
    FFab: TFRMaterialFAB;

    procedure BuildAppBar;
    procedure BuildNavRail;
    procedure BuildKPICards;
    procedure BuildFormRow(var Y: Integer);
    procedure BuildGrid(var Y: Integer);
    procedure BuildControlsRow(var Y: Integer);
    procedure BuildThemeRow(var Y: Integer);
    procedure BuildButtonRow(var Y: Integer);
    procedure BuildFab;
    procedure PopulateGrid;
    procedure MakeKpiCard(ACard: TFRMaterialCard; const ATitle, AValue, ADelta: string;
      AColor: TColor);

    procedure OnDarkModeClick(Sender: TObject);
    procedure OnVariantToggleClick(Sender: TObject);
    procedure OnSwatchClick(Sender: TObject);
    procedure OnDarkToggleChange(Sender: TObject);
    procedure OnVariantBtnClick(Sender: TObject);
    procedure OnSliderChange(Sender: TObject);
    procedure OnSegmentedChange(Sender: TObject);
    procedure OnSnackClick(Sender: TObject);
    procedure OnGridReloadClick(Sender: TObject);
    procedure OnGridClearClick(Sender: TObject);
    procedure OnContentResize(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  FmShowcase: TFmShowcase;

implementation

uses
  {$IFDEF MSWINDOWS} LCLIntf {$ENDIF};

{$IFDEF MSWINDOWS}
function FRSetWindowTheme(hWnd: THandle; pszSubAppName: PWideChar;
  pszSubIdList: PWideChar): HRESULT;
  stdcall; external 'uxtheme.dll' name 'SetWindowTheme';
{$ENDIF}

const
  FORM_W      = 1280;
  FORM_H      = 800;
  NAVRAIL_W   = 80;
  APPBAR_H    = 64;
  CONTENT_PAD = 24;

{ TFmShowcase }

constructor TFmShowcase.Create(AOwner: TComponent);
var
  Y: Integer;
begin
  inherited CreateNew(AOwner);

  Caption               := 'FRComponents — Material Design 3 Showcase';
  Position              := poScreenCenter;
  Width                 := FORM_W;
  Height                := FORM_H;
  Constraints.MinWidth  := 800;
  Constraints.MinHeight := 600;
  DoubleBuffered        := True;
  OnResize              := @OnContentResize;

  { ThemeManager — default light theme with baseline palette.
    The dark mode toggle in the AppBar flips this at runtime. }
  FThemeManager := TFRMaterialThemeManager.Create(Self);
  FThemeManager.Palette  := mpBaseline;
  FThemeManager.DarkMode := False;
  FThemeManager.Density  := ddNormal;
  FThemeManager.Variant  := mvFilled;
  FDarkMode := False;

  { Snackbar — shared instance for all toasts }
  FSnackbar := TFRMaterialSnackbar.Create(Self);
  FSnackbar.Duration := 3000;
  FSnackbar.Position := spBottom;

  { Root background panel }
  FPnFundo := TPanel.Create(Self);
  FPnFundo.Parent     := Self;
  FPnFundo.Align      := alClient;
  FPnFundo.BevelOuter := bvNone;
  FPnFundo.Color      := MD3Colors.Surface;

  BuildAppBar;
  BuildNavRail;

  { Scrollable content area to the right of the NavRail, below AppBar }
  FPnContent := TScrollBox.Create(Self);
  FPnContent.Parent      := FPnFundo;
  FPnContent.BorderStyle := bsNone;
  FPnContent.SetBounds(NAVRAIL_W, 0,
    FORM_W - NAVRAIL_W, FORM_H);
  FPnContent.Anchors := [akLeft, akTop, akRight, akBottom];
  FPnContent.Color := MD3Colors.Surface;
  FPnContent.AutoScroll := False;
  FPnContent.HorzScrollBar.Visible := False;
  FPnContent.VertScrollBar.Tracking := True;
  FPnContent.VertScrollBar.Visible := True;
  FPnContent.OnResize := @OnContentResize;

  Y := CONTENT_PAD;
  BuildKPICards;
  Y := Y + 140;
  BuildFormRow(Y);
  BuildGrid(Y);
  BuildControlsRow(Y);
  BuildThemeRow(Y);
  BuildButtonRow(Y);
  BuildFab;

  PopulateGrid;

  FContentHeight := Y + CONTENT_PAD;
  FPnContent.VertScrollBar.Range := FContentHeight;
end;

procedure TFmShowcase.BuildAppBar;
var
  Act: TFRMaterialTitleBarAction;
begin
  { Use the TitleBar built-in from TFRMaterialForm instead of a
    separate AppBar.  The TitleBar already has min/max/close buttons. }
  TitleBar.Title := 'FRCom';
  TitleBar.LeadingIcon := imMenu;

  Act := TitleBar.Actions.Add;
  Act.IconMode := imSearch;
  Act.Hint     := 'Search';

  Act := TitleBar.Actions.Add;
  Act.IconMode := imEdit;
  Act.Hint     := 'Toggle variant';
  Act.OnClick  := @OnVariantToggleClick;

  Act := TitleBar.Actions.Add;
  Act.IconMode := imNightlight;
  Act.Hint     := 'Toggle dark mode';
  Act.OnClick  := @OnDarkModeClick;

  Act := TitleBar.Actions.Add;
  Act.IconMode := imNotification;
  Act.Hint     := 'Notifications';

  Act := TitleBar.Actions.Add;
  Act.IconMode := imPerson;
  Act.Hint     := 'Profile';
end;

procedure TFmShowcase.BuildNavRail;
var
  Nav: TFRMaterialNavItem;
begin
  FNavRail := TFRMaterialNavRail.Create(Self);
  FNavRail.Parent := FPnFundo;
  FNavRail.SetBounds(0, 0, NAVRAIL_W, FORM_H);
  FNavRail.Anchors := [akLeft, akTop, akBottom];

  Nav := TFRMaterialNavItem(FNavRail.Items.Add);
  Nav.Caption := 'Dashboard';
  Nav.IconMode := imDashboard;

  Nav := TFRMaterialNavItem(FNavRail.Items.Add);
  Nav.Caption := 'Tasks';
  Nav.IconMode := imCheck;

  Nav := TFRMaterialNavItem(FNavRail.Items.Add);
  Nav.Caption := 'Reports';
  Nav.IconMode := imBarChart;

  Nav := TFRMaterialNavItem(FNavRail.Items.Add);
  Nav.Caption := 'Settings';
  Nav.IconMode := imSettings;

  Nav := TFRMaterialNavItem(FNavRail.Items.Add);
  Nav.Caption := 'Profile';
  Nav.IconMode := imPerson;

  FNavRail.ItemIndex := 0;
end;

procedure TFmShowcase.MakeKpiCard(ACard: TFRMaterialCard;
  const ATitle, AValue, ADelta: string; AColor: TColor);
var
  L: TFRMaterialLabel;
  LDelta: TLabel;
  Bdg: TFRMaterialBadge;
begin
  ACard.Parent := FPnContent;
  ACard.CardStyle := cssFilled;
  ACard.BorderRadius := 16;

  { Title — usa token OnSurfaceVariant que muda com o tema. }
  L := TFRMaterialLabel.Create(Self);
  L.Parent := ACard;
  L.AutoSize := False;
  L.SetBounds(16, 16, ACard.Width - 32, 18);
  L.Caption := ATitle;
  L.Font.Size := 10;
  L.ColorToken := ctOnSurfaceVariant;

  { Value — destaque, token OnSurface. }
  L := TFRMaterialLabel.Create(Self);
  L.Parent := ACard;
  L.AutoSize := False;
  L.SetBounds(16, 38, ACard.Width - 32, 36);
  L.Caption := AValue;
  L.Font.Size := 24;
  L.Font.Style := [fsBold];
  L.ColorToken := ctOnSurface;

  { Delta — cor customizada (verde/vermelho) passada como parametro.
    Usamos TLabel raw aqui porque queremos uma cor fixa semantica
    (success/danger), nao um token de tema. }
  LDelta := TLabel.Create(Self);
  LDelta.Parent := ACard;
  LDelta.AutoSize := True;
  LDelta.Left := 16;
  LDelta.Top := 82;
  LDelta.Caption := ADelta;
  LDelta.Font.Size := 10;
  LDelta.Font.Style := [fsBold];
  LDelta.Font.Color := AColor;
  LDelta.Transparent := True;

  Bdg := TFRMaterialBadge.Create(Self);
  Bdg.Parent := ACard;
  Bdg.BadgeMode := bmDot;
  Bdg.Width := 12;
  Bdg.Height := 12;
  Bdg.Left := ACard.Width - 24;
  Bdg.Top := 16;
end;

procedure TFmShowcase.BuildKPICards;
const
  CARD_W = 250;
  CARD_H = 110;
  GAP    = 16;
var
  StartX: Integer;
begin
  StartX := CONTENT_PAD;

  FCardRevenue := TFRMaterialCard.Create(Self);
  FCardRevenue.SetBounds(StartX, CONTENT_PAD, CARD_W, CARD_H);
  MakeKpiCard(FCardRevenue, 'MONTHLY REVENUE', 'R$ 84.250',
    '↑ 12.4% vs last month', RGBToColor($16, $a3, $4a));

  FCardUsers := TFRMaterialCard.Create(Self);
  FCardUsers.SetBounds(StartX + CARD_W + GAP, CONTENT_PAD, CARD_W, CARD_H);
  MakeKpiCard(FCardUsers, 'ACTIVE USERS', '1.284',
    '↑ 5.2% new users', RGBToColor($16, $a3, $4a));

  FCardGrowth := TFRMaterialCard.Create(Self);
  FCardGrowth.SetBounds(StartX + (CARD_W + GAP) * 2, CONTENT_PAD, CARD_W, CARD_H);
  MakeKpiCard(FCardGrowth, 'CONVERSION RATE', '24.7%',
    '↓ 0.8% vs last week', RGBToColor($ba, $1a, $1a));
end;

procedure TFmShowcase.BuildFormRow(var Y: Integer);
begin
  FLblForm := TFRMaterialLabel.Create(Self);
  FLblForm.Parent := FPnContent;
  FLblForm.SetBounds(CONTENT_PAD, Y, 400, 20);
  FLblForm.Caption := 'CUSTOMER FORM — GridPanel with AutoColSpan';
  FLblForm.Font.Size := 9;
  FLblForm.Font.Style := [fsBold];
  FLblForm.ColorToken := ctPrimary;
  Inc(Y, 28);

  FGridForm := TFRMaterialGridPanel.Create(Self);
  FGridForm.Parent := FPnContent;
  FGridForm.SetBounds(CONTENT_PAD, Y,
    FPnContent.ClientWidth - CONTENT_PAD * 2, 200);
  FGridForm.ColumnCount := 12;
  FGridForm.GapH := 16;
  FGridForm.GapV := 12;
  FGridForm.AutoColSpan := True;
  FGridForm.AutoHeight  := True;

  { Name — fsHuge (8 cols) }
  FEdName := TFRMaterialEdit.Create(Self);
  FEdName.Parent := FGridForm;
  FEdName.Caption := 'FULL NAME';
  FEdName.Edit.Text := 'Ana Silva Rodrigues';
  FEdName.AutoSelect := False;
  FEdName.FieldSize := TFRFieldSize.fsHuge;

  { Email — fsMedium (4 cols), com leading icon de envelope para demo }
  FEdEmail := TFRMaterialEdit.Create(Self);
  FEdEmail.Parent := FGridForm;
  FEdEmail.Caption := 'EMAIL';
  FEdEmail.Edit.Text := 'ana@example.com';
  FEdEmail.FieldSize := TFRFieldSize.fsMedium;
  FEdEmail.ShowLeadingIcon := True;
  FEdEmail.LeadingIconMode := imMail;

  { State — fsLarge (6 cols). Novo TFRMaterialCombo 100% custom, sem
    TComboBox nativo LCL. Populado com os 26 estados do Brasil para
    exercitar virtualizacao + busca integrada (> 8 items = scroll). }
  FEdCity := TFRMaterialCombo.Create(Self);
  FEdCity.Parent := FGridForm;
  FEdCity.Caption := 'STATE';
  FEdCity.Items.Add('Acre');
  FEdCity.Items.Add('Alagoas');
  FEdCity.Items.Add('Amapá');
  FEdCity.Items.Add('Amazonas');
  FEdCity.Items.Add('Bahia');
  FEdCity.Items.Add('Ceará');
  FEdCity.Items.Add('Espírito Santo');
  FEdCity.Items.Add('Goiás');
  FEdCity.Items.Add('Maranhão');
  FEdCity.Items.Add('Mato Grosso');
  FEdCity.Items.Add('Mato Grosso do Sul');
  FEdCity.Items.Add('Minas Gerais');
  FEdCity.Items.Add('Pará');
  FEdCity.Items.Add('Paraíba');
  FEdCity.Items.Add('Paraná');
  FEdCity.Items.Add('Pernambuco');
  FEdCity.Items.Add('Piauí');
  FEdCity.Items.Add('Rio de Janeiro');
  FEdCity.Items.Add('Rio Grande do Norte');
  FEdCity.Items.Add('Rio Grande do Sul');
  FEdCity.Items.Add('Rondônia');
  FEdCity.Items.Add('Roraima');
  FEdCity.Items.Add('Santa Catarina');
  FEdCity.Items.Add('São Paulo');
  FEdCity.Items.Add('Sergipe');
  FEdCity.Items.Add('Tocantins');
  FEdCity.ItemIndex := 23; { São Paulo }
  FEdCity.FieldSize := TFRFieldSize.fsLarge;

  { Birth date — fsSmall (3 cols) }
  FEdBirth := TFRMaterialDateEdit.Create(Self);
  FEdBirth.Parent := FGridForm;
  FEdBirth.Caption := 'BIRTH DATE';
  FEdBirth.Date := EncodeDate(1992, 7, 15);
  FEdBirth.FieldSize := TFRFieldSize.fsSmall;

  { Budget — fsSmall (3 cols). Usa sync default — responde ao toggle
    de variant do AppBar para demonstrar mvOutlined vs mvFilled. }
  FEdBudget := TFRMaterialEdit.Create(Self);
  FEdBudget.Parent := FGridForm;
  FEdBudget.Caption := 'BUDGET';
  FEdBudget.PrefixText := 'R$';
  FEdBudget.NumericMask := nmtMoney;
  FEdBudget.NumericValue := 12500.00;
  FEdBudget.FieldSize := TFRFieldSize.fsSmall;

  { Força re-layout agora que todos os FieldSizes estão definidos }
  FGridForm.DoLayout;

  Inc(Y, FGridForm.Height + 24);
end;

procedure TFmShowcase.BuildGrid(var Y: Integer);
const
  GRID_H = 240;
begin
  FLblGrid := TFRMaterialLabel.Create(Self);
  FLblGrid.Parent := FPnContent;
  FLblGrid.SetBounds(CONTENT_PAD, Y, 500, 20);
  FLblGrid.Caption := 'CUSTOMERS — VirtualDataGrid with zebra + hover states';
  FLblGrid.Font.Size := 9;
  FLblGrid.Font.Style := [fsBold];
  FLblGrid.ColorToken := ctPrimary;
  Inc(Y, 28);

  FGrid := TFRMaterialVirtualDataGrid.Create(Self);
  FGrid.Parent := FPnContent;
  FGrid.SetBounds(CONTENT_PAD, Y,
    FPnContent.ClientWidth - CONTENT_PAD * 2, GRID_H);
  FGrid.Density := ddNormal;
  FGrid.ZebraStripes := True;
  FGrid.AutoSort := True;
  FGrid.FilterEnabled := True;
  FGrid.EmptyText := 'Nenhum cliente cadastrado';
  FGrid.EmptyHint := 'Clique em RELOAD para carregar exemplos';
  FGrid.LoadingText := 'Loading customers...';
  FGrid.Margin := 4;  { Espaço para checkboxes do VirtualTreeView }

  with FGrid.Header.Columns.Add do begin Text := 'ID';           Width := 60;  end;
  with FGrid.Header.Columns.Add do begin Text := 'Nome';         Width := 240; end;
  with FGrid.Header.Columns.Add do begin Text := 'E-mail';       Width := 240; end;
  with FGrid.Header.Columns.Add do begin Text := 'Cidade';       Width := 160; end;
  with FGrid.Header.Columns.Add do
  begin
    Text := 'Faturamento';
    Width := 140;
    Alignment := taRightJustify;
  end;
  with FGrid.Header.Columns.Add do
  begin
    Text := 'Status';
    Width := 100;
    Alignment := taCenter;
  end;

  FGrid.Header.Options := FGrid.Header.Options + [hoVisible];

  Inc(Y, GRID_H + 24);
end;

procedure TFmShowcase.PopulateGrid;

  procedure Add(const AId, AName, AEmail, ACity, ARevenue, AStatus: string;
    AChecked: Boolean = False);
  var
    Node: PVirtualNode;
  begin
    Node := FGrid.AddChild(nil);
    FGrid.CheckType[Node] := ctCheckBox;
    if AChecked then
      FGrid.CheckState[Node] := csCheckedNormal;
    FGrid.Text[Node, 0] := AId;
    FGrid.Text[Node, 1] := AName;
    FGrid.Text[Node, 2] := AEmail;
    FGrid.Text[Node, 3] := ACity;
    FGrid.Text[Node, 4] := ARevenue;
    FGrid.Text[Node, 5] := AStatus;
  end;

begin
  FGrid.BeginUpdate;
  try
    FGrid.Clear;
    Add('001', 'Ana Silva Rodrigues',  'ana.silva@example.com',    'São Paulo',      'R$ 12.500,00', 'Active',   True);
    Add('002', 'Bruno Carvalho',       'bruno.c@example.com',      'Rio de Janeiro', 'R$  8.720,50', 'Active');
    Add('003', 'Carla Mendes Souza',   'carla.mendes@example.com', 'Belo Horizonte', 'R$ 24.150,00', 'Active',   True);
    Add('004', 'Diego Pereira',        'diego.p@example.com',      'Curitiba',       'R$  5.680,75', 'Trial');
    Add('005', 'Eduarda Martins',      'eduarda@example.com',      'São Paulo',      'R$ 15.320,00', 'Active');
    Add('006', 'Felipe Almeida Costa', 'felipe.a@example.com',     'Porto Alegre',   'R$  3.450,00', 'Inactive');
    Add('007', 'Gabriela Lima',        'gabi.lima@example.com',    'Salvador',       'R$ 19.800,25', 'Active',   True);
    Add('008', 'Henrique Vasconcelos', 'henrique.v@example.com',   'Recife',         'R$  6.920,00', 'Trial');
  finally
    FGrid.EndUpdate;
  end;
end;

procedure TFmShowcase.BuildControlsRow(var Y: Integer);
const
  ROW_H = 60;
var
  X: Integer;
begin
  FLblControls := TFRMaterialLabel.Create(Self);
  FLblControls.Parent := FPnContent;
  FLblControls.SetBounds(CONTENT_PAD, Y, 400, 20);
  FLblControls.Caption := 'QUICK FILTERS & CONTROLS';
  FLblControls.Font.Size := 9;
  FLblControls.Font.Style := [fsBold];
  FLblControls.ColorToken := ctPrimary;
  Inc(Y, 28);

  FPnControls := TPanel.Create(Self);
  FPnControls.Parent := FPnContent;
  FPnControls.SetBounds(CONTENT_PAD, Y,
    FPnContent.ClientWidth - CONTENT_PAD * 2, ROW_H);
  FPnControls.BevelOuter := bvNone;
  FPnControls.Color := MD3Colors.Surface;
  FPnControls.ParentColor := False;

  X := 8;

  { Switch + label }
  FSwitchLabel := TFRMaterialLabel.Create(Self);
  FSwitchLabel.Parent := FPnControls;
  FSwitchLabel.SetBounds(X, 20, 80, 20);
  FSwitchLabel.Caption := 'Only active';
  FSwitchLabel.Font.Size := 10;
  FSwitchLabel.ColorToken := ctOnSurface;
  Inc(X, 88);

  FSwitch := TFRMaterialSwitch.Create(Self);
  FSwitch.Parent := FPnControls;
  FSwitch.SetBounds(X, 14, 52, 32);
  FSwitch.Checked := True;
  Inc(X, 72);

  { Chips }
  FChipAssist := TFRMaterialChip.Create(Self);
  FChipAssist.Parent := FPnControls;
  FChipAssist.SetBounds(X, 16, 96, 32);
  FChipAssist.Caption := 'All';
  FChipAssist.ChipStyle := csFilter;
  FChipAssist.Selected := True;
  Inc(X, 104);

  FChipFilter := TFRMaterialChip.Create(Self);
  FChipFilter.Parent := FPnControls;
  FChipFilter.SetBounds(X, 16, 110, 32);
  FChipFilter.Caption := 'Enterprise';
  FChipFilter.ChipStyle := csFilter;
  Inc(X, 118);

  FChipInput := TFRMaterialChip.Create(Self);
  FChipInput.Parent := FPnControls;
  FChipInput.SetBounds(X, 16, 86, 32);
  FChipInput.Caption := 'Trial';
  FChipInput.ChipStyle := csFilter;
  Inc(X, 110);

  { Segmented — variant selector (Standard / Filled / Outlined) }
  FSegmented := TFRMaterialSegmentedButton.Create(Self);
  FSegmented.Parent := FPnControls;
  FSegmented.SetBounds(X, 12, 270, 36);
  FSegmented.Items.Add('Standard');
  FSegmented.Items.Add('Filled');
  FSegmented.Items.Add('Outlined');
  FSegmented.ItemIndex := 2; { mvOutlined = initial }
  FSegmented.OnChange := @OnSegmentedChange;
  Inc(X, 286);

  { Slider — density (0=Normal, 1=Compact, 2=Dense, 3=UltraDense) }
  FSlider := TFRMaterialSlider.Create(Self);
  FSlider.Parent := FPnControls;
  FSlider.SetBounds(X, 14, 140, 32);
  FSlider.Min := 0;
  FSlider.Max := 3;
  FSlider.Value := 0; { ddNormal = initial }
  FSlider.Discrete := True;
  FSlider.Steps := 3;
  FSlider.ShowValueLabel := True;
  FSlider.OnChange := @OnSliderChange;
  Inc(X, 156);

  FSliderLabel := TFRMaterialLabel.Create(Self);
  FSliderLabel.Parent := FPnControls;
  FSliderLabel.SetBounds(X, 20, 80, 20);
  FSliderLabel.Caption := 'Normal';
  FSliderLabel.Font.Size := 10;
  FSliderLabel.ColorToken := ctOnSurface;
  Inc(X, 96);

  { Progress circular }
  FProgress := TFRMaterialCircularProgress.Create(Self);
  FProgress.Parent := FPnControls;
  FProgress.SetBounds(X, 12, 36, 36);
  FProgress.Value := 72;

  Inc(Y, ROW_H + 24);
end;

procedure TFmShowcase.BuildThemeRow(var Y: Integer);
const
  SWATCH_SZ = 32;
  SWATCH_GAP = 10;
  ROW_H = 48;
  { 6 representative palettes + their seed colors (TColor = BGR) }
  PALETTES: array[0..5] of TFRMDPalette =
    (mpBaseline, mpBlue, mpGreen, mpOrange, mpRed, mpDeepPurple);
  SWATCH_COLORS: array[0..5] of TColor =
    ($00A45067, $00B85A1A, $00388E3C, $000D8CE5, $001B1BD6, $00A03B67);
  { Variant buttons }
  VARIANTS: array[0..2] of TFRMaterialVariant =
    (mvStandard, mvFilled, mvOutlined);
  VAR_CAPTIONS: array[0..2] of string =
    ('Standard', 'Filled', 'Outlined');
  VAR_STYLES: array[0..2] of TFRMDButtonStyle =
    (mbsOutlined, mbsFilled, mbsOutlined);
var
  X, I: Integer;
  Pn: TPanel;
  Btn: TFRMaterialButton;
begin
  FLblTheme := TFRMaterialLabel.Create(Self);
  FLblTheme.Parent := FPnContent;
  FLblTheme.SetBounds(CONTENT_PAD, Y, 400, 20);
  FLblTheme.Caption := 'THEME CUSTOMIZATION';
  FLblTheme.Font.Size := 9;
  FLblTheme.Font.Style := [fsBold];
  FLblTheme.ColorToken := ctPrimary;
  Inc(Y, 28);

  FPnTheme := TPanel.Create(Self);
  FPnTheme.Parent := FPnContent;
  FPnTheme.SetBounds(CONTENT_PAD, Y,
    FPnContent.ClientWidth - CONTENT_PAD * 2, ROW_H);
  FPnTheme.BevelOuter := bvNone;
  FPnTheme.Color := MD3Colors.Surface;
  FPnTheme.ParentColor := False;

  X := 8;

  { 6 color swatches }
  for I := 0 to 5 do
  begin
    Pn := TPanel.Create(Self);
    Pn.Parent := FPnTheme;
    Pn.SetBounds(X, (ROW_H - SWATCH_SZ) div 2, SWATCH_SZ, SWATCH_SZ);
    Pn.BevelOuter := bvNone;
    Pn.Color := SWATCH_COLORS[I];
    Pn.ParentColor := False;
    Pn.Cursor := crHandPoint;
    Pn.Tag := Ord(PALETTES[I]);
    Pn.OnClick := @OnSwatchClick;
    FColorSwatches[I] := Pn;
    Inc(X, SWATCH_SZ + SWATCH_GAP);
  end;

  Inc(X, 16);

  { Dark mode toggle }
  FDarkToggleLabel := TFRMaterialLabel.Create(Self);
  FDarkToggleLabel.Parent := FPnTheme;
  FDarkToggleLabel.SetBounds(X, (ROW_H - 20) div 2, 70, 20);
  FDarkToggleLabel.Caption := 'Dark mode';
  FDarkToggleLabel.Font.Size := 10;
  FDarkToggleLabel.ColorToken := ctOnSurface;
  Inc(X, 78);

  FDarkToggle := TFRMaterialSwitch.Create(Self);
  FDarkToggle.Parent := FPnTheme;
  FDarkToggle.SetBounds(X, (ROW_H - 32) div 2, 52, 32);
  FDarkToggle.Checked := False;
  FDarkToggle.OnChange := @OnDarkToggleChange;
  Inc(X, 72);

  Inc(X, 16);

  { 3 variant buttons + 1 density toggle }
  for I := 0 to 2 do
  begin
    Btn := TFRMaterialButton.Create(Self);
    Btn.Parent := FPnTheme;
    Btn.SetBounds(X, (ROW_H - 36) div 2, 100, 36);
    Btn.Caption := VAR_CAPTIONS[I];
    Btn.ButtonStyle := VAR_STYLES[I];
    Btn.Tag := Ord(VARIANTS[I]);
    Btn.OnClick := @OnVariantBtnClick;
    FBtnVariants[I] := Btn;
    Inc(X, 108);
  end;

  { 4th button: toggle density compact/normal }
  Btn := TFRMaterialButton.Create(Self);
  Btn.Parent := FPnTheme;
  Btn.SetBounds(X, (ROW_H - 36) div 2, 100, 36);
  Btn.Caption := 'Compact';
  Btn.ButtonStyle := mbsTonal;
  Btn.Tag := 99; { special tag for density }
  Btn.OnClick := @OnVariantBtnClick;
  FBtnVariants[3] := Btn;

  Inc(Y, ROW_H + 24);
end;

procedure TFmShowcase.BuildButtonRow(var Y: Integer);
const
  BTN_W    = 120;
  BTN_GAP  = 10;
  ROW_GAP  = 8;
  ICON_SZ  = 40;
  STYLES: array[0..4] of TFRMDButtonStyle =
    (mbsFilled, mbsTonal, mbsOutlined, mbsText, mbsElevated);
  CAPTIONS: array[0..4] of string =
    ('FILLED', 'TONAL', 'OUTLINED', 'TEXT', 'ELEVATED');
  DENSITIES: array[0..2] of TFRMDDensity = (ddNormal, ddCompact, ddDense);
  DENSITY_H: array[0..2] of Integer = (44, 38, 32);
var
  X, Row, Col, RowY, PanelH: Integer;
  Btn: TFRMaterialButton;
begin
  FLblButtons := TFRMaterialLabel.Create(Self);
  FLblButtons.Parent := FPnContent;
  FLblButtons.SetBounds(CONTENT_PAD, Y, 500, 20);
  FLblButtons.Caption := 'BUTTONS — 5 styles × 3 densities + icon + split';
  FLblButtons.Font.Size := 9;
  FLblButtons.Font.Style := [fsBold];
  FLblButtons.ColorToken := ctPrimary;
  Inc(Y, 28);

  { Panel height: 3 densities + spacing + icon row + 16px padding }
  PanelH := (DENSITY_H[0] + DENSITY_H[1] + DENSITY_H[2]) + ROW_GAP * 2
          + ICON_SZ + ROW_GAP + 16;

  FPnButtons := TPanel.Create(Self);
  FPnButtons.Parent := FPnContent;
  FPnButtons.SetBounds(CONTENT_PAD, Y,
    FPnContent.ClientWidth - CONTENT_PAD * 2, PanelH);
  FPnButtons.BevelOuter := bvNone;
  FPnButtons.Color := MD3Colors.Surface;
  FPnButtons.ParentColor := False;

  { 5 × 3 grid of TFRMaterialButton — coluna = estilo, linha = densidade }
  RowY := 8;
  for Row := 0 to 2 do
  begin
    X := 0;
    for Col := 0 to 4 do
    begin
      Btn := TFRMaterialButton.Create(Self);
      Btn.Parent := FPnButtons;
      Btn.SetBounds(X, RowY, BTN_W, DENSITY_H[Row]);
      Btn.Caption := CAPTIONS[Col];
      Btn.ButtonStyle := STYLES[Col];
      Btn.Density := DENSITIES[Row];
      if Col = 0 then
      begin
        Btn.ShowIcon := True;
        Btn.IconMode := imCheck;
      end;
      FBtnRows[Row, Col] := Btn;
      Inc(X, BTN_W + BTN_GAP);
    end;
    Inc(RowY, DENSITY_H[Row] + ROW_GAP);
  end;

  { Icon buttons row + split button + snackbar button, na direita do grid }
  X := (BTN_W + BTN_GAP) * 5 + 16;

  FBtnIconStd := TFRMaterialButtonIcon.Create(Self);
  FBtnIconStd.Parent := FPnButtons;
  FBtnIconStd.SetBounds(X, 8, ICON_SZ, ICON_SZ);
  FBtnIconStd.IconStyle := ibsStandard;
  FBtnIconStd.IconMode := imSearch;
  Inc(X, ICON_SZ + 6);

  FBtnIconFilled := TFRMaterialButtonIcon.Create(Self);
  FBtnIconFilled.Parent := FPnButtons;
  FBtnIconFilled.SetBounds(X, 8, ICON_SZ, ICON_SZ);
  FBtnIconFilled.IconStyle := ibsFilled;
  FBtnIconFilled.IconMode := imCheck;
  Inc(X, ICON_SZ + 6);

  FBtnIconTonal := TFRMaterialButtonIcon.Create(Self);
  FBtnIconTonal.Parent := FPnButtons;
  FBtnIconTonal.SetBounds(X, 8, ICON_SZ, ICON_SZ);
  FBtnIconTonal.IconStyle := ibsFilledTonal;
  FBtnIconTonal.IconMode := imRefresh;
  Inc(X, ICON_SZ + 6);

  FBtnIconOutlined := TFRMaterialButtonIcon.Create(Self);
  FBtnIconOutlined.Parent := FPnButtons;
  FBtnIconOutlined.SetBounds(X, 8, ICON_SZ, ICON_SZ);
  FBtnIconOutlined.IconStyle := ibsOutlined;
  FBtnIconOutlined.IconMode := imSettings;

  { Split button abaixo dos icons }
  FBtnSplit := TFRMaterialSplitButton.Create(Self);
  FBtnSplit.Parent := FPnButtons;
  FBtnSplit.SetBounds((BTN_W + BTN_GAP) * 5 + 16, 8 + ICON_SZ + ROW_GAP,
    180, 40);
  FBtnSplit.Caption := 'ACTIONS';
  FBtnSplit.ButtonStyle := mbsTonal;

  { Botao de Snackbar — reutiliza o click que ja existia }
  FBtnSnack := TFRMaterialButton.Create(Self);
  FBtnSnack.Parent := FPnButtons;
  FBtnSnack.SetBounds((BTN_W + BTN_GAP) * 5 + 16 + 192,
    8 + ICON_SZ + ROW_GAP, 180, 40);
  FBtnSnack.Caption := 'SHOW SNACKBAR';
  FBtnSnack.ButtonStyle := mbsElevated;
  FBtnSnack.OnClick := @OnSnackClick;

  { Reload/clear handlers agora vivem nos botoes filled e outlined da
    primeira linha — mantem o comportamento do demo }
  FBtnRows[0, 0].OnClick := @OnGridReloadClick;
  FBtnRows[0, 2].OnClick := @OnGridClearClick;

  Inc(Y, PanelH + 24);
end;

procedure TFmShowcase.BuildFab;
begin
  FFab := TFRMaterialFAB.Create(Self);
  FFab.Parent := FPnFundo;
  FFab.SetBounds(FORM_W - 96, FORM_H - 96, 56, 56);
  FFab.Anchors := [akRight, akBottom];
  FFab.IconMode := imPlus;
end;

procedure TFmShowcase.OnDarkModeClick(Sender: TObject);
begin
  FDarkMode := not FDarkMode;
  FThemeManager.DarkMode := FDarkMode;
  FDarkToggle.Checked := FDarkMode;
  FPnFundo.Color   := MD3Colors.Surface;
  FPnContent.Color := MD3Colors.Surface;
  FPnControls.Color := MD3Colors.Surface;
  FPnButtons.Color := MD3Colors.Surface;
  FPnTheme.Color   := MD3Colors.Surface;
  {$IFDEF MSWINDOWS}
  if FPnContent.HandleAllocated then
  begin
    if FDarkMode then
      FRSetWindowTheme(FPnContent.Handle, PWideChar(WideString('DarkMode_Explorer')), nil)
    else
      FRSetWindowTheme(FPnContent.Handle, PWideChar(WideString('Explorer')), nil);
    SendMessage(FPnContent.Handle, $031A, 0, 0);
  end;
  {$ENDIF}
  if FDarkMode then
    FSnackbar.Show('Dark mode on', stInfo)
  else
    FSnackbar.Show('Light mode on', stInfo);
end;

procedure TFmShowcase.OnSwatchClick(Sender: TObject);
var
  P: TFRMDPalette;
begin
  P := TFRMDPalette((Sender as TPanel).Tag);
  FThemeManager.Palette := P;
  FPnFundo.Color    := MD3Colors.Surface;
  FPnContent.Color  := MD3Colors.Surface;
  FPnControls.Color := MD3Colors.Surface;
  FPnButtons.Color  := MD3Colors.Surface;
  FPnTheme.Color    := MD3Colors.Surface;
  FSnackbar.Show('Palette: ' + MD3PaletteName(P), stInfo);
end;

procedure TFmShowcase.OnDarkToggleChange(Sender: TObject);
begin
  FDarkMode := FDarkToggle.Checked;
  FThemeManager.DarkMode := FDarkMode;
  FPnFundo.Color   := MD3Colors.Surface;
  FPnContent.Color := MD3Colors.Surface;
  FPnControls.Color := MD3Colors.Surface;
  FPnButtons.Color := MD3Colors.Surface;
  FPnTheme.Color   := MD3Colors.Surface;
  if FDarkMode then
    FSnackbar.Show('Dark mode on', stInfo)
  else
    FSnackbar.Show('Light mode on', stInfo);
end;

procedure TFmShowcase.OnVariantBtnClick(Sender: TObject);
var
  Btn: TFRMaterialButton;
begin
  Btn := Sender as TFRMaterialButton;
  if Btn.Tag = 99 then
  begin
    { Toggle density }
    if FThemeManager.Density = ddNormal then
    begin
      FThemeManager.Density := ddCompact;
      FSnackbar.Show('Density: Compact', stInfo);
    end
    else
    begin
      FThemeManager.Density := ddNormal;
      FSnackbar.Show('Density: Normal', stInfo);
    end;
  end
  else
  begin
    FThemeManager.Variant := TFRMaterialVariant(Btn.Tag);
    FSnackbar.Show('Variant: ' + Btn.Caption, stInfo);
  end;
end;

procedure TFmShowcase.OnVariantToggleClick(Sender: TObject);
var
  Msg: string;
begin
  if FThemeManager.Variant = mvOutlined then
  begin
    FThemeManager.Variant := mvFilled;
    Msg := 'Variant: Filled';
  end
  else
  begin
    FThemeManager.Variant := mvOutlined;
    Msg := 'Variant: Outlined';
  end;
  FSnackbar.Show(Msg, stInfo);
end;

procedure TFmShowcase.OnSliderChange(Sender: TObject);
const
  NAMES: array[0..3] of string = ('Normal', 'Compact', 'Dense', 'UltraDense');
  DENS:  array[0..3] of TFRMDDensity = (ddNormal, ddCompact, ddDense, ddUltraDense);
var
  Idx: Integer;
begin
  Idx := EnsureRange(Round(FSlider.Value), 0, 3);
  FThemeManager.Density := DENS[Idx];
  FSliderLabel.Caption := NAMES[Idx];
  FSnackbar.Show('Density: ' + NAMES[Idx], stInfo);
end;

procedure TFmShowcase.OnSegmentedChange(Sender: TObject);
const
  VARS: array[0..2] of TFRMaterialVariant = (mvStandard, mvFilled, mvOutlined);
  NAMES: array[0..2] of string = ('Standard', 'Filled', 'Outlined');
var
  Idx: Integer;
begin
  Idx := FSegmented.ItemIndex;
  if (Idx < 0) or (Idx > 2) then Exit;
  FThemeManager.Variant := VARS[Idx];
  FSnackbar.Show('Variant: ' + NAMES[Idx], stInfo);
end;

procedure TFmShowcase.OnSnackClick(Sender: TObject);
begin
  FSnackbar.Show('Changes saved successfully!', stSuccess);
end;

procedure TFmShowcase.OnGridReloadClick(Sender: TObject);
begin
  FGrid.Loading := True;
  Application.ProcessMessages;
  Sleep(800);
  PopulateGrid;
  FGrid.Loading := False;
  FSnackbar.Show('Data reloaded', stInfo);
end;

procedure TFmShowcase.OnGridClearClick(Sender: TObject);
begin
  FGrid.Loading := False;
  FGrid.Clear;
  FSnackbar.Show('Grid cleared', stInfo);
end;

procedure TFmShowcase.OnContentResize(Sender: TObject);
var
  W, ViewportW, SbW: Integer;
begin
  { TScrollBox.Width/.ClientWidth pode refletir o Range (largura virtual)
    quando filhos excedem a area visível. Calculamos o viewport real
    a partir do ClientWidth do form, que é sempre confiável. }
  ViewportW := Self.ClientWidth - NAVRAIL_W;
  { Desconta scrollbar vertical se visível }
  SbW := GetSystemMetrics(SM_CXVSCROLL);
  if FPnContent.VertScrollBar.IsScrollBarVisible then
    Dec(ViewportW, SbW);
  W := ViewportW - CONTENT_PAD * 2;
  if W < 100 then W := 100;
  FGridForm.Width    := W;
  FGrid.Width        := W;
  FPnControls.Width  := W;
  FPnTheme.Width     := W;
  FPnButtons.Width   := W;

  { Mantém o range vertical para scroll funcionar }
  if FContentHeight > 0 then
    FPnContent.VertScrollBar.Range := FContentHeight;
end;


end.

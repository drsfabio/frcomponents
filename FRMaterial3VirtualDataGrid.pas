unit FRMaterial3VirtualDataGrid;

{$mode delphi}{$H+}

{ TFRMaterialVirtualDataGrid — Material Design 3 VirtualStringTree.

  Descendente de TLazVirtualStringTree com estilização MD3 embutida:
  - Cabeçalho com SurfaceContainerHighest + fonte bold
  - State layers em hover/seleção (SecondaryContainer)
  - Suporte a TFRMDDensity (altura de nó ajustável)
  - Zebra stripes opcionais (SurfaceContainerLow em linhas pares)
  - Divider horizontal entre linhas (OutlineVariant)
  - Classificação automática com indicador visual (▲/▼)
  - Filtro por coluna com popup MD3 integrado
  - Edição inline com navegação Tab/Enter/Shift+Tab
  - Pintura MD3 automática de colunas editáveis
  - Nós hierárquicos com CheckBox e propagação de estado
  - 100% compatível com TLazVirtualStringTree

  Licença: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, Types, StdCtrls, ExtCtrls, Forms,
  Generics.Collections,
  {$IFDEF FPC} LCLType, LCLIntf, LResources, LMessages, {$ENDIF}
  laz.VirtualTrees, FRMaterial3Base, FRMaterialTheme;

type
  { ── Sort ── }

  TFRMDSortDirection = (sdNone, sdAscending, sdDescending);

  TFRMDSortColumnEvent = procedure(Sender: TObject; ACol: Integer;
    var ADirection: TFRMDSortDirection) of object;

  { ── Filter ── }

  TFRMDFilterApplyEvent = procedure(Sender: TObject; ACol: Integer;
    const AFilterText: String) of object;

  { ── Edit column ── }

  TFRMDEditColumnType = (ectInteger, ectFloat, ectText);

  TFRMDEditColumnConfig = record
    ColumnIndex: TColumnIndex;
    ColumnType: TFRMDEditColumnType;
    MinValue: Double;
    MaxValue: Double;
    DecimalPlaces: Integer;
    AllowNegative: Boolean;
  end;

  { ── Edit callbacks ── }

  TFRMDEditApplyEvent = procedure(Sender: TObject; Node: PVirtualNode;
    Column: TColumnIndex; const IntValue: Integer;
    const FloatValue: Double; const TextValue: String) of object;

  TFRMDEditGetValueEvent = procedure(Sender: TObject; Node: PVirtualNode;
    Column: TColumnIndex; out DisplayText: String) of object;

  { ── Generic node data for hierarchy ── }

  PFRMDNodeData = ^TFRMDNodeData;
  TFRMDNodeData = record
    Nivel: Integer;
    Texto: String;
    Data: TObject;
  end;

  { Forward }
  TFRMaterialVirtualDataGrid = class;
  TFRMDFilterPopup = class;

  { TFRMDFilterPopup — Popup MD3 para filtro de coluna }

  TFRMDFilterPopup = class(TCustomForm)
  private
    FGrid: TFRMaterialVirtualDataGrid;
    FColumn: Integer;
    FEdit: TEdit;
    FBtnApply: TPanel;
    FBtnClear: TPanel;
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnApplyClick(Sender: TObject);
    procedure BtnClearClick(Sender: TObject);
    procedure DoApplyFilter;
    procedure DoClearFilter;
    procedure FormDeactivate(Sender: TObject);
  public
    constructor CreatePopup(AGrid: TFRMaterialVirtualDataGrid; AColumn: Integer;
      AScreenPos: TPoint);
  end;

  { TFRMDGridEditLink — IVTEditLink integrado com MD3 }

  TFRMDGridEditLink = class(TInterfacedObject, IVTEditLink)
  private
    FGrid: TFRMaterialVirtualDataGrid;
    FEdit: TEdit;
    FTree: TBaseVirtualTree;
    FNode: PVirtualNode;
    FColumn: TColumnIndex;
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
  public
    constructor Create(AGrid: TFRMaterialVirtualDataGrid);
    destructor Destroy; override;
    function  BeginEdit: Boolean; stdcall;
    function  CancelEdit: Boolean; stdcall;
    function  EndEdit: Boolean; stdcall;
    function  GetBounds: TRect; stdcall;
    function  PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode;
                Column: TColumnIndex): Boolean; stdcall;
    procedure ProcessMessage(var Message: TLMessage); stdcall;
    procedure SetBounds(R: TRect); stdcall;
  end;

  { TFRMaterialVirtualDataGrid }

  TFRMaterialVirtualDataGrid = class(TLazVirtualStringTree, IFRMaterialComponent)
  private
    FSyncWithTheme: TFRMDSyncOptions;
    { Sort }
    FDensity: TFRMDDensity;
    FZebraStripes: Boolean;
    FSortCol: Integer;
    FSortDir: TFRMDSortDirection;
    FAutoSort: Boolean;
    FOnSortColumn: TFRMDSortColumnEvent;
    FMD3Initialized: Boolean;
    { Filter }
    FFilterTexts: TDictionary<Integer, String>;
    FFilterEnabled: Boolean;
    FOnFilterApply: TFRMDFilterApplyEvent;
    { Edit }
    FEditColumns: array of TFRMDEditColumnConfig;
    FOnEditApplyValue: TFRMDEditApplyEvent;
    FOnEditGetValue: TFRMDEditGetValueEvent;
    FPendingEditNode: PVirtualNode;
    FPendingEditColumn: TColumnIndex;
    FReverseNavigation: Boolean;
    FEditingNode: PVirtualNode;
    { Style }
    procedure SetDensity(AValue: TFRMDDensity);
    procedure SetZebraStripes(AValue: Boolean);
    procedure ApplyNodeHeight;
    procedure ApplyMD3Style;
    { Edit internals }
    function FindEditColumn(AIndex: TColumnIndex): Integer;
    procedure DoPendingEdit(Data: PtrInt);
    procedure ApplyParsedValue(Node: PVirtualNode; Column: TColumnIndex;
      const NewText: String; const Cfg: TFRMDEditColumnConfig);
    procedure ScheduleNextEdit(Node: PVirtualNode);
    { Sort/Filter internals }
    procedure DoInternalSort;
    procedure ApplyFilter;
    function MatchesFilter(Node: PVirtualNode): Boolean;
    procedure ShowFilterPopup(AColumn: Integer);
    function HasActiveFilter(AColumn: Integer): Boolean;
    { Internal event stubs (required so VT detects AdvancedOwnerDraw) }
    procedure InternalAdvancedHeaderDraw(Sender: TVTHeader;
      var PaintInfo: THeaderPaintInfo;
      const Elements: THeaderPaintElements);
    procedure InternalHeaderDrawQueryElements(Sender: TVTHeader;
      var PaintInfo: THeaderPaintInfo;
      var Elements: THeaderPaintElements);
  protected
    { Painting }
    procedure DoBeforeCellPaint(ACanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; CellPaintMode: TVTCellPaintMode;
      CellRect: TRect; var ContentRect: TRect); override;
    procedure DoPaintText(Node: PVirtualNode; const ACanvas: TCanvas;
      Column: TColumnIndex; TextType: TVSTTextType); override;
    procedure DoAfterCellPaint(ACanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; const CellRect: TRect); override;
    procedure PaintCheckImage(ACanvas: TCanvas;
      const ImageInfo: TVTImageInfo; Selected: Boolean); override;
    { Header }
    procedure DoHeaderDraw(ACanvas: TCanvas; Column: TVirtualTreeColumn;
      const R: TRect; Hover, Pressed: Boolean;
      DropMark: TVTDropMarkMode); override;
    procedure DoAdvancedHeaderDraw(var PaintInfo: THeaderPaintInfo;
      const Elements: THeaderPaintElements); override;
    procedure DoHeaderDrawQueryElements(var PaintInfo: THeaderPaintInfo;
      var Elements: THeaderPaintElements); override;
    procedure DoHeaderClick(HitInfo: TVTHeaderHitInfo); override;
    procedure DoHotChange(Old, New: PVirtualNode); override;
    function DoCompare(Node1, Node2: PVirtualNode;
      Column: TColumnIndex): Integer; override;
    procedure Loaded; override;
    { Editing overrides }
    procedure DoCanEdit(Node: PVirtualNode; Column: TColumnIndex;
      var Allowed: Boolean); override;
    function DoCreateEditor(Node: PVirtualNode;
      Column: TColumnIndex): IVTEditLink; override;
    procedure DoNewText(Node: PVirtualNode; Column: TColumnIndex;
      const Text: String); override;
    function DoCancelEdit: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const AThemeManager: TObject); virtual;

    { Ordena a coluna ACol. AAscending: True=Asc, False=Desc }
    procedure SortByColumn(ACol: Integer; AAscending: Boolean);
    { Reaplica as cores MD3 (chamar após trocar paleta/dark mode) }
    procedure RefreshMD3Colors;
    { Coluna/direção ativamente ordenada }
    property SortCol: Integer read FSortCol;
    property SortDir: TFRMDSortDirection read FSortDir;

    { ── Filtro ── }
    procedure SetFilterText(ACol: Integer; const AText: String);
    procedure ClearFilter(ACol: Integer);
    procedure ClearAllFilters;
    function GetFilterText(ACol: Integer): String;
    function HasAnyFilter: Boolean;

    { ── Export ── }
    procedure ExportToCSV(const AFileName: string; ADelimiter: Char = ','; AIncludeHeader: Boolean = True);
    procedure ExportToTXT(const AFileName: string; AIncludeHeader: Boolean = True);
    procedure ExportToHTML(const AFileName: string; const ATitle: string = '');

    { ── Edição inline ── }
    procedure AddEditColumn(AIndex: TColumnIndex; AType: TFRMDEditColumnType;
      AMinValue: Double = 0; AMaxValue: Double = 0;
      ADecimalPlaces: Integer = 2; AAllowNegative: Boolean = False);
    function IsEditableColumn(Column: TColumnIndex): Boolean;
    function GetEditColumnConfig(AIndex: TColumnIndex;
      out AConfig: TFRMDEditColumnConfig): Boolean;
    function GetNextEditColumn(ACurrent: TColumnIndex;
      AReverse: Boolean): TColumnIndex;
    property EditingNode: PVirtualNode read FEditingNode;

    { Parse/validação }
    class function ParseInteger(const AText: String): Integer; static;
    class function ParseFloat(const AText: String): Double; static;
    class function ClampValue(AValue: Double;
      const AConfig: TFRMDEditColumnConfig): Double; static;
    class function AllowedChars(AType: TFRMDEditColumnType;
      AAllowNegative: Boolean): TSysCharSet; static;

    { ── Hierarquia / CheckBox ── }
    procedure AddHierarchicalNode(const Keys, Textos: array of string;
      const DataObject: TObject;
      var NodeCache: TDictionary<String, PVirtualNode>;
      const CheckableLevels: array of Integer);
    function GetCheckedObjects: TList<TObject>;
    procedure CheckAllNodes(CheckValue: Boolean);
    procedure UncheckAllNodes;
    procedure SetChildrenCheckState(Parent: PVirtualNode; State: TCheckState);
    procedure UpdateParentsCheckState(Node: PVirtualNode);

  published
    { Compactação de linhas. Afeta DefaultNodeHeight. }
    property Density: TFRMDDensity read FDensity write SetDensity default ddNormal;
    { Alterna coloração zebra nas linhas de dados }
    property ZebraStripes: Boolean read FZebraStripes write SetZebraStripes default False;
    { Disparado ao clicar em um cabeçalho de coluna para ordenação }
    property OnSortColumn: TFRMDSortColumnEvent read FOnSortColumn write FOnSortColumn;
    { Quando True, ordena automaticamente pelo texto da célula ao clicar no header }
    property AutoSort: Boolean read FAutoSort write FAutoSort default True;
    { Habilita filtro por coluna (ícone de filtro no header, popup MD3) }
    property FilterEnabled: Boolean read FFilterEnabled write FFilterEnabled default True;
    { Disparado após aplicar um filtro }
    property OnFilterApply: TFRMDFilterApplyEvent read FOnFilterApply write FOnFilterApply;
    { Edição: disparado para gravar o valor editado }
    property OnEditApplyValue: TFRMDEditApplyEvent read FOnEditApplyValue write FOnEditApplyValue;
    { Edição: disparado para obter o valor atual do editor }
    property OnEditGetValue: TFRMDEditGetValueEvent read FOnEditGetValue write FOnEditGetValue;
    property SyncWithTheme: TFRMDSyncOptions read FSyncWithTheme write FSyncWithTheme default [toColor, toDensity, toVariant];
  end;

procedure Register;

implementation

uses Math, LazUTF8;

const
  { Win32 Edit control style flags for text alignment }
  ES_LEFT   = $0000;
  ES_CENTER = $0001;
  ES_RIGHT  = $0002;

function GetWindowLongW(hWnd: THandle; nIndex: Integer): DWord; stdcall; external 'user32.dll' name 'GetWindowLongW';
function SetWindowLongW(hWnd: THandle; nIndex: Integer; dwNewLong: DWord): DWord; stdcall; external 'user32.dll' name 'SetWindowLongW';

{ ══════════════════════════════════════════════════════════════════════════ }
{  TFRMDGridEditLink                                                       }
{ ══════════════════════════════════════════════════════════════════════════ }

constructor TFRMDGridEditLink.Create(AGrid: TFRMaterialVirtualDataGrid);
begin
  inherited Create;
  FGrid := AGrid;
end;

destructor TFRMDGridEditLink.Destroy;
begin
  FreeAndNil(FEdit);
  inherited;
end;

function TFRMDGridEditLink.PrepareEdit(Tree: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
var
  displayText: String;
  WStyle: DWord;
begin
  FTree   := Tree;
  FNode   := Node;
  FColumn := Column;

  FreeAndNil(FEdit);

  FEdit := TEdit.Create(Tree as TWinControl);
  FEdit.Visible     := False;
  FEdit.AutoSize    := False;
  FEdit.BorderStyle := bsNone;
  if (Column >= 0) and (Column < TLazVirtualStringTree(Tree).Header.Columns.Count) then
    FEdit.Alignment := TLazVirtualStringTree(Tree).Header.Columns[Column].Alignment
  else
    FEdit.Alignment := taRightJustify;
  FEdit.Parent      := Tree as TWinControl;
  FEdit.Color       := ColorToRGB(MD3Colors.SurfaceContainerHighest);
  FEdit.Font.Assign(Tree.Font);
  FEdit.Font.Color  := ColorToRGB(MD3Colors.OnSurface);
  FEdit.OnKeyDown  := EditKeyDown;
  FEdit.OnKeyPress := EditKeyPress;

  { Force Win32 alignment via window style — LCL TEdit.Alignment
    is unreliable on some widgetsets/BorderStyle combinations }
  if FEdit.HandleAllocated then
  begin
    WStyle := GetWindowLongW(FEdit.Handle, GWL_STYLE);
    WStyle := WStyle and not (ES_LEFT or ES_CENTER or ES_RIGHT);
    case FEdit.Alignment of
      taLeftJustify:  WStyle := WStyle or ES_LEFT;
      taCenter:       WStyle := WStyle or ES_CENTER;
      taRightJustify: WStyle := WStyle or ES_RIGHT;
    end;
    SetWindowLongW(FEdit.Handle, GWL_STYLE, WStyle);
  end;

  displayText := '0';
  if Assigned(FGrid.FOnEditGetValue) then
    FGrid.FOnEditGetValue(FGrid, Node, Column, displayText);

  FEdit.Text := displayText;
  Result := True;
end;

function TFRMDGridEditLink.BeginEdit: Boolean; stdcall;
begin
  FEdit.Show;
  FEdit.SetFocus;
  FEdit.SelectAll;
  Result := True;
end;

function TFRMDGridEditLink.CancelEdit: Boolean; stdcall;
begin
  if Assigned(FEdit) then
    FEdit.Hide;
  Result := True;
end;

function TFRMDGridEditLink.EndEdit: Boolean; stdcall;
var
  SavedText: String;
begin
  Result := True;
  if not Assigned(FEdit) then Exit;
  SavedText := FEdit.Text;
  FEdit.Hide;
  { Apply text — this triggers DoNewText → ScheduleNextEdit }
  TLazVirtualStringTree(FTree).Text[FNode, FColumn] := SavedText;
  { Do NOT call InvalidateNode here — VT's SetText already does it,
    and calling it again while tsEditing is still set can trigger
    UpdateEditBounds with stale state → AV }
end;

function TFRMDGridEditLink.GetBounds: TRect; stdcall;
begin
  Result := FEdit.BoundsRect;
end;

procedure TFRMDGridEditLink.SetBounds(R: TRect); stdcall;
var
  colLeft, colRight: Integer;
begin
  if not Assigned(FEdit) then Exit;

  if Assigned(FTree) and (FColumn >= 0) and
     (FColumn < TLazVirtualStringTree(FTree).Header.Columns.Count) then
  begin
    colLeft  := TLazVirtualStringTree(FTree).Header.Columns[FColumn].Left;
    colRight := colLeft + TLazVirtualStringTree(FTree).Header.Columns[FColumn].Width;
    R.Left  := colLeft;
    R.Right := colRight;
  end;

  { Inset by 2px so the Primary border from DoBeforeCellPaint stays visible }
  R.Left   := R.Left + 2;
  R.Top    := R.Top + 2;
  R.Right  := R.Right - 2;
  R.Bottom := R.Bottom - 2;

  FEdit.BoundsRect := R;
end;

procedure TFRMDGridEditLink.ProcessMessage(var Message: TLMessage); stdcall;
begin
  if Assigned(FEdit) then
    FEdit.Dispatch(Message);
end;

procedure TFRMDGridEditLink.EditKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN, VK_TAB:
    begin
      Key := 0;
      FGrid.FReverseNavigation := (ssShift in Shift);
      FGrid.FPendingEditColumn := FGrid.GetNextEditColumn(FColumn, ssShift in Shift);
      FTree.EndEditNode;
    end;
    VK_ESCAPE:
    begin
      Key := 0;
      FTree.CancelEditNode;
    end;
  end;
end;

procedure TFRMDGridEditLink.EditKeyPress(Sender: TObject; var Key: Char);
var
  cfg: TFRMDEditColumnConfig;
  allowed: TSysCharSet;
begin
  if FGrid.GetEditColumnConfig(FColumn, cfg) then
    allowed := TFRMaterialVirtualDataGrid.AllowedChars(cfg.ColumnType, cfg.AllowNegative)
  else
    allowed := ['0'..'9', #8];

  if not (Key in allowed) then
    Key := #0;
end;

{ ══════════════════════════════════════════════════════════════════════════ }
{  TFRMaterialVirtualDataGrid                                              }
{ ══════════════════════════════════════════════════════════════════════════ }

constructor TFRMaterialVirtualDataGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDensity      := ddNormal;
  FZebraStripes := False;
  FSortCol      := -1;
  FSortDir      := sdNone;
  FAutoSort     := True;
  FMD3Initialized := False;
  FFilterTexts    := TDictionary<Integer, String>.Create;
  FFilterEnabled  := True;
  FPendingEditNode   := nil;
  FPendingEditColumn := -1;
  FReverseNavigation := False;
  FEditingNode       := nil;
  FSyncWithTheme     := [toColor, toDensity, toVariant];

  { Defaults MD3 }
  BorderStyle     := bsNone;
  DefaultNodeHeight := 36;
  Font.Height     := -13;
  Font.Size       := 10;

  Header.Height   := 40;
  Header.Options  := Header.Options + [hoVisible, hoColumnResize, hoOwnerDraw]
                                    - [hoAutoResize, hoShowSortGlyphs];
  Header.Font.Height := -12;
  Header.Font.Size   := 9;
  Header.Style       := hsFlatButtons;
  Header.Background  := ColorToRGB(MD3Colors.SurfaceContainerHighest);

  { Assign event stubs so VT detects AdvancedOwnerDraw (checks Assigned()) }
  OnAdvancedHeaderDraw      := InternalAdvancedHeaderDraw;
  OnHeaderDrawQueryElements := InternalHeaderDrawQueryElements;

  TreeOptions.PaintOptions := TreeOptions.PaintOptions
    + [toHideFocusRect, toShowFilteredNodes,
       toAlwaysHideSelection, toHotTrack, toHideSelection]
    - [toShowTreeLines, toShowRoot, toShowButtons,
       toShowHorzGridLines, toShowVertGridLines];

  TreeOptions.SelectionOptions := TreeOptions.SelectionOptions + [toFullRowSelect];
  TreeOptions.MiscOptions := TreeOptions.MiscOptions - [toEditable];

  Margin    := 0;
  TextMargin := 8;

  FRMDRegisterComponent(Self);

  ApplyMD3Style;
  FMD3Initialized := True;
end;

destructor TFRMaterialVirtualDataGrid.Destroy;
begin
  FRMDUnregisterComponent(Self);
  Application.RemoveAsyncCalls(Self);
  FPendingEditNode   := nil;
  FPendingEditColumn := -1;
  FreeAndNil(FFilterTexts);
  inherited;
end;

procedure TFRMaterialVirtualDataGrid.ApplyTheme(const AThemeManager: TObject);
begin
  if not Assigned(AThemeManager) then Exit;

  if toDensity in FSyncWithTheme then
    SetDensity(FRMDGetThemeDensity(AThemeManager));

  RefreshMD3Colors;
end;

procedure TFRMaterialVirtualDataGrid.Loaded;
begin
  inherited Loaded;
  { Re-apply options that the .lfm may have overwritten }
  Header.Options := Header.Options + [hoOwnerDraw] - [hoShowSortGlyphs];
  Header.Style   := hsFlatButtons;
  Header.Background := ColorToRGB(MD3Colors.SurfaceContainerHighest);
  ApplyMD3Style;
end;

procedure TFRMaterialVirtualDataGrid.ApplyMD3Style;
begin
  Color             := ColorToRGB(MD3Colors.Surface);
  Font.Color        := ColorToRGB(MD3Colors.OnSurface);
  Header.Font.Color := ColorToRGB(MD3Colors.OnSurface);
  ApplyNodeHeight;
end;

procedure TFRMaterialVirtualDataGrid.ApplyNodeHeight;
var
  H: Integer;
begin
  H := 36 + MD3DensityDelta(FDensity);
  if H < 24 then H  := 24;
  DefaultNodeHeight := H;

  Header.Height := Max(32, 40 + MD3DensityDelta(FDensity));
end;

procedure TFRMaterialVirtualDataGrid.RefreshMD3Colors;
begin
  ApplyMD3Style;
  Invalidate;
end;

procedure TFRMaterialVirtualDataGrid.SetDensity(AValue: TFRMDDensity);
begin
  if FDensity = AValue then Exit;
  FDensity := AValue;
  ApplyNodeHeight;
  Invalidate;
end;

procedure TFRMaterialVirtualDataGrid.SetZebraStripes(AValue: Boolean);
begin
  if FZebraStripes = AValue then Exit;
  FZebraStripes := AValue;
  Invalidate;
end;

{ ── Painting ── }

procedure TFRMaterialVirtualDataGrid.DoBeforeCellPaint(ACanvas: TCanvas;
  Node: PVirtualNode; Column: TColumnIndex; CellPaintMode: TVTCellPaintMode;
  CellRect: TRect; var ContentRect: TRect);
var
  bg: TColor;
  isSelected, isHovered, isEditable: Boolean;
  NodeIdx: Cardinal;
  rect: TRect;
begin
  isSelected := Selected[Node];
  isHovered  := (Node = HotNode) and not isSelected;
  isEditable := IsEditableColumn(Column);

  if isSelected then
    bg := ColorToRGB(MD3Colors.SecondaryContainer)
  else if isHovered then
    bg := MD3Blend(ColorToRGB(MD3Colors.Surface),
            ColorToRGB(MD3Colors.OnSurface), 20)  { 8% state layer }
  else if isEditable then
    bg := MD3Blend(ColorToRGB(MD3Colors.Surface),
            ColorToRGB(MD3Colors.TertiaryContainer), 80)  { subtle editable hint }
  else
  begin
    NodeIdx := Node^.Index;
    if FZebraStripes and (NodeIdx mod 2 = 0) then
      bg := ColorToRGB(MD3Colors.SurfaceContainerLow)
    else
      bg := ColorToRGB(MD3Colors.Surface);
  end;

  ACanvas.Brush.Color := bg;
  ACanvas.FillRect(CellRect);

  { Editing border — Primary }
  if isEditable and Assigned(FEditingNode) and (Node = FEditingNode) then
  begin
    rect := CellRect;
    InflateRect(rect, -1, -1);
    ACanvas.Pen.Color   := ColorToRGB(MD3Colors.Primary);
    ACanvas.Pen.Width   := 2;
    ACanvas.Brush.Style := bsClear;
    ACanvas.Rectangle(rect);
    ACanvas.Pen.Width   := 1;
    ACanvas.Brush.Style := bsSolid;
  end;

  inherited DoBeforeCellPaint(ACanvas, Node, Column, CellPaintMode, CellRect, ContentRect);
end;

procedure TFRMaterialVirtualDataGrid.DoPaintText(Node: PVirtualNode;
  const ACanvas: TCanvas; Column: TColumnIndex; TextType: TVSTTextType);
var
  fg: TColor;
  IsParent: Boolean;
  NodeData: PFRMDNodeData;
begin
  { ── MD3 Color ── }
  if Selected[Node] then
    fg := ColorToRGB(MD3Colors.OnSecondaryContainer)
  else
    fg := ColorToRGB(MD3Colors.OnSurface);

  ACanvas.Font.Color := fg;

  { ── MD3 Typography ── }
  { Detect parent nodes: either has children, or hierarchy data with Nivel < leaf }
  IsParent := (Node^.ChildCount > 0);
  if (not IsParent) and (NodeDataSize = SizeOf(TFRMDNodeData)) then
  begin
    NodeData := GetNodeData(Node);
    if Assigned(NodeData) and Assigned(Node^.Parent) and
       (Node^.Parent <> RootNode) then
      { Node with parent = intermediate/leaf; no parent = top-level }
      IsParent := False
    else if Assigned(NodeData) and (NodeData^.Nivel = 0) then
      IsParent := True;
  end;

  if IsParent then
  begin
    { MD3 Title Small — parent/group rows: bold, 11pt }
    ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
    ACanvas.Font.Size  := 11;
  end
  else
  begin
    { MD3 Body Medium — leaf/data rows: normal, 10pt }
    ACanvas.Font.Style := ACanvas.Font.Style - [fsBold];
    ACanvas.Font.Size  := 10;
  end;

  inherited DoPaintText(Node, ACanvas, Column, TextType);
end;

procedure TFRMaterialVirtualDataGrid.DoAfterCellPaint(ACanvas: TCanvas;
  Node: PVirtualNode; Column: TColumnIndex; const CellRect: TRect);
begin
  inherited DoAfterCellPaint(ACanvas, Node, Column, CellRect);

  { Divider horizontal MD3 }
  ACanvas.Pen.Color := ColorToRGB(MD3Colors.OutlineVariant);
  ACanvas.Pen.Width := 1;
  ACanvas.MoveTo(CellRect.Left,  CellRect.Bottom - 1);
  ACanvas.LineTo(CellRect.Right, CellRect.Bottom - 1);
end;

procedure TFRMaterialVirtualDataGrid.PaintCheckImage(ACanvas: TCanvas;
  const ImageInfo: TVTImageInfo; Selected: Boolean);
var
  BoxSize, X, Y, Cx, Cy, R: Integer;
  BoxRect: TRect;
  FillColor, BorderColor, TickColor: TColor;
  IsChecked, IsMixed, IsUnchecked: Boolean;
begin
  { Determine check state from image Index }
  IsChecked   := ImageInfo.Index in [13, 14, 15, 16];   { ckCheckCheckedNormal..Disabled }
  IsMixed     := ImageInfo.Index in [17, 18, 19, 20];   { ckCheckMixedNormal..Disabled }
  IsUnchecked := ImageInfo.Index in [9, 10, 11, 12];    { ckCheckUncheckedNormal..Disabled }

  { Radio buttons (0..8) and plain buttons (21..24): fallback to default }
  if not (IsChecked or IsMixed or IsUnchecked) then
  begin
    inherited PaintCheckImage(ACanvas, ImageInfo, Selected);
    Exit;
  end;

  { ── Box metrics — MD3 uses 18dp checkbox ── }
  BoxSize := 18;
  R := 3;  { corner radius — MD3 spec: 2dp, we use 3 for canvas rendering }
  X := ImageInfo.XPos;
  Y := ImageInfo.YPos;

  { Center the box vertically within the image area }
  if ImageInfo.Images <> nil then
  begin
    if BoxSize < ImageInfo.Images.Height then
      Y := Y + (ImageInfo.Images.Height - BoxSize) div 2;
  end;

  BoxRect.Left   := X;
  BoxRect.Top    := Y;
  BoxRect.Right  := X + BoxSize;
  BoxRect.Bottom := Y + BoxSize;

  Cx := X + BoxSize div 2;
  Cy := Y + BoxSize div 2;

  { ── Colors based on state ── }
  if IsChecked or IsMixed then
  begin
    FillColor   := ColorToRGB(MD3Colors.Primary);
    BorderColor := FillColor;
    TickColor   := ColorToRGB(MD3Colors.OnPrimary);
  end
  else
  begin
    FillColor   := clNone;
    BorderColor := ColorToRGB(MD3Colors.OnSurfaceVariant);
    TickColor   := clNone;
  end;

  { ── Clear the area first to avoid artifacts ── }
  ACanvas.Brush.Style := bsSolid;
  if Selected then
    ACanvas.Brush.Color := ColorToRGB(MD3Colors.SecondaryContainer)
  else
    ACanvas.Brush.Color := ColorToRGB(MD3Colors.Surface);
  ACanvas.FillRect(BoxRect.Left - 1, BoxRect.Top - 1,
                   BoxRect.Right + 1, BoxRect.Bottom + 1);

  { ── Draw box ── }
  ACanvas.Pen.Style := psSolid;

  if IsChecked or IsMixed then
  begin
    { Filled rounded box }
    ACanvas.Brush.Color := FillColor;
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Pen.Color   := BorderColor;
    ACanvas.Pen.Width   := 1;
    ACanvas.RoundRect(BoxRect, R, R);
  end
  else
  begin
    { Empty rounded box with border }
    ACanvas.Brush.Style := bsClear;
    ACanvas.Pen.Color   := BorderColor;
    ACanvas.Pen.Width   := 2;
    ACanvas.RoundRect(BoxRect.Left + 1, BoxRect.Top + 1,
                      BoxRect.Right - 1, BoxRect.Bottom - 1, R, R);
  end;

  { ── Draw tick or dash ── }
  if IsChecked then
  begin
    { ✓ checkmark — proportional to box size }
    ACanvas.Pen.Color := TickColor;
    ACanvas.Pen.Width := 2;
    ACanvas.Pen.Style := psSolid;
    { Short leg }
    ACanvas.MoveTo(Cx - 4, Cy);
    ACanvas.LineTo(Cx - 1, Cy + 3);
    { Long leg }
    ACanvas.LineTo(Cx + 5, Cy - 4);
  end
  else if IsMixed then
  begin
    { ─ horizontal dash }
    ACanvas.Pen.Color := TickColor;
    ACanvas.Pen.Width := 2;
    ACanvas.Pen.Style := psSolid;
    ACanvas.MoveTo(X + 4, Cy);
    ACanvas.LineTo(X + BoxSize - 4, Cy);
  end;

  { Restore canvas state }
  ACanvas.Pen.Width   := 1;
  ACanvas.Brush.Style := bsSolid;
end;

{ ── Header ── }

procedure TFRMaterialVirtualDataGrid.DoHeaderDrawQueryElements(
  var PaintInfo: THeaderPaintInfo; var Elements: THeaderPaintElements);
begin
  { Claim ALL elements so VT skips all native drawing (background, text, glyphs) }
  Elements := [hpeBackground, hpeHeaderGlyph, hpeText, hpeSortGlyph, hpeDropMark];
end;

{ Dummy stubs — never called, just need to be Assigned() for VT AdvancedOwnerDraw detection }
procedure TFRMaterialVirtualDataGrid.InternalAdvancedHeaderDraw(
  Sender: TVTHeader; var PaintInfo: THeaderPaintInfo;
  const Elements: THeaderPaintElements);
begin
end;

procedure TFRMaterialVirtualDataGrid.InternalHeaderDrawQueryElements(
  Sender: TVTHeader; var PaintInfo: THeaderPaintInfo;
  var Elements: THeaderPaintElements);
begin
end;

procedure TFRMaterialVirtualDataGrid.DoAdvancedHeaderDraw(
  var PaintInfo: THeaderPaintInfo; const Elements: THeaderPaintElements);
var
  ACanvas: TCanvas;
  R: TRect;
  Column: TVirtualTreeColumn;
  Hover, Pressed: Boolean;
  bg, fg, divClr, sortClr, filterClr: TColor;
  txt, sortGlyph, filterIcon: string;
  TextRect: TRect;
  th, ty, sortW: Integer;
  Flags: Cardinal;
  hasFilter: Boolean;
  filterW: Integer;
begin
  { We draw everything in the hpeBackground pass; ignore subsequent passes }
  if not (hpeBackground in Elements) then
    Exit;

  ACanvas := PaintInfo.TargetCanvas;
  R       := PaintInfo.PaintRectangle;
  Column  := PaintInfo.Column;
  Hover   := PaintInfo.IsHoverIndex;
  Pressed := PaintInfo.IsDownIndex;

  divClr := ColorToRGB(MD3Colors.OutlineVariant);
  hasFilter := HasActiveFilter(Column.Index);

  { ── Background — flat MD3 surface ── }
  bg := ColorToRGB(MD3Colors.SurfaceContainerHighest);
  if Pressed then
    bg := MD3Blend(bg, ColorToRGB(MD3Colors.OnSurface), 24)    { 12% press }
  else if Hover then
    bg := MD3Blend(bg, ColorToRGB(MD3Colors.OnSurface), 16);   { 8% hover }

  fg := ColorToRGB(MD3Colors.OnSurface);

  ACanvas.Brush.Color := bg;
  ACanvas.Pen.Style   := psClear;
  ACanvas.FillRect(R);
  ACanvas.Pen.Style := psSolid;

  { ── Bottom divider — 2px Primary when sorted, 1px OutlineVariant otherwise ── }
  if (Column.Index = FSortCol) and (FSortDir <> sdNone) then
  begin
    ACanvas.Pen.Color := ColorToRGB(MD3Colors.Primary);
    ACanvas.Pen.Width := 2;
    ACanvas.MoveTo(R.Left,  R.Bottom - 1);
    ACanvas.LineTo(R.Right, R.Bottom - 1);
    ACanvas.Pen.Width := 1;
  end
  else
  begin
    ACanvas.Pen.Color := divClr;
    ACanvas.Pen.Width := 1;
    ACanvas.MoveTo(R.Left,  R.Bottom - 1);
    ACanvas.LineTo(R.Right, R.Bottom - 1);
  end;

  { ── Filter icon (rightmost area) ── }
  filterW := 0;
  if FFilterEnabled then
  begin
    if hasFilter then
    begin
      filterIcon := '⏚';
      filterClr  := ColorToRGB(MD3Colors.Primary);
    end
    else if Hover then
    begin
      filterIcon := '▽';
      filterClr  := MD3Blend(fg, bg, 100);
    end
    else
    begin
      filterIcon := '';
      filterClr  := bg;
    end;

    if filterIcon <> '' then
    begin
      ACanvas.Font.Assign(Header.Font);
      ACanvas.Font.Color  := filterClr;
      ACanvas.Font.Style  := [];
      ACanvas.Font.Height := -10;
      ACanvas.Brush.Style := bsClear;
      filterW := ACanvas.TextWidth(filterIcon) + 6;
      th := ACanvas.TextHeight(filterIcon);
      ty := R.Top + (R.Height - th) div 2;
      ACanvas.TextOut(R.Right - filterW, ty, filterIcon);
    end;
  end;

  { ── Sort glyph ── }
  sortGlyph := '';
  sortW := 0;
  if Column.Index = FSortCol then
  begin
    case FSortDir of
      sdAscending:  sortGlyph := ' ▲';
      sdDescending: sortGlyph := ' ▼';
    end;
  end;

  { ── Text — MD3 Label Large: medium weight, 11pt ── }
  txt := Column.Text;

  ACanvas.Font.Assign(Header.Font);
  ACanvas.Font.Color  := fg;
  ACanvas.Font.Style  := [fsBold];
  ACanvas.Font.Height := -13;
  ACanvas.Brush.Style := bsClear;

  if sortGlyph <> '' then
    sortW := ACanvas.TextWidth(sortGlyph);

  TextRect := R;
  TextRect.Left  := TextRect.Left + 10;
  TextRect.Right := TextRect.Right - 10 - filterW - sortW;

  Flags := DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS or DT_NOPREFIX;
  case Column.CaptionAlignment of
    taCenter:        Flags := Flags or DT_CENTER;
    taRightJustify:  Flags := Flags or DT_RIGHT;
  else
    Flags := Flags or DT_LEFT;
  end;

  DrawText(ACanvas.Handle, PChar(txt), Length(txt), TextRect, Flags);

  { ── Sort glyph — Primary color, after text ── }
  if sortGlyph <> '' then
  begin
    sortClr := ColorToRGB(MD3Colors.Primary);
    ACanvas.Font.Color  := sortClr;
    ACanvas.Font.Style  := [];
    ACanvas.Font.Height := -10;
    th := ACanvas.TextHeight('▲');
    ty := R.Top + (R.Height - th) div 2;
    ACanvas.TextOut(TextRect.Right + 2, ty, sortGlyph);
  end;

  ACanvas.Brush.Style := bsSolid;
  ACanvas.Font.Style  := [];
end;

procedure TFRMaterialVirtualDataGrid.DoHeaderDraw(ACanvas: TCanvas;
  Column: TVirtualTreeColumn; const R: TRect; Hover, Pressed: Boolean;
  DropMark: TVTDropMarkMode);
var
  bg, fg, divClr, sortClr, filterClr: TColor;
  txt, sortGlyph, filterIcon: string;
  TextRect: TRect;
  th, ty, sortW: Integer;
  Flags: Cardinal;
  hasFilter: Boolean;
  filterW: Integer;
begin
  divClr := ColorToRGB(MD3Colors.OutlineVariant);
  hasFilter := HasActiveFilter(Column.Index);

  { ── Background — flat MD3 surface ── }
  bg := ColorToRGB(MD3Colors.SurfaceContainerHighest);
  if Pressed then
    bg := MD3Blend(bg, ColorToRGB(MD3Colors.OnSurface), 24)
  else if Hover then
    bg := MD3Blend(bg, ColorToRGB(MD3Colors.OnSurface), 16);

  fg := ColorToRGB(MD3Colors.OnSurface);

  ACanvas.Brush.Color := bg;
  ACanvas.Pen.Style   := psClear;
  ACanvas.FillRect(R);
  ACanvas.Pen.Style := psSolid;

  { ── Bottom divider — 2px Primary when sorted, 1px OutlineVariant otherwise ── }
  if (Column.Index = FSortCol) and (FSortDir <> sdNone) then
  begin
    ACanvas.Pen.Color := ColorToRGB(MD3Colors.Primary);
    ACanvas.Pen.Width := 2;
    ACanvas.MoveTo(R.Left,  R.Bottom - 1);
    ACanvas.LineTo(R.Right, R.Bottom - 1);
    ACanvas.Pen.Width := 1;
  end
  else
  begin
    ACanvas.Pen.Color := divClr;
    ACanvas.Pen.Width := 1;
    ACanvas.MoveTo(R.Left,  R.Bottom - 1);
    ACanvas.LineTo(R.Right, R.Bottom - 1);
  end;

  { ── Filter icon (rightmost area) ── }
  filterW := 0;
  if FFilterEnabled then
  begin
    if hasFilter then
    begin
      filterIcon := '⏚';
      filterClr  := ColorToRGB(MD3Colors.Primary);
    end
    else if Hover then
    begin
      filterIcon := '▽';
      filterClr  := MD3Blend(fg, bg, 100);
    end
    else
    begin
      filterIcon := '';
      filterClr  := bg;
    end;

    if filterIcon <> '' then
    begin
      ACanvas.Font.Assign(Header.Font);
      ACanvas.Font.Color  := filterClr;
      ACanvas.Font.Style  := [];
      ACanvas.Font.Height := -10;
      ACanvas.Brush.Style := bsClear;
      filterW := ACanvas.TextWidth(filterIcon) + 6;
      th := ACanvas.TextHeight(filterIcon);
      ty := R.Top + (R.Height - th) div 2;
      ACanvas.TextOut(R.Right - filterW, ty, filterIcon);
    end;
  end;

  { ── Sort glyph ── }
  sortGlyph := '';
  sortW := 0;
  if Column.Index = FSortCol then
  begin
    case FSortDir of
      sdAscending:  sortGlyph := ' ▲';
      sdDescending: sortGlyph := ' ▼';
    end;
  end;

  { ── Text — MD3 Label Large ── }
  txt := Column.Text;

  ACanvas.Font.Assign(Header.Font);
  ACanvas.Font.Color  := fg;
  ACanvas.Font.Style  := [fsBold];
  ACanvas.Font.Height := -13;
  ACanvas.Brush.Style := bsClear;

  if sortGlyph <> '' then
    sortW := ACanvas.TextWidth(sortGlyph);

  TextRect := R;
  TextRect.Left  := TextRect.Left + 10;
  TextRect.Right := TextRect.Right - 10 - filterW - sortW;

  Flags := DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS or DT_NOPREFIX;
  case Column.CaptionAlignment of
    taCenter:        Flags := Flags or DT_CENTER;
    taRightJustify:  Flags := Flags or DT_RIGHT;
  else
    Flags := Flags or DT_LEFT;
  end;

  DrawText(ACanvas.Handle, PChar(txt), Length(txt), TextRect, Flags);

  { ── Sort glyph — Primary color ── }
  if sortGlyph <> '' then
  begin
    sortClr := ColorToRGB(MD3Colors.Primary);
    ACanvas.Font.Color  := sortClr;
    ACanvas.Font.Style  := [];
    ACanvas.Font.Height := -10;
    th := ACanvas.TextHeight('▲');
    ty := R.Top + (R.Height - th) div 2;
    ACanvas.TextOut(TextRect.Right + 2, ty, sortGlyph);
  end;

  ACanvas.Brush.Style := bsSolid;
  ACanvas.Font.Style  := [];
  { Do NOT call inherited — prevents native Win32 header painting }
end;

procedure TFRMaterialVirtualDataGrid.DoHeaderClick(HitInfo: TVTHeaderHitInfo);
var
  ColR: TRect;
  FilterZoneLeft: Integer;
begin
  if HitInfo.Column >= 0 then
  begin
    { Check if click was in the filter icon zone (rightmost 24px of header) }
    if FFilterEnabled and (HitInfo.Column < Header.Columns.Count) then
    begin
      ColR := Header.Columns[HitInfo.Column].GetRect;
      FilterZoneLeft := ColR.Right - 24;
      if HitInfo.X >= FilterZoneLeft then
      begin
        ShowFilterPopup(HitInfo.Column);
        inherited DoHeaderClick(HitInfo);
        Exit;
      end;
    end;

    { Normal sort click }
    if FSortCol = HitInfo.Column then
    begin
      case FSortDir of
        sdNone:       FSortDir := sdAscending;
        sdAscending:  FSortDir := sdDescending;
        sdDescending: FSortDir := sdNone;
      end;
    end
    else
    begin
      FSortCol := HitInfo.Column;
      FSortDir := sdAscending;
    end;

    if Assigned(FOnSortColumn) then
      FOnSortColumn(Self, FSortCol, FSortDir);

    if FAutoSort and (FSortDir <> sdNone) then
      DoInternalSort;

    Invalidate;
  end;

  inherited DoHeaderClick(HitInfo);
end;

procedure TFRMaterialVirtualDataGrid.DoHotChange(Old, New: PVirtualNode);
begin
  inherited DoHotChange(Old, New);
  Invalidate;
end;

procedure TFRMaterialVirtualDataGrid.SortByColumn(ACol: Integer; AAscending: Boolean);
begin
  FSortCol := ACol;
  if AAscending then
    FSortDir := sdAscending
  else
    FSortDir := sdDescending;

  if Assigned(FOnSortColumn) then
    FOnSortColumn(Self, FSortCol, FSortDir);

  if FAutoSort then
    DoInternalSort;

  Invalidate;
end;

{ ══════════════════════════════════════════════════════════════════════════ }
{  Editing overrides                                                       }
{ ══════════════════════════════════════════════════════════════════════════ }

procedure TFRMaterialVirtualDataGrid.DoCanEdit(Node: PVirtualNode;
  Column: TColumnIndex; var Allowed: Boolean);
begin
  inherited DoCanEdit(Node, Column, Allowed);
  { Override: only columns registered via AddEditColumn are editable }
  if Length(FEditColumns) > 0 then
  begin
    Allowed := IsEditableColumn(Column);
    if Allowed then
    begin
      FEditingNode := Node;
      InvalidateNode(Node);
    end;
  end;
end;

function TFRMaterialVirtualDataGrid.DoCreateEditor(Node: PVirtualNode;
  Column: TColumnIndex): IVTEditLink;
begin
  Result := inherited DoCreateEditor(Node, Column);
  if (Result = nil) and IsEditableColumn(Column) then
    Result := TFRMDGridEditLink.Create(Self);
end;

procedure TFRMaterialVirtualDataGrid.DoNewText(Node: PVirtualNode;
  Column: TColumnIndex; const Text: String);
var
  cfg: TFRMDEditColumnConfig;
begin
  if GetEditColumnConfig(Column, cfg) then
    ApplyParsedValue(Node, Column, Text, cfg);

  inherited DoNewText(Node, Column, Text);
  InvalidateNode(Node);
  ScheduleNextEdit(Node);
end;

function TFRMaterialVirtualDataGrid.DoCancelEdit: Boolean;
var
  OldEditNode: PVirtualNode;
begin
  OldEditNode := FEditingNode;
  FEditingNode := nil;
  Result := inherited DoCancelEdit;
  if Assigned(OldEditNode) then
    InvalidateNode(OldEditNode);
end;

{ ══════════════════════════════════════════════════════════════════════════ }
{  Edit column management                                                  }
{ ══════════════════════════════════════════════════════════════════════════ }

procedure TFRMaterialVirtualDataGrid.AddEditColumn(AIndex: TColumnIndex;
  AType: TFRMDEditColumnType; AMinValue: Double; AMaxValue: Double;
  ADecimalPlaces: Integer; AAllowNegative: Boolean);
var
  len: Integer;
begin
  len := Length(FEditColumns);
  SetLength(FEditColumns, len + 1);
  FEditColumns[len].ColumnIndex   := AIndex;
  FEditColumns[len].ColumnType    := AType;
  FEditColumns[len].MinValue      := AMinValue;
  FEditColumns[len].MaxValue      := AMaxValue;
  FEditColumns[len].DecimalPlaces := ADecimalPlaces;
  FEditColumns[len].AllowNegative := AAllowNegative;

  { Auto-enable editing }
  TreeOptions.MiscOptions := TreeOptions.MiscOptions
    + [toEditable, toEditOnDblClick, toGridExtensions];
end;

function TFRMaterialVirtualDataGrid.FindEditColumn(AIndex: TColumnIndex): Integer;
var
  i: Integer;
begin
  for i := 0 to High(FEditColumns) do
    if FEditColumns[i].ColumnIndex = AIndex then
      Exit(i);
  Result := -1;
end;

function TFRMaterialVirtualDataGrid.IsEditableColumn(Column: TColumnIndex): Boolean;
begin
  Result := FindEditColumn(Column) >= 0;
end;

function TFRMaterialVirtualDataGrid.GetEditColumnConfig(AIndex: TColumnIndex;
  out AConfig: TFRMDEditColumnConfig): Boolean;
var
  idx: Integer;
begin
  idx := FindEditColumn(AIndex);
  Result := idx >= 0;
  if Result then
    AConfig := FEditColumns[idx];
end;

function TFRMaterialVirtualDataGrid.GetNextEditColumn(ACurrent: TColumnIndex;
  AReverse: Boolean): TColumnIndex;
var
  i, curIdx: Integer;
begin
  if Length(FEditColumns) <= 1 then
    Exit(ACurrent);

  curIdx := FindEditColumn(ACurrent);
  if curIdx < 0 then
    Exit(ACurrent);

  if AReverse then
  begin
    i := curIdx - 1;
    if i < 0 then
      i := High(FEditColumns);
  end
  else
  begin
    i := curIdx + 1;
    if i > High(FEditColumns) then
      i := 0;
  end;

  Result := FEditColumns[i].ColumnIndex;
end;

procedure TFRMaterialVirtualDataGrid.ApplyParsedValue(Node: PVirtualNode;
  Column: TColumnIndex; const NewText: String;
  const Cfg: TFRMDEditColumnConfig);
var
  intVal: Integer;
  floatVal: Double;
begin
  case Cfg.ColumnType of
    ectInteger:
    begin
      floatVal := ClampValue(ParseInteger(NewText), Cfg);
      intVal   := Round(floatVal);
      if Assigned(FOnEditApplyValue) then
        FOnEditApplyValue(Self, Node, Column, intVal, floatVal, '');
    end;
    ectFloat:
    begin
      floatVal := ClampValue(ParseFloat(NewText), Cfg);
      intVal   := Round(floatVal);
      if Assigned(FOnEditApplyValue) then
        FOnEditApplyValue(Self, Node, Column, intVal, floatVal, '');
    end;
    ectText:
    begin
      if Assigned(FOnEditApplyValue) then
        FOnEditApplyValue(Self, Node, Column, 0, 0, NewText);
    end;
  end;
  FEditingNode := nil;
end;

procedure TFRMaterialVirtualDataGrid.ScheduleNextEdit(Node: PVirtualNode);
begin
  if FPendingEditColumn < 0 then
    Exit;

  if FReverseNavigation then
  begin
    if FPendingEditColumn = FEditColumns[High(FEditColumns)].ColumnIndex then
      FPendingEditNode := GetPreviousSibling(Node)
    else
      FPendingEditNode := Node;
  end
  else
  begin
    if FPendingEditColumn = FEditColumns[0].ColumnIndex then
      FPendingEditNode := GetNextSibling(Node)
    else
      FPendingEditNode := Node;
  end;

  if Assigned(FPendingEditNode) then
    Application.QueueAsyncCall(DoPendingEdit, 0)
  else
    FPendingEditColumn := -1;
end;

procedure TFRMaterialVirtualDataGrid.DoPendingEdit(Data: PtrInt);
var
  N: PVirtualNode;
  C: TColumnIndex;
begin
  N := FPendingEditNode;
  C := FPendingEditColumn;
  FPendingEditNode   := nil;
  FPendingEditColumn := -1;

  { Validate everything before starting a new edit }
  if not Assigned(N) then Exit;
  if csDestroying in ComponentState then Exit;
  if RootNode.ChildCount = 0 then Exit;
  if (C < 0) or (C >= Header.Columns.Count) then Exit;
  if not (vsInitialized in N^.States) then Exit;

  { Set FocusedColumn BEFORE EditNode so VT's UpdateEditBounds
    sees the correct FEditColumn value }
  FocusedColumn := C;
  FocusedNode   := N;
  Selected[N]   := True;
  EditNode(N, C);
end;

{ ── Parse utilities ── }

class function TFRMaterialVirtualDataGrid.ParseInteger(const AText: String): Integer;
var
  clean: String;
begin
  clean := StringReplace(AText, '.', '', [rfReplaceAll]);
  clean := StringReplace(clean, ',', '', [rfReplaceAll]);
  clean := Trim(clean);
  if not TryStrToInt(clean, Result) then
    Result := 0;
end;

class function TFRMaterialVirtualDataGrid.ParseFloat(const AText: String): Double;
var
  clean: String;
begin
  clean := StringReplace(AText, '.', '', [rfReplaceAll]);
  clean := StringReplace(clean, ',', DefaultFormatSettings.DecimalSeparator, [rfReplaceAll]);
  clean := Trim(clean);
  if not TryStrToFloat(clean, Result) then
    Result := 0.0;
end;

class function TFRMaterialVirtualDataGrid.ClampValue(AValue: Double;
  const AConfig: TFRMDEditColumnConfig): Double;
begin
  Result := AValue;
  if (not AConfig.AllowNegative) and (Result < 0) then
    Result := 0;
  if Result < AConfig.MinValue then
    Result := AConfig.MinValue;
  if (AConfig.MaxValue > 0) and (Result > AConfig.MaxValue) then
    Result := AConfig.MaxValue;
end;

class function TFRMaterialVirtualDataGrid.AllowedChars(
  AType: TFRMDEditColumnType; AAllowNegative: Boolean): TSysCharSet;
begin
  case AType of
    ectInteger:
    begin
      Result := ['0'..'9', #8];
      if AAllowNegative then
        Include(Result, '-');
    end;
    ectFloat:
    begin
      Result := ['0'..'9', ',', '.', #8];
      if AAllowNegative then
        Include(Result, '-');
    end;
    ectText:
      Result := [#1..#255];
  end;
end;

{ ══════════════════════════════════════════════════════════════════════════ }
{  Hierarchy / CheckBox                                                    }
{ ══════════════════════════════════════════════════════════════════════════ }

procedure TFRMaterialVirtualDataGrid.AddHierarchicalNode(
  const Keys, Textos: array of string; const DataObject: TObject;
  var NodeCache: TDictionary<String, PVirtualNode>;
  const CheckableLevels: array of Integer);
var
  Node: PVirtualNode;
  NodeData: PFRMDNodeData;
  i, j: Integer;
  KeyBuilder, FullKey, ParentKey: string;
  IsCheckable: Boolean;
begin
  if Length(Keys) <> Length(Textos) then
    raise Exception.Create('Keys e Textos devem ter o mesmo tamanho');

  TreeOptions.MiscOptions      := TreeOptions.MiscOptions + [toCheckSupport];
  TreeOptions.SelectionOptions := TreeOptions.SelectionOptions + [toMultiSelect];

  if NodeDataSize <> SizeOf(TFRMDNodeData) then
    NodeDataSize := SizeOf(TFRMDNodeData);

  for i := 0 to High(Keys) do
  begin
    KeyBuilder := '';
    for j := 0 to i do
      KeyBuilder := KeyBuilder + '|' + Keys[j];

    FullKey := KeyBuilder;

    if not NodeCache.TryGetValue(FullKey, Node) then
    begin
      if i = 0 then
        Node := AddChild(nil)
      else
      begin
        ParentKey := '';
        for j := 0 to i - 1 do
          ParentKey := ParentKey + '|' + Keys[j];

        if not NodeCache.TryGetValue(ParentKey, Node) then
          raise Exception.CreateFmt('ParentNode não encontrado para chave %s', [ParentKey]);

        Node := AddChild(Node);
      end;

      NodeData := GetNodeData(Node);
      if not Assigned(NodeData) then
        raise Exception.CreateFmt('NodeData não inicializado para chave %s', [FullKey]);

      FillChar(NodeData^, SizeOf(TFRMDNodeData), 0);
      NodeData^.Nivel := i;
      NodeData^.Texto := Textos[i];
      NodeData^.Data  := DataObject;

      IsCheckable := False;
      for j := 0 to High(CheckableLevels) do
        if i = CheckableLevels[j] then
        begin
          IsCheckable := True;
          Break;
        end;

      if IsCheckable then
        CheckType[Node] := ctCheckBox
      else
        CheckType[Node] := ctNone;

      NodeCache.Add(FullKey, Node);
    end;
  end;
end;

function TFRMaterialVirtualDataGrid.GetCheckedObjects: TList<TObject>;
var
  Node: PVirtualNode;
  Data: PFRMDNodeData;
begin
  Result := TList<TObject>.Create;
  Node := GetFirst;
  while Assigned(Node) do
  begin
    Data := GetNodeData(Node);
    if Assigned(Data) and (CheckState[Node] = csCheckedNormal) then
      Result.Add(Data^.Data);
    Node := GetNext(Node);
  end;
end;

procedure TFRMaterialVirtualDataGrid.CheckAllNodes(CheckValue: Boolean);
var
  Node: PVirtualNode;
begin
  BeginUpdate;
  try
    Node := GetFirst;
    while Assigned(Node) do
    begin
      if CheckType[Node] <> ctNone then
      begin
        if CheckValue then
          CheckState[Node] := csCheckedNormal
        else
          CheckState[Node] := csUncheckedNormal;
      end;
      Node := GetNext(Node);
    end;
  finally
    EndUpdate;
  end;
end;

procedure TFRMaterialVirtualDataGrid.UncheckAllNodes;
begin
  CheckAllNodes(False);
end;

procedure TFRMaterialVirtualDataGrid.SetChildrenCheckState(
  Parent: PVirtualNode; State: TCheckState);
var
  Child: PVirtualNode;
begin
  Child := GetFirstChild(Parent);
  while Assigned(Child) do
  begin
    if CheckType[Child] <> ctNone then
      CheckState[Child] := State;
    SetChildrenCheckState(Child, State);
    Child := GetNextSibling(Child);
  end;
end;

procedure TFRMaterialVirtualDataGrid.UpdateParentsCheckState(Node: PVirtualNode);
var
  P, Child: PVirtualNode;
  AllChecked, AllUnchecked: Boolean;
  CS: TCheckState;
begin
  P := NodeParent[Node];
  while Assigned(P) do
  begin
    AllChecked   := True;
    AllUnchecked := True;

    Child := GetFirstChild(P);
    while Assigned(Child) do
    begin
      if CheckType[Child] <> ctNone then
      begin
        CS := CheckState[Child];
        case CS of
          csCheckedNormal:   AllUnchecked := False;
          csUncheckedNormal: AllChecked := False;
          csMixedNormal:
          begin
            AllChecked   := False;
            AllUnchecked := False;
          end;
        end;
      end;
      Child := GetNextSibling(Child);
    end;

    if AllChecked then
      CheckState[P] := csCheckedNormal
    else if AllUnchecked then
      CheckState[P] := csUncheckedNormal
    else
      CheckState[P] := csMixedNormal;

    P := NodeParent[P];
  end;
end;

{ ══════════════════════════════════════════════════════════════════════════ }
{  Sort / Filter                                                           }
{ ══════════════════════════════════════════════════════════════════════════ }

function TFRMaterialVirtualDataGrid.DoCompare(Node1, Node2: PVirtualNode;
  Column: TColumnIndex): Integer;
var
  s1, s2: String;
  d1, d2: Double;
begin
  Result := inherited DoCompare(Node1, Node2, Column);
  { If consumer handled it via OnCompareNodes, respect that }
  if Result <> 0 then Exit;

  { Auto compare by cell text }
  s1 := Text[Node1, Column];
  s2 := Text[Node2, Column];

  { Try numeric comparison first }
  if TryStrToFloat(StringReplace(StringReplace(s1, '.', '', [rfReplaceAll]),
       ',', DefaultFormatSettings.DecimalSeparator, [rfReplaceAll]), d1) and
     TryStrToFloat(StringReplace(StringReplace(s2, '.', '', [rfReplaceAll]),
       ',', DefaultFormatSettings.DecimalSeparator, [rfReplaceAll]), d2) then
  begin
    if d1 < d2 then Result := -1
    else if d1 > d2 then Result := 1
    else Result := 0;
  end
  else
    Result := UTF8CompareStr(UTF8LowerCase(s1), UTF8LowerCase(s2));
end;

procedure TFRMaterialVirtualDataGrid.DoInternalSort;
begin
  if FSortCol < 0 then Exit;
  if FSortDir = sdNone then Exit;

  if FSortDir = sdAscending then
    Header.SortDirection := laz.VirtualTrees.sdAscending
  else
    Header.SortDirection := laz.VirtualTrees.sdDescending;

  Header.SortColumn := FSortCol;
  SortTree(FSortCol, Header.SortDirection, True);
end;

{ ── Filter ── }

function TFRMaterialVirtualDataGrid.HasActiveFilter(AColumn: Integer): Boolean;
var
  ft: String;
begin
  Result := FFilterTexts.TryGetValue(AColumn, ft) and (ft <> '');
end;

function TFRMaterialVirtualDataGrid.HasAnyFilter: Boolean;
var
  pair: TPair<Integer, String>;
begin
  for pair in FFilterTexts do
    if pair.Value <> '' then
      Exit(True);
  Result := False;
end;

function TFRMaterialVirtualDataGrid.GetFilterText(ACol: Integer): String;
begin
  if not FFilterTexts.TryGetValue(ACol, Result) then
    Result := '';
end;

procedure TFRMaterialVirtualDataGrid.SetFilterText(ACol: Integer; const AText: String);
begin
  if AText = '' then
    FFilterTexts.Remove(ACol)
  else
    FFilterTexts.AddOrSetValue(ACol, UTF8LowerCase(AText));
  ApplyFilter;

  if Assigned(FOnFilterApply) then
    FOnFilterApply(Self, ACol, AText);
end;

procedure TFRMaterialVirtualDataGrid.ClearFilter(ACol: Integer);
begin
  SetFilterText(ACol, '');
end;

procedure TFRMaterialVirtualDataGrid.ClearAllFilters;
begin
  FFilterTexts.Clear;
  ApplyFilter;
end;

function TFRMaterialVirtualDataGrid.MatchesFilter(Node: PVirtualNode): Boolean;
var
  pair: TPair<Integer, String>;
  cellText: String;
begin
  if FFilterTexts.Count = 0 then
    Exit(True);

  for pair in FFilterTexts do
  begin
    if pair.Value = '' then Continue;
    cellText := UTF8LowerCase(Text[Node, pair.Key]);
    if Pos(pair.Value, cellText) = 0 then
      Exit(False);
  end;
  Result := True;
end;

procedure TFRMaterialVirtualDataGrid.ApplyFilter;
var
  Node: PVirtualNode;
begin
  BeginUpdate;
  try
    Node := GetFirst;
    while Assigned(Node) do
    begin
      IsVisible[Node] := MatchesFilter(Node);
      Node := GetNext(Node, False);
    end;
  finally
    EndUpdate;
  end;
end;

procedure TFRMaterialVirtualDataGrid.ShowFilterPopup(AColumn: Integer);
var
  ColR: TRect;
  ScreenPt: TPoint;
begin
  ColR := Header.Columns[AColumn].GetRect;
  ScreenPt := ClientToScreen(Point(ColR.Right, ColR.Bottom));
  TFRMDFilterPopup.CreatePopup(Self, AColumn, ScreenPt);
end;

{ ══════════════════════════════════════════════════════════════════════════ }
{  TFRMDFilterPopup                                                        }
{ ══════════════════════════════════════════════════════════════════════════ }

constructor TFRMDFilterPopup.CreatePopup(AGrid: TFRMaterialVirtualDataGrid;
  AColumn: Integer; AScreenPos: TPoint);
var
  LblTitle: TLabel;
  curFilter: String;
begin
  inherited CreateNew(nil);
  FGrid   := AGrid;
  FColumn := AColumn;

  BorderStyle := bsNone;
  FormStyle   := fsStayOnTop;
  Width       := 220;
  Height      := 120;
  Color       := ColorToRGB(MD3Colors.SurfaceContainerHigh);
  Font.Color  := ColorToRGB(MD3Colors.OnSurface);
  Font.Height := -12;

  { Position: right-aligned to column, below header }
  Left := AScreenPos.X - Width;
  Top  := AScreenPos.Y + 2;

  OnDeactivate := FormDeactivate;

  { Title label }
  LblTitle := TLabel.Create(Self);
  LblTitle.Parent     := Self;
  LblTitle.SetBounds(12, 8, Width - 24, 18);
  LblTitle.Caption    := 'Filtrar: ' + AGrid.Header.Columns[AColumn].Text;
  LblTitle.Font.Style := [fsBold];
  LblTitle.Font.Color := ColorToRGB(MD3Colors.OnSurface);

  { Edit }
  FEdit := TEdit.Create(Self);
  FEdit.Parent      := Self;
  FEdit.SetBounds(12, 32, Width - 24, 26);
  FEdit.BorderStyle := bsSingle;
  FEdit.Color       := ColorToRGB(MD3Colors.SurfaceContainerHighest);
  FEdit.Font.Color  := ColorToRGB(MD3Colors.OnSurface);
  FEdit.Font.Height := -13;
  FEdit.OnKeyDown   := EditKeyDown;

  curFilter := AGrid.GetFilterText(AColumn);
  FEdit.Text := curFilter;

  { Apply button }
  FBtnApply := TPanel.Create(Self);
  FBtnApply.Parent     := Self;
  FBtnApply.SetBounds(12, 68, 90, 30);
  FBtnApply.Caption    := '✓ Filtrar';
  FBtnApply.Color      := ColorToRGB(MD3Colors.Primary);
  FBtnApply.Font.Color := ColorToRGB(MD3Colors.OnPrimary);
  FBtnApply.Font.Style := [fsBold];
  FBtnApply.BevelOuter := bvNone;
  FBtnApply.Cursor     := crHandPoint;
  FBtnApply.OnClick    := BtnApplyClick;

  { Clear button }
  FBtnClear := TPanel.Create(Self);
  FBtnClear.Parent     := Self;
  FBtnClear.SetBounds(112, 68, 90, 30);
  FBtnClear.Caption    := '✕ Limpar';
  FBtnClear.Color      := ColorToRGB(MD3Colors.SurfaceContainerHighest);
  FBtnClear.Font.Color := ColorToRGB(MD3Colors.OnSurface);
  FBtnClear.Font.Style := [fsBold];
  FBtnClear.BevelOuter := bvNone;
  FBtnClear.Cursor     := crHandPoint;
  FBtnClear.OnClick    := BtnClearClick;

  Show;
  FEdit.SetFocus;
  FEdit.SelectAll;
end;

procedure TFRMDFilterPopup.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
    begin
      Key := 0;
      DoApplyFilter;
    end;
    VK_ESCAPE:
    begin
      Key := 0;
      Close;
      Free;
    end;
  end;
end;

procedure TFRMDFilterPopup.BtnApplyClick(Sender: TObject);
begin
  DoApplyFilter;
end;

procedure TFRMDFilterPopup.BtnClearClick(Sender: TObject);
begin
  DoClearFilter;
end;

procedure TFRMDFilterPopup.DoApplyFilter;
begin
  FGrid.SetFilterText(FColumn, Trim(FEdit.Text));
  FGrid.Invalidate;
  Close;
  Free;
end;

procedure TFRMDFilterPopup.DoClearFilter;
begin
  FGrid.ClearFilter(FColumn);
  FGrid.Invalidate;
  Close;
  Free;
end;

procedure TFRMDFilterPopup.FormDeactivate(Sender: TObject);
begin
  Close;
  Free;
end;

{ ── Export helpers ── }

function MD3CSVQuote(const S: string; ADelimiter: Char): string;
begin
  if (Pos(ADelimiter, S) > 0) or (Pos('"', S) > 0) or
     (Pos(#10, S) > 0) or (Pos(#13, S) > 0) then
    Result := '"' + StringReplace(S, '"', '""', [rfReplaceAll]) + '"'
  else
    Result := S;
end;

function MD3HTMLEscape(const S: string): string;
begin
  Result := StringReplace(S, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
end;

procedure TFRMaterialVirtualDataGrid.ExportToCSV(const AFileName: string;
  ADelimiter: Char; AIncludeHeader: Boolean);
var
  SL: TStringList;
  Node: PVirtualNode;
  Line, CellText: string;
  i: Integer;
begin
  SL := TStringList.Create;
  try
    if AIncludeHeader then
    begin
      Line := '';
      for i := 0 to Header.Columns.Count - 1 do
      begin
        if not (coVisible in Header.Columns[i].Options) then Continue;
        if Line <> '' then Line := Line + ADelimiter;
        Line := Line + MD3CSVQuote(Header.Columns[i].Text, ADelimiter);
      end;
      SL.Add(Line);
    end;

    Node := GetFirst;
    while Node <> nil do
    begin
      Line := '';
      for i := 0 to Header.Columns.Count - 1 do
      begin
        if not (coVisible in Header.Columns[i].Options) then Continue;
        CellText := Self.Text[Node, i];
        if Line <> '' then Line := Line + ADelimiter;
        Line := Line + MD3CSVQuote(CellText, ADelimiter);
      end;
      SL.Add(Line);
      Node := GetNext(Node);
    end;

    SL.SaveToFile(AFileName);
  finally
    SL.Free;
  end;
end;

procedure TFRMaterialVirtualDataGrid.ExportToTXT(const AFileName: string;
  AIncludeHeader: Boolean);
begin
  ExportToCSV(AFileName, #9, AIncludeHeader);
end;

procedure TFRMaterialVirtualDataGrid.ExportToHTML(const AFileName: string;
  const ATitle: string);
var
  SL: TStringList;
  Node: PVirtualNode;
  CellText, Title: string;
  i: Integer;
  bg, fg, hdrBg, hdrFg, borderClr: TColor;

  function ColorToHex(C: TColor): string;
  begin
    C := ColorToRGB(C);
    Result := '#' + IntToHex(Red(C), 2) + IntToHex(Green(C), 2) + IntToHex(Blue(C), 2);
  end;

begin
  bg        := ColorToRGB(MD3Colors.Surface);
  fg        := ColorToRGB(MD3Colors.OnSurface);
  hdrBg     := ColorToRGB(MD3Colors.SurfaceContainerHighest);
  hdrFg     := ColorToRGB(MD3Colors.OnSurface);
  borderClr := ColorToRGB(MD3Colors.OutlineVariant);

  if ATitle <> '' then
    Title := MD3HTMLEscape(ATitle)
  else
    Title := 'Export';

  SL := TStringList.Create;
  try
    SL.Add('<!DOCTYPE html>');
    SL.Add('<html><head><meta charset="utf-8">');
    SL.Add('<title>' + Title + '</title>');
    SL.Add('<style>');
    SL.Add('body{font-family:"Segoe UI",Roboto,sans-serif;background:' + ColorToHex(bg) + ';color:' + ColorToHex(fg) + ';margin:24px}');
    SL.Add('h1{font-size:22px;font-weight:400;margin-bottom:16px}');
    SL.Add('table{border-collapse:collapse;width:100%}');
    SL.Add('th{background:' + ColorToHex(hdrBg) + ';color:' + ColorToHex(hdrFg) + ';font-weight:600;text-align:left;padding:12px 16px;border-bottom:1px solid ' + ColorToHex(borderClr) + '}');
    SL.Add('td{padding:12px 16px;border-bottom:1px solid ' + ColorToHex(borderClr) + '}');
    SL.Add('tr:hover td{background:rgba(0,0,0,0.04)}');
    SL.Add('</style></head><body>');
    SL.Add('<h1>' + Title + '</h1>');
    SL.Add('<table>');

    { Header }
    SL.Add('<thead><tr>');
    for i := 0 to Header.Columns.Count - 1 do
    begin
      if not (coVisible in Header.Columns[i].Options) then Continue;
      SL.Add('<th>' + MD3HTMLEscape(Header.Columns[i].Text) + '</th>');
    end;
    SL.Add('</tr></thead>');

    { Body }
    SL.Add('<tbody>');
    Node := GetFirst;
    while Node <> nil do
    begin
      SL.Add('<tr>');
      for i := 0 to Header.Columns.Count - 1 do
      begin
        if not (coVisible in Header.Columns[i].Options) then Continue;
        CellText := MD3HTMLEscape(Self.Text[Node, i]);
        SL.Add('<td>' + CellText + '</td>');
      end;
      SL.Add('</tr>');
      Node := GetNext(Node);
    end;
    SL.Add('</tbody></table></body></html>');

    SL.SaveToFile(AFileName);
  finally
    SL.Free;
  end;
end;

{ ── Registration ── }

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialvirtualdatagrid_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialVirtualDataGrid]);
end;

end.

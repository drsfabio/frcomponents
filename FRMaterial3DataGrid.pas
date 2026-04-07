unit FRMaterial3DataGrid;

{$mode objfpc}{$H+}

{ TFRMaterialDataGrid — Material Design 3 Data Table para Lazarus.

  Wrapper sobre TStringGrid que implementa a especificação MD3 de tabelas:
  - Cabeçalho com SurfaceContainerHighest + fonte em peso bold
  - Linhas com state layer em hover/seleção (SecondaryContainer)
  - Suporte a TFRMDDensity (altura de linha ajustável)
  - Zebra stripes opcionais (SurfaceContainerLow nas linhas pares)
  - Colunas redimensionáveis (padrão do TStringGrid)
  - Borda do componente no estilo MD3 (OutlineVariant)
  - Evento OnSortColumn para ordenação customizada

  Uso básico:
    DataGrid1.Columns.Add.Title.Caption := 'Nome';
    DataGrid1.Columns.Add.Title.Caption := 'Valor';
    DataGrid1.Cells[0, 1] := 'João';
    DataGrid1.Cells[1, 1] := 'R$ 1.234,56';
    DataGrid1.Density := ddCompact;

  Licença: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, Grids, Types, StdCtrls,
  {$IFDEF FPC} LResources, LCLType, LMessages, {$ENDIF}
  BGRABitmap, BGRABitmapTypes,
  FRMaterial3Base, FRMaterialTheme;

type
  TFRMDSortDirection = (sdNone, sdAscending, sdDescending);

  TFRMDSortEvent = procedure(Sender: TObject; ACol: Integer;
    var ADirection: TFRMDSortDirection) of object;

  TFRMaterialDataGrid = class(TStringGrid, IFRMaterialComponent)
  private
    FSyncWithTheme: TFRMDSyncOptions;
    FDensity: TFRMDDensity;
    FZebraStripes: Boolean;
    FSortCol: Integer;
    FSortDir: TFRMDSortDirection;
    FOnSortColumn: TFRMDSortEvent;
    FHoveredRow: Integer;
    procedure SetDensity(AValue: TFRMDDensity);
    procedure SetZebraStripes(AValue: Boolean);
    procedure ApplyRowHeight;
    procedure ApplyMD3Style;
    function GetRowHeight: Integer;
  protected
    procedure DrawCell(ACol, ARow: Integer; ARect: TRect;
      AState: TGridDrawState); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseLeave; override;
    procedure HeaderClick(IsColumn: Boolean; Index: Integer); override;
    procedure SelectEditor; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const AThemeManager: TObject); virtual;
    { Ordena a coluna ACol pelo índice. AscDesc: True=Asc, False=Desc }
    procedure SortByColumn(ACol: Integer; AAscending: Boolean);
    { Col/linha ativamente ordenada (somente leitura) }
    property SortCol: Integer read FSortCol;
    property SortDir: TFRMDSortDirection read FSortDir;
  published
    { Compactação de linhas. Afeta RowHeights quando alterado. }
    property Density: TFRMDDensity read FDensity write SetDensity default ddNormal;
    { Alterna coloração zebra nas linhas de dados }
    property ZebraStripes: Boolean read FZebraStripes write SetZebraStripes default False;
    { Disparado ao clicar em um cabeçalho de coluna }
    property OnSortColumn: TFRMDSortEvent read FOnSortColumn write FOnSortColumn;
    property SyncWithTheme: TFRMDSyncOptions read FSyncWithTheme write FSyncWithTheme default [toColor, toDensity, toVariant];
    { Herda todas as propriedades do TStringGrid }
    property Align;
    property Anchors;
    property BorderSpacing;
    property ColCount;
    property ColWidths;
    property Columns;
    property Constraints;
    property DefaultColWidth;
    property Enabled;
    property FixedCols;
    property FixedRows;
    property Font;
    property Options;
    property PopupMenu;
    property RowCount;
    property ScrollBars;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnSelectCell;
  end;

procedure Register;

implementation

type
  { Editor customizado para desabilitar a seleção forçada e ajustar margens }
  TFRMaterialCellEditor = class(TStringCellEditor)
  protected
    procedure DoEnter; override;
  public
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
  end;

{ ── helpers ── }

function BrightenColor(AColor: TColor; AAmount: Integer): TColor;
var r, g, b: Integer;
begin
  AColor := ColorToRGB(AColor);
  r := Red(AColor)   + AAmount; if r > 255 then r := 255;
  g := Green(AColor) + AAmount; if g > 255 then g := 255;
  b := Blue(AColor)  + AAmount; if b > 255 then b := 255;
  Result := RGBToColor(r, g, b);
end;

{ ── TFRMaterialDataGrid ── }

constructor TFRMaterialDataGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDensity      := ddNormal;
  FZebraStripes := False;
  FSortCol      := -1;
  FSortDir      := sdNone;
  FHoveredRow   := -1;
  FSyncWithTheme := [toColor, toDensity, toVariant];

  { Defaults do grid }
  FixedRows     := 1;
  FixedCols     := 0;
  RowCount      := 5;
  ColCount      := 3;
  DefaultColWidth := 120;
  Options       := Options + [goRowSelect, goColSizing, goSmoothScroll]
                            - [goVertLine, goHorzLine, goDrawFocusSelected];

  ApplyMD3Style;
  
  FRMDRegisterComponent(Self);
end;

destructor TFRMaterialDataGrid.Destroy;
begin
  FRMDUnregisterComponent(Self);
  inherited Destroy;
end;

procedure TFRMaterialDataGrid.ApplyTheme(const AThemeManager: TObject);
begin
  if not Assigned(AThemeManager) then Exit;

  if toDensity in FSyncWithTheme then
    SetDensity(FRMDGetThemeDensity(AThemeManager));

  ApplyMD3Style;
end;

function TFRMaterialDataGrid.GetRowHeight: Integer;
begin
  { Altura padrão MD3: 52px para dados, ajustada pelo delta de densidade }
  Result := 52 + MD3DensityDelta(FDensity);
  if Result < 28 then Result := 28;
end;

procedure TFRMaterialDataGrid.ApplyRowHeight;
var i: Integer;
begin
  { Cabeçalho é um pouco maior: 56px base }
  DefaultRowHeight := GetRowHeight;
  if FixedRows > 0 then
    RowHeights[0] := 56 + MD3DensityDelta(FDensity);
end;

procedure TFRMaterialDataGrid.ApplyMD3Style;
begin
  { Remove borda padrão do Lazarus; vamos pintar nós mesmos }
  BorderStyle := bsNone;
  Color       := ColorToRGB(MD3Colors.Surface);
  Font.Color  := ColorToRGB(MD3Colors.OnSurface);

  ApplyRowHeight;
  Invalidate;
end;

procedure TFRMaterialDataGrid.SetDensity(AValue: TFRMDDensity);
begin
  if FDensity = AValue then Exit;
  FDensity := AValue;
  ApplyRowHeight;
  Invalidate;
end;

procedure TFRMaterialDataGrid.SetZebraStripes(AValue: Boolean);
begin
  if FZebraStripes = AValue then Exit;
  FZebraStripes := AValue;
  Invalidate;
end;

procedure TFRMaterialDataGrid.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
var
  bg, fg: TColor;
  isHeader, isSelected, isHovered, isFixed: Boolean;
  txt: string;
  sortArrow: string;
  tw: Integer;
begin
  isHeader   := ARow < FixedRows;
  isFixed    := ACol < FixedCols;
  isSelected := gdSelected in AState;
  isHovered  := (ARow = FHoveredRow) and not isHeader;

  { ── Background ── }
  if isHeader then
    bg := ColorToRGB(MD3Colors.SurfaceContainerHighest)
  else if isSelected then
    bg := ColorToRGB(MD3Colors.SecondaryContainer)
  else if isHovered then
    bg := MD3Blend(ColorToRGB(MD3Colors.Surface),
            ColorToRGB(MD3Colors.OnSurface), 20)  { 8% state layer }
  else if FZebraStripes and (ARow mod 2 = 0) then
    bg := ColorToRGB(MD3Colors.SurfaceContainerLow)
  else
    bg := ColorToRGB(MD3Colors.Surface);

  Canvas.Brush.Color := bg;
  Canvas.FillRect(ARect);

  { ── Divider horizontal (apenas entre linhas de dados) ── }
  if not isHeader then
  begin
    Canvas.Pen.Color := ColorToRGB(MD3Colors.OutlineVariant);
    Canvas.Pen.Width := 1;
    Canvas.MoveTo(ARect.Left,  ARect.Bottom - 1);
    Canvas.LineTo(ARect.Right, ARect.Bottom - 1);
  end;

  { ── Cor do texto ── }
  if isHeader then
  begin
    fg := ColorToRGB(MD3Colors.OnSurface);
    Canvas.Font.Style := [fsBold];
    Canvas.Font.Size  := 12;
  end
  else if isSelected then
  begin
    fg := ColorToRGB(MD3Colors.OnSecondaryContainer);
    Canvas.Font.Style := [];
    Canvas.Font.Size  := 13;
  end
  else
  begin
    fg := ColorToRGB(MD3Colors.OnSurface);
    Canvas.Font.Style := [];
    Canvas.Font.Size  := 13;
  end;

  { ── Texto da célula ── }
  txt := Cells[ACol, ARow];

  { ── Seta de ordenação no cabeçalho ── }
  if isHeader and (ACol = FSortCol) then
  begin
    case FSortDir of
      sdAscending:  sortArrow := ' ↑';
      sdDescending: sortArrow := ' ↓';
    else
      sortArrow := '';
    end;
    txt := txt + sortArrow;
  end;

  Canvas.Font.Color := fg;
  Canvas.Brush.Style := bsClear;

  { Padding horizontal de 16px (MD3 spec) }
  ARect.Left   := ARect.Left  + 16;
  ARect.Right  := ARect.Right - 4;
  ARect.Top    := ARect.Top   + 4;
  ARect.Bottom := ARect.Bottom - 4;
  Canvas.TextRect(ARect, ARect.Left, ARect.Top + (ARect.Height - Canvas.TextHeight('A')) div 2, txt);

  Canvas.Brush.Style := bsSolid;
  Canvas.Font.Style  := [];
  Canvas.Font.Size   := 13;
end;

procedure TFRMaterialDataGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  ACol2, ARow2: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  MouseToCell(X, Y, ACol2, ARow2);
  if ARow2 <> FHoveredRow then
  begin
    FHoveredRow := ARow2;
    Invalidate;
  end;
end;

procedure TFRMaterialDataGrid.MouseLeave;
begin
  inherited MouseLeave;
  FHoveredRow := -1;
  Invalidate;
end;

procedure TFRMaterialDataGrid.HeaderClick(IsColumn: Boolean; Index: Integer);
begin
  inherited HeaderClick(IsColumn, Index);
  if not IsColumn then Exit;

  { Alterna direção de ordenação }
  if FSortCol = Index then
  begin
    case FSortDir of
      sdNone:       FSortDir := sdAscending;
      sdAscending:  FSortDir := sdDescending;
      sdDescending: FSortDir := sdNone;
    end;
  end
  else
  begin
    FSortCol := Index;
    FSortDir := sdAscending;
  end;

  { Chama handler customizado se definido }
  if Assigned(FOnSortColumn) then
    FOnSortColumn(Self, FSortCol, FSortDir);

  Invalidate;
end;

procedure TFRMaterialDataGrid.SortByColumn(ACol: Integer; AAscending: Boolean);
begin
  FSortCol := ACol;
  FSortDir := sdAscending;
  if not AAscending then FSortDir := sdDescending;

  if Assigned(FOnSortColumn) then
    FOnSortColumn(Self, FSortCol, FSortDir);

  Invalidate;
end;

type
  TAccessCustomEdit = class(TCustomEdit);

procedure TFRMaterialDataGrid.SelectEditor;
begin
  inherited SelectEditor;
  if Editor is TCustomEdit then
  begin
    TCustomEdit(Editor).BorderStyle := bsNone;
    TCustomEdit(Editor).Color := ColorToRGB(MD3Colors.SecondaryContainer);
    TCustomEdit(Editor).Font.Color := ColorToRGB(MD3Colors.OnSecondaryContainer);
    TCustomEdit(Editor).Font.Size := 13;
    { Desabilita a seleção automática total que pinta o fundo de azul nas configurações nativas do SO }
    TAccessCustomEdit(Editor).AutoSelect := False;
  end;
end;



{ ── TFRMaterialCellEditor ── }

procedure TFRMaterialCellEditor.DoEnter;
begin
  inherited DoEnter;
  SelLength := 0; { Removemos a seleção incômoda nativa }
end;

procedure TFRMaterialCellEditor.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  { Imita as margens exatas do Canvas (Left=16px) e centraliza verticalmente }
  if (AWidth > 20) and (AHeight > 10) then
  begin
    Inc(ALeft, 14);
    Dec(AWidth, 18);
    Inc(ATop, (AHeight - 20) div 2); 
    AHeight := 20; 
  end;
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
end;

procedure Register;
begin
  RegisterComponents('Material Design 3', [TFRMaterialDataGrid]);
end;

end.

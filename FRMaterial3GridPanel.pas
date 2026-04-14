unit FRMaterial3GridPanel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LMessages,
  FRMaterialTheme, FRMaterial3Base;

{.$DEFINE GRIDPANEL_FILELOG}

procedure GridLog(const S: string);

type

  TFRMaterialGridPanel = class;

  { ── TFRGridItem ──
    Each child control inside the grid panel has a corresponding
    TFRGridItem in the Items collection. When you drop a control
    into the panel in the IDE, an item is auto-created.
    Set ColSpan in the Object Inspector. }

  TFRGridItem = class(TCollectionItem)
  private
    FControl: TControl;
    FColSpan: Integer;
    procedure SetControl(AValue: TControl);
    procedure SetColSpan(AValue: Integer);
    function GetGrid: TFRMaterialGridPanel;
  protected
    function GetDisplayName: string; override;
  published
    property Control: TControl read FControl write SetControl;
    property ColSpan: Integer read FColSpan write SetColSpan default 12;
  end;

  { ── TFRGridItems ── }

  TFRGridItems = class(TOwnedCollection)
  private
    function GetGrid: TFRMaterialGridPanel;
    function GetItem(AIndex: Integer): TFRGridItem;
    procedure SetItem(AIndex: Integer; AValue: TFRGridItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    function Add: TFRGridItem;
    function FindByControl(AControl: TControl): TFRGridItem;
    property Items[AIndex: Integer]: TFRGridItem read GetItem write SetItem; default;
  end;

  { TFRMaterialGridPanel
    ─────────────────────────────────────────────────────
    Auto-flow grid layout with 12-column system (MD3).
    Drop child controls inside and set their ColSpan
    via the Items collection in the Object Inspector.
  }

  TFRMaterialGridPanel = class(TCustomControl, IFRMaterialComponent)
  private
    FColumnCount: Integer;
    FGapH: Integer;
    FGapV: Integer;
    FItems: TFRGridItems;
    FUpdating: Boolean;
    FAutoColSpan: Boolean;
    FAutoHeight: Boolean;
    FFlexItemWidth: Integer;
    FPaddingLeft: Integer;
    FPaddingTop: Integer;
    FPaddingRight: Integer;
    FPaddingBottom: Integer;

    procedure SetColumnCount(AValue: Integer);
    procedure SetGapH(AValue: Integer);
    procedure SetGapV(AValue: Integer);
    procedure SetItems(AValue: TFRGridItems);
    procedure SetAutoColSpan(AValue: Boolean);
    procedure SetAutoHeight(AValue: Boolean);
    procedure SetFlexItemWidth(AValue: Integer);
    procedure SetPaddingLeft(AValue: Integer);
    procedure SetPaddingTop(AValue: Integer);
    procedure SetPaddingRight(AValue: Integer);
    procedure SetPaddingBottom(AValue: Integer);
    function  ResolveSpan(AControl: TControl): Integer;

  protected
    procedure AdjustClientRect(var ARect: TRect); override;
    procedure AlignControls(AControl: TControl; var ARect: TRect); override;
    procedure Resize; override;
    procedure Paint; override;
    procedure CMControlChange(var Msg: TLMessage); message CM_CONTROLCHANGE;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Forca o layout independente de HandleAllocated. Use quando
      precisar posicionar filhos durante a construcao do form
      (antes do handle existir). }
    procedure DoLayout;

    procedure SetColSpan(AControl: TControl; ASpan: Integer);
    function  GetColSpan(AControl: TControl): Integer;
    procedure ApplyTheme(const AThemeManager: TObject); virtual;

  published
    property ColumnCount: Integer read FColumnCount write SetColumnCount default 12;
    { GapH / GapV — defaults com respiro suficiente para variantes sem borda
      (Standard/Filled) sob densidades compactas. Reduza explicitamente no
      LFM se quiser um layout mais denso. }
    property GapH: Integer read FGapH write SetGapH default 24;
    property GapV: Integer read FGapV write SetGapV default 16;
    { Quando True, o ColSpan de cada filho eh resolvido automaticamente a partir
      da property FieldSize do TFRMaterial3Control (fsTiny=2, fsSmall=3,
      fsMedium=4, fsLarge=6, fsHuge=8, fsFull=12). Filhos com FieldSize=fsAuto
      ou que nao sao TFRMaterial3Control caem no fallback fsLarge (6 cols).
      Quando False (default), usa o ColSpan manual definido em Items. }
    property AutoColSpan: Boolean read FAutoColSpan write SetAutoColSpan default False;
    { Quando True, o Height do grid eh recalculado automaticamente apos
      o layout, de modo que todos os filhos fiquem visiveis sem corte.
      Compativel com densidades e temas dinamicos — o grid redimensiona
      conforme os filhos mudam de altura. }
    property AutoHeight: Boolean read FAutoHeight write SetAutoHeight default True;
    { Flex-wrap mode: quando > 0, ignora ColumnCount/ColSpan e posiciona
      cada filho com largura fixa de FlexItemWidth pixels. O numero de
      colunas eh calculado automaticamente a partir da largura disponivel:
        cols = (Width + GapH) div (FlexItemWidth + GapH)
      Itens que nao cabem na linha atual sao empurrados para a proxima.
      Ideal para grids de cards de tamanho uniforme.
      Quando 0 (default), usa o layout por colunas+ColSpan normal. }
    property FlexItemWidth: Integer read FFlexItemWidth write SetFlexItemWidth default 0;
    { Padding interno — espaçamento entre as bordas do grid e os filhos.
      Funciona como TPanel.BorderWidth mas com controle individual por lado. }
    property PaddingLeft: Integer read FPaddingLeft write SetPaddingLeft default 8;
    property PaddingTop: Integer read FPaddingTop write SetPaddingTop default 8;
    property PaddingRight: Integer read FPaddingRight write SetPaddingRight default 8;
    property PaddingBottom: Integer read FPaddingBottom write SetPaddingBottom default 8;
    property Items: TFRGridItems read FItems write SetItems;

    property Align;
    property Anchors;
    property BorderSpacing;
    property Color;
    property Enabled;
    property Visible;
    property OnResize;
  end;

procedure Register;

implementation

var
  GridLogFile: TextFile;
  GridLogOpen: Boolean = False;

{ ── File Logging ── }

procedure GridLog(const S: string);
begin
  {$IFDEF GRIDPANEL_FILELOG}
  if not GridLogOpen then
  begin
    AssignFile(GridLogFile, ExtractFilePath(ParamStr(0)) + 'gridpanel.log');
    Rewrite(GridLogFile);
    GridLogOpen := True;
  end;
  WriteLn(GridLogFile, S);
  Flush(GridLogFile);
  {$ENDIF}
end;

{ ── Registration ── }

procedure Register;
begin
  RegisterComponents('Material Design 3', [TFRMaterialGridPanel]);
end;

{ ════════════════════════════════════════════════════════
  TFRGridItem
  ════════════════════════════════════════════════════════ }

function TFRGridItem.GetGrid: TFRMaterialGridPanel;
begin
  if (Collection <> nil) and (Collection is TFRGridItems) then
    Result := TFRGridItems(Collection).GetGrid
  else
    Result := nil;
end;

function TFRGridItem.GetDisplayName: string;
begin
  if (FControl <> nil) and (FControl.Name <> '') then
    Result := FControl.Name + ' [' + IntToStr(FColSpan) + ']'
  else
    Result := '(empty) [' + IntToStr(FColSpan) + ']';
end;

procedure TFRGridItem.SetControl(AValue: TControl);
begin
  if FControl = AValue then Exit;
  FControl := AValue;
  Changed(False);
end;

procedure TFRGridItem.SetColSpan(AValue: Integer);
var
  grid: TFRMaterialGridPanel;
begin
  if AValue < 1 then AValue := 1;
  grid := GetGrid;
  if (grid <> nil) and (AValue > grid.ColumnCount) then
    AValue := grid.ColumnCount;
  if FColSpan = AValue then Exit;
  FColSpan := AValue;
  Changed(False);
end;

{ ════════════════════════════════════════════════════════
  TFRGridItems
  ════════════════════════════════════════════════════════ }

function TFRGridItems.GetGrid: TFRMaterialGridPanel;
begin
  if Owner is TFRMaterialGridPanel then
    Result := TFRMaterialGridPanel(Owner)
  else
    Result := nil;
end;

function TFRGridItems.GetItem(AIndex: Integer): TFRGridItem;
begin
  Result := TFRGridItem(inherited Items[AIndex]);
end;

procedure TFRGridItems.SetItem(AIndex: Integer; AValue: TFRGridItem);
begin
  inherited Items[AIndex] := AValue;
end;

function TFRGridItems.Add: TFRGridItem;
begin
  Result := TFRGridItem(inherited Add);
  Result.FColSpan := 12;
end;

function TFRGridItems.FindByControl(AControl: TControl): TFRGridItem;
var
  i: Integer;
begin
  if AControl = nil then Exit(nil);
  for i := 0 to Count - 1 do
    if Items[i].Control = AControl then
      Exit(Items[i]);
  Result := nil;
end;

procedure TFRGridItems.Update(Item: TCollectionItem);
var
  grid: TFRMaterialGridPanel;
begin
  inherited;
  grid := GetGrid;
  if (grid <> nil) and (not grid.FUpdating) then
    grid.DoLayout;
end;

{ ════════════════════════════════════════════════════════
  TFRMaterialGridPanel
  ════════════════════════════════════════════════════════ }

constructor TFRMaterialGridPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRMDRegisterComponent(Self);

  ControlStyle := ControlStyle + [csAcceptsControls];

  FColumnCount := 12;
  FGapH := 24;
  FGapV := 16;
  FUpdating := False;
  FAutoColSpan := False;
  FAutoHeight  := True;
  FFlexItemWidth := 0;
  FPaddingLeft   := 8;
  FPaddingTop    := 8;
  FPaddingRight  := 8;
  FPaddingBottom := 8;
  FItems := TFRGridItems.Create(Self, TFRGridItem);

  Width  := 600;
  Height := 200;
end;

destructor TFRMaterialGridPanel.Destroy;
begin
  FRMDUnregisterComponent(Self);
  FreeAndNil(FItems);
  inherited Destroy;
end;

{ ── Property setters ── }

procedure TFRMaterialGridPanel.SetColumnCount(AValue: Integer);
begin
  if AValue < 1  then AValue := 1;
  if AValue > 24 then AValue := 24;
  if FColumnCount = AValue then Exit;
  FColumnCount := AValue;
  DoLayout;
end;

procedure TFRMaterialGridPanel.SetGapH(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if FGapH = AValue then Exit;
  FGapH := AValue;
  DoLayout;
end;

procedure TFRMaterialGridPanel.SetGapV(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if FGapV = AValue then Exit;
  FGapV := AValue;
  DoLayout;
end;

procedure TFRMaterialGridPanel.SetItems(AValue: TFRGridItems);
begin
  FItems.Assign(AValue);
end;

procedure TFRMaterialGridPanel.SetAutoColSpan(AValue: Boolean);
begin
  if FAutoColSpan = AValue then Exit;
  FAutoColSpan := AValue;
  DoLayout;
end;

procedure TFRMaterialGridPanel.SetAutoHeight(AValue: Boolean);
begin
  if FAutoHeight = AValue then Exit;
  FAutoHeight := AValue;
  DoLayout;
end;

procedure TFRMaterialGridPanel.SetFlexItemWidth(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if FFlexItemWidth = AValue then Exit;
  FFlexItemWidth := AValue;
  DoLayout;
end;

procedure TFRMaterialGridPanel.SetPaddingLeft(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if FPaddingLeft = AValue then Exit;
  FPaddingLeft := AValue;
  DoLayout;
end;

procedure TFRMaterialGridPanel.SetPaddingTop(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if FPaddingTop = AValue then Exit;
  FPaddingTop := AValue;
  DoLayout;
end;

procedure TFRMaterialGridPanel.SetPaddingRight(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if FPaddingRight = AValue then Exit;
  FPaddingRight := AValue;
  DoLayout;
end;

procedure TFRMaterialGridPanel.SetPaddingBottom(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if FPaddingBottom = AValue then Exit;
  FPaddingBottom := AValue;
  DoLayout;
end;

procedure TFRMaterialGridPanel.AdjustClientRect(var ARect: TRect);
begin
  inherited AdjustClientRect(ARect);
  Inc(ARect.Left, FPaddingLeft);
  Inc(ARect.Top, FPaddingTop);
  Dec(ARect.Right, FPaddingRight);
  Dec(ARect.Bottom, FPaddingBottom);
end;

{ Resolve o ColSpan efetivo de um controle.
  - AutoColSpan=False → usa o ColSpan manual do Items (default 12).
  - AutoColSpan=True:
      * TFRMaterial3Control com FieldSize<>fsAuto → mapeia por FieldSize.
      * TFRMaterial3Control com fsAuto → fallback fsLarge (6 cols).
      * Filho nao-MD3 (TPanel, TLabel...) → respeita ColSpan manual
        do Items, permitindo uso misto de auto + manual no mesmo grid. }
function TFRMaterialGridPanel.ResolveSpan(AControl: TControl): Integer;
var
  size: TFRFieldSize;
begin
  if not FAutoColSpan then
  begin
    Result := GetColSpan(AControl);
    Exit;
  end;

  if not (AControl is TFRMaterial3Control) then
  begin
    Result := GetColSpan(AControl);
    if Result > FColumnCount then Result := FColumnCount;
    Exit;
  end;

  size := TFRMaterial3Control(AControl).FieldSize;

  case size of
    fsTiny:   Result := 2;
    fsSmall:  Result := 3;
    fsMedium: Result := 4;
    fsLarge:  Result := 6;
    fsHuge:   Result := 8;
    fsFull:   Result := 12;
  else
    { fsAuto — fallback: metade da linha (6 cols). }
    Result := 6;
  end;

  if Result > FColumnCount then
    Result := FColumnCount;
end;

{ ── Public ColSpan helpers (code usage) ── }

procedure TFRMaterialGridPanel.SetColSpan(AControl: TControl; ASpan: Integer);
var
  item: TFRGridItem;
  colW: Double;
  cw: Integer;
begin
  if AControl = nil then Exit;
  item := FItems.FindByControl(AControl);
  if item = nil then
  begin
    item := FItems.Add;
    item.FControl := AControl;
  end;
  item.ColSpan := ASpan;

  { Aplica a largura imediatamente para que filhos internos do controle
    (labels, botoes, etc.) possam usar Width correto ao serem criados,
    sem depender de DoLayout posterior. }
  if (Width > 0) and (FColumnCount > 0) then
  begin
    colW := (Width - (FColumnCount - 1) * FGapH) / FColumnCount;
    if colW < 1 then colW := 1;
    cw := Round(ASpan * colW + (ASpan - 1) * FGapH);
    AControl.Width := cw;
  end;
end;

function TFRMaterialGridPanel.GetColSpan(AControl: TControl): Integer;
var
  item: TFRGridItem;
begin
  item := FItems.FindByControl(AControl);
  if item <> nil then
    Result := item.ColSpan
  else
    Result := FColumnCount;
end;

{ ── Auto-manage items when controls are added/removed ── }

procedure TFRMaterialGridPanel.CMControlChange(var Msg: TLMessage);
var
  ctrl: TControl;
  item: TFRGridItem;
begin
  if (Msg.WParam = 0) or (FItems = nil) then Exit;

  ctrl := TControl(Msg.WParam);
  if Boolean(Msg.LParam) then
  begin
    { Control inserted → auto-create item if not exists }
    if FItems.FindByControl(ctrl) = nil then
    begin
      item := FItems.Add;
      item.FControl := ctrl;
    end;
    { Force child layout props — we manage ALL positioning.
      Must happen here, NOT inside AlignControls, otherwise
      setting Anchors triggers cascade re-layout via LCL. }
    if ctrl.Align <> alNone then
      ctrl.Align := alNone;
    if ctrl.Anchors <> [akLeft, akTop] then
      ctrl.Anchors := [akLeft, akTop];
  end
  else
  begin
    { Control removed → remove item }
    item := FItems.FindByControl(ctrl);
    if item <> nil then
    begin
      FUpdating := True;
      try
        item.Free;
      finally
        FUpdating := False;
      end;
    end;
  end;
end;

procedure TFRMaterialGridPanel.Notification(AComponent: TComponent; Operation: TOperation);
var
  item: TFRGridItem;
begin
  inherited;
  if (Operation = opRemove) and (AComponent is TControl) and (FItems <> nil) then
  begin
    item := FItems.FindByControl(TControl(AComponent));
    if item <> nil then
      item.FControl := nil;
  end;
end;

{ ── Layout engine ── }

procedure TFRMaterialGridPanel.DoLayout;
var
  R: TRect;
begin
  if csDestroying in ComponentState then Exit;
  if FUpdating then Exit;
  if (Width <= 0) or (ControlCount = 0) then Exit;
  GridLog('DoLayout Width=' + IntToStr(Width) + ' CC=' + IntToStr(ControlCount));
  R := Rect(0, 0, Width, Height);
  AlignControls(nil, R);
end;

procedure TFRMaterialGridPanel.Resize;
begin
  inherited Resize;
  GridLog('Resize Width=' + IntToStr(Width) + ' Height=' + IntToStr(Height));
  DoLayout;
end;

procedure TFRMaterialGridPanel.AlignControls(AControl: TControl; var ARect: TRect);
var
  i, col, span: Integer;
  areaW: Integer;
  colW: Double;
  ctrl: TControl;
  cx, cy, cw: Integer;
  rowMaxH: Integer;
  totalH: Integer;
  flexCols: Integer;
begin
  if ControlCount = 0 then Exit;
  if FUpdating then Exit;

  areaW := ARect.Right - ARect.Left;
  if areaW <= 0 then Exit;

  FUpdating := True;
  try

  { ── Flex-wrap mode ──
    Cada filho recebe largura fixa de FlexItemWidth pixels.
    O numero de colunas eh calculado a partir da area disponivel:
      cols = (areaW + GapH) / (FlexItemWidth + GapH)
    Funciona como CSS flex-wrap: wrap com itens de tamanho uniforme. }
  if FFlexItemWidth > 0 then
  begin
    flexCols := (areaW + FGapH) div (FFlexItemWidth + FGapH);
    if flexCols < 1 then flexCols := 1;

    col := 0;
    cy := ARect.Top;
    rowMaxH := 0;

    for i := 0 to ControlCount - 1 do
    begin
      ctrl := Controls[i];
      if not ctrl.Visible then Continue;

      { Wrap }
      if (col > 0) and (col >= flexCols) then
      begin
        cy := cy + rowMaxH + FGapV;
        col := 0;
        rowMaxH := 0;
      end;

      cx := ARect.Left + col * (FFlexItemWidth + FGapH);
      ctrl.SetBounds(cx, cy, FFlexItemWidth, ctrl.Height);

      if ctrl.Height > rowMaxH then
        rowMaxH := ctrl.Height;
      Inc(col);
    end;
  end
  else
  begin
    { ── Column-based mode (padrao) ── }
    colW := (areaW - (FColumnCount - 1) * FGapH) / FColumnCount;
    if colW < 1 then colW := 1;

    col := 0;
    cy := ARect.Top;
    rowMaxH := 0;

    for i := 0 to ControlCount - 1 do
    begin
      ctrl := Controls[i];
      if not ctrl.Visible then Continue;

      span := ResolveSpan(ctrl);
      if span > FColumnCount then span := FColumnCount;

      { Wrap to next row if this child won't fit }
      if (col > 0) and (col + span > FColumnCount) then
      begin
        cy := cy + rowMaxH + FGapV;
        col := 0;
        rowMaxH := 0;
      end;

      cx := ARect.Left + Round(col * (colW + FGapH));
      cw := Round(span * colW + (span - 1) * FGapH);

      ctrl.SetBounds(cx, cy, cw, ctrl.Height);

      if ctrl.Height > rowMaxH then
        rowMaxH := ctrl.Height;

      col := col + span;

      { Row full → advance }
      if col >= FColumnCount then
      begin
        cy := cy + rowMaxH + FGapV;
        col := 0;
        rowMaxH := 0;
      end;
    end;
  end;

  { AutoHeight: ajusta o Height do grid para acomodar todos os filhos.

    DisableAutoSizing em Self E em Parent protege contra loop
    InvalidatePreferredSize: setar Self.Height dispara Resize no parent →
    parent recalcula layout → pode redimensionar este grid → DoLayout
    dispara de novo → LOOP. Com varios GridPanels alTop empilhados, o
    LCL detecta e aborta com ELayoutException.

    A defesa precisa cobrir AMBOS os lados (Self e Parent) porque o loop
    eh BIDIRECIONAL — protegendo so Self, o parent ainda pode reagir e
    re-disparar. Com ambos protegidos, o ciclo eh quebrado no nivel do LCL. }
  if FAutoHeight then
  begin
    if (col > 0) and (rowMaxH > 0) then
      totalH := cy + rowMaxH
    else if cy > ARect.Top then
      totalH := cy - FGapV
    else
      totalH := 0;
    if Self.Height <> totalH then
    begin
      Self.DisableAutoSizing;
      if Assigned(Parent) then Parent.DisableAutoSizing;
      try
        Self.Height := totalH;
      finally
        if Assigned(Parent) then Parent.EnableAutoSizing;
        Self.EnableAutoSizing;
      end;
    end;
  end;

  finally
    FUpdating := False;
  end;
end;

{ ── Design-time paint (grid guides) ── }

procedure TFRMaterialGridPanel.Paint;
var
  colW: Double;
  i, x: Integer;
  r: TRect;
begin
  if csDesigning in ComponentState then
  begin
    r := ClientRect;
    Canvas.Pen.Color := clSilver;
    Canvas.Pen.Style := psDot;
    Canvas.Brush.Style := bsClear;

    colW := (r.Right - r.Left - (FColumnCount - 1) * FGapH) / FColumnCount;

    for i := 0 to FColumnCount - 1 do
    begin
      x := r.Left + Round(i * (colW + FGapH));
      Canvas.Rectangle(x, r.Top, Round(x + colW), r.Bottom);
    end;
  end;
end;

{ ── Theme ── }

procedure TFRMaterialGridPanel.ApplyTheme(const AThemeManager: TObject);
begin
  if not Assigned(AThemeManager) then Exit;
  Invalidate;
end;

end.

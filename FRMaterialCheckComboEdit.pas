unit FRMaterialCheckComboEdit;

{$mode objfpc}{$H+}

{ TFRMaterialCheckComboEdit
  Multi-select com checkboxes no estilo Material Design.
  Equivalente ao <select multiple> / Material Multi-Select da web.

  Funcionamento:
    - Campo somente-leitura exibe o resumo da seleção
    - Botão "▾" abre painel flutuante com TCheckListBox
    - Fechar clicando fora ou pressionando Escape / Enter
    - Propriedade DisplayFormat controla o texto exibido no campo

  Licença: LGPL v3 — mesma do bgracontrols
}

interface

uses
  FRMaterial3Base, FRMaterialTheme, FRMaterialFieldPainter, Classes, Controls, ExtCtrls, Forms, Graphics, Math,
  {$IFDEF FPC} LCLType, LResources, {$ENDIF}
  Menus, StdCtrls, CheckLst, SysUtils;

type
  { Como o campo exibe os itens selecionados }
  TCheckComboDisplayFormat = (
    cdfCommaSeparated,  { "Item1, Item2, Item3"              }
    cdfCountOnly,       { "3 selecionado(s)"                 }
    cdfCountAndFirst    { "Item1 (+2)"                       }
  );

  { Evento disparado quando qualquer checkbox muda de estado }
  TCheckItemChangeEvent = procedure(Sender: TObject; AIndex: Integer;
    AChecked: Boolean) of object;

  { Painel flutuante interno — não publicado }
  TCheckComboDropDown = class;

  { TFRMaterialCheckComboEdit }

  TFRMaterialCheckComboEdit = class(TFRMaterialCustomControl)
  private
    FLabel: TBoundLabel;
    FDisplayEdit: TEdit;
    FDropButton: TButton;
    FDropDown: TCheckComboDropDown;
    FFocused: Boolean;
    FVariant: TFRMaterialVariant;
    FBorderRadius: Integer;
    FItems: TStrings;
    FDisplayFormat: TCheckComboDisplayFormat;
    FEmptyText: string;
    FDropDownCount: Integer;
    FOnCheckChange: TCheckItemChangeEvent;
    FOnDropDownOpen: TNotifyEvent;
    FOnDropDownClose: TNotifyEvent;

    function IsNeededAdjustSize: Boolean;
    procedure DropButtonClick(Sender: TObject);
    procedure CloseDropDown;
    procedure DropDownDeactivate(Sender: TObject);
    procedure InternalCheckChange(AIndex: Integer; AChecked: Boolean);
    procedure ItemsChange(Sender: TObject);
    procedure UpdateDisplayText;

    function GetChecked(AIndex: Integer): Boolean;
    procedure SetChecked(AIndex: Integer; AValue: Boolean);
    function GetCheckedCount: Integer;
    function GetItems: TStrings;
    procedure SetItems(AValue: TStrings);
    function GetDisplayFormat: TCheckComboDisplayFormat;
    procedure SetDisplayFormat(AValue: TCheckComboDisplayFormat);
    function GetEmptyText: string;
    procedure SetEmptyText(const AValue: string);
    function GetDropDownCount: Integer;
    procedure SetDropDownCount(AValue: Integer);
    function GetSorted: Boolean;
    procedure SetSorted(AValue: Boolean);
    function GetLabelCaption: TCaption;
    procedure SetLabelCaption(const AValue: TCaption);
    function GetLabelSpacing: Integer;
    procedure SetLabelSpacing(AValue: Integer);
    function GetEditCursor: TCursor;
    procedure SetEditCursor(AValue: TCursor);
    function GetEditTabStop: Boolean;
    procedure SetEditTabStop(AValue: Boolean);

  protected
    procedure SetAnchors(const AValue: TAnchors); override;
    procedure SetColor(AValue: TColor); override;
    procedure SetName(const AValue: TComponentName); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DoOnResize; override;
    procedure Paint; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Marca/desmarca todos os itens }
    procedure CheckAll(AChecked: Boolean);
    { Inverte o estado de todos os itens }
    procedure InvertAll;
    { Retorna TStringList com os textos dos itens marcados (caller libera) }
    function GetCheckedItems: TStringList;
    { Retorna TStringList com os índices (como string) dos itens marcados (caller libera) }
    function GetCheckedIndices: TStringList;
    { Abre/fecha o painel de seleção por código }
    procedure OpenDropDown;
    { Está com o painel aberto? }
    function IsDropDownOpen: Boolean;

    { Acesso individual a cada checkbox pelo índice }
    property Checked[AIndex: Integer]: Boolean read GetChecked write SetChecked;
    { Quantidade de itens marcados }
    property CheckedCount: Integer read GetCheckedCount;
    { Acesso ao TEdit que exibe o resumo (para customização visual) }
    property DisplayEdit: TEdit read FDisplayEdit;
    { Acesso ao botão de abrir dropdown (para customização visual) }
    property DropButton: TButton read FDropButton;

  published
    property Align;
    property Constraints;
    property Cursor: TCursor read GetEditCursor write SetEditCursor default crDefault;
    property Variant: TFRMaterialVariant read FVariant write FVariant default mvStandard;
    { Raio dos cantos arredondados em pixels; 0 = cantos retos }
    property BorderRadius: Integer read FBorderRadius write FBorderRadius default 0;
    { Como o campo exibe os itens selecionados }
    property DisplayFormat: TCheckComboDisplayFormat
      read GetDisplayFormat write SetDisplayFormat default cdfCommaSeparated;
    { Número de linhas visíveis no painel suspenso }
    property DropDownCount: Integer
      read GetDropDownCount write SetDropDownCount default 8;
    { Label flutuante acima do campo }
    property EditLabel: TBoundLabel read FLabel;
    property Enabled;
    { Texto exibido quando nenhum item está selecionado }
    property EmptyText: string read GetEmptyText write SetEmptyText;
    property Font;
    property Hint;
    { Lista de opções (strings) }
    property Items: TStrings read GetItems write SetItems;
    property LabelSpacing: Integer read GetLabelSpacing write SetLabelSpacing default 4;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont default False;
    property ShowHint;
    { Ordena a lista de itens }
    property Sorted: Boolean read GetSorted write SetSorted default False;
    property TabOrder;
    property TabStop: Boolean read GetEditTabStop write SetEditTabStop default True;
    property Visible;

    { Disparado quando qualquer checkbox muda de estado }
    property OnCheckChange: TCheckItemChangeEvent
      read FOnCheckChange write FOnCheckChange;
    property OnChangeBounds;
    { Disparado ao abrir o painel de seleção }
    property OnDropDownOpen: TNotifyEvent
      read FOnDropDownOpen write FOnDropDownOpen;
    { Disparado ao fechar o painel de seleção }
    property OnDropDownClose: TNotifyEvent
      read FOnDropDownClose write FOnDropDownClose;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    
  protected
    FLabelAnimator: TFRMDFloatingLabelAnimator;
  end;

  { TCheckComboDropDown — Form flutuante com a lista de checkboxes }

  TCheckComboDropDown = class(TCustomForm)
  private
    FCheckList: TCheckListBox;
    FOwnerCombo: TFRMaterialCheckComboEdit;
    procedure CheckListItemClick(Sender: TObject);
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Deactivate; override;
  public
    constructor CreateForCombo(AOwner: TFRMaterialCheckComboEdit);
    procedure SyncItems;
    procedure SyncChecks;
    property CheckList: TCheckListBox read FCheckList;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialcheckcomboedit_icon.lrs}
  {$ENDIF}
  RegisterComponents('BGRA Controls', [TFRMaterialCheckComboEdit]);
end;

{ TCheckComboDropDown }

constructor TCheckComboDropDown.CreateForCombo(AOwner: TFRMaterialCheckComboEdit);
begin
  inherited CreateNew(AOwner);
  FOwnerCombo := AOwner;

  BorderStyle := bsNone;
  FormStyle   := fsStayOnTop;
  ShowInTaskBar := stNever;

  FCheckList := TCheckListBox.Create(Self);
  FCheckList.Align        := alClient;
  FCheckList.BorderStyle  := bsNone;
  FCheckList.Parent       := Self;
  FCheckList.OnClickCheck := @CheckListItemClick;
end;

procedure TCheckComboDropDown.CheckListItemClick(Sender: TObject);
var
  AIndex: Integer;
begin
  AIndex := FCheckList.ItemIndex;
  if AIndex < 0 then Exit;
  FOwnerCombo.InternalCheckChange(AIndex, FCheckList.Checked[AIndex]);
end;

procedure TCheckComboDropDown.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Key in [VK_ESCAPE, VK_RETURN] then
    FOwnerCombo.CloseDropDown;
end;

procedure TCheckComboDropDown.Deactivate;
begin
  inherited Deactivate;
  { Fecha ao perder o foco, mas apenas quando o foco não voltou para o combo }
  if Assigned(FOwnerCombo) and FOwnerCombo.IsDropDownOpen then
    FOwnerCombo.CloseDropDown;
end;

procedure TCheckComboDropDown.SyncItems;
var
  i: Integer;
  SaveChecks: array of Boolean;
begin
  { Preserva o estado de check atual }
  SetLength(SaveChecks, FCheckList.Items.Count);
  for i := 0 to FCheckList.Items.Count - 1 do
    SaveChecks[i] := FCheckList.Checked[i];

  FCheckList.Items.BeginUpdate;
  try
    FCheckList.Items.Assign(FOwnerCombo.Items);
  finally
    FCheckList.Items.EndUpdate;
  end;

  { Restaura checks para itens que ainda existem }
  for i := 0 to Min(FCheckList.Items.Count, Length(SaveChecks)) - 1 do
    FCheckList.Checked[i] := SaveChecks[i];
end;

procedure TCheckComboDropDown.SyncChecks;
var
  i: Integer;
begin
  for i := 0 to FCheckList.Items.Count - 1 do
    FCheckList.Checked[i] := FOwnerCombo.Checked[i];
end;

{ TFRMaterialCheckComboEdit }

function TFRMaterialCheckComboEdit.IsNeededAdjustSize: Boolean;
begin
  if Self.Align in [alLeft, alRight, alClient] then Exit(False);
  if (akTop in Self.Anchors) and (akBottom in Self.Anchors) then Exit(False);
  Result := True;
end;

procedure TFRMaterialCheckComboEdit.DropButtonClick(Sender: TObject);
begin
  if IsDropDownOpen then
    CloseDropDown
  else
    OpenDropDown;
end;

procedure TFRMaterialCheckComboEdit.CloseDropDown;
begin
  if not Assigned(FDropDown) then Exit;
  FDropDown.Hide;
  if Assigned(FOnDropDownClose) then
    FOnDropDownClose(Self);
end;

procedure TFRMaterialCheckComboEdit.DropDownDeactivate(Sender: TObject);
begin
  CloseDropDown;
end;

procedure TFRMaterialCheckComboEdit.InternalCheckChange(AIndex: Integer;
  AChecked: Boolean);
begin
  UpdateDisplayText;
  if Assigned(FOnCheckChange) then
    FOnCheckChange(Self, AIndex, AChecked);
  Invalidate;
end;

procedure TFRMaterialCheckComboEdit.ItemsChange(Sender: TObject);
begin
  if Assigned(FDropDown) then
    FDropDown.SyncItems;
  UpdateDisplayText;
end;

procedure TFRMaterialCheckComboEdit.UpdateDisplayText;
var
  i: Integer;
  CheckedItems: TStringList;
begin
  if not Assigned(FDropDown) then
  begin
    FDisplayEdit.Text := FEmptyText;
    Exit;
  end;

  CheckedItems := GetCheckedItems;
  try
    if CheckedItems.Count = 0 then
    begin
      FDisplayEdit.Text := FEmptyText;
      Exit;
    end;

    case FDisplayFormat of
      cdfCommaSeparated:
        FDisplayEdit.Text := CheckedItems.CommaText;

      cdfCountOnly:
        FDisplayEdit.Text := IntToStr(CheckedItems.Count) + ' selecionado(s)';

      cdfCountAndFirst:
        if CheckedItems.Count = 1 then
          FDisplayEdit.Text := CheckedItems[0]
        else
          FDisplayEdit.Text := CheckedItems[0] + ' (+' +
            IntToStr(CheckedItems.Count - 1) + ')';
    end;
  finally
    CheckedItems.Free;
  end;
  
  if Assigned(FLabelAnimator) then
  begin
    if ((Trim(FDisplayEdit.Text) <> '') and (FDisplayEdit.Text <> FEmptyText)) or FFocused or IsDropDownOpen then
      FLabelAnimator.FloatLabel
    else
      FLabelAnimator.InlineLabel;
  end;
end;

{ --- Checked[] e contagem --- }

function TFRMaterialCheckComboEdit.GetChecked(AIndex: Integer): Boolean;
begin
  if not Assigned(FDropDown) or
     (AIndex < 0) or (AIndex >= FDropDown.CheckList.Items.Count) then
    Exit(False);
  Result := FDropDown.CheckList.Checked[AIndex];
end;

procedure TFRMaterialCheckComboEdit.SetChecked(AIndex: Integer; AValue: Boolean);
begin
  if not Assigned(FDropDown) or
     (AIndex < 0) or (AIndex >= FDropDown.CheckList.Items.Count) then Exit;
  if FDropDown.CheckList.Checked[AIndex] = AValue then Exit;
  FDropDown.CheckList.Checked[AIndex] := AValue;
  InternalCheckChange(AIndex, AValue);
end;

function TFRMaterialCheckComboEdit.GetCheckedCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  if not Assigned(FDropDown) then Exit;
  for i := 0 to FDropDown.CheckList.Items.Count - 1 do
    if FDropDown.CheckList.Checked[i] then Inc(Result);
end;

{ --- Getters/Setters --- }

function TFRMaterialCheckComboEdit.GetItems: TStrings;
begin
  Result := FItems;
end;

procedure TFRMaterialCheckComboEdit.SetItems(AValue: TStrings);
begin
  FItems.Assign(AValue);
end;

function TFRMaterialCheckComboEdit.GetDisplayFormat: TCheckComboDisplayFormat;
begin
  Result := FDisplayFormat;
end;

procedure TFRMaterialCheckComboEdit.SetDisplayFormat(AValue: TCheckComboDisplayFormat);
begin
  if FDisplayFormat = AValue then Exit;
  FDisplayFormat := AValue;
  UpdateDisplayText;
end;

function TFRMaterialCheckComboEdit.GetEmptyText: string;
begin
  Result := FEmptyText;
end;

procedure TFRMaterialCheckComboEdit.SetEmptyText(const AValue: string);
begin
  if FEmptyText = AValue then Exit;
  FEmptyText := AValue;
  UpdateDisplayText;
end;

function TFRMaterialCheckComboEdit.GetDropDownCount: Integer;
begin
  Result := FDropDownCount;
end;

procedure TFRMaterialCheckComboEdit.SetDropDownCount(AValue: Integer);
begin
  if FDropDownCount = AValue then Exit;
  FDropDownCount := AValue;
end;

function TFRMaterialCheckComboEdit.GetSorted: Boolean;
begin
  if Assigned(FDropDown) then
    Result := FDropDown.CheckList.Sorted
  else
    Result := False;
end;

procedure TFRMaterialCheckComboEdit.SetSorted(AValue: Boolean);
begin
  if Assigned(FDropDown) then
    FDropDown.CheckList.Sorted := AValue;
end;

function TFRMaterialCheckComboEdit.GetLabelCaption: TCaption;
begin
  Result := FLabel.Caption;
end;

procedure TFRMaterialCheckComboEdit.SetLabelCaption(const AValue: TCaption);
begin
  FLabel.Caption := AValue;
end;

function TFRMaterialCheckComboEdit.GetLabelSpacing: Integer;
begin
  Result := FLabel.BorderSpacing.Bottom;
end;

procedure TFRMaterialCheckComboEdit.SetLabelSpacing(AValue: Integer);
begin
  if FLabel.BorderSpacing.Bottom = AValue then Exit;
  FLabel.BorderSpacing.Bottom := AValue;
  if not (csLoading in ComponentState) then Self.DoOnResize;
end;

function TFRMaterialCheckComboEdit.GetEditCursor: TCursor;
begin
  Result := FDisplayEdit.Cursor;
end;

procedure TFRMaterialCheckComboEdit.SetEditCursor(AValue: TCursor);
begin
  FDisplayEdit.Cursor := AValue;
end;

function TFRMaterialCheckComboEdit.GetEditTabStop: Boolean;
begin
  Result := FDisplayEdit.TabStop;
end;

procedure TFRMaterialCheckComboEdit.SetEditTabStop(AValue: Boolean);
begin
  FDisplayEdit.TabStop := AValue;
end;

{ --- Métodos públicos --- }

procedure TFRMaterialCheckComboEdit.CheckAll(AChecked: Boolean);
var
  i: Integer;
begin
  if not Assigned(FDropDown) then Exit;
  for i := 0 to FDropDown.CheckList.Items.Count - 1 do
    FDropDown.CheckList.Checked[i] := AChecked;
  UpdateDisplayText;
  Invalidate;
end;

procedure TFRMaterialCheckComboEdit.InvertAll;
var
  i: Integer;
begin
  if not Assigned(FDropDown) then Exit;
  for i := 0 to FDropDown.CheckList.Items.Count - 1 do
    FDropDown.CheckList.Checked[i] := not FDropDown.CheckList.Checked[i];
  UpdateDisplayText;
  Invalidate;
end;

function TFRMaterialCheckComboEdit.GetCheckedItems: TStringList;
var
  i: Integer;
begin
  Result := TStringList.Create;
  if not Assigned(FDropDown) then Exit;
  for i := 0 to FDropDown.CheckList.Items.Count - 1 do
    if FDropDown.CheckList.Checked[i] then
      Result.Add(FDropDown.CheckList.Items[i]);
end;

function TFRMaterialCheckComboEdit.GetCheckedIndices: TStringList;
var
  i: Integer;
begin
  Result := TStringList.Create;
  if not Assigned(FDropDown) then Exit;
  for i := 0 to FDropDown.CheckList.Items.Count - 1 do
    if FDropDown.CheckList.Checked[i] then
      Result.Add(IntToStr(i));
end;

procedure TFRMaterialCheckComboEdit.OpenDropDown;
var
  P: TPoint;
  ListHeight: Integer;
begin
  if not Assigned(FDropDown) then Exit;

  FDropDown.SyncItems;
  FDropDown.SyncChecks;

  { Dimensiona o painel }
  ListHeight := FDropDownCount *
    (FDropDown.CheckList.ItemHeight + 2);
  FDropDown.Width  := Self.Width;
  FDropDown.Height := ListHeight;

  { Posiciona abaixo do controle, na tela }
  P := Self.ClientToScreen(Point(0, Self.Height));
  FDropDown.Left := P.X;
  FDropDown.Top  := P.Y;

  { Garante que não ultrapasse a borda inferior da tela }
  if FDropDown.Top + FDropDown.Height > Screen.Height then
    FDropDown.Top := P.Y - Self.Height - FDropDown.Height;

  FDropDown.Show;
  FDropDown.FCheckList.SetFocus;

  if Assigned(FLabelAnimator) then FLabelAnimator.FloatLabel;

  if Assigned(FOnDropDownOpen) then
    FOnDropDownOpen(Self);
end;

function TFRMaterialCheckComboEdit.IsDropDownOpen: Boolean;
begin
  Result := Assigned(FDropDown) and FDropDown.Visible;
end;

{ --- Métodos protegidos --- }

procedure TFRMaterialCheckComboEdit.SetAnchors(const AValue: TAnchors);
begin
  if Self.Anchors = AValue then Exit;
  inherited SetAnchors(AValue);
  if not (csLoading in ComponentState) then Self.DoOnResize;
end;

procedure TFRMaterialCheckComboEdit.SetColor(AValue: TColor);
begin
  inherited SetColor(AValue);
  if Assigned(FDisplayEdit) then FDisplayEdit.Color := AValue;
end;

procedure TFRMaterialCheckComboEdit.SetName(const AValue: TComponentName);
begin
  if csDesigning in ComponentState then
  begin
    if (FLabel.Caption = '') or AnsiSameText(FLabel.Caption, Name) then
      FLabel.Caption := 'Selecionar';
    if (FLabel.Name = '') or AnsiSameText(FLabel.Name, Name) then
      FLabel.Name := AValue + 'SubLabel';
  end;
  inherited SetName(AValue);
end;

procedure TFRMaterialCheckComboEdit.DoEnter;
begin
  inherited DoEnter;
  FFocused := True;
  if Assigned(FLabelAnimator) then FLabelAnimator.FloatLabel;
  Invalidate;
end;

procedure TFRMaterialCheckComboEdit.DoExit;
begin
  FFocused := False;
  if Assigned(FLabelAnimator) then
  begin
    if ((Trim(FDisplayEdit.Text) = '') or (FDisplayEdit.Text = FEmptyText)) and not IsDropDownOpen then
      FLabelAnimator.InlineLabel
    else
      FLabelAnimator.FloatLabel;
  end;
  Invalidate;
  inherited DoExit;
end;

procedure TFRMaterialCheckComboEdit.DoOnResize;
var
  AutoSizedHeight: LongInt;
  EditArea: TRect;
  BtnW: Integer;
begin
  if IsNeededAdjustSize then
  begin
    { O "campo" é composto por FDisplayEdit + FDropButton no alBottom }
    AutoSizedHeight :=
      FLabel.Height +
      FLabel.BorderSpacing.Around * 2 +
      FLabel.BorderSpacing.Bottom +
      FLabel.BorderSpacing.Top +
      FDisplayEdit.Height +
      FDisplayEdit.BorderSpacing.Around * 2 +
      FDisplayEdit.BorderSpacing.Bottom +
      FDisplayEdit.BorderSpacing.Top;

    if Self.Height <> AutoSizedHeight then
      Self.Height := AutoSizedHeight;
  end;

  { Posiciona o botão de dropdown à direita do campo de exibição }
  BtnW := 24;
  EditArea := Rect(
    FDisplayEdit.BorderSpacing.Left,
    0,
    Self.ClientWidth - FDisplayEdit.BorderSpacing.Right,
    Self.ClientHeight - FDisplayEdit.BorderSpacing.Bottom
  );

  FDropButton.Width  := BtnW;
  FDropButton.Height := FDisplayEdit.Height;
  FDropButton.Left   := EditArea.Right - BtnW;
  FDropButton.Top    := FDisplayEdit.Top;
  FDropButton.BringToFront;

  { Recua o campo para não sobrepor o botão }
  FDisplayEdit.BorderSpacing.Right := BtnW + 4;

  inherited DoOnResize;
end;

procedure TFRMaterialCheckComboEdit.Paint;
var
  DecoColor: TColor;
  P: TFRMDFieldPaintParams;
begin
  inherited Paint;

  if FDisplayEdit.Color <> Self.Color then
    FDisplayEdit.Color := Self.Color;

  if FFocused and Self.Enabled then
    DecoColor := AccentColor
  else
    DecoColor := DisabledColor;

  P.Canvas := Canvas;
  P.Rect := ClientRect;
  P.BgColor := Color;
  if Assigned(Parent) then P.ParentBgColor := Parent.Color else P.ParentBgColor := clNone;

  P.Variant := Variant;
  P.BorderRadius := BorderRadius;

  P.DecoColor := DecoColor;
  P.HelperColor := DisabledColor;
  P.DisabledColor := DisabledColor;

  P.IsFocused := FFocused;
  P.IsEnabled := Enabled;
  P.IsRequired := Required;

  P.EditLeft := FDisplayEdit.Left;
  P.EditTop := FDisplayEdit.Top;
  P.EditWidth := FDisplayEdit.Width;
  P.EditHeight := FDisplayEdit.Height;

  P.ActionRight := FDropButton.Left + FDropButton.Width;
  P.BottomMargin := 0;

  P.HelperText := HelperText;
  P.CharCounterText := '';
  P.PrefixText := '';
  P.SuffixText := '';

  P.EditFont := FDisplayEdit.Font;
  P.LabelFont := FLabel.Font;
  P.LabelRight := FLabel.Left + Canvas.TextWidth(FLabel.Caption);
  P.LabelTop := FLabel.Top;
  P.LabelText := FLabel.Caption;
  if Assigned(FLabelAnimator) then
    P.LabelProgress := FLabelAnimator.Progress
  else
    P.LabelProgress := 1.0;

  TFRMaterialFieldPainter.DrawField(P);
end;

procedure TFRMaterialCheckComboEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Key in [VK_RETURN, VK_DOWN, VK_F4] then
    if not IsDropDownOpen then OpenDropDown;
  if (Key = VK_ESCAPE) and IsDropDownOpen then CloseDropDown;
end;

constructor TFRMaterialCheckComboEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Self.BorderStyle := bsNone;
  Self.ParentColor := True;

  FItems := TStringList.Create;
  TStringList(FItems).OnChange := @ItemsChange;

  FLabel := TBoundLabel.Create(Self);
  FLabel.Align                := alNone;
  FLabel.Visible              := False;
  FLabel.AutoSize             := True;
  FLabel.Top                  := 4;
  FLabel.BorderSpacing.Around := 0;
  FLabel.BorderSpacing.Bottom := 4;
  FLabel.BorderSpacing.Left   := 4;
  FLabel.BorderSpacing.Right  := 4;
  FLabel.BorderSpacing.Top    := 4;
  FLabel.Font.Color           := $00B8AFA8;
  FLabel.Font.Style           := [fsBold];
  FLabel.Parent               := Self;
  FLabel.ParentFont           := False;
  FLabel.ParentBiDiMode       := True;
  FLabel.SetSubComponent(True);
  
  FLabelAnimator := TFRMDFloatingLabelAnimator.Create(Self);
  FLabelAnimator.SnapTo(1.0);

  FDisplayEdit := TEdit.Create(Self);
  FDisplayEdit.Align                := alBottom;
  FDisplayEdit.AutoSize             := True;
  FDisplayEdit.BorderSpacing.Around := 0;
  FDisplayEdit.BorderSpacing.Bottom := 4;
  FDisplayEdit.BorderSpacing.Left   := 4;
  FDisplayEdit.BorderSpacing.Right  := 28; { reserva espaço para FDropButton }
  FDisplayEdit.BorderSpacing.Top    := 0;
  FDisplayEdit.BorderStyle          := bsNone;
  FDisplayEdit.ParentColor          := True;
  FDisplayEdit.ReadOnly             := True;
  FDisplayEdit.TabStop              := True;
  FDisplayEdit.Parent               := Self;
  FDisplayEdit.ParentFont           := True;
  FDisplayEdit.ParentBiDiMode       := True;
  FDisplayEdit.SetSubComponent(True);

  FDropButton := TButton.Create(Self);
  FDropButton.Caption    := '▾';      { ▾ triângulo para baixo U+25BE }
  FDropButton.Width      := 24;
  FDropButton.Height     := 24;
  FDropButton.TabStop    := False;
  FDropButton.Parent     := Self;
  FDropButton.OnClick    := @DropButtonClick;
  FDropButton.SetSubComponent(True);

  { Cria o painel flutuante (oculto) }
  FDropDown := TCheckComboDropDown.CreateForCombo(Self);

  FDisplayFormat := cdfCommaSeparated;
  FDropDownCount := 8;
  FEmptyText     := '';

  FVariant      := mvStandard;
  FBorderRadius := 0;

  UpdateDisplayText;
end;

destructor TFRMaterialCheckComboEdit.Destroy;
begin
  if Assigned(FLabelAnimator) then FLabelAnimator.Free;
  FItems.Free;
  inherited Destroy;
end;

end.

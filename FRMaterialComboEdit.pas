unit FRMaterialComboEdit;

{$mode objfpc}{$H+}

{ TFRMaterialComboEdit
  Variante "select/combobox" do TFRMaterialEdit com estilo Material Design.
  Encapsula TComboBox (LCL) expondo:
    - Label flutuante acima do campo (accentColor no foco)
    - Sublinhado Material Design (linha dupla no foco)
    - Suporte a estilos csDropDown (editável) e csDropDownList (somente seleção)
    - Propriedade Style controlável em design-time
    - Acesso completo às propriedades/eventos do TComboBox interno

  Uso análogo ao <select> HTML / Material Select do Angular/React.
  Licença: LGPL v3 — mesma do bgracontrols
}

interface

uses
  FRMaterialTheme, Classes, Controls, ExtCtrls, Forms, Graphics,
  {$IFDEF FPC} LCLType, LResources, {$ENDIF}
  Menus, StdCtrls, SysUtils;

type

  { TFRMaterialComboEdit }

  TFRMaterialComboEdit = class(TCustomPanel)
  private
    FAccentColor: TColor;
    FDisabledColor: TColor;
    FLabel: TBoundLabel;
    FCombo: TComboBox;
    FFocused: Boolean;
    FVariant: TFRMaterialVariant;
    FBorderRadius: Integer;
    { Armazena OnChange do usuário — FCombo.OnChange é reservado internamente }
    FUserOnChange: TNotifyEvent;

    function IsNeededAdjustSize: Boolean;
    procedure InternalComboChange(Sender: TObject);

    { Propriedades }
    function GetAutoComplete: Boolean;
    procedure SetAutoComplete(AValue: Boolean);
    function GetAutoCompleteText: TComboBoxAutoCompleteText;
    procedure SetAutoCompleteText(AValue: TComboBoxAutoCompleteText);
    function GetAutoDropDown: Boolean;
    procedure SetAutoDropDown(AValue: Boolean);
    function GetComboStyle: TComboBoxStyle;
    procedure SetComboStyle(AValue: TComboBoxStyle);
    function GetDropDownCount: Integer;
    procedure SetDropDownCount(AValue: Integer);
    function GetEditCursor: TCursor;
    procedure SetEditCursor(AValue: TCursor);
    function GetItems: TStrings;
    procedure SetItems(AValue: TStrings);
    function GetItemHeight: Integer;
    procedure SetItemHeight(AValue: Integer);
    function GetItemIndex: Integer;
    procedure SetItemIndex(AValue: Integer);
    function GetItemWidth: Integer;
    procedure SetItemWidth(AValue: Integer);
    function GetMaxLength: Integer;
    procedure SetMaxLength(AValue: Integer);
    function GetEditPopupMenu: TPopupMenu;
    procedure SetEditPopupMenu(AValue: TPopupMenu);
    function GetEditReadOnly: Boolean;
    procedure SetEditReadOnly(AValue: Boolean);
    function GetSorted: Boolean;
    procedure SetSorted(AValue: Boolean);
    function GetEditTabStop: Boolean;
    procedure SetEditTabStop(AValue: Boolean);
    function GetEditText: TCaption;
    procedure SetEditText(const AValue: TCaption);
    function GetLabelCaption: TCaption;
    procedure SetLabelCaption(const AValue: TCaption);
    function GetLabelSpacing: Integer;
    procedure SetLabelSpacing(AValue: Integer);

    { Eventos }
    function GetOnChange: TNotifyEvent;
    procedure SetOnChange(AValue: TNotifyEvent);
    function GetOnClick: TNotifyEvent;
    procedure SetOnClick(AValue: TNotifyEvent);
    function GetOnCloseUp: TNotifyEvent;
    procedure SetOnCloseUp(AValue: TNotifyEvent);
    function GetOnDblClick: TNotifyEvent;
    procedure SetOnDblClick(AValue: TNotifyEvent);
    function GetOnDropDown: TNotifyEvent;
    procedure SetOnDropDown(AValue: TNotifyEvent);
    function GetOnEditingDone: TNotifyEvent;
    procedure SetOnEditingDone(AValue: TNotifyEvent);
    function GetOnEnter: TNotifyEvent;
    procedure SetOnEnter(AValue: TNotifyEvent);
    function GetOnExit: TNotifyEvent;
    procedure SetOnExit(AValue: TNotifyEvent);
    function GetOnKeyDown: TKeyEvent;
    procedure SetOnKeyDown(AValue: TKeyEvent);
    function GetOnKeyPress: TKeyPressEvent;
    procedure SetOnKeyPress(AValue: TKeyPressEvent);
    function GetOnKeyUp: TKeyEvent;
    procedure SetOnKeyUp(AValue: TKeyEvent);
    function GetOnMouseDown: TMouseEvent;
    procedure SetOnMouseDown(AValue: TMouseEvent);
    function GetOnMouseEnter: TNotifyEvent;
    procedure SetOnMouseEnter(AValue: TNotifyEvent);
    function GetOnMouseLeave: TNotifyEvent;
    procedure SetOnMouseLeave(AValue: TNotifyEvent);
    function GetOnMouseMove: TMouseMoveEvent;
    procedure SetOnMouseMove(AValue: TMouseMoveEvent);
    function GetOnMouseUp: TMouseEvent;
    procedure SetOnMouseUp(AValue: TMouseEvent);
    function GetOnMouseWheel: TMouseWheelEvent;
    procedure SetOnMouseWheel(AValue: TMouseWheelEvent);
    function GetOnMouseWheelDown: TMouseWheelUpDownEvent;
    procedure SetOnMouseWheelDown(AValue: TMouseWheelUpDownEvent);
    function GetOnMouseWheelUp: TMouseWheelUpDownEvent;
    procedure SetOnMouseWheelUp(AValue: TMouseWheelUpDownEvent);
    function GetOnSelect: TNotifyEvent;
    procedure SetOnSelect(AValue: TNotifyEvent);
    function GetOnUTF8KeyPress: TUTF8KeyPressEvent;
    procedure SetOnUTF8KeyPress(AValue: TUTF8KeyPressEvent);

  protected
    procedure SetAnchors(const AValue: TAnchors); override;
    procedure SetColor(AValue: TColor); override;
    procedure SetName(const AValue: TComponentName); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DoOnResize; override;
    procedure Paint; override;

  public
    constructor Create(AOwner: TComponent); override;
    { Retorna a string do item atualmente selecionado, ou '' se nenhum }
    function SelectedText: string;
    { Seleciona o primeiro item cujo texto começa com AText (case-insensitive) }
    procedure SelectByText(const AText: string);
    { Acesso direto ao TComboBox interno para customizações avançadas }
    property Combo: TComboBox read FCombo;

  published
    property Align;
    property AccentColor: TColor read FAccentColor write FAccentColor;
    property Anchors;
    { Habilita autocompletar ao digitar (relevante em Style=csDropDown) }
    property AutoComplete: Boolean
      read GetAutoComplete write SetAutoComplete default True;
    { Configura o comportamento de autocompletar }
    property AutoCompleteText: TComboBoxAutoCompleteText
      read GetAutoCompleteText write SetAutoCompleteText
      default [cbactEnabled, cbactEndOfLineComplete];
    { Abre o dropdown automaticamente ao digitar }
    property AutoDropDown: Boolean
      read GetAutoDropDown write SetAutoDropDown default False;
    property BiDiMode;
    property BorderSpacing;
    { Legenda do label flutuante }
    property Caption: TCaption read GetLabelCaption write SetLabelCaption;
    property Color;
    property Constraints;
    property Cursor: TCursor read GetEditCursor write SetEditCursor default crDefault;
    property DisabledColor: TColor read FDisabledColor write FDisabledColor;
    { Variante visual: sublinhado (mvStandard), preenchido (mvFilled) ou contornado (mvOutlined) }
    property Variant: TFRMaterialVariant read FVariant write FVariant default mvStandard;
    { Raio dos cantos arredondados em pixels; 0 = cantos retos }
    property BorderRadius: Integer read FBorderRadius write FBorderRadius default 0;
    { Número de linhas visíveis no dropdown }
    property DropDownCount: Integer
      read GetDropDownCount write SetDropDownCount default 8;
    { Label flutuante acima do campo }
    property EditLabel: TBoundLabel read FLabel;
    property Enabled;
    property Font;
    property Hint;
    { Lista de itens do ComboBox }
    property Items: TStrings read GetItems write SetItems;
    property ItemHeight: Integer read GetItemHeight write SetItemHeight default 0;
    { Índice do item selecionado (-1 = nenhum) }
    property ItemIndex: Integer read GetItemIndex write SetItemIndex default -1;
    property ItemWidth: Integer read GetItemWidth write SetItemWidth default 0;
    property LabelSpacing: Integer read GetLabelSpacing write SetLabelSpacing default 4;
    property MaxLength: Integer read GetMaxLength write SetMaxLength default 0;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont default False;
    property PopupMenu: TPopupMenu read GetEditPopupMenu write SetEditPopupMenu;
    { False = somente seleção (como <select> HTML); True = editável }
    property ReadOnly: Boolean read GetEditReadOnly write SetEditReadOnly default False;
    { Ordena os itens alfabeticamente }
    property Sorted: Boolean read GetSorted write SetSorted default False;
    property ShowHint;
    { csDropDown = editável (default); csDropDownList = somente seleção (como <select>) }
    property Style: TComboBoxStyle
      read GetComboStyle write SetComboStyle default csDropDown;
    property TabOrder;
    property TabStop: Boolean read GetEditTabStop write SetEditTabStop default True;
    property Text: TCaption read GetEditText write SetEditText;
    property Visible;

    property OnChange: TNotifyEvent read GetOnChange write SetOnChange;
    property OnChangeBounds;
    property OnClick: TNotifyEvent read GetOnClick write SetOnClick;
    { Disparado quando o dropdown fecha }
    property OnCloseUp: TNotifyEvent read GetOnCloseUp write SetOnCloseUp;
    property OnDblClick: TNotifyEvent read GetOnDblClick write SetOnDblClick;
    { Disparado quando o dropdown abre }
    property OnDropDown: TNotifyEvent read GetOnDropDown write SetOnDropDown;
    property OnEditingDone: TNotifyEvent read GetOnEditingDone write SetOnEditingDone;
    property OnEnter: TNotifyEvent read GetOnEnter write SetOnEnter;
    property OnExit: TNotifyEvent read GetOnExit write SetOnExit;
    property OnKeyDown: TKeyEvent read GetOnKeyDown write SetOnKeyDown;
    property OnKeyPress: TKeyPressEvent read GetOnKeyPress write SetOnKeyPress;
    property OnKeyUp: TKeyEvent read GetOnKeyUp write SetOnKeyUp;
    property OnMouseDown: TMouseEvent read GetOnMouseDown write SetOnMouseDown;
    property OnMouseEnter: TNotifyEvent read GetOnMouseEnter write SetOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read GetOnMouseLeave write SetOnMouseLeave;
    property OnMouseMove: TMouseMoveEvent read GetOnMouseMove write SetOnMouseMove;
    property OnMouseUp: TMouseEvent read GetOnMouseUp write SetOnMouseUp;
    property OnMouseWheel: TMouseWheelEvent read GetOnMouseWheel write SetOnMouseWheel;
    property OnMouseWheelDown: TMouseWheelUpDownEvent
      read GetOnMouseWheelDown write SetOnMouseWheelDown;
    property OnMouseWheelUp: TMouseWheelUpDownEvent
      read GetOnMouseWheelUp write SetOnMouseWheelUp;
    { Disparado ao selecionar um item (complementa OnChange) }
    property OnSelect: TNotifyEvent read GetOnSelect write SetOnSelect;
    property OnResize;
    property OnUTF8KeyPress: TUTF8KeyPressEvent
      read GetOnUTF8KeyPress write SetOnUTF8KeyPress;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialcomboedit_icon.lrs}
  {$ENDIF}
  RegisterComponents('BGRA Controls', [TFRMaterialComboEdit]);
end;

{ TFRMaterialComboEdit }

function TFRMaterialComboEdit.IsNeededAdjustSize: Boolean;
begin
  if Self.Align in [alLeft, alRight, alClient] then Exit(False);
  if (akTop in Self.Anchors) and (akBottom in Self.Anchors) then Exit(False);
  Result := True; { TComboBox tem altura fixa (AutoSize implícito) }
end;

procedure TFRMaterialComboEdit.InternalComboChange(Sender: TObject);
begin
  if Assigned(FUserOnChange) then
    FUserOnChange(Sender);
end;

{ --- Getters/Setters de propriedades --- }

function TFRMaterialComboEdit.GetAutoComplete: Boolean;
begin
  Result := FCombo.AutoComplete;
end;

procedure TFRMaterialComboEdit.SetAutoComplete(AValue: Boolean);
begin
  FCombo.AutoComplete := AValue;
end;

function TFRMaterialComboEdit.GetAutoCompleteText: TComboBoxAutoCompleteText;
begin
  Result := FCombo.AutoCompleteText;
end;

procedure TFRMaterialComboEdit.SetAutoCompleteText(AValue: TComboBoxAutoCompleteText);
begin
  FCombo.AutoCompleteText := AValue;
end;

function TFRMaterialComboEdit.GetAutoDropDown: Boolean;
begin
  Result := FCombo.AutoDropDown;
end;

procedure TFRMaterialComboEdit.SetAutoDropDown(AValue: Boolean);
begin
  FCombo.AutoDropDown := AValue;
end;

function TFRMaterialComboEdit.GetComboStyle: TComboBoxStyle;
begin
  Result := FCombo.Style;
end;

procedure TFRMaterialComboEdit.SetComboStyle(AValue: TComboBoxStyle);
begin
  FCombo.Style := AValue;
end;

function TFRMaterialComboEdit.GetDropDownCount: Integer;
begin
  Result := FCombo.DropDownCount;
end;

procedure TFRMaterialComboEdit.SetDropDownCount(AValue: Integer);
begin
  FCombo.DropDownCount := AValue;
end;

function TFRMaterialComboEdit.GetEditCursor: TCursor;
begin
  Result := FCombo.Cursor;
end;

procedure TFRMaterialComboEdit.SetEditCursor(AValue: TCursor);
begin
  FCombo.Cursor := AValue;
end;

function TFRMaterialComboEdit.GetItems: TStrings;
begin
  Result := FCombo.Items;
end;

procedure TFRMaterialComboEdit.SetItems(AValue: TStrings);
begin
  FCombo.Items := AValue;
end;

function TFRMaterialComboEdit.GetItemHeight: Integer;
begin
  Result := FCombo.ItemHeight;
end;

procedure TFRMaterialComboEdit.SetItemHeight(AValue: Integer);
begin
  FCombo.ItemHeight := AValue;
end;

function TFRMaterialComboEdit.GetItemIndex: Integer;
begin
  Result := FCombo.ItemIndex;
end;

procedure TFRMaterialComboEdit.SetItemIndex(AValue: Integer);
begin
  FCombo.ItemIndex := AValue;
end;

function TFRMaterialComboEdit.GetItemWidth: Integer;
begin
  Result := FCombo.ItemWidth;
end;

procedure TFRMaterialComboEdit.SetItemWidth(AValue: Integer);
begin
  FCombo.ItemWidth := AValue;
end;

function TFRMaterialComboEdit.GetMaxLength: Integer;
begin
  Result := FCombo.MaxLength;
end;

procedure TFRMaterialComboEdit.SetMaxLength(AValue: Integer);
begin
  FCombo.MaxLength := AValue;
end;

function TFRMaterialComboEdit.GetEditPopupMenu: TPopupMenu;
begin
  if csDestroying in ComponentState then Exit(nil);
  Result := FCombo.PopupMenu;
end;

procedure TFRMaterialComboEdit.SetEditPopupMenu(AValue: TPopupMenu);
begin
  FCombo.PopupMenu := AValue;
end;

function TFRMaterialComboEdit.GetEditReadOnly: Boolean;
begin
  Result := FCombo.ReadOnly;
end;

procedure TFRMaterialComboEdit.SetEditReadOnly(AValue: Boolean);
begin
  FCombo.ReadOnly := AValue;
end;

function TFRMaterialComboEdit.GetSorted: Boolean;
begin
  Result := FCombo.Sorted;
end;

procedure TFRMaterialComboEdit.SetSorted(AValue: Boolean);
begin
  FCombo.Sorted := AValue;
end;

function TFRMaterialComboEdit.GetEditTabStop: Boolean;
begin
  Result := FCombo.TabStop;
end;

procedure TFRMaterialComboEdit.SetEditTabStop(AValue: Boolean);
begin
  FCombo.TabStop := AValue;
end;

function TFRMaterialComboEdit.GetEditText: TCaption;
begin
  Result := FCombo.Text;
end;

procedure TFRMaterialComboEdit.SetEditText(const AValue: TCaption);
begin
  FCombo.Text := AValue;
end;

function TFRMaterialComboEdit.GetLabelCaption: TCaption;
begin
  Result := FLabel.Caption;
end;

procedure TFRMaterialComboEdit.SetLabelCaption(const AValue: TCaption);
begin
  FLabel.Caption := AValue;
end;

function TFRMaterialComboEdit.GetLabelSpacing: Integer;
begin
  Result := FLabel.BorderSpacing.Bottom;
end;

procedure TFRMaterialComboEdit.SetLabelSpacing(AValue: Integer);
begin
  if FLabel.BorderSpacing.Bottom = AValue then Exit;
  FLabel.BorderSpacing.Bottom := AValue;
  if not (csLoading in ComponentState) then Self.DoOnResize;
end;

{ --- Getters/Setters de eventos --- }

function TFRMaterialComboEdit.GetOnChange: TNotifyEvent;
begin
  Result := FUserOnChange;
end;

procedure TFRMaterialComboEdit.SetOnChange(AValue: TNotifyEvent);
begin
  FUserOnChange := AValue;
end;

function TFRMaterialComboEdit.GetOnClick: TNotifyEvent;
begin
  Result := FCombo.OnClick;
end;

procedure TFRMaterialComboEdit.SetOnClick(AValue: TNotifyEvent);
begin
  FCombo.OnClick := AValue;
end;

function TFRMaterialComboEdit.GetOnCloseUp: TNotifyEvent;
begin
  Result := FCombo.OnCloseUp;
end;

procedure TFRMaterialComboEdit.SetOnCloseUp(AValue: TNotifyEvent);
begin
  FCombo.OnCloseUp := AValue;
end;

function TFRMaterialComboEdit.GetOnDblClick: TNotifyEvent;
begin
  Result := FCombo.OnDblClick;
end;

procedure TFRMaterialComboEdit.SetOnDblClick(AValue: TNotifyEvent);
begin
  FCombo.OnDblClick := AValue;
end;

function TFRMaterialComboEdit.GetOnDropDown: TNotifyEvent;
begin
  Result := FCombo.OnDropDown;
end;

procedure TFRMaterialComboEdit.SetOnDropDown(AValue: TNotifyEvent);
begin
  FCombo.OnDropDown := AValue;
end;

function TFRMaterialComboEdit.GetOnEditingDone: TNotifyEvent;
begin
  Result := FCombo.OnEditingDone;
end;

procedure TFRMaterialComboEdit.SetOnEditingDone(AValue: TNotifyEvent);
begin
  FCombo.OnEditingDone := AValue;
end;

function TFRMaterialComboEdit.GetOnEnter: TNotifyEvent;
begin
  Result := FCombo.OnEnter;
end;

procedure TFRMaterialComboEdit.SetOnEnter(AValue: TNotifyEvent);
begin
  FCombo.OnEnter := AValue;
end;

function TFRMaterialComboEdit.GetOnExit: TNotifyEvent;
begin
  Result := FCombo.OnExit;
end;

procedure TFRMaterialComboEdit.SetOnExit(AValue: TNotifyEvent);
begin
  FCombo.OnExit := AValue;
end;

function TFRMaterialComboEdit.GetOnKeyDown: TKeyEvent;
begin
  Result := FCombo.OnKeyDown;
end;

procedure TFRMaterialComboEdit.SetOnKeyDown(AValue: TKeyEvent);
begin
  FCombo.OnKeyDown := AValue;
end;

function TFRMaterialComboEdit.GetOnKeyPress: TKeyPressEvent;
begin
  Result := FCombo.OnKeyPress;
end;

procedure TFRMaterialComboEdit.SetOnKeyPress(AValue: TKeyPressEvent);
begin
  FCombo.OnKeyPress := AValue;
end;

function TFRMaterialComboEdit.GetOnKeyUp: TKeyEvent;
begin
  Result := FCombo.OnKeyUp;
end;

procedure TFRMaterialComboEdit.SetOnKeyUp(AValue: TKeyEvent);
begin
  FCombo.OnKeyUp := AValue;
end;

function TFRMaterialComboEdit.GetOnMouseDown: TMouseEvent;
begin
  Result := FCombo.OnMouseDown;
end;

procedure TFRMaterialComboEdit.SetOnMouseDown(AValue: TMouseEvent);
begin
  FCombo.OnMouseDown := AValue;
end;

function TFRMaterialComboEdit.GetOnMouseEnter: TNotifyEvent;
begin
  Result := FCombo.OnMouseEnter;
end;

procedure TFRMaterialComboEdit.SetOnMouseEnter(AValue: TNotifyEvent);
begin
  FCombo.OnMouseEnter := AValue;
end;

function TFRMaterialComboEdit.GetOnMouseLeave: TNotifyEvent;
begin
  Result := FCombo.OnMouseLeave;
end;

procedure TFRMaterialComboEdit.SetOnMouseLeave(AValue: TNotifyEvent);
begin
  FCombo.OnMouseLeave := AValue;
end;

function TFRMaterialComboEdit.GetOnMouseMove: TMouseMoveEvent;
begin
  Result := FCombo.OnMouseMove;
end;

procedure TFRMaterialComboEdit.SetOnMouseMove(AValue: TMouseMoveEvent);
begin
  FCombo.OnMouseMove := AValue;
end;

function TFRMaterialComboEdit.GetOnMouseUp: TMouseEvent;
begin
  Result := FCombo.OnMouseUp;
end;

procedure TFRMaterialComboEdit.SetOnMouseUp(AValue: TMouseEvent);
begin
  FCombo.OnMouseUp := AValue;
end;

function TFRMaterialComboEdit.GetOnMouseWheel: TMouseWheelEvent;
begin
  Result := FCombo.OnMouseWheel;
end;

procedure TFRMaterialComboEdit.SetOnMouseWheel(AValue: TMouseWheelEvent);
begin
  FCombo.OnMouseWheel := AValue;
end;

function TFRMaterialComboEdit.GetOnMouseWheelDown: TMouseWheelUpDownEvent;
begin
  Result := FCombo.OnMouseWheelDown;
end;

procedure TFRMaterialComboEdit.SetOnMouseWheelDown(AValue: TMouseWheelUpDownEvent);
begin
  FCombo.OnMouseWheelDown := AValue;
end;

function TFRMaterialComboEdit.GetOnMouseWheelUp: TMouseWheelUpDownEvent;
begin
  Result := FCombo.OnMouseWheelUp;
end;

procedure TFRMaterialComboEdit.SetOnMouseWheelUp(AValue: TMouseWheelUpDownEvent);
begin
  FCombo.OnMouseWheelUp := AValue;
end;

function TFRMaterialComboEdit.GetOnSelect: TNotifyEvent;
begin
  Result := FCombo.OnSelect;
end;

procedure TFRMaterialComboEdit.SetOnSelect(AValue: TNotifyEvent);
begin
  FCombo.OnSelect := AValue;
end;

function TFRMaterialComboEdit.GetOnUTF8KeyPress: TUTF8KeyPressEvent;
begin
  Result := FCombo.OnUTF8KeyPress;
end;

procedure TFRMaterialComboEdit.SetOnUTF8KeyPress(AValue: TUTF8KeyPressEvent);
begin
  FCombo.OnUTF8KeyPress := AValue;
end;

{ --- Métodos públicos --- }

function TFRMaterialComboEdit.SelectedText: string;
begin
  if FCombo.ItemIndex >= 0 then
    Result := FCombo.Items[FCombo.ItemIndex]
  else
    Result := '';
end;

procedure TFRMaterialComboEdit.SelectByText(const AText: string);
var
  i: Integer;
begin
  for i := 0 to FCombo.Items.Count - 1 do
    if AnsiSameText(Copy(FCombo.Items[i], 1, Length(AText)), AText) then
    begin
      FCombo.ItemIndex := i;
      Exit;
    end;
end;

{ --- Métodos protegidos --- }

procedure TFRMaterialComboEdit.SetAnchors(const AValue: TAnchors);
begin
  if Self.Anchors = AValue then Exit;
  inherited SetAnchors(AValue);
  if not (csLoading in ComponentState) then Self.DoOnResize;
end;

procedure TFRMaterialComboEdit.SetColor(AValue: TColor);
begin
  inherited SetColor(AValue);
  FCombo.Color := AValue;
end;

procedure TFRMaterialComboEdit.SetName(const AValue: TComponentName);
begin
  if csDesigning in ComponentState then
  begin
    if (FLabel.Caption = '') or AnsiSameText(FLabel.Caption, Name) then
      FLabel.Caption := 'Selecionar';
    if (FLabel.Name = '') or AnsiSameText(FLabel.Name, Name) then
      FLabel.Name := AValue + 'SubLabel';
    if (FCombo.Name = '') or AnsiSameText(FCombo.Name, Name) then
      FCombo.Name := AValue + 'SubCombo';
  end;
  inherited SetName(AValue);
end;

procedure TFRMaterialComboEdit.DoEnter;
begin
  inherited DoEnter;
  FFocused := True;
  Invalidate;
end;

procedure TFRMaterialComboEdit.DoExit;
begin
  FFocused := False;
  Invalidate;
  inherited DoExit;
end;

procedure TFRMaterialComboEdit.DoOnResize;
var
  AutoSizedHeight: LongInt;
begin
  if IsNeededAdjustSize then
  begin
    FCombo.Align := alBottom;
    AutoSizedHeight :=
      FLabel.Height +
      FLabel.BorderSpacing.Around +
      FLabel.BorderSpacing.Bottom +
      FLabel.BorderSpacing.Top +
      FCombo.Height +
      FCombo.BorderSpacing.Around +
      FCombo.BorderSpacing.Bottom +
      FCombo.BorderSpacing.Top;

    if Self.Height <> AutoSizedHeight then
      Self.Height := AutoSizedHeight;
  end else
    FCombo.Align := alClient;

  inherited DoOnResize;
end;

procedure TFRMaterialComboEdit.Paint;
var
  LeftPos, RightPos, FieldTop, CR: Integer;
  DecoColor: TColor;
begin
  inherited Paint;

  if FCombo.Color <> Self.Color then
    FCombo.Color := Self.Color;

  CR := FBorderRadius * 2;
  if FFocused and Self.Enabled then
    DecoColor := AccentColor
  else
    DecoColor := DisabledColor;

  if Assigned(Parent) and (Parent.Color = Color) then
  begin
    LeftPos  := FCombo.Left;
    RightPos := FCombo.Left + FCombo.Width;
  end else
  begin
    LeftPos  := 0;
    RightPos := Width;
  end;

  FieldTop := FCombo.Top - 2;
  if FieldTop < 0 then FieldTop := 0;

  Canvas.Pen.Width   := 1;
  Canvas.Pen.Color   := Color;
  Canvas.Brush.Color := Color;
  case FVariant of
    mvFilled:
      if CR > 0 then
        Canvas.RoundRect(0, 0, Width, Height, CR, CR)
      else
        Canvas.Rectangle(0, 0, Width, Height);
  else
    Canvas.Rectangle(0, 0, Width, Height);
  end;

  Canvas.Pen.Color  := DecoColor;
  FLabel.Font.Color := DecoColor;

  case FVariant of
    mvStandard, mvFilled:
    begin
      if FFocused and Self.Enabled then
      begin
        Canvas.Line(LeftPos, Height - 2, RightPos, Height - 2);
        Canvas.Line(LeftPos, Height - 1, RightPos, Height - 1);
      end else
        Canvas.Line(LeftPos, Height - 1, RightPos, Height - 1);
    end;
    mvOutlined:
    begin
      Canvas.Brush.Style := bsClear;
      if FFocused and Self.Enabled then
        Canvas.Pen.Width := 2
      else
        Canvas.Pen.Width := 1;
      if CR > 0 then
        Canvas.RoundRect(LeftPos, FieldTop, RightPos, Height - 1, CR, CR)
      else
        Canvas.Rectangle(LeftPos, FieldTop, RightPos, Height - 1);
      Canvas.Pen.Width   := 1;
      Canvas.Brush.Style := bsSolid;
    end;
  end;
end;

constructor TFRMaterialComboEdit.Create(AOwner: TComponent);
begin
  FCombo := TComboBox.Create(Self);
  FLabel := TBoundLabel.Create(Self);
  inherited Create(AOwner);

  Self.AccentColor   := clHighlight;
  Self.BorderStyle   := bsNone;
  Self.DisabledColor := $00B8AFA8;
  Self.ParentColor   := True;

  FLabel.Align                := alTop;
  FLabel.AutoSize             := True;
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

  FCombo.Align                := alBottom;
  FCombo.AutoComplete         := True;
  FCombo.AutoDropDown         := False;
  FCombo.BorderSpacing.Around := 0;
  FCombo.BorderSpacing.Bottom := 4;
  FCombo.BorderSpacing.Left   := 4;
  FCombo.BorderSpacing.Right  := 4;
  FCombo.BorderSpacing.Top    := 0;
  FCombo.ParentColor          := True;
  FCombo.DropDownCount        := 8;
  FCombo.Parent               := Self;
  FCombo.ParentFont           := True;
  FCombo.ParentBiDiMode       := True;
  FCombo.Style                := csDropDown;
  FCombo.TabStop              := True;
  FCombo.SetSubComponent(True);

  { Intercepta OnChange para não sobrescrever o handler do usuário }
  FCombo.OnChange := @InternalComboChange;

  FVariant      := mvStandard;
  FBorderRadius := 0;
end;

end.

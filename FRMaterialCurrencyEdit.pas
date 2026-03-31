unit FRMaterialCurrencyEdit;

{$mode objfpc}{$H+}

{ TFRMaterialCurrencyEdit
  Campo de entrada de valores monetários com estilo Material Design.

  Comportamento de entrada:
  - Somente dígitos são aceitos; os demais caracteres são bloqueados.
  - O valor cresce da direita para a esquerda (centavos primeiro):
      "1"      → R$ 0,01
      "12"     → R$ 0,12
      "123"    → R$ 1,23
      "12345"  → R$ 123,45
      "123456" → R$ 1.234,56
  - Backspace remove o último dígito.
  - Pressionar "-" inverte o sinal (apenas quando AllowNegative = True).
  - Ctrl+V cola texto da área de transferência: apenas dígitos são extraídos.

  Propriedades principais:
    Value            — valor numérico corrente (Currency)
    CurrencySymbol   — prefixo exibido antes do valor (padrão: "R$")
    DecimalPlaces    — casas decimais; 0 = inteiro, 2 = centavos (padrão), 4 = máximo
    ThousandSeparator — separador de milhar (padrão: '.')
    DecimalSeparator  — separador decimal (padrão: ',')
    AllowNegative    — permite valores negativos (padrão: False)
    ShowClearButton  — exibe botão "×" quando valor > 0

  O campo é totalmente gerenciado internamente; a propriedade Text não é exposta.
  Use Value para ler/escrever o valor numérico e Clear para zerar o campo.

  Licença: LGPL v3 — mesma do bgracontrols
}

interface

uses
  FRMaterialTheme, FRMaterialIcons, Classes, Clipbrd, Controls, ExtCtrls, Forms, Graphics,
  {$IFDEF FPC} LCLType, LResources, {$ENDIF}
  Math, Menus, StdCtrls, SysUtils;

type

  { TFRMaterialCurrencyEdit }

  TFRMaterialCurrencyEdit = class(TCustomPanel)
  private
    { Visuais / layout }
    FAccentColor: TColor;
    FDisabledColor: TColor;
    FLabel: TBoundLabel;
    FEdit: TEdit;
    FFocused: Boolean;
    FVariant: TFRMaterialVariant;
    FBorderRadius: Integer;
    FClearButton: TFRMaterialIconButton;
    FShowClearButton: Boolean;
    FOnClearButtonClick: TNotifyEvent;

    { Estado da moeda }
    FCents: Int64;             { valor em unidade mínima (sempre >= 0) }
    FNegative: Boolean;        { sinal do valor }
    FDecimalPlaces: Integer;   { casas decimais: 0..4 }
    FCurrencySymbol: string;   { prefixo, ex.: "R$", "US$", "€" }
    FThousandSeparator: Char;  { separador de milhar }
    FDecimalSeparator: Char;   { separador decimal }
    FAllowNegative: Boolean;   { permite valores negativos }
    FUpdating: Boolean;        { guarda reentrância em RefreshDisplay }

    { Handlers de eventos do usuário (armazenados para não perder ao interceptarmos) }
    FUserOnChange: TNotifyEvent;
    FUserOnKeyPress: TKeyPressEvent;

    { Auxiliares internos }
    function Pow10(N: Integer): Int64;
    function BuildDisplay: string;
    procedure RefreshDisplay;
    procedure InternalKeyPress(Sender: TObject; var Key: Char);

    { Value }
    function GetValue: Currency;
    procedure SetValue(AValue: Currency);

    { Botão de limpeza }
    function GetShowClearButton: Boolean;
    procedure SetShowClearButton(AValue: Boolean);
    procedure ClearButtonClick(Sender: TObject);
    procedure UpdateClearButton;

    { DecimalPlaces — rescala FCents ao mudar }
    function GetDecimalPlaces: Integer;
    procedure SetDecimalPlaces(AValue: Integer);

    { Propriedades delegadas ao TEdit interno }
    function GetAlignment: TAlignment;
    procedure SetAlignment(AValue: TAlignment);
    function GetAutoSelect: Boolean;
    procedure SetAutoSelect(AValue: Boolean);
    function GetEditCursor: TCursor;
    procedure SetEditCursor(AValue: TCursor);
    function GetEditPopupMenu: TPopupMenu;
    procedure SetEditPopupMenu(AValue: TPopupMenu);
    function GetEditReadOnly: Boolean;
    procedure SetEditReadOnly(AValue: Boolean);
    function GetEditTabStop: Boolean;
    procedure SetEditTabStop(AValue: Boolean);
    function GetLabelCaption: TCaption;
    procedure SetLabelCaption(const AValue: TCaption);
    function GetLabelSpacing: Integer;
    procedure SetLabelSpacing(AValue: Integer);

    { Eventos delegados }
    function GetOnChange: TNotifyEvent;
    procedure SetOnChange(AValue: TNotifyEvent);
    function GetOnClick: TNotifyEvent;
    procedure SetOnClick(AValue: TNotifyEvent);
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

    function IsNeededAdjustSize: Boolean;

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

    { Zera o campo (equivale a Value := 0) }
    procedure Clear;

    { Acesso direto ao TEdit interno para customizações avançadas }
    property Edit: TEdit read FEdit;
    { Botão "×" — customização de caption, hint, font, etc. }
    property ClearButton: TFRMaterialIconButton read FClearButton;
    { Valor numérico corrente }
    property Value: Currency read GetValue write SetValue;

  published
    property Align;
    { Alinhamento do texto no campo (padrão: taRightJustify, comum em moeda) }
    property Alignment: TAlignment read GetAlignment write SetAlignment default taRightJustify;
    property AccentColor: TColor read FAccentColor write FAccentColor;
    { Permite valores negativos; pressione "-" para inverter o sinal }
    property AllowNegative: Boolean read FAllowNegative write FAllowNegative default False;
    property Anchors;
    property AutoSelect: Boolean read GetAutoSelect write SetAutoSelect default True;
    property BiDiMode;
    property BorderSpacing;
    { Legenda do label flutuante }
    property Caption: TCaption read GetLabelCaption write SetLabelCaption;
    property Color;
    property Constraints;
    property Cursor: TCursor read GetEditCursor write SetEditCursor default crDefault;
    { Símbolo monetário exibido antes do valor. Use '' para omitir.
      Padrão: 'R$' }
    property CurrencySymbol: string read FCurrencySymbol write FCurrencySymbol;
    { Separador de milhar. Padrão: '.' (padrão brasileiro) }
    property ThousandSeparator: Char
      read FThousandSeparator write FThousandSeparator default '.';
    { Separador decimal. Padrão: ',' (padrão brasileiro) }
    property DecimalSeparator: Char
      read FDecimalSeparator write FDecimalSeparator default ',';
    { Número de casas decimais (0 a 4). Padrão: 2 (centavos).
      Alterar em tempo de execução rescala o valor atual automaticamente. }
    property DecimalPlaces: Integer
      read GetDecimalPlaces write SetDecimalPlaces default 2;
    property DisabledColor: TColor read FDisabledColor write FDisabledColor;
    property EditLabel: TBoundLabel read FLabel;
    property Enabled;
    property Font;
    property Hint;
    property LabelSpacing: Integer read GetLabelSpacing write SetLabelSpacing default 4;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont default False;
    property PopupMenu: TPopupMenu read GetEditPopupMenu write SetEditPopupMenu;
    property ReadOnly: Boolean read GetEditReadOnly write SetEditReadOnly default False;
    { Exibe botão "×" quando o valor for diferente de zero e o campo não estiver ReadOnly }
    property ShowClearButton: Boolean
      read GetShowClearButton write SetShowClearButton default False;
    property ShowHint;
    property TabOrder;
    property TabStop: Boolean read GetEditTabStop write SetEditTabStop default True;
    { Variante visual: sublinhado (mvStandard), preenchido (mvFilled) ou contornado (mvOutlined) }
    property Variant: TFRMaterialVariant read FVariant write FVariant default mvStandard;
    { Raio dos cantos arredondados em pixels; 0 = cantos retos }
    property BorderRadius: Integer read FBorderRadius write FBorderRadius default 0;
    property Visible;

    property OnChange: TNotifyEvent read GetOnChange write SetOnChange;
    property OnChangeBounds;
    { Disparado após o usuário clicar no botão de limpeza }
    property OnClearButtonClick: TNotifyEvent
      read FOnClearButtonClick write FOnClearButtonClick;
    property OnClick: TNotifyEvent read GetOnClick write SetOnClick;
    property OnEditingDone: TNotifyEvent
      read GetOnEditingDone write SetOnEditingDone;
    property OnEnter: TNotifyEvent read GetOnEnter write SetOnEnter;
    property OnExit: TNotifyEvent read GetOnExit write SetOnExit;
    property OnKeyDown: TKeyEvent read GetOnKeyDown write SetOnKeyDown;
    { Disparado após o filtro interno de teclas. A tecla já foi processada;
      Key pode ser #0 para as teclas aceitas pelo campo. }
    property OnKeyPress: TKeyPressEvent read GetOnKeyPress write SetOnKeyPress;
    property OnKeyUp: TKeyEvent read GetOnKeyUp write SetOnKeyUp;
    property OnResize;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialcurrencyedit_icon.lrs}
  {$ENDIF}
  RegisterComponents('BGRA Controls', [TFRMaterialCurrencyEdit]);
end;

{ TFRMaterialCurrencyEdit }

{ --- Auxiliares internos --- }

function TFRMaterialCurrencyEdit.Pow10(N: Integer): Int64;
var
  I: Integer;
begin
  Result := 1;
  for I := 1 to N do
    Result := Result * 10;
end;

function TFRMaterialCurrencyEdit.BuildDisplay: string;
var
  Scale, IntPart, DecPart: Int64;
  IntStr, DecStr: string;
  I, Len, GroupStart: Integer;
begin
  Scale    := Pow10(FDecimalPlaces);
  IntPart  := FCents div Scale;
  DecPart  := FCents mod Scale;

  { Parte inteira com separadores de milhar }
  IntStr := IntToStr(IntPart);
  Len    := Length(IntStr);
  Result := '';
  GroupStart := Len mod 3;
  if GroupStart = 0 then GroupStart := 3;
  for I := 1 to Len do
  begin
    Result := Result + IntStr[I];
    if (I < Len) and (I mod 3 = GroupStart mod 3) and ((Len - I) mod 3 = 0) then
      Result := Result + FThousandSeparator;
  end;

  { Parte decimal }
  if FDecimalPlaces > 0 then
  begin
    DecStr := IntToStr(DecPart);
    while Length(DecStr) < FDecimalPlaces do
      DecStr := '0' + DecStr;
    Result := Result + FDecimalSeparator + DecStr;
  end;

  { Sinal negativo }
  if FNegative and (FCents > 0) then
    Result := '-' + Result;

  { Símbolo monetário }
  if FCurrencySymbol <> '' then
    Result := FCurrencySymbol + ' ' + Result;
end;

procedure TFRMaterialCurrencyEdit.RefreshDisplay;
begin
  if FUpdating then Exit;
  FUpdating := True;
  try
    FEdit.Text := BuildDisplay;
    FEdit.SelStart  := Length(FEdit.Text);
    FEdit.SelLength := 0;
  finally
    FUpdating := False;
  end;
end;

{ --- Filtragem de teclas --- }

procedure TFRMaterialCurrencyEdit.InternalKeyPress(Sender: TObject; var Key: Char);
var
  ValueChanged: Boolean;
  S: string;
  I: Integer;
  NewCents: Int64;
  NewNeg: Boolean;
  SaveKey: Char;
begin
  SaveKey := Key;
  ValueChanged := False;

  case Key of
    '0'..'9':
    begin
      FCents := FCents * 10 + (Ord(Key) - Ord('0'));
      Key    := #0;
      ValueChanged := True;
    end;
    #8: { Backspace }
    begin
      if FCents > 0 then
      begin
        FCents := FCents div 10;
        if FCents = 0 then FNegative := False;
        ValueChanged := True;
      end;
      Key := #0;
    end;
    '-':
    begin
      if FAllowNegative then
      begin
        FNegative := not FNegative;
        if FCents = 0 then FNegative := False;
        ValueChanged := True;
      end;
      Key := #0;
    end;
    #22: { Ctrl+V — colar }
    begin
      S := Clipboard.AsText;
      NewCents := 0;
      NewNeg   := False;
      for I := 1 to Length(S) do
      begin
        if S[I] in ['0'..'9'] then
          NewCents := NewCents * 10 + (Ord(S[I]) - Ord('0'))
        else if (S[I] = '-') and FAllowNegative then
          NewNeg := True;
      end;
      FCents    := NewCents;
      FNegative := NewNeg and FAllowNegative and (NewCents > 0);
      Key       := #0;
      ValueChanged := True;
    end;
    #1, #3: { Ctrl+A, Ctrl+C — passa para o TEdit }
    begin
      { não bloqueia; TEdit trata nativamente }
    end;
  else
    Key := #0; { bloqueia qualquer outro caractere }
  end;

  if ValueChanged then
  begin
    RefreshDisplay;
    UpdateClearButton;
    if Assigned(FUserOnChange) then
      FUserOnChange(Self);
  end;

  { Dispara o handler do usuário com a tecla original (pode ser #0 para
    as teclas filtradas; isso é esperado em campos totalmente gerenciados) }
  if Assigned(FUserOnKeyPress) then
    FUserOnKeyPress(Sender, SaveKey);
end;

{ --- Value --- }

function TFRMaterialCurrencyEdit.GetValue: Currency;
begin
  Result := Extended(FCents) / Extended(Pow10(FDecimalPlaces));
  if FNegative then Result := -Result;
end;

procedure TFRMaterialCurrencyEdit.SetValue(AValue: Currency);
begin
  FNegative := AValue < 0;
  FCents    := Abs(Round(Extended(AValue) * Pow10(FDecimalPlaces)));
  RefreshDisplay;
  UpdateClearButton;
end;

{ --- Botão de limpeza --- }

function TFRMaterialCurrencyEdit.GetShowClearButton: Boolean;
begin
  Result := FShowClearButton;
end;

procedure TFRMaterialCurrencyEdit.SetShowClearButton(AValue: Boolean);
begin
  if FShowClearButton = AValue then Exit;
  FShowClearButton := AValue;
  UpdateClearButton;
end;

procedure TFRMaterialCurrencyEdit.ClearButtonClick(Sender: TObject);
begin
  Clear;
  FEdit.SetFocus;
  if Assigned(FOnClearButtonClick) then
    FOnClearButtonClick(Self);
end;

procedure TFRMaterialCurrencyEdit.UpdateClearButton;
var
  ShouldShow: Boolean;
begin
  ShouldShow := FShowClearButton and (FCents > 0) and not FEdit.ReadOnly;
  if ShouldShow = FClearButton.Visible then Exit;
  DisableAlign;
  try
    FClearButton.Visible := ShouldShow;
    if ShouldShow then
    begin
      FClearButton.Anchors := [akTop, akRight, akBottom];
      FClearButton.AnchorSide[akRight].Control  := Self;
      FClearButton.AnchorSide[akRight].Side     := asrBottom;
      FClearButton.AnchorSide[akTop].Control    := FEdit;
      FClearButton.AnchorSide[akTop].Side       := asrTop;
      FClearButton.AnchorSide[akBottom].Control := FEdit;
      FClearButton.AnchorSide[akBottom].Side    := asrBottom;
      FClearButton.BorderSpacing.Right := 4;
      FEdit.BorderSpacing.Right := FClearButton.Width + 6;
    end
    else
    begin
      FClearButton.Anchors := [];
      FEdit.BorderSpacing.Right := 4;
    end;
  finally
    EnableAlign;
  end;
  Invalidate;
end;

procedure TFRMaterialCurrencyEdit.Clear;
begin
  FCents    := 0;
  FNegative := False;
  RefreshDisplay;
  UpdateClearButton;
  if Assigned(FUserOnChange) then
    FUserOnChange(Self);
end;

{ --- DecimalPlaces --- }

function TFRMaterialCurrencyEdit.GetDecimalPlaces: Integer;
begin
  Result := FDecimalPlaces;
end;

procedure TFRMaterialCurrencyEdit.SetDecimalPlaces(AValue: Integer);
var
  OldScale, NewScale: Int64;
begin
  if AValue = FDecimalPlaces then Exit;
  AValue := Max(0, Min(4, AValue));
  OldScale := Pow10(FDecimalPlaces);
  NewScale := Pow10(AValue);
  { Rescala FCents para manter o mesmo valor numérico }
  if NewScale > OldScale then
    FCents := FCents * (NewScale div OldScale)
  else
    FCents := FCents div (OldScale div NewScale);
  FDecimalPlaces := AValue;
  RefreshDisplay;
end;

{ --- Getters/Setters de propriedades do TEdit --- }

function TFRMaterialCurrencyEdit.GetAlignment: TAlignment;
begin
  Result := FEdit.Alignment;
end;

procedure TFRMaterialCurrencyEdit.SetAlignment(AValue: TAlignment);
begin
  FEdit.Alignment := AValue;
end;

function TFRMaterialCurrencyEdit.GetAutoSelect: Boolean;
begin
  Result := FEdit.AutoSelect;
end;

procedure TFRMaterialCurrencyEdit.SetAutoSelect(AValue: Boolean);
begin
  FEdit.AutoSelect := AValue;
end;

function TFRMaterialCurrencyEdit.GetEditCursor: TCursor;
begin
  Result := FEdit.Cursor;
end;

procedure TFRMaterialCurrencyEdit.SetEditCursor(AValue: TCursor);
begin
  FEdit.Cursor := AValue;
end;

function TFRMaterialCurrencyEdit.GetEditPopupMenu: TPopupMenu;
begin
  if csDestroying in ComponentState then Exit(nil);
  Result := FEdit.PopupMenu;
end;

procedure TFRMaterialCurrencyEdit.SetEditPopupMenu(AValue: TPopupMenu);
begin
  FEdit.PopupMenu := AValue;
end;

function TFRMaterialCurrencyEdit.GetEditReadOnly: Boolean;
begin
  Result := FEdit.ReadOnly;
end;

procedure TFRMaterialCurrencyEdit.SetEditReadOnly(AValue: Boolean);
begin
  FEdit.ReadOnly := AValue;
  UpdateClearButton;
end;

function TFRMaterialCurrencyEdit.GetEditTabStop: Boolean;
begin
  Result := FEdit.TabStop;
end;

procedure TFRMaterialCurrencyEdit.SetEditTabStop(AValue: Boolean);
begin
  FEdit.TabStop := AValue;
end;

function TFRMaterialCurrencyEdit.GetLabelCaption: TCaption;
begin
  Result := FLabel.Caption;
end;

procedure TFRMaterialCurrencyEdit.SetLabelCaption(const AValue: TCaption);
begin
  FLabel.Caption := AValue;
end;

function TFRMaterialCurrencyEdit.GetLabelSpacing: Integer;
begin
  Result := FLabel.BorderSpacing.Bottom;
end;

procedure TFRMaterialCurrencyEdit.SetLabelSpacing(AValue: Integer);
begin
  if FLabel.BorderSpacing.Bottom = AValue then Exit;
  FLabel.BorderSpacing.Bottom := AValue;
  if not (csLoading in ComponentState) then Self.DoOnResize;
end;

{ --- Getters/Setters de eventos --- }

function TFRMaterialCurrencyEdit.GetOnChange: TNotifyEvent;
begin
  Result := FUserOnChange;
end;

procedure TFRMaterialCurrencyEdit.SetOnChange(AValue: TNotifyEvent);
begin
  FUserOnChange := AValue;
end;

function TFRMaterialCurrencyEdit.GetOnClick: TNotifyEvent;
begin
  Result := FEdit.OnClick;
end;

procedure TFRMaterialCurrencyEdit.SetOnClick(AValue: TNotifyEvent);
begin
  FEdit.OnClick := AValue;
end;

function TFRMaterialCurrencyEdit.GetOnEditingDone: TNotifyEvent;
begin
  Result := FEdit.OnEditingDone;
end;

procedure TFRMaterialCurrencyEdit.SetOnEditingDone(AValue: TNotifyEvent);
begin
  FEdit.OnEditingDone := AValue;
end;

function TFRMaterialCurrencyEdit.GetOnEnter: TNotifyEvent;
begin
  Result := FEdit.OnEnter;
end;

procedure TFRMaterialCurrencyEdit.SetOnEnter(AValue: TNotifyEvent);
begin
  FEdit.OnEnter := AValue;
end;

function TFRMaterialCurrencyEdit.GetOnExit: TNotifyEvent;
begin
  Result := FEdit.OnExit;
end;

procedure TFRMaterialCurrencyEdit.SetOnExit(AValue: TNotifyEvent);
begin
  FEdit.OnExit := AValue;
end;

function TFRMaterialCurrencyEdit.GetOnKeyDown: TKeyEvent;
begin
  Result := FEdit.OnKeyDown;
end;

procedure TFRMaterialCurrencyEdit.SetOnKeyDown(AValue: TKeyEvent);
begin
  FEdit.OnKeyDown := AValue;
end;

function TFRMaterialCurrencyEdit.GetOnKeyPress: TKeyPressEvent;
begin
  Result := FUserOnKeyPress;
end;

procedure TFRMaterialCurrencyEdit.SetOnKeyPress(AValue: TKeyPressEvent);
begin
  FUserOnKeyPress := AValue;
end;

function TFRMaterialCurrencyEdit.GetOnKeyUp: TKeyEvent;
begin
  Result := FEdit.OnKeyUp;
end;

procedure TFRMaterialCurrencyEdit.SetOnKeyUp(AValue: TKeyEvent);
begin
  FEdit.OnKeyUp := AValue;
end;

{ --- Métodos protegidos --- }

function TFRMaterialCurrencyEdit.IsNeededAdjustSize: Boolean;
begin
  if (Self.Align in [alLeft, alRight, alClient]) then Exit(False);
  if (akTop in Self.Anchors) and (akBottom in Self.Anchors) then Exit(False);
  Result := FEdit.AutoSize;
end;

procedure TFRMaterialCurrencyEdit.SetAnchors(const AValue: TAnchors);
begin
  if Self.Anchors = AValue then Exit;
  inherited SetAnchors(AValue);
  if not (csLoading in ComponentState) then Self.DoOnResize;
end;

procedure TFRMaterialCurrencyEdit.SetColor(AValue: TColor);
begin
  inherited SetColor(AValue);
  FEdit.Color := AValue;
end;

procedure TFRMaterialCurrencyEdit.SetName(const AValue: TComponentName);
begin
  if csDesigning in ComponentState then
  begin
    if (FLabel.Caption = '') or AnsiSameText(FLabel.Caption, Name) then
      FLabel.Caption := 'Valor';
    if (FLabel.Name = '') or AnsiSameText(FLabel.Name, Name) then
      FLabel.Name := AValue + 'SubLabel';
    if (FEdit.Name = '') or AnsiSameText(FEdit.Name, Name) then
      FEdit.Name := AValue + 'SubEdit';
  end;
  inherited SetName(AValue);
end;

procedure TFRMaterialCurrencyEdit.DoEnter;
begin
  inherited DoEnter;
  FFocused := True;
  Invalidate;
end;

procedure TFRMaterialCurrencyEdit.DoExit;
begin
  FFocused := False;
  { Ajusta o sinal: se o valor for zero, garante que não fique negativo }
  if FCents = 0 then FNegative := False;
  Invalidate;
  inherited DoExit;
end;

procedure TFRMaterialCurrencyEdit.DoOnResize;
var
  AutoSizedHeight: LongInt;
begin
  if IsNeededAdjustSize then
  begin
    FEdit.Align := alBottom;
    AutoSizedHeight :=
      FLabel.Height +
      FLabel.BorderSpacing.Around +
      FLabel.BorderSpacing.Bottom +
      FLabel.BorderSpacing.Top +
      FEdit.Height +
      FEdit.BorderSpacing.Around +
      FEdit.BorderSpacing.Bottom +
      FEdit.BorderSpacing.Top;

    if Self.Height <> AutoSizedHeight then
      Self.Height := AutoSizedHeight;
  end else
    FEdit.Align := alClient;

  { Dimensiona o botão; âncoras cuidam do posicionamento }
  if Assigned(FClearButton) then
  begin
    FClearButton.Width  := FEdit.Height - 2;
    FClearButton.Height := FEdit.Height - 2;
  end;

  inherited DoOnResize;
end;

procedure TFRMaterialCurrencyEdit.Paint;
var
  LeftPos, RightPos, FieldTop, CR: Integer;
  DecoColor: TColor;
begin
  inherited Paint;

  if FEdit.Color <> Self.Color then
    FEdit.Color := Self.Color;

  CR := FBorderRadius * 2;
  if FFocused and Self.Enabled then
    DecoColor := AccentColor
  else
    DecoColor := DisabledColor;

  if Assigned(Parent) and (Parent.Color = Color) then
  begin
    LeftPos := FEdit.Left;
    if FClearButton.Visible then
      RightPos := FClearButton.Left + FClearButton.Width
    else
      RightPos := FEdit.Left + FEdit.Width;
  end else
  begin
    LeftPos  := 0;
    RightPos := Width;
  end;

  FieldTop := FEdit.Top - 2;
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

constructor TFRMaterialCurrencyEdit.Create(AOwner: TComponent);
begin
  FEdit  := TEdit.Create(Self);
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

  FEdit.Align                := alBottom;
  FEdit.AutoSize             := True;
  FEdit.AutoSelect           := True;
  FEdit.Alignment            := taRightJustify;
  FEdit.BorderSpacing.Around := 0;
  FEdit.BorderSpacing.Bottom := 4;
  FEdit.BorderSpacing.Left   := 4;
  FEdit.BorderSpacing.Right  := 4;
  FEdit.BorderSpacing.Top    := 0;
  FEdit.BorderStyle          := bsNone;
  FEdit.ParentColor          := True;
  FEdit.Parent               := Self;
  FEdit.ParentFont           := True;
  FEdit.ParentBiDiMode       := True;
  FEdit.ReadOnly             := False;
  FEdit.TabStop              := True;
  FEdit.SetSubComponent(True);

  { Intercepta KeyPress para filtrar entrada; não usa AddHandlerOnKeyPress
    para garantir que Key := #0 chegue à frente de outros handlers }
  FEdit.OnKeyPress := @InternalKeyPress;

  FClearButton := TFRMaterialIconButton.Create(Self);
  FClearButton.IconMode := imClear;
  FClearButton.Width    := 22;
  FClearButton.Height   := 22;
  FClearButton.Visible  := False;
  FClearButton.Parent   := Self;
  FClearButton.OnClick  := @ClearButtonClick;
  FClearButton.SetSubComponent(True);

  { Estado inicial }
  FCents            := 0;
  FNegative         := False;
  FDecimalPlaces    := 2;
  FCurrencySymbol   := 'R$';
  FThousandSeparator := '.';
  FDecimalSeparator  := ',';
  FAllowNegative    := False;
  FUpdating         := False;
  FShowClearButton  := False;
  FVariant          := mvStandard;
  FBorderRadius     := 0;

  RefreshDisplay; { exibe "R$ 0,00" }
end;

end.

unit FRMaterialEdit;

{$mode objfpc}{$H+}

interface

uses
  FRMaterialTheme, FRMaterialIcons, FRMaterialMasks, Classes, Clipbrd, Controls, Dialogs, ExtCtrls, Forms, Graphics,
  {$IFDEF FPC} LCLType, LResources, {$ENDIF} Math, MaskEdit, Menus, StdCtrls, SysUtils;

type

  { Posição do botão de pesquisa }
  TFRButtonPosition = (bpLeft, bpRight);

  { TFRMaterialEditBase }

  generic TFRMaterialEditBase<T> = class(TCustomPanel)
  private
    FAccentColor: TColor;
    FDisabledColor: TColor;
    FLabel: TBoundLabel;
    FFocused: boolean;
    FClearButton: TFRMaterialIconButton;
    FShowClearButton: Boolean;
    FOnClearButtonClick: TNotifyEvent;
    FSearchButton: TFRMaterialIconButton;
    FShowSearchButton: Boolean;
    FOnSearchButtonClick: TNotifyEvent;
    FSearchButtonPosition: TFRButtonPosition;
    FVariant: TFRMaterialVariant;
    FBorderRadius: Integer;
    FIconStrokeWidth: Double;
    FValidationState: TFRValidationState;
    FValidColor: TColor;
    FInvalidColor: TColor;

    { Novos campos — HelperText / ErrorText / Counter }
    FHelperText: string;
    FErrorText: string;
    FShowCharCounter: Boolean;

    { Novos campos — Validação avançada }
    FRequired: Boolean;
    FMinLength: Integer;
    FValidateMode: TFRValidateMode;
    FOnValidate: TFRValidateEvent;

    { Novos campos — Prefixo / Sufixo }
    FPrefixText: string;
    FSuffixText: string;

    { Novos campos — LeadingIcon }
    FLeadingIcon: TFRMaterialIconButton;
    FShowLeadingIcon: Boolean;
    FLeadingIconMode: TFRIconMode;
    FOnLeadingIconClick: TNotifyEvent;

    { Novos campos — PasswordMode }
    FPasswordMode: Boolean;
    FEyeButton: TFRMaterialIconButton;

    { Novos campos — CopyButton }
    FCopyButton: TFRMaterialIconButton;
    FShowCopyButton: Boolean;

    { Novos campos — AutoFocusNext }
    FAutoFocusNext: Boolean;

    function IsNeededAdjustSize: boolean;

    function GetShowClearButton: Boolean;
    procedure SetShowClearButton(AValue: Boolean);
    procedure ClearButtonClick(Sender: TObject);
    procedure InternalEditChange(Sender: TObject);
    procedure UpdateClearButton;
    procedure UpdateRightButtonSpacing;
    function GetShowSearchButton: Boolean;
    procedure SetShowSearchButton(AValue: Boolean);
    procedure SearchButtonClick(Sender: TObject);
    function GetIconStrokeWidth: Double;
    procedure SetIconStrokeWidth(AValue: Double);
    function GetSearchButtonPosition: TFRButtonPosition;
    procedure SetSearchButtonPosition(AValue: TFRButtonPosition);
    procedure AnchorButtons;
    function GetValidationState: TFRValidationState;
    procedure SetValidationState(AValue: TFRValidationState);

    { Novos setters }
    procedure SetHelperText(const AValue: string);
    procedure SetErrorText(const AValue: string);
    procedure SetShowCharCounter(AValue: Boolean);
    procedure SetRequired(AValue: Boolean);
    procedure SetPrefixText(const AValue: string);
    procedure SetSuffixText(const AValue: string);
    procedure SetShowLeadingIcon(AValue: Boolean);
    procedure SetLeadingIconMode(AValue: TFRIconMode);
    procedure LeadingIconClick(Sender: TObject);
    procedure SetPasswordMode(AValue: Boolean);
    procedure EyeButtonClick(Sender: TObject);
    procedure SetShowCopyButton(AValue: Boolean);
    procedure CopyButtonClick(Sender: TObject);

    { Helpers }
    function GetBottomMargin: Integer;
    function GetDisplayHelperText: string;
    procedure InternalValidate;

    function GetOnEditChange: TNotifyEvent;
    function GetOnEditClick: TNotifyEvent;
    function GetOnEditEditingDone: TNotifyEvent;
    function GetOnEditEnter: TNotifyEvent;
    function GetOnEditExit: TNotifyEvent;
    function GetOnEditKeyDown: TKeyEvent;
    function GetOnEditKeyPress: TKeyPressEvent;
    function GetOnEditKeyUp: TKeyEvent;
    function GetOnEditMouseDown: TMouseEvent;
    function GetOnEditMouseEnter: TNotifyEvent;
    function GetOnEditMouseLeave: TNotifyEvent;
    function GetOnEditMouseMove: TMouseMoveEvent;
    function GetOnEditMouseUp: TMouseEvent;
    function GetOnEditMouseWheel: TMouseWheelEvent;
    function GetOnEditMouseWheelDown: TMouseWheelUpDownEvent;
    function GetOnEditMouseWheelUp: TMouseWheelUpDownEvent;
    function GetOnEditUTF8KeyPress: TUTF8KeyPressEvent;

    procedure SetOnEditChange(AValue: TNotifyEvent);
    procedure SetOnEditClick(AValue: TNotifyEvent);
    procedure SetOnEditEditingDone(AValue: TNotifyEvent);
    procedure SetOnEditEnter(AValue: TNotifyEvent);
    procedure SetOnEditExit(AValue: TNotifyEvent);
    procedure SetOnEditKeyDown(AValue: TKeyEvent);
    procedure SetOnEditKeyPress(AValue: TKeyPressEvent);
    procedure SetOnEditKeyUp(AValue: TKeyEvent);
    procedure SetOnEditMouseDown(AValue: TMouseEvent);
    procedure SetOnEditMouseEnter(AValue: TNotifyEvent);
    procedure SetOnEditMouseLeave(AValue: TNotifyEvent);
    procedure SetOnEditMouseMove(AValue: TMouseMoveEvent);
    procedure SetOnEditMouseUp(AValue: TMouseEvent);
    procedure SetOnEditMouseWheel(AValue: TMouseWheelEvent);
    procedure SetOnEditMouseWheelDown(AValue: TMouseWheelUpDownEvent);
    procedure SetOnEditMouseWheelUp(AValue: TMouseWheelUpDownEvent);
    procedure SetOnEditUTF8KeyPress(AValue: TUTF8KeyPressEvent);
  protected
    FEdit: T;

    function GetEditAlignment: TAlignment;
    function GetEditAutoSize: Boolean;
    function GetEditAutoSelect: Boolean;
    function GetEditCharCase: TEditCharCase;
    function GetEditCursor: TCursor;
    function GetEditDoubleBuffered: Boolean;
    function GetEditHideSelection: Boolean;
    function GetEditHint: TTranslateString;
    function GetEditMaxLength: Integer;
    function GetEditParentColor: Boolean;
    function GetEditPopupMenu: TPopupMenu;
    function GetEditReadOnly: Boolean;
    function GetEditShowHint: Boolean;
    function GetEditTag: PtrInt;
    function GetEditTabStop: Boolean;
    function GetEditText: TCaption;
    function GetEditTextHint: TTranslateString;
    function GetLabelCaption: TCaption;
    function GetLabelSpacing: Integer;

    procedure SetAnchors(const AValue: TAnchors); override;
    procedure SetColor(AValue: TColor); override;
    procedure SetEditAlignment(const AValue: TAlignment);
    procedure SetEditAutoSize(AValue: Boolean);
    procedure SetEditAutoSelect(AValue: Boolean);
    procedure SetEditCharCase(AValue: TEditCharCase);
    procedure SetEditCursor(AValue: TCursor);
    procedure SetEditDoubleBuffered(AValue: Boolean);
    procedure SetEditHideSelection(AValue: Boolean);
    procedure SetEditHint(const AValue: TTranslateString);
    procedure SetEditMaxLength(AValue: Integer);
    procedure SetEditParentColor(AValue: Boolean);
    procedure SetEditPopupMenu(AValue: TPopupmenu);
    procedure SetEditReadOnly(AValue: Boolean);
    procedure SetEditShowHint(AValue: Boolean);
    procedure SetEditTag(AValue: PtrInt);
    procedure SetEditTabStop(AValue: Boolean);
    procedure SetEditText(const AValue: TCaption);
    procedure SetEditTextHint(const Avalue: TTranslateString);
    procedure SetLabelCaption(const AValue: TCaption);
    procedure SetLabelSpacing(AValue: Integer);
    procedure SetName(const AValue: TComponentName); override;

    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DoOnResize; override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    { Expõe o botão de limpeza para customização visual }
    property ClearButton: TFRMaterialIconButton read FClearButton;
    { Expõe o botão de pesquisa para customização visual }
    property SearchButton: TFRMaterialIconButton read FSearchButton;
    { Expõe o botão lateral esquerdo (ícone de líder) }
    property LeadingIcon: TFRMaterialIconButton read FLeadingIcon;
    { Expõe o botão de olho (toggle senha) }
    property EyeButton: TFRMaterialIconButton read FEyeButton;
    { Expõe o botão de copiar }
    property CopyButton: TFRMaterialIconButton read FCopyButton;
  published
    property Align;
    property Alignment: TAlignment read GetEditAlignment write SetEditAlignment default taLeftJustify;
    property AccentColor: TColor read FAccentColor write FAccentColor;
    property Anchors;
    property AutoSelect: Boolean read GetEditAutoSelect write SetEditAutoSelect default True;
    property AutoSize: Boolean read GetEditAutoSize write SetEditAutoSize default True;
    property BiDiMode;
    property BorderSpacing;
    property Caption: TCaption read GetLabelCaption write SetLabelCaption;
    property CharCase: TEditCharCase read GetEditCharCase write SetEditCharCase default ecNormal;
    property Color;
    property Constraints;
    property Cursor: TCursor read GetEditCursor write SetEditCursor default crDefault;
    property DisabledColor: TColor read FDisabledColor write FDisabledColor;
    property DoubleBuffered: Boolean read GetEditDoubleBuffered write SetEditDoubleBuffered;
    property EditLabel: TBoundLabel read FLabel;
    property Enabled;
    property Font;
    property HideSelection: Boolean read GetEditHideSelection write SetEditHideSelection default True;
    property Hint: TTranslateString read GetEditHint write SetEditHint;
    property LabelSpacing: Integer read GetLabelSpacing write SetLabelSpacing default 4;
    property MaxLength: Integer read GetEditMaxLength write SetEditMaxLength default 0;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont default False;
    property PopupMenu: TPopupmenu read GetEditPopupMenu write SetEditPopupMenu;
    property ReadOnly: Boolean read GetEditReadOnly write SetEditReadOnly default False;
    { Quando True, exibe um botão "×" à direita do campo ao digitar texto }
    property ShowClearButton: Boolean read GetShowClearButton write SetShowClearButton default False;
    { Quando True, exibe um botão com ícone de lupa ao lado do campo }
    property ShowSearchButton: Boolean read GetShowSearchButton write SetShowSearchButton default False;
    { Posição do botão de pesquisa: bpLeft (esquerda) ou bpRight (direita, padrão) }
    property SearchButtonPosition: TFRButtonPosition read GetSearchButtonPosition write SetSearchButtonPosition default bpRight;
    { Variante visual: sublinhado (mvStandard), preenchido (mvFilled) ou contornado (mvOutlined) }
    property Variant: TFRMaterialVariant read FVariant write FVariant default mvStandard;
    { Raio dos cantos arredondados em pixels; 0 = cantos retos }
    property BorderRadius: Integer read FBorderRadius write FBorderRadius default 0;
    { Espessura do traço dos ícones SVG (0 = usa padrão de cada ícone) }
    property IconStrokeWidth: Double read GetIconStrokeWidth write SetIconStrokeWidth;
    { Estado atual da validação: vsNone (neutro), vsValid (válido), vsInvalid (inválido) }
    property ValidationState: TFRValidationState read GetValidationState write SetValidationState default vsNone;
    { Cor de destaque quando ValidationState = vsValid }
    property ValidColor: TColor read FValidColor write FValidColor default $0000B300;
    { Cor de destaque quando ValidationState = vsInvalid }
    property InvalidColor: TColor read FInvalidColor write FInvalidColor default $000000FF;
    { Texto auxiliar exibido abaixo do campo (oculto quando ErrorText existe e estado é inválido) }
    property HelperText: string read FHelperText write SetHelperText;
    { Texto de erro exibido abaixo do campo quando ValidationState = vsInvalid }
    property ErrorText: string read FErrorText write SetErrorText;
    { Quando True, exibe um contador de caracteres "N/MaxLength" abaixo do campo }
    property ShowCharCounter: Boolean read FShowCharCounter write SetShowCharCounter default False;
    { Quando True, o campo é obrigatório; label exibe asterisco e valida campo vazio }
    property Required: Boolean read FRequired write SetRequired default False;
    { Comprimento mínimo de texto; validado conforme ValidateMode }
    property MinLength: Integer read FMinLength write FMinLength default 0;
    { Modo de validação: vmOnExit (padrão) ou vmOnChange }
    property ValidateMode: TFRValidateMode read FValidateMode write FValidateMode default vmOnExit;
    { Evento de validação personalizada — permite lógica de validação customizada }
    property OnValidate: TFRValidateEvent read FOnValidate write FOnValidate;
    { Texto fixo exibido como prefixo dentro do campo (ex: "R$") }
    property PrefixText: string read FPrefixText write SetPrefixText;
    { Texto fixo exibido como sufixo dentro do campo (ex: "kg") }
    property SuffixText: string read FSuffixText write SetSuffixText;
    { Quando True, exibe um ícone SVG à esquerda do campo }
    property ShowLeadingIcon: Boolean read FShowLeadingIcon write SetShowLeadingIcon default False;
    { Modo do ícone à esquerda (imSearch, imCalendar, etc.) }
    property LeadingIconMode: TFRIconMode read FLeadingIconMode write SetLeadingIconMode default imSearch;
    { Disparado ao clicar no ícone à esquerda }
    property OnLeadingIconClick: TNotifyEvent read FOnLeadingIconClick write FOnLeadingIconClick;
    { Quando True, campo opera em modo senha com botão toggle (olho) }
    property PasswordMode: Boolean read FPasswordMode write SetPasswordMode default False;
    { Quando True, exibe um botão para copiar o texto para a área de transferência }
    property ShowCopyButton: Boolean read FShowCopyButton write SetShowCopyButton default False;
    { Quando True, ao completar máscara/validação o foco avança para o próximo controle }
    property AutoFocusNext: Boolean read FAutoFocusNext write FAutoFocusNext default False;
    property ShowHint: Boolean read GetEditShowHint write SetEditShowHint default False;
    property Tag: PtrInt read GetEditTag write SetEditTag default 0;
    property TabOrder;
    property TabStop: boolean read GetEditTabStop write SetEditTabStop default True;
    property Text: TCaption read GetEditText write SetEditText;
    property TextHint: TTranslateString read GetEditTextHint write SetEditTextHint;
    property Visible;

    property OnChange: TNotifyEvent read GetOnEditChange write SetOnEditChange;
    property OnChangeBounds;
    { Disparado após o usuário clicar no botão de limpeza }
    property OnClearButtonClick: TNotifyEvent read FOnClearButtonClick write FOnClearButtonClick;
    property OnClick: TNotifyEvent read GetOnEditClick write SetOnEditClick;
    property OnEditingDone: TNotifyEvent read GetOnEditEditingDone write SetOnEditEditingDone;
    property OnEnter: TNotifyEvent read GetOnEditEnter write SetOnEditEnter;
    property OnExit: TNotifyEvent read GetOnEditExit write SetOnEditExit;
    property OnKeyDown: TKeyEvent read GetOnEditKeyDown write SetOnEditKeyDown;
    property OnKeyPress: TKeyPressEvent read GetOnEditKeyPress write SetOnEditKeyPress;
    property OnKeyUp: TKeyEvent read GetOnEditKeyUp write SetOnEditKeyUp;
    property OnMouseDown: TMouseEvent read GetOnEditMouseDown write SetOnEditMouseDown;
    property OnMouseEnter: TNotifyEvent read GetOnEditMouseEnter write SetOnEditMouseEnter;
    property OnMouseLeave: TNotifyEvent read GetOnEditMouseLeave write SetOnEditMouseLeave;
    property OnMouseMove: TMouseMoveEvent read GetOnEditMouseMove write SetOnEditMouseMove;
    property OnMouseUp: TMouseEvent read GetOnEditMouseUp write SetOnEditMouseUp;
    property OnMouseWheel: TMouseWheelEvent read GetOnEditMouseWheel write SetOnEditMouseWheel;
    property OnMouseWheelDown: TMouseWheelUpDownEvent read GetOnEditMouseWheelDown write SetOnEditMouseWheelDown;
    property OnMouseWheelUp: TMouseWheelUpDownEvent read GetOnEditMouseWheelUp write SetOnEditMouseWheelUp;
    property OnResize;
    property OnUTF8KeyPress: TUTF8KeyPressEvent read GetOnEditUTF8KeyPress write SetOnEditUTF8KeyPress;
  end;

  { TFRMaterialEdit }

  TFRMaterialEdit = class(specialize TFRMaterialEditBase<TMaskEdit>)
  private
    FTextMask: TFRTextMaskType;
    FApplyingMask: Boolean;
    FUserOnChange: TNotifyEvent;
    FUserOnKeyPress: TKeyPressEvent;

    { Input Filter }
    FInputFilter: TFRInputFilter;
    FAllowedChars: string;

    { Numeric Mask }
    FNumericMask: TFRNumericMaskType;
    FNumericValue: Currency;
    FApplyingNumeric: Boolean;

    { AutoComplete }
    FAutoCompleteItems: TStringList;
    FAutoCompletePopup: TListBox;
    FAutoCompleteEnabled: Boolean;
    FOnAutoCompleteSelect: TNotifyEvent;

    function GetEditMask: string;
    procedure SetEditMask(const AValue: string);
    function GetMaskedText: string;
    function GetEditDragCursor: TCursor;
    function GetEditDragMode: TDragMode;

    function GetOnEditDblClick: TNotifyEvent;
    function GetOnEditDragDrop: TDragDropEvent;
    function GetOnEditDragOver: TDragOverEvent;
    function GetOnEditEndDrag: TEndDragEvent;
    function GetOnEditStartDrag: TStartDragEvent;

    procedure SetEditDragCursor(AValue: TCursor);
    procedure SetEditDragMode(AValue: TDragMode);

    procedure SetOnEditDblClick(AValue: TNotifyEvent);
    procedure SetOnEditDragDrop(AValue: TDragDropEvent);
    procedure SetOnEditDragOver(AValue: TDragOverEvent);
    procedure SetOnEditEndDrag(AValue: TEndDragEvent);
    procedure SetOnEditStartDrag(AValue: TStartDragEvent);

    { Máscara PT-BR }
    function GetTextMask: TFRTextMaskType;
    procedure SetTextMask(AValue: TFRTextMaskType);
    procedure MaskKeyPress(Sender: TObject; var Key: Char);
    procedure MaskChange(Sender: TObject);
    function GetUserOnChange: TNotifyEvent;
    procedure SetUserOnChange(AValue: TNotifyEvent);
    function GetUserOnKeyPress: TKeyPressEvent;
    procedure SetUserOnKeyPress(AValue: TKeyPressEvent);

    { Input Filter }
    procedure SetInputFilter(AValue: TFRInputFilter);
    procedure FilterKeyPress(Sender: TObject; var Key: Char);

    { Numeric Mask }
    procedure SetNumericMask(AValue: TFRNumericMaskType);
    procedure NumericKeyPress(Sender: TObject; var Key: Char);
    procedure NumericChange(Sender: TObject);
    function GetNumericValue: Currency;
    procedure SetNumericValue(AValue: Currency);

    { AutoComplete }
    procedure SetAutoCompleteEnabled(AValue: Boolean);
    procedure AutoCompleteChange(Sender: TObject);
    procedure AutoCompleteKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure AutoCompletePopupClick(Sender: TObject);
    procedure AutoCompletePopupExit(Sender: TObject);
    procedure ShowAutoCompletePopup;
    procedure HideAutoCompletePopup;
  protected
    procedure DoExit; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Lista de itens para auto-completar }
    property AutoCompleteItems: TStringList read FAutoCompleteItems;
  published
    property Align;
    property Alignment;
    property AccentColor;
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property BiDiMode;
    property BorderSpacing;
    property Caption;
    property CharCase;
    property Color;
    property Constraints;
    property Cursor;
    property DisabledColor;
    property DoubleBuffered;
    property DragCursor: TCursor read GetEditDragCursor write SetEditDragCursor default crDrag;
    property DragMode: TDragMode read GetEditDragMode write SetEditDragMode default dmManual;
    property Font;
    property Edit: TMaskEdit read FEdit;
    property EditLabel;
    property EditMask: string read GetEditMask write SetEditMask;
    property Enabled;
    property HideSelection;
    property Hint;
    property LabelSpacing;
    property MaxLength;
    property MaskedText: string read GetMaskedText;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property PopupMenu;
    property ReadOnly;
    property ShowClearButton;
    property ShowSearchButton: Boolean read GetShowSearchButton write SetShowSearchButton default False;
    property SearchButtonPosition;
    { Máscara PT-BR com formatação automática e validação }
    property TextMask: TFRTextMaskType read GetTextMask write SetTextMask default tmtNone;
    { Filtro de entrada: restringe os caracteres que podem ser digitados }
    property InputFilter: TFRInputFilter read FInputFilter write SetInputFilter default ifNone;
    { Caracteres permitidos quando InputFilter = ifCustom (ex: '0123456789.,') }
    property AllowedChars: string read FAllowedChars write FAllowedChars;
    { Máscara numérica com formatação automática (R$, kg, etc.) }
    property NumericMask: TFRNumericMaskType read FNumericMask write SetNumericMask default nmtNone;
    { Valor numérico (Currency) do campo — leitura/escrita direta }
    property NumericValue: Currency read GetNumericValue write SetNumericValue;
    { Quando True, habilita sugestões automáticas baseadas em AutoCompleteItems }
    property AutoCompleteEnabled: Boolean read FAutoCompleteEnabled write SetAutoCompleteEnabled default False;
    { Disparado ao selecionar um item do auto-completar }
    property OnAutoCompleteSelect: TNotifyEvent read FOnAutoCompleteSelect write FOnAutoCompleteSelect;
    property ValidationState;
    property ValidColor;
    property InvalidColor;
    property Variant;
    property BorderRadius;
    property ShowHint;
    property Tag;
    property TabOrder;
    property TabStop;
    property Text;
    property TextHint;
    property Visible;

    property OnChange: TNotifyEvent read GetUserOnChange write SetUserOnChange;
    property OnChangeBounds;
    property OnClearButtonClick;
    property OnSearchButtonClick: TNotifyEvent read FOnSearchButtonClick write FOnSearchButtonClick;
    property OnClick;
    property OnDbClick: TNotifyEvent read GetOnEditDblClick write SetOnEditDblClick;
    property OnDragDrop: TDragDropEvent read GetOnEditDragDrop write SetOnEditDragDrop;
    property OnDragOver: TDragOverEvent read GetOnEditDragOver write SetOnEditDragOver;
    property OnEditingDone;
    property OnEndDrag: TEndDragEvent read GetOnEditEndDrag write SetOnEditEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress: TKeyPressEvent read GetUserOnKeyPress write SetUserOnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnStartDrag: TStartDragEvent read GetOnEditStartDrag write SetOnEditStartDrag;
    property OnUTF8KeyPress;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialedit_icon.lrs}
  {$ENDIF}
  RegisterComponents('BGRA Controls', [TFRMaterialEdit]);
end;

{ TFRMaterialEditBase }

{ --- Botão de limpeza --- }

function TFRMaterialEditBase.GetShowClearButton: Boolean;
begin
  Result := FShowClearButton;
end;

procedure TFRMaterialEditBase.SetShowClearButton(AValue: Boolean);
begin
  if FShowClearButton = AValue then Exit;
  FShowClearButton := AValue;
  UpdateClearButton;
end;

procedure TFRMaterialEditBase.ClearButtonClick(Sender: TObject);
begin
  FEdit.Text := '';
  FEdit.SetFocus;
  if Assigned(FOnClearButtonClick) then
    FOnClearButtonClick(Self);
end;

procedure TFRMaterialEditBase.InternalEditChange(Sender: TObject);
begin
  UpdateClearButton;
  { Validação em tempo real se ValidateMode = vmOnChange }
  if FValidateMode = vmOnChange then
    InternalValidate;
  { Repinta para atualizar o contador de caracteres }
  if FShowCharCounter then
    Invalidate;
end;

procedure TFRMaterialEditBase.UpdateRightButtonSpacing;
begin
  AnchorButtons;
end;

procedure TFRMaterialEditBase.UpdateClearButton;
var
  ShouldShow: Boolean;
begin
  ShouldShow := FShowClearButton and (FEdit.Text <> '') and not FEdit.ReadOnly;
  if ShouldShow = FClearButton.Visible then Exit;

  DisableAlign;
  try
    FClearButton.Visible := ShouldShow;
    UpdateRightButtonSpacing;
  finally
    EnableAlign;
  end;
  Invalidate;
end;

{ --- Botão de pesquisa --- }

function TFRMaterialEditBase.GetShowSearchButton: Boolean;
begin
  Result := FShowSearchButton;
end;

procedure TFRMaterialEditBase.SetShowSearchButton(AValue: Boolean);
begin
  if FShowSearchButton = AValue then Exit;
  FShowSearchButton := AValue;
  DisableAlign;
  try
    FSearchButton.Visible := FShowSearchButton;
    AnchorButtons;
  finally
    EnableAlign;
  end;
  Invalidate;
end;

procedure TFRMaterialEditBase.SearchButtonClick(Sender: TObject);
begin
  if Assigned(FOnSearchButtonClick) then
    FOnSearchButtonClick(Self);
end;

function TFRMaterialEditBase.GetIconStrokeWidth: Double;
begin
  Result := FIconStrokeWidth;
end;

procedure TFRMaterialEditBase.SetIconStrokeWidth(AValue: Double);
begin
  if FIconStrokeWidth = AValue then Exit;
  FIconStrokeWidth := AValue;
  FClearButton.StrokeWidth   := AValue;
  FSearchButton.StrokeWidth  := AValue;
  FLeadingIcon.StrokeWidth   := AValue;
  FEyeButton.StrokeWidth     := AValue;
  FCopyButton.StrokeWidth    := AValue;
  FClearButton.InvalidateCache;
  FSearchButton.InvalidateCache;
  FLeadingIcon.InvalidateCache;
  FEyeButton.InvalidateCache;
  FCopyButton.InvalidateCache;
end;

function TFRMaterialEditBase.GetSearchButtonPosition: TFRButtonPosition;
begin
  Result := FSearchButtonPosition;
end;

procedure TFRMaterialEditBase.SetSearchButtonPosition(AValue: TFRButtonPosition);
begin
  if FSearchButtonPosition = AValue then Exit;
  FSearchButtonPosition := AValue;
  AnchorButtons;
  Invalidate;
end;

procedure TFRMaterialEditBase.AnchorButtons;
var
  LeftSpacing, RightSpacing: Integer;
  RightAnchorCtrl: TControl;
  RightAnchorSide: TAnchorSideReference;
begin
  LeftSpacing  := 4;
  RightSpacing := 4;

  { Limpa âncoras dos botões antes de reconfigurar }
  FClearButton.Anchors  := [];
  FSearchButton.Anchors := [];
  FLeadingIcon.Anchors  := [];
  FEyeButton.Anchors    := [];
  FCopyButton.Anchors   := [];

  { LeadingIcon — sempre à esquerda }
  if FShowLeadingIcon then
  begin
    FLeadingIcon.Anchors := [akLeft, akTop, akBottom];
    FLeadingIcon.AnchorSide[akLeft].Control   := Self;
    FLeadingIcon.AnchorSide[akLeft].Side      := asrTop;
    FLeadingIcon.AnchorSide[akTop].Control    := FEdit;
    FLeadingIcon.AnchorSide[akTop].Side       := asrTop;
    FLeadingIcon.AnchorSide[akBottom].Control := FEdit;
    FLeadingIcon.AnchorSide[akBottom].Side    := asrBottom;
    FLeadingIcon.BorderSpacing.Left := 4;
    Inc(LeftSpacing, FLeadingIcon.Width + 2);
  end;

  { Botão de pesquisa — posição configurável }
  if FShowSearchButton then
  begin
    FSearchButton.Anchors := [akTop, akBottom];
    case FSearchButtonPosition of
      bpLeft:
      begin
        FSearchButton.Anchors := FSearchButton.Anchors + [akLeft];
        if FShowLeadingIcon then
        begin
          FSearchButton.AnchorSide[akLeft].Control := FLeadingIcon;
          FSearchButton.AnchorSide[akLeft].Side    := asrBottom;
        end
        else
        begin
          FSearchButton.AnchorSide[akLeft].Control := Self;
          FSearchButton.AnchorSide[akLeft].Side    := asrTop;
        end;
        FSearchButton.AnchorSide[akTop].Control  := FEdit;
        FSearchButton.AnchorSide[akTop].Side     := asrTop;
        FSearchButton.AnchorSide[akBottom].Control := FEdit;
        FSearchButton.AnchorSide[akBottom].Side    := asrBottom;
        FSearchButton.BorderSpacing.Left := 4;
        Inc(LeftSpacing, FSearchButton.Width + 2);
      end;
      bpRight:
      begin
        FSearchButton.Anchors := FSearchButton.Anchors + [akRight];
        FSearchButton.AnchorSide[akRight].Control := Self;
        FSearchButton.AnchorSide[akRight].Side    := asrBottom;
        FSearchButton.AnchorSide[akTop].Control   := FEdit;
        FSearchButton.AnchorSide[akTop].Side      := asrTop;
        FSearchButton.AnchorSide[akBottom].Control := FEdit;
        FSearchButton.AnchorSide[akBottom].Side    := asrBottom;
        FSearchButton.BorderSpacing.Right := 4;
        Inc(RightSpacing, FSearchButton.Width + 2);
      end;
    end;
  end;

  { Determina referência de âncora direita para botões internos }
  if FShowSearchButton and (FSearchButtonPosition = bpRight) then
  begin
    RightAnchorCtrl := FSearchButton;
    RightAnchorSide := asrTop;
  end
  else
  begin
    RightAnchorCtrl := Self;
    RightAnchorSide := asrBottom;
  end;

  { EyeButton — à direita (antes do search se bpRight) }
  if FPasswordMode and FEyeButton.Visible then
  begin
    FEyeButton.Anchors := [akTop, akRight, akBottom];
    FEyeButton.AnchorSide[akTop].Control    := FEdit;
    FEyeButton.AnchorSide[akTop].Side       := asrTop;
    FEyeButton.AnchorSide[akBottom].Control := FEdit;
    FEyeButton.AnchorSide[akBottom].Side    := asrBottom;
    FEyeButton.AnchorSide[akRight].Control  := RightAnchorCtrl;
    FEyeButton.AnchorSide[akRight].Side     := RightAnchorSide;
    FEyeButton.BorderSpacing.Right := 2;
    Inc(RightSpacing, FEyeButton.Width + 2);
    { Atualiza referência para o próximo botão }
    RightAnchorCtrl := FEyeButton;
    RightAnchorSide := asrTop;
  end;

  { CopyButton — à direita }
  if FShowCopyButton then
  begin
    FCopyButton.Anchors := [akTop, akRight, akBottom];
    FCopyButton.AnchorSide[akTop].Control    := FEdit;
    FCopyButton.AnchorSide[akTop].Side       := asrTop;
    FCopyButton.AnchorSide[akBottom].Control := FEdit;
    FCopyButton.AnchorSide[akBottom].Side    := asrBottom;
    FCopyButton.AnchorSide[akRight].Control  := RightAnchorCtrl;
    FCopyButton.AnchorSide[akRight].Side     := RightAnchorSide;
    FCopyButton.BorderSpacing.Right := 2;
    Inc(RightSpacing, FCopyButton.Width + 2);
    { Atualiza referência para o próximo botão }
    RightAnchorCtrl := FCopyButton;
    RightAnchorSide := asrTop;
  end;

  { Botão de limpeza — sempre à direita, antes dos anteriores }
  if FShowClearButton then
  begin
    FClearButton.Anchors := [akTop, akRight, akBottom];
    FClearButton.AnchorSide[akTop].Control    := FEdit;
    FClearButton.AnchorSide[akTop].Side       := asrTop;
    FClearButton.AnchorSide[akBottom].Control := FEdit;
    FClearButton.AnchorSide[akBottom].Side    := asrBottom;
    FClearButton.AnchorSide[akRight].Control  := RightAnchorCtrl;
    FClearButton.AnchorSide[akRight].Side     := RightAnchorSide;
    FClearButton.BorderSpacing.Right := 2;
    Inc(RightSpacing, FClearButton.Width + 2);
  end;

  FEdit.BorderSpacing.Left  := LeftSpacing;
  FEdit.BorderSpacing.Right := RightSpacing;
end;

function TFRMaterialEditBase.GetValidationState: TFRValidationState;
begin
  Result := FValidationState;
end;

procedure TFRMaterialEditBase.SetValidationState(AValue: TFRValidationState);
begin
  if FValidationState = AValue then Exit;
  FValidationState := AValue;
  Invalidate;
end;

{ --- Novos setters --- }

procedure TFRMaterialEditBase.SetHelperText(const AValue: string);
begin
  if FHelperText = AValue then Exit;
  FHelperText := AValue;
  if not (csLoading in ComponentState) then DoOnResize;
  Invalidate;
end;

procedure TFRMaterialEditBase.SetErrorText(const AValue: string);
begin
  if FErrorText = AValue then Exit;
  FErrorText := AValue;
  if not (csLoading in ComponentState) then DoOnResize;
  Invalidate;
end;

procedure TFRMaterialEditBase.SetShowCharCounter(AValue: Boolean);
begin
  if FShowCharCounter = AValue then Exit;
  FShowCharCounter := AValue;
  if not (csLoading in ComponentState) then DoOnResize;
  Invalidate;
end;

procedure TFRMaterialEditBase.SetRequired(AValue: Boolean);
begin
  if FRequired = AValue then Exit;
  FRequired := AValue;
  Invalidate;
end;

procedure TFRMaterialEditBase.SetPrefixText(const AValue: string);
begin
  if FPrefixText = AValue then Exit;
  FPrefixText := AValue;
  Invalidate;
end;

procedure TFRMaterialEditBase.SetSuffixText(const AValue: string);
begin
  if FSuffixText = AValue then Exit;
  FSuffixText := AValue;
  Invalidate;
end;

procedure TFRMaterialEditBase.SetShowLeadingIcon(AValue: Boolean);
begin
  if FShowLeadingIcon = AValue then Exit;
  FShowLeadingIcon := AValue;
  DisableAlign;
  try
    FLeadingIcon.Visible := FShowLeadingIcon;
    AnchorButtons;
  finally
    EnableAlign;
  end;
  Invalidate;
end;

procedure TFRMaterialEditBase.SetLeadingIconMode(AValue: TFRIconMode);
begin
  if FLeadingIconMode = AValue then Exit;
  FLeadingIconMode := AValue;
  FLeadingIcon.IconMode := AValue;
  FLeadingIcon.InvalidateCache;
end;

procedure TFRMaterialEditBase.LeadingIconClick(Sender: TObject);
begin
  if Assigned(FOnLeadingIconClick) then
    FOnLeadingIconClick(Self);
end;

procedure TFRMaterialEditBase.SetPasswordMode(AValue: Boolean);
begin
  if FPasswordMode = AValue then Exit;
  FPasswordMode := AValue;
  DisableAlign;
  try
    FEyeButton.Visible := FPasswordMode;
    if FPasswordMode then
    begin
      FEdit.EchoMode := emPassword;
      FEdit.PasswordChar := '*';
      FEyeButton.IconMode := imEyeClosed;
    end
    else
    begin
      FEdit.EchoMode := emNormal;
      FEdit.PasswordChar := #0;
    end;
    AnchorButtons;
  finally
    EnableAlign;
  end;
  Invalidate;
end;

procedure TFRMaterialEditBase.EyeButtonClick(Sender: TObject);
begin
  if FEdit.EchoMode = emPassword then
  begin
    FEdit.EchoMode := emNormal;
    FEdit.PasswordChar := #0;
    FEyeButton.IconMode := imEyeOpen;
  end
  else
  begin
    FEdit.EchoMode := emPassword;
    FEdit.PasswordChar := '*';
    FEyeButton.IconMode := imEyeClosed;
  end;
  FEyeButton.InvalidateCache;
  if FEdit.CanFocus then
    FEdit.SetFocus;
end;

procedure TFRMaterialEditBase.SetShowCopyButton(AValue: Boolean);
begin
  if FShowCopyButton = AValue then Exit;
  FShowCopyButton := AValue;
  DisableAlign;
  try
    FCopyButton.Visible := FShowCopyButton;
    AnchorButtons;
  finally
    EnableAlign;
  end;
  Invalidate;
end;

procedure TFRMaterialEditBase.CopyButtonClick(Sender: TObject);
begin
  Clipboard.AsText := FEdit.Text;
end;

function TFRMaterialEditBase.GetBottomMargin: Integer;
begin
  Result := 0;
  if (FHelperText <> '') or (FErrorText <> '') or FShowCharCounter then
    Result := Canvas.TextHeight('Hg') + 4;
end;

function TFRMaterialEditBase.GetDisplayHelperText: string;
begin
  if (FValidationState = vsInvalid) and (FErrorText <> '') then
    Result := FErrorText
  else
    Result := FHelperText;
end;

procedure TFRMaterialEditBase.InternalValidate;
var
  State: TFRValidationState;
begin
  State := vsNone;

  { Obrigatório }
  if FRequired and (Trim(FEdit.Text) = '') then
    State := vsInvalid
  { MinLength }
  else if (FMinLength > 0) and (Length(FEdit.Text) > 0) and (Length(FEdit.Text) < FMinLength) then
    State := vsInvalid
  { Callback customizado }
  else if Assigned(FOnValidate) then
    FOnValidate(Self, FEdit.Text, State);

  if State <> vsNone then
    ValidationState := State;
end;

{ --- Getters de propriedades do Edit --- }

function TFRMaterialEditBase.GetEditAlignment: TAlignment;
begin
  result := FEdit.Alignment;
end;

function TFRMaterialEditBase.GetEditAutoSize: Boolean;
begin
  result := FEdit.AutoSize;
end;

function TFRMaterialEditBase.GetEditAutoSelect: Boolean;
begin
  result := FEdit.AutoSelect;
end;

function TFRMaterialEditBase.GetEditCharCase: TEditCharCase;
begin
  result := FEdit.CharCase;
end;

function TFRMaterialEditBase.GetEditCursor: TCursor;
begin
  result := FEdit.Cursor;
end;

function TFRMaterialEditBase.GetEditDoubleBuffered: Boolean;
begin
  result := FEdit.DoubleBuffered;
end;

function TFRMaterialEditBase.GetEditHideSelection: Boolean;
begin
  result := FEdit.HideSelection;
end;

function TFRMaterialEditBase.GetEditHint: TTranslateString;
begin
  result := FEdit.Hint;
end;

function TFRMaterialEditBase.GetEditMaxLength: Integer;
begin
  result := FEdit.MaxLength;
end;

function TFRMaterialEditBase.GetEditParentColor: Boolean;
begin
  Result := Self.ParentColor;
end;

function TFRMaterialEditBase.GetEditPopupMenu: TPopupMenu;
begin
  if (csDestroying in ComponentState) then Exit(nil);
  result := FEdit.PopupMenu;
end;

function TFRMaterialEditBase.GetEditReadOnly: Boolean;
begin
  result := FEdit.ReadOnly;
end;

function TFRMaterialEditBase.GetEditShowHint: Boolean;
begin
  result := FEdit.ShowHint;
end;

function TFRMaterialEditBase.GetEditTag: PtrInt;
begin
  result := FEdit.Tag;
end;

function TFRMaterialEditBase.GetEditTabStop: Boolean;
begin
  result := FEdit.TabStop;
end;

function TFRMaterialEditBase.GetEditText: TCaption;
begin
  result := FEdit.Text;
end;

function TFRMaterialEditBase.GetEditTextHint: TCaption;
begin
  result := FEdit.TextHint;
end;

function TFRMaterialEditBase.GetLabelCaption: TCaption;
begin
  result := FLabel.Caption
end;

function TFRMaterialEditBase.GetLabelSpacing: Integer;
begin
  result := FLabel.BorderSpacing.Bottom;
end;

{ --- Getters de eventos do Edit --- }

function TFRMaterialEditBase.GetOnEditChange: TNotifyEvent;
begin
  result := FEdit.OnChange;
end;

function TFRMaterialEditBase.GetOnEditClick: TNotifyEvent;
begin
  result := FEdit.OnClick;
end;

function TFRMaterialEditBase.GetOnEditEditingDone: TNotifyEvent;
begin
  result := FEdit.OnEditingDone;
end;

function TFRMaterialEditBase.GetOnEditEnter: TNotifyEvent;
begin
  result := FEdit.OnEnter;
end;

function TFRMaterialEditBase.GetOnEditExit: TNotifyEvent;
begin
  result := FEdit.OnExit;
end;

function TFRMaterialEditBase.GetOnEditKeyDown: TKeyEvent;
begin
  result := FEdit.OnKeyDown;
end;

function TFRMaterialEditBase.GetOnEditKeyPress: TKeyPressEvent;
begin
  result := FEdit.OnKeyPress;
end;

function TFRMaterialEditBase.GetOnEditKeyUp: TKeyEvent;
begin
  result := FEdit.OnKeyUp;
end;

function TFRMaterialEditBase.GetOnEditMouseDown: TMouseEvent;
begin
  result := FEdit.OnMouseDown;
end;

function TFRMaterialEditBase.GetOnEditMouseEnter: TNotifyEvent;
begin
  result := FEdit.OnMouseEnter;
end;

function TFRMaterialEditBase.GetOnEditMouseLeave: TNotifyEvent;
begin
  result := FEdit.OnMouseLeave;
end;

function TFRMaterialEditBase.GetOnEditMouseMove: TMouseMoveEvent;
begin
  result := FEdit.OnMouseMove;
end;

function TFRMaterialEditBase.GetOnEditMouseUp: TMouseEvent;
begin
  result := FEdit.OnMouseUp;
end;

function TFRMaterialEditBase.GetOnEditMouseWheel: TMouseWheelEvent;
begin
  result := FEdit.OnMouseWheel;
end;

function TFRMaterialEditBase.GetOnEditMouseWheelDown: TMouseWheelUpDownEvent;
begin
  result := FEdit.OnMouseWheelDown;
end;

function TFRMaterialEditBase.GetOnEditMouseWheelUp: TMouseWheelUpDownEvent;
begin
  result := FEdit.OnMouseWheelUp;
end;

function TFRMaterialEditBase.GetOnEditUTF8KeyPress: TUTF8KeyPressEvent;
begin
  result := FEdit.OnUTF8KeyPress;
end;

{ --- Setters de eventos do Edit --- }

procedure TFRMaterialEditBase.SetOnEditChange(AValue: TNotifyEvent);
begin
  FEdit.OnChange := AValue;
end;

procedure TFRMaterialEditBase.SetOnEditClick(AValue: TNotifyEvent);
begin
  FEdit.OnClick := AValue;
end;

procedure TFRMaterialEditBase.SetOnEditEditingDone(AValue: TNotifyEvent);
begin
  FEdit.OnEditingDone := AValue;
end;

procedure TFRMaterialEditBase.SetOnEditEnter(AValue: TNotifyEvent);
begin
  FEdit.OnEnter := AValue;
end;

procedure TFRMaterialEditBase.SetOnEditExit(AValue: TNotifyEvent);
begin
  FEdit.OnExit := AValue;
end;

procedure TFRMaterialEditBase.SetOnEditKeyDown(AValue: TKeyEvent);
begin
  FEdit.OnKeyDown := AValue;
end;

procedure TFRMaterialEditBase.SetOnEditKeyPress(AValue: TKeyPressEvent);
begin
  FEdit.OnKeyPress := AValue;
end;

procedure TFRMaterialEditBase.SetOnEditKeyUp(AValue: TKeyEvent);
begin
  FEdit.OnKeyUp := AValue;
end;

procedure TFRMaterialEditBase.SetOnEditMouseDown(AValue: TMouseEvent);
begin
  FEdit.OnMouseDown := AValue;
end;

procedure TFRMaterialEditBase.SetOnEditMouseEnter(AValue: TNotifyEvent);
begin
  FEdit.OnMouseEnter := AValue;
end;

procedure TFRMaterialEditBase.SetOnEditMouseLeave(AValue: TNotifyEvent);
begin
  FEdit.OnMouseLeave := AValue;
end;

procedure TFRMaterialEditBase.SetOnEditMouseMove(AValue: TMouseMoveEvent);
begin
  FEdit.OnMouseMove := AValue;
end;

procedure TFRMaterialEditBase.SetOnEditMouseUp(AValue: TMouseEvent);
begin
  FEdit.OnMouseUp := AValue;
end;

procedure TFRMaterialEditBase.SetOnEditMouseWheel(AValue: TMouseWheelEvent);
begin
  FEdit.OnMouseWheel := AValue;
end;

procedure TFRMaterialEditBase.SetOnEditMouseWheelDown(AValue: TMouseWheelUpDownEvent);
begin
  FEdit.OnMouseWheelDown := AValue;
end;

procedure TFRMaterialEditBase.SetOnEditMouseWheelUp(AValue: TMouseWheelUpDownEvent);
begin
  FEdit.OnMouseWheelUp := AValue;
end;

procedure TFRMaterialEditBase.SetOnEditUTF8KeyPress(AValue: TUTF8KeyPressEvent);
begin
  FEdit.OnUTF8KeyPress := AValue;
end;

{ --- Setters de propriedades do Edit --- }

function TFRMaterialEditBase.IsNeededAdjustSize: boolean;
begin
  if (Self.Align in [alLeft, alRight, alClient]) then Exit(False);
  if (akTop in Self.Anchors) and (akBottom in Self.Anchors) then Exit(False);
  result := FEdit.AutoSize;
end;

procedure TFRMaterialEditBase.SetAnchors(const AValue: TAnchors);
begin
  if (Self.Anchors = AValue) then Exit;
  inherited SetAnchors(AValue);
  if not (csLoading in ComponentState) then
    Self.DoOnResize;
end;

procedure TFRMaterialEditBase.SetColor(AValue: TColor);
begin
  inherited SetColor(AValue);
  FEdit.Color := AValue;
end;

procedure TFRMaterialEditBase.SetEditAlignment(const AValue: TAlignment);
begin
  FEdit.Alignment := AValue;
end;

procedure TFRMaterialEditBase.SetEditAutoSize(AValue: Boolean);
begin
  if (FEdit.AutoSize = AValue) then Exit;
  FEdit.AutoSize := AValue;
  if not (csLoading in ComponentState) then Self.DoOnResize;
end;

procedure TFRMaterialEditBase.SetEditAutoSelect(AValue: Boolean);
begin
  FEdit.AutoSelect := AValue;
end;

procedure TFRMaterialEditBase.SetEditCharCase(AValue: TEditCharCase);
begin
  FEdit.CharCase := AValue;
end;

procedure TFRMaterialEditBase.SetEditCursor(AValue: TCursor);
begin
  FEdit.Cursor := AValue;
end;

procedure TFRMaterialEditBase.SetEditDoubleBuffered(AValue: Boolean);
begin
  FEdit.DoubleBuffered := AValue;
end;

procedure TFRMaterialEditBase.SetEditHideSelection(AValue: Boolean);
begin
  FEdit.HideSelection := AValue;
end;

procedure TFRMaterialEditBase.SetEditHint(const AValue: TTranslateString);
begin
  FEdit.Hint := AValue;
end;

procedure TFRMaterialEditBase.SetEditMaxLength(AValue: Integer);
begin
  FEdit.MaxLength := AValue;
end;

procedure TFRMaterialEditBase.SetEditParentColor(AValue: Boolean);
begin
  FEdit.ParentColor := AValue;
  FLabel.ParentColor := AValue;
end;

procedure TFRMaterialEditBase.SetEditTabStop(AValue: Boolean);
begin
  FEdit.TabStop := AValue;
end;

procedure TFRMaterialEditBase.SetEditPopupMenu(AValue: TPopupmenu);
begin
  FEdit.PopupMenu := AValue;
end;

procedure TFRMaterialEditBase.SetEditReadOnly(AValue: Boolean);
begin
  FEdit.ReadOnly := AValue;
  UpdateClearButton;
end;

procedure TFRMaterialEditBase.SetEditShowHint(AValue: Boolean);
begin
  FEdit.ShowHint := AValue;
end;

procedure TFRMaterialEditBase.SetEditTag(AValue: PtrInt);
begin
  FEdit.Tag := AValue;
end;

procedure TFRMaterialEditBase.SetEditTextHint(const Avalue: TTranslateString);
begin
  FEdit.TextHint := AValue;
end;

procedure TFRMaterialEditBase.SetEditText(const AValue: TCaption);
begin
  FEdit.Text := AValue;
end;

procedure TFRMaterialEditBase.SetLabelCaption(const AValue: TCaption);
begin
  FLabel.Caption := AValue;
end;

procedure TFRMaterialEditBase.SetLabelSpacing(AValue: Integer);
begin
  if (FLabel.BorderSpacing.Bottom = AValue) then Exit;
  FLabel.BorderSpacing.Bottom := AValue;
  if not (csLoading in ComponentState) then Self.DoOnResize;
end;

procedure TFRMaterialEditBase.SetName(const AValue: TComponentName);
begin
  if (csDesigning in ComponentState) then
  begin
    if (FLabel.Caption = '') or (AnsiSameText(FLabel.Caption, AValue)) then
      FLabel.Caption := 'Label';

    if (FLabel.Name = '') or (AnsiSameText(FLabel.Name, AValue)) then
      FLabel.Name := AValue + 'SubLabel';

    if (FEdit.Text = '') or (AnsiSameText(FEdit.Text, AValue)) then
      FEdit.Text := AValue;

    if (FEdit.Name = '') or (AnsiSameText(FEdit.Name, AValue)) then
      FEdit.Name := AValue + 'SubEdit';
  end;
  inherited SetName(AValue);
end;

procedure TFRMaterialEditBase.DoEnter;
begin
  inherited DoEnter;
  FFocused := True;
  Invalidate;
end;

procedure TFRMaterialEditBase.DoExit;
begin
  FFocused := False;
  { Validação interna no DoExit base — Required, MinLength, OnValidate }
  if FValidateMode = vmOnExit then
    InternalValidate;
  Invalidate;
  inherited DoExit;
end;

procedure TFRMaterialEditBase.DoOnResize;
var
  AutoSizedHeight: longint;
  BottomExtra, BtnSize: Integer;
begin
  BottomExtra := GetBottomMargin;

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
      FEdit.BorderSpacing.Top +
      BottomExtra;

    if Self.Height <> AutoSizedHeight then
      Self.Height := AutoSizedHeight;
  end else
  begin
    FEdit.Align := alClient;
  end;

  { Dimensiona os botões proporcionais ao Edit; âncoras cuidam do posicionamento }
  BtnSize := FEdit.Height - 2;
  if BtnSize < 8 then BtnSize := 8;

  if Assigned(FSearchButton) then
  begin
    FSearchButton.Width  := BtnSize;
    FSearchButton.Height := BtnSize;
  end;
  if Assigned(FClearButton) then
  begin
    FClearButton.Width  := BtnSize;
    FClearButton.Height := BtnSize;
  end;
  if Assigned(FLeadingIcon) then
  begin
    FLeadingIcon.Width  := BtnSize;
    FLeadingIcon.Height := BtnSize;
  end;
  if Assigned(FEyeButton) then
  begin
    FEyeButton.Width  := BtnSize;
    FEyeButton.Height := BtnSize;
  end;
  if Assigned(FCopyButton) then
  begin
    FCopyButton.Width  := BtnSize;
    FCopyButton.Height := BtnSize;
  end;

  inherited DoOnResize;
end;

procedure TFRMaterialEditBase.Paint;
var
  LeftPos, RightPos, FieldTop, CR, DecoBottom, BottomExtra: Integer;
  DecoColor, HelperColor: TColor;
  HelperStr, CounterStr, LblCap: string;
  PrefixW: Integer;
begin
  inherited Paint;

  { Sync internal edit color with container }
  if FEdit.Color <> Self.Color then
    FEdit.Color := Self.Color;

  CR := FBorderRadius * 2;
  BottomExtra := GetBottomMargin;
  DecoBottom := Height - BottomExtra;

  { Prioridade: validação > foco > inativo }
  case FValidationState of
    vsValid:   DecoColor := FValidColor;
    vsInvalid: DecoColor := FInvalidColor;
  else
    if FFocused and Self.Enabled then
      DecoColor := AccentColor
    else
      DecoColor := DisabledColor;
  end;

  { Extensão horizontal do sublinhado/borda }
  if Assigned(Parent) and (Parent.Color = Color) then
  begin
    LeftPos := FEdit.Left;
    { Estende até cobrir a área dos botões de ação quando visíveis }
    if FSearchButton.Visible then
      RightPos := FSearchButton.Left + FSearchButton.Width
    else if FClearButton.Visible then
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

  { Passo 1: preenchimento do fundo }
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

  { Passo 2: cor do label e decoração do campo }
  Canvas.Pen.Color  := DecoColor;

  { Label — mostra asterisco quando Required }
  LblCap := FLabel.Caption;
  if FRequired then
  begin
    if (LblCap <> '') and (LblCap[Length(LblCap)] <> '*') then
      FLabel.Font.Color := DecoColor
    else
      FLabel.Font.Color := DecoColor;
  end
  else
    FLabel.Font.Color := DecoColor;

  { Atualiza cor dos ícones SVG dos botões de ação conforme o estado de foco }
  if FSearchButton.Visible and (FSearchButton.NormalColor <> DecoColor) then
  begin
    FSearchButton.NormalColor := DecoColor;
    FSearchButton.InvalidateCache;
  end;

  case FVariant of
    mvStandard, mvFilled:
    begin
      if FFocused and Self.Enabled then
      begin
        Canvas.Line(LeftPos, DecoBottom - 2, RightPos, DecoBottom - 2);
        Canvas.Line(LeftPos, DecoBottom - 1, RightPos, DecoBottom - 1);
      end else
        Canvas.Line(LeftPos, DecoBottom - 1, RightPos, DecoBottom - 1);
    end;
    mvOutlined:
    begin
      Canvas.Brush.Style := bsClear;
      if FFocused and Self.Enabled then
        Canvas.Pen.Width := 2
      else
        Canvas.Pen.Width := 1;
      if CR > 0 then
        Canvas.RoundRect(LeftPos, FieldTop, RightPos, DecoBottom - 1, CR, CR)
      else
        Canvas.Rectangle(LeftPos, FieldTop, RightPos, DecoBottom - 1);
      Canvas.Pen.Width   := 1;
      Canvas.Brush.Style := bsSolid;
    end;
  end;

  { Passo 3: Required asterisk — desenha "•" vermelho ao lado do label }
  if FRequired then
  begin
    Canvas.Font.Assign(FLabel.Font);
    Canvas.Font.Color := FInvalidColor;
    Canvas.Brush.Style := bsClear;
    Canvas.TextOut(FLabel.Left + Canvas.TextWidth(FLabel.Caption) + 2,
      FLabel.Top, ' *');
    Canvas.Brush.Style := bsSolid;
  end;

  { Passo 4: Prefix / Suffix }
  if FPrefixText <> '' then
  begin
    Canvas.Font.Assign(FEdit.Font);
    Canvas.Font.Color := DisabledColor;
    Canvas.Brush.Style := bsClear;
    PrefixW := Canvas.TextWidth(FPrefixText + ' ');
    Canvas.TextOut(FEdit.Left - PrefixW, FEdit.Top + (FEdit.Height - Canvas.TextHeight(FPrefixText)) div 2,
      FPrefixText);
    Canvas.Brush.Style := bsSolid;
  end;

  if FSuffixText <> '' then
  begin
    Canvas.Font.Assign(FEdit.Font);
    Canvas.Font.Color := DisabledColor;
    Canvas.Brush.Style := bsClear;
    Canvas.TextOut(FEdit.Left + FEdit.Width + 2,
      FEdit.Top + (FEdit.Height - Canvas.TextHeight(FSuffixText)) div 2,
      FSuffixText);
    Canvas.Brush.Style := bsSolid;
  end;

  { Passo 5: Helper text / Error text (abaixo da decoração) }
  if BottomExtra > 0 then
  begin
    HelperStr := GetDisplayHelperText;
    if FValidationState = vsInvalid then
      HelperColor := FInvalidColor
    else if FValidationState = vsValid then
      HelperColor := FValidColor
    else
      HelperColor := DisabledColor;

    Canvas.Font.Assign(Font);
    Canvas.Font.Size := Font.Size - 1;
    if Canvas.Font.Size < 7 then Canvas.Font.Size := 7;
    Canvas.Brush.Style := bsClear;

    if HelperStr <> '' then
    begin
      Canvas.Font.Color := HelperColor;
      Canvas.TextOut(LeftPos + 4, DecoBottom + 2, HelperStr);
    end;

    { Contador de caracteres }
    if FShowCharCounter and (FEdit.MaxLength > 0) then
    begin
      CounterStr := IntToStr(Length(FEdit.Text)) + '/' + IntToStr(FEdit.MaxLength);
      Canvas.Font.Color := DisabledColor;
      Canvas.TextOut(RightPos - Canvas.TextWidth(CounterStr) - 4,
        DecoBottom + 2, CounterStr);
    end;

    Canvas.Brush.Style := bsSolid;
  end;
end;

constructor TFRMaterialEditBase.Create(AOwner: TComponent);
begin
  FEdit := T.Create(Self);
  FLabel := TBoundLabel.Create(Self);
  inherited Create(AOwner);

  Self.AccentColor := clHighlight;
  Self.BorderStyle := bsNone;
  Self.DisabledColor := $00B8AFA8;
  Self.ParentColor := True;

  FLabel.Align := alTop;
  FLabel.AutoSize := True;
  FLabel.BorderSpacing.Around := 0;
  FLabel.BorderSpacing.Bottom := 4;
  FLabel.BorderSpacing.Left := 4;
  FLabel.BorderSpacing.Right := 4;
  FLabel.BorderSpacing.Top := 4;
  FLabel.Font.Color := $00B8AFA8;
  FLabel.Font.Style := [fsBold];
  FLabel.Parent := Self;
  FLabel.ParentFont := False;
  FLabel.ParentBiDiMode := True;
  FLabel.SetSubComponent(True);

  FEdit.Align := alBottom;
  FEdit.AutoSelect := True;
  FEdit.AutoSize := True;
  FEdit.BorderSpacing.Around := 0;
  FEdit.BorderSpacing.Bottom := 4;
  FEdit.BorderSpacing.Left := 4;
  FEdit.BorderSpacing.Right := 4;
  FEdit.BorderSpacing.Top := 0;
  FEdit.BorderStyle := bsNone;
  FEdit.ParentColor := True;
  FEdit.Font.Color := clBlack;
  FEdit.Parent := Self;
  FEdit.ParentFont := True;
  FEdit.ParentBiDiMode := True;
  FEdit.TabStop := True;
  FEdit.SetSubComponent(True);

  { Monitora mudanças de texto para mostrar/ocultar o botão de limpeza.
    AddHandlerOnChange é usado para não sobrescrever o OnChange do usuário. }
  FEdit.AddHandlerOnChange(@InternalEditChange);

  { Configura o botão de limpeza — ícone SVG "×" vermelho }
  FClearButton := TFRMaterialIconButton.Create(Self);
  FClearButton.IconMode := imClear;
  FClearButton.Width    := 22;
  FClearButton.Height   := 22;
  FClearButton.Visible  := False;
  FClearButton.Parent   := Self;
  FClearButton.OnClick  := @ClearButtonClick;
  FClearButton.SetSubComponent(True);

  { Configura o botão de pesquisa — ícone SVG de lupa }
  FSearchButton := TFRMaterialIconButton.Create(Self);
  FSearchButton.IconMode    := imSearch;
  FSearchButton.NormalColor := DisabledColor;
  FSearchButton.HoverColor  := AccentColor;
  FSearchButton.Width       := 22;
  FSearchButton.Height      := 22;
  FSearchButton.Visible     := False;
  FSearchButton.Parent      := Self;
  FSearchButton.OnClick     := @SearchButtonClick;
  FSearchButton.SetSubComponent(True);

  { Configura o LeadingIcon — ícone SVG à esquerda }
  FLeadingIcon := TFRMaterialIconButton.Create(Self);
  FLeadingIcon.IconMode    := imSearch;
  FLeadingIcon.NormalColor := DisabledColor;
  FLeadingIcon.HoverColor  := AccentColor;
  FLeadingIcon.Width       := 22;
  FLeadingIcon.Height      := 22;
  FLeadingIcon.Visible     := False;
  FLeadingIcon.Parent      := Self;
  FLeadingIcon.OnClick     := @LeadingIconClick;
  FLeadingIcon.SetSubComponent(True);

  { Configura o EyeButton — toggle senha }
  FEyeButton := TFRMaterialIconButton.Create(Self);
  FEyeButton.IconMode    := imEyeClosed;
  FEyeButton.NormalColor := DisabledColor;
  FEyeButton.HoverColor  := AccentColor;
  FEyeButton.Width       := 22;
  FEyeButton.Height      := 22;
  FEyeButton.Visible     := False;
  FEyeButton.Parent      := Self;
  FEyeButton.OnClick     := @EyeButtonClick;
  FEyeButton.SetSubComponent(True);

  { Configura o CopyButton — copiar texto }
  FCopyButton := TFRMaterialIconButton.Create(Self);
  FCopyButton.IconMode    := imCopy;
  FCopyButton.NormalColor := DisabledColor;
  FCopyButton.HoverColor  := AccentColor;
  FCopyButton.Width       := 22;
  FCopyButton.Height      := 22;
  FCopyButton.Visible     := False;
  FCopyButton.Parent      := Self;
  FCopyButton.OnClick     := @CopyButtonClick;
  FCopyButton.SetSubComponent(True);

  FShowClearButton      := False;
  FShowSearchButton     := False;
  FSearchButtonPosition := bpRight;
  FVariant              := mvStandard;
  FBorderRadius         := 0;
  FIconStrokeWidth      := 0;
  FValidationState      := vsNone;
  FValidColor           := $0000B300;
  FInvalidColor         := $000000FF;

  { Valores padrão — novos campos }
  FHelperText       := '';
  FErrorText        := '';
  FShowCharCounter  := False;
  FRequired         := False;
  FMinLength        := 0;
  FValidateMode     := vmOnExit;
  FPrefixText       := '';
  FSuffixText       := '';
  FShowLeadingIcon  := False;
  FLeadingIconMode  := imSearch;
  FPasswordMode     := False;
  FShowCopyButton   := False;
  FAutoFocusNext    := False;
end;

{ TFRMaterialEdit }

function TFRMaterialEdit.GetEditDragCursor: TCursor;
begin
  result := FEdit.DragCursor;
end;

function TFRMaterialEdit.GetEditDragMode: TDragMode;
begin
  result := FEdit.DragMode;
end;

function TFRMaterialEdit.GetOnEditDblClick: TNotifyEvent;
begin
  result := FEdit.OnDblClick;
end;

function TFRMaterialEdit.GetOnEditDragDrop: TDragDropEvent;
begin
  result := FEdit.OnDragDrop;
end;

function TFRMaterialEdit.GetOnEditDragOver: TDragOverEvent;
begin
  result := FEdit.OnDragOver;
end;

function TFRMaterialEdit.GetOnEditEndDrag: TEndDragEvent;
begin
  result := FEdit.OnEndDrag;
end;

function TFRMaterialEdit.GetOnEditStartDrag: TStartDragEvent;
begin
  result := FEdit.OnStartDrag;
end;

procedure TFRMaterialEdit.SetEditDragCursor(AValue: TCursor);
begin
  FEdit.DragCursor := AValue;
end;

procedure TFRMaterialEdit.SetEditDragMode(AValue: TDragMode);
begin
  FEdit.DragMode := AValue;
end;

procedure TFRMaterialEdit.SetOnEditDblClick(AValue: TNotifyEvent);
begin
  FEdit.OnDblClick := AValue;
end;

procedure TFRMaterialEdit.SetOnEditDragDrop(AValue: TDragDropEvent);
begin
  FEdit.OnDragDrop := AValue;
end;

procedure TFRMaterialEdit.SetOnEditDragOver(AValue: TDragOverEvent);
begin
  FEdit.OnDragOver := AValue;
end;

procedure TFRMaterialEdit.SetOnEditEndDrag(AValue: TEndDragEvent);
begin
  FEdit.OnEndDrag := AValue;
end;

procedure TFRMaterialEdit.SetOnEditStartDrag(AValue: TStartDragEvent);
begin
  FEdit.OnStartDrag := AValue;
end;

{ --- EditMask / MaskedText --- }

function TFRMaterialEdit.GetEditMask: string;
begin
  Result := FEdit.EditMask;
end;

procedure TFRMaterialEdit.SetEditMask(const AValue: string);
begin
  FEdit.EditMask := AValue;
end;

function TFRMaterialEdit.GetMaskedText: string;
begin
  { EditText retorna o texto COM os literais da máscara }
  Result := FEdit.EditText;
end;

{ --- TextMask PT-BR --- }

function TFRMaterialEdit.GetTextMask: TFRTextMaskType;
begin
  Result := FTextMask;
end;

procedure TFRMaterialEdit.SetTextMask(AValue: TFRTextMaskType);
var
  ML: Integer;
begin
  if FTextMask = AValue then Exit;
  FTextMask := AValue;

  if FTextMask <> tmtNone then
  begin
    { Limpa EditMask nativa para não conflitar }
    FEdit.EditMask := '';

    { MaxLength formatado }
    ML := FRMaxLenForMask(FTextMask);
    if ML > 0 then
      FEdit.MaxLength := ML
    else
      FEdit.MaxLength := 0;

    { Intercepta eventos }
    FEdit.OnKeyPress := @MaskKeyPress;
    FEdit.OnChange   := @MaskChange;
  end
  else
  begin
    FEdit.MaxLength  := 0;
    FEdit.OnKeyPress := FUserOnKeyPress;
    FEdit.OnChange   := FUserOnChange;
    FValidationState := vsNone;
  end;
  Invalidate;
end;

function TFRMaterialEdit.GetUserOnChange: TNotifyEvent;
begin
  Result := FUserOnChange;
end;

procedure TFRMaterialEdit.SetUserOnChange(AValue: TNotifyEvent);
begin
  FUserOnChange := AValue;
  { Se a máscara não estiver ativa, configura diretamente no Edit }
  if FTextMask = tmtNone then
    FEdit.OnChange := AValue;
end;

function TFRMaterialEdit.GetUserOnKeyPress: TKeyPressEvent;
begin
  Result := FUserOnKeyPress;
end;

procedure TFRMaterialEdit.SetUserOnKeyPress(AValue: TKeyPressEvent);
begin
  FUserOnKeyPress := AValue;
  if FTextMask = tmtNone then
    FEdit.OnKeyPress := AValue;
end;

procedure TFRMaterialEdit.MaskKeyPress(Sender: TObject; var Key: Char);
begin
  if FTextMask <> tmtNone then
  begin
    if not (Key in ['0'..'9', #8]) then
      Key := #0;
  end;
  if Assigned(FUserOnKeyPress) then
    FUserOnKeyPress(Sender, Key);
end;

procedure TFRMaterialEdit.MaskChange(Sender: TObject);
var
  Digits, Mask, Formatted: string;
  NumDigits: Integer;
begin
  if FApplyingMask then Exit;
  if FTextMask = tmtNone then
  begin
    if Assigned(FUserOnChange) then
      FUserOnChange(Sender);
    Exit;
  end;

  FApplyingMask := True;
  try
    Digits    := FRRemoveNonDigits(FEdit.Text);
    NumDigits := Length(Digits);
    Mask      := FRMaskForDigits(FTextMask, NumDigits);

    if Mask <> '' then
    begin
      Formatted       := FRApplyMaskPattern(Digits, Mask);
      FEdit.Text      := Formatted;
      FEdit.SelStart  := Length(Formatted);
    end;

    { Atualiza estado de validação em tempo real }
    ValidationState := FRValidateMask(FTextMask, FEdit.Text);

    { Atualiza visibilidade do botão de limpeza }
    UpdateClearButton;

    if Assigned(FUserOnChange) then
      FUserOnChange(Sender);

    { AutoFocusNext — avança ao completar a máscara com sucesso }
    if FAutoFocusNext and (ValidationState = vsValid) then
    begin
      if Assigned(Parent) then
        Parent.SelectNext(Self, True, True);
    end;
  finally
    FApplyingMask := False;
  end;
end;

procedure TFRMaterialEdit.DoExit;
var
  State: TFRValidationState;
  Digits: string;
begin
  { Oculta auto-completar }
  HideAutoCompletePopup;

  if FTextMask <> tmtNone then
  begin
    State  := FRValidateMask(FTextMask, FEdit.Text);
    Digits := FRRemoveNonDigits(FEdit.Text);

    if State = vsInvalid then
    begin
      ValidationState := vsInvalid;

      case FTextMask of
        tmtCpfCnpj:
          if Length(Digits) <= 11 then
            MessageDlg('Atenção', 'CPF inválido!', mtWarning, [mbOK], 0)
          else
            MessageDlg('Atenção', 'CNPJ inválido!', mtWarning, [mbOK], 0);
        tmtCep:
          MessageDlg('Atenção', 'CEP inválido!', mtWarning, [mbOK], 0);
        tmtChaveNFe:
          MessageDlg('Atenção', 'Chave NF-e inválida!', mtWarning, [mbOK], 0);
        tmtBoleto:
          MessageDlg('Atenção', 'Código de boleto inválido!', mtWarning, [mbOK], 0);
        tmtTelefone:
          MessageDlg('Atenção', 'Telefone inválido!', mtWarning, [mbOK], 0);
      end;

      if FEdit.CanFocus then
        FEdit.SetFocus;
      Exit; { não chama inherited — mantém foco }
    end;
  end;
  inherited DoExit;
end;

procedure TFRMaterialEdit.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FAutoCompletePopup) then
    FAutoCompletePopup := nil;
end;

constructor TFRMaterialEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTextMask         := tmtNone;
  FApplyingMask     := False;
  FInputFilter      := ifNone;
  FAllowedChars     := '';
  FNumericMask      := nmtNone;
  FNumericValue     := 0;
  FApplyingNumeric  := False;
  FAutoCompleteEnabled := False;
  FAutoCompleteItems := TStringList.Create;
  FAutoCompleteItems.Sorted := True;
  FAutoCompleteItems.Duplicates := dupIgnore;
  FAutoCompletePopup := nil;
end;

destructor TFRMaterialEdit.Destroy;
begin
  HideAutoCompletePopup;
  FreeAndNil(FAutoCompleteItems);
  inherited Destroy;
end;

{ --- InputFilter --- }

procedure TFRMaterialEdit.SetInputFilter(AValue: TFRInputFilter);
begin
  if FInputFilter = AValue then Exit;
  FInputFilter := AValue;
  if FInputFilter <> ifNone then
  begin
    { Não conflita com TextMask — TextMask tem prioridade }
    if FTextMask = tmtNone then
      FEdit.OnKeyPress := @FilterKeyPress;
  end
  else
  begin
    if FTextMask = tmtNone then
      FEdit.OnKeyPress := FUserOnKeyPress;
  end;
end;

procedure TFRMaterialEdit.FilterKeyPress(Sender: TObject; var Key: Char);
begin
  if FInputFilter = ifCustom then
  begin
    if (FAllowedChars <> '') and (Key >= #32) and (Pos(Key, FAllowedChars) = 0) then
      Key := #0;
  end
  else if not FRIsCharAllowed(FInputFilter, Key) then
    Key := #0;

  if Assigned(FUserOnKeyPress) then
    FUserOnKeyPress(Sender, Key);
end;

{ --- NumericMask --- }

procedure TFRMaterialEdit.SetNumericMask(AValue: TFRNumericMaskType);
begin
  if FNumericMask = AValue then Exit;
  FNumericMask := AValue;
  if FNumericMask <> nmtNone then
  begin
    { Desativa TextMask se estava ativa }
    FTextMask := tmtNone;
    FEdit.EditMask := '';
    FEdit.OnKeyPress := @NumericKeyPress;
    FEdit.OnChange   := @NumericChange;
    FEdit.Text := FRFormatNumeric(FNumericMask, 0);
  end
  else
  begin
    FEdit.OnKeyPress := FUserOnKeyPress;
    FEdit.OnChange   := FUserOnChange;
  end;
end;

procedure TFRMaterialEdit.NumericKeyPress(Sender: TObject; var Key: Char);
begin
  if FNumericMask <> nmtNone then
  begin
    if not (Key in ['0'..'9', ',', '-', #8]) then
      Key := #0;
  end;
  if Assigned(FUserOnKeyPress) then
    FUserOnKeyPress(Sender, Key);
end;

procedure TFRMaterialEdit.NumericChange(Sender: TObject);
var
  Val: Currency;
  Formatted: string;
begin
  if FApplyingNumeric then Exit;
  if FNumericMask = nmtNone then
  begin
    if Assigned(FUserOnChange) then FUserOnChange(Sender);
    Exit;
  end;

  FApplyingNumeric := True;
  try
    Val := FRParseNumericText(FEdit.Text);
    FNumericValue := Val;
    Formatted := FRFormatNumeric(FNumericMask, Val);
    FEdit.Text := Formatted;
    FEdit.SelStart := Length(Formatted);
    UpdateClearButton;
    if Assigned(FUserOnChange) then FUserOnChange(Sender);
  finally
    FApplyingNumeric := False;
  end;
end;

function TFRMaterialEdit.GetNumericValue: Currency;
begin
  if FNumericMask <> nmtNone then
    Result := FRParseNumericText(FEdit.Text)
  else
    Result := FNumericValue;
end;

procedure TFRMaterialEdit.SetNumericValue(AValue: Currency);
begin
  FNumericValue := AValue;
  if FNumericMask <> nmtNone then
  begin
    FApplyingNumeric := True;
    try
      FEdit.Text := FRFormatNumeric(FNumericMask, AValue);
    finally
      FApplyingNumeric := False;
    end;
    UpdateClearButton;
  end;
end;

{ --- AutoComplete --- }

procedure TFRMaterialEdit.SetAutoCompleteEnabled(AValue: Boolean);
begin
  if FAutoCompleteEnabled = AValue then Exit;
  FAutoCompleteEnabled := AValue;
  if FAutoCompleteEnabled then
  begin
    FEdit.AddHandlerOnChange(@AutoCompleteChange);
    FEdit.OnKeyDown := @AutoCompleteKeyDown;
  end
  else
  begin
    HideAutoCompletePopup;
  end;
end;

procedure TFRMaterialEdit.AutoCompleteChange(Sender: TObject);
begin
  if not FAutoCompleteEnabled then Exit;
  if FEdit.Text = '' then
  begin
    HideAutoCompletePopup;
    Exit;
  end;
  ShowAutoCompletePopup;
end;

procedure TFRMaterialEdit.AutoCompleteKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
begin
  if not Assigned(FAutoCompletePopup) then Exit;
  if not FAutoCompletePopup.Visible then Exit;

  case Key of
    VK_DOWN:
    begin
      if FAutoCompletePopup.ItemIndex < FAutoCompletePopup.Count - 1 then
        FAutoCompletePopup.ItemIndex := FAutoCompletePopup.ItemIndex + 1;
      Key := 0;
    end;
    VK_UP:
    begin
      if FAutoCompletePopup.ItemIndex > 0 then
        FAutoCompletePopup.ItemIndex := FAutoCompletePopup.ItemIndex - 1;
      Key := 0;
    end;
    VK_RETURN:
    begin
      AutoCompletePopupClick(FAutoCompletePopup);
      Key := 0;
    end;
    VK_ESCAPE:
    begin
      HideAutoCompletePopup;
      Key := 0;
    end;
  end;
end;

procedure TFRMaterialEdit.AutoCompletePopupClick(Sender: TObject);
begin
  if not Assigned(FAutoCompletePopup) then Exit;
  if FAutoCompletePopup.ItemIndex < 0 then Exit;

  FEdit.Text := FAutoCompletePopup.Items[FAutoCompletePopup.ItemIndex];
  FEdit.SelStart := Length(FEdit.Text);
  HideAutoCompletePopup;

  if Assigned(FOnAutoCompleteSelect) then
    FOnAutoCompleteSelect(Self);

  if FEdit.CanFocus then
    FEdit.SetFocus;
end;

procedure TFRMaterialEdit.AutoCompletePopupExit(Sender: TObject);
begin
  HideAutoCompletePopup;
end;

procedure TFRMaterialEdit.ShowAutoCompletePopup;
var
  i, MatchCount: Integer;
  Filter, UpperFilter: string;
  P: TPoint;
begin
  if FAutoCompleteItems.Count = 0 then
  begin
    HideAutoCompletePopup;
    Exit;
  end;

  Filter := FEdit.Text;
  UpperFilter := UpperCase(Filter);

  { Cria o popup sob demanda }
  if not Assigned(FAutoCompletePopup) then
  begin
    FAutoCompletePopup := TListBox.Create(Self);
    FAutoCompletePopup.Visible := False;
    FAutoCompletePopup.OnClick := @AutoCompletePopupClick;
    FAutoCompletePopup.OnExit  := @AutoCompletePopupExit;
    FAutoCompletePopup.FreeNotification(Self);
  end;

  FAutoCompletePopup.Items.BeginUpdate;
  try
    FAutoCompletePopup.Items.Clear;
    for i := 0 to FAutoCompleteItems.Count - 1 do
    begin
      if Pos(UpperFilter, UpperCase(FAutoCompleteItems[i])) > 0 then
        FAutoCompletePopup.Items.Add(FAutoCompleteItems[i]);
    end;
  finally
    FAutoCompletePopup.Items.EndUpdate;
  end;

  MatchCount := FAutoCompletePopup.Items.Count;
  if MatchCount = 0 then
  begin
    HideAutoCompletePopup;
    Exit;
  end;

  { Posiciona abaixo do componente }
  if Assigned(Parent) then
  begin
    FAutoCompletePopup.Parent := Parent;
    P := Point(Self.Left, Self.Top + Self.Height);
    FAutoCompletePopup.SetBounds(P.X, P.Y, Self.Width,
      Min(MatchCount * FAutoCompletePopup.ItemHeight + 4, 150));
    FAutoCompletePopup.Visible := True;
    FAutoCompletePopup.BringToFront;
  end;
end;

procedure TFRMaterialEdit.HideAutoCompletePopup;
begin
  if Assigned(FAutoCompletePopup) then
  begin
    FAutoCompletePopup.Visible := False;
    FAutoCompletePopup.Items.Clear;
  end;
end;

end.

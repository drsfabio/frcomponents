unit FRMaterialEdit;

{$mode objfpc}{$H+}

interface

uses
  FRMaterialTheme, FRMaterialThemeManager, FRMaterialIcons, FRMaterialMasks, FRMaterial3Base,
  FRMaterialFieldPainter, FRMaterialInternalEdits, BGRABitmap, BGRABitmapTypes,
  Classes, Clipbrd, Controls, Dialogs, ExtCtrls, Forms, Graphics,
  {$IFDEF FPC} LCLType, LMessages, LResources, {$ENDIF} Math, MaskEdit, Menus, StdCtrls, SysUtils;

const
  { Altura padrão MD3 do MaterialEdit (igual ao Combo). }
  EDIT_DEFAULT_H = 56;

type

  { Posição do botão de pesquisa }
  TFRButtonPosition = (bpLeft, bpRight);

  { TFRMaterialEditBase }

  generic TFRMaterialEditBase<T> = class(TFRMaterialCustomControl)
  private
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
    FApplyingTheme: Boolean;
    FBorderRadius: Integer;
    FIconStrokeWidth: Double;
    FValidColor: TColor;
    FInvalidColor: TColor;

    { Novos campos — CharCounter }
    FShowCharCounter: Boolean;

    { Novos campos — Validação avançada }
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

    { Novo campo — Locked (campo bloqueado após resultado de pesquisa) }
    FLocked: Boolean;
    FLockedColor: TColor;
    FOriginalReadOnly: Boolean;

    { Controle de diálogos de validação e font auto-sizing }
    FShowValidationDialog: Boolean;
    FAutoFontSize: Boolean;

    { Dimensões dos painéis (Mockup Universal Field) }
    FLeftPanelWidth: Integer;
    FRightPanelWidth: Integer;

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

    procedure SetVariant(AValue: TFRMaterialVariant);
    procedure SetBorderRadius(AValue: Integer);
    procedure SetValidColor(AValue: TColor);
    procedure SetInvalidColor(AValue: TColor);

    { Novos setters }
    procedure SetShowCharCounter(AValue: Boolean);
    procedure SetPrefixText(const AValue: string);
    procedure SetSuffixText(const AValue: string);
    procedure SetShowLeadingIcon(AValue: Boolean);
    procedure SetLeadingIconMode(AValue: TFRIconMode);
    procedure LeadingIconClick(Sender: TObject);
    procedure SetPasswordMode(AValue: Boolean);
    procedure EyeButtonClick(Sender: TObject);
    procedure SetShowCopyButton(AValue: Boolean);
    procedure CopyButtonClick(Sender: TObject);
    procedure SetLocked(AValue: Boolean);

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
    FLabelAnimator: TFRMDFloatingLabelAnimator;

    function GetEditAlignment: TAlignment;
    function GetEditAutoSize: Boolean;
    function GetEditAutoSelect: Boolean;
    function GetEditCharCase: TEditCharCase;
    function GetEditCursor: TCursor;
    function GetEditDoubleBuffered: Boolean;
    function GetEditHideSelection: Boolean;
    function GetEditHint: TTranslateString;
    function GetEditMaxLength: Integer;
    function GetEditNumbersOnly: Boolean;
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
    procedure SetEditNumbersOnly(AValue: Boolean);
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
    procedure Loaded; override;
    procedure Paint; override;
    procedure SetDensity(AValue: TFRMDDensity); override;
    procedure CMEnabledChanged(var Message: TLMessage); message CM_ENABLEDCHANGED;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const AThemeManager: TObject); override;
    { Bloqueia o campo (ReadOnly + visual MD3 locked) }
    procedure Lock;
    { Desbloqueia o campo (editável + visual MD3 normal) }
    procedure Unlock;
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
    property DoubleBuffered: Boolean read GetEditDoubleBuffered write SetEditDoubleBuffered;
    property EditLabel: TBoundLabel read FLabel;
    property Enabled;
    property Font;
    property HideSelection: Boolean read GetEditHideSelection write SetEditHideSelection default True;
    property Hint: TTranslateString read GetEditHint write SetEditHint;
    property LabelSpacing: Integer read GetLabelSpacing write SetLabelSpacing default 4;
    property MaxLength: Integer read GetEditMaxLength write SetEditMaxLength default 0;
    property NumbersOnly: Boolean read GetEditNumbersOnly write SetEditNumbersOnly default False;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont default False;
    property PopupMenu: TPopupmenu read GetEditPopupMenu write SetEditPopupMenu;
    property ReadOnly: Boolean read GetEditReadOnly write SetEditReadOnly default False;
    { Quando True, exibe um botão "×" à direita do campo ao digitar texto }
    property ShowClearButton: Boolean read GetShowClearButton write SetShowClearButton default True;
    { Quando True, exibe um botão com ícone de lupa ao lado do campo }
    property ShowSearchButton: Boolean read GetShowSearchButton write SetShowSearchButton default False;
    { Posição do botão de pesquisa: bpLeft (esquerda) ou bpRight (direita, padrão) }
    property SearchButtonPosition: TFRButtonPosition read GetSearchButtonPosition write SetSearchButtonPosition default bpRight;
    { Variante visual: sublinhado (mvStandard), preenchido (mvFilled) ou contornado (mvOutlined) }
    property Variant: TFRMaterialVariant read FVariant write SetVariant default mvStandard;
    { Raio dos cantos arredondados em pixels; 0 = cantos retos }
    property BorderRadius: Integer read FBorderRadius write SetBorderRadius default 0;
    { Espessura do traço dos ícones SVG (0 = usa padrão de cada ícone) }
    property IconStrokeWidth: Double read GetIconStrokeWidth write SetIconStrokeWidth;
    { Cor de destaque quando ValidationState = vsValid }
    property ValidColor: TColor read FValidColor write SetValidColor default $0000B300;
    { Cor de destaque quando ValidationState = vsInvalid }
    property InvalidColor: TColor read FInvalidColor write SetInvalidColor default $000000FF;
    { Quando True, exibe um contador de caracteres "N/MaxLength" abaixo do campo }
    property ShowCharCounter: Boolean read FShowCharCounter write SetShowCharCounter default False;
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
    { Quando True, campo está bloqueado (ReadOnly + visual MD3 locked) }
    property Locked: Boolean read FLocked write SetLocked default False;
    { Cor de fundo quando Locked = True. Se clNone, usa MD3Colors.SurfaceContainerHigh }
    property LockedColor: TColor read FLockedColor write FLockedColor default clNone;
    { Quando True, exibe MessageDlg ao sair do campo com validação inválida (padrão True) }
    property ShowValidationDialog: Boolean read FShowValidationDialog write FShowValidationDialog default True;
    { Quando True, ajusta Font.Size proporcionalmente à altura do componente (padrão True) }
    property AutoFontSize: Boolean read FAutoFontSize write FAutoFontSize default True;
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

  TFRMaterialEdit = class(specialize TFRMaterialEditBase<TFRInternalMaskEdit>)
  private
    FTextMask: TFRTextMaskType;
    FMaskKind: TFRMaskKind;
    FLocale: TFRLocale;
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
    FAutoCompleteHandlerAdded: Boolean;
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

    { Máscara PT-BR legacy (TFRTextMaskType) }
    function GetTextMask: TFRTextMaskType;
    procedure SetTextMask(AValue: TFRTextMaskType);
    procedure MaskKeyPress(Sender: TObject; var Key: Char);
    procedure MaskChange(Sender: TObject);

    { Mascara via MaskKind + Locale — API unificada com i18n.
      Resolve o pattern em runtime via FRMaskKindPattern e aplica
      direto em FEdit.EditMask. Cada Set re-resolve, suportando
      toggle de Locale sem perder o MaskKind. }
    procedure SetMaskKind(AValue: TFRMaskKind);
    procedure SetLocale(AValue: TFRLocale);
    procedure ApplyMaskKind;
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
    property Edit: TFRInternalMaskEdit read FEdit;
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
    { Máscara PT-BR legacy com formatação automática e validação.
      API nova: use MaskKind + Locale abaixo para formatos i18n. }
    property TextMask: TFRTextMaskType read GetTextMask write SetTextMask default tmtNone;
    { Mascara unificada por tipo semantico + locale. Resolve o pattern
      via FRMaskKindPattern em runtime. Kinds brasileiros (fmkCpfBR,
      fmkCnpjBR, etc.) ignoram Locale; internacionais (fmkPhone, fmkDate,
      fmkTime, fmkPostalCode) respeitam Locale para o layout. }
    property MaskKind: TFRMaskKind read FMaskKind write SetMaskKind default fmkNone;
    { Locale para mascaras internacionais. Default pt-BR. Toggle de
      Locale re-aplica o pattern correspondente ao MaskKind atual. }
    property Locale: TFRLocale read FLocale write SetLocale default locPtBR;
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
    property ParentShowHint;
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
  RegisterComponents('Material Design 3', [TFRMaterialEdit]);
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
  if FLocked then
    Unlock;
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
    
  if Assigned(FLabelAnimator) then
  begin
    if (FLabel.Caption <> '') or (Trim(FEdit.Text) <> '') or FFocused then
      FLabelAnimator.FloatLabel
    else
      FLabelAnimator.InlineLabel;
  end;
  
  { Repinta para atualizar o contador de caracteres e animador }
  if FShowCharCounter then
    FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialEditBase.UpdateRightButtonSpacing;
begin
  AnchorButtons;
end;

procedure TFRMaterialEditBase.UpdateClearButton;
var
  ShouldShow: Boolean;
begin
  ShouldShow := FShowClearButton and (FEdit.Text <> '') and FEdit.Enabled;
  if ShouldShow = FClearButton.Visible then Exit;

  DisableAlign;
  try
    FClearButton.Visible := ShouldShow;
    UpdateRightButtonSpacing;
  finally
    EnableAlign;
  end;
  FRMDSafeInvalidate(Self);
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
  FRMDSafeInvalidate(Self);
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
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialEditBase.AnchorButtons;
var
  LeftCursor, RightCursor, CenterY, FieldH: Integer;
begin
  if csLoading in ComponentState then Exit;

  { Reinicia larguras dos painéis — MD3 spec: 16dp de padding horizontal }
  FLeftPanelWidth  := MD3_FIELD_PADDING_H;
  FRightPanelWidth := MD3_FIELD_PADDING_H;

  LeftCursor  := MD3_FIELD_PADDING_H;
  RightCursor := MD3_FIELD_PADDING_H;

  { Limpa âncoras dos botões antes de reconfigurar }
  FClearButton.Anchors  := [];
  FSearchButton.Anchors := [];
  FLeadingIcon.Anchors  := [];
  FEyeButton.Anchors    := [];
  FCopyButton.Anchors   := [];

  { --- Left Panel Slot --- }
  
  { 1. LeadingIcon }
  if FShowLeadingIcon then
  begin
    FLeadingIcon.Anchors := [akLeft];
    FLeadingIcon.AnchorSide[akLeft].Control := Self;
    FLeadingIcon.AnchorSide[akLeft].Side    := asrTop;
    FLeadingIcon.BorderSpacing.Left := LeftCursor;
    
    LeftCursor := FLeadingIcon.Width + 4;
    Inc(FLeftPanelWidth, FLeadingIcon.Width + 4);
  end;

  { 2. Pesquisa (se na esquerda) }
  if FShowSearchButton and (FSearchButtonPosition = bpLeft) then
  begin
    FSearchButton.Anchors := [akLeft];
    FSearchButton.AnchorSide[akLeft].Control := Self;
    FSearchButton.AnchorSide[akLeft].Side    := asrTop;
    FSearchButton.BorderSpacing.Left := LeftCursor;
    
    Inc(FLeftPanelWidth, FSearchButton.Width + 4);
  end;

  { --- Right Panel Slot --- }
  
  { 1. Pesquisa (se na direita) }
  if FShowSearchButton and (FSearchButtonPosition = bpRight) then
  begin
    FSearchButton.Anchors := [akRight];
    FSearchButton.AnchorSide[akRight].Control := Self;
    FSearchButton.AnchorSide[akRight].Side    := asrBottom;
    FSearchButton.BorderSpacing.Right := RightCursor;

    Inc(RightCursor, FSearchButton.Width + 4);
    Inc(FRightPanelWidth, FSearchButton.Width + 4);
  end;

  { 2. EyeButton (Senha) }
  if FPasswordMode and FEyeButton.Visible then
  begin
    FEyeButton.Anchors := [akRight];
    FEyeButton.AnchorSide[akRight].Control := Self;
    FEyeButton.AnchorSide[akRight].Side    := asrBottom;
    FEyeButton.BorderSpacing.Right := RightCursor;
    
    Inc(RightCursor, FEyeButton.Width + 2);
    Inc(FRightPanelWidth, FEyeButton.Width + 2);
  end;

  { 3. CopyButton }
  if FShowCopyButton then
  begin
    FCopyButton.Anchors := [akRight];
    FCopyButton.AnchorSide[akRight].Control := Self;
    FCopyButton.AnchorSide[akRight].Side    := asrBottom;
    FCopyButton.BorderSpacing.Right := RightCursor;
    
    Inc(RightCursor, FCopyButton.Width + 2);
    Inc(FRightPanelWidth, FCopyButton.Width + 2);
  end;

  { 4. ClearButton }
  if FShowClearButton and FClearButton.Visible then
  begin
    FClearButton.Anchors := [akRight];
    FClearButton.AnchorSide[akRight].Control := Self;
    FClearButton.AnchorSide[akRight].Side    := asrBottom;
    FClearButton.BorderSpacing.Right := RightCursor;
    
    Inc(FRightPanelWidth, FClearButton.Width + 4);
  end;

  { Reserva espaço para Prefix/Suffix dentro do campo.
    MD3 layout: |-- padding --|-- prefix --|-- edit text --|-- suffix --|-- padding --|
    O FieldPainter desenha o prefix em EditLeft - PrefixW, então a margem
    esquerda do edit precisa incluir a largura do prefix. }
  if FPrefixText <> '' then
  begin
    Canvas.Font.Assign(FEdit.Font);
    Inc(FLeftPanelWidth, Canvas.TextWidth(FPrefixText + ' '));
  end;
  if FSuffixText <> '' then
  begin
    Canvas.Font.Assign(FEdit.Font);
    Inc(FRightPanelWidth, Canvas.TextWidth(FSuffixText + ' '));
  end;

  { Aplica as margens calculadas ao painel central (FEdit) }
  FEdit.BorderSpacing.Left  := FLeftPanelWidth;
  FEdit.BorderSpacing.Right := FRightPanelWidth;

  { Centraliza todos os botões visíveis verticalmente no container (excl. BottomMargin) }
  FieldH := Self.Height - GetBottomMargin;
  if FieldH < 1 then FieldH := Self.Height;

  if FLeadingIcon.Visible then
  begin
    CenterY := (FieldH - FLeadingIcon.Height) div 2;
    if CenterY < 0 then CenterY := 0;
    FLeadingIcon.Top := CenterY;
  end;
  if FSearchButton.Visible then
  begin
    CenterY := (FieldH - FSearchButton.Height) div 2;
    if CenterY < 0 then CenterY := 0;
    FSearchButton.Top := CenterY;
  end;
  if FEyeButton.Visible then
  begin
    CenterY := (FieldH - FEyeButton.Height) div 2;
    if CenterY < 0 then CenterY := 0;
    FEyeButton.Top := CenterY;
  end;
  if FCopyButton.Visible then
  begin
    CenterY := (FieldH - FCopyButton.Height) div 2;
    if CenterY < 0 then CenterY := 0;
    FCopyButton.Top := CenterY;
  end;
  if FClearButton.Visible then
  begin
    CenterY := (FieldH - FClearButton.Height) div 2;
    if CenterY < 0 then CenterY := 0;
    FClearButton.Top := CenterY;
  end;
end;

procedure TFRMaterialEditBase.SetShowCharCounter(AValue: Boolean);
begin
  if FShowCharCounter = AValue then Exit;
  FShowCharCounter := AValue;
  if not (csLoading in ComponentState) then DoOnResize;
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialEditBase.SetPrefixText(const AValue: string);
begin
  if FPrefixText = AValue then Exit;
  FPrefixText := AValue;
  AnchorButtons;
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialEditBase.SetSuffixText(const AValue: string);
begin
  if FSuffixText = AValue then Exit;
  FSuffixText := AValue;
  AnchorButtons;
  FRMDSafeInvalidate(Self);
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
  FRMDSafeInvalidate(Self);
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
      FEdit.PasswordChar  := '*';
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
  FRMDSafeInvalidate(Self);
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
    FEdit.PasswordChar  := '*';
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
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialEditBase.CopyButtonClick(Sender: TObject);
begin
  Clipboard.AsText := FEdit.Text;
end;

{ --- Locked (campo bloqueado após resultado de pesquisa) --- }

procedure TFRMaterialEditBase.SetLocked(AValue: Boolean);
begin
  if FLocked = AValue then Exit;
  FLocked := AValue;
  if FLocked then
  begin
    FOriginalReadOnly := FEdit.ReadOnly;
    FEdit.ReadOnly := True;
    FEdit.AutoSelect := False;
    if FLockedColor <> clNone then
      Self.Color := FLockedColor
    else
      Self.Color := MD3Colors.SurfaceContainerHigh;
  end
  else
  begin
    FEdit.ReadOnly := FOriginalReadOnly;
    FEdit.AutoSelect := True;
    if Assigned(FRMaterialDefaultThemeManager) then
    begin
      if FVariant = mvFilled then
        Self.Color := MD3Colors.SurfaceContainerHighest
      else
        Self.Color := MD3Colors.Surface;
    end
    else
      Self.Color := clWhite;
  end;
  UpdateClearButton;
  FRMDSafeInvalidate(Self);
end;

{ --- Enabled/Disabled (estado visual MD3 para campos desabilitados) ---

  Quando o componente fica Enabled := False, espelhamos o visual seguindo o
  padrao Material Design 3: fundo SurfaceDim (tom mais apagado) para deixar
  claro que o campo nao aceita interacao. Borda, label e helper ja sao
  pintados com DisabledColor pelo Paint existente (ver linhas 1583-1587).

  Locked tem precedencia sobre Disabled: se o campo esta Locked, nao
  sobrescrevemos a Self.Color — a semantica do Lock (campo preenchido por
  pesquisa, limpavel apenas via clear) deve permanecer visivel. }
procedure TFRMaterialEditBase.CMEnabledChanged(var Message: TLMessage);
begin
  inherited;
  if not FLocked then
  begin
    if Enabled then
    begin
      if Assigned(FRMaterialDefaultThemeManager) then
      begin
        if FVariant = mvFilled then
          Self.Color := MD3Colors.SurfaceContainerHighest
        else
          Self.Color := MD3Colors.Surface;
      end
      else
        Self.Color := clWhite;
    end
    else
      Self.Color := MD3Colors.SurfaceDim;
  end;
  UpdateClearButton;
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialEditBase.SetVariant(AValue: TFRMaterialVariant);
begin
  if FVariant = AValue then Exit;
  FVariant := AValue;
  { Guard contra reentrancia: ApplyTheme chama SetVariant (via toVariant in
    SyncWithTheme), e se SetVariant chamar ApplyTheme de volta, o corpo
    inteiro de ApplyTheme roda 2x por Edit × N edits = freeze visivel. }
  if (not FApplyingTheme) and Assigned(FRMaterialDefaultThemeManager) then
    ApplyTheme(FRMaterialDefaultThemeManager);
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialEditBase.SetBorderRadius(AValue: Integer);
begin
  if FBorderRadius = AValue then Exit;
  FBorderRadius := AValue;
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialEditBase.SetValidColor(AValue: TColor);
begin
  if FValidColor = AValue then Exit;
  FValidColor := AValue;
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialEditBase.SetInvalidColor(AValue: TColor);
begin
  if FInvalidColor = AValue then Exit;
  FInvalidColor := AValue;
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialEditBase.Lock;
begin
  SetLocked(True);
end;

procedure TFRMaterialEditBase.Unlock;
begin
  SetLocked(False);
end;

function TFRMaterialEditBase.GetBottomMargin: Integer;
var
  SaveSize: Integer;
begin
  Result := 0;
  if (FHelperText <> '') or (FErrorText <> '') or FShowCharCounter then
  begin
    if HandleAllocated then
    begin
      SaveSize := Canvas.Font.Size;
      Canvas.Font.Size := 7;
      Result := Canvas.TextHeight('Hg') + 4;
      Canvas.Font.Size := SaveSize;
    end
    else
      Result := 16;
  end;
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

  { Sempre atualiza o estado — permite restaurar vsNone quando campo é corrigido }
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

function TFRMaterialEditBase.GetEditNumbersOnly: Boolean;
begin
  Result := FEdit.NumbersOnly;
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

procedure TFRMaterialEditBase.SetEditNumbersOnly(AValue: Boolean);
begin
  FEdit.NumbersOnly := AValue;
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

    if (FEdit.Name = '') or (AnsiSameText(FEdit.Name, AValue)) then
    begin
      FEdit.Name := AValue + 'SubEdit';
      FEdit.Text := '';
    end;
  end;
  inherited SetName(AValue);
end;

procedure TFRMaterialEditBase.DoEnter;
begin
  inherited DoEnter;
  FFocused := True;
  if Assigned(FLabelAnimator) then FLabelAnimator.FloatLabel;
  if FSearchButton.Visible then
  begin
    FSearchButton.NormalColor := AccentColor;
    FSearchButton.InvalidateCache;
  end;
  FRMDSafeInvalidate(Self);
  { Redireciona o foco para o edit interno }
  if FEdit.CanFocus then
    FEdit.SetFocus;
end;

procedure TFRMaterialEditBase.DoExit;
begin
  FFocused := False;
  { Validação interna no DoExit base — Required, MinLength, OnValidate }
  if FValidateMode = vmOnExit then
    InternalValidate;
    
  { MD3 floating label: permanece flutuante se há Caption definido,
    mesmo com campo vazio — o TEdit cobre a posição inline, tornando
    o label invisível. Só anima para inline quando não há Caption. }
  if Assigned(FLabelAnimator) then
  begin
    if (FLabel.Caption <> '') or (Trim(FEdit.Text) <> '') then
      FLabelAnimator.FloatLabel
    else
      FLabelAnimator.InlineLabel;
  end;

  if FSearchButton.Visible then
  begin
    FSearchButton.NormalColor := DisabledColor;
    FSearchButton.InvalidateCache;
  end;

  FRMDSafeInvalidate(Self);
  inherited DoExit;
end;

procedure TFRMaterialEditBase.SetDensity(AValue: TFRMDDensity);
var
  NewH: Integer;
begin
  inherited SetDensity(AValue);
  { Ajusta a altura total do container usando baseline fixa,
    da mesma forma que TFRMaterialCombo.SetDensity. }
  NewH := EDIT_DEFAULT_H + MD3DensityDelta(AValue);
  if NewH < 32 then NewH := 32;
  if Height <> NewH then
    Height := NewH;
  if FAutoFontSize then
    FEdit.Font.Size := MD3FontSizeForField(NewH, AValue);
  InvalidatePaintCache;
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialEditBase.DoOnResize;
var
  BtnSize: Integer;
  BottomExtra: Integer;
begin
  BottomExtra := GetBottomMargin;

  { Sempre alBottom para que o FEdit não cubra o label pintado pelo FieldPainter }
  FEdit.Align := alBottom;

  { Reserva espaço inferior para helper/error text e char counter.
    Quando BottomExtra > 0 o FEdit deve terminar acima do DecoBottom
    para não sobrepor o texto de validação pintado pelo FieldPainter. }
  if BottomExtra > 0 then
    FEdit.BorderSpacing.Bottom := BottomExtra + 4
  else
    FEdit.BorderSpacing.Bottom := 4;

  { Dimensiona os botões proporcionais ao campo visível (excl. BottomMargin) }
  BtnSize := (Self.Height - BottomExtra) div 2;
  if BtnSize < 20 then BtnSize := 20;

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

  { Recalcula o layout dos painéis (Left, Center, Right) }
  AnchorButtons;

  { Responsividade: adaptar Font.Size proporcionalmente à altura e densidade.
    Referência MD3: Height 56 → Font.Size 12.  Mínimo 8, máximo 16. }
  if FAutoFontSize then
    FEdit.Font.Size := MD3FontSizeForField(Self.Height, Density);

  inherited DoOnResize;
end;

procedure TFRMaterialEditBase.Paint;
var
  DecoColor, HelperColor: TColor;
  HelperStr, CounterStr: string;
  P: TFRMDFieldPaintParams;
  ActionRightPos: Integer;
begin
  if not FRMDCanPaint(Self) then Exit;
  inherited Paint;

  if not Assigned(FEdit) then Exit;

  { Sync ClearButton visibility with Edit.Enabled state }
  if Assigned(FClearButton) then
    UpdateClearButton;

  { Sync internal edit color with container }
  if FEdit.Color <> Self.Color then
    FEdit.Color := Self.Color;

  { Prioridade: validação > foco > inativo }
  case ValidationState of
    vsValid:   DecoColor := FValidColor;
    vsInvalid: DecoColor := FInvalidColor;
  else
    if FFocused and Self.Enabled then
      DecoColor := AccentColor
    else
      DecoColor := DisabledColor;
  end;

  if ValidationState = vsInvalid then
    HelperColor := FInvalidColor
  else if ValidationState = vsValid then
    HelperColor := FValidColor
  else
    HelperColor := DisabledColor;

  HelperStr  := GetDisplayHelperText;
  CounterStr := '';
  if FShowCharCounter and (FEdit.MaxLength > 0) then
    CounterStr := IntToStr(Length(FEdit.Text)) + '/' + IntToStr(FEdit.MaxLength);

  ActionRightPos := FEdit.Left + FEdit.Width;
  if FSearchButton.Visible then
    ActionRightPos := FSearchButton.Left + FSearchButton.Width
  else if FClearButton.Visible then
    ActionRightPos := FClearButton.Left + FClearButton.Width;

  P.Canvas := Canvas;
  P.Rect := ClientRect;
  P.BgColor := Color;
  if Assigned(Parent) then P.ParentBgColor := Parent.Color else P.ParentBgColor := clNone;

  P.Variant := FVariant;
  P.BorderRadius := FBorderRadius;

  P.DecoColor := DecoColor;
  P.HelperColor := HelperColor;
  P.DisabledColor := DisabledColor;

  P.IsFocused := FFocused;
  P.IsEnabled := Enabled;
  P.IsRequired := Required;
  P.IsLocked := FLocked;

  P.EditLeft := FEdit.Left;
  P.EditTop := FEdit.Top;
  P.EditWidth := FEdit.Width;
  P.EditHeight := FEdit.Height;

  P.LeftPanelWidth := FLeftPanelWidth;
  P.RightPanelWidth := FRightPanelWidth;

  P.ActionRight := ActionRightPos;
  P.BottomMargin := GetBottomMargin;

  P.HelperText := HelperStr;
  P.CharCounterText := CounterStr;
  P.PrefixText := FPrefixText;
  P.SuffixText := FSuffixText;

  P.EditFont := FEdit.Font;
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

constructor TFRMaterialEditBase.Create(AOwner: TComponent);
begin
  FEdit := T.Create(Self);
  FLabel := TBoundLabel.Create(Self);
  inherited Create(AOwner);

  Self.BorderStyle := bsNone;
  Self.ParentColor := True;
  Self.Height := EDIT_DEFAULT_H;
  Self.Width  := 200;

  FRMDRegisterComponent(Self as IFRMaterialComponent);

  FLabel.Align := alNone;
  FLabel.Visible := False; // Hide logic moved to field painter
  FLabel.AutoSize := True;
  FLabel.Top := 4;
  FLabel.BorderSpacing.Around := 0;
  FLabel.BorderSpacing.Bottom := 4;
  FLabel.BorderSpacing.Left := MD3_FIELD_PADDING_H;
  FLabel.BorderSpacing.Right := MD3_FIELD_PADDING_H;
  FLabel.BorderSpacing.Top := 4;
  FLabel.Font.Color := $00B8AFA8;
  FLabel.Font.Style := [fsBold];
  FLabel.Parent := Self;
  FLabel.ParentFont := False;
  FLabel.ParentBiDiMode := True;
  FLabel.SetSubComponent(True);
  
  FLabelAnimator := TFRMDFloatingLabelAnimator.Create(Self);
  FLabelAnimator.SnapTo(1.0); // Safe default until populated

  FEdit.Align := alBottom;
  FEdit.AutoSelect := True;
  FEdit.AutoSize := True;
  FEdit.BorderSpacing.Around := 0;
  FEdit.BorderSpacing.Bottom := 4;
  FEdit.BorderSpacing.Left := MD3_FIELD_PADDING_H;
  FEdit.BorderSpacing.Right := MD3_FIELD_PADDING_H;
  FEdit.BorderSpacing.Top := 0;
  FEdit.BorderStyle := bsNone;
  FEdit.ParentColor := True;
  FEdit.Font.Color := clBlack;
  FEdit.Parent := Self;
  FEdit.ParentFont := True;
  FEdit.ParentBiDiMode := True;
  FEdit.TabStop := True;
  FEdit.SetSubComponent(True);

  { Container não participa do tab order — o foco vai direto para FEdit }
  inherited TabStop := False;

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

  FShowClearButton      := True;
  FShowSearchButton     := False;
  FSearchButtonPosition := bpRight;
  FVariant              := mvStandard;
  FBorderRadius         := 0;
  FIconStrokeWidth      := 0;
  FValidColor           := $0000B300;
  FInvalidColor         := $000000FF;

  { Valores padrão — novos campos }
  FShowCharCounter  := False;
  FMinLength        := 0;
  FValidateMode     := vmOnExit;
  FPrefixText       := '';
  FSuffixText       := '';
  FShowLeadingIcon  := False;
  FLeadingIconMode  := imSearch;
  FPasswordMode     := False;
  FShowCopyButton   := False;
  FAutoFocusNext    := False;
  FLocked           := False;
  FLockedColor      := clNone;
  FOriginalReadOnly := False;
  FShowValidationDialog := True;
  FAutoFontSize     := True;

  FEdit.Text := '';

  { ApplyTheme DEPOIS de todas as inicializacoes de campo. Antes
    estava no inicio do Create e FVariant/FBorderRadius/FShowClearButton
    eram sobrescritos logo apos — deixando o edit "preso" em mvStandard
    independente do Variant do ThemeManager global. }
  if Assigned(FRMaterialDefaultThemeManager) then
    Self.ApplyTheme(FRMaterialDefaultThemeManager)
  else
  begin
    Self.AccentColor   := clHighlight;
    Self.DisabledColor := $00B8AFA8;
  end;
end;

destructor TFRMaterialEditBase.Destroy;
begin
  FRMDUnregisterComponent(Self as IFRMaterialComponent);

  { Zera OnClick/OnChange dos sub-controles ANTES de inherited Destroy.
    inherited cascata-libera os 5 IconButtons (Clear/Search/Leading/Eye/
    Copy) e o FEdit interno via owner chain. Se um evento estiver em fila
    (ex: clique disparado durante fade-out), o handler pode executar em
    self ja meio-destruido — AV. Desconectar os handlers elimina isto. }
  if Assigned(FClearButton)  then FClearButton.OnClick  := nil;
  if Assigned(FSearchButton) then FSearchButton.OnClick := nil;
  if Assigned(FLeadingIcon)  then FLeadingIcon.OnClick  := nil;
  if Assigned(FEyeButton)    then FEyeButton.OnClick    := nil;
  if Assigned(FCopyButton)   then FCopyButton.OnClick   := nil;
  if Assigned(FEdit) then
    FEdit.OnChange := nil;

  if Assigned(FLabelAnimator) then FLabelAnimator.Free;
  inherited Destroy;
end;

procedure TFRMaterialEditBase.Loaded;
begin
  inherited Loaded;
  if Assigned(FRMaterialDefaultThemeManager) then
    ApplyTheme(FRMaterialDefaultThemeManager);
end;

procedure TFRMaterialEditBase.ApplyTheme(const AThemeManager: TObject);
begin
  if FApplyingTheme then Exit;
  FApplyingTheme := True;
  try
  inherited ApplyTheme(AThemeManager);

  if toVariant in SyncWithTheme then
    SetVariant(FRMDGetThemeVariant(AThemeManager));

  FAccentColor := MD3Colors.Primary;
  FDisabledColor := MD3Colors.OnSurfaceVariant;

  { Cores de fundo conforme variante e tema }
  case FVariant of
    mvFilled:   Self.Color := MD3Colors.SurfaceContainerHighest;
    mvOutlined: Self.Color := MD3Colors.Surface;
  else
    Self.ParentColor := True;
  end;

  { Cores de texto — OnSurface contrasta com Surface/Container.
    Explicit em FEdit.Font.Color: ParentFont=True nao propaga confiavelmente
    em runtime quando Self.Font.Color muda via ApplyTheme (LCL snapshota a
    Font no momento do SetParentFont). Sem esta linha, dark mode deixa o
    texto do edit em clBlack hardcoded pelo construtor — invisivel contra
    Surface escuro. }
  Self.Font.Color := MD3Colors.OnSurface;
  FLabel.Font.Color := MD3Colors.OnSurfaceVariant;
  if Assigned(FEdit) then
  begin
    FEdit.Font.Color := MD3Colors.OnSurface;
    { Sync background do Edit interno (TMaskEdit) com o container.
      Sem isto, o miolo do edit fica clWhite (default LCL) enquanto o
      container ja tem cor MD3 — aparece um retangulo branco visivel
      ate o primeiro DoOnResize sincronizar. }
    FEdit.Color := Self.Color;
  end;
  if Assigned(FSearchButton) then
  begin
    FSearchButton.NormalColor := MD3Colors.Primary;
    FSearchButton.HoverColor  := MD3Colors.OnPrimaryContainer;
    FSearchButton.InvalidateCache;
  end;
  if Assigned(FClearButton) then
  begin
    FClearButton.NormalColor := MD3Colors.OnSurfaceVariant;
    FClearButton.HoverColor  := MD3Colors.Error;
    FClearButton.InvalidateCache;
  end;
  if Assigned(FLeadingIcon) then
  begin
    FLeadingIcon.NormalColor := MD3Colors.OnSurfaceVariant;
    FLeadingIcon.HoverColor  := MD3Colors.Primary;
    FLeadingIcon.InvalidateCache;
  end;
  if Assigned(FEyeButton) then
  begin
    FEyeButton.NormalColor := MD3Colors.OnSurfaceVariant;
    FEyeButton.HoverColor  := MD3Colors.Primary;
    FEyeButton.InvalidateCache;
  end;
  if Assigned(FCopyButton) then
  begin
    FCopyButton.NormalColor := MD3Colors.OnSurfaceVariant;
    FCopyButton.HoverColor  := MD3Colors.Primary;
    FCopyButton.InvalidateCache;
  end;
  { Atualiza cor de fundo conforme estado locked }
  if FLocked then
  begin
    if FLockedColor <> clNone then
      Self.Color := FLockedColor
    else
      Self.Color := MD3Colors.SurfaceContainerHigh;
  end;
  FRMDSafeInvalidate(Self);
  finally
    FApplyingTheme := False;
  end;
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
  FRMDSafeInvalidate(Self);
end;

procedure TFRMaterialEdit.SetMaskKind(AValue: TFRMaskKind);
begin
  if FMaskKind = AValue then Exit;
  FMaskKind := AValue;
  ApplyMaskKind;
end;

procedure TFRMaterialEdit.SetLocale(AValue: TFRLocale);
begin
  if FLocale = AValue then Exit;
  FLocale := AValue;
  { Apenas reaplica se tem MaskKind ativo — caso contrario o locale
    eh so informativo e nao altera renderizacao. }
  if FMaskKind <> fmkNone then
    ApplyMaskKind;
end;

procedure TFRMaterialEdit.ApplyMaskKind;
var
  pattern: string;
  maxLen: Integer;
begin
  { Resolve o pattern via library. MaskKind precedence sobre TextMask
    e NumericMask: se o dev set MaskKind, desativamos os outros para
    nao conflitar os handlers de keypress. }
  if FMaskKind = fmkNone then
  begin
    { Limpa a mascara sem mexer nos outros caminhos (TextMask/NumericMask)
      — se eles estavam ativos, continuam funcionando. }
    if (FTextMask = tmtNone) and (FNumericMask = nmtNone) then
    begin
      FEdit.EditMask := '';
      FEdit.MaxLength := 0;
    end;
    Exit;
  end;

  { Desativa os caminhos legacy para evitar conflito de handlers. }
  if FTextMask <> tmtNone then
    FTextMask := tmtNone;
  if FNumericMask <> nmtNone then
    FNumericMask := nmtNone;

  pattern := FRMaskKindPattern(FMaskKind, FLocale);
  maxLen  := FRMaskKindMaxLen(FMaskKind, FLocale);

  { Para kinds brasileiros documentais (CPF/CNPJ/CEP/PIS etc.) usamos
    o FRApplyMaskPattern via handler de KeyPress em vez de EditMask
    nativo — o EditMask do LCL eh rigido e nao auto-completa. }
  FEdit.EditMask := pattern;
  if maxLen > 0 then
    FEdit.MaxLength := maxLen
  else
    FEdit.MaxLength := 0;

  FRMDSafeInvalidate(Self);
end;

function TFRMaterialEdit.GetUserOnChange: TNotifyEvent;
begin
  Result := FUserOnChange;
end;

procedure TFRMaterialEdit.SetUserOnChange(AValue: TNotifyEvent);
begin
  FUserOnChange := AValue;
  { Só atribui diretamente se nenhum interceptor está ativo }
  if (FTextMask = tmtNone) and (FNumericMask = nmtNone) then
    FEdit.OnChange := AValue;
end;

function TFRMaterialEdit.GetUserOnKeyPress: TKeyPressEvent;
begin
  Result := FUserOnKeyPress;
end;

procedure TFRMaterialEdit.SetUserOnKeyPress(AValue: TKeyPressEvent);
begin
  FUserOnKeyPress := AValue;
  { Só atribui diretamente se nenhum interceptor está ativo }
  if (FTextMask = tmtNone) and (FNumericMask = nmtNone) and (FInputFilter = ifNone) then
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
  CanTrap: Boolean;
begin
  { Oculta auto-completar }
  HideAutoCompletePopup;

  { Não travar foco quando o formulário está fechando ou a aplicação encerrando }
  CanTrap := not (csDestroying in ComponentState)
         and not Application.Terminated
         and ((GetParentForm(Self) = nil) or not (csDestroying in GetParentForm(Self).ComponentState));

  if (FTextMask <> tmtNone) and CanTrap then
  begin
    State  := FRValidateMask(FTextMask, FEdit.Text);
    Digits := FRRemoveNonDigits(FEdit.Text);

    if State = vsInvalid then
    begin
      ValidationState := vsInvalid;

      if FShowValidationDialog then
      begin
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
  FMaskKind         := fmkNone;
  FLocale           := locPtBR;
  FApplyingMask     := False;
  FInputFilter      := ifNone;
  FAllowedChars     := '';
  FNumericMask      := nmtNone;
  FNumericValue     := 0;
  FApplyingNumeric  := False;
  FAutoCompleteEnabled := False;
  FAutoCompleteHandlerAdded := False;
  FAutoCompleteItems := TStringList.Create;
  FAutoCompleteItems.Sorted := True;
  FAutoCompleteItems.Duplicates := dupIgnore;
  FAutoCompletePopup := nil;
end;

destructor TFRMaterialEdit.Destroy;
begin
  HideAutoCompletePopup;
  FreeAndNil(FAutoCompleteItems);
  if Assigned(FAutoCompletePopup) then FreeAndNil(FAutoCompletePopup);
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
    if not FAutoCompleteHandlerAdded then
    begin
      FEdit.AddHandlerOnChange(@AutoCompleteChange);
      FAutoCompleteHandlerAdded := True;
    end;
    FEdit.OnKeyDown := @AutoCompleteKeyDown;
  end
  else
  begin
    if FAutoCompleteHandlerAdded then
    begin
      FEdit.RemoveHandlerOnChange(@AutoCompleteChange);
      FAutoCompleteHandlerAdded := False;
    end;
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

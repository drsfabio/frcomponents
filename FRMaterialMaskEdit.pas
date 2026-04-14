unit FRMaterialMaskEdit;

{$mode objfpc}{$H+}

{ TFRMaterialMaskEdit
  Campo de texto com máscara de entrada no estilo Material Design.
  Encapsula TMaskEdit (LCL) com:
    - Label flutuante acima do campo (accentColor no foco)
    - Sublinhado Material Design (linha dupla no foco)
    - Propriedade EditMask compatível com o padrão Delphi/Lazarus
    - Propriedade MaskedText (somente leitura) retorna texto COM os literais da máscara
    - Botão de limpeza opcional (ShowClearButton)
    - Suporte a Variant (mvStandard / mvFilled / mvOutlined) e BorderRadius

  Sintaxe da EditMask (formato: <máscara>;<useLiteral>;<blankChar>):
    0  — dígito obrigatório (0-9)
    9  — dígito ou espaço (opcional)
    #  — dígito, espaço, + ou - (opcional)
    L  — letra obrigatória (A-Z, a-z)
    ?  — letra opcional
    A  — letra ou dígito obrigatório
    a  — letra ou dígito opcional
    C  — qualquer caractere obrigatório
    c  — qualquer caractere opcional
    >  — força maiúsculas a partir daqui
    <  — força minúsculas a partir daqui
    \  — próximo caractere é literal
    !  — preenche da direita para a esquerda

  Exemplos comuns (Brasil):
    "(00) 00000-0000;0;_"    — celular (11 dígitos)
    "(00) 0000-0000;0;_"     — fixo (10 dígitos)
    "000.000.000-00;0;_"     — CPF
    "00.000.000/0000-00;0;_" — CNPJ
    "00/00/0000;0;_"         — data DD/MM/AAAA
    "00000-000;0;_"          — CEP
    "00:00:00;0;_"           — hora HH:MM:SS

  Licença: LGPL v3 — mesma do bgracontrols
}

interface

uses
  FRMaterial3Base, FRMaterialTheme, FRMaterialIcons, FRMaterialFieldPainter, Classes, Controls, ExtCtrls, Forms, Graphics,
  {$IFDEF FPC} LCLType, LResources, {$ENDIF}
  MaskEdit, Menus, StdCtrls, SysUtils;

type

  { TFRMaterialMaskEdit }

  TFRMaterialMaskEdit = class(TCustomPanel, IFRMaterialComponent)
  private
    FAccentColor: TColor;
    FDisabledColor: TColor;
    FLabel: TBoundLabel;
    FMaskEdit: TMaskEdit;
    FFocused: Boolean;
    FVariant: TFRMaterialVariant;
    FBorderRadius: Integer;
    FAutoFontSize: Boolean;
    FClearButton: TFRMaterialIconButton;
    FShowClearButton: Boolean;
    FOnClearButtonClick: TNotifyEvent;

    function IsNeededAdjustSize: Boolean;

    { Botão de limpeza }
    function GetShowClearButton: Boolean;
    procedure SetShowClearButton(AValue: Boolean);
    procedure ClearButtonClick(Sender: TObject);
    procedure InternalEditChange(Sender: TObject);
    procedure UpdateClearButton;

    { Propriedades de TMaskEdit }
    function GetAlignment: TAlignment;
    procedure SetAlignment(AValue: TAlignment);
    function GetAutoSelect: Boolean;
    procedure SetAutoSelect(AValue: Boolean);
    function GetCharCase: TEditCharCase;
    procedure SetCharCase(AValue: TEditCharCase);
    function GetEditCursor: TCursor;
    procedure SetEditCursor(AValue: TCursor);
    function GetEditMask: string;
    procedure SetEditMask(const AValue: string);
    function GetEditPopupMenu: TPopupMenu;
    procedure SetEditPopupMenu(AValue: TPopupMenu);
    function GetEditReadOnly: Boolean;
    procedure SetEditReadOnly(AValue: Boolean);
    function GetEditTabStop: Boolean;
    procedure SetEditTabStop(AValue: Boolean);
    function GetEditText: TCaption;
    procedure SetEditText(const AValue: TCaption);
    function GetEditTextHint: TTranslateString;
    procedure SetEditTextHint(const AValue: TTranslateString);
    function GetHideSelection: Boolean;
    procedure SetHideSelection(AValue: Boolean);
    function GetMaxLength: Integer;
    procedure SetMaxLength(AValue: Integer);
    function GetMaskedText: string;
    function GetLabelCaption: TCaption;
    procedure SetLabelCaption(const AValue: TCaption);
    function GetLabelSpacing: Integer;
    procedure SetLabelSpacing(AValue: Integer);

    { Eventos de TMaskEdit }
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
    destructor Destroy; override;
    procedure ApplyTheme(const AThemeManager: TObject); virtual;
    
  protected
    FLabelAnimator: TFRMDFloatingLabelAnimator;

    { Acesso direto ao TMaskEdit interno para customizações avançadas }
    property MaskEdit: TMaskEdit read FMaskEdit;
    { Botão de limpeza — permite customizar caption, hint, cor, etc. }
    property ClearButton: TFRMaterialIconButton read FClearButton;
    { Texto com os literais da máscara incluídos (ex.: "(11) 98765-4321") }
    property MaskedText: string read GetMaskedText;

  published
    property Align;
    property Alignment: TAlignment read GetAlignment write SetAlignment default taLeftJustify;
    property AccentColor: TColor read FAccentColor write FAccentColor;
    property Anchors;
    property AutoSelect: Boolean read GetAutoSelect write SetAutoSelect default True;
    property BiDiMode;
    property BorderSpacing;
    { Legenda do label flutuante }
    property Caption: TCaption read GetLabelCaption write SetLabelCaption;
    property CharCase: TEditCharCase read GetCharCase write SetCharCase default ecNormal;
    property Color;
    property Constraints;
    property Cursor: TCursor read GetEditCursor write SetEditCursor default crDefault;
    property DisabledColor: TColor read FDisabledColor write FDisabledColor;
    { Label flutuante acima do campo }
    property EditLabel: TBoundLabel read FLabel;
    { Máscara de entrada no formato Delphi/Lazarus.
      Formato: <máscara>;<useLiteral>;<blankChar>
      Exemplos:
        "(00) 00000-0000;0;_"    — celular
        "000.000.000-00;0;_"     — CPF
        "00.000.000/0000-00;0;_" — CNPJ
        "00/00/0000;0;_"         — data DD/MM/AAAA
        "00000-000;0;_"          — CEP }
    property EditMask: string read GetEditMask write SetEditMask;
    property Enabled;
    property Font;
    property HideSelection: Boolean read GetHideSelection write SetHideSelection default True;
    property Hint;
    property LabelSpacing: Integer read GetLabelSpacing write SetLabelSpacing default 4;
    property MaxLength: Integer read GetMaxLength write SetMaxLength default 0;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont default False;
    property PopupMenu: TPopupMenu read GetEditPopupMenu write SetEditPopupMenu;
    property ReadOnly: Boolean read GetEditReadOnly write SetEditReadOnly default False;
    { Exibe botão "×" quando o campo tem texto e não está em ReadOnly }
    property ShowClearButton: Boolean
      read GetShowClearButton write SetShowClearButton default False;
    property AutoFontSize: Boolean read FAutoFontSize write FAutoFontSize default True;
    property ShowHint;
    property ParentShowHint;
    property TabOrder;
    property TabStop: Boolean read GetEditTabStop write SetEditTabStop default True;
    { Texto sem os literais da máscara (somente os caracteres digitados pelo usuário).
      Use MaskedText para obter o valor completo com separadores. }
    property Text: TCaption read GetEditText write SetEditText;
    property TextHint: TTranslateString read GetEditTextHint write SetEditTextHint;
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
    property OnEditingDone: TNotifyEvent read GetOnEditingDone write SetOnEditingDone;
    property OnEnter: TNotifyEvent read GetOnEnter write SetOnEnter;
    property OnExit: TNotifyEvent read GetOnExit write SetOnExit;
    property OnKeyDown: TKeyEvent read GetOnKeyDown write SetOnKeyDown;
    property OnKeyPress: TKeyPressEvent read GetOnKeyPress write SetOnKeyPress;
    property OnKeyUp: TKeyEvent read GetOnKeyUp write SetOnKeyUp;
    property OnResize;
    property OnUTF8KeyPress: TUTF8KeyPressEvent
      read GetOnUTF8KeyPress write SetOnUTF8KeyPress;
  end;

procedure Register;

implementation

uses Math;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialmaskedit_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialMaskEdit]);
end;

{ TFRMaterialMaskEdit }

function TFRMaterialMaskEdit.IsNeededAdjustSize: Boolean;
begin
  if (Self.Align in [alLeft, alRight, alClient]) then Exit(False);
  if (akTop in Self.Anchors) and (akBottom in Self.Anchors) then Exit(False);
  Result := FMaskEdit.AutoSize;
end;

{ --- Botão de limpeza --- }

function TFRMaterialMaskEdit.GetShowClearButton: Boolean;
begin
  Result := FShowClearButton;
end;

procedure TFRMaterialMaskEdit.SetShowClearButton(AValue: Boolean);
begin
  if FShowClearButton = AValue then Exit;
  FShowClearButton := AValue;
  UpdateClearButton;
end;

procedure TFRMaterialMaskEdit.ClearButtonClick(Sender: TObject);
begin
  FMaskEdit.Text := '';
  FMaskEdit.SetFocus;
  if Assigned(FOnClearButtonClick) then
    FOnClearButtonClick(Self);
end;

procedure TFRMaterialMaskEdit.InternalEditChange(Sender: TObject);
begin
  UpdateClearButton;
  if Assigned(FLabelAnimator) then
  begin
    if (Trim(FMaskEdit.Text) <> '') or FFocused then
      FLabelAnimator.FloatLabel
    else
      FLabelAnimator.InlineLabel;
  end;
end;

procedure TFRMaterialMaskEdit.UpdateClearButton;
var
  ShouldShow: Boolean;
begin
  ShouldShow := FShowClearButton
    and (FMaskEdit.Text <> '')
    and not FMaskEdit.ReadOnly;

  if ShouldShow = FClearButton.Visible then Exit;

  DisableAlign;
  try
    FClearButton.Visible := ShouldShow;
    if ShouldShow then
    begin
      FClearButton.Anchors := [akTop, akRight, akBottom];
      FClearButton.AnchorSide[akRight].Control  := Self;
      FClearButton.AnchorSide[akRight].Side     := asrBottom;
      FClearButton.AnchorSide[akTop].Control    := FMaskEdit;
      FClearButton.AnchorSide[akTop].Side       := asrTop;
      FClearButton.AnchorSide[akBottom].Control := FMaskEdit;
      FClearButton.AnchorSide[akBottom].Side    := asrBottom;
      FClearButton.BorderSpacing.Right := 4;
      FMaskEdit.BorderSpacing.Right := FClearButton.Width + 6;
    end
    else
    begin
      FClearButton.Anchors := [];
      FMaskEdit.BorderSpacing.Right := 4;
    end;
  finally
    EnableAlign;
  end;
  Invalidate;
end;

{ --- Getters/Setters de propriedades --- }

function TFRMaterialMaskEdit.GetAlignment: TAlignment;
begin
  Result := FMaskEdit.Alignment;
end;

procedure TFRMaterialMaskEdit.SetAlignment(AValue: TAlignment);
begin
  FMaskEdit.Alignment := AValue;
end;

function TFRMaterialMaskEdit.GetAutoSelect: Boolean;
begin
  Result := FMaskEdit.AutoSelect;
end;

procedure TFRMaterialMaskEdit.SetAutoSelect(AValue: Boolean);
begin
  FMaskEdit.AutoSelect := AValue;
end;

function TFRMaterialMaskEdit.GetCharCase: TEditCharCase;
begin
  Result := FMaskEdit.CharCase;
end;

procedure TFRMaterialMaskEdit.SetCharCase(AValue: TEditCharCase);
begin
  FMaskEdit.CharCase := AValue;
end;

function TFRMaterialMaskEdit.GetEditCursor: TCursor;
begin
  Result := FMaskEdit.Cursor;
end;

procedure TFRMaterialMaskEdit.SetEditCursor(AValue: TCursor);
begin
  FMaskEdit.Cursor := AValue;
end;

function TFRMaterialMaskEdit.GetEditMask: string;
begin
  Result := FMaskEdit.EditMask;
end;

procedure TFRMaterialMaskEdit.SetEditMask(const AValue: string);
begin
  FMaskEdit.EditMask := AValue;
end;

function TFRMaterialMaskEdit.GetEditPopupMenu: TPopupMenu;
begin
  if csDestroying in ComponentState then Exit(nil);
  Result := FMaskEdit.PopupMenu;
end;

procedure TFRMaterialMaskEdit.SetEditPopupMenu(AValue: TPopupMenu);
begin
  FMaskEdit.PopupMenu := AValue;
end;

function TFRMaterialMaskEdit.GetEditReadOnly: Boolean;
begin
  Result := FMaskEdit.ReadOnly;
end;

procedure TFRMaterialMaskEdit.SetEditReadOnly(AValue: Boolean);
begin
  FMaskEdit.ReadOnly := AValue;
  UpdateClearButton;
end;

function TFRMaterialMaskEdit.GetEditTabStop: Boolean;
begin
  Result := FMaskEdit.TabStop;
end;

procedure TFRMaterialMaskEdit.SetEditTabStop(AValue: Boolean);
begin
  FMaskEdit.TabStop := AValue;
end;

function TFRMaterialMaskEdit.GetEditText: TCaption;
begin
  Result := FMaskEdit.Text;
end;

procedure TFRMaterialMaskEdit.SetEditText(const AValue: TCaption);
begin
  FMaskEdit.Text := AValue;
end;

function TFRMaterialMaskEdit.GetEditTextHint: TTranslateString;
begin
  Result := FMaskEdit.TextHint;
end;

procedure TFRMaterialMaskEdit.SetEditTextHint(const AValue: TTranslateString);
begin
  FMaskEdit.TextHint := AValue;
end;

function TFRMaterialMaskEdit.GetHideSelection: Boolean;
begin
  Result := FMaskEdit.HideSelection;
end;

procedure TFRMaterialMaskEdit.SetHideSelection(AValue: Boolean);
begin
  FMaskEdit.HideSelection := AValue;
end;

function TFRMaterialMaskEdit.GetMaxLength: Integer;
begin
  Result := FMaskEdit.MaxLength;
end;

procedure TFRMaterialMaskEdit.SetMaxLength(AValue: Integer);
begin
  FMaskEdit.MaxLength := AValue;
end;

function TFRMaterialMaskEdit.GetMaskedText: string;
begin
  Result := FMaskEdit.EditText;
end;

function TFRMaterialMaskEdit.GetLabelCaption: TCaption;
begin
  Result := FLabel.Caption;
end;

procedure TFRMaterialMaskEdit.SetLabelCaption(const AValue: TCaption);
begin
  FLabel.Caption := AValue;
end;

function TFRMaterialMaskEdit.GetLabelSpacing: Integer;
begin
  Result := FLabel.BorderSpacing.Bottom;
end;

procedure TFRMaterialMaskEdit.SetLabelSpacing(AValue: Integer);
begin
  if FLabel.BorderSpacing.Bottom = AValue then Exit;
  FLabel.BorderSpacing.Bottom := AValue;
  if not (csLoading in ComponentState) then Self.DoOnResize;
end;

{ --- Getters/Setters de eventos --- }

{ OnChange é exposto diretamente via FMaskEdit.OnChange.
  O controle de visibilidade do botão de limpeza usa AddHandlerOnChange
  separadamente, de modo que o OnChange do usuário não é perdido. }
function TFRMaterialMaskEdit.GetOnChange: TNotifyEvent;
begin
  Result := FMaskEdit.OnChange;
end;

procedure TFRMaterialMaskEdit.SetOnChange(AValue: TNotifyEvent);
begin
  FMaskEdit.OnChange := AValue;
end;

function TFRMaterialMaskEdit.GetOnClick: TNotifyEvent;
begin
  Result := FMaskEdit.OnClick;
end;

procedure TFRMaterialMaskEdit.SetOnClick(AValue: TNotifyEvent);
begin
  FMaskEdit.OnClick := AValue;
end;

function TFRMaterialMaskEdit.GetOnEditingDone: TNotifyEvent;
begin
  Result := FMaskEdit.OnEditingDone;
end;

procedure TFRMaterialMaskEdit.SetOnEditingDone(AValue: TNotifyEvent);
begin
  FMaskEdit.OnEditingDone := AValue;
end;

function TFRMaterialMaskEdit.GetOnEnter: TNotifyEvent;
begin
  Result := FMaskEdit.OnEnter;
end;

procedure TFRMaterialMaskEdit.SetOnEnter(AValue: TNotifyEvent);
begin
  FMaskEdit.OnEnter := AValue;
end;

function TFRMaterialMaskEdit.GetOnExit: TNotifyEvent;
begin
  Result := FMaskEdit.OnExit;
end;

procedure TFRMaterialMaskEdit.SetOnExit(AValue: TNotifyEvent);
begin
  FMaskEdit.OnExit := AValue;
end;

function TFRMaterialMaskEdit.GetOnKeyDown: TKeyEvent;
begin
  Result := FMaskEdit.OnKeyDown;
end;

procedure TFRMaterialMaskEdit.SetOnKeyDown(AValue: TKeyEvent);
begin
  FMaskEdit.OnKeyDown := AValue;
end;

function TFRMaterialMaskEdit.GetOnKeyPress: TKeyPressEvent;
begin
  Result := FMaskEdit.OnKeyPress;
end;

procedure TFRMaterialMaskEdit.SetOnKeyPress(AValue: TKeyPressEvent);
begin
  FMaskEdit.OnKeyPress := AValue;
end;

function TFRMaterialMaskEdit.GetOnKeyUp: TKeyEvent;
begin
  Result := FMaskEdit.OnKeyUp;
end;

procedure TFRMaterialMaskEdit.SetOnKeyUp(AValue: TKeyEvent);
begin
  FMaskEdit.OnKeyUp := AValue;
end;

function TFRMaterialMaskEdit.GetOnUTF8KeyPress: TUTF8KeyPressEvent;
begin
  Result := FMaskEdit.OnUTF8KeyPress;
end;

procedure TFRMaterialMaskEdit.SetOnUTF8KeyPress(AValue: TUTF8KeyPressEvent);
begin
  FMaskEdit.OnUTF8KeyPress := AValue;
end;

{ --- Métodos protegidos --- }

procedure TFRMaterialMaskEdit.SetAnchors(const AValue: TAnchors);
begin
  if Self.Anchors = AValue then Exit;
  inherited SetAnchors(AValue);
  if not (csLoading in ComponentState) then Self.DoOnResize;
end;

procedure TFRMaterialMaskEdit.SetColor(AValue: TColor);
begin
  inherited SetColor(AValue);
  FMaskEdit.Color := AValue;
end;

procedure TFRMaterialMaskEdit.SetName(const AValue: TComponentName);
begin
  if csDesigning in ComponentState then
  begin
    if (FLabel.Caption = '') or AnsiSameText(FLabel.Caption, Name) then
      FLabel.Caption := 'Label';
    if (FLabel.Name = '') or AnsiSameText(FLabel.Name, Name) then
      FLabel.Name := AValue + 'SubLabel';
    if (FMaskEdit.Name = '') or AnsiSameText(FMaskEdit.Name, Name) then
      FMaskEdit.Name := AValue + 'SubEdit';
  end;
  inherited SetName(AValue);
end;

procedure TFRMaterialMaskEdit.DoEnter;
begin
  inherited DoEnter;
  FFocused := True;
  if Assigned(FLabelAnimator) then FLabelAnimator.FloatLabel;
  Invalidate;
  { Redireciona o foco para o edit interno }
  if FMaskEdit.CanFocus then
    FMaskEdit.SetFocus;
end;

procedure TFRMaterialMaskEdit.DoExit;
begin
  FFocused := False;
  if Assigned(FLabelAnimator) then
  begin
    if Trim(FMaskEdit.Text) = '' then
      FLabelAnimator.InlineLabel
    else
      FLabelAnimator.FloatLabel;
  end;
  Invalidate;
  inherited DoExit;
end;

procedure TFRMaterialMaskEdit.DoOnResize;
var
  AutoSizedHeight: LongInt;
begin
  if IsNeededAdjustSize then
  begin
    FMaskEdit.Align := alBottom;
    AutoSizedHeight :=
      FLabel.Height +
      FLabel.BorderSpacing.Around +
      FLabel.BorderSpacing.Bottom +
      FLabel.BorderSpacing.Top +
      FMaskEdit.Height +
      FMaskEdit.BorderSpacing.Around +
      FMaskEdit.BorderSpacing.Bottom +
      FMaskEdit.BorderSpacing.Top;

    if Self.Height <> AutoSizedHeight then
      Self.Height := AutoSizedHeight;
  end else
    FMaskEdit.Align := alClient;

  { Dimensiona o botão; âncoras cuidam do posicionamento }
  if Assigned(FClearButton) then
  begin
    FClearButton.Width  := FMaskEdit.Height - 2;
    FClearButton.Height := FMaskEdit.Height - 2;
  end;

  { Responsividade: adaptar Font.Size proporcionalmente à altura e densidade.
    Referência MD3: Height 56 → Font.Size 12.  Mínimo 8, máximo 16. }
  if FAutoFontSize then
    FMaskEdit.Font.Size := MD3FontSizeForField(Self.Height, ddNormal);

  inherited DoOnResize;
end;

procedure TFRMaterialMaskEdit.Paint;
var
  DecoColor: TColor;
  P: TFRMDFieldPaintParams;
  ActionRightPos: Integer;
begin
  if not FRMDCanPaint(Self) then Exit;
  inherited Paint;

  if not Assigned(FMaskEdit) then Exit;

  if FMaskEdit.Color <> Self.Color then
    FMaskEdit.Color := Self.Color;

  if FFocused and Self.Enabled then
    DecoColor := AccentColor
  else
    DecoColor := DisabledColor;

  ActionRightPos := FMaskEdit.Left + FMaskEdit.Width;
  if Assigned(FClearButton) and FClearButton.Visible then
    ActionRightPos := FClearButton.Left + FClearButton.Width;

  P.Canvas := Canvas;
  P.Rect := ClientRect;
  P.BgColor := Color;
  if Assigned(Parent) then P.ParentBgColor := Parent.Color else P.ParentBgColor := clNone;

  P.Variant := FVariant;
  P.BorderRadius := FBorderRadius;
  
  P.DecoColor := DecoColor;
  P.HelperColor := DisabledColor;
  P.DisabledColor := DisabledColor;
  
  P.IsFocused := FFocused;
  P.IsEnabled := Enabled;
  P.IsRequired := False;
  
  P.EditLeft := FMaskEdit.Left;
  P.EditTop := FMaskEdit.Top;
  P.EditWidth := FMaskEdit.Width;
  P.EditHeight := FMaskEdit.Height;
  
  P.ActionRight := ActionRightPos;
  P.BottomMargin := 0;
  
  P.HelperText := '';
  P.CharCounterText := '';
  P.PrefixText := '';
  P.SuffixText := '';
  
  P.EditFont := FMaskEdit.Font;
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

constructor TFRMaterialMaskEdit.Create(AOwner: TComponent);
begin
  FMaskEdit := TMaskEdit.Create(Self);
  FLabel    := TBoundLabel.Create(Self);
  inherited Create(AOwner);

  Self.BevelOuter    := bvNone;
  Self.AccentColor   := clHighlight;
  Self.BorderStyle   := bsNone;
  Self.DisabledColor := $00B8AFA8;
  Self.ParentColor   := True;
  
  FRMDRegisterComponent(Self);

  FLabel.Align                := alNone;
  FLabel.Visible              := False;
  FLabel.AutoSize             := True;
  FLabel.Top                  := 4;
  FLabel.BorderSpacing.Around := 0;
  FLabel.BorderSpacing.Bottom := 4;
  FLabel.BorderSpacing.Left   := MD3_FIELD_PADDING_H;
  FLabel.BorderSpacing.Right  := MD3_FIELD_PADDING_H;
  FLabel.BorderSpacing.Top    := 4;
  FLabel.Font.Color           := $00B8AFA8;
  FLabel.Font.Style           := [fsBold];
  FLabel.Parent               := Self;
  FLabel.ParentFont           := False;
  FLabel.ParentBiDiMode       := True;
  FLabel.SetSubComponent(True);
  
  FLabelAnimator := TFRMDFloatingLabelAnimator.Create(Self);
  FLabelAnimator.SnapTo(1.0);

  FMaskEdit.Align                := alBottom;
  FMaskEdit.AutoSize             := True;
  FMaskEdit.AutoSelect           := True;
  FMaskEdit.BorderSpacing.Around := 0;
  FMaskEdit.BorderSpacing.Bottom := 4;
  FMaskEdit.BorderSpacing.Left   := MD3_FIELD_PADDING_H;
  FMaskEdit.BorderSpacing.Right  := MD3_FIELD_PADDING_H;
  FMaskEdit.BorderSpacing.Top    := 0;
  FMaskEdit.BorderStyle          := bsNone;
  FMaskEdit.ParentColor          := True;
  FMaskEdit.Parent               := Self;
  FMaskEdit.ParentFont           := True;
  FMaskEdit.ParentBiDiMode       := True;
  FMaskEdit.TabStop              := True;
  FMaskEdit.SetSubComponent(True);

  { Container não participa do tab order — o foco vai direto para FMaskEdit }
  inherited TabStop := False;

  { AddHandlerOnChange é usado para não sobrescrever o OnChange do usuário.
    O controle de visibilidade do botão de limpeza é feito internamente. }
  FMaskEdit.AddHandlerOnChange(@InternalEditChange);

  FClearButton := TFRMaterialIconButton.Create(Self);
  FClearButton.IconMode := imClear;
  FClearButton.Width    := 22;
  FClearButton.Height   := 22;
  FClearButton.Visible  := False;
  FClearButton.Parent   := Self;
  FClearButton.OnClick  := @ClearButtonClick;
  FClearButton.SetSubComponent(True);

  FShowClearButton := False;
  FVariant         := mvStandard;
  FBorderRadius    := 0;
  FAutoFontSize    := True;
end;

destructor TFRMaterialMaskEdit.Destroy;
begin
  if Assigned(FLabelAnimator) then FLabelAnimator.Free;
  
  FRMDUnregisterComponent(Self);
    
  inherited Destroy;
end;

procedure TFRMaterialMaskEdit.ApplyTheme(const AThemeManager: TObject);
begin
  if not Assigned(AThemeManager) then Exit;

  { Sync variant from ThemeManager }
  FVariant := FRMDGetThemeVariant(AThemeManager);

  FAccentColor   := MD3Colors.Primary;
  FDisabledColor := MD3Colors.OnSurfaceVariant;

  case FVariant of
    mvFilled:   Self.Color := MD3Colors.SurfaceContainerHighest;
    mvOutlined: Self.Color := MD3Colors.Surface;
  else
    Self.ParentColor := True;
  end;

  Self.Font.Color       := MD3Colors.OnSurface;
  FLabel.Font.Color     := MD3Colors.OnSurfaceVariant;

  if Assigned(FClearButton) then
  begin
    FClearButton.NormalColor := MD3Colors.OnSurfaceVariant;
    FClearButton.HoverColor  := MD3Colors.Error;
    FClearButton.InvalidateCache;
  end;

  Invalidate;
end;

end.

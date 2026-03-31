unit FRMaterialDateEdit;

{$mode objfpc}{$H+}

{ TFRMaterialDateEdit
  Componente de edição de data com estilo Material Design.
  Encapsula TDateEdit (LCL) com:
    - Label flutuante acima do campo (accentColor no foco)
    - Sublinhado Material Design
    - Botão de limpeza nativo opcional (ShowClearButton)
    - Acesso completo às propriedades/eventos do TDateEdit interno

  Requer: EditBtn, Calendar (LCL)
  Licença: LGPL v3 — mesma do bgracontrols
}

interface

uses
  FRMaterialTheme, FRMaterialIcons, Classes, Calendar, Controls, EditBtn, ExtCtrls, Forms, Graphics,
  {$IFDEF FPC} LCLType, LResources, {$ENDIF} Menus, StdCtrls, SysUtils;

type

  { TFRMaterialDateEdit }

  TFRMaterialDateEdit = class(TCustomPanel)
  private
    FAccentColor: TColor;
    FDisabledColor: TColor;
    FLabel: TBoundLabel;
    FDateEdit: TDateEdit;
    FFocused: Boolean;
    FVariant: TFRMaterialVariant;
    FBorderRadius: Integer;
    FClearButton: TFRMaterialIconButton;
    FShowClearButton: Boolean;
    FOnClearButtonClick: TNotifyEvent;
    { Armazena OnChange do usuário; FDateEdit.OnChange é reservado para uso interno }
    FUserOnChange: TNotifyEvent;

    function IsNeededAdjustSize: Boolean;

    { Botão de limpeza }
    function GetShowClearButton: Boolean;
    procedure SetShowClearButton(AValue: Boolean);
    procedure ClearButtonClick(Sender: TObject);
    procedure InternalDateEditChange(Sender: TObject);
    procedure UpdateClearButton;

    { Propriedades de TDateEdit }
    function GetCalendarDisplaySettings: TDisplaySettings;
    procedure SetCalendarDisplaySettings(AValue: TDisplaySettings);
    function GetDate: TDateTime;
    procedure SetDate(AValue: TDateTime);
    function GetDateOrder: TDateOrder;
    procedure SetDateOrder(AValue: TDateOrder);
    function GetDirectInput: Boolean;
    procedure SetDirectInput(AValue: Boolean);
    function GetEditCursor: TCursor;
    procedure SetEditCursor(AValue: TCursor);
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
    function GetLabelCaption: TCaption;
    procedure SetLabelCaption(const AValue: TCaption);
    function GetLabelSpacing: Integer;
    procedure SetLabelSpacing(AValue: Integer);

    { Eventos de TDateEdit }
    function GetOnAcceptDate: TAcceptDateEvent;
    procedure SetOnAcceptDate(AValue: TAcceptDateEvent);
    function GetOnChange: TNotifyEvent;
    procedure SetOnChange(AValue: TNotifyEvent);
    function GetOnClick: TNotifyEvent;
    procedure SetOnClick(AValue: TNotifyEvent);
    function GetOnCustomDate: TCustomDateEvent;
    procedure SetOnCustomDate(AValue: TCustomDateEvent);
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
    { Limpa o campo de data }
    procedure ClearDate;
    { Acesso direto ao TDateEdit interno para customizações avançadas }
    property DateEdit: TDateEdit read FDateEdit;
    { Acesso ao botão de limpeza (caption, hint, cor etc.) }
    property ClearButton: TFRMaterialIconButton read FClearButton;

  published
    property Align;
    property AccentColor: TColor read FAccentColor write FAccentColor;
    property Anchors;
    property BiDiMode;
    property BorderSpacing;
    { Configurações de exibição do calendário popup }
    property CalendarDisplaySettings: TDisplaySettings
      read GetCalendarDisplaySettings write SetCalendarDisplaySettings;
    { Legenda do label flutuante }
    property Caption: TCaption read GetLabelCaption write SetLabelCaption;
    property Color;
    property Constraints;
    property Cursor: TCursor read GetEditCursor write SetEditCursor default crDefault;
    { Data selecionada (TDateTime) }
    property Date: TDateTime read GetDate write SetDate;
    { Ordem de exibição da data (DMY, MDY, YMD, nativa, nenhuma) }
    property DateOrder: TDateOrder read GetDateOrder write SetDateOrder default doNone;
    { Permite digitação direta; False = somente via calendário }
    property DirectInput: Boolean read GetDirectInput write SetDirectInput default True;
    property DisabledColor: TColor read FDisabledColor write FDisabledColor;
    { Variante visual: sublinhado (mvStandard), preenchido (mvFilled) ou contornado (mvOutlined) }
    property Variant: TFRMaterialVariant read FVariant write FVariant default mvStandard;
    { Raio dos cantos arredondados em pixels; 0 = cantos retos }
    property BorderRadius: Integer read FBorderRadius write FBorderRadius default 0;
    { Label flutuante acima do campo }
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
    { Exibe botão "×" quando o campo tiver data e não estiver em ReadOnly }
    property ShowClearButton: Boolean
      read GetShowClearButton write SetShowClearButton default False;
    property ShowHint;
    property TabOrder;
    property TabStop: Boolean read GetEditTabStop write SetEditTabStop default True;
    { Texto bruto do campo (use Date para obter TDateTime) }
    property Text: TCaption read GetEditText write SetEditText;
    property TextHint: TTranslateString read GetEditTextHint write SetEditTextHint;
    property Visible;

    { Disparado quando o usuário confirma uma data no calendário }
    property OnAcceptDate: TAcceptDateEvent read GetOnAcceptDate write SetOnAcceptDate;
    property OnChange: TNotifyEvent read GetOnChange write SetOnChange;
    property OnChangeBounds;
    { Disparado após clicar no botão de limpeza (campo já foi limpo) }
    property OnClearButtonClick: TNotifyEvent
      read FOnClearButtonClick write FOnClearButtonClick;
    property OnClick: TNotifyEvent read GetOnClick write SetOnClick;
    { Disparado quando o usuário escolhe "data personalizada" no calendário }
    property OnCustomDate: TCustomDateEvent read GetOnCustomDate write SetOnCustomDate;
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

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialdateedit_icon.lrs}
  {$ENDIF}
  RegisterComponents('BGRA Controls', [TFRMaterialDateEdit]);
end;

{ TFRMaterialDateEdit }

function TFRMaterialDateEdit.IsNeededAdjustSize: Boolean;
begin
  if (Self.Align in [alLeft, alRight, alClient]) then Exit(False);
  if (akTop in Self.Anchors) and (akBottom in Self.Anchors) then Exit(False);
  Result := True; { TDateEdit tem altura fixa (AutoSize implícito) }
end;

{ --- Botão de limpeza --- }

function TFRMaterialDateEdit.GetShowClearButton: Boolean;
begin
  Result := FShowClearButton;
end;

procedure TFRMaterialDateEdit.SetShowClearButton(AValue: Boolean);
begin
  if FShowClearButton = AValue then Exit;
  FShowClearButton := AValue;
  UpdateClearButton;
end;

procedure TFRMaterialDateEdit.ClearButtonClick(Sender: TObject);
begin
  ClearDate;
  FDateEdit.SetFocus;
  if Assigned(FOnClearButtonClick) then
    FOnClearButtonClick(Self);
end;

procedure TFRMaterialDateEdit.InternalDateEditChange(Sender: TObject);
begin
  UpdateClearButton;
  if Assigned(FUserOnChange) then
    FUserOnChange(Sender);
end;

procedure TFRMaterialDateEdit.UpdateClearButton;
var
  ShouldShow: Boolean;
begin
  ShouldShow := FShowClearButton
    and (FDateEdit.Text <> '')
    and not FDateEdit.ReadOnly;

  if ShouldShow = FClearButton.Visible then Exit;

  DisableAlign;
  try
    FClearButton.Visible := ShouldShow;
    if ShouldShow then
    begin
      FClearButton.Anchors := [akTop, akRight, akBottom];
      FClearButton.AnchorSide[akRight].Control  := Self;
      FClearButton.AnchorSide[akRight].Side     := asrBottom;
      FClearButton.AnchorSide[akTop].Control    := FDateEdit;
      FClearButton.AnchorSide[akTop].Side       := asrTop;
      FClearButton.AnchorSide[akBottom].Control := FDateEdit;
      FClearButton.AnchorSide[akBottom].Side    := asrBottom;
      FClearButton.BorderSpacing.Right := 4;
      FDateEdit.BorderSpacing.Right := FClearButton.Width + 6;
    end
    else
    begin
      FClearButton.Anchors := [];
      FDateEdit.BorderSpacing.Right := 4;
    end;
  finally
    EnableAlign;
  end;
  Invalidate;
end;

procedure TFRMaterialDateEdit.ClearDate;
begin
  FDateEdit.Text := '';
end;

{ --- Getters/Setters de propriedades --- }

function TFRMaterialDateEdit.GetCalendarDisplaySettings: TDisplaySettings;
begin
  Result := FDateEdit.CalendarDisplaySettings;
end;

procedure TFRMaterialDateEdit.SetCalendarDisplaySettings(AValue: TDisplaySettings);
begin
  FDateEdit.CalendarDisplaySettings := AValue;
end;

function TFRMaterialDateEdit.GetDate: TDateTime;
begin
  Result := FDateEdit.Date;
end;

procedure TFRMaterialDateEdit.SetDate(AValue: TDateTime);
begin
  FDateEdit.Date := AValue;
end;

function TFRMaterialDateEdit.GetDateOrder: TDateOrder;
begin
  Result := FDateEdit.DateOrder;
end;

procedure TFRMaterialDateEdit.SetDateOrder(AValue: TDateOrder);
begin
  FDateEdit.DateOrder := AValue;
end;

function TFRMaterialDateEdit.GetDirectInput: Boolean;
begin
  Result := FDateEdit.DirectInput;
end;

procedure TFRMaterialDateEdit.SetDirectInput(AValue: Boolean);
begin
  FDateEdit.DirectInput := AValue;
end;

function TFRMaterialDateEdit.GetEditCursor: TCursor;
begin
  Result := FDateEdit.Cursor;
end;

procedure TFRMaterialDateEdit.SetEditCursor(AValue: TCursor);
begin
  FDateEdit.Cursor := AValue;
end;

function TFRMaterialDateEdit.GetEditPopupMenu: TPopupMenu;
begin
  if csDestroying in ComponentState then Exit(nil);
  Result := FDateEdit.PopupMenu;
end;

procedure TFRMaterialDateEdit.SetEditPopupMenu(AValue: TPopupMenu);
begin
  FDateEdit.PopupMenu := AValue;
end;

function TFRMaterialDateEdit.GetEditReadOnly: Boolean;
begin
  Result := FDateEdit.ReadOnly;
end;

procedure TFRMaterialDateEdit.SetEditReadOnly(AValue: Boolean);
begin
  FDateEdit.ReadOnly := AValue;
  UpdateClearButton;
end;

function TFRMaterialDateEdit.GetEditTabStop: Boolean;
begin
  Result := FDateEdit.TabStop;
end;

procedure TFRMaterialDateEdit.SetEditTabStop(AValue: Boolean);
begin
  FDateEdit.TabStop := AValue;
end;

function TFRMaterialDateEdit.GetEditText: TCaption;
begin
  Result := FDateEdit.Text;
end;

procedure TFRMaterialDateEdit.SetEditText(const AValue: TCaption);
begin
  FDateEdit.Text := AValue;
end;

function TFRMaterialDateEdit.GetEditTextHint: TTranslateString;
begin
  Result := FDateEdit.TextHint;
end;

procedure TFRMaterialDateEdit.SetEditTextHint(const AValue: TTranslateString);
begin
  FDateEdit.TextHint := AValue;
end;

function TFRMaterialDateEdit.GetLabelCaption: TCaption;
begin
  Result := FLabel.Caption;
end;

procedure TFRMaterialDateEdit.SetLabelCaption(const AValue: TCaption);
begin
  FLabel.Caption := AValue;
end;

function TFRMaterialDateEdit.GetLabelSpacing: Integer;
begin
  Result := FLabel.BorderSpacing.Bottom;
end;

procedure TFRMaterialDateEdit.SetLabelSpacing(AValue: Integer);
begin
  if FLabel.BorderSpacing.Bottom = AValue then Exit;
  FLabel.BorderSpacing.Bottom := AValue;
  if not (csLoading in ComponentState) then Self.DoOnResize;
end;

{ --- Getters/Setters de eventos --- }

function TFRMaterialDateEdit.GetOnAcceptDate: TAcceptDateEvent;
begin
  Result := FDateEdit.OnAcceptDate;
end;

procedure TFRMaterialDateEdit.SetOnAcceptDate(AValue: TAcceptDateEvent);
begin
  FDateEdit.OnAcceptDate := AValue;
end;

{ OnChange é interceptado internamente para controlar o botão de limpeza.
  O handler do usuário é armazenado em FUserOnChange e chamado dentro de
  InternalDateEditChange. }
function TFRMaterialDateEdit.GetOnChange: TNotifyEvent;
begin
  Result := FUserOnChange;
end;

procedure TFRMaterialDateEdit.SetOnChange(AValue: TNotifyEvent);
begin
  FUserOnChange := AValue;
end;

function TFRMaterialDateEdit.GetOnClick: TNotifyEvent;
begin
  Result := FDateEdit.OnClick;
end;

procedure TFRMaterialDateEdit.SetOnClick(AValue: TNotifyEvent);
begin
  FDateEdit.OnClick := AValue;
end;

function TFRMaterialDateEdit.GetOnCustomDate: TCustomDateEvent;
begin
  Result := FDateEdit.OnCustomDate;
end;

procedure TFRMaterialDateEdit.SetOnCustomDate(AValue: TCustomDateEvent);
begin
  FDateEdit.OnCustomDate := AValue;
end;

function TFRMaterialDateEdit.GetOnEditingDone: TNotifyEvent;
begin
  Result := FDateEdit.OnEditingDone;
end;

procedure TFRMaterialDateEdit.SetOnEditingDone(AValue: TNotifyEvent);
begin
  FDateEdit.OnEditingDone := AValue;
end;

function TFRMaterialDateEdit.GetOnEnter: TNotifyEvent;
begin
  Result := FDateEdit.OnEnter;
end;

procedure TFRMaterialDateEdit.SetOnEnter(AValue: TNotifyEvent);
begin
  FDateEdit.OnEnter := AValue;
end;

function TFRMaterialDateEdit.GetOnExit: TNotifyEvent;
begin
  Result := FDateEdit.OnExit;
end;

procedure TFRMaterialDateEdit.SetOnExit(AValue: TNotifyEvent);
begin
  FDateEdit.OnExit := AValue;
end;

function TFRMaterialDateEdit.GetOnKeyDown: TKeyEvent;
begin
  Result := FDateEdit.OnKeyDown;
end;

procedure TFRMaterialDateEdit.SetOnKeyDown(AValue: TKeyEvent);
begin
  FDateEdit.OnKeyDown := AValue;
end;

function TFRMaterialDateEdit.GetOnKeyPress: TKeyPressEvent;
begin
  Result := FDateEdit.OnKeyPress;
end;

procedure TFRMaterialDateEdit.SetOnKeyPress(AValue: TKeyPressEvent);
begin
  FDateEdit.OnKeyPress := AValue;
end;

function TFRMaterialDateEdit.GetOnKeyUp: TKeyEvent;
begin
  Result := FDateEdit.OnKeyUp;
end;

procedure TFRMaterialDateEdit.SetOnKeyUp(AValue: TKeyEvent);
begin
  FDateEdit.OnKeyUp := AValue;
end;

function TFRMaterialDateEdit.GetOnUTF8KeyPress: TUTF8KeyPressEvent;
begin
  Result := FDateEdit.OnUTF8KeyPress;
end;

procedure TFRMaterialDateEdit.SetOnUTF8KeyPress(AValue: TUTF8KeyPressEvent);
begin
  FDateEdit.OnUTF8KeyPress := AValue;
end;

{ --- Métodos protegidos --- }

procedure TFRMaterialDateEdit.SetAnchors(const AValue: TAnchors);
begin
  if Self.Anchors = AValue then Exit;
  inherited SetAnchors(AValue);
  if not (csLoading in ComponentState) then Self.DoOnResize;
end;

procedure TFRMaterialDateEdit.SetColor(AValue: TColor);
begin
  inherited SetColor(AValue);
  FDateEdit.Color := AValue;
end;

procedure TFRMaterialDateEdit.SetName(const AValue: TComponentName);
begin
  if csDesigning in ComponentState then
  begin
    if (FLabel.Caption = '') or AnsiSameText(FLabel.Caption, Name) then
      FLabel.Caption := 'Data';
    if (FLabel.Name = '') or AnsiSameText(FLabel.Name, Name) then
      FLabel.Name := AValue + 'SubLabel';
    if (FDateEdit.Name = '') or AnsiSameText(FDateEdit.Name, Name) then
      FDateEdit.Name := AValue + 'SubDateEdit';
  end;
  inherited SetName(AValue);
end;

procedure TFRMaterialDateEdit.DoEnter;
begin
  inherited DoEnter;
  FFocused := True;
  Invalidate;
end;

procedure TFRMaterialDateEdit.DoExit;
begin
  FFocused := False;
  Invalidate;
  inherited DoExit;
end;

procedure TFRMaterialDateEdit.DoOnResize;
var
  AutoSizedHeight: LongInt;
begin
  if IsNeededAdjustSize then
  begin
    FDateEdit.Align := alBottom;
    AutoSizedHeight :=
      FLabel.Height +
      FLabel.BorderSpacing.Around +
      FLabel.BorderSpacing.Bottom +
      FLabel.BorderSpacing.Top +
      FDateEdit.Height +
      FDateEdit.BorderSpacing.Around +
      FDateEdit.BorderSpacing.Bottom +
      FDateEdit.BorderSpacing.Top;

    if Self.Height <> AutoSizedHeight then
      Self.Height := AutoSizedHeight;
  end else
    FDateEdit.Align := alClient;

  { Dimensiona o botão; âncoras cuidam do posicionamento }
  if Assigned(FClearButton) then
  begin
    FClearButton.Width  := FDateEdit.Height - 2;
    FClearButton.Height := FDateEdit.Height - 2;
  end;

  inherited DoOnResize;
end;

procedure TFRMaterialDateEdit.Paint;
var
  LeftPos, RightPos, FieldTop, CR: Integer;
  DecoColor: TColor;
begin
  inherited Paint;

  if FDateEdit.Color <> Self.Color then
    FDateEdit.Color := Self.Color;

  CR := FBorderRadius * 2;
  if FFocused and Self.Enabled then
    DecoColor := AccentColor
  else
    DecoColor := DisabledColor;

  if Assigned(Parent) and (Parent.Color = Color) then
  begin
    LeftPos := FDateEdit.Left;
    if FClearButton.Visible then
      RightPos := FClearButton.Left + FClearButton.Width
    else
      RightPos := FDateEdit.Left + FDateEdit.Width;
  end else
  begin
    LeftPos  := 0;
    RightPos := Width;
  end;

  FieldTop := FDateEdit.Top - 2;
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

constructor TFRMaterialDateEdit.Create(AOwner: TComponent);
begin
  FDateEdit := TDateEdit.Create(Self);
  FLabel    := TBoundLabel.Create(Self);
  inherited Create(AOwner);

  Self.AccentColor  := clHighlight;
  Self.BorderStyle  := bsNone;
  Self.DisabledColor := $00B8AFA8;
  Self.ParentColor  := True;

  FLabel.Align                  := alTop;
  FLabel.AutoSize               := True;
  FLabel.BorderSpacing.Around   := 0;
  FLabel.BorderSpacing.Bottom   := 4;
  FLabel.BorderSpacing.Left     := 4;
  FLabel.BorderSpacing.Right    := 4;
  FLabel.BorderSpacing.Top      := 4;
  FLabel.Font.Color             := $00B8AFA8;
  FLabel.Font.Style             := [fsBold];
  FLabel.Parent                 := Self;
  FLabel.ParentFont             := False;
  FLabel.ParentBiDiMode         := True;
  FLabel.SetSubComponent(True);

  FDateEdit.Align                := alBottom;
  FDateEdit.BorderSpacing.Around := 0;
  FDateEdit.BorderSpacing.Bottom := 4;
  FDateEdit.BorderSpacing.Left   := 4;
  FDateEdit.BorderSpacing.Right  := 4;
  FDateEdit.BorderSpacing.Top    := 0;
  FDateEdit.ParentColor          := True;
  FDateEdit.Parent               := Self;
  FDateEdit.ParentFont           := True;
  FDateEdit.ParentBiDiMode       := True;
  FDateEdit.TabStop              := True;
  FDateEdit.SetSubComponent(True);

  { Intercepta OnChange para controlar visibilidade do botão de limpeza.
    O OnChange que o usuário definir é armazenado em FUserOnChange e
    chamado dentro de InternalDateEditChange. }
  FDateEdit.OnChange := @InternalDateEditChange;

  { Botão de limpeza — ícone SVG "×" vermelho }
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
end;

end.

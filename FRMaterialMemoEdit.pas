unit FRMaterialMemoEdit;

{$mode objfpc}{$H+}

{ FRMaterialMemoEdit
  Componente TMemo com estilo Material Design.
  Herda o visual de TFRMaterialEditBase mas usa TMemo internamente.

  Propriedades exclusivas:
    ScrollBars  — controle das barras de rolagem
    WordWrap    — quebra de linha automática
    Lines       — acesso às linhas do memo

  Licença: LGPL v3 — mesma do bgracontrols
}

interface

uses
  FRMaterialTheme, FRMaterialIcons, FRMaterialMasks, Classes, Controls, Dialogs, ExtCtrls, Forms, Graphics,
  {$IFDEF FPC} LCLType, LResources, {$ENDIF} Menus, StdCtrls, SysUtils;

type

  { TFRMaterialMemoEdit }

  TFRMaterialMemoEdit = class(TCustomPanel)
  private
    FAccentColor: TColor;
    FDisabledColor: TColor;
    FLabel: TBoundLabel;
    FFocused: Boolean;
    FMemo: TMemo;
    FVariant: TFRMaterialVariant;
    FBorderRadius: Integer;
    FValidationState: TFRValidationState;
    FValidColor: TColor;
    FInvalidColor: TColor;
    FHelperText: string;
    FErrorText: string;
    FShowCharCounter: Boolean;
    FRequired: Boolean;
    FMinLength: Integer;
    FValidateMode: TFRValidateMode;
    FOnValidate: TFRValidateEvent;

    function GetLines: TStrings;
    procedure SetLines(AValue: TStrings);
    function GetScrollBars: TScrollStyle;
    procedure SetScrollBars(AValue: TScrollStyle);
    function GetWordWrap: Boolean;
    procedure SetWordWrap(AValue: Boolean);
    function GetMemoText: TCaption;
    procedure SetMemoText(const AValue: TCaption);
    function GetMemoTextHint: TTranslateString;
    procedure SetMemoTextHint(const AValue: TTranslateString);
    function GetMemoReadOnly: Boolean;
    procedure SetMemoReadOnly(AValue: Boolean);
    function GetMemoMaxLength: Integer;
    procedure SetMemoMaxLength(AValue: Integer);
    function GetLabelCaption: TCaption;
    procedure SetLabelCaption(const AValue: TCaption);
    function GetLabelSpacing: Integer;
    procedure SetLabelSpacing(AValue: Integer);
    function GetOnMemoChange: TNotifyEvent;
    procedure SetOnMemoChange(AValue: TNotifyEvent);
    function GetOnMemoKeyPress: TKeyPressEvent;
    procedure SetOnMemoKeyPress(AValue: TKeyPressEvent);
    function GetOnMemoKeyDown: TKeyEvent;
    procedure SetOnMemoKeyDown(AValue: TKeyEvent);

    procedure SetHelperText(const AValue: string);
    procedure SetErrorText(const AValue: string);
    procedure SetShowCharCounter(AValue: Boolean);
    procedure SetRequired(AValue: Boolean);
    procedure SetValidationState(AValue: TFRValidationState);

    function GetBottomMargin: Integer;
    function GetDisplayHelperText: string;
    procedure InternalValidate;
    procedure InternalMemoChange(Sender: TObject);
  protected
    procedure SetColor(AValue: TColor); override;
    procedure SetName(const AValue: TComponentName); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Memo: TMemo read FMemo;
  published
    property Align;
    property AccentColor: TColor read FAccentColor write FAccentColor;
    property Anchors;
    property BiDiMode;
    property BorderSpacing;
    property Caption: TCaption read GetLabelCaption write SetLabelCaption;
    property Color;
    property Constraints;
    property DisabledColor: TColor read FDisabledColor write FDisabledColor;
    property EditLabel: TBoundLabel read FLabel;
    property Enabled;
    property Font;
    property LabelSpacing: Integer read GetLabelSpacing write SetLabelSpacing default 4;
    property Lines: TStrings read GetLines write SetLines;
    property MaxLength: Integer read GetMemoMaxLength write SetMemoMaxLength default 0;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont default False;
    property ReadOnly: Boolean read GetMemoReadOnly write SetMemoReadOnly default False;
    property ScrollBars: TScrollStyle read GetScrollBars write SetScrollBars default ssNone;
    property ShowCharCounter: Boolean read FShowCharCounter write SetShowCharCounter default False;
    property Text: TCaption read GetMemoText write SetMemoText;
    property TextHint: TTranslateString read GetMemoTextHint write SetMemoTextHint;
    property Variant: TFRMaterialVariant read FVariant write FVariant default mvStandard;
    property BorderRadius: Integer read FBorderRadius write FBorderRadius default 0;
    property ValidationState: TFRValidationState read FValidationState write SetValidationState default vsNone;
    property ValidColor: TColor read FValidColor write FValidColor default $0000B300;
    property InvalidColor: TColor read FInvalidColor write FInvalidColor default $000000FF;
    property HelperText: string read FHelperText write SetHelperText;
    property ErrorText: string read FErrorText write SetErrorText;
    property Required: Boolean read FRequired write SetRequired default False;
    property MinLength: Integer read FMinLength write FMinLength default 0;
    property ValidateMode: TFRValidateMode read FValidateMode write FValidateMode default vmOnExit;
    property OnValidate: TFRValidateEvent read FOnValidate write FOnValidate;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property WordWrap: Boolean read GetWordWrap write SetWordWrap default True;

    property OnChange: TNotifyEvent read GetOnMemoChange write SetOnMemoChange;
    property OnKeyDown: TKeyEvent read GetOnMemoKeyDown write SetOnMemoKeyDown;
    property OnKeyPress: TKeyPressEvent read GetOnMemoKeyPress write SetOnMemoKeyPress;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialmemoedit_icon.lrs}
  {$ENDIF}
  RegisterComponents('BGRA Controls', [TFRMaterialMemoEdit]);
end;

{ TFRMaterialMemoEdit }

constructor TFRMaterialMemoEdit.Create(AOwner: TComponent);
begin
  FMemo := TMemo.Create(Self);
  FLabel := TBoundLabel.Create(Self);
  inherited Create(AOwner);

  Self.AccentColor  := clHighlight;
  Self.BorderStyle  := bsNone;
  Self.DisabledColor := $00B8AFA8;
  Self.ParentColor  := True;
  Self.Height       := 120;

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
  FLabel.SetSubComponent(True);

  FMemo.Align := alClient;
  FMemo.BorderSpacing.Around := 0;
  FMemo.BorderSpacing.Left := 4;
  FMemo.BorderSpacing.Right := 4;
  FMemo.BorderSpacing.Bottom := 4;
  FMemo.BorderStyle := bsNone;
  FMemo.ParentColor := True;
  FMemo.Font.Color := clBlack;
  FMemo.Parent := Self;
  FMemo.ParentFont := True;
  FMemo.ScrollBars := ssNone;
  FMemo.WordWrap := True;
  FMemo.TabStop := True;
  FMemo.SetSubComponent(True);

  FMemo.OnChange := @InternalMemoChange;

  FVariant         := mvStandard;
  FBorderRadius    := 0;
  FValidationState := vsNone;
  FValidColor      := $0000B300;
  FInvalidColor    := $000000FF;
  FHelperText      := '';
  FErrorText       := '';
  FShowCharCounter := False;
  FRequired        := False;
  FMinLength       := 0;
  FValidateMode    := vmOnExit;
end;

procedure TFRMaterialMemoEdit.SetColor(AValue: TColor);
begin
  inherited SetColor(AValue);
  FMemo.Color := AValue;
end;

procedure TFRMaterialMemoEdit.SetName(const AValue: TComponentName);
begin
  if (csDesigning in ComponentState) then
  begin
    if (FLabel.Caption = '') or AnsiSameText(FLabel.Caption, AValue) then
      FLabel.Caption := 'Label';
    if (FLabel.Name = '') or AnsiSameText(FLabel.Name, AValue) then
      FLabel.Name := AValue + 'SubLabel';
    if (FMemo.Name = '') or AnsiSameText(FMemo.Name, AValue) then
      FMemo.Name := AValue + 'SubMemo';
  end;
  inherited SetName(AValue);
end;

procedure TFRMaterialMemoEdit.DoEnter;
begin
  inherited DoEnter;
  FFocused := True;
  Invalidate;
end;

procedure TFRMaterialMemoEdit.DoExit;
begin
  FFocused := False;
  if FValidateMode = vmOnExit then
    InternalValidate;
  Invalidate;
  inherited DoExit;
end;

function TFRMaterialMemoEdit.GetLines: TStrings;
begin
  Result := FMemo.Lines;
end;

procedure TFRMaterialMemoEdit.SetLines(AValue: TStrings);
begin
  FMemo.Lines.Assign(AValue);
end;

function TFRMaterialMemoEdit.GetScrollBars: TScrollStyle;
begin
  Result := FMemo.ScrollBars;
end;

procedure TFRMaterialMemoEdit.SetScrollBars(AValue: TScrollStyle);
begin
  FMemo.ScrollBars := AValue;
end;

function TFRMaterialMemoEdit.GetWordWrap: Boolean;
begin
  Result := FMemo.WordWrap;
end;

procedure TFRMaterialMemoEdit.SetWordWrap(AValue: Boolean);
begin
  FMemo.WordWrap := AValue;
end;

function TFRMaterialMemoEdit.GetMemoText: TCaption;
begin
  Result := FMemo.Text;
end;

procedure TFRMaterialMemoEdit.SetMemoText(const AValue: TCaption);
begin
  FMemo.Text := AValue;
end;

function TFRMaterialMemoEdit.GetMemoTextHint: TTranslateString;
begin
  Result := FMemo.TextHint;
end;

procedure TFRMaterialMemoEdit.SetMemoTextHint(const AValue: TTranslateString);
begin
  FMemo.TextHint := AValue;
end;

function TFRMaterialMemoEdit.GetMemoReadOnly: Boolean;
begin
  Result := FMemo.ReadOnly;
end;

procedure TFRMaterialMemoEdit.SetMemoReadOnly(AValue: Boolean);
begin
  FMemo.ReadOnly := AValue;
end;

function TFRMaterialMemoEdit.GetMemoMaxLength: Integer;
begin
  Result := FMemo.MaxLength;
end;

procedure TFRMaterialMemoEdit.SetMemoMaxLength(AValue: Integer);
begin
  FMemo.MaxLength := AValue;
end;

function TFRMaterialMemoEdit.GetLabelCaption: TCaption;
begin
  Result := FLabel.Caption;
end;

procedure TFRMaterialMemoEdit.SetLabelCaption(const AValue: TCaption);
begin
  FLabel.Caption := AValue;
end;

function TFRMaterialMemoEdit.GetLabelSpacing: Integer;
begin
  Result := FLabel.BorderSpacing.Bottom;
end;

procedure TFRMaterialMemoEdit.SetLabelSpacing(AValue: Integer);
begin
  FLabel.BorderSpacing.Bottom := AValue;
end;

function TFRMaterialMemoEdit.GetOnMemoChange: TNotifyEvent;
begin
  Result := FMemo.OnChange;
end;

procedure TFRMaterialMemoEdit.SetOnMemoChange(AValue: TNotifyEvent);
begin
  FMemo.OnChange := AValue;
end;

function TFRMaterialMemoEdit.GetOnMemoKeyPress: TKeyPressEvent;
begin
  Result := FMemo.OnKeyPress;
end;

procedure TFRMaterialMemoEdit.SetOnMemoKeyPress(AValue: TKeyPressEvent);
begin
  FMemo.OnKeyPress := AValue;
end;

function TFRMaterialMemoEdit.GetOnMemoKeyDown: TKeyEvent;
begin
  Result := FMemo.OnKeyDown;
end;

procedure TFRMaterialMemoEdit.SetOnMemoKeyDown(AValue: TKeyEvent);
begin
  FMemo.OnKeyDown := AValue;
end;

procedure TFRMaterialMemoEdit.SetHelperText(const AValue: string);
begin
  if FHelperText = AValue then Exit;
  FHelperText := AValue;
  Invalidate;
end;

procedure TFRMaterialMemoEdit.SetErrorText(const AValue: string);
begin
  if FErrorText = AValue then Exit;
  FErrorText := AValue;
  Invalidate;
end;

procedure TFRMaterialMemoEdit.SetShowCharCounter(AValue: Boolean);
begin
  if FShowCharCounter = AValue then Exit;
  FShowCharCounter := AValue;
  Invalidate;
end;

procedure TFRMaterialMemoEdit.SetRequired(AValue: Boolean);
begin
  if FRequired = AValue then Exit;
  FRequired := AValue;
  Invalidate;
end;

procedure TFRMaterialMemoEdit.SetValidationState(AValue: TFRValidationState);
begin
  if FValidationState = AValue then Exit;
  FValidationState := AValue;
  Invalidate;
end;

function TFRMaterialMemoEdit.GetBottomMargin: Integer;
begin
  Result := 0;
  if (FHelperText <> '') or (FErrorText <> '') or FShowCharCounter then
    Result := Canvas.TextHeight('Hg') + 4;
end;

function TFRMaterialMemoEdit.GetDisplayHelperText: string;
begin
  if (FValidationState = vsInvalid) and (FErrorText <> '') then
    Result := FErrorText
  else
    Result := FHelperText;
end;

procedure TFRMaterialMemoEdit.InternalValidate;
var
  State: TFRValidationState;
begin
  State := vsNone;
  if FRequired and (Trim(FMemo.Text) = '') then
    State := vsInvalid
  else if (FMinLength > 0) and (Length(FMemo.Text) > 0) and (Length(FMemo.Text) < FMinLength) then
    State := vsInvalid
  else if Assigned(FOnValidate) then
    FOnValidate(Self, FMemo.Text, State);
  if State <> vsNone then
    ValidationState := State;
end;

procedure TFRMaterialMemoEdit.InternalMemoChange(Sender: TObject);
begin
  if FValidateMode = vmOnChange then
    InternalValidate;
  if FShowCharCounter then
    Invalidate;
end;

procedure TFRMaterialMemoEdit.Paint;
var
  LeftPos, RightPos, CR, DecoBottom, BottomExtra: Integer;
  DecoColor, HelperColor: TColor;
  HelperStr, CounterStr: string;
begin
  inherited Paint;

  if FMemo.Color <> Self.Color then
    FMemo.Color := Self.Color;

  CR := FBorderRadius * 2;
  BottomExtra := GetBottomMargin;
  DecoBottom := Height - BottomExtra;

  case FValidationState of
    vsValid:   DecoColor := FValidColor;
    vsInvalid: DecoColor := FInvalidColor;
  else
    if FFocused and Self.Enabled then
      DecoColor := AccentColor
    else
      DecoColor := DisabledColor;
  end;

  LeftPos  := 0;
  RightPos := Width;

  Canvas.Pen.Width := 1;
  Canvas.Pen.Color := Color;
  Canvas.Brush.Color := Color;
  Canvas.Rectangle(0, 0, Width, Height);

  Canvas.Pen.Color  := DecoColor;
  FLabel.Font.Color := DecoColor;

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
        Canvas.RoundRect(LeftPos, FMemo.Top - 2, RightPos, DecoBottom - 1, CR, CR)
      else
        Canvas.Rectangle(LeftPos, FMemo.Top - 2, RightPos, DecoBottom - 1);
      Canvas.Pen.Width := 1;
      Canvas.Brush.Style := bsSolid;
    end;
  end;

  { Required asterisk }
  if FRequired then
  begin
    Canvas.Font.Assign(FLabel.Font);
    Canvas.Font.Color := FInvalidColor;
    Canvas.Brush.Style := bsClear;
    Canvas.TextOut(FLabel.Left + Canvas.TextWidth(FLabel.Caption) + 2, FLabel.Top, ' *');
    Canvas.Brush.Style := bsSolid;
  end;

  { Helper / Counter }
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

    if FShowCharCounter and (FMemo.MaxLength > 0) then
    begin
      CounterStr := IntToStr(Length(FMemo.Text)) + '/' + IntToStr(FMemo.MaxLength);
      Canvas.Font.Color := DisabledColor;
      Canvas.TextOut(RightPos - Canvas.TextWidth(CounterStr) - 4, DecoBottom + 2, CounterStr);
    end;

    Canvas.Brush.Style := bsSolid;
  end;
end;

end.

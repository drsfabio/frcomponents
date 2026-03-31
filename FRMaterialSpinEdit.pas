unit FRMaterialSpinEdit;

{$mode objfpc}{$H+}

{ FRMaterialSpinEdit
  Campo numérico com botões +/- estilo Material Design.
  Usa TEdit internamente com dois TFRMaterialIconButton (Plus/Minus).

  Propriedades exclusivas:
    Value     — valor inteiro atual
    MinValue  — valor mínimo permitido
    MaxValue  — valor máximo permitido
    Increment — incremento por clique (+/-)

  Licença: LGPL v3 — mesma do bgracontrols
}

interface

uses
  FRMaterialTheme, FRMaterialIcons, FRMaterialMasks, Classes, Controls, Dialogs, ExtCtrls, Forms, Graphics,
  {$IFDEF FPC} LCLType, LResources, {$ENDIF} Menus, StdCtrls, SysUtils;

type

  { TFRMaterialSpinEdit }

  TFRMaterialSpinEdit = class(TCustomPanel)
  private
    FAccentColor: TColor;
    FDisabledColor: TColor;
    FLabel: TBoundLabel;
    FFocused: Boolean;
    FEdit: TEdit;
    FMinusButton: TFRMaterialIconButton;
    FPlusButton: TFRMaterialIconButton;
    FVariant: TFRMaterialVariant;
    FBorderRadius: Integer;
    FValidationState: TFRValidationState;
    FValidColor: TColor;
    FInvalidColor: TColor;
    FValue: Int64;
    FMinValue: Int64;
    FMaxValue: Int64;
    FIncrement: Int64;
    FOnValueChanged: TNotifyEvent;

    function GetLabelCaption: TCaption;
    procedure SetLabelCaption(const AValue: TCaption);
    function GetLabelSpacing: Integer;
    procedure SetLabelSpacing(AValue: Integer);
    procedure SetValue(AValue: Int64);
    procedure SetMinValue(AValue: Int64);
    procedure SetMaxValue(AValue: Int64);
    procedure SetValidationState(AValue: TFRValidationState);

    procedure MinusButtonClick(Sender: TObject);
    procedure PlusButtonClick(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure EditChange(Sender: TObject);
    procedure UpdateEditText;
    procedure ClampValue;
  protected
    procedure SetColor(AValue: TColor); override;
    procedure SetName(const AValue: TComponentName); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DoOnResize; override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Edit: TEdit read FEdit;
    property MinusButton: TFRMaterialIconButton read FMinusButton;
    property PlusButton: TFRMaterialIconButton read FPlusButton;
  published
    property Align;
    property AccentColor: TColor read FAccentColor write FAccentColor;
    property Anchors;
    property BorderSpacing;
    property Caption: TCaption read GetLabelCaption write SetLabelCaption;
    property Color;
    property Constraints;
    property DisabledColor: TColor read FDisabledColor write FDisabledColor;
    property EditLabel: TBoundLabel read FLabel;
    property Enabled;
    property Font;
    property Increment: Int64 read FIncrement write FIncrement default 1;
    property LabelSpacing: Integer read GetLabelSpacing write SetLabelSpacing default 4;
    property MaxValue: Int64 read FMaxValue write SetMaxValue default 100;
    property MinValue: Int64 read FMinValue write SetMinValue default 0;
    property ParentColor default False;
    property ParentFont default False;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Value: Int64 read FValue write SetValue default 0;
    property Variant: TFRMaterialVariant read FVariant write FVariant default mvStandard;
    property BorderRadius: Integer read FBorderRadius write FBorderRadius default 0;
    property ValidationState: TFRValidationState read FValidationState write SetValidationState default vsNone;
    property ValidColor: TColor read FValidColor write FValidColor default $0000B300;
    property InvalidColor: TColor read FInvalidColor write FInvalidColor default $000000FF;
    property Visible;

    property OnValueChanged: TNotifyEvent read FOnValueChanged write FOnValueChanged;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialspinedit_icon.lrs}
  {$ENDIF}
  RegisterComponents('BGRA Controls', [TFRMaterialSpinEdit]);
end;

{ TFRMaterialSpinEdit }

constructor TFRMaterialSpinEdit.Create(AOwner: TComponent);
begin
  FEdit := TEdit.Create(Self);
  FLabel := TBoundLabel.Create(Self);
  inherited Create(AOwner);

  Self.AccentColor  := clHighlight;
  Self.BorderStyle  := bsNone;
  Self.DisabledColor := $00B8AFA8;
  Self.ParentColor  := True;

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

  FEdit.Align := alBottom;
  FEdit.AutoSize := True;
  FEdit.Alignment := taCenter;
  FEdit.BorderSpacing.Around := 0;
  FEdit.BorderSpacing.Bottom := 4;
  FEdit.BorderSpacing.Left := 30;
  FEdit.BorderSpacing.Right := 30;
  FEdit.BorderSpacing.Top := 0;
  FEdit.BorderStyle := bsNone;
  FEdit.ParentColor := True;
  FEdit.Font.Color := clBlack;
  FEdit.Parent := Self;
  FEdit.ParentFont := True;
  FEdit.TabStop := True;
  FEdit.SetSubComponent(True);
  FEdit.OnKeyPress := @EditKeyPress;
  FEdit.OnChange := @EditChange;

  { Botão Minus (-) à esquerda }
  FMinusButton := TFRMaterialIconButton.Create(Self);
  FMinusButton.IconMode    := imMinus;
  FMinusButton.NormalColor := DisabledColor;
  FMinusButton.HoverColor  := AccentColor;
  FMinusButton.Width       := 22;
  FMinusButton.Height      := 22;
  FMinusButton.Visible     := True;
  FMinusButton.Parent      := Self;
  FMinusButton.OnClick     := @MinusButtonClick;
  FMinusButton.SetSubComponent(True);
  FMinusButton.Anchors     := [akLeft, akTop, akBottom];
  FMinusButton.AnchorSide[akLeft].Control := Self;
  FMinusButton.AnchorSide[akLeft].Side    := asrTop;
  FMinusButton.AnchorSide[akTop].Control  := FEdit;
  FMinusButton.AnchorSide[akTop].Side     := asrTop;
  FMinusButton.AnchorSide[akBottom].Control := FEdit;
  FMinusButton.AnchorSide[akBottom].Side    := asrBottom;
  FMinusButton.BorderSpacing.Left := 4;

  { Botão Plus (+) à direita }
  FPlusButton := TFRMaterialIconButton.Create(Self);
  FPlusButton.IconMode    := imPlus;
  FPlusButton.NormalColor := DisabledColor;
  FPlusButton.HoverColor  := AccentColor;
  FPlusButton.Width       := 22;
  FPlusButton.Height      := 22;
  FPlusButton.Visible     := True;
  FPlusButton.Parent      := Self;
  FPlusButton.OnClick     := @PlusButtonClick;
  FPlusButton.SetSubComponent(True);
  FPlusButton.Anchors     := [akRight, akTop, akBottom];
  FPlusButton.AnchorSide[akRight].Control := Self;
  FPlusButton.AnchorSide[akRight].Side    := asrBottom;
  FPlusButton.AnchorSide[akTop].Control   := FEdit;
  FPlusButton.AnchorSide[akTop].Side      := asrTop;
  FPlusButton.AnchorSide[akBottom].Control := FEdit;
  FPlusButton.AnchorSide[akBottom].Side    := asrBottom;
  FPlusButton.BorderSpacing.Right := 4;

  FVariant         := mvStandard;
  FBorderRadius    := 0;
  FValidationState := vsNone;
  FValidColor      := $0000B300;
  FInvalidColor    := $000000FF;
  FValue           := 0;
  FMinValue        := 0;
  FMaxValue        := 100;
  FIncrement       := 1;

  UpdateEditText;
end;

procedure TFRMaterialSpinEdit.SetColor(AValue: TColor);
begin
  inherited SetColor(AValue);
  FEdit.Color := AValue;
end;

procedure TFRMaterialSpinEdit.SetName(const AValue: TComponentName);
begin
  if (csDesigning in ComponentState) then
  begin
    if (FLabel.Caption = '') or AnsiSameText(FLabel.Caption, AValue) then
      FLabel.Caption := 'Label';
    if (FLabel.Name = '') or AnsiSameText(FLabel.Name, AValue) then
      FLabel.Name := AValue + 'SubLabel';
    if (FEdit.Name = '') or AnsiSameText(FEdit.Name, AValue) then
      FEdit.Name := AValue + 'SubEdit';
  end;
  inherited SetName(AValue);
end;

procedure TFRMaterialSpinEdit.DoEnter;
begin
  inherited DoEnter;
  FFocused := True;
  Invalidate;
end;

procedure TFRMaterialSpinEdit.DoExit;
begin
  FFocused := False;
  ClampValue;
  Invalidate;
  inherited DoExit;
end;

procedure TFRMaterialSpinEdit.DoOnResize;
var
  BtnSize: Integer;
begin
  BtnSize := FEdit.Height - 2;
  if BtnSize < 8 then BtnSize := 8;
  FMinusButton.Width  := BtnSize;
  FMinusButton.Height := BtnSize;
  FPlusButton.Width   := BtnSize;
  FPlusButton.Height  := BtnSize;
  FEdit.BorderSpacing.Left  := BtnSize + 8;
  FEdit.BorderSpacing.Right := BtnSize + 8;
  inherited DoOnResize;
end;

function TFRMaterialSpinEdit.GetLabelCaption: TCaption;
begin
  Result := FLabel.Caption;
end;

procedure TFRMaterialSpinEdit.SetLabelCaption(const AValue: TCaption);
begin
  FLabel.Caption := AValue;
end;

function TFRMaterialSpinEdit.GetLabelSpacing: Integer;
begin
  Result := FLabel.BorderSpacing.Bottom;
end;

procedure TFRMaterialSpinEdit.SetLabelSpacing(AValue: Integer);
begin
  FLabel.BorderSpacing.Bottom := AValue;
end;

procedure TFRMaterialSpinEdit.SetValue(AValue: Int64);
begin
  if AValue < FMinValue then AValue := FMinValue;
  if AValue > FMaxValue then AValue := FMaxValue;
  if FValue = AValue then Exit;
  FValue := AValue;
  UpdateEditText;
  if Assigned(FOnValueChanged) then
    FOnValueChanged(Self);
end;

procedure TFRMaterialSpinEdit.SetMinValue(AValue: Int64);
begin
  FMinValue := AValue;
  if FValue < FMinValue then
    Value := FMinValue;
end;

procedure TFRMaterialSpinEdit.SetMaxValue(AValue: Int64);
begin
  FMaxValue := AValue;
  if FValue > FMaxValue then
    Value := FMaxValue;
end;

procedure TFRMaterialSpinEdit.SetValidationState(AValue: TFRValidationState);
begin
  if FValidationState = AValue then Exit;
  FValidationState := AValue;
  Invalidate;
end;

procedure TFRMaterialSpinEdit.MinusButtonClick(Sender: TObject);
begin
  Value := FValue - FIncrement;
end;

procedure TFRMaterialSpinEdit.PlusButtonClick(Sender: TObject);
begin
  Value := FValue + FIncrement;
end;

procedure TFRMaterialSpinEdit.EditKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', '-', #8]) then
    Key := #0;
end;

procedure TFRMaterialSpinEdit.EditChange(Sender: TObject);
var
  V: Int64;
begin
  if TryStrToInt64(FEdit.Text, V) then
    FValue := V;
end;

procedure TFRMaterialSpinEdit.UpdateEditText;
begin
  FEdit.Text := IntToStr(FValue);
end;

procedure TFRMaterialSpinEdit.ClampValue;
var
  V: Int64;
begin
  if TryStrToInt64(FEdit.Text, V) then
  begin
    if V < FMinValue then V := FMinValue;
    if V > FMaxValue then V := FMaxValue;
    FValue := V;
  end;
  UpdateEditText;
end;

procedure TFRMaterialSpinEdit.Paint;
var
  LeftPos, RightPos, CR: Integer;
  DecoColor: TColor;
begin
  inherited Paint;

  if FEdit.Color <> Self.Color then
    FEdit.Color := Self.Color;

  CR := FBorderRadius * 2;

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

  Canvas.Pen.Width   := 1;
  Canvas.Pen.Color   := Color;
  Canvas.Brush.Color := Color;
  Canvas.Rectangle(0, 0, Width, Height);

  Canvas.Pen.Color  := DecoColor;
  FLabel.Font.Color := DecoColor;

  { Atualiza cor dos botões }
  if FMinusButton.NormalColor <> DecoColor then
  begin
    FMinusButton.NormalColor := DecoColor;
    FMinusButton.InvalidateCache;
  end;
  if FPlusButton.NormalColor <> DecoColor then
  begin
    FPlusButton.NormalColor := DecoColor;
    FPlusButton.InvalidateCache;
  end;

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
        Canvas.RoundRect(LeftPos, FEdit.Top - 2, RightPos, Height - 1, CR, CR)
      else
        Canvas.Rectangle(LeftPos, FEdit.Top - 2, RightPos, Height - 1);
      Canvas.Pen.Width := 1;
      Canvas.Brush.Style := bsSolid;
    end;
  end;
end;

end.

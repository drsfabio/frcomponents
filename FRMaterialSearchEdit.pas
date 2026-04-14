unit FRMaterialSearchEdit;

{$mode objfpc}{$H+}

{ FRMaterialSearchEdit
  Campo de busca com debounce estilo Material Design.
  Baseado em TFRMaterialEditBase<TMaskEdit> com busca temporizada.

  Propriedades exclusivas:
    DebounceInterval — intervalo em milissegundos antes de disparar OnSearch
    OnSearch         — evento disparado após o debounce com o texto digitado

  Licença: LGPL v3 — mesma do bgracontrols
}

interface

uses
  FRMaterial3Base, FRMaterialTheme, FRMaterialIcons, FRMaterialMasks, FRMaterialFieldPainter, Classes, Controls, Dialogs, ExtCtrls, Forms, Graphics,
  {$IFDEF FPC} LCLType, LResources, {$ENDIF} MaskEdit, Menus, StdCtrls, SysUtils;

type

  { Evento OnSearch — fornece o texto digitado }
  TFRSearchEvent = procedure(Sender: TObject; const ASearchText: string) of object;

  { TFRMaterialSearchEdit }

  TFRMaterialSearchEdit = class(TCustomPanel, IFRMaterialComponent)
  private
    FAccentColor: TColor;
    FDisabledColor: TColor;
    FLabel: TBoundLabel;
    FFocused: Boolean;
    FEdit: TEdit;
    FSearchButton: TFRMaterialIconButton;
    FClearButton: TFRMaterialIconButton;
    FVariant: TFRMaterialVariant;
    FBorderRadius: Integer;
    FAutoFontSize: Boolean;
    FDebounceTimer: TTimer;
    FDebounceInterval: Integer;
    FOnSearch: TFRSearchEvent;
    FIconStrokeWidth: Double;

    function GetEditText: TCaption;
    procedure SetEditText(const AValue: TCaption);
    function GetEditTextHint: TTranslateString;
    procedure SetEditTextHint(const AValue: TTranslateString);
    function GetEditReadOnly: Boolean;
    procedure SetEditReadOnly(AValue: Boolean);
    function GetEditMaxLength: Integer;
    procedure SetEditMaxLength(AValue: Integer);
    function GetLabelCaption: TCaption;
    procedure SetLabelCaption(const AValue: TCaption);
    function GetLabelSpacing: Integer;
    procedure SetLabelSpacing(AValue: Integer);

    procedure SetDebounceInterval(AValue: Integer);
    procedure SetIconStrokeWidth(AValue: Double);

    procedure SearchButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure InternalEditChange(Sender: TObject);
    procedure InternalEditKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure DebounceTimerFired(Sender: TObject);
    procedure UpdateClearButton;
    procedure DoSearch;
  protected
    FLabelAnimator: TFRMDFloatingLabelAnimator;
    procedure SetColor(AValue: TColor); override;
    procedure SetName(const AValue: TComponentName); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DoOnResize; override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Desregistra do theme manager e nila handlers de sub-controles antes
      do cascade destruction. Sem isto, WM_PAINT/WM_TIMER em fila podem
      disparar nos sub-controles ja parcialmente liberados. }
    procedure BeforeDestruction; override;
    procedure ApplyTheme(const AThemeManager: TObject); virtual;
    property Edit: TEdit read FEdit;
  published
    property Align;
    property AccentColor: TColor read FAccentColor write FAccentColor;
    property Anchors;
    property BorderSpacing;
    property Caption: TCaption read GetLabelCaption write SetLabelCaption;
    property Color;
    property Constraints;
    property Cursor;
    property DebounceInterval: Integer read FDebounceInterval write SetDebounceInterval default 400;
    property DisabledColor: TColor read FDisabledColor write FDisabledColor;
    property EditLabel: TBoundLabel read FLabel;
    property Enabled;
    property Font;
    property IconStrokeWidth: Double read FIconStrokeWidth write SetIconStrokeWidth;
    property LabelSpacing: Integer read GetLabelSpacing write SetLabelSpacing default 4;
    property MaxLength: Integer read GetEditMaxLength write SetEditMaxLength default 0;
    property ParentColor default False;
    property ParentFont default False;
    property PopupMenu;
    property ReadOnly: Boolean read GetEditReadOnly write SetEditReadOnly default False;
    property AutoFontSize: Boolean read FAutoFontSize write FAutoFontSize default True;
    property ShowHint;
    property ParentShowHint;
    property TabOrder;
    property TabStop default True;
    property Text: TCaption read GetEditText write SetEditText;
    property TextHint: TTranslateString read GetEditTextHint write SetEditTextHint;
    property Variant: TFRMaterialVariant read FVariant write FVariant default mvStandard;
    property BorderRadius: Integer read FBorderRadius write FBorderRadius default 0;
    property Visible;

    property OnSearch: TFRSearchEvent read FOnSearch write FOnSearch;
  end;

procedure Register;

implementation

uses Math;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialsearchedit_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialSearchEdit]);
end;

{ TFRMaterialSearchEdit }

constructor TFRMaterialSearchEdit.Create(AOwner: TComponent);
begin
  FEdit := TEdit.Create(Self);
  FLabel := TBoundLabel.Create(Self);
  inherited Create(AOwner);

  Self.BevelOuter   := bvNone;
  Self.AccentColor  := clHighlight;
  Self.BorderStyle  := bsNone;
  Self.DisabledColor := $00B8AFA8;
  Self.ParentColor  := True;
  
  FRMDRegisterComponent(Self);

  FLabel.Align := alNone;
  FLabel.Visible := False;
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
  FLabel.SetSubComponent(True);
  
  FLabelAnimator := TFRMDFloatingLabelAnimator.Create(Self);
  FLabelAnimator.SnapTo(1.0);

  FEdit.Align := alBottom;
  FEdit.AutoSize := True;
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
  FEdit.AddHandlerOnChange(@InternalEditChange);
  FEdit.OnKeyDown := @InternalEditKeyDown;

  { Container não participa do tab order — o foco vai direto para FEdit }
  inherited TabStop := False;

  { Ícone de lupa à esquerda }
  FSearchButton := TFRMaterialIconButton.Create(Self);
  FSearchButton.IconMode    := imSearch;
  FSearchButton.NormalColor := DisabledColor;
  FSearchButton.HoverColor  := AccentColor;
  FSearchButton.Width       := 22;
  FSearchButton.Height      := 22;
  FSearchButton.Visible     := True;
  FSearchButton.Parent      := Self;
  FSearchButton.OnClick     := @SearchButtonClick;
  FSearchButton.SetSubComponent(True);
  FSearchButton.Anchors     := [akLeft, akTop, akBottom];
  FSearchButton.AnchorSide[akLeft].Control := Self;
  FSearchButton.AnchorSide[akLeft].Side    := asrTop;
  FSearchButton.AnchorSide[akTop].Control  := FEdit;
  FSearchButton.AnchorSide[akTop].Side     := asrTop;
  FSearchButton.AnchorSide[akBottom].Control := FEdit;
  FSearchButton.AnchorSide[akBottom].Side    := asrBottom;
  FSearchButton.BorderSpacing.Left := MD3_FIELD_PADDING_H;

  { Botão de limpar à direita }
  FClearButton := TFRMaterialIconButton.Create(Self);
  FClearButton.IconMode := imClear;
  FClearButton.Width    := 22;
  FClearButton.Height   := 22;
  FClearButton.Visible  := False;
  FClearButton.Parent   := Self;
  FClearButton.OnClick  := @ClearButtonClick;
  FClearButton.SetSubComponent(True);
  FClearButton.Anchors  := [akRight, akTop, akBottom];
  FClearButton.AnchorSide[akRight].Control := Self;
  FClearButton.AnchorSide[akRight].Side    := asrBottom;
  FClearButton.AnchorSide[akTop].Control   := FEdit;
  FClearButton.AnchorSide[akTop].Side      := asrTop;
  FClearButton.AnchorSide[akBottom].Control := FEdit;
  FClearButton.AnchorSide[akBottom].Side    := asrBottom;
  FClearButton.BorderSpacing.Right := 4;

  { Timer de debounce }
  FDebounceTimer := TTimer.Create(Self);
  FDebounceTimer.Enabled  := False;
  FDebounceTimer.Interval := 400;
  FDebounceTimer.OnTimer  := @DebounceTimerFired;

  FVariant          := mvStandard;
  FBorderRadius     := 0;
  FAutoFontSize     := True;
  FDebounceInterval := 400;
  FIconStrokeWidth  := 0;
end;

procedure TFRMaterialSearchEdit.BeforeDestruction;
begin
  { Unregister cedo — impede callbacks de tema em Self enquanto children
    sao destruidos. }
  FRMDUnregisterComponent(Self);

  { Desativa e nila handlers dos sub-controles antes do cascade para que
    mensagens enfileiradas (timer, mouse, key) nao disparem em Self ja
    meio-destruido. Os sub-controles em si serao liberados pela owner
    chain do inherited. }
  if Assigned(FDebounceTimer) then
  begin
    FDebounceTimer.Enabled := False;
    FDebounceTimer.OnTimer := nil;
  end;
  if Assigned(FSearchButton) then FSearchButton.OnClick := nil;
  if Assigned(FClearButton)  then FClearButton.OnClick  := nil;
  if Assigned(FEdit) then
  begin
    FEdit.OnKeyDown := nil;
    FEdit.RemoveAllHandlersOfObject(Self);
  end;

  inherited BeforeDestruction;
end;

destructor TFRMaterialSearchEdit.Destroy;
begin
  { BeforeDestruction ja desregistrou e desarmou handlers. Aqui apenas
    libera recursos proprios (FLabelAnimator). Os sub-controles sao
    liberados pela owner chain. }
  if Assigned(FLabelAnimator) then FreeAndNil(FLabelAnimator);
  inherited Destroy;
end;

procedure TFRMaterialSearchEdit.ApplyTheme(const AThemeManager: TObject);
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

  Self.Font.Color   := MD3Colors.OnSurface;
  FEdit.Font.Color  := MD3Colors.OnSurface;
  FLabel.Font.Color := MD3Colors.OnSurfaceVariant;

  FSearchButton.NormalColor := MD3Colors.OnSurfaceVariant;
  FSearchButton.HoverColor  := MD3Colors.Primary;
  FSearchButton.InvalidateCache;
  if Assigned(FClearButton) then
  begin
    FClearButton.NormalColor := MD3Colors.OnSurfaceVariant;
    FClearButton.HoverColor  := MD3Colors.Error;
    FClearButton.InvalidateCache;
  end;

  Invalidate;
end;

procedure TFRMaterialSearchEdit.SetColor(AValue: TColor);
begin
  inherited SetColor(AValue);
  FEdit.Color := AValue;
end;

procedure TFRMaterialSearchEdit.SetName(const AValue: TComponentName);
begin
  if (csDesigning in ComponentState) then
  begin
    if (FLabel.Caption = '') or AnsiSameText(FLabel.Caption, AValue) then
      FLabel.Caption := 'Buscar';
    if (FLabel.Name = '') or AnsiSameText(FLabel.Name, AValue) then
      FLabel.Name := AValue + 'SubLabel';
    if (FEdit.Name = '') or AnsiSameText(FEdit.Name, AValue) then
      FEdit.Name := AValue + 'SubEdit';
  end;
  inherited SetName(AValue);
end;

procedure TFRMaterialSearchEdit.DoEnter;
begin
  inherited DoEnter;
  FFocused := True;
  if Assigned(FLabelAnimator) then FLabelAnimator.FloatLabel;
  Invalidate;
  { Redireciona o foco para o edit interno }
  if FEdit.CanFocus then
    FEdit.SetFocus;
end;

procedure TFRMaterialSearchEdit.DoExit;
begin
  FFocused := False;
  if Assigned(FLabelAnimator) then
  begin
    if Trim(FEdit.Text) = '' then
      FLabelAnimator.InlineLabel
    else
      FLabelAnimator.FloatLabel;
  end;
  Invalidate;
  inherited DoExit;
end;

procedure TFRMaterialSearchEdit.DoOnResize;
var
  BtnSize: Integer;
begin
  BtnSize := FEdit.Height - 2;
  if BtnSize < 8 then BtnSize := 8;
  FSearchButton.Width  := BtnSize;
  FSearchButton.Height := BtnSize;
  FClearButton.Width   := BtnSize;
  FClearButton.Height  := BtnSize;
  FEdit.BorderSpacing.Left  := BtnSize + 8;
  FEdit.BorderSpacing.Right := BtnSize + 8;

  { Responsividade: adaptar Font.Size proporcionalmente à altura e densidade.
    Referência MD3: Height 56 → Font.Size 12.  Mínimo 8, máximo 16. }
  if FAutoFontSize then
    FEdit.Font.Size := MD3FontSizeForField(Self.Height, ddNormal);

  inherited DoOnResize;
end;

function TFRMaterialSearchEdit.GetEditText: TCaption;
begin
  Result := FEdit.Text;
end;

procedure TFRMaterialSearchEdit.SetEditText(const AValue: TCaption);
begin
  FEdit.Text := AValue;
end;

function TFRMaterialSearchEdit.GetEditTextHint: TTranslateString;
begin
  Result := FEdit.TextHint;
end;

procedure TFRMaterialSearchEdit.SetEditTextHint(const AValue: TTranslateString);
begin
  FEdit.TextHint := AValue;
end;

function TFRMaterialSearchEdit.GetEditReadOnly: Boolean;
begin
  Result := FEdit.ReadOnly;
end;

procedure TFRMaterialSearchEdit.SetEditReadOnly(AValue: Boolean);
begin
  FEdit.ReadOnly := AValue;
end;

function TFRMaterialSearchEdit.GetEditMaxLength: Integer;
begin
  Result := FEdit.MaxLength;
end;

procedure TFRMaterialSearchEdit.SetEditMaxLength(AValue: Integer);
begin
  FEdit.MaxLength := AValue;
end;

function TFRMaterialSearchEdit.GetLabelCaption: TCaption;
begin
  Result := FLabel.Caption;
end;

procedure TFRMaterialSearchEdit.SetLabelCaption(const AValue: TCaption);
begin
  FLabel.Caption := AValue;
end;

function TFRMaterialSearchEdit.GetLabelSpacing: Integer;
begin
  Result := FLabel.BorderSpacing.Bottom;
end;

procedure TFRMaterialSearchEdit.SetLabelSpacing(AValue: Integer);
begin
  FLabel.BorderSpacing.Bottom := AValue;
end;

procedure TFRMaterialSearchEdit.SetDebounceInterval(AValue: Integer);
begin
  if AValue < 50 then AValue := 50;
  FDebounceInterval := AValue;
  FDebounceTimer.Interval := AValue;
end;

procedure TFRMaterialSearchEdit.SetIconStrokeWidth(AValue: Double);
begin
  if FIconStrokeWidth = AValue then Exit;
  FIconStrokeWidth := AValue;
  FSearchButton.StrokeWidth := AValue;
  FClearButton.StrokeWidth  := AValue;
  FSearchButton.InvalidateCache;
  FClearButton.InvalidateCache;
end;

procedure TFRMaterialSearchEdit.SearchButtonClick(Sender: TObject);
begin
  DoSearch;
end;

procedure TFRMaterialSearchEdit.ClearButtonClick(Sender: TObject);
begin
  FEdit.Text := '';
  FDebounceTimer.Enabled := False;
  UpdateClearButton;
  if FEdit.CanFocus then
    FEdit.SetFocus;
  { Dispara busca vazia para resetar resultados }
  DoSearch;
end;

procedure TFRMaterialSearchEdit.InternalEditChange(Sender: TObject);
begin
  { Guard: OnChange pode disparar durante construcao antes de FDebounceTimer
    / FClearButton / FLabelAnimator estarem criados, ou durante destruicao. }
  if csDestroying in ComponentState then Exit;

  if Assigned(FClearButton) then
    UpdateClearButton;

  if Assigned(FLabelAnimator) then
  begin
    if (Trim(FEdit.Text) <> '') or FFocused then
      FLabelAnimator.FloatLabel
    else
      FLabelAnimator.InlineLabel;
  end;

  { Reinicia o debounce }
  if Assigned(FDebounceTimer) then
  begin
    FDebounceTimer.Enabled := False;
    FDebounceTimer.Enabled := True;
  end;
end;

procedure TFRMaterialSearchEdit.InternalEditKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    FDebounceTimer.Enabled := False;
    DoSearch;
    Key := 0;
  end;
end;

procedure TFRMaterialSearchEdit.DebounceTimerFired(Sender: TObject);
begin
  FDebounceTimer.Enabled := False;
  DoSearch;
end;

procedure TFRMaterialSearchEdit.UpdateClearButton;
var
  ShouldShow: Boolean;
begin
  ShouldShow := FEdit.Text <> '';
  if ShouldShow = FClearButton.Visible then Exit;
  FClearButton.Visible := ShouldShow;
end;

procedure TFRMaterialSearchEdit.DoSearch;
begin
  if Assigned(FOnSearch) then
    FOnSearch(Self, FEdit.Text);
end;

procedure TFRMaterialSearchEdit.Paint;
var
  DecoColor: TColor;
  P: TFRMDFieldPaintParams;
  ActionRightPos: Integer;
begin
  { Guard sistemico — impede que WM_PAINT tardias batam em sub-controles
    ja parcialmente destruidos. FRMDCanPaint checa csDestroying/csLoading/
    HandleAllocated/dimensoes em uma chamada so. }
  if not FRMDCanPaint(Self) then Exit;

  inherited Paint;

  if not Assigned(FEdit) then Exit;

  if FEdit.Color <> Self.Color then
    FEdit.Color := Self.Color;

  if FFocused and Self.Enabled then
    DecoColor := AccentColor
  else
    DecoColor := DisabledColor;

  if Assigned(FSearchButton) and (FSearchButton.NormalColor <> DecoColor) then
  begin
    FSearchButton.NormalColor := DecoColor;
    FSearchButton.InvalidateCache;
  end;

  ActionRightPos := FEdit.Left + FEdit.Width;
  if Assigned(FClearButton) and FClearButton.Visible then
    ActionRightPos := FClearButton.Left + FClearButton.Width;

  P.Canvas := Canvas;
  P.Rect := ClientRect;
  P.BgColor := Color;
  if Assigned(Parent) then P.ParentBgColor := Parent.Color else P.ParentBgColor := clNone;

  P.Variant := FVariant;
  P.Density := FRMDGetThemeDensity(FRMaterialDefaultThemeManager);
  P.BorderRadius := FBorderRadius;

  P.DecoColor := DecoColor;
  P.HelperColor := DisabledColor;
  P.DisabledColor := DisabledColor;

  P.IsFocused := FFocused;
  P.IsEnabled := Enabled;
  P.IsRequired := False;

  P.EditLeft := FEdit.Left;
  P.EditTop := FEdit.Top;
  P.EditWidth := FEdit.Width;
  P.EditHeight := FEdit.Height;

  P.ActionRight := ActionRightPos;
  P.BottomMargin := 0;

  P.HelperText := '';
  P.CharCounterText := '';
  P.PrefixText := '';
  P.SuffixText := '';

  P.EditFont := FEdit.Font;
  if Assigned(FLabel) then
  begin
    P.LabelFont := FLabel.Font;
    P.LabelRight := FLabel.Left + Canvas.TextWidth(FLabel.Caption);
    P.LabelTop := FLabel.Top;
    P.LabelText := FLabel.Caption;
  end;
  if Assigned(FLabelAnimator) then
    P.LabelProgress := FLabelAnimator.Progress
  else
    P.LabelProgress := 1.0;

  TFRMaterialFieldPainter.DrawField(P);
end;

end.

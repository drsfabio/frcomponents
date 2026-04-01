unit FRMaterialDateEdit;

{$mode objfpc}{$H+}

{ TFRMaterialDateEdit
  Componente de edição de data com estilo Material Design.
  Usa TEdit interno com máscara de data (dd/mm/yyyy ou mm/yyyy),
  botão SVG de calendário e popup de calendário nativo.

  Requer: Calendar (LCL), FRMaterialTheme, FRMaterialIcons
  Licença: LGPL v3 — mesma do bgracontrols
}

interface

uses
  FRMaterial3Base, FRMaterialTheme, FRMaterialIcons, FRMaterialFieldPainter, Classes, Calendar, Controls, ExtCtrls, Forms,
  Graphics, {$IFDEF FPC} LCLType, LResources, {$ENDIF} Menus, StdCtrls, SysUtils;

type

  TFRDateFormat = (dfDDMMYYYY, dfMMYYYY);

  { TFRMaterialDateEdit }

  TFRMaterialDateEdit = class(TCustomPanel)
  private
    FAccentColor: TColor;
    FDisabledColor: TColor;
    FLabel: TBoundLabel;
    FEdit: TEdit;
    FCalendarButton: TFRMaterialIconButton;
    FClearButton: TFRMaterialIconButton;
    FFocused: Boolean;
    FVariant: TFRMaterialVariant;
    FBorderRadius: Integer;
    FDateFormat: TFRDateFormat;
    FDate: TDateTime;
    FShowClearButton: Boolean;
    FOnClearButtonClick: TNotifyEvent;
    FUserOnChange: TNotifyEvent;
    FUserOnKeyDown: TKeyEvent;
    FUpdating: Boolean;

    { Calendar popup }
    FCalendarPopup: TForm;
    FCalendar: TCalendar;

    function IsNeededAdjustSize: Boolean;

    { Botão de limpeza }
    function GetShowClearButton: Boolean;
    procedure SetShowClearButton(AValue: Boolean);
    procedure ClearButtonClick(Sender: TObject);
    procedure UpdateClearButton;

    { Calendar button }
    procedure CalendarButtonClick(Sender: TObject);
    procedure CalendarDblClick(Sender: TObject);
    procedure CalendarPopupDeactivate(Sender: TObject);

    { Internal edit }
    procedure InternalEditChange(Sender: TObject);
    procedure InternalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure InternalKeyPress(Sender: TObject; var Key: Char);
    procedure ApplyMask;
    function ParseDate: TDateTime;
    procedure RefreshDisplay;

    { Segment navigation }
    function GetCurrentSegment: Integer;
    procedure SelectSegment(ASegment: Integer);
    procedure AdjustSegmentValue(ADelta: Integer);
    function IsTextComplete: Boolean;

    { Propriedades }
    function GetDate: TDateTime;
    procedure SetDate(AValue: TDateTime);
    procedure SetDateFormat(AValue: TFRDateFormat);
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
    function GetDirectInput: Boolean;
    procedure SetDirectInput(AValue: Boolean);

    { Eventos }
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
    procedure ClearDate;
    property Edit: TEdit read FEdit;
    property CalendarButton: TFRMaterialIconButton read FCalendarButton;
    property ClearButton: TFRMaterialIconButton read FClearButton;

  published
    property Align;
    property AccentColor: TColor read FAccentColor write FAccentColor;
    property Anchors;
    property BiDiMode;
    property BorderSpacing;
    property Caption: TCaption read GetLabelCaption write SetLabelCaption;
    property Color;
    property Constraints;
    property Cursor: TCursor read GetEditCursor write SetEditCursor default crDefault;
    property Date: TDateTime read GetDate write SetDate;
    property DateFormat: TFRDateFormat read FDateFormat write SetDateFormat default dfDDMMYYYY;
    property DirectInput: Boolean read GetDirectInput write SetDirectInput default True;
    property DisabledColor: TColor read FDisabledColor write FDisabledColor;
    property Variant: TFRMaterialVariant read FVariant write FVariant default mvStandard;
    property BorderRadius: Integer read FBorderRadius write FBorderRadius default 0;
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
    property ShowClearButton: Boolean read GetShowClearButton write SetShowClearButton default False;
    property ShowHint;
    property TabOrder;
    property TabStop: Boolean read GetEditTabStop write SetEditTabStop default True;
    property Text: TCaption read GetEditText write SetEditText;
    property TextHint: TTranslateString read GetEditTextHint write SetEditTextHint;
    property Visible;

    property OnChange: TNotifyEvent read GetOnChange write SetOnChange;
    property OnChangeBounds;
    property OnClearButtonClick: TNotifyEvent read FOnClearButtonClick write FOnClearButtonClick;
    property OnClick: TNotifyEvent read GetOnClick write SetOnClick;
    property OnEditingDone: TNotifyEvent read GetOnEditingDone write SetOnEditingDone;
    property OnEnter: TNotifyEvent read GetOnEnter write SetOnEnter;
    property OnExit: TNotifyEvent read GetOnExit write SetOnExit;
    property OnKeyDown: TKeyEvent read GetOnKeyDown write SetOnKeyDown;
    property OnKeyPress: TKeyPressEvent read GetOnKeyPress write SetOnKeyPress;
    property OnKeyUp: TKeyEvent read GetOnKeyUp write SetOnKeyUp;
    property OnResize;
  end;

procedure Register;

implementation

uses
  DateUtils;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialdateedit_icon.lrs}
  {$ENDIF}
  RegisterComponents('BGRA Controls', [TFRMaterialDateEdit]);
end;

{ ── Helpers ── }

function OnlyDigits(const S: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(S) do
    if S[I] in ['0'..'9'] then
      Result := Result + S[I];
end;

function FormatDateMask(const ADigits: string; AFormat: TFRDateFormat): string;
var
  D: string;
begin
  D := ADigits;
  case AFormat of
    dfDDMMYYYY:
    begin
      { dd/mm/yyyy — max 8 digits }
      if Length(D) > 8 then D := Copy(D, 1, 8);
      Result := D;
      if Length(D) > 2 then
        Insert('/', Result, 3);
      if Length(D) > 4 then
        Insert('/', Result, 6);
    end;
    dfMMYYYY:
    begin
      { mm/yyyy — max 6 digits }
      if Length(D) > 6 then D := Copy(D, 1, 6);
      Result := D;
      if Length(D) > 2 then
        Insert('/', Result, 3);
    end;
  end;
end;

function MaxDigitsForFormat(AFormat: TFRDateFormat): Integer;
begin
  case AFormat of
    dfDDMMYYYY: Result := 8;
    dfMMYYYY:   Result := 6;
  else
    Result := 8;
  end;
end;

{ ── TFRMaterialDateEdit ── }

function TFRMaterialDateEdit.IsNeededAdjustSize: Boolean;
begin
  if (Self.Align in [alLeft, alRight, alClient]) then Exit(False);
  if (akTop in Self.Anchors) and (akBottom in Self.Anchors) then Exit(False);
  Result := True;
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
  FEdit.SetFocus;
  if Assigned(FOnClearButtonClick) then
    FOnClearButtonClick(Self);
end;

procedure TFRMaterialDateEdit.UpdateClearButton;
var
  ShouldShow: Boolean;
begin
  ShouldShow := FShowClearButton
    and (FEdit.Text <> '')
    and not FEdit.ReadOnly;

  if ShouldShow = FClearButton.Visible then Exit;

  DisableAlign;
  try
    FClearButton.Visible := ShouldShow;
    if ShouldShow then
    begin
      FClearButton.Anchors := [akTop, akRight, akBottom];
      FClearButton.AnchorSide[akRight].Control  := FCalendarButton;
      FClearButton.AnchorSide[akRight].Side     := asrTop;
      FClearButton.AnchorSide[akTop].Control    := FEdit;
      FClearButton.AnchorSide[akTop].Side       := asrTop;
      FClearButton.AnchorSide[akBottom].Control := FEdit;
      FClearButton.AnchorSide[akBottom].Side    := asrBottom;
      FClearButton.BorderSpacing.Right := 2;
      FEdit.BorderSpacing.Right := FClearButton.Width + FCalendarButton.Width + 10;
    end
    else
    begin
      FClearButton.Anchors := [];
      FEdit.BorderSpacing.Right := FCalendarButton.Width + 6;
    end;
  finally
    EnableAlign;
  end;
  Invalidate;
end;

procedure TFRMaterialDateEdit.ClearDate;
begin
  FDate := 0;
  FUpdating := True;
  try
    FEdit.Text := '';
  finally
    FUpdating := False;
  end;
  UpdateClearButton;
  if Assigned(FUserOnChange) then
    FUserOnChange(Self);
end;

{ --- Calendar button/popup --- }

procedure TFRMaterialDateEdit.CalendarButtonClick(Sender: TObject);
var
  P: TPoint;
begin
  if FEdit.ReadOnly then Exit;

  if Assigned(FCalendarPopup) and FCalendarPopup.Visible then
  begin
    FCalendarPopup.Close;
    Exit;
  end;

  if not Assigned(FCalendarPopup) then
  begin
    FCalendarPopup := TForm.CreateNew(Self);
    FCalendarPopup.BorderStyle := bsNone;
    FCalendarPopup.FormStyle := fsStayOnTop;
    FCalendarPopup.Width := 220;
    FCalendarPopup.Height := 180;
    FCalendarPopup.Color := MD3Colors.SurfaceContainerHigh;
    FCalendarPopup.OnDeactivate := @CalendarPopupDeactivate;

    FCalendar := TCalendar.Create(FCalendarPopup);
    FCalendar.Parent := FCalendarPopup;
    FCalendar.Align := alClient;
    FCalendar.OnDblClick := @CalendarDblClick;
  end;

  { Set calendar to current date if valid }
  if FDate > 1 then
    FCalendar.DateTime := FDate
  else
    FCalendar.DateTime := Now;

  { Position popup below the component, clamped to screen bounds }
  P := Self.ClientToScreen(Point(0, Self.Height));
  if P.X + FCalendarPopup.Width > Screen.Width then
    P.X := Screen.Width - FCalendarPopup.Width;
  if P.Y + FCalendarPopup.Height > Screen.Height then
    P.Y := P.Y - Self.Height - FCalendarPopup.Height; { flip above }
  FCalendarPopup.Left := P.X;
  FCalendarPopup.Top  := P.Y;
  FCalendarPopup.Show;
end;

procedure TFRMaterialDateEdit.CalendarDblClick(Sender: TObject);
begin
  Date := FCalendar.DateTime;
  FCalendarPopup.Close;
  FEdit.SetFocus;
end;

procedure TFRMaterialDateEdit.CalendarPopupDeactivate(Sender: TObject);
begin
  FCalendarPopup.Close;
end;

{ --- Internal edit --- }

procedure TFRMaterialDateEdit.InternalEditChange(Sender: TObject);
begin
  if FUpdating then Exit;
  ApplyMask;
  FDate := ParseDate;
  UpdateClearButton;
  if Assigned(FUserOnChange) then
    FUserOnChange(Self);
end;

procedure TFRMaterialDateEdit.InternalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Seg, MaxSeg: Integer;
begin
  if IsTextComplete then
  begin
    case Key of
      VK_UP:
      begin
        AdjustSegmentValue(1);
        Key := 0;
      end;
      VK_DOWN:
      begin
        AdjustSegmentValue(-1);
        Key := 0;
      end;
      VK_LEFT:
      begin
        Seg := GetCurrentSegment;
        if Seg > 0 then
        begin
          SelectSegment(Seg - 1);
          Key := 0;
        end;
      end;
      VK_RIGHT:
      begin
        Seg := GetCurrentSegment;
        case FDateFormat of
          dfDDMMYYYY: MaxSeg := 2;
          dfMMYYYY:   MaxSeg := 1;
        else MaxSeg := 2;
        end;
        if Seg < MaxSeg then
        begin
          SelectSegment(Seg + 1);
          Key := 0;
        end;
      end;
    end;
  end;
  if Assigned(FUserOnKeyDown) then
    FUserOnKeyDown(Sender, Key, Shift);
end;

procedure TFRMaterialDateEdit.InternalKeyPress(Sender: TObject; var Key: Char);
begin
  { Allow digits, backspace, and delete }
  if not (Key in ['0'..'9', #8, #127]) then
    Key := #0;
end;

procedure TFRMaterialDateEdit.ApplyMask;
var
  Digits, Formatted: string;
  OldSelStart: Integer;
begin
  FUpdating := True;
  try
    Digits := OnlyDigits(FEdit.Text);
    if Length(Digits) > MaxDigitsForFormat(FDateFormat) then
      Digits := Copy(Digits, 1, MaxDigitsForFormat(FDateFormat));
    Formatted := FormatDateMask(Digits, FDateFormat);
    OldSelStart := Length(Formatted);
    if FEdit.Text <> Formatted then
    begin
      FEdit.Text := Formatted;
      FEdit.SelStart := OldSelStart;
    end;
  finally
    FUpdating := False;
  end;
end;

function TFRMaterialDateEdit.ParseDate: TDateTime;
var
  Digits: string;
  D, M, Y: Word;
begin
  Result := 0;
  Digits := OnlyDigits(FEdit.Text);
  case FDateFormat of
    dfDDMMYYYY:
    begin
      if Length(Digits) <> 8 then Exit;
      D := StrToIntDef(Copy(Digits, 1, 2), 0);
      M := StrToIntDef(Copy(Digits, 3, 2), 0);
      Y := StrToIntDef(Copy(Digits, 5, 4), 0);
      if (D < 1) or (D > 31) or (M < 1) or (M > 12) or (Y < 1) then Exit;
      try
        Result := EncodeDate(Y, M, D);
      except
        Result := 0;
      end;
    end;
    dfMMYYYY:
    begin
      if Length(Digits) <> 6 then Exit;
      M := StrToIntDef(Copy(Digits, 1, 2), 0);
      Y := StrToIntDef(Copy(Digits, 3, 4), 0);
      if (M < 1) or (M > 12) or (Y < 1) then Exit;
      try
        Result := EncodeDate(Y, M, 1);
      except
        Result := 0;
      end;
    end;
  end;
end;

{ --- Segment navigation --- }

function TFRMaterialDateEdit.IsTextComplete: Boolean;
begin
  case FDateFormat of
    dfDDMMYYYY: Result := Length(FEdit.Text) = 10; { dd/mm/yyyy }
    dfMMYYYY:   Result := Length(FEdit.Text) = 7;  { mm/yyyy }
  else
    Result := False;
  end;
end;

function TFRMaterialDateEdit.GetCurrentSegment: Integer;
var
  Pos: Integer;
begin
  Pos := FEdit.SelStart;
  case FDateFormat of
    dfDDMMYYYY:
    begin
      if Pos < 3 then Result := 0       { Day }
      else if Pos < 6 then Result := 1  { Month }
      else Result := 2;                 { Year }
    end;
    dfMMYYYY:
    begin
      if Pos < 3 then Result := 0       { Month }
      else Result := 1;                 { Year }
    end;
  else
    Result := 0;
  end;
end;

procedure TFRMaterialDateEdit.SelectSegment(ASegment: Integer);
begin
  case FDateFormat of
    dfDDMMYYYY:
      case ASegment of
        0: begin FEdit.SelStart := 0; FEdit.SelLength := 2; end;
        1: begin FEdit.SelStart := 3; FEdit.SelLength := 2; end;
        2: begin FEdit.SelStart := 6; FEdit.SelLength := 4; end;
      end;
    dfMMYYYY:
      case ASegment of
        0: begin FEdit.SelStart := 0; FEdit.SelLength := 2; end;
        1: begin FEdit.SelStart := 3; FEdit.SelLength := 4; end;
      end;
  end;
end;

procedure TFRMaterialDateEdit.AdjustSegmentValue(ADelta: Integer);
var
  D, M, Y: Word;
  Seg: Integer;
begin
  if FDate < 1 then
  begin
    FDate := SysUtils.Date;
    RefreshDisplay;
  end;
  if FDate < 1 then Exit;

  Seg := GetCurrentSegment;
  DecodeDate(FDate, Y, M, D);

  case FDateFormat of
    dfDDMMYYYY:
      case Seg of
        0: begin
             D := D + ADelta;
             if D < 1 then D := 31;
             if D > 31 then D := 1;
           end;
        1: begin
             M := M + ADelta;
             if M < 1 then M := 12;
             if M > 12 then M := 1;
           end;
        2: begin
             Y := Y + ADelta;
             if Y < 1 then Y := 9999;
             if Y > 9999 then Y := 1;
           end;
      end;
    dfMMYYYY:
      case Seg of
        0: begin
             M := M + ADelta;
             if M < 1 then M := 12;
             if M > 12 then M := 1;
           end;
        1: begin
             Y := Y + ADelta;
             if Y < 1 then Y := 9999;
             if Y > 9999 then Y := 1;
           end;
      end;
  end;

  { Clamp day if it exceeds valid range for new month/year }
  if D > DaysInAMonth(Y, M) then
    D := DaysInAMonth(Y, M);

  FDate := EncodeDate(Y, M, D);

  RefreshDisplay;
  SelectSegment(Seg);
  UpdateClearButton;

  if Assigned(FUserOnChange) then
    FUserOnChange(Self);
end;

procedure TFRMaterialDateEdit.RefreshDisplay;
var
  Y, M, D: Word;
begin
  FUpdating := True;
  try
    if FDate < 1 then
    begin
      FEdit.Text := '';
      Exit;
    end;
    DecodeDate(FDate, Y, M, D);
    case FDateFormat of
      dfDDMMYYYY:
        FEdit.Text := Format('%.2d/%.2d/%.4d', [D, M, Y]);
      dfMMYYYY:
        FEdit.Text := Format('%.2d/%.4d', [M, Y]);
    end;
  finally
    FUpdating := False;
  end;
end;

{ --- Getters/Setters --- }

function TFRMaterialDateEdit.GetDate: TDateTime;
begin
  Result := FDate;
end;

procedure TFRMaterialDateEdit.SetDate(AValue: TDateTime);
begin
  if FDate = AValue then Exit;
  FDate := AValue;
  RefreshDisplay;
  UpdateClearButton;
end;

procedure TFRMaterialDateEdit.SetDateFormat(AValue: TFRDateFormat);
begin
  if FDateFormat = AValue then Exit;
  FDateFormat := AValue;
  RefreshDisplay;
end;

function TFRMaterialDateEdit.GetDirectInput: Boolean;
begin
  Result := not FEdit.ReadOnly;
end;

procedure TFRMaterialDateEdit.SetDirectInput(AValue: Boolean);
begin
  FEdit.ReadOnly := not AValue;
end;

function TFRMaterialDateEdit.GetEditCursor: TCursor;
begin
  Result := FEdit.Cursor;
end;

procedure TFRMaterialDateEdit.SetEditCursor(AValue: TCursor);
begin
  FEdit.Cursor := AValue;
end;

function TFRMaterialDateEdit.GetEditPopupMenu: TPopupMenu;
begin
  if csDestroying in ComponentState then Exit(nil);
  Result := FEdit.PopupMenu;
end;

procedure TFRMaterialDateEdit.SetEditPopupMenu(AValue: TPopupMenu);
begin
  FEdit.PopupMenu := AValue;
end;

function TFRMaterialDateEdit.GetEditReadOnly: Boolean;
begin
  Result := FEdit.ReadOnly;
end;

procedure TFRMaterialDateEdit.SetEditReadOnly(AValue: Boolean);
begin
  FEdit.ReadOnly := AValue;
  UpdateClearButton;
end;

function TFRMaterialDateEdit.GetEditTabStop: Boolean;
begin
  Result := FEdit.TabStop;
end;

procedure TFRMaterialDateEdit.SetEditTabStop(AValue: Boolean);
begin
  FEdit.TabStop := AValue;
end;

function TFRMaterialDateEdit.GetEditText: TCaption;
begin
  Result := FEdit.Text;
end;

procedure TFRMaterialDateEdit.SetEditText(const AValue: TCaption);
begin
  FEdit.Text := AValue;
end;

function TFRMaterialDateEdit.GetEditTextHint: TTranslateString;
begin
  Result := FEdit.TextHint;
end;

procedure TFRMaterialDateEdit.SetEditTextHint(const AValue: TTranslateString);
begin
  FEdit.TextHint := AValue;
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

{ --- Event getters/setters --- }

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
  Result := FEdit.OnClick;
end;

procedure TFRMaterialDateEdit.SetOnClick(AValue: TNotifyEvent);
begin
  FEdit.OnClick := AValue;
end;

function TFRMaterialDateEdit.GetOnEditingDone: TNotifyEvent;
begin
  Result := FEdit.OnEditingDone;
end;

procedure TFRMaterialDateEdit.SetOnEditingDone(AValue: TNotifyEvent);
begin
  FEdit.OnEditingDone := AValue;
end;

function TFRMaterialDateEdit.GetOnEnter: TNotifyEvent;
begin
  Result := FEdit.OnEnter;
end;

procedure TFRMaterialDateEdit.SetOnEnter(AValue: TNotifyEvent);
begin
  FEdit.OnEnter := AValue;
end;

function TFRMaterialDateEdit.GetOnExit: TNotifyEvent;
begin
  Result := FEdit.OnExit;
end;

procedure TFRMaterialDateEdit.SetOnExit(AValue: TNotifyEvent);
begin
  FEdit.OnExit := AValue;
end;

function TFRMaterialDateEdit.GetOnKeyDown: TKeyEvent;
begin
  Result := FUserOnKeyDown;
end;

procedure TFRMaterialDateEdit.SetOnKeyDown(AValue: TKeyEvent);
begin
  FUserOnKeyDown := AValue;
end;

function TFRMaterialDateEdit.GetOnKeyPress: TKeyPressEvent;
begin
  Result := FEdit.OnKeyPress;
end;

procedure TFRMaterialDateEdit.SetOnKeyPress(AValue: TKeyPressEvent);
begin
  FEdit.OnKeyPress := AValue;
end;

function TFRMaterialDateEdit.GetOnKeyUp: TKeyEvent;
begin
  Result := FEdit.OnKeyUp;
end;

procedure TFRMaterialDateEdit.SetOnKeyUp(AValue: TKeyEvent);
begin
  FEdit.OnKeyUp := AValue;
end;

{ --- Protected --- }

procedure TFRMaterialDateEdit.SetAnchors(const AValue: TAnchors);
begin
  if Self.Anchors = AValue then Exit;
  inherited SetAnchors(AValue);
  if not (csLoading in ComponentState) then Self.DoOnResize;
end;

procedure TFRMaterialDateEdit.SetColor(AValue: TColor);
begin
  inherited SetColor(AValue);
  FEdit.Color := AValue;
end;

procedure TFRMaterialDateEdit.SetName(const AValue: TComponentName);
begin
  if csDesigning in ComponentState then
  begin
    if (FLabel.Caption = '') or AnsiSameText(FLabel.Caption, Name) then
      FLabel.Caption := 'Data';
    if (FLabel.Name = '') or AnsiSameText(FLabel.Name, Name) then
      FLabel.Name := AValue + 'SubLabel';
    if (FEdit.Name = '') or AnsiSameText(FEdit.Name, Name) then
      FEdit.Name := AValue + 'SubEdit';
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

  if Assigned(FClearButton) then
  begin
    FClearButton.Width  := FEdit.Height - 2;
    FClearButton.Height := FEdit.Height - 2;
  end;
  if Assigned(FCalendarButton) then
  begin
    FCalendarButton.Width  := FEdit.Height - 2;
    FCalendarButton.Height := FEdit.Height - 2;
  end;

  inherited DoOnResize;
end;

procedure TFRMaterialDateEdit.Paint;
var
  DecoColor: TColor;
  P: TFRMDFieldPaintParams;
  ActionRightPos: Integer;
begin
  inherited Paint;

  if FEdit.Color <> Self.Color then
    FEdit.Color := Self.Color;

  if FFocused and Self.Enabled then
    DecoColor := AccentColor
  else
    DecoColor := DisabledColor;

  ActionRightPos := FCalendarButton.Left + FCalendarButton.Width;
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
  P.LabelFont := FLabel.Font;
  P.LabelRight := FLabel.Left + Canvas.TextWidth(FLabel.Caption);
  P.LabelTop := FLabel.Top;

  TFRMaterialFieldPainter.DrawField(P);

  FLabel.Font.Color := DecoColor;
end;

constructor TFRMaterialDateEdit.Create(AOwner: TComponent);
begin
  FEdit  := TEdit.Create(Self);
  FLabel := TBoundLabel.Create(Self);
  inherited Create(AOwner);

  Self.BevelOuter    := bvNone;
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
  FEdit.BorderSpacing.Around := 0;
  FEdit.BorderSpacing.Bottom := 4;
  FEdit.BorderSpacing.Left   := 4;
  FEdit.BorderSpacing.Right  := 30;
  FEdit.BorderSpacing.Top    := 0;
  FEdit.BorderStyle          := bsNone;
  FEdit.ParentColor          := True;
  FEdit.Parent               := Self;
  FEdit.ParentFont           := True;
  FEdit.ParentBiDiMode       := True;
  FEdit.TabStop              := True;
  FEdit.SetSubComponent(True);
  FEdit.OnKeyDown  := @InternalKeyDown;
  FEdit.OnKeyPress := @InternalKeyPress;
  FEdit.AddHandlerOnChange(@InternalEditChange);
  FEdit.Text := '';

  { Botão calendário — ícone SVG }
  FCalendarButton := TFRMaterialIconButton.Create(Self);
  FCalendarButton.IconMode    := imCalendar;
  FCalendarButton.NormalColor := $00B8AFA8;
  FCalendarButton.HoverColor  := clHighlight;
  FCalendarButton.Width       := 22;
  FCalendarButton.Height      := 22;
  FCalendarButton.Visible     := True;
  FCalendarButton.Parent      := Self;
  FCalendarButton.OnClick     := @CalendarButtonClick;
  FCalendarButton.SetSubComponent(True);
  FCalendarButton.Anchors     := [akTop, akRight, akBottom];
  FCalendarButton.AnchorSide[akRight].Control  := Self;
  FCalendarButton.AnchorSide[akRight].Side     := asrBottom;
  FCalendarButton.AnchorSide[akTop].Control    := FEdit;
  FCalendarButton.AnchorSide[akTop].Side       := asrTop;
  FCalendarButton.AnchorSide[akBottom].Control := FEdit;
  FCalendarButton.AnchorSide[akBottom].Side    := asrBottom;
  FCalendarButton.BorderSpacing.Right := 4;

  { Botão de limpeza — ícone SVG "×" }
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
  FDateFormat      := dfDDMMYYYY;
  FDate            := 0;
  FUpdating        := False;
  FCalendarPopup   := nil;
end;

destructor TFRMaterialDateEdit.Destroy;
begin
  FreeAndNil(FCalendarPopup);
  inherited Destroy;
end;

end.

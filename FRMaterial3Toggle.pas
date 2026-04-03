unit FRMaterial3Toggle;

{$mode objfpc}{$H+}

{ Material Design 3 — Toggle controls.

  TFRMaterialSwitch      — On/Off toggle (52×32 track, sliding handle)
  TFRMaterialCheckBox    — Checkbox with check mark (tri-state support)
  TFRMaterialRadioButton — Radio button with dot indicator

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, StdCtrls,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base;

type
  { ── TFRMaterialSwitch ── }

  TFRMaterialSwitch = class(TFRMaterial3Control)
  private
    FChecked: Boolean;
    FOnChange: TNotifyEvent;
    procedure SetChecked(AValue: Boolean);
  protected
    procedure Paint; override;
    procedure Click; override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Checked: Boolean read FChecked write SetChecked default False;
    property Enabled;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
  end;

  { ── TFRMaterialCheckBox ── }

  TFRMaterialCheckBox = class(TFRMaterial3Control)
  private
    FState: TCheckBoxState;
    FAllowGrayed: Boolean;
    FOnChange: TNotifyEvent;
    procedure SetState(AValue: TCheckBoxState);
    procedure SetAllowGrayed(AValue: Boolean);
    function GetChecked: Boolean;
    procedure SetChecked(AValue: Boolean);
  protected
    procedure Paint; override;
    procedure Click; override;
    procedure Resize; override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Checked: Boolean read GetChecked write SetChecked default False;
    property State: TCheckBoxState read FState write SetState default cbUnchecked;
    property AllowGrayed: Boolean read FAllowGrayed write SetAllowGrayed default False;
    property Caption;
    property Font;
    property Enabled;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
  end;

  { ── TFRMaterialRadioButton ── }

  TFRMaterialRadioButton = class(TFRMaterial3Control)
  private
    FChecked: Boolean;
    FGroupIndex: Integer;
    FOnChange: TNotifyEvent;
    procedure SetChecked(AValue: Boolean);
    procedure UncheckSiblings;
  protected
    procedure Paint; override;
    procedure Click; override;
    procedure Resize; override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Checked: Boolean read FChecked write SetChecked default False;
    property GroupIndex: Integer read FGroupIndex write FGroupIndex default 0;
    property Caption;
    property Font;
    property Enabled;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
  end;

procedure Register;

implementation

uses Math;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialswitch_icon.lrs}
    {$I icons\frmaterialcheckbox_icon.lrs}
    {$I icons\frmaterialradiobutton_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialSwitch, TFRMaterialCheckBox, TFRMaterialRadioButton]);
end;

{ ── TFRMaterialSwitch ── }

constructor TFRMaterialSwitch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FChecked := False;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
end;

class function TFRMaterialSwitch.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 52;
  Result.cy := 32;
end;

procedure TFRMaterialSwitch.SetChecked(AValue: Boolean);
begin
  if FChecked = AValue then Exit;
  FChecked := AValue;
  Invalidate;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TFRMaterialSwitch.Click;
begin
  Checked := not Checked;
  inherited;
end;

procedure TFRMaterialSwitch.Paint;
var
  bmp: TBGRABitmap;
  trackColor, handleColor, stateColor: TColor;
  trackR, handleX, handleSize: Integer;
  op: Byte;
begin
  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    trackR := Height div 2;

    if FChecked then
    begin
      trackColor := MD3Colors.Primary;
      handleColor := MD3Colors.OnPrimary;
      stateColor := MD3Colors.OnPrimary;
      handleSize := 24;
      handleX := Width - handleSize div 2 - 4;
    end
    else
    begin
      trackColor := MD3Colors.SurfaceContainerHighest;
      handleColor := MD3Colors.Outline;
      stateColor := MD3Colors.OnSurface;
      handleSize := 16;
      handleX := handleSize div 2 + 4;
    end;

    if not Enabled then
    begin
      trackColor := MD3Colors.SurfaceContainerHighest;
      handleColor := MD3Colors.OnSurface;
    end;

    { Track }
    MD3FillRoundRect(bmp, 0, 0, Width - 1, Height - 1, trackR, trackColor,
      IfThen(Enabled, 255, 30));

    { Track border when unchecked }
    if not FChecked then
      MD3RoundRect(bmp, 0.5, 0.5, Width - 1.5, Height - 1.5, trackR,
        MD3Colors.Outline, 2.0, IfThen(Enabled, 255, 30));

    { State layer on handle — only for hover/press, not focus }
    if Enabled then
    begin
      op := MD3StateOpacity(InteractionState);
      if (op > 0) and (InteractionState in [isHovered, isPressed]) then
      begin
        { Clamp center so the 40px circle stays within component bounds }
        bmp.FillEllipseAntialias(
          EnsureRange(handleX, 20, Width - 20),
          Height / 2.0, 20, 20,
          ColorToBGRA(ColorToRGB(stateColor), op));
      end;
    end;

    { Handle }
    bmp.FillEllipseAntialias(handleX, Height / 2.0,
      handleSize / 2.0, handleSize / 2.0,
      ColorToBGRA(ColorToRGB(handleColor), IfThen(Enabled, 255, 97)));

    { Check icon inside handle when checked }
    if FChecked and (handleSize >= 24) then
    begin
      bmp.DrawLineAntialias(handleX - 4, Height / 2.0,
        handleX - 1, Height / 2.0 + 3,
        ColorToBGRA(ColorToRGB(trackColor)), 2.0);
      bmp.DrawLineAntialias(handleX - 1, Height / 2.0 + 3,
        handleX + 5, Height / 2.0 - 3,
        ColorToBGRA(ColorToRGB(trackColor)), 2.0);
    end;

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;
end;

{ ── TFRMaterialCheckBox ── }

constructor TFRMaterialCheckBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FState := cbUnchecked;
  FAllowGrayed := False;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
  Font.Size := 10;
end;

class function TFRMaterialCheckBox.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 150;
  Result.cy := 24;
end;

function TFRMaterialCheckBox.GetChecked: Boolean;
begin
  Result := FState = cbChecked;
end;

procedure TFRMaterialCheckBox.SetChecked(AValue: Boolean);
begin
  if AValue then
    State := cbChecked
  else
    State := cbUnchecked;
end;

procedure TFRMaterialCheckBox.SetState(AValue: TCheckBoxState);
begin
  if FState = AValue then Exit;
  FState := AValue;
  Invalidate;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TFRMaterialCheckBox.SetAllowGrayed(AValue: Boolean);
begin
  if FAllowGrayed = AValue then Exit;
  FAllowGrayed := AValue;
end;

procedure TFRMaterialCheckBox.Click;
begin
  case FState of
    cbUnchecked:
      if FAllowGrayed then State := cbGrayed
      else State := cbChecked;
    cbGrayed:
      State := cbChecked;
    cbChecked:
      State := cbUnchecked;
  end;
  inherited;
end;

procedure TFRMaterialCheckBox.Resize;
begin
  inherited Resize;
  { Responsividade: adaptar Font.Size proporcionalmente à altura.
    Referência MD3: Height 24 → Font.Size 10.  Mínimo 8, máximo 14. }
  Font.Size := EnsureRange(Height * 10 div 24, 8, 14);
end;

procedure TFRMaterialCheckBox.Paint;
var
  bmp: TBGRABitmap;
  boxSize, boxX, boxY: Integer;
  boxColor, checkColor, borderColor: TColor;
  aRect: TRect;
  op: Byte;
begin
  { Box proporcional à altura — referência: 18px para Height 24 }
  boxSize := EnsureRange(Height * 18 div 24, 12, 22);
  boxX := 2;
  boxY := (Height - boxSize) div 2;

  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    case FState of
      cbUnchecked:
      begin
        borderColor := MD3Colors.OnSurfaceVariant;
        MD3RoundRect(bmp, boxX + 0.5, boxY + 0.5,
          boxX + boxSize - 0.5, boxY + boxSize - 0.5, 2, borderColor, 2.0);
      end;
      cbChecked:
      begin
        boxColor := MD3Colors.Primary;
        checkColor := MD3Colors.OnPrimary;
        MD3FillRoundRect(bmp, boxX, boxY, boxX + boxSize, boxY + boxSize, 2, boxColor);
        { Check mark }
        bmp.DrawLineAntialias(boxX + 4, boxY + boxSize / 2.0,
          boxX + 7, boxY + boxSize - 5,
          ColorToBGRA(ColorToRGB(checkColor)), 2.0);
        bmp.DrawLineAntialias(boxX + 7, boxY + boxSize - 5,
          boxX + boxSize - 4, boxY + 5,
          ColorToBGRA(ColorToRGB(checkColor)), 2.0);
      end;
      cbGrayed:
      begin
        boxColor := MD3Colors.Primary;
        checkColor := MD3Colors.OnPrimary;
        MD3FillRoundRect(bmp, boxX, boxY, boxX + boxSize, boxY + boxSize, 2, boxColor);
        { Dash }
        bmp.DrawLineAntialias(boxX + 4, boxY + boxSize / 2.0,
          boxX + boxSize - 4, boxY + boxSize / 2.0,
          ColorToBGRA(ColorToRGB(checkColor)), 2.0);
      end;
    end;

    { State layer — circular per MD3 spec.
      Content color depends on state: Primary when checked, OnSurface otherwise. }
    if Enabled then
    begin
      op := MD3StateOpacity(InteractionState);
      if op > 0 then
      begin
        if FState = cbChecked then
          bmp.FillEllipseAntialias(boxX + boxSize / 2.0, boxY + boxSize / 2.0,
            17, 17, ColorToBGRA(ColorToRGB(MD3Colors.Primary), op))
        else
          bmp.FillEllipseAntialias(boxX + boxSize / 2.0, boxY + boxSize / 2.0,
            17, 17, ColorToBGRA(ColorToRGB(MD3Colors.OnSurface), op));
      end;
    end;

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { Caption text }
  if Caption <> '' then
  begin
    aRect := Rect(boxX + boxSize + 12, 0, Width, Height);
    Canvas.Font := Self.Font;
    MD3DrawText(Canvas, Caption, aRect, MD3Colors.OnSurface, taLeftJustify, True);
  end;
end;

{ ── TFRMaterialRadioButton ── }

constructor TFRMaterialRadioButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FChecked := False;
  FGroupIndex := 0;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
  Font.Size := 10;
end;

class function TFRMaterialRadioButton.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 150;
  Result.cy := 24;
end;

procedure TFRMaterialRadioButton.SetChecked(AValue: Boolean);
begin
  if FChecked = AValue then Exit;
  FChecked := AValue;
  if FChecked then
    UncheckSiblings;
  Invalidate;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TFRMaterialRadioButton.UncheckSiblings;
var
  i: Integer;
  Sibling: TFRMaterialRadioButton;
begin
  if Parent = nil then Exit;
  for i := 0 to Parent.ControlCount - 1 do
  begin
    if (Parent.Controls[i] is TFRMaterialRadioButton) and (Parent.Controls[i] <> Self) then
    begin
      Sibling := TFRMaterialRadioButton(Parent.Controls[i]);
      if Sibling.GroupIndex = FGroupIndex then
        Sibling.FChecked := False;
    end;
  end;
  Parent.Invalidate;
end;

procedure TFRMaterialRadioButton.Click;
begin
  if not FChecked then
    Checked := True;
  inherited;
end;

procedure TFRMaterialRadioButton.Resize;
begin
  inherited Resize;
  { Responsividade: adaptar Font.Size proporcionalmente à altura.
    Referência MD3: Height 24 → Font.Size 10.  Mínimo 8, máximo 14. }
  Font.Size := EnsureRange(Height * 10 div 24, 8, 14);
end;

procedure TFRMaterialRadioButton.Paint;
var
  bmp: TBGRABitmap;
  circSize, circX, circY, circR, dotR: Integer;
  ringColor: TColor;
  aRect: TRect;
begin
  { Proporcional à altura — referência: 20px para Height 24 }
  circSize := EnsureRange(Height * 20 div 24, 14, 24);
  circX := 2 + circSize div 2;
  circY := Height div 2;
  circR := circSize div 2;
  dotR  := EnsureRange(circSize * 5 div 20, 3, 7);

  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    if FChecked then
    begin
      ringColor := MD3Colors.Primary;
      { Outer ring }
      bmp.EllipseAntialias(circX, circY, circR, circR,
        ColorToBGRA(ColorToRGB(ringColor)), 2.0);
      { Inner dot }
      bmp.FillEllipseAntialias(circX, circY, dotR, dotR,
        ColorToBGRA(ColorToRGB(ringColor)));
    end
    else
    begin
      ringColor := MD3Colors.OnSurfaceVariant;
      bmp.EllipseAntialias(circX, circY, circR, circR,
        ColorToBGRA(ColorToRGB(ringColor)), 2.0);
    end;

    { State layer }
    if Enabled then
      MD3StateLayer(bmp, circX - 18, circY - 18, circX + 18, circY + 18,
        18, MD3Colors.OnSurface, InteractionState);

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  { Caption text }
  if Caption <> '' then
  begin
    aRect := Rect(circSize + 16, 0, Width, Height);
    Canvas.Font := Self.Font;
    MD3DrawText(Canvas, Caption, aRect, MD3Colors.OnSurface, taLeftJustify, True);
  end;
end;

end.

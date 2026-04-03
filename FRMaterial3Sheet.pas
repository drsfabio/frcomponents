unit FRMaterial3Sheet;

{$mode objfpc}{$H+}

{ Material Design 3 — Sheets.

  TFRMaterialBottomSheet — Panel that slides up from the bottom.
  TFRMaterialSideSheet   — Panel that slides in from the right.

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, ExtCtrls, Forms,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base;

type
  TFRMaterialBottomSheet = class(TFRMaterial3Control)
  private
    FExpanded: Boolean;
    FSheetHeight: Integer;
    FDragHandle: Boolean;
    FAnimTimer: TTimer;
    FTargetTop: Integer;
    procedure SetExpanded(AValue: Boolean);
    procedure OnAnimTimer(Sender: TObject);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Toggle;
  published
    property Expanded: Boolean read FExpanded write SetExpanded default False;
    property SheetHeight: Integer read FSheetHeight write FSheetHeight default 300;
    property DragHandle: Boolean read FDragHandle write FDragHandle default True;
    property Align;
    property Anchors;
    property Visible;
    property Enabled;
  end;

  TFRMaterialSideSheet = class(TFRMaterial3Control)
  private
    FExpanded: Boolean;
    FSheetWidth: Integer;
    FAnimTimer: TTimer;
    FTargetLeft: Integer;
    procedure SetExpanded(AValue: Boolean);
    procedure OnAnimTimer(Sender: TObject);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Toggle;
  published
    property Expanded: Boolean read FExpanded write SetExpanded default False;
    property SheetWidth: Integer read FSheetWidth write FSheetWidth default 360;
    property Align;
    property Anchors;
    property Visible;
    property Enabled;
  end;

procedure Register;

implementation

uses Math;

{ ══════════════════════════════════════════════════════════════
  TFRMaterialBottomSheet
  ══════════════════════════════════════════════════════════════ }

constructor TFRMaterialBottomSheet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FExpanded := False;
  FSheetHeight := 300;
  FDragHandle := True;
  Width := 400;
  Height := 300;
  Anchors := [akLeft, akRight, akBottom];

  FAnimTimer := TTimer.Create(Self);
  FAnimTimer.Interval := 16;
  FAnimTimer.Enabled := False;
  FAnimTimer.OnTimer := @OnAnimTimer;
end;

destructor TFRMaterialBottomSheet.Destroy;
begin
  FAnimTimer.Free;
  inherited Destroy;
end;

procedure TFRMaterialBottomSheet.SetExpanded(AValue: Boolean);
begin
  if FExpanded = AValue then Exit;
  FExpanded := AValue;

  if csDesigning in ComponentState then
  begin
    Invalidate;
    Exit;
  end;

  if Assigned(Parent) then
  begin
    if FExpanded then
      FTargetTop := Parent.ClientHeight - FSheetHeight
    else
      FTargetTop := Parent.ClientHeight;
    FAnimTimer.Enabled := True;
  end;
end;

procedure TFRMaterialBottomSheet.OnAnimTimer(Sender: TObject);
var
  diff: Integer;
begin
  diff := FTargetTop - Top;
  if Abs(diff) < 4 then
  begin
    Top := FTargetTop;
    FAnimTimer.Enabled := False;
    if not FExpanded then
      Visible := False;
  end
  else
    Top := Top + diff div 4;
end;

procedure TFRMaterialBottomSheet.Toggle;
begin
  if not FExpanded then
  begin
    Visible := True;
    if Assigned(Parent) then
      Top := Parent.ClientHeight;
  end;
  SetExpanded(not FExpanded);
end;

procedure TFRMaterialBottomSheet.Paint;
var
  bmp: TBGRABitmap;
begin
  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    { top corners rounded }
    MD3FillRoundRect(bmp, 0, 0, Width - 1, Height + 28, 28, MD3Colors.SurfaceContainerLow);

    { drag handle }
    if FDragHandle then
      MD3FillRoundRect(bmp, Width div 2 - 16, 8, Width div 2 + 16, 12, 2,
        MD3Colors.OnSurfaceVariant);

    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;
end;

procedure TFRMaterialBottomSheet.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  { Toggle on drag handle click }
  if FDragHandle and (Y < 20) and (Button = mbLeft) then
    Toggle;
end;

{ ══════════════════════════════════════════════════════════════
  TFRMaterialSideSheet
  ══════════════════════════════════════════════════════════════ }

constructor TFRMaterialSideSheet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FExpanded := False;
  FSheetWidth := 360;
  Width := 360;
  Height := 600;
  Anchors := [akTop, akRight, akBottom];

  FAnimTimer := TTimer.Create(Self);
  FAnimTimer.Interval := 16;
  FAnimTimer.Enabled := False;
  FAnimTimer.OnTimer := @OnAnimTimer;
end;

destructor TFRMaterialSideSheet.Destroy;
begin
  FAnimTimer.Free;
  inherited Destroy;
end;

procedure TFRMaterialSideSheet.SetExpanded(AValue: Boolean);
begin
  if FExpanded = AValue then Exit;
  FExpanded := AValue;

  if csDesigning in ComponentState then
  begin
    Invalidate;
    Exit;
  end;

  if Assigned(Parent) then
  begin
    if FExpanded then
      FTargetLeft := Parent.ClientWidth - FSheetWidth
    else
      FTargetLeft := Parent.ClientWidth;
    FAnimTimer.Enabled := True;
  end;
end;

procedure TFRMaterialSideSheet.OnAnimTimer(Sender: TObject);
var
  diff: Integer;
begin
  diff := FTargetLeft - Left;
  if Abs(diff) < 4 then
  begin
    Left := FTargetLeft;
    FAnimTimer.Enabled := False;
    if not FExpanded then
      Visible := False;
  end
  else
    Left := Left + diff div 4;
end;

procedure TFRMaterialSideSheet.Toggle;
begin
  if not FExpanded then
  begin
    Visible := True;
    if Assigned(Parent) then
      Left := Parent.ClientWidth;
  end;
  SetExpanded(not FExpanded);
end;

procedure TFRMaterialSideSheet.Paint;
var
  bmp: TBGRABitmap;
begin
  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    MD3FillRoundRect(bmp, 0, 0, Width - 1, Height - 1, 16, MD3Colors.SurfaceContainerLow);
    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;
end;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialbottomsheet_icon.lrs}
    {$I icons\frmaterialsidesheet_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialBottomSheet, TFRMaterialSideSheet]);
end;

end.

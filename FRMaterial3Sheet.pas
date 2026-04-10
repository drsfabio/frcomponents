unit FRMaterial3Sheet;

{$mode objfpc}{$H+}

{ Material Design 3 — Sheets.

  TFRMaterialBottomSheet — Panel that slides up from the bottom.
  TFRMaterialSideSheet   — Panel that slides in from the right.

  Features:
    • Dismiss on click outside (scrim overlay)
    • Dismiss on Escape key
    • Smooth slide animation
    • Configurable scrim opacity

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, ExtCtrls, Forms,
  {$IFDEF FPC} LCLType, LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialTheme;

type

  { ── Scrim panel — transparent overlay for click-outside dismiss ── }

  TFRSheetScrim = class(TCustomControl)
  private
    FAlpha: Byte;
  protected
    procedure Paint; override;
  end;

  { ── TFRMaterialBottomSheet ── }

  TFRMaterialBottomSheet = class(TFRMaterial3Control)
  private
    FExpanded: Boolean;
    FSheetHeight: Integer;
    FDragHandle: Boolean;
    FDismissOnClickOutside: Boolean;
    FDismissOnEscape: Boolean;
    FScrimOpacity: Byte;
    FOnExpand: TNotifyEvent;
    FOnCollapse: TNotifyEvent;
    FAnimTimer: TTimer;
    FTargetTop: Integer;
    FScrim: TFRSheetScrim;
    procedure SetExpanded(AValue: Boolean);
    procedure OnAnimTimer(Sender: TObject);
    procedure OnScrimClick(Sender: TObject);
    procedure DoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CreateScrim;
    procedure DestroyScrim;
  protected
    function PaintCached(ABmp: TBGRABitmap): Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Toggle;
  published
    property Expanded: Boolean read FExpanded write SetExpanded default False;
    property SheetHeight: Integer read FSheetHeight write FSheetHeight default 300;
    property DragHandle: Boolean read FDragHandle write FDragHandle default True;
    property DismissOnClickOutside: Boolean read FDismissOnClickOutside write FDismissOnClickOutside default True;
    property DismissOnEscape: Boolean read FDismissOnEscape write FDismissOnEscape default True;
    property ScrimOpacity: Byte read FScrimOpacity write FScrimOpacity default 80;
    property OnExpand: TNotifyEvent read FOnExpand write FOnExpand;
    property OnCollapse: TNotifyEvent read FOnCollapse write FOnCollapse;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
    property Cursor;
    property Enabled;
    property PopupMenu;
    property ShowHint;
    property ParentShowHint;
    property Visible;
  end;

  { ── TFRMaterialSideSheet ── }

  TFRMaterialSideSheet = class(TFRMaterial3Control)
  private
    FExpanded: Boolean;
    FSheetWidth: Integer;
    FDismissOnClickOutside: Boolean;
    FDismissOnEscape: Boolean;
    FScrimOpacity: Byte;
    FOnExpand: TNotifyEvent;
    FOnCollapse: TNotifyEvent;
    FAnimTimer: TTimer;
    FTargetLeft: Integer;
    FScrim: TFRSheetScrim;
    procedure SetExpanded(AValue: Boolean);
    procedure OnAnimTimer(Sender: TObject);
    procedure OnScrimClick(Sender: TObject);
    procedure DoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CreateScrim;
    procedure DestroyScrim;
  protected
    function PaintCached(ABmp: TBGRABitmap): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Toggle;
  published
    property Expanded: Boolean read FExpanded write SetExpanded default False;
    property SheetWidth: Integer read FSheetWidth write FSheetWidth default 360;
    property DismissOnClickOutside: Boolean read FDismissOnClickOutside write FDismissOnClickOutside default True;
    property DismissOnEscape: Boolean read FDismissOnEscape write FDismissOnEscape default True;
    property ScrimOpacity: Byte read FScrimOpacity write FScrimOpacity default 80;
    property OnExpand: TNotifyEvent read FOnExpand write FOnExpand;
    property OnCollapse: TNotifyEvent read FOnCollapse write FOnCollapse;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Constraints;
    property Cursor;
    property Enabled;
    property PopupMenu;
    property ShowHint;
    property ParentShowHint;
    property Visible;
  end;

procedure Register;

implementation

uses Math;

{ ── TFRSheetScrim ── }

procedure TFRSheetScrim.Paint;
var
  bmp: TBGRABitmap;
begin
  if (Width <= 0) or (Height <= 0) then Exit;
  bmp := TBGRABitmap.Create(Width, Height, BGRA(0, 0, 0, FAlpha));
  bmp.Draw(Canvas, 0, 0, False);
  bmp.Free;
end;

{ ══════════════════════════════════════════════════════════════
  TFRMaterialBottomSheet
  ══════════════════════════════════════════════════════════════ }

constructor TFRMaterialBottomSheet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FExpanded := False;
  FSheetHeight := 300;
  FDragHandle := True;
  FDismissOnClickOutside := True;
  FDismissOnEscape := True;
  FScrimOpacity := 80;
  FScrim := nil;
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
  DestroyScrim;
  FAnimTimer.Free;
  inherited Destroy;
end;

procedure TFRMaterialBottomSheet.CreateScrim;
begin
  if Assigned(FScrim) then Exit;
  if not Assigned(Parent) then Exit;

  FScrim := TFRSheetScrim.Create(Parent);
  FScrim.Parent := Parent;
  { Do NOT use Align := alClient — it triggers LCL re-layout and can
    displace sibling controls (e.g. child form content disappears).
    Instead, cover the parent area manually with anchors. }
  FScrim.Align := alNone;
  FScrim.SetBounds(0, 0, Parent.ClientWidth, Parent.ClientHeight);
  FScrim.Anchors := [akLeft, akTop, akRight, akBottom];
  FScrim.FAlpha := FScrimOpacity;
  FScrim.OnClick := @OnScrimClick;
  FScrim.BringToFront;

  { Ensure the sheet is above the scrim }
  Self.BringToFront;
end;

procedure TFRMaterialBottomSheet.DestroyScrim;
begin
  if Assigned(FScrim) then
  begin
    FScrim.Free;
    FScrim := nil;
  end;
end;

procedure TFRMaterialBottomSheet.OnScrimClick(Sender: TObject);
begin
  if FDismissOnClickOutside and FExpanded then
    SetExpanded(False);
end;

procedure TFRMaterialBottomSheet.DoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and FDismissOnEscape and FExpanded then
  begin
    SetExpanded(False);
    Key := 0;
  end;
end;

procedure TFRMaterialBottomSheet.SetExpanded(AValue: Boolean);
var
  frm: TCustomForm;
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
    begin
      { Show scrim + register ESC handler }
      if FDismissOnClickOutside then
        CreateScrim;
      if FDismissOnEscape then
      begin
        frm := GetParentForm(Self);
        if Assigned(frm) then
        begin
          frm.KeyPreview := True;
          frm.OnKeyDown := @DoKeyDown;
        end;
      end;
      FTargetTop := Parent.ClientHeight - FSheetHeight;
      if Assigned(FOnExpand) then
        FOnExpand(Self);
    end
    else
    begin
      { Remove ESC handler }
      if FDismissOnEscape then
      begin
        frm := GetParentForm(Self);
        if Assigned(frm) then
          frm.OnKeyDown := nil;
      end;
      FTargetTop := Parent.ClientHeight;
      if Assigned(FOnCollapse) then
        FOnCollapse(Self);
    end;
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
    begin
      Visible := False;
      DestroyScrim;
    end;
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

function TFRMaterialBottomSheet.PaintCached(ABmp: TBGRABitmap): Boolean;
begin
  Result := True;
  MD3DrawShadow(ABmp, 0, 0, Width - 1, Height + 28, 28, elLevel1);
  { top corners rounded }
  MD3FillRoundRect(ABmp, 0, 0, Width - 1, Height + 28, 28, MD3Colors.SurfaceContainerLow);

  { drag handle }
  if FDragHandle then
    MD3FillRoundRect(ABmp, Width div 2 - 16, 8, Width div 2 + 16, 12, 2,
      MD3Colors.OnSurfaceVariant);
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
  FDismissOnClickOutside := True;
  FDismissOnEscape := True;
  FScrimOpacity := 80;
  FScrim := nil;
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
  DestroyScrim;
  FAnimTimer.Free;
  inherited Destroy;
end;

procedure TFRMaterialSideSheet.CreateScrim;
begin
  if Assigned(FScrim) then Exit;
  if not Assigned(Parent) then Exit;

  FScrim := TFRSheetScrim.Create(Parent);
  FScrim.Parent := Parent;
  { Do NOT use Align := alClient — it triggers LCL re-layout and can
    displace sibling controls (e.g. child form content disappears).
    Instead, cover the parent area manually with anchors. }
  FScrim.Align := alNone;
  FScrim.SetBounds(0, 0, Parent.ClientWidth, Parent.ClientHeight);
  FScrim.Anchors := [akLeft, akTop, akRight, akBottom];
  FScrim.FAlpha := FScrimOpacity;
  FScrim.OnClick := @OnScrimClick;
  FScrim.BringToFront;

  { Ensure the sheet is above the scrim }
  Self.BringToFront;
end;

procedure TFRMaterialSideSheet.DestroyScrim;
begin
  if Assigned(FScrim) then
  begin
    FScrim.Free;
    FScrim := nil;
  end;
end;

procedure TFRMaterialSideSheet.OnScrimClick(Sender: TObject);
begin
  if FDismissOnClickOutside and FExpanded then
    SetExpanded(False);
end;

procedure TFRMaterialSideSheet.DoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and FDismissOnEscape and FExpanded then
  begin
    SetExpanded(False);
    Key := 0;
  end;
end;

procedure TFRMaterialSideSheet.SetExpanded(AValue: Boolean);
var
  frm: TCustomForm;
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
    begin
      if FDismissOnClickOutside then
        CreateScrim;
      if FDismissOnEscape then
      begin
        frm := GetParentForm(Self);
        if Assigned(frm) then
        begin
          frm.KeyPreview := True;
          frm.OnKeyDown := @DoKeyDown;
        end;
      end;
      FTargetLeft := Parent.ClientWidth - FSheetWidth;
      if Assigned(FOnExpand) then
        FOnExpand(Self);
    end
    else
    begin
      if FDismissOnEscape then
      begin
        frm := GetParentForm(Self);
        if Assigned(frm) then
          frm.OnKeyDown := nil;
      end;
      FTargetLeft := Parent.ClientWidth;
      if Assigned(FOnCollapse) then
        FOnCollapse(Self);
    end;
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
    begin
      Visible := False;
      DestroyScrim;
    end;
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

function TFRMaterialSideSheet.PaintCached(ABmp: TBGRABitmap): Boolean;
begin
  Result := True;
  MD3DrawShadow(ABmp, 0, 0, Width - 1, Height - 1, 16, elLevel1);
  MD3FillRoundRect(ABmp, 0, 0, Width - 1, Height - 1, 16, MD3Colors.SurfaceContainerLow);
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

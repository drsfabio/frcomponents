unit FRMaterial3Tooltip;

{$mode objfpc}{$H+}

{ Material Design 3 — Tooltip.

  TFRMaterialTooltip — Non-visual component, attaches to a control
  and shows a tooltip on hover.

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, Forms, ExtCtrls,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base;

type
  TFRMaterialTooltip = class(TComponent)
  private
    FText: string;
    FAttachTo: TControl;
    FDelay: Integer;
    FPanel: TCustomControl;
    FTimer: TTimer;
    FAutoHideTimer: TTimer;
    procedure SetAttachTo(AValue: TControl);
    procedure OnShowTimer(Sender: TObject);
    procedure OnHideTimer(Sender: TObject);
    procedure ControlMouseEnter(Sender: TObject);
    procedure ControlMouseLeave(Sender: TObject);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ShowAt(X, Y: Integer);
    procedure Hide;
  published
    property Text: string read FText write FText;
    property AttachTo: TControl read FAttachTo write SetAttachTo;
    property Delay: Integer read FDelay write FDelay default 500;
  end;

procedure Register;

implementation

uses Math;

type
  TControlAccess = class(TControl);

  TTooltipPanel = class(TCustomControl)
  private
    FTooltipText: string;
  protected
    procedure Paint; override;
  end;

procedure TTooltipPanel.Paint;
var
  bmp: TBGRABitmap;
  aRect: TRect;
begin
  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    MD3FillRoundRect(bmp, 0, 0, Width - 1, Height - 1, 4, MD3Colors.InverseSurface);
    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  aRect := Rect(8, 0, Width - 8, Height);
  Canvas.Font.Size := 8;
  MD3DrawText(Canvas, FTooltipText, aRect, MD3Colors.InverseOnSurface, taCenter, True);
end;

{ ── TFRMaterialTooltip ── }

constructor TFRMaterialTooltip.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FText := '';
  FAttachTo := nil;
  FDelay := 500;
  FPanel := nil;
  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.OnTimer := @OnShowTimer;
  FAutoHideTimer := TTimer.Create(Self);
  FAutoHideTimer.Enabled := False;
  FAutoHideTimer.Interval := 3000;
  FAutoHideTimer.OnTimer := @OnHideTimer;
end;

destructor TFRMaterialTooltip.Destroy;
begin
  Hide;
  FTimer.Free;
  FAutoHideTimer.Free;
  inherited Destroy;
end;

procedure TFRMaterialTooltip.SetAttachTo(AValue: TControl);
begin
  if FAttachTo = AValue then Exit;
  if Assigned(FAttachTo) then
  begin
    FAttachTo.RemoveFreeNotification(Self);
    TControlAccess(FAttachTo).OnMouseEnter := nil;
    TControlAccess(FAttachTo).OnMouseLeave := nil;
  end;
  FAttachTo := AValue;
  if Assigned(FAttachTo) then
  begin
    FAttachTo.FreeNotification(Self);
    TControlAccess(FAttachTo).OnMouseEnter := @ControlMouseEnter;
    TControlAccess(FAttachTo).OnMouseLeave := @ControlMouseLeave;
  end;
end;

procedure TFRMaterialTooltip.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FAttachTo) then
    FAttachTo := nil;
end;

procedure TFRMaterialTooltip.ControlMouseEnter(Sender: TObject);
begin
  FTimer.Interval := FDelay;
  FTimer.Enabled := True;
end;

procedure TFRMaterialTooltip.ControlMouseLeave(Sender: TObject);
begin
  FTimer.Enabled := False;
  Hide;
end;

procedure TFRMaterialTooltip.OnShowTimer(Sender: TObject);
var
  P: TPoint;
begin
  FTimer.Enabled := False;
  if not Assigned(FAttachTo) then Exit;
  P := FAttachTo.ClientToScreen(Point(FAttachTo.Width div 2, FAttachTo.Height));
  ShowAt(P.X, P.Y + 4);
end;

procedure TFRMaterialTooltip.OnHideTimer(Sender: TObject);
begin
  Hide;
end;

procedure TFRMaterialTooltip.ShowAt(X, Y: Integer);
var
  ownerForm: TCustomForm;
  tipPanel: TTooltipPanel;
  tw: Integer;
  formPt: TPoint;
begin
  Hide;
  ownerForm := nil;
  if Owner is TCustomForm then
    ownerForm := TCustomForm(Owner)
  else if (Owner is TControl) and Assigned(TControl(Owner).Parent) then
    ownerForm := GetParentForm(TControl(Owner));
  if ownerForm = nil then Exit;

  tipPanel := TTooltipPanel.Create(ownerForm);
  tipPanel.FTooltipText := FText;
  tipPanel.Parent := ownerForm;
  tipPanel.Canvas.Font.Size := 8;
  tw := tipPanel.Canvas.TextWidth(FText) + 16;
  tipPanel.Width := tw;
  tipPanel.Height := 24;

  formPt := ownerForm.ScreenToClient(Point(X, Y));
  tipPanel.Left := Max(0, Min(formPt.X - tw div 2, ownerForm.ClientWidth - tw));
  tipPanel.Top := Min(formPt.Y, ownerForm.ClientHeight - 24);
  tipPanel.BringToFront;
  FPanel := tipPanel;

  FAutoHideTimer.Enabled := True;
end;

procedure TFRMaterialTooltip.Hide;
begin
  FAutoHideTimer.Enabled := False;
  if Assigned(FPanel) then
  begin
    FPanel.Free;
    FPanel := nil;
  end;
end;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialtooltip_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialTooltip]);
end;

end.

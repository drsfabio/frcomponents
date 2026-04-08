unit FRMaterial3Snackbar;

{$mode objfpc}{$H+}

{ Material Design 3 — Snackbar.

  TFRMaterialSnackbar — Non-visual component for showing snackbar notifications.
  Call Show to display at the bottom of the parent form.

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, Forms, ExtCtrls,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterialTheme, FRMaterial3Base;

type
  TFRMaterialSnackbar = class(TComponent, IFRMaterialComponent)
  private
    FMessage: string;
    FActionText: string;
    FDuration: Integer;
    FOnAction: TNotifyEvent;
    FPanel: TCustomControl;
    FTimer: TTimer;
    procedure OnTimerFire(Sender: TObject);
    procedure OnActionClick(Sender: TObject);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Show; overload;
    procedure Show(const AMessage: string); overload;
    procedure Show(const AMessage, AAction: string); overload;
    procedure Hide;
    procedure ApplyTheme(const AThemeManager: TObject); virtual;
  published
    property Message: string read FMessage write FMessage;
    property ActionText: string read FActionText write FActionText;
    property Duration: Integer read FDuration write FDuration default 4000;
    property OnAction: TNotifyEvent read FOnAction write FOnAction;
  end;

procedure Register;

implementation

uses Math, StdCtrls;

type
  TSnackbarPanel = class(TCustomControl)
  private
    FSnackbar: TFRMaterialSnackbar;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  end;

procedure TSnackbarPanel.Paint;
var
  bmp: TBGRABitmap;
  aRect: TRect;
begin
  if (Width <= 0) or (Height <= 0) then Exit;
  bmp := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
  try
    MD3DrawShadow(bmp, 0, 0, Width - 1, Height - 1, 4, elLevel3);
    MD3FillRoundRect(bmp, 0, 0, Width - 1, Height - 1, 4, MD3Colors.InverseSurface);
    bmp.Draw(Canvas, 0, 0, False);
  finally
    bmp.Free;
  end;

  aRect := Rect(16, 0, Width - 100, Height);
  MD3DrawText(Canvas, FSnackbar.FMessage, aRect, MD3Colors.InverseOnSurface, taLeftJustify, True);

  if FSnackbar.FActionText <> '' then
  begin
    aRect := Rect(Width - 96, 0, Width - 16, Height);
    MD3DrawText(Canvas, FSnackbar.FActionText, aRect, MD3Colors.InversePrimary, taRightJustify, True);
  end;
end;

procedure TSnackbarPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and (FSnackbar.FActionText <> '') and (X >= Width - 100) then
    FSnackbar.OnActionClick(Self);
end;

{ ── TFRMaterialSnackbar ── }

constructor TFRMaterialSnackbar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMessage := '';
  FActionText := '';
  FDuration := 4000;
  FPanel := nil;
  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.OnTimer := @OnTimerFire;
  
  FRMDRegisterComponent(Self);
end;

destructor TFRMaterialSnackbar.Destroy;
begin
  Hide;
  FTimer.Free;
  
  FRMDUnregisterComponent(Self);
    
  inherited Destroy;
end;

procedure TFRMaterialSnackbar.ApplyTheme(const AThemeManager: TObject);
begin
  if not Assigned(AThemeManager) then Exit;
  if Assigned(FPanel) then
    FPanel.Invalidate;
end;

procedure TFRMaterialSnackbar.Show;
var
  ownerForm: TCustomForm;
  snkPanel: TSnackbarPanel;
begin
  Hide;
  ownerForm := nil;
  if Owner is TCustomForm then
    ownerForm := TCustomForm(Owner)
  else if (Owner is TControl) and Assigned(TControl(Owner).Parent) then
    ownerForm := GetParentForm(TControl(Owner));
  if ownerForm = nil then Exit;

  snkPanel := TSnackbarPanel.Create(ownerForm);
  snkPanel.FSnackbar := Self;
  snkPanel.Parent := ownerForm;
  snkPanel.Height := 48;
  snkPanel.Width := ownerForm.ClientWidth - 32;
  snkPanel.Left := 16;
  snkPanel.Top := ownerForm.ClientHeight - 64;
  snkPanel.Anchors := [akLeft, akRight, akBottom];
  snkPanel.BringToFront;
  FPanel := snkPanel;
  FPanel.FreeNotification(Self);

  FTimer.Interval := FDuration;
  FTimer.Enabled := True;
end;

procedure TFRMaterialSnackbar.Show(const AMessage: string);
begin
  FMessage := AMessage;
  Show;
end;

procedure TFRMaterialSnackbar.Show(const AMessage, AAction: string);
begin
  FMessage := AMessage;
  FActionText := AAction;
  Show;
end;

procedure TFRMaterialSnackbar.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FPanel) then
    FPanel := nil;
end;

procedure TFRMaterialSnackbar.Hide;
begin
  FTimer.Enabled := False;
  if Assigned(FPanel) then
  begin
    FPanel.Free;
    FPanel := nil;
  end;
end;

procedure TFRMaterialSnackbar.OnTimerFire(Sender: TObject);
begin
  Hide;
end;

procedure TFRMaterialSnackbar.OnActionClick(Sender: TObject);
begin
  if Assigned(FOnAction) then
    FOnAction(Self);
  Hide;
end;

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialsnackbar_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialSnackbar]);
end;

end.

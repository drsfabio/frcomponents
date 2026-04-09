unit FRMaterial3PageControl;

{$mode objfpc}{$H+}

{ Material Design 3 — PageControl.

  TFRMaterialPageControl — Tab container with MD3 styling.
  TFRMaterialTabPage     — Individual page (container for child controls).

  Drop-in replacement workflow for TPageControl/TTabSheet:

    Page := TFRMaterialTabPage.Create(Self);
    Page.PageControl := MyPageControl;
    Page.Caption := 'Tab Title';
    Form.Parent := Page;
    MyPageControl.ActivePage := Page;

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, Forms, Types, Dialogs,
  {$IFDEF FPC} LCLType, LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterialTheme, FRMaterial3Base, FRMaterialIcons,
  ComponentEditors, PropEdits;

type
  TFRTabPosition = (tpTop, tpBottom);
  TFRMaterialPageControl = class;

  { ── TFRMaterialTabPage ── }

  TFRMaterialTabPage = class(TCustomControl, IFRMaterialComponent)
  private
    FPageControl: TFRMaterialPageControl;
    FTabCaption: TCaption;
    FIconMode: TFRIconMode;
    FShowIcon: Boolean;
    FImageIndex: Integer;
    procedure SetPageControl(AValue: TFRMaterialPageControl);
    procedure SetTabCaption(const AValue: TCaption);
    procedure SetIconMode(AValue: TFRIconMode);
    procedure SetShowIcon(AValue: Boolean);
  protected
    procedure Paint; override;
    procedure ApplyTheme(const AThemeManager: TObject); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetParentComponent: TComponent; override;
    function HasParent: Boolean; override;
    procedure SetParentComponent(AParent: TComponent); override;
  published
    property PageControl: TFRMaterialPageControl read FPageControl write SetPageControl;
    property Caption: TCaption read FTabCaption write SetTabCaption;
    property IconMode: TFRIconMode read FIconMode write SetIconMode default imClear;
    property ShowIcon: Boolean read FShowIcon write SetShowIcon default True;
    property ImageIndex: Integer read FImageIndex write FImageIndex default -1;
    property Anchors;
    property Color;
    property Constraints;
    property Cursor;
    property Font;
    property PopupMenu;
    property ShowHint;
    property Tag;
    property Visible;
  end;

  { Event fired before closing a tab }
  TFRMDCloseTabEvent = procedure(Sender: TObject; APage: TFRMaterialTabPage;
    var AllowClose: Boolean) of object;

  { ── TFRMaterialPageControl ── }

  TFRMaterialPageControl = class(TCustomControl, IFRMaterialComponent)
  private
    FPages: TList;
    FActivePageIndex: Integer;
    FTabHeight: Integer;
    FShowCloseButton: Boolean;
    FBackgroundImage: TPicture;
    FOnChange: TNotifyEvent;
    FOnCloseTab: TFRMDCloseTabEvent;
    FHoverTabIndex: Integer;
    FHoverClose: Boolean;
    FTabPosition: TFRTabPosition;
    function GetPageCount: Integer;
    function GetPage(Index: Integer): TFRMaterialTabPage;
    function GetActivePage: TFRMaterialTabPage;
    procedure SetActivePage(AValue: TFRMaterialTabPage);
    procedure SetActivePageIndex(AValue: Integer);
    procedure SetShowCloseButton(AValue: Boolean);
    procedure SetTabPosition(AValue: TFRTabPosition);
    procedure BackgroundImageChanged(Sender: TObject);
    function CalcTabWidth: Integer;
    function TabRect(AIndex: Integer): TRect;
    function CloseRect(AIndex: Integer): TRect;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseLeave; override;
    procedure ApplyTheme(const AThemeManager: TObject); virtual;
    procedure Resize; override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddPage(APage: TFRMaterialTabPage);
    procedure RemovePage(APage: TFRMaterialTabPage);
    function IndexOfPage(APage: TFRMaterialTabPage): Integer;
    procedure UpdatePageLayout;
    property PageCount: Integer read GetPageCount;
    property Pages[Index: Integer]: TFRMaterialTabPage read GetPage;
  published
    property ActivePage: TFRMaterialTabPage read GetActivePage write SetActivePage;
    property ActivePageIndex: Integer read FActivePageIndex write SetActivePageIndex default -1;
    property TabHeight: Integer read FTabHeight write FTabHeight default 48;
    property ShowCloseButton: Boolean read FShowCloseButton write SetShowCloseButton default False;
    property BackgroundImage: TPicture read FBackgroundImage write FBackgroundImage;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnCloseTab: TFRMDCloseTabEvent read FOnCloseTab write FOnCloseTab;
    property TabPosition: TFRTabPosition read FTabPosition write SetTabPosition default tpTop;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Color;
    property Constraints;
    property Cursor;
    property Enabled;
    property Font;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
  end;

  { ── Component Editor — IDE integration ── }

  TFRMaterialPageControlEditor = class(TComponentEditor)
  public
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

procedure Register;

implementation

uses Math;

{ ── TFRMaterialTabPage ── }

constructor TFRMaterialTabPage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  
  FRMDRegisterComponent(Self);

  ControlStyle := ControlStyle + [csAcceptsControls];
  FPageControl := nil;
  FIconMode := imClear;
  FShowIcon := True;
  FImageIndex := -1;
  Visible := False;
end;

destructor TFRMaterialTabPage.Destroy;
begin
  if Assigned(FPageControl) then
    FPageControl.RemovePage(Self);
    
  FRMDUnregisterComponent(Self);
    
  inherited Destroy;
end;

procedure TFRMaterialTabPage.ApplyTheme(const AThemeManager: TObject);
begin
  if not Assigned(AThemeManager) then Exit;
  Invalidate;
end;

procedure TFRMaterialTabPage.SetPageControl(AValue: TFRMaterialPageControl);
begin
  if FPageControl = AValue then Exit;
  if Assigned(FPageControl) then
    FPageControl.RemovePage(Self);
  FPageControl := AValue;
  if Assigned(FPageControl) then
  begin
    Parent := FPageControl;
    FPageControl.AddPage(Self);
  end
  else
    Parent := nil;
end;

procedure TFRMaterialTabPage.SetTabCaption(const AValue: TCaption);
begin
  if FTabCaption = AValue then Exit;
  FTabCaption := AValue;
  if Assigned(FPageControl) then
    FPageControl.Invalidate;
end;

procedure TFRMaterialTabPage.SetIconMode(AValue: TFRIconMode);
begin
  if FIconMode = AValue then Exit;
  FIconMode := AValue;
  if Assigned(FPageControl) then
    FPageControl.Invalidate;
end;

procedure TFRMaterialTabPage.SetShowIcon(AValue: Boolean);
begin
  if FShowIcon = AValue then Exit;
  FShowIcon := AValue;
  if Assigned(FPageControl) then
    FPageControl.Invalidate;
end;

procedure TFRMaterialTabPage.Paint;
begin
  Canvas.Brush.Color := MD3Colors.Surface;
  Canvas.FillRect(ClientRect);
end;

function TFRMaterialTabPage.GetParentComponent: TComponent;
begin
  if Assigned(FPageControl) then
    Result := FPageControl
  else
    Result := inherited GetParentComponent;
end;

function TFRMaterialTabPage.HasParent: Boolean;
begin
  if Assigned(FPageControl) then
    Result := True
  else
    Result := inherited HasParent;
end;

procedure TFRMaterialTabPage.SetParentComponent(AParent: TComponent);
begin
  if AParent is TFRMaterialPageControl then
    SetPageControl(TFRMaterialPageControl(AParent))
  else
    inherited SetParentComponent(AParent);
end;

{ ── TFRMaterialPageControl ── }

constructor TFRMaterialPageControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  
  FRMDRegisterComponent(Self);

  ControlStyle := ControlStyle + [csAcceptsControls];
  FPages := TList.Create;
  FActivePageIndex := -1;
  FTabHeight := 48;
  FShowCloseButton := False;
  FHoverTabIndex := -1;
  FHoverClose := False;
  FTabPosition := tpTop;
  FBackgroundImage := TPicture.Create;
  FBackgroundImage.OnChange := @BackgroundImageChanged;
  Width := 400;
  Height := 300;
end;

destructor TFRMaterialPageControl.Destroy;
var
  i: Integer;
begin
  { Clear back-references so TabPage destructors don't call RemovePage }
  for i := FPages.Count - 1 downto 0 do
    TFRMaterialTabPage(FPages[i]).FPageControl := nil;
  FPages.Free;
  FBackgroundImage.Free;
  
  FRMDUnregisterComponent(Self);

  inherited Destroy;
end;

procedure TFRMaterialPageControl.ApplyTheme(const AThemeManager: TObject);
begin
  if not Assigned(AThemeManager) then Exit;
  Invalidate;
end;

function TFRMaterialPageControl.GetPageCount: Integer;
begin
  Result := FPages.Count;
end;

function TFRMaterialPageControl.GetPage(Index: Integer): TFRMaterialTabPage;
begin
  Result := TFRMaterialTabPage(FPages[Index]);
end;

function TFRMaterialPageControl.GetActivePage: TFRMaterialTabPage;
begin
  if (FActivePageIndex >= 0) and (FActivePageIndex < FPages.Count) then
    Result := TFRMaterialTabPage(FPages[FActivePageIndex])
  else
    Result := nil;
end;

procedure TFRMaterialPageControl.SetActivePage(AValue: TFRMaterialTabPage);
var
  idx: Integer;
begin
  if AValue = nil then
    SetActivePageIndex(-1)
  else
  begin
    idx := FPages.IndexOf(AValue);
    if idx >= 0 then
      SetActivePageIndex(idx);
  end;
end;

procedure TFRMaterialPageControl.SetActivePageIndex(AValue: Integer);
begin
  if AValue < -1 then AValue := -1;
  if AValue >= FPages.Count then AValue := FPages.Count - 1;
  if FActivePageIndex = AValue then Exit;
  FActivePageIndex := AValue;
  UpdatePageLayout;
  Invalidate;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TFRMaterialPageControl.SetShowCloseButton(AValue: Boolean);
begin
  if FShowCloseButton = AValue then Exit;
  FShowCloseButton := AValue;
  Invalidate;
end;

procedure TFRMaterialPageControl.SetTabPosition(AValue: TFRTabPosition);
begin
  if FTabPosition = AValue then Exit;
  FTabPosition := AValue;
  UpdatePageLayout;
  Invalidate;
end;

procedure TFRMaterialPageControl.BackgroundImageChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TFRMaterialPageControl.AddPage(APage: TFRMaterialTabPage);
begin
  if FPages.IndexOf(APage) >= 0 then Exit;
  FPages.Add(APage);
  APage.Parent := Self;
  if FPages.Count = 1 then
    SetActivePageIndex(0)
  else
  begin
    UpdatePageLayout;
    Invalidate;
  end;
end;

procedure TFRMaterialPageControl.RemovePage(APage: TFRMaterialTabPage);
var
  idx: Integer;
begin
  idx := FPages.IndexOf(APage);
  if idx < 0 then Exit;
  FPages.Remove(APage);
  if FActivePageIndex >= FPages.Count then
    FActivePageIndex := FPages.Count - 1;
  UpdatePageLayout;
  Invalidate;
end;

function TFRMaterialPageControl.IndexOfPage(APage: TFRMaterialTabPage): Integer;
begin
  Result := FPages.IndexOf(APage);
end;

procedure TFRMaterialPageControl.UpdatePageLayout;
var
  i, contentTop, contentH: Integer;
  page: TFRMaterialTabPage;
begin
  contentH := Height - FTabHeight;
  if contentH < 0 then contentH := 0;

  if FTabPosition = tpTop then
    contentTop := FTabHeight
  else
    contentTop := 0;

  for i := 0 to FPages.Count - 1 do
  begin
    page := TFRMaterialTabPage(FPages[i]);
    page.SetBounds(0, contentTop, Width, contentH);
    page.Visible := (i = FActivePageIndex);
  end;
end;

function TFRMaterialPageControl.CalcTabWidth: Integer;
begin
  if FPages.Count = 0 then
    Result := 0
  else
  begin
    Result := Width div FPages.Count;
    if Result > 240 then Result := 240;
    if Result < 60 then Result := 60;
  end;
end;

function TFRMaterialPageControl.TabRect(AIndex: Integer): TRect;
var
  tw, tabTop: Integer;
begin
  tw := CalcTabWidth;
  if FTabPosition = tpTop then
    tabTop := 0
  else
    tabTop := Height - FTabHeight;
  Result := Rect(AIndex * tw, tabTop, (AIndex + 1) * tw, tabTop + FTabHeight);
end;

function TFRMaterialPageControl.CloseRect(AIndex: Integer): TRect;
var
  tr: TRect;
begin
  tr := TabRect(AIndex);
  Result := Rect(tr.Right - 26, tr.Top + (FTabHeight - 18) div 2,
                 tr.Right - 8, tr.Top + (FTabHeight + 18) div 2);
end;

procedure TFRMaterialPageControl.Paint;
var
  bmp: TBGRABitmap;
  i, tw, tabBarY: Integer;
  page: TFRMaterialTabPage;
  tr, aRect: TRect;
  textColor: TColor;
  iconBmp: TBGRABitmap;
  bx: Integer; { bitmap-local X for current tab }
  closeX, closeY, closeCX, closeCY: Integer;
  clipText: string;
  availW: Integer;
begin
  if FTabPosition = tpTop then
    tabBarY := 0
  else
    tabBarY := Height - FTabHeight;

  { Tab bar bitmap — always FTabHeight tall, drawn at tabBarY }
  if (Width <= 0) or (FTabHeight <= 0) then Exit;
  bmp := TBGRABitmap.Create(Width, FTabHeight, ColorToBGRA(MD3Colors.Surface));
  try
    { Background image on tab bar }
    if Assigned(FBackgroundImage.Graphic) and (not FBackgroundImage.Graphic.Empty) then
      bmp.Canvas.StretchDraw(Rect(0, 0, Width, FTabHeight), FBackgroundImage.Graphic);

    { Divider line }
    if FTabPosition = tpTop then
      bmp.DrawLineAntialias(0, FTabHeight - 1, Width, FTabHeight - 1,
        ColorToBGRA(MD3Colors.SurfaceContainerHighest), 1)
    else
      bmp.DrawLineAntialias(0, 0, Width, 0,
        ColorToBGRA(MD3Colors.SurfaceContainerHighest), 1);

    tw := CalcTabWidth;
    for i := 0 to FPages.Count - 1 do
    begin
      page := TFRMaterialTabPage(FPages[i]);
      bx := i * tw;

      { Hover highlight }
      if (i = FHoverTabIndex) and (not FHoverClose) then
        bmp.FillRect(bx, 0, bx + tw, FTabHeight,
          ColorToBGRA(MD3Colors.OnSurface, 12), dmDrawWithTransparency);

      { Active indicator }
      if i = FActivePageIndex then
      begin
        if FTabPosition = tpTop then
          bmp.FillRect(bx + tw div 4, FTabHeight - 3,
                       bx + tw - tw div 4, FTabHeight,
            ColorToBGRA(MD3Colors.Primary), dmDrawWithTransparency)
        else
          bmp.FillRect(bx + tw div 4, 0,
                       bx + tw - tw div 4, 3,
            ColorToBGRA(MD3Colors.Primary), dmDrawWithTransparency);
      end;

      { Icon }
      if page.FShowIcon and (page.FIconMode <> imClear) then
      begin
        if i = FActivePageIndex then
          textColor := MD3Colors.Primary
        else
          textColor := MD3Colors.OnSurfaceVariant;
        iconBmp := FRGetCachedIcon(page.FIconMode, FRColorToSVGHex(textColor), 2.0, 20, 20);
        bmp.PutImage(bx + (tw - 20) div 2, 8, iconBmp, dmDrawWithTransparency);
      end;

      { Close button }
      if FShowCloseButton then
      begin
        closeX := bx + tw - 24;
        closeY := (FTabHeight - 14) div 2;
        closeCX := closeX + 7;  { center X of 14px icon }
        closeCY := closeY + 7;  { center Y of 14px icon }
        if (i = FHoverTabIndex) and FHoverClose then
        begin
          { MD3 state-layer circle behind close icon }
          bmp.FillEllipseAntialias(closeCX, closeCY, 11, 11,
            ColorToBGRA(MD3Colors.OnSurface, 30));
          textColor := MD3Colors.Error;
        end
        else
          textColor := MD3Colors.OnSurfaceVariant;
        iconBmp := FRGetCachedIcon(imClear, FRColorToSVGHex(textColor), 2.0, 14, 14);
        bmp.PutImage(closeX, closeY, iconBmp, dmDrawWithTransparency);
      end;
    end;

    bmp.Draw(Canvas, 0, tabBarY, False);
  finally
    bmp.Free;
  end;

  { Text labels — second pass on Canvas for crisp font rendering }
  Canvas.Font.Size := 10;
  Canvas.Font.Style := [];
  tw := CalcTabWidth;
  for i := 0 to FPages.Count - 1 do
  begin
    page := TFRMaterialTabPage(FPages[i]);
    tr := TabRect(i);

    if i = FActivePageIndex then
      textColor := MD3Colors.Primary
    else
      textColor := MD3Colors.OnSurfaceVariant;

    aRect := tr;
    aRect.Left := aRect.Left + 8;
    if FShowCloseButton then
      aRect.Right := aRect.Right - 28;

    if page.FShowIcon and (page.FIconMode <> imClear) then
    begin
      aRect.Top := tr.Top + 30;
      aRect.Bottom := tr.Top + FTabHeight - 4;
    end;

    { Truncate text with ellipsis when it exceeds available width }
    clipText := page.FTabCaption;
    availW := aRect.Right - aRect.Left;
    if Canvas.TextWidth(clipText) > availW then
    begin
      while (Length(clipText) > 1) and
            (Canvas.TextWidth(clipText + '...') > availW) do
        Delete(clipText, Length(clipText), 1);
      clipText := clipText + '...';
    end;

    MD3DrawText(Canvas, clipText, aRect, textColor, taCenter, True);
  end;

  { Content area — only visible when no pages }
  if FPages.Count = 0 then
  begin
    Canvas.Brush.Color := MD3Colors.Surface;
    if FTabPosition = tpTop then
      Canvas.FillRect(Rect(0, FTabHeight, Width, Height))
    else
      Canvas.FillRect(Rect(0, 0, Width, Height - FTabHeight));
  end;
end;

procedure TFRMaterialPageControl.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i, tw: Integer;
  page: TFRMaterialTabPage;
  allowClose: Boolean;
begin
  inherited;
  if (Button = mbLeft) and
     (((FTabPosition = tpTop) and (Y < FTabHeight)) or
      ((FTabPosition = tpBottom) and (Y >= Height - FTabHeight))) then
  begin
    tw := CalcTabWidth;
    if tw > 0 then
    begin
      i := X div tw;
      if (i >= 0) and (i < FPages.Count) then
      begin
        { Close button click }
        if FShowCloseButton and PtInRect(CloseRect(i), Point(X, Y)) then
        begin
          page := TFRMaterialTabPage(FPages[i]);
          allowClose := True;
          if Assigned(FOnCloseTab) then
            FOnCloseTab(Self, page, allowClose);
          if allowClose then
          begin
            page.FPageControl := nil; { avoid double-remove in Destroy }
            RemovePage(page);
            page.Free;
          end;
          Exit;
        end;
        { Select tab }
        SetActivePageIndex(i);
      end;
    end;
  end;
end;

procedure TFRMaterialPageControl.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  tw, newHover: Integer;
  newClose: Boolean;
begin
  inherited;
  if ((FTabPosition = tpTop) and (Y < FTabHeight)) or
     ((FTabPosition = tpBottom) and (Y >= Height - FTabHeight)) then
  begin
    tw := CalcTabWidth;
    if tw > 0 then
    begin
      newHover := X div tw;
      if (newHover < 0) or (newHover >= FPages.Count) then
        newHover := -1;
    end
    else
      newHover := -1;

    newClose := False;
    if FShowCloseButton and (newHover >= 0) then
      newClose := PtInRect(CloseRect(newHover), Point(X, Y));
  end
  else
  begin
    newHover := -1;
    newClose := False;
  end;

  if (newHover <> FHoverTabIndex) or (newClose <> FHoverClose) then
  begin
    FHoverTabIndex := newHover;
    FHoverClose := newClose;
    Invalidate;
  end;
end;

procedure TFRMaterialPageControl.MouseLeave;
begin
  inherited;
  if (FHoverTabIndex >= 0) or FHoverClose then
  begin
    FHoverTabIndex := -1;
    FHoverClose := False;
    Invalidate;
  end;
end;

procedure TFRMaterialPageControl.Resize;
begin
  inherited;
  UpdatePageLayout;
end;

procedure TFRMaterialPageControl.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  i: Integer;
begin
  for i := 0 to FPages.Count - 1 do
    Proc(TComponent(FPages[i]));
end;

{ ── TFRMaterialPageControlEditor ── }

function TFRMaterialPageControlEditor.GetVerbCount: Integer;
begin
  Result := 4;
end;

function TFRMaterialPageControlEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Add Page';
    1: Result := 'Delete Page';
    2: Result := 'Next Page';
    3: Result := 'Previous Page';
  else
    Result := '';
  end;
end;

procedure TFRMaterialPageControlEditor.ExecuteVerb(Index: Integer);
var
  PC: TFRMaterialPageControl;
  Page: TFRMaterialTabPage;
  ADesigner: TComponentEditorDesigner;
  PageName, PageCaption: string;
begin
  PC := Component as TFRMaterialPageControl;
  ADesigner := GetDesigner;
  case Index of
    0: { Add Page }
    begin
      PageName := ADesigner.CreateUniqueComponentName('FRMaterialTabPage');
      if not InputQuery('Add Page', 'Component Name:', PageName) then Exit;
      PageCaption := 'Page ' + IntToStr(PC.PageCount + 1);
      if not InputQuery('Add Page', 'Tab Caption:', PageCaption) then Exit;
      Page := TFRMaterialTabPage.Create(PC.Owner);
      Page.Name := PageName;
      Page.Caption := PageCaption;
      Page.PageControl := PC;
      PC.ActivePageIndex := PC.PageCount - 1;
      ADesigner.Modified;
    end;
    1: { Delete Page }
    begin
      if PC.PageCount = 0 then Exit;
      Page := PC.ActivePage;
      if Page = nil then Exit;
      Page.PageControl := nil;
      Page.Free;
      ADesigner.Modified;
    end;
    2: { Next Page }
    begin
      if PC.ActivePageIndex < PC.PageCount - 1 then
      begin
        PC.ActivePageIndex := PC.ActivePageIndex + 1;
        ADesigner.Modified;
      end;
    end;
    3: { Previous Page }
    begin
      if PC.ActivePageIndex > 0 then
      begin
        PC.ActivePageIndex := PC.ActivePageIndex - 1;
        ADesigner.Modified;
      end;
    end;
  end;
end;

procedure Register;
begin
  RegisterComponents('Material Design 3', [TFRMaterialPageControl]);
  RegisterNoIcon([TFRMaterialTabPage]);
  RegisterClass(TFRMaterialTabPage);
  RegisterComponentEditor(TFRMaterialPageControl, TFRMaterialPageControlEditor);
end;

end.

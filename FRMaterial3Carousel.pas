unit FRMaterial3Carousel;

{$mode objfpc}{$H+}

{ Material Design 3 — Carousel.

  TFRMaterialCarousel — Horizontal item rotator with MD3 styling.
    • Auto-play with configurable interval
    • Smooth slide animation
    • Page indicator dots
    • Mouse drag / swipe support
    • Each item: image + optional title + subtitle

  License: LGPL v3
}

interface

uses
  Classes, SysUtils, Controls, Graphics, ExtCtrls, FileUtil,
  {$IFDEF FPC} LResources, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterial3Base, FRMaterialTheme, FRMaterialIcons;

type

  { ── TFRMaterialCarouselItem ── }

  TFRMaterialCarouselItem = class(TCollectionItem)
  private
    FImage: TPicture;
    FTitle: string;
    FSubtitle: string;
    FTag: Integer;
    procedure SetImage(AValue: TPicture);
    procedure SetTitle(const AValue: string);
    procedure SetSubtitle(const AValue: string);
    procedure ImageChanged(Sender: TObject);
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Image: TPicture read FImage write SetImage;
    property Title: string read FTitle write SetTitle;
    property Subtitle: string read FSubtitle write SetSubtitle;
    property Tag: Integer read FTag write FTag default 0;
  end;

  { ── TFRMaterialCarouselItems ── }

  TFRMaterialCarouselItems = class(TCollection)
  private
    FOwner: TComponent;
    function GetItem(Index: Integer): TFRMaterialCarouselItem;
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TComponent);
    function Add: TFRMaterialCarouselItem;
    property Items[Index: Integer]: TFRMaterialCarouselItem read GetItem; default;
  end;

  TFRMaterialCarousel = class;

  TFRCarouselChangeEvent = procedure(Sender: TObject; AIndex: Integer) of object;

  { ── TFRMaterialCarousel ── }

  TFRMaterialCarousel = class(TFRMaterial3Control)
  private
    FItems: TFRMaterialCarouselItems;
    FActiveIndex: Integer;
    FAutoPlay: Boolean;
    FAutoPlayInterval: Integer;
    FShowIndicators: Boolean;
    FBorderRadius: Integer;
    FOnChange: TFRCarouselChangeEvent;
    { Animation }
    FAnimTimer: TTimer;
    FAutoTimer: TTimer;
    FAnimOffset: Single;
    FTargetOffset: Single;
    FAnimDirection: Integer;  { -1 = left, +1 = right }
    { Drag }
    FDragging: Boolean;
    FDragStartX: Integer;
    FDragOffset: Single;
    FImageDirectory: string;
    procedure SetItems(AValue: TFRMaterialCarouselItems);
    procedure SetActiveIndex(AValue: Integer);
    procedure SetAutoPlay(AValue: Boolean);
    procedure SetAutoPlayInterval(AValue: Integer);
    procedure SetShowIndicators(AValue: Boolean);
    procedure SetBorderRadius(AValue: Integer);
    procedure SetImageDirectory(const AValue: string);
    procedure LoadImagesFromDirectory;
    procedure DoAnimTick(Sender: TObject);
    procedure DoAutoTick(Sender: TObject);
    procedure AnimateTo(AIndex: Integer);
    function IndicatorRect: TRect;
    function IndicatorDotRect(AIdx: Integer): TRect;
  protected
    function PaintCached(ABmp: TBGRABitmap): Boolean; override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    class function GetControlClassDefaultSize: TSize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Next;
    procedure Previous;
  published
    property ActiveIndex: Integer read FActiveIndex write SetActiveIndex;
    property Items: TFRMaterialCarouselItems read FItems write SetItems;
    property AutoPlay: Boolean read FAutoPlay write SetAutoPlay default True;
    property AutoPlayInterval: Integer read FAutoPlayInterval write SetAutoPlayInterval default 5000;
    property ShowIndicators: Boolean read FShowIndicators write SetShowIndicators default True;
    property BorderRadius: Integer read FBorderRadius write SetBorderRadius default 16;
    property OnChange: TFRCarouselChangeEvent read FOnChange write FOnChange;
    property ImageDirectory: string read FImageDirectory write SetImageDirectory;
    property Align;
    property Anchors;
    property BorderSpacing;
    property Caption;
    property Color;
    property Constraints;
    property Cursor;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnResize;
  end;

procedure Register;

implementation

uses Math, Forms, LazFileUtils;

{ ── TFRMaterialCarouselItem ── }

constructor TFRMaterialCarouselItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FImage := TPicture.Create;
  FImage.OnChange := @ImageChanged;
  FTag := 0;
end;

destructor TFRMaterialCarouselItem.Destroy;
begin
  FImage.Free;
  inherited Destroy;
end;

procedure TFRMaterialCarouselItem.Assign(Source: TPersistent);
var
  src: TFRMaterialCarouselItem;
begin
  if Source is TFRMaterialCarouselItem then
  begin
    src := TFRMaterialCarouselItem(Source);
    FImage.Assign(src.FImage);
    FTitle := src.FTitle;
    FSubtitle := src.FSubtitle;
    FTag := src.FTag;
  end
  else
    inherited Assign(Source);
end;

procedure TFRMaterialCarouselItem.SetImage(AValue: TPicture);
begin
  FImage.Assign(AValue);
end;

procedure TFRMaterialCarouselItem.SetTitle(const AValue: string);
begin
  if FTitle = AValue then Exit;
  FTitle := AValue;
  Changed(False);
end;

procedure TFRMaterialCarouselItem.SetSubtitle(const AValue: string);
begin
  if FSubtitle = AValue then Exit;
  FSubtitle := AValue;
  Changed(False);
end;

procedure TFRMaterialCarouselItem.ImageChanged(Sender: TObject);
begin
  Changed(False);
end;

{ ── TFRMaterialCarouselItems ── }

constructor TFRMaterialCarouselItems.Create(AOwner: TComponent);
begin
  inherited Create(TFRMaterialCarouselItem);
  FOwner := AOwner;
end;

function TFRMaterialCarouselItems.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TFRMaterialCarouselItems.GetItem(Index: Integer): TFRMaterialCarouselItem;
begin
  Result := TFRMaterialCarouselItem(inherited Items[Index]);
end;

function TFRMaterialCarouselItems.Add: TFRMaterialCarouselItem;
begin
  Result := TFRMaterialCarouselItem(inherited Add);
end;

procedure TFRMaterialCarouselItems.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if FOwner is TControl then
    TControl(FOwner).Invalidate;
end;

{ ── TFRMaterialCarousel ── }

constructor TFRMaterialCarousel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FItems := TFRMaterialCarouselItems.Create(Self);
  FActiveIndex := 0;
  FAutoPlay := True;
  FAutoPlayInterval := 5000;
  FShowIndicators := True;
  FBorderRadius := 16;
  FImageDirectory := '';
  FAnimOffset := 0;
  FTargetOffset := 0;
  FAnimDirection := 0;
  FDragging := False;
  FDragOffset := 0;

  FAnimTimer := TTimer.Create(Self);
  FAnimTimer.Interval := 16;
  FAnimTimer.Enabled := False;
  FAnimTimer.OnTimer := @DoAnimTick;

  FAutoTimer := TTimer.Create(Self);
  FAutoTimer.Interval := FAutoPlayInterval;
  FAutoTimer.Enabled := FAutoPlay;
  FAutoTimer.OnTimer := @DoAutoTick;

  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, cx, cy);
end;

destructor TFRMaterialCarousel.Destroy;
begin
  FAutoTimer.Free;
  FAnimTimer.Free;
  FItems.Free;
  inherited Destroy;
end;

class function TFRMaterialCarousel.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 400;
  Result.cy := 240;
end;

procedure TFRMaterialCarousel.Loaded;
begin
  inherited Loaded;
  if FImageDirectory <> '' then
    LoadImagesFromDirectory;
end;

procedure TFRMaterialCarousel.SetItems(AValue: TFRMaterialCarouselItems);
begin
  FItems.Assign(AValue);
end;

procedure TFRMaterialCarousel.SetImageDirectory(const AValue: string);
begin
  if FImageDirectory = AValue then Exit;
  FImageDirectory := AValue;
  LoadImagesFromDirectory;
end;

procedure TFRMaterialCarousel.LoadImagesFromDirectory;
var
  Files: TStringList;
  i: Integer;
  Item: TFRMaterialCarouselItem;
  FileName, Ext, BaseName, ResolvedDir: string;
begin
  if csLoading in ComponentState then Exit;
  if FImageDirectory = '' then Exit;

  { Resolve caminho relativo ao executável }
  if FilenameIsAbsolute(FImageDirectory) then
    ResolvedDir := FImageDirectory
  else
    ResolvedDir := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + FImageDirectory;

  if not DirectoryExists(ResolvedDir) then Exit;

  FItems.Clear;
  Files := TStringList.Create;
  try
    Files.Sorted := True;
    FindAllFiles(Files, ResolvedDir, '*.png;*.jpg;*.jpeg;*.bmp;*.webp', False);
    for i := 0 to Files.Count - 1 do
    begin
      FileName := Files[i];
      Ext := LowerCase(ExtractFileExt(FileName));
      if (Ext = '.png') or (Ext = '.jpg') or (Ext = '.jpeg') or (Ext = '.bmp') or (Ext = '.webp') then
      begin
        Item := FItems.Add;
        try
          Item.Image.LoadFromFile(FileName);
        except
          Item.Free;
          Continue;
        end;
        BaseName := ChangeFileExt(ExtractFileName(FileName), '');
        Item.Title := BaseName;
      end;
    end;
  finally
    Files.Free;
  end;
  FActiveIndex := 0;
  Invalidate;
end;

procedure TFRMaterialCarousel.SetActiveIndex(AValue: Integer);
begin
  if FItems.Count = 0 then
  begin
    FActiveIndex := 0;
    Exit;
  end;
  AValue := EnsureRange(AValue, 0, FItems.Count - 1);
  if FActiveIndex = AValue then Exit;
  AnimateTo(AValue);
end;

procedure TFRMaterialCarousel.SetAutoPlay(AValue: Boolean);
begin
  if FAutoPlay = AValue then Exit;
  FAutoPlay := AValue;
  FAutoTimer.Enabled := FAutoPlay and (FItems.Count > 1);
end;

procedure TFRMaterialCarousel.SetAutoPlayInterval(AValue: Integer);
begin
  if AValue < 500 then AValue := 500;
  if FAutoPlayInterval = AValue then Exit;
  FAutoPlayInterval := AValue;
  FAutoTimer.Interval := AValue;
end;

procedure TFRMaterialCarousel.SetShowIndicators(AValue: Boolean);
begin
  if FShowIndicators = AValue then Exit;
  FShowIndicators := AValue;
  Invalidate;
end;

procedure TFRMaterialCarousel.SetBorderRadius(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if FBorderRadius = AValue then Exit;
  FBorderRadius := AValue;
  Invalidate;
end;

procedure TFRMaterialCarousel.AnimateTo(AIndex: Integer);
begin
  if AIndex = FActiveIndex then Exit;
  if AIndex > FActiveIndex then
    FAnimDirection := -1  { slide left }
  else
    FAnimDirection := 1;  { slide right }
  FActiveIndex := AIndex;
  FAnimOffset := -FAnimDirection;  { start from opposite side }
  FTargetOffset := 0;
  FAnimTimer.Enabled := True;
  if Assigned(FOnChange) then
    FOnChange(Self, FActiveIndex);
end;

procedure TFRMaterialCarousel.Next;
begin
  if FItems.Count <= 1 then Exit;
  if FActiveIndex < FItems.Count - 1 then
    SetActiveIndex(FActiveIndex + 1)
  else
    SetActiveIndex(0);
end;

procedure TFRMaterialCarousel.Previous;
begin
  if FItems.Count <= 1 then Exit;
  if FActiveIndex > 0 then
    SetActiveIndex(FActiveIndex - 1)
  else
    SetActiveIndex(FItems.Count - 1);
end;

procedure TFRMaterialCarousel.DoAnimTick(Sender: TObject);
var
  speed: Single;
begin
  speed := 0.12;
  if Abs(FAnimOffset - FTargetOffset) < 0.01 then
  begin
    FAnimOffset := FTargetOffset;
    FAnimTimer.Enabled := False;
  end
  else
    FAnimOffset := FAnimOffset + (FTargetOffset - FAnimOffset) * speed;
  Invalidate;
end;

procedure TFRMaterialCarousel.DoAutoTick(Sender: TObject);
begin
  if FDragging then Exit;
  if FAnimTimer.Enabled then Exit;
  Next;
end;

function TFRMaterialCarousel.IndicatorRect: TRect;
var
  indicW, dotSize, dotGap, totalW: Integer;
begin
  dotSize := 8;
  dotGap := 8;
  totalW := FItems.Count * dotSize + (FItems.Count - 1) * dotGap;
  indicW := totalW + 16;
  Result := Rect(
    (Width - indicW) div 2,
    Height - 28,
    (Width + indicW) div 2,
    Height - 8
  );
end;

function TFRMaterialCarousel.IndicatorDotRect(AIdx: Integer): TRect;
var
  dotSize, dotGap, totalW, startX, cx, cy: Integer;
begin
  dotSize := 8;
  dotGap := 8;
  totalW := FItems.Count * dotSize + (FItems.Count - 1) * dotGap;
  startX := (Width - totalW) div 2;
  cx := startX + AIdx * (dotSize + dotGap) + dotSize div 2;
  cy := Height - 18;
  Result := Rect(cx - dotSize div 2, cy - dotSize div 2,
                 cx + dotSize div 2, cy + dotSize div 2);
end;

procedure TFRMaterialCarousel.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (FItems.Count > 1) then
  begin
    FDragging := True;
    FDragStartX := X;
    FDragOffset := 0;
    FAnimTimer.Enabled := False;
  end;
  inherited;
end;

procedure TFRMaterialCarousel.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if FDragging then
  begin
    FDragOffset := (X - FDragStartX) / Width;
    FAnimOffset := FDragOffset;
    Invalidate;
  end;
  inherited;
end;

procedure TFRMaterialCarousel.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  threshold: Single;
begin
  if FDragging then
  begin
    FDragging := False;
    threshold := 0.15;
    if FDragOffset < -threshold then
    begin
      if FActiveIndex < FItems.Count - 1 then
      begin
        Inc(FActiveIndex);
        if Assigned(FOnChange) then
          FOnChange(Self, FActiveIndex);
      end;
    end
    else if FDragOffset > threshold then
    begin
      if FActiveIndex > 0 then
      begin
        Dec(FActiveIndex);
        if Assigned(FOnChange) then
          FOnChange(Self, FActiveIndex);
      end;
    end;
    FAnimOffset := FDragOffset;
    FTargetOffset := 0;
    FAnimTimer.Enabled := True;
  end;
  inherited;
end;

function TFRMaterialCarousel.PaintCached(ABmp: TBGRABitmap): Boolean;
var
  item: TFRMaterialCarouselItem;
  i, drawX, contentH: Integer;
  offset: Single;
  dotRect: TRect;
  dotColor: TColor;
  dotAlpha: Byte;
  titleRect: TRect;
begin
  Result := True;

  contentH := Height;
  if FShowIndicators then
    contentH := Height - 32;

  ABmp.Fill(ColorToBGRA(MD3Colors.SurfaceContainerHighest));

  { Draw current item }
  if FItems.Count > 0 then
  begin
    offset := FAnimOffset;

    { Draw the current and adjacent items for smooth transition }
    for i := -1 to 1 do
    begin
      drawX := Round((i + offset) * Width);
      if (FActiveIndex + i < 0) or (FActiveIndex + i >= FItems.Count) then
        Continue;

      item := FItems[FActiveIndex + i];

      if Assigned(item.FImage.Graphic) and (not item.FImage.Graphic.Empty) then
      begin
        ABmp.Canvas.StretchDraw(
          Rect(drawX, 0, drawX + Width, contentH),
          item.FImage.Graphic);
      end
      else
      begin
        { Placeholder — colored surface }
        MD3FillRoundRect(ABmp, drawX, 0, drawX + Width - 1, contentH - 1,
          0, MD3Colors.SurfaceContainerHigh);
      end;

      { Title overlay gradient at bottom }
      if (item.FTitle <> '') or (item.FSubtitle <> '') then
      begin
        { Semi-transparent gradient overlay }
        ABmp.FillRect(drawX, contentH - 64, drawX + Width, contentH,
          ColorToBGRA(MD3Colors.OnSurface, 100), dmDrawWithTransparency);
      end;
    end;
  end
  else
  begin
    { Empty state }
    ABmp.FontFullHeight := 14;
    ABmp.FontQuality := fqFineAntialiasing;
    ABmp.TextOut(Width div 2 - ABmp.TextSize('No items').cx div 2,
      contentH div 2 - 7,
      'No items', ColorToBGRA(MD3Colors.OnSurfaceVariant));
  end;

  { Indicator dots }
  if FShowIndicators and (FItems.Count > 1) then
  begin
    for i := 0 to FItems.Count - 1 do
    begin
      dotRect := IndicatorDotRect(i);
      if i = FActiveIndex then
      begin
        dotColor := MD3Colors.Primary;
        dotAlpha := 255;
      end
      else
      begin
        dotColor := MD3Colors.OnSurfaceVariant;
        dotAlpha := 100;
      end;
      ABmp.FillEllipseAntialias(
        (dotRect.Left + dotRect.Right) / 2,
        (dotRect.Top + dotRect.Bottom) / 2,
        4, 4,
        ColorToBGRA(dotColor, dotAlpha));
    end;
  end;

  { Title and subtitle text — drawn on Canvas for crisp fonts }
  if (FItems.Count > 0) and (FActiveIndex >= 0) and (FActiveIndex < FItems.Count) then
  begin
    item := FItems[FActiveIndex];
    if item.FTitle <> '' then
    begin
      ABmp.FontHeight := Abs(12 * 96 div 72);
      ABmp.FontStyle := [fsBold];
      titleRect := Rect(16, contentH - 56, Width - 16, contentH - 30);
      MD3DrawTextBGRA(ABmp, item.FTitle, titleRect, MD3Colors.Surface,
        taLeftJustify, True);
    end;
    if item.FSubtitle <> '' then
    begin
      ABmp.FontHeight := Abs(9 * 96 div 72);
      ABmp.FontStyle := [];
      titleRect := Rect(16, contentH - 30, Width - 16, contentH - 8);
      MD3DrawTextBGRA(ABmp, item.FSubtitle, titleRect, MD3Colors.Surface,
        taLeftJustify, True);
    end;
  end;
end;

{ ── Registration ── }

procedure Register;
begin
  {$IFDEF FPC}
    {$I icons\frmaterialcarousel_icon.lrs}
  {$ENDIF}
  RegisterComponents('Material Design 3', [TFRMaterialCarousel]);
end;

end.

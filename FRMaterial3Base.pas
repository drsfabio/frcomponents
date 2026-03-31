unit FRMaterial3Base;

{$mode objfpc}{$H+}

{ Material Design 3 — Foundation unit.

  Provides the MD3 color scheme, shape scale, helper rendering functions,
  and base control classes for all MD3 components.

  License: LGPL v3 — mesma do bgracontrols
}

interface

uses
  Classes, SysUtils, Controls, Graphics,
  {$IFDEF FPC} LCLType, LCLIntf, {$ENDIF}
  BGRABitmap, BGRABitmapTypes;

type
  { MD3 shape scale }
  TFRMDShape = (
    msNone,        // 0dp
    msExtraSmall,  // 4dp
    msSmall,       // 8dp
    msMedium,      // 12dp
    msLarge,       // 16dp
    msExtraLarge,  // 28dp
    msFull         // 50% of smallest dimension
  );

  { Interaction state for MD3 state-layer rendering }
  TFRMDInteractionState = (isNormal, isHovered, isFocused, isPressed, isDisabled);

  { Named palettes }
  TFRMDPalette = (
    mpBaseline,    // Material 3 baseline (purple/magenta)
    mpBlue,
    mpGreen,
    mpTeal,
    mpOrange,
    mpRed,
    mpYellow,
    mpCyan,
    mpDeepPurple,
    mpIndigo,
    mpPink,
    mpBrown
  );

  { MD3 color scheme — all 32 color roles }
  TFRMDColorScheme = record
    Primary: TColor;
    OnPrimary: TColor;
    PrimaryContainer: TColor;
    OnPrimaryContainer: TColor;
    Secondary: TColor;
    OnSecondary: TColor;
    SecondaryContainer: TColor;
    OnSecondaryContainer: TColor;
    Tertiary: TColor;
    OnTertiary: TColor;
    TertiaryContainer: TColor;
    OnTertiaryContainer: TColor;
    Error: TColor;
    OnError: TColor;
    ErrorContainer: TColor;
    OnErrorContainer: TColor;
    Surface: TColor;
    OnSurface: TColor;
    SurfaceVariant: TColor;
    OnSurfaceVariant: TColor;
    Outline: TColor;
    OutlineVariant: TColor;
    SurfaceDim: TColor;
    SurfaceBright: TColor;
    SurfaceContainerLowest: TColor;
    SurfaceContainerLow: TColor;
    SurfaceContainer: TColor;
    SurfaceContainerHigh: TColor;
    SurfaceContainerHighest: TColor;
    InverseSurface: TColor;
    InverseOnSurface: TColor;
    InversePrimary: TColor;
  end;

var
  { Global MD3 color scheme. Defaults to the Material 3 baseline light theme.
    Modify at runtime to switch themes; call Invalidate on forms afterwards. }
  MD3Colors: TFRMDColorScheme;

{ Returns the corner radius in pixels for the given shape and control size. }
function MD3ShapeRadius(AShape: TFRMDShape; ASize: Integer): Integer;

{ Blends AOverlay onto ABase with the given opacity (0..255). }
function MD3Blend(ABase, AOverlay: TColor; AOpacity: Byte): TColor;

{ Returns the state-layer opacity byte for the given interaction state.
  MD3 spec: hover=8%, focus=10%, press=10%. }
function MD3StateOpacity(AState: TFRMDInteractionState): Byte;

{ Draws a filled rounded rectangle with antialiasing. }
procedure MD3FillRoundRect(ABmp: TBGRABitmap; X1, Y1, X2, Y2: Single;
  ARadius: Integer; AFill: TColor; AAlpha: Byte = 255);

{ Draws a rounded rectangle border with antialiasing. }
procedure MD3RoundRect(ABmp: TBGRABitmap; X1, Y1, X2, Y2: Single;
  ARadius: Integer; ABorder: TColor; ABorderWidth: Single = 1.0; AAlpha: Byte = 255);

{ Draws an MD3 state layer (semi-transparent overlay for hover/press/focus). }
procedure MD3StateLayer(ABmp: TBGRABitmap; X1, Y1, X2, Y2: Single;
  ARadius: Integer; AContentColor: TColor; AState: TFRMDInteractionState);

{ Draws text on a Canvas within ARect. Simple and platform-independent. }
procedure MD3DrawText(ACanvas: TCanvas; const AText: string; ARect: TRect;
  AColor: TColor; AHAlign: TAlignment = taCenter; AVCenter: Boolean = True);

{ Initializes MD3Colors with the Material 3 baseline light scheme. }
procedure MD3LoadLightScheme;

{ Initializes MD3Colors with the Material 3 baseline dark scheme. }
procedure MD3LoadDarkScheme;

{ Loads a named palette. ADark selects light or dark variant. }
procedure MD3LoadPalette(APalette: TFRMDPalette; ADark: Boolean = False);

{ Generates a full 32-color scheme from a seed color.
  Uses HSL-based tonal palette generation. }
procedure MD3GenerateScheme(ASeedColor: TColor; ADark: Boolean = False);

{ Returns the current palette count. }
function MD3PaletteCount: Integer;

{ Returns the name of a palette. }
function MD3PaletteName(APalette: TFRMDPalette): string;

type
  { Base class for interactive MD3 components (buttons, switches, etc.).
    Extends TCustomControl (windowed, can receive focus).
    Provides hover/press state tracking. }

  TFRMaterial3Control = class(TCustomControl)
  private
    FHovered: Boolean;
    FPressed: Boolean;
  protected
    procedure EraseBackground({%H-}DC: HDC); override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function InteractionState: TFRMDInteractionState;
  public
    constructor Create(AOwner: TComponent); override;
    property Hovered: Boolean read FHovered;
    property Pressed: Boolean read FPressed;
  end;

  { Base class for visual-only MD3 components (dividers, progress bars, etc.).
    Extends TGraphicControl (lightweight, no window handle). }

  TFRMaterial3Graphic = class(TGraphicControl)
  private
    FHovered: Boolean;
  protected
    procedure MouseEnter; override;
    procedure MouseLeave; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Hovered: Boolean read FHovered;
  end;

implementation

uses Math;

{ ── HSL helpers for palette generation ── }

procedure ColorToHSL(AColor: TColor; out H, S, L: Double);
var
  r, g, b, cmax, cmin, d: Double;
begin
  AColor := ColorToRGB(AColor);
  r := Red(AColor) / 255.0;
  g := Green(AColor) / 255.0;
  b := Blue(AColor) / 255.0;
  cmax := Max(r, Max(g, b));
  cmin := Min(r, Min(g, b));
  L := (cmax + cmin) / 2.0;
  if cmax = cmin then
  begin
    H := 0;
    S := 0;
  end
  else
  begin
    d := cmax - cmin;
    if L > 0.5 then
      S := d / (2.0 - cmax - cmin)
    else
      S := d / (cmax + cmin);
    if cmax = r then
      H := (g - b) / d + (IfThen(g < b, 6, 0))
    else if cmax = g then
      H := (b - r) / d + 2.0
    else
      H := (r - g) / d + 4.0;
    H := H / 6.0;
  end;
end;

function HueToRGB(p, q, t: Double): Double;
begin
  if t < 0 then t := t + 1.0;
  if t > 1 then t := t - 1.0;
  if t < 1/6 then
    Result := p + (q - p) * 6.0 * t
  else if t < 1/2 then
    Result := q
  else if t < 2/3 then
    Result := p + (q - p) * (2/3 - t) * 6.0
  else
    Result := p;
end;

function HSLToColor(H, S, L: Double): TColor;
var
  r, g, b, p, q: Double;
begin
  H := H - Floor(H); { normalize to 0..1 }
  if S <= 0 then
  begin
    r := L; g := L; b := L;
  end
  else
  begin
    if L < 0.5 then
      q := L * (1.0 + S)
    else
      q := L + S - L * S;
    p := 2.0 * L - q;
    r := HueToRGB(p, q, H + 1/3);
    g := HueToRGB(p, q, H);
    b := HueToRGB(p, q, H - 1/3);
  end;
  Result := RGBToColor(
    EnsureRange(Round(r * 255), 0, 255),
    EnsureRange(Round(g * 255), 0, 255),
    EnsureRange(Round(b * 255), 0, 255)
  );
end;

{ Generate a tonal color at a specific tone (0=black, 100=white) }
function ToneColor(H, S: Double; ATone: Integer): TColor;
var
  L: Double;
begin
  L := EnsureRange(ATone, 0, 100) / 100.0;
  Result := HSLToColor(H, S, L);
end;

{ ── Color scheme loaders ── }

procedure MD3LoadLightScheme;
begin
  with MD3Colors do
  begin
    Primary                 := $00A45067;
    OnPrimary               := $00FFFFFF;
    PrimaryContainer        := $00FFDDEA;
    OnPrimaryContainer      := $005D0021;
    Secondary               := $00715B62;
    OnSecondary             := $00FFFFFF;
    SecondaryContainer      := $00F8DEE8;
    OnSecondaryContainer    := $002B191D;
    Tertiary                := $0060527D;
    OnTertiary              := $00FFFFFF;
    TertiaryContainer       := $00E4D8FF;
    OnTertiaryContainer     := $001D1131;
    Error                   := $001E26B3;
    OnError                 := $00FFFFFF;
    ErrorContainer          := $00DCDEF9;
    OnErrorContainer        := $000B0E41;
    Surface                 := $00FFF7FE;
    OnSurface               := $00201B1D;
    SurfaceVariant          := $00ECE0E7;
    OnSurfaceVariant        := $004F4549;
    Outline                 := $007E7479;
    OutlineVariant          := $00D0C4CA;
    SurfaceDim              := $00E1D8DE;
    SurfaceBright           := $00FFF7FE;
    SurfaceContainerLowest  := $00FFFFFF;
    SurfaceContainerLow     := $00FAF2F7;
    SurfaceContainer        := $00F7EDF3;
    SurfaceContainerHigh    := $00F0E6EC;
    SurfaceContainerHighest := $00E9E0E6;
    InverseSurface          := $00333031;
    InverseOnSurface        := $00F5EFF4;
    InversePrimary          := $00FFBCD0;
  end;
end;

procedure MD3LoadDarkScheme;
begin
  with MD3Colors do
  begin
    Primary                 := $00FFBCD0;
    OnPrimary               := $00731E38;
    PrimaryContainer        := $008B374F;
    OnPrimaryContainer      := $00FFDDEA;
    Secondary               := $00DCC2CC;
    OnSecondary             := $00412D33;
    SecondaryContainer      := $0058444A;
    OnSecondaryContainer    := $00F8DEE8;
    Tertiary                := $00C8B8EF;
    OnTertiary              := $00322549;
    TertiaryContainer       := $00483B63;
    OnTertiaryContainer     := $00E4D8FF;
    Error                   := $00C5B8F2;
    OnError                 := $00101460;
    ErrorContainer          := $00181D8C;
    OnErrorContainer        := $00DCDEF9;
    Surface                 := $00181214;
    OnSurface               := $00E9E0E6;
    SurfaceVariant          := $004F4549;
    OnSurfaceVariant        := $00CFC5CA;
    Outline                 := $00998F93;
    OutlineVariant          := $004F4549;
    SurfaceDim              := $00181214;
    SurfaceBright           := $003E383B;
    SurfaceContainerLowest  := $00130D0F;
    SurfaceContainerLow     := $00201B1D;
    SurfaceContainer        := $00261F21;
    SurfaceContainerHigh    := $0030292B;
    SurfaceContainerHighest := $003B3436;
    InverseSurface          := $00E9E0E6;
    InverseOnSurface        := $00333031;
    InversePrimary          := $00A45067;
  end;
end;

{ ── Palette generation ── }

procedure MD3GenerateScheme(ASeedColor: TColor; ADark: Boolean);
var
  pH, pS, pL: Double;   { primary }
  sH, sS: Double;       { secondary (desaturated) }
  tH, tS: Double;       { tertiary (hue shifted +60°) }
  eH, eS: Double;       { error (red) }
  nH, nS: Double;       { neutral }
  nvH, nvS: Double;     { neutral variant }
begin
  ColorToHSL(ASeedColor, pH, pS, pL);

  { Secondary: same hue, reduced saturation }
  sH := pH;
  sS := pS * 0.35;

  { Tertiary: hue shifted +60°, moderate saturation }
  tH := pH + (60.0 / 360.0);
  tS := pS * 0.65;

  { Error: red }
  eH := 0.0;
  eS := 0.75;

  { Neutral: very low saturation from primary hue }
  nH := pH;
  nS := pS * 0.08;

  { Neutral variant: slightly more chroma }
  nvH := pH;
  nvS := pS * 0.18;

  with MD3Colors do
  begin
    if ADark then
    begin
      { === Dark scheme === }
      Primary                 := ToneColor(pH, pS, 80);
      OnPrimary               := ToneColor(pH, pS, 20);
      PrimaryContainer        := ToneColor(pH, pS, 30);
      OnPrimaryContainer      := ToneColor(pH, pS, 90);

      Secondary               := ToneColor(sH, sS, 80);
      OnSecondary             := ToneColor(sH, sS, 20);
      SecondaryContainer      := ToneColor(sH, sS, 30);
      OnSecondaryContainer    := ToneColor(sH, sS, 90);

      Tertiary                := ToneColor(tH, tS, 80);
      OnTertiary              := ToneColor(tH, tS, 20);
      TertiaryContainer       := ToneColor(tH, tS, 30);
      OnTertiaryContainer     := ToneColor(tH, tS, 90);

      Error                   := ToneColor(eH, eS, 80);
      OnError                 := ToneColor(eH, eS, 20);
      ErrorContainer          := ToneColor(eH, eS, 30);
      OnErrorContainer        := ToneColor(eH, eS, 90);

      Surface                 := ToneColor(nH, nS, 6);
      OnSurface               := ToneColor(nH, nS, 90);
      SurfaceVariant          := ToneColor(nvH, nvS, 30);
      OnSurfaceVariant        := ToneColor(nvH, nvS, 80);

      Outline                 := ToneColor(nvH, nvS, 60);
      OutlineVariant          := ToneColor(nvH, nvS, 30);

      SurfaceDim              := ToneColor(nH, nS, 6);
      SurfaceBright           := ToneColor(nH, nS, 24);
      SurfaceContainerLowest  := ToneColor(nH, nS, 4);
      SurfaceContainerLow     := ToneColor(nH, nS, 10);
      SurfaceContainer        := ToneColor(nH, nS, 12);
      SurfaceContainerHigh    := ToneColor(nH, nS, 17);
      SurfaceContainerHighest := ToneColor(nH, nS, 22);

      InverseSurface          := ToneColor(nH, nS, 90);
      InverseOnSurface        := ToneColor(nH, nS, 20);
      InversePrimary          := ToneColor(pH, pS, 40);
    end
    else
    begin
      { === Light scheme === }
      Primary                 := ToneColor(pH, pS, 40);
      OnPrimary               := ToneColor(pH, pS, 100);
      PrimaryContainer        := ToneColor(pH, pS, 90);
      OnPrimaryContainer      := ToneColor(pH, pS, 10);

      Secondary               := ToneColor(sH, sS, 40);
      OnSecondary             := ToneColor(sH, sS, 100);
      SecondaryContainer      := ToneColor(sH, sS, 90);
      OnSecondaryContainer    := ToneColor(sH, sS, 10);

      Tertiary                := ToneColor(tH, tS, 40);
      OnTertiary              := ToneColor(tH, tS, 100);
      TertiaryContainer       := ToneColor(tH, tS, 90);
      OnTertiaryContainer     := ToneColor(tH, tS, 10);

      Error                   := ToneColor(eH, eS, 40);
      OnError                 := ToneColor(eH, eS, 100);
      ErrorContainer          := ToneColor(eH, eS, 90);
      OnErrorContainer        := ToneColor(eH, eS, 10);

      Surface                 := ToneColor(nH, nS, 98);
      OnSurface               := ToneColor(nH, nS, 10);
      SurfaceVariant          := ToneColor(nvH, nvS, 90);
      OnSurfaceVariant        := ToneColor(nvH, nvS, 30);

      Outline                 := ToneColor(nvH, nvS, 50);
      OutlineVariant          := ToneColor(nvH, nvS, 80);

      SurfaceDim              := ToneColor(nH, nS, 87);
      SurfaceBright           := ToneColor(nH, nS, 98);
      SurfaceContainerLowest  := ToneColor(nH, nS, 100);
      SurfaceContainerLow     := ToneColor(nH, nS, 96);
      SurfaceContainer        := ToneColor(nH, nS, 94);
      SurfaceContainerHigh    := ToneColor(nH, nS, 92);
      SurfaceContainerHighest := ToneColor(nH, nS, 90);

      InverseSurface          := ToneColor(nH, nS, 20);
      InverseOnSurface        := ToneColor(nH, nS, 95);
      InversePrimary          := ToneColor(pH, pS, 80);
    end;
  end;
end;

{ ── Named palettes ── }

const
  CPaletteSeedColors: array[TFRMDPalette] of TColor = (
    $00A45067,   { mpBaseline  — magenta/pink }
    $00B85A1A,   { mpBlue      }
    $00388E3C,   { mpGreen     }
    $0080897B,   { mpTeal      }
    $000D8CE5,   { mpOrange    }
    $001B1BD6,   { mpRed       }
    $0000B8F5,   { mpYellow    }
    $00B6A500,   { mpCyan      }
    $00A03B67,   { mpDeepPurple}
    $00994830,   { mpIndigo    }
    $009C27B0,   { mpPink      — actually purple-pink }
    $002D5D79    { mpBrown     }
  );

  CPaletteNames: array[TFRMDPalette] of string = (
    'Baseline', 'Blue', 'Green', 'Teal', 'Orange',
    'Red', 'Yellow', 'Cyan', 'Deep Purple', 'Indigo',
    'Pink', 'Brown'
  );

procedure MD3LoadPalette(APalette: TFRMDPalette; ADark: Boolean);
begin
  if (APalette = mpBaseline) and (not ADark) then
    MD3LoadLightScheme
  else if (APalette = mpBaseline) and ADark then
    MD3LoadDarkScheme
  else
    MD3GenerateScheme(CPaletteSeedColors[APalette], ADark);
end;

function MD3PaletteCount: Integer;
begin
  Result := Ord(High(TFRMDPalette)) + 1;
end;

function MD3PaletteName(APalette: TFRMDPalette): string;
begin
  Result := CPaletteNames[APalette];
end;

{ ── Helper functions ── }

function MD3ShapeRadius(AShape: TFRMDShape; ASize: Integer): Integer;
begin
  case AShape of
    msNone:       Result := 0;
    msExtraSmall: Result := 4;
    msSmall:      Result := 8;
    msMedium:     Result := 12;
    msLarge:      Result := 16;
    msExtraLarge: Result := 28;
    msFull:       Result := ASize div 2;
  else
    Result := 0;
  end;
end;

function MD3Blend(ABase, AOverlay: TColor; AOpacity: Byte): TColor;
var
  rb, gb, bb, ro, go, bo: Byte;
  a: Single;
begin
  ABase := ColorToRGB(ABase);
  AOverlay := ColorToRGB(AOverlay);
  rb := Red(ABase);
  gb := Green(ABase);
  bb := Blue(ABase);
  ro := Red(AOverlay);
  go := Green(AOverlay);
  bo := Blue(AOverlay);
  a := AOpacity / 255.0;
  Result := RGBToColor(
    Round(rb + (ro - rb) * a),
    Round(gb + (go - gb) * a),
    Round(bb + (bo - bb) * a)
  );
end;

function MD3StateOpacity(AState: TFRMDInteractionState): Byte;
begin
  case AState of
    isHovered:  Result := 20;  { 8% of 255 }
    isFocused:  Result := 26;  { 10% }
    isPressed:  Result := 26;  { 10% }
    isDisabled: Result := 0;
  else
    Result := 0;
  end;
end;

procedure MD3FillRoundRect(ABmp: TBGRABitmap; X1, Y1, X2, Y2: Single;
  ARadius: Integer; AFill: TColor; AAlpha: Byte);
var
  c: TBGRAPixel;
begin
  c := ColorToBGRA(ColorToRGB(AFill), AAlpha);
  if ARadius <= 0 then
    ABmp.FillRect(Round(X1), Round(Y1), Round(X2) + 1, Round(Y2) + 1, c, dmDrawWithTransparency)
  else
    ABmp.FillRoundRectAntialias(X1, Y1, X2, Y2, ARadius, ARadius, c);
end;

procedure MD3RoundRect(ABmp: TBGRABitmap; X1, Y1, X2, Y2: Single;
  ARadius: Integer; ABorder: TColor; ABorderWidth: Single; AAlpha: Byte);
var
  c: TBGRAPixel;
begin
  c := ColorToBGRA(ColorToRGB(ABorder), AAlpha);
  if ARadius <= 0 then
    ABmp.RectangleAntialias(X1, Y1, X2, Y2, c, ABorderWidth)
  else
    ABmp.RoundRectAntialias(X1, Y1, X2, Y2, ARadius, ARadius, c, ABorderWidth);
end;

procedure MD3StateLayer(ABmp: TBGRABitmap; X1, Y1, X2, Y2: Single;
  ARadius: Integer; AContentColor: TColor; AState: TFRMDInteractionState);
var
  op: Byte;
begin
  op := MD3StateOpacity(AState);
  if op = 0 then Exit;
  MD3FillRoundRect(ABmp, X1, Y1, X2, Y2, ARadius, AContentColor, op);
end;

procedure MD3DrawText(ACanvas: TCanvas; const AText: string; ARect: TRect;
  AColor: TColor; AHAlign: TAlignment; AVCenter: Boolean);
var
  tw, th, tx, ty: Integer;
begin
  if AText = '' then Exit;
  ACanvas.Font.Color := AColor;
  ACanvas.Brush.Style := bsClear;
  tw := ACanvas.TextWidth(AText);
  th := ACanvas.TextHeight(AText);
  case AHAlign of
    taLeftJustify:  tx := ARect.Left;
    taCenter:       tx := ARect.Left + (ARect.Right - ARect.Left - tw) div 2;
    taRightJustify: tx := ARect.Right - tw;
  end;
  if AVCenter then
    ty := ARect.Top + (ARect.Bottom - ARect.Top - th) div 2
  else
    ty := ARect.Top;
  ACanvas.TextOut(tx, ty, AText);
end;

{ ── TFRMaterial3Control ── }

constructor TFRMaterial3Control.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHovered := False;
  FPressed := False;
  ControlStyle := ControlStyle + [csClickEvents, csCaptureMouse];
  TabStop := True;
end;

procedure TFRMaterial3Control.EraseBackground(DC: HDC);
var
  ARect: TRect;
begin
  if DC = 0 then Exit;
  ARect := Rect(0, 0, Width, Height);
  { Fill with parent background so transparent corners of rounded
    components blend seamlessly instead of showing square artefacts. }
  if Parent <> nil then
    Brush.Color := Parent.Brush.Color
  else
    Brush.Color := MD3Colors.Surface;
  LCLIntf.FillRect(DC, ARect, HBRUSH(Brush.Reference.Handle));
end;

procedure TFRMaterial3Control.MouseEnter;
begin
  FHovered := True;
  Invalidate;
  inherited;
end;

procedure TFRMaterial3Control.MouseLeave;
begin
  FHovered := False;
  FPressed := False;
  Invalidate;
  inherited;
end;

procedure TFRMaterial3Control.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FPressed := True;
    Invalidate;
  end;
  inherited;
end;

procedure TFRMaterial3Control.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FPressed := False;
    Invalidate;
  end;
  inherited;
end;

function TFRMaterial3Control.InteractionState: TFRMDInteractionState;
begin
  if not Enabled then
    Result := isDisabled
  else if FPressed then
    Result := isPressed
  else if Focused then
    Result := isFocused
  else if FHovered then
    Result := isHovered
  else
    Result := isNormal;
end;

{ ── TFRMaterial3Graphic ── }

constructor TFRMaterial3Graphic.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHovered := False;
end;

procedure TFRMaterial3Graphic.MouseEnter;
begin
  FHovered := True;
  Invalidate;
  inherited;
end;

procedure TFRMaterial3Graphic.MouseLeave;
begin
  FHovered := False;
  Invalidate;
  inherited;
end;

initialization
  MD3LoadLightScheme;

end.

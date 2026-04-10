unit FRMaterial3Base;

{$mode objfpc}{$H+}

{ Material Design 3 — Foundation unit.

  Provides the MD3 color scheme, shape scale, helper rendering functions,
  and base control classes for all MD3 components.

  License: LGPL v3 — mesma do bgracontrols
}

interface

uses
  Classes, SysUtils, Controls, Graphics, ExtCtrls,
  {$IFDEF FPC} LCLType, LCLIntf, {$ENDIF}
  BGRABitmap, BGRABitmapTypes, FRMaterialTheme, FRMaterialMasks;

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

{ Draws a filled rectangle with only the top two corners rounded.
  Used by mvFilled edit fields per MD3 spec. }
procedure MD3FillTopRoundRect(ABmp: TBGRABitmap; X1, Y1, X2, Y2: Single;
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

{ Draws text on a TBGRABitmap with proper antialiasing on transparent backgrounds.
  Use this instead of MD3DrawText inside PaintCached methods. }
procedure MD3DrawTextBGRA(ABmp: TBGRABitmap; const AText: string; ARect: TRect;
  AColor: TColor; AHAlign: TAlignment = taCenter; AVCenter: Boolean = True);

{ Desenha sombra MD3 com nível de elevação. }
procedure MD3DrawShadow(ABmp: TBGRABitmap; X1, Y1, X2, Y2: Single;
  ARadius: Integer; ALevel: TFRMDElevation);

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

  TFRMaterial3Control = class(TCustomControl, IFRMaterialComponent)
  private
    FHovered: Boolean;
    FPressed: Boolean;
    FDensity: TFRMDDensity;
    FSyncWithTheme: TFRMDSyncOptions;
    { Ripple animation }
    FRippleX: Integer;
    FRippleY: Integer;
    FRippleProgress: Single;
    FRippleFading: Boolean;
    FRippleFadeProgress: Single;
    FRippleTimer: TTimer;
    { Paint cache — evita recriar TBGRABitmap a cada Paint }
    FPaintCache: TBGRABitmap;
    FPaintCacheW: Integer;
    FPaintCacheH: Integer;
    procedure DoRippleTick(Sender: TObject);
  protected
    procedure EraseBackground({%H-}DC: HDC); override;
    procedure Paint; override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure SetDensity(AValue: TFRMDDensity); virtual;
    function InteractionState: TFRMDInteractionState;
    { Desenha o efeito ripple (círculo expandindo do ponto de clique) }
    procedure PaintRipple(ABmp: TBGRABitmap; ARippleColor: TColor);
    { Renderiza o conteúdo do componente no bitmap. Override nos descendentes.
      Retorna True se o bitmap foi pintado; False para pular o cache (ex: componentes
      com subcontroles que pintam diretamente no Canvas, como Edits). }
    function PaintCached(ABmp: TBGRABitmap): Boolean; virtual;
    { Cor usada pelo ripple. Override para customizar (ex: OnPrimary para botões filled). }
    function RippleColor: TColor; virtual;
    { Marca o cache de pintura como inválido. Chamar quando propriedades visuais mudam. }
    procedure InvalidatePaintCache;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const AThemeManager: TObject); virtual;
    property Hovered: Boolean read FHovered;
    property Pressed: Boolean read FPressed;
  published
    property Align;
    property Anchors;
    property BorderSpacing;
    property ShowHint;
    property ParentShowHint;
    property TabOrder;
    property TabStop;
    property Density: TFRMDDensity read FDensity write SetDensity default ddNormal;
    property SyncWithTheme: TFRMDSyncOptions read FSyncWithTheme write FSyncWithTheme default [toColor, toDensity, toVariant];
  end;

  { Base class for visual-only MD3 components (dividers, progress bars, etc.).
    Extends TGraphicControl (lightweight, no window handle). }

  TFRMaterial3Graphic = class(TGraphicControl, IFRMaterialComponent)
  private
    FHovered: Boolean;
    { Paint cache — evita recriar TBGRABitmap a cada Paint }
    FPaintCache: TBGRABitmap;
    FPaintCacheW: Integer;
    FPaintCacheH: Integer;
  protected
    procedure Paint; override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    { Renderiza o conteúdo no bitmap. Override nos descendentes.
      Retorna True se pintou; False para pular o cache. }
    function PaintCached(ABmp: TBGRABitmap): Boolean; virtual;
    { Marca o cache de pintura como inválido. }
    procedure InvalidatePaintCache;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyTheme(const AThemeManager: TObject); virtual;
    property Hovered: Boolean read FHovered;
  published
    property Anchors;
  end;

  { TFRMaterialCustomControl
    Base para componentes MD3 que possuem estados de validação, densidade
    e labels auxiliares (Edits, CheckCombos, etc). }

  TFRMaterialCustomControl = class(TFRMaterial3Control)
  protected
    FAccentColor: TColor;
    FDisabledColor: TColor;
    FValidationState: TFRValidationState;
    FHelperText: string;
    FErrorText: string;
    FRequired: Boolean;

    procedure SetValidationState(AValue: TFRValidationState); virtual;
    procedure SetRequired(AValue: Boolean); virtual;
    procedure SetHelperText(const AValue: string); virtual;
    procedure SetErrorText(const AValue: string); virtual;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property AccentColor: TColor read FAccentColor write FAccentColor;
    property DisabledColor: TColor read FDisabledColor write FDisabledColor;
    property ValidationState: TFRValidationState read FValidationState write SetValidationState default vsNone;
    property HelperText: string read FHelperText write SetHelperText;
    property ErrorText: string read FErrorText write SetErrorText;
    property Required: Boolean read FRequired write SetRequired default False;
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

procedure MD3FillTopRoundRect(ABmp: TBGRABitmap; X1, Y1, X2, Y2: Single;
  ARadius: Integer; AFill: TColor; AAlpha: Byte);
var
  c: TBGRAPixel;
  rx: Integer;
begin
  c := ColorToBGRA(ColorToRGB(AFill), AAlpha);
  { Use at least 4px radius per MD3 spec for filled fields }
  rx := ARadius;
  if rx <= 0 then rx := 4;
  { Draw normally rounded rect, then fill bottom corners as squares }
  ABmp.FillRoundRectAntialias(X1, Y1, X2, Y2, rx, rx, c);
  { Overdraw bottom-left corner }
  ABmp.FillRect(Round(X1), Round(Y2) - rx, Round(X1) + rx, Round(Y2) + 1, c, dmDrawWithTransparency);
  { Overdraw bottom-right corner }
  ABmp.FillRect(Round(X2) - rx + 1, Round(Y2) - rx, Round(X2) + 1, Round(Y2) + 1, c, dmDrawWithTransparency);
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

procedure MD3DrawTextBGRA(ABmp: TBGRABitmap; const AText: string; ARect: TRect;
  AColor: TColor; AHAlign: TAlignment; AVCenter: Boolean);
var
  sz: TSize;
  tx, ty: Integer;
begin
  if AText = '' then Exit;
  ABmp.FontQuality := fqFineAntialiasing;
  sz := ABmp.TextSize(AText);
  case AHAlign of
    taLeftJustify:  tx := ARect.Left;
    taCenter:       tx := ARect.Left + (ARect.Right - ARect.Left - sz.cx) div 2;
    taRightJustify: tx := ARect.Right - sz.cx;
  end;
  if AVCenter then
    ty := ARect.Top + (ARect.Bottom - ARect.Top - sz.cy) div 2
  else
    ty := ARect.Top;
  ABmp.TextOut(tx, ty, AText, ColorToBGRA(ColorToRGB(AColor)));
end;

{ ── MD3DrawShadow ── }

procedure MD3DrawShadow(ABmp: TBGRABitmap; X1, Y1, X2, Y2: Single;
  ARadius: Integer; ALevel: TFRMDElevation);
var
  off, i, layers: Integer;
  alpha: Byte;
begin
  if ALevel = elLevel0 then Exit;
  off := MD3ElevationOffset(ALevel);
  layers := EnsureRange(off, 1, 4);
  for i := layers downto 1 do
  begin
    alpha := EnsureRange(30 div i, 5, 30);
    MD3FillRoundRect(ABmp, X1 + i, Y1 + i + off, X2 - i, Y2 + off,
      ARadius, MD3Colors.OnSurface, alpha);
  end;
end;

{ ── TFRMaterial3Control ── }

constructor TFRMaterial3Control.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHovered := False;
  FPressed := False;
  FRippleProgress := 0;
  FRippleFading := False;
  FRippleFadeProgress := 0;
  FRippleTimer := nil;
  FPaintCache := nil;
  FPaintCacheW := 0;
  FPaintCacheH := 0;
  ControlStyle := ControlStyle + [csClickEvents, csCaptureMouse];
  TabStop := True;

  FRMDRegisterComponent(Self);
end;

destructor TFRMaterial3Control.Destroy;
begin
  FreeAndNil(FPaintCache);
  FreeAndNil(FRippleTimer);
  FRMDUnregisterComponent(Self);
  inherited Destroy;
end;

procedure TFRMaterial3Control.ApplyTheme(const AThemeManager: TObject);
begin
  if not Assigned(AThemeManager) then Exit;

  if toDensity in FSyncWithTheme then
    SetDensity(FRMDGetThemeDensity(AThemeManager));

  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterial3Control.InvalidatePaintCache;
begin
  FreeAndNil(FPaintCache);
  FPaintCacheW := 0;
  FPaintCacheH := 0;
end;

function TFRMaterial3Control.PaintCached(ABmp: TBGRABitmap): Boolean;
begin
  { Retorna False por padrão — descendentes que não usam bitmap
    (ex: Edits com sub-controles) podem ignorar o cache. }
  Result := False;
end;

function TFRMaterial3Control.RippleColor: TColor;
begin
  Result := MD3Colors.OnSurface;
end;

procedure TFRMaterial3Control.Paint;
var
  NeedsRebuild: Boolean;
  bmpRipple: TBGRABitmap;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  NeedsRebuild := (FPaintCache = nil)
    or (FPaintCacheW <> Width)
    or (FPaintCacheH <> Height);

  if NeedsRebuild then
  begin
    FreeAndNil(FPaintCache);
    FPaintCache := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
    { GDI canvas font (for Canvas.TextWidth measurements) }
    FPaintCache.Canvas.Font := Self.Font;
    FPaintCache.Canvas.Font.PixelsPerInch := Font.PixelsPerInch;
    { BGRABitmap native font (for MD3DrawTextBGRA / ABmp.TextOut) }
    FPaintCache.FontName := Self.Font.Name;
    FPaintCache.FontStyle := Self.Font.Style;
    FPaintCache.FontQuality := fqFineAntialiasing;
    if Self.Font.Size > 0 then
      FPaintCache.FontHeight := Abs(Self.Font.Height)
    else
      FPaintCache.FontFullHeight := 14;
    if not PaintCached(FPaintCache) then
    begin
      FreeAndNil(FPaintCache);
      FPaintCacheW := 0;
      FPaintCacheH := 0;
      Exit;
    end;
    FPaintCacheW := Width;
    FPaintCacheH := Height;
  end;

  { Ripple ativo: combina cache + ripple em bitmap temporário }
  if (FRippleProgress > 0) or FRippleFading then
  begin
    bmpRipple := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
    try
      bmpRipple.PutImage(0, 0, FPaintCache, dmDrawWithTransparency);
      PaintRipple(bmpRipple, RippleColor);
      bmpRipple.Draw(Canvas, 0, 0, False);
    finally
      bmpRipple.Free;
    end;
  end
  else
    FPaintCache.Draw(Canvas, 0, 0, False);
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
  InvalidatePaintCache;
  Invalidate;
  inherited;
end;

procedure TFRMaterial3Control.MouseLeave;
begin
  FHovered := False;
  FPressed := False;
  InvalidatePaintCache;
  if FRippleProgress > 0 then
  begin
    FRippleFading := True;
    FRippleFadeProgress := 0;
  end;
  Invalidate;
  inherited;
end;

procedure TFRMaterial3Control.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FPressed := True;
    InvalidatePaintCache;
    { Start ripple animation }
    if not (csDesigning in ComponentState) then
    begin
      FRippleX := X;
      FRippleY := Y;
      FRippleProgress := 0;
      FRippleFading := False;
      FRippleFadeProgress := 0;
      if FRippleTimer = nil then
      begin
        FRippleTimer := TTimer.Create(Self);
        FRippleTimer.Interval := 16;
        FRippleTimer.OnTimer := @DoRippleTick;
      end;
      FRippleTimer.Enabled := True;
    end;
    Invalidate;
  end;
  inherited;
end;

procedure TFRMaterial3Control.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FPressed := False;
    InvalidatePaintCache;
    { Start fade-out }
    if FRippleProgress > 0 then
    begin
      FRippleFading := True;
      FRippleFadeProgress := 0;
    end;
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

procedure TFRMaterial3Control.DoRippleTick(Sender: TObject);
begin
  if FRippleFading then
  begin
    FRippleFadeProgress := FRippleFadeProgress + 0.12;
    if FRippleFadeProgress >= 1.0 then
    begin
      FRippleFadeProgress := 1.0;
      FRippleFading := False;
      FRippleProgress := 0;
      if Assigned(FRippleTimer) then
        FRippleTimer.Enabled := False;
    end;
  end
  else
  begin
    FRippleProgress := FRippleProgress + 0.08;
    if FRippleProgress >= 1.0 then
    begin
      FRippleProgress := 1.0;
      if not FPressed then
      begin
        FRippleFading := True;
        FRippleFadeProgress := 0;
      end;
    end;
  end;
  Invalidate;
end;

procedure TFRMaterial3Control.PaintRipple(ABmp: TBGRABitmap; ARippleColor: TColor);
var
  maxR, currentR: Single;
  alpha: Byte;
begin
  if (FRippleProgress <= 0) and (not FRippleFading) then Exit;

  maxR := Sqrt(Sqr(Single(Width)) + Sqr(Single(Height)));
  currentR := maxR * FRippleProgress;

  if FRippleFading then
    alpha := EnsureRange(Round(25 * (1.0 - FRippleFadeProgress)), 0, 255)
  else
    alpha := 25; { ~10% opacity per MD3 spec }

  if alpha <= 0 then Exit;

  ABmp.FillEllipseAntialias(FRippleX, FRippleY, currentR, currentR,
    ColorToBGRA(ColorToRGB(ARippleColor), alpha));
end;

{ ── TFRMaterial3Graphic ── }

constructor TFRMaterial3Graphic.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHovered := False;
  FPaintCache := nil;
  FPaintCacheW := 0;
  FPaintCacheH := 0;

  FRMDRegisterComponent(Self);
end;

destructor TFRMaterial3Graphic.Destroy;
begin
  FreeAndNil(FPaintCache);
  FRMDUnregisterComponent(Self);
  inherited Destroy;
end;

procedure TFRMaterial3Graphic.ApplyTheme(const AThemeManager: TObject);
begin
  if not Assigned(AThemeManager) then Exit;
  InvalidatePaintCache;
  Invalidate;
end;

procedure TFRMaterial3Graphic.InvalidatePaintCache;
begin
  FreeAndNil(FPaintCache);
  FPaintCacheW := 0;
  FPaintCacheH := 0;
end;

function TFRMaterial3Graphic.PaintCached(ABmp: TBGRABitmap): Boolean;
begin
  Result := False;
end;

procedure TFRMaterial3Graphic.Paint;
var
  NeedsRebuild: Boolean;
begin
  if (Width <= 0) or (Height <= 0) then Exit;

  NeedsRebuild := (FPaintCache = nil)
    or (FPaintCacheW <> Width)
    or (FPaintCacheH <> Height);

  if NeedsRebuild then
  begin
    FreeAndNil(FPaintCache);
    FPaintCache := TBGRABitmap.Create(Width, Height, BGRAPixelTransparent);
    FPaintCache.Canvas.Font := Self.Font;
    FPaintCache.Canvas.Font.PixelsPerInch := Font.PixelsPerInch;
    FPaintCache.FontName := Self.Font.Name;
    FPaintCache.FontStyle := Self.Font.Style;
    FPaintCache.FontQuality := fqFineAntialiasing;
    if Self.Font.Size > 0 then
      FPaintCache.FontHeight := Abs(Self.Font.Height)
    else
      FPaintCache.FontFullHeight := 14;
    if not PaintCached(FPaintCache) then
    begin
      FreeAndNil(FPaintCache);
      FPaintCacheW := 0;
      FPaintCacheH := 0;
      Exit;
    end;
    FPaintCacheW := Width;
    FPaintCacheH := Height;
  end;

  FPaintCache.Draw(Canvas, 0, 0, False);
end;

procedure TFRMaterial3Graphic.MouseEnter;
begin
  FHovered := True;
  InvalidatePaintCache;
  Invalidate;
  inherited;
end;

procedure TFRMaterial3Graphic.MouseLeave;
begin
  FHovered := False;
  InvalidatePaintCache;
  Invalidate;
  inherited;
end;

{ ── TFRMaterialCustomControl ── }

constructor TFRMaterialCustomControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAccentColor := clHighlight;
  FDisabledColor := $00B8AFA8;
  FValidationState := vsNone;
  FRequired := False;
end;

procedure TFRMaterial3Control.SetDensity(AValue: TFRMDDensity);
begin
  if FDensity <> AValue then
  begin
    FDensity := AValue;
    InvalidatePaintCache;
    Invalidate;
    DoOnResize;
  end;
end;

procedure TFRMaterialCustomControl.SetValidationState(AValue: TFRValidationState);
begin
  if FValidationState <> AValue then
  begin
    FValidationState := AValue;
    Invalidate;
  end;
end;

procedure TFRMaterialCustomControl.SetRequired(AValue: Boolean);
begin
  if FRequired <> AValue then
  begin
    FRequired := AValue;
    Invalidate;
  end;
end;

procedure TFRMaterialCustomControl.SetHelperText(const AValue: string);
begin
  if FHelperText <> AValue then
  begin
    FHelperText := AValue;
    DoOnResize;
    Invalidate;
  end;
end;

procedure TFRMaterialCustomControl.SetErrorText(const AValue: string);
begin
  if FErrorText <> AValue then
  begin
    FErrorText := AValue;
    DoOnResize;
    Invalidate;
  end;
end;

initialization
  MD3LoadLightScheme;

end.

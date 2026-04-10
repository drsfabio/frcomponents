unit FRMaterialTheme;

{$mode objfpc}{$H+}

{ Utilitários de tema compartilhados pelos componentes Material Design.

  Exporta:
    TFRMaterialVariant — enum para os três estilos visuais de campo
    MCLuminance        — luminância relativa de uma cor (WCAG 2.1)
    MCContrastRatio    — razão de contraste entre duas cores (WCAG 2.1)
    MCContrastText     — retorna clBlack ou clWhite para máximo contraste

  Licença: LGPL v3 — mesma do bgracontrols
}

interface

uses
  Graphics, Math, SysUtils;

type
  { Variante visual do campo Material Design.

    mvStandard : apenas sublinhado na base (estilo MD2 — padrão histórico)
    mvFilled   : campo preenchido com cantos arredondados + sublinhado na base
    mvOutlined : moldura retangular/arredondada sem sublinhado (estilo MD3)
  }
  TFRMaterialVariant = (
    mvStandard,
    mvFilled,
    mvOutlined
  );

  { Density scale MD3. Cada nível reduz alturas em 4px.
    Equiv: 0, -1, -2, -3 na spec MD3. }
  TFRMDDensity = (
    ddNormal,      {  0px — espaço padrão    }
    ddCompact,     { -4px — compacto         }
    ddDense,       { -8px — denso            }
    ddUltraDense   { -12px — espaço mínimo   }
  );

  { Elevation levels MD3. Controla intensidade da sombra.
    Level0=0dp, Level1=1dp, Level2=3dp, Level3=6dp, Level4=8dp, Level5=12dp. }
  TFRMDElevation = (
    elLevel0,      { 0dp  — sem sombra            }
    elLevel1,      { 1dp  — card em repouso        }
    elLevel2,      { 3dp  — card hover, FAB rest    }
    elLevel3,      { 6dp  — FAB pressed, snackbar   }
    elLevel4,      { 8dp  — menu, dialog            }
    elLevel5       { 12dp — modal sheets            }
  );

  { Opções de sincronização com o ThemeManager global }
  TFRMDSyncOption = (toColor, toDensity, toVariant);
  TFRMDSyncOptions = set of TFRMDSyncOption;

  { Interface a ser implementada por todo componente que desejar
    ouvir mudanças globais de tema/paleta. }
  IFRMaterialComponent = interface
    ['{6BC17C2F-4A93-4B0F-8761-DCED7B94B5CB}']
    procedure ApplyTheme(const AThemeManager: TObject);
  end;

  { Interface exposta pelo TFRMaterialThemeManager para que componentes
    base possam registrar-se e ler propriedades sem criar dependência
    circular de unidade. }
  IFRMaterialThemeManager = interface
    ['{A3D71C8F-9642-4E30-B812-3F5E9C1A7B20}']
    procedure RegisterComponent(AComponent: IFRMaterialComponent);
    procedure UnregisterComponent(AComponent: IFRMaterialComponent);
    function GetDensity: TFRMDDensity;
    function GetVariant: TFRMaterialVariant;
    property Density: TFRMDDensity read GetDensity;
    property Variant: TFRMaterialVariant read GetVariant;
  end;

var
  FRMaterialDefaultThemeManager: TObject = nil;

{ Retorna a luminância relativa de AColor segundo o modelo WCAG 2.1 (0..1).
  Use para calcular contraste entre cores de texto e fundo. }
function MCLuminance(AColor: TColor): Single;

{ Retorna a razão de contraste WCAG 2.1 entre AFg (frente) e ABg (fundo).
  Valores: 1 (sem contraste) … 21 (preto sobre branco).
  AA large requer >= 3.0; AA normal >= 4.5; AAA >= 7.0. }
function MCContrastRatio(AFg, ABg: TColor): Single;

{ Retorna clBlack ou clWhite — a cor que garante maior contraste sobre ABg.
  Útil para escolher automaticamente a cor de legenda/ícone sobre qualquer fundo.

  Exemplo:
    FLabel.Font.Color := MCContrastText(Self.Color);
}
function MCContrastText(ABg: TColor): TColor;

{ Retorna o delta em pixels para a escala de densidade.
  Normal=0, Compact=-4, Dense=-8, UltraDense=-12. }
function MD3DensityDelta(ADensity: TFRMDDensity): Integer;

{ Calcula o Font.Size ideal para um campo de entrada com a altura informada.
  Referência MD3: Height 56 → Font.Size 12 (body-large).
  Aplica redução proporcional para densidades maiores:
  Normal=0, Compact=-1, Dense=-2, UltraDense=-3.
  Resultado clamped entre 8 e 16. }
function MD3FontSizeForField(AHeight: Integer; ADensity: TFRMDDensity): Integer;

{ Retorna o offset de sombra em pixels para o nível de elevação MD3. }
function MD3ElevationOffset(ALevel: TFRMDElevation): Integer;

{ Registra AComponent no ThemeManager global, se disponível.
  Chame no constructor dos componentes MD3. }
procedure FRMDRegisterComponent(AComponent: IFRMaterialComponent);

{ Remove o registro de AComponent no ThemeManager global, se disponível.
  Chame no destructor dos componentes MD3. }
procedure FRMDUnregisterComponent(AComponent: IFRMaterialComponent);

{ Retorna a densidade do AThemeManager (via IFRMaterialThemeManager).
  Retorna ddNormal se AThemeManager não implementar a interface. }
function FRMDGetThemeDensity(AThemeManager: TObject): TFRMDDensity;

{ Retorna a variante visual do AThemeManager (via IFRMaterialThemeManager).
  Retorna mvStandard se AThemeManager não implementar a interface. }
function FRMDGetThemeVariant(AThemeManager: TObject): TFRMaterialVariant;

implementation

{ Lineariza um canal de cor de 0-255 para espaço linear (sRGB → linear RGB) }
function MCLinearize(AChannel: Byte): Single;
var
  S: Single;
begin
  S := AChannel / 255.0;
  if S <= 0.04045 then
    Result := S / 12.92
  else
    Result := Power((S + 0.055) / 1.055, 2.4);
end;

function MCLuminance(AColor: TColor): Single;
var
  C: TColor;
begin
  C := ColorToRGB(AColor);
  Result :=
    0.2126 * MCLinearize(Red(C)) +
    0.7152 * MCLinearize(Green(C)) +
    0.0722 * MCLinearize(Blue(C));
end;

function MCContrastRatio(AFg, ABg: TColor): Single;
var
  L1, L2, Tmp: Single;
begin
  L1 := MCLuminance(AFg);
  L2 := MCLuminance(ABg);
  if L1 < L2 then
  begin
    Tmp := L1;
    L1  := L2;
    L2  := Tmp;
  end;
  Result := (L1 + 0.05) / (L2 + 0.05);
end;

function MCContrastText(ABg: TColor): TColor;
begin
  if MCContrastRatio(clWhite, ABg) >= MCContrastRatio(clBlack, ABg) then
    Result := clWhite
  else
    Result := clBlack;
end;

function MD3DensityDelta(ADensity: TFRMDDensity): Integer;
const
  Deltas: array[TFRMDDensity] of Integer = (0, -4, -8, -12);
begin
  Result := Deltas[ADensity];
end;

function MD3FontSizeForField(AHeight: Integer; ADensity: TFRMDDensity): Integer;
const
  { Redução de fonte por nível de densidade (Normal=0, Compact=-1, Dense=-1, UltraDense=-2) }
  FontDeltas: array[TFRMDDensity] of Integer = (0, -1, -1, -2);
begin
  { Base: proporcional à altura. Ref MD3: Height 56 → Size 12 }
  Result := AHeight * 12 div 56;
  { Aplica delta de densidade }
  Result := Result + FontDeltas[ADensity];
  { Clamp entre 8 e 16 }
  if Result < 8 then Result := 8;
  if Result > 16 then Result := 16;
end;

function MD3ElevationOffset(ALevel: TFRMDElevation): Integer;
const
  Offsets: array[TFRMDElevation] of Integer = (0, 1, 3, 6, 8, 12);
begin
  Result := Offsets[ALevel];
end;

procedure FRMDRegisterComponent(AComponent: IFRMaterialComponent);
var
  TM: IFRMaterialThemeManager;
begin
  if Supports(FRMaterialDefaultThemeManager, IFRMaterialThemeManager, TM) then
    TM.RegisterComponent(AComponent);
end;

procedure FRMDUnregisterComponent(AComponent: IFRMaterialComponent);
var
  TM: IFRMaterialThemeManager;
begin
  if Supports(FRMaterialDefaultThemeManager, IFRMaterialThemeManager, TM) then
    TM.UnregisterComponent(AComponent);
end;

function FRMDGetThemeDensity(AThemeManager: TObject): TFRMDDensity;
var
  TM: IFRMaterialThemeManager;
begin
  if Supports(AThemeManager, IFRMaterialThemeManager, TM) then
    Result := TM.Density
  else
    Result := ddNormal;
end;

function FRMDGetThemeVariant(AThemeManager: TObject): TFRMaterialVariant;
var
  TM: IFRMaterialThemeManager;
begin
  if Supports(AThemeManager, IFRMaterialThemeManager, TM) then
    Result := TM.Variant
  else
    Result := mvStandard;
end;

end.

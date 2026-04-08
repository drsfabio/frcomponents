unit FRMaterialIcons;

{$mode objfpc}{$H+}

{ Ícones SVG vetoriais e botão com renderização via BGRABitmap.
  Usado internamente pelos componentes TFRMaterial* para botões de
  limpar (×), pesquisar (lupa) e calendário.

  TFRMaterialIconButton:
    TSpeedButton com renderização SVG, cache de ícone e efeito hover.
    Três modos: imClear (X vermelho), imSearch (lupa), imCalendar.
    Cores Normal/Hover configuráveis; StrokeWidth parametrizável.

  Funções públicas de SVG:
    FRColorToSVGHex  — converte TColor para '#rrggbb'
    FRClearIconSVG   — retorna SVG do ícone "X"
    FRSearchIconSVG  — retorna SVG da lupa
    FRCalendarIconSVG— retorna SVG do calendário
    FRRenderSVGIcon  — renderiza string SVG em TBGRABitmap

  Licença: LGPL v3 — mesma do bgracontrols
}

interface

uses
  Classes, SysUtils, Controls, Buttons, Graphics,
  BGRABitmap, BGRABitmapTypes, Generics.Collections;

type
  { Modo do ícone exibido no botão }
  TFRIconMode = (
    imClear, imSearch, imCalendar, imEyeOpen, imEyeClosed, imCopy, imPlus, imMinus,
    { Novos ícones MD3 }
    imHome, imMenu, imArrowBack, imArrowForward, imMoreVert,
    imCheck, imEdit, imDelete, imShare, imStar,
    imFavorite, imSettings, imPerson, imNotification, imMail,
    imDownload, imUpload, imRefresh, imFilter, imAttach, imLink,
    imNightlight, imLightMode, imList, imDashboard,
    imExpandMore, imExpandLess, imFolder, imFolderOpen,
    imWarning, imInfo, imError, imSuccess, imHelp,
    imLock, imShield,
    { Financeiro }
    imMoney, imCreditCard, imWallet, imReceipt,
    imBarChart, imPieChart, imTrendUp, imTrendDown,
    imPercent, imBank, imCalculator, imCoin,
    { Estoque / Logística }
    imBox, imBarcode, imTruck, imWarehouse,
    imTag, imShoppingCart, imScale,
    { Negócios / ERP }
    imStore, imStorefront, imLocalShipping, imRoute,
    imInventory, imCashFlow, imAccountBalance, imTax,
    imInvoice, imHandshake, imFactory, imQrCode,
    imPrinter, imClipboard, imAssignment,
    imReport, imFile, imKpi
  );

  { TFRMaterialIconButton
    TSpeedButton com renderização SVG vetorial e efeito hover.
    Suporta múltiplos modos de ícone com cache simplificado. }

  TFRMaterialIconButton = class(TSpeedButton)
  private
    FHovered: Boolean;
    FIconMode: TFRIconMode;
    FNormalColor: TColor;
    FHoverColor: TColor;
    FStrokeWidth: Double;
    FCacheNormal: TBGRABitmap;
    FCacheHover: TBGRABitmap;
    FCacheMode: TFRIconMode;
    FCacheW: Integer;
    FCacheH: Integer;
    procedure RebuildCache;
    procedure SetIconMode(AValue: TFRIconMode);
  protected
    procedure Paint; override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Descarta o cache para forçar re-renderização (chamar após mudar cores) }
    procedure InvalidateCache;
    property IconMode: TFRIconMode read FIconMode write SetIconMode;
    property NormalColor: TColor read FNormalColor write FNormalColor;
    property HoverColor: TColor read FHoverColor write FHoverColor;
    { Espessura do traço SVG; 0 = usa padrão de cada ícone }
    property StrokeWidth: Double read FStrokeWidth write FStrokeWidth;
  end;

{ ── Funções públicas de SVG ── }

function FRColorToSVGHex(AColor: TColor): string;
function FRClearIconSVG(const AHex: string; AStroke: Double = 3.0): string;
function FRSearchIconSVG(const AHex: string; AStroke: Double = 2.5): string;
function FRCalendarIconSVG(const AHex: string; AStroke: Double = 2.5): string;
function FREyeOpenIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FREyeClosedIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRCopyIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRPlusIconSVG(const AHex: string; AStroke: Double = 2.5): string;
function FRMinusIconSVG(const AHex: string; AStroke: Double = 2.5): string;
function FRHomeIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRMenuIconSVG(const AHex: string; AStroke: Double = 2.5): string;
function FRArrowBackIconSVG(const AHex: string; AStroke: Double = 2.5): string;
function FRArrowForwardIconSVG(const AHex: string; AStroke: Double = 2.5): string;
function FRMoreVertIconSVG(const AHex: string; AStroke: Double = 0): string;
function FRCheckIconSVG(const AHex: string; AStroke: Double = 2.5): string;
function FREditIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRDeleteIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRShareIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRStarIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRFavoriteIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRSettingsIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRPersonIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRNotificationIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRMailIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRDownloadIconSVG(const AHex: string; AStroke: Double = 2.5): string;
function FRUploadIconSVG(const AHex: string; AStroke: Double = 2.5): string;
function FRRefreshIconSVG(const AHex: string; AStroke: Double = 2.5): string;
function FRFilterIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRAttachIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRLinkIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRNightlightIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRLightModeIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRListIconSVG(const AHex: string; AStroke: Double = 2.5): string;
function FRDashboardIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRExpandMoreIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRExpandLessIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRFolderIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRFolderOpenIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRWarningIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRInfoIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRErrorIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRSuccessIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRHelpIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRLockIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRShieldIconSVG(const AHex: string; AStroke: Double = 2.0): string;
{ Financeiro }
function FRMoneyIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRCreditCardIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRWalletIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRReceiptIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRBarChartIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRPieChartIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRTrendUpIconSVG(const AHex: string; AStroke: Double = 2.5): string;
function FRTrendDownIconSVG(const AHex: string; AStroke: Double = 2.5): string;
function FRPercentIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRBankIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRCalculatorIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRCoinIconSVG(const AHex: string; AStroke: Double = 2.0): string;
{ Estoque / Logística }
function FRBoxIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRBarcodeIconSVG(const AHex: string): string;
function FRTruckIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRWarehouseIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRTagIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRShoppingCartIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRScaleIconSVG(const AHex: string; AStroke: Double = 2.0): string;
{ Negócios / ERP }
function FRStoreIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRStorefrontIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRLocalShippingIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRRouteIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRInventoryIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRCashFlowIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRAccountBalanceIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRTaxIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRInvoiceIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRHandshakeIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRFactoryIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRQrCodeIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRPrinterIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRClipboardIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRAssignmentIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRReportIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRFileIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRKpiIconSVG(const AHex: string; AStroke: Double = 2.0): string;
function FRRenderSVGIcon(const ASVG: string; AW, AH: Integer): TBGRABitmap;
function FRGetIconSVG(AMode: TFRIconMode; const AHex: string; AStroke: Double): string;

{ Busca no Cache Global para evitar a pesada carga de gerar SVG toda vez.
  Não dê .Free no Bitmap retornado! }
function FRGetCachedIcon(AMode: TFRIconMode; const AHex: string; AStroke: Double; AW, AH: Integer): TBGRABitmap;

{ Limpa todo o cache global de ícones SVG. Deve ser chamado ao trocar o tema
  para que ícones com cores antigas não permaneçam em memória. }
procedure FRClearIconCache;

implementation

uses
  Math, BGRACanvas2D, BGRASVG;

{ ── Helpers internos ── }

function StrokeToStr(AValue: Double): string;
var
  FS: TFormatSettings;
begin
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';
  Result := FormatFloat('0.0', AValue, FS);
end;

{ ── Funções públicas de SVG ── }

function FRColorToSVGHex(AColor: TColor): string;
var
  c: LongInt;
begin
  c := ColorToRGB(AColor);
  Result := Format('#%.2x%.2x%.2x', [c and $FF, (c shr 8) and $FF, (c shr 16) and $FF]);
end;

function FRClearIconSVG(const AHex: string; AStroke: Double = 3.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<line x1="6" y1="6" x2="18" y2="18" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="18" y1="6" x2="6" y2="18" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

function FRSearchIconSVG(const AHex: string; AStroke: Double = 2.5): string;
var
  sw, swHandle: string;
begin
  sw := StrokeToStr(AStroke);
  swHandle := StrokeToStr(AStroke + 0.4);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<circle cx="10" cy="10" r="7" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="15.5" y1="15.5" x2="21" y2="21" stroke="' + AHex + '" stroke-width="' + swHandle + '" stroke-linecap="round"/>' +
    '</svg>';
end;

function FRCalendarIconSVG(const AHex: string; AStroke: Double = 2.5): string;
var
  sw, swPin: string;
begin
  sw := StrokeToStr(AStroke);
  swPin := StrokeToStr(AStroke + 0.4);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<rect x="3" y="4" width="18" height="18" rx="2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="3" y1="10" x2="21" y2="10" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="8" y1="2" x2="8" y2="6" stroke="' + AHex + '" stroke-width="' + swPin + '" stroke-linecap="round"/>' +
    '<line x1="16" y1="2" x2="16" y2="6" stroke="' + AHex + '" stroke-width="' + swPin + '" stroke-linecap="round"/>' +
    '<rect x="7" y="13" width="3" height="3" rx="0.5" fill="' + AHex + '"/>' +
    '</svg>';
end;

function FREyeOpenIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8S1 12 1 12z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<circle cx="12" cy="12" r="3" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '</svg>';
end;

function FREyeClosedIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<line x1="1" y1="1" x2="23" y2="23" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

function FRCopyIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<rect x="9" y="9" width="13" height="13" rx="2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

function FRPlusIconSVG(const AHex: string; AStroke: Double = 2.5): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<line x1="12" y1="5" x2="12" y2="19" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="5" y1="12" x2="19" y2="12" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

function FRMinusIconSVG(const AHex: string; AStroke: Double = 2.5): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<line x1="5" y1="12" x2="19" y2="12" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

function FRHomeIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M3 12l2-2m0 0l7-7 7 7m-14 0v9a1 1 0 0 0 1 1h3m10-10l2 2m-2-2v9a1 1 0 0 1-1 1h-3m-4 0v-5a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v5m-4 0h4" ' +
    'fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

function FRMenuIconSVG(const AHex: string; AStroke: Double = 2.5): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<line x1="3" y1="6" x2="21" y2="6" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="3" y1="12" x2="21" y2="12" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="3" y1="18" x2="21" y2="18" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

function FRArrowBackIconSVG(const AHex: string; AStroke: Double = 2.5): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<line x1="19" y1="12" x2="5" y2="12" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<polyline points="12,19 5,12 12,5" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

function FRArrowForwardIconSVG(const AHex: string; AStroke: Double = 2.5): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<line x1="5" y1="12" x2="19" y2="12" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<polyline points="12,5 19,12 12,19" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

function FRMoreVertIconSVG(const AHex: string; AStroke: Double = 0): string;
var
  r: string;
begin
  if AStroke > 0 then
    r := StrokeToStr(AStroke)
  else
    r := '1.5';
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<circle cx="12" cy="5" r="' + r + '" fill="' + AHex + '"/>' +
    '<circle cx="12" cy="12" r="' + r + '" fill="' + AHex + '"/>' +
    '<circle cx="12" cy="19" r="' + r + '" fill="' + AHex + '"/>' +
    '</svg>';
end;

function FRCheckIconSVG(const AHex: string; AStroke: Double = 2.5): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<polyline points="4,12 9,17 20,6" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

function FREditIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

function FRDeleteIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<polyline points="3,6 5,6 21,6" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

function FRShareIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<circle cx="18" cy="5" r="3" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<circle cx="6" cy="12" r="3" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<circle cx="18" cy="19" r="3" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="8.59" y1="13.51" x2="15.42" y2="17.49" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="15.41" y1="6.51" x2="8.59" y2="10.49" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '</svg>';
end;

function FRStarIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<polygon points="12,2 15.09,8.26 22,9.27 17,14.14 18.18,21.02 12,17.77 5.82,21.02 7,14.14 2,9.27 8.91,8.26" ' +
    'fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '</svg>';
end;

function FRFavoriteIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" ' +
    'fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

function FRSettingsIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<circle cx="12" cy="12" r="3" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 ' +
    '1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15 ' +
    '1.65 1.65 0 0 0 3.13 14H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68 ' +
    '1.65 1.65 0 0 0 10 3.13V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9 ' +
    '1.65 1.65 0 0 0 20.94 10H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

function FRPersonIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<circle cx="12" cy="7" r="4" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '</svg>';
end;

function FRNotificationIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<path d="M13.73 21a2 2 0 0 1-3.46 0" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

function FRMailIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<rect x="2" y="4" width="20" height="16" rx="2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<polyline points="22,6 12,13 2,6" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

function FRDownloadIconSVG(const AHex: string; AStroke: Double = 2.5): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<polyline points="7,10 12,15 17,10" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<line x1="12" y1="15" x2="12" y2="3" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

function FRUploadIconSVG(const AHex: string; AStroke: Double = 2.5): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<polyline points="17,8 12,3 7,8" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<line x1="12" y1="3" x2="12" y2="15" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

function FRRefreshIconSVG(const AHex: string; AStroke: Double = 2.5): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<polyline points="23,4 23,10 17,10" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<polyline points="1,20 1,14 7,14" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

function FRFilterIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<polygon points="22,3 2,3 10,12.46 10,19 14,21 14,12.46" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

function FRAttachIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48" ' +
    'fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

function FRLinkIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

function FRNightlightIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

function FRLightModeIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<circle cx="12" cy="12" r="5" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="12" y1="1" x2="12" y2="3" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="12" y1="21" x2="12" y2="23" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="4.22" y1="4.22" x2="5.64" y2="5.64" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="18.36" y1="18.36" x2="19.78" y2="19.78" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="1" y1="12" x2="3" y2="12" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="21" y1="12" x2="23" y2="12" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="4.22" y1="19.78" x2="5.64" y2="18.36" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="18.36" y1="5.64" x2="19.78" y2="4.22" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

function FRListIconSVG(const AHex: string; AStroke: Double = 2.5): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<line x1="8" y1="6" x2="21" y2="6" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="8" y1="12" x2="21" y2="12" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="8" y1="18" x2="21" y2="18" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<circle cx="3.5" cy="6" r="1.5" fill="' + AHex + '"/>' +
    '<circle cx="3.5" cy="12" r="1.5" fill="' + AHex + '"/>' +
    '<circle cx="3.5" cy="18" r="1.5" fill="' + AHex + '"/>' +
    '</svg>';
end;

function FRDashboardIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var
  sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<rect x="3" y="3" width="7" height="9" rx="1" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<rect x="14" y="3" width="7" height="5" rx="1" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<rect x="14" y="12" width="7" height="9" rx="1" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<rect x="3" y="16" width="7" height="5" rx="1" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '</svg>';
end;

{ expand_more — chevron down }
function FRExpandMoreIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<polyline points="6,9 12,15 18,9" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

{ expand_less — chevron up }
function FRExpandLessIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<polyline points="6,15 12,9 18,15" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

{ folder — closed folder }
function FRFolderIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M2 6a2 2 0 012-2h5l2 2h9a2 2 0 012 2v10a2 2 0 01-2 2H4a2 2 0 01-2-2V6z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '</svg>';
end;

{ folder_open — open folder }
function FRFolderOpenIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M2 6a2 2 0 012-2h5l2 2h9a2 2 0 012 2v2H6l-4 8V6z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<path d="M2 18l4-8h16l-4 8H2z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '</svg>';
end;

{ warning — triangle with exclamation }
function FRWarningIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M12 2L1 21h22L12 2z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<line x1="12" y1="9" x2="12" y2="14" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<circle cx="12" cy="17" r="0.5" fill="' + AHex + '"/>' +
    '</svg>';
end;

{ info — circle with i }
function FRInfoIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<circle cx="12" cy="12" r="10" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="12" y1="11" x2="12" y2="17" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<circle cx="12" cy="8" r="0.5" fill="' + AHex + '"/>' +
    '</svg>';
end;

{ error — circle with X }
function FRErrorIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<circle cx="12" cy="12" r="10" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="9" y1="9" x2="15" y2="15" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="15" y1="9" x2="9" y2="15" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

{ success — circle with checkmark }
function FRSuccessIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<circle cx="12" cy="12" r="10" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<polyline points="8,12.5 11,15.5 16,9" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

{ help — circle with question mark }
function FRHelpIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<circle cx="12" cy="12" r="10" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<path d="M9.5 9a2.5 2.5 0 014.5 1.5c0 1.5-2.5 2-2.5 3.5" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<circle cx="12" cy="17" r="0.5" fill="' + AHex + '"/>' +
    '</svg>';
end;

{ ── Ícones de Sistema Financeiro ── }

{ imMoney — cédula com círculo central (valor) e dois pontos decorativos }
function FRMoneyIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<rect x="2" y="6" width="20" height="12" rx="2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<circle cx="12" cy="12" r="3" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<circle cx="5.5" cy="9" r="1" fill="' + AHex + '"/>' +
    '<circle cx="18.5" cy="15" r="1" fill="' + AHex + '"/>' +
    '</svg>';
end;

{ imCreditCard — cartão com tarja e chip }
function FRCreditCardIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<rect x="1" y="4" width="22" height="16" rx="2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="1" y1="10" x2="23" y2="10" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="6" y1="15" x2="11" y2="15" stroke="' + AHex + '" stroke-width="2.5" stroke-linecap="round"/>' +
    '</svg>';
end;

{ imWallet — carteira com bolso central }
function FRWalletIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M2 7a2 2 0 012-2h16a2 2 0 012 2v10a2 2 0 01-2 2H4a2 2 0 01-2-2V7z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="2" y1="11" x2="22" y2="11" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<path d="M16 14a2 2 0 000 4h5v-4h-5z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '</svg>';
end;

{ imReceipt — nota fiscal com linhas de itens }
function FRReceiptIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw, swl: string;
begin
  sw := StrokeToStr(AStroke);
  swl := StrokeToStr(AStroke - 0.5);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M4 2v20l2-1.5 2 1.5 2-1.5 2 1.5 2-1.5 2 1.5 2-1.5V2l-2 1.5-2-1.5-2 1.5-2-1.5-2 1.5-2-1.5z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<line x1="8" y1="9" x2="16" y2="9" stroke="' + AHex + '" stroke-width="' + swl + '" stroke-linecap="round"/>' +
    '<line x1="8" y1="13" x2="16" y2="13" stroke="' + AHex + '" stroke-width="' + swl + '" stroke-linecap="round"/>' +
    '<line x1="8" y1="17" x2="12" y2="17" stroke="' + AHex + '" stroke-width="' + swl + '" stroke-linecap="round"/>' +
    '</svg>';
end;

{ imBarChart — barras ascendentes com linha de base }
function FRBarChartIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<line x1="2" y1="20" x2="22" y2="20" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<rect x="3" y="13" width="4" height="7" rx="1" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<rect x="10" y="8" width="4" height="12" rx="1" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<rect x="17" y="4" width="4" height="16" rx="1" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '</svg>';
end;

{ imPieChart — gráfico de pizza com fatia destacada }
function FRPieChartIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M21.21 15.89A10 10 0 118.11 2.79" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<path d="M22 12A10 10 0 0012 2v10z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '</svg>';
end;

{ imTrendUp — seta de tendência ascendente }
function FRTrendUpIconSVG(const AHex: string; AStroke: Double = 2.5): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<polyline points="22,7 13.5,15.5 8.5,10.5 2,17" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<polyline points="16,7 22,7 22,13" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

{ imTrendDown — seta de tendência descendente }
function FRTrendDownIconSVG(const AHex: string; AStroke: Double = 2.5): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<polyline points="22,17 13.5,8.5 8.5,13.5 2,7" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<polyline points="16,17 22,17 22,11" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

{ imPercent — dois círculos com linha diagonal }
function FRPercentIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<circle cx="8" cy="8" r="3" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<circle cx="16" cy="16" r="3" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="19" y1="5" x2="5" y2="19" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

{ imBank — prédio com colunas (banco/instituição financeira) }
function FRBankIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw, swb: string;
begin
  sw := StrokeToStr(AStroke);
  swb := StrokeToStr(AStroke + 0.5);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<polygon points="2,12 12,3 22,12" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<line x1="5" y1="12" x2="5" y2="20" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="9" y1="12" x2="9" y2="20" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="15" y1="12" x2="15" y2="20" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="19" y1="12" x2="19" y2="20" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="2" y1="20" x2="22" y2="20" stroke="' + AHex + '" stroke-width="' + swb + '" stroke-linecap="round"/>' +
    '</svg>';
end;

{ imCalculator — calculadora com display e teclas }
function FRCalculatorIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw, swi: string;
begin
  sw := StrokeToStr(AStroke);
  swi := StrokeToStr(1.5);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<rect x="4" y="2" width="16" height="20" rx="2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<rect x="8" y="6" width="8" height="4" rx="1" fill="none" stroke="' + AHex + '" stroke-width="' + swi + '"/>' +
    '<circle cx="8" cy="14" r="1" fill="' + AHex + '"/>' +
    '<circle cx="12" cy="14" r="1" fill="' + AHex + '"/>' +
    '<circle cx="16" cy="14" r="1" fill="' + AHex + '"/>' +
    '<circle cx="8" cy="18" r="1" fill="' + AHex + '"/>' +
    '<circle cx="12" cy="18" r="1" fill="' + AHex + '"/>' +
    '<circle cx="16" cy="18" r="1" fill="' + AHex + '"/>' +
    '</svg>';
end;

{ imCoin — pilha de moedas (elipse + arcos de profundidade) }
function FRCoinIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<ellipse cx="12" cy="8" rx="8" ry="3" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<path d="M4 8v4c0 1.66 3.58 3 8 3s8-1.34 8-3V8" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<path d="M4 12v4c0 1.66 3.58 3 8 3s8-1.34 8-3v-4" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '</svg>';
end;

{ ── Ícones de Estoque / Logística ── }

{ imBox — caixa 3D (pacote) }
function FRBoxIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M21 16V8a2 2 0 00-1-1.73L13 2.27a2 2 0 00-2 0L4 6.27A2 2 0 003 8v8a2 2 0 001 1.73l7 4.04a2 2 0 002 0l7-4.04A2 2 0 0021 16z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<polyline points="3.27,6.96 12,12.01 20.73,6.96" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<line x1="12" y1="22.08" x2="12" y2="12" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

{ imBarcode — código de barras simplificado (barras preenchidas) }
function FRBarcodeIconSVG(const AHex: string): string;
begin
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<rect x="2" y="4" width="2" height="16" fill="' + AHex + '"/>' +
    '<rect x="6" y="4" width="1" height="16" fill="' + AHex + '"/>' +
    '<rect x="9" y="4" width="2" height="16" fill="' + AHex + '"/>' +
    '<rect x="13" y="4" width="1" height="16" fill="' + AHex + '"/>' +
    '<rect x="16" y="4" width="2" height="16" fill="' + AHex + '"/>' +
    '<rect x="20" y="4" width="2" height="16" fill="' + AHex + '"/>' +
    '</svg>';
end;

{ imTruck — caminhão de entrega }
function FRTruckIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<rect x="1" y="4" width="14" height="12" rx="1" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<path d="M15 9h4l3 4v4h-7V9z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<circle cx="5.5" cy="18.5" r="2.5" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<circle cx="18.5" cy="18.5" r="2.5" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="8" y1="16" x2="13" y2="16" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

{ imWarehouse — galpão/armazém com porta dupla }
function FRWarehouseIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M2 20V9l10-6 10 6v11" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<rect x="8" y="13" width="8" height="7" rx="1" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="12" y1="13" x2="12" y2="20" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="2" y1="20" x2="22" y2="20" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

{ imTag — etiqueta de preço }
function FRTagIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M20.59 13.41l-7.17 7.17a2 2 0 01-2.83 0L2 12V2h10l8.59 8.59a2 2 0 010 2.82z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<circle cx="7" cy="7" r="1.5" fill="' + AHex + '"/>' +
    '</svg>';
end;

{ imShoppingCart — carrinho de compras }
function FRShoppingCartIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<circle cx="9" cy="21" r="1.5" fill="' + AHex + '"/>' +
    '<circle cx="20" cy="21" r="1.5" fill="' + AHex + '"/>' +
    '<path d="M1 1h4l2.68 13.39a2 2 0 001.96 1.61h9.72a2 2 0 001.97-1.67L23 6H6" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

{ imScale — balança de fiel (dois pratos) }
function FRScaleIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<line x1="12" y1="3" x2="12" y2="22" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="4" y1="22" x2="20" y2="22" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<path d="M3 7l9-4 9 4" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<path d="M3 7c0 3.31 2.69 6 6 6s6-2.69 6-6" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<path d="M12 7c0 3.31 2.69 6 6 6s6-2.69 6-6" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '</svg>';
end;

{ ── Negócios / ERP ── }

{ imStore — loja (prédio com toldo) }
function FRStoreIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M3 21V10l1.5-7h15L21 10v11" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<line x1="3" y1="10" x2="21" y2="10" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<path d="M9 21v-7h6v7" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '</svg>';
end;

{ imStorefront — vitrine de loja }
function FRStorefrontIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M4 7V4h16v3" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<path d="M2 7h20l-1.5 4H3.5L2 7z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<path d="M4 11v9h16v-9" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<rect x="9" y="14" width="6" height="6" rx="0.5" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '</svg>';
end;

{ imLocalShipping — caminhão de entrega local }
function FRLocalShippingIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<rect x="1" y="4" width="14" height="11" rx="1" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<path d="M15 8h4l3 4v3h-7V8z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<circle cx="6" cy="17.5" r="2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<circle cx="18" cy="17.5" r="2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '</svg>';
end;

{ imRoute — rota com marcadores }
function FRRouteIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<circle cx="6" cy="5" r="3" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<circle cx="18" cy="19" r="3" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<path d="M6 8c0 6 12 4 12 8" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

{ imInventory — inventário (prancheta com caixas) }
function FRInventoryIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<rect x="3" y="2" width="18" height="20" rx="2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="3" y1="8" x2="21" y2="8" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="10" y1="2" x2="10" y2="8" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<rect x="7" y="12" width="4" height="3" rx="0.5" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<rect x="13" y="12" width="4" height="3" rx="0.5" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '</svg>';
end;

{ imCashFlow — fluxo de caixa (setas + dinheiro) }
function FRCashFlowIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<circle cx="12" cy="12" r="3" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="12" y1="10" x2="12" y2="14" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<path d="M2 12h4" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<path d="M4 10l-2 2 2 2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<path d="M18 12h4" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<path d="M20 10l2 2-2 2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<path d="M12 2v4" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<path d="M10 4l2-2 2 2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<path d="M12 18v4" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<path d="M10 20l2 2 2-2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

{ imAccountBalance — balança contábil / balanço }
function FRAccountBalanceIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M12 2L2 7h20L12 2z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<line x1="2" y1="20" x2="22" y2="20" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="5" y1="9" x2="5" y2="18" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="9.5" y1="9" x2="9.5" y2="18" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="14.5" y1="9" x2="14.5" y2="18" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="19" y1="9" x2="19" y2="18" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

{ imTax — tributo/imposto (documento com %) }
function FRTaxIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<path d="M14 2v6h6" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<circle cx="10" cy="12" r="1.2" fill="' + AHex + '"/>' +
    '<circle cx="14" cy="17" r="1.2" fill="' + AHex + '"/>' +
    '<line x1="9" y1="18" x2="15" y2="11" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

{ imInvoice — nota fiscal / fatura }
function FRInvoiceIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M4 2h16v20l-3-2-3 2-3-2-3 2V2z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<line x1="8" y1="7" x2="16" y2="7" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="8" y1="11" x2="16" y2="11" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="8" y1="15" x2="12" y2="15" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

{ imHandshake — aperto de mão (negociação) }
function FRHandshakeIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M2 11l4-4 4 2 4-4 4 2 4-2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<path d="M6 13l3 3 3-1 3 3" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<path d="M18 9l-3 3-3-1-3 3" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

{ imFactory — fábrica / indústria }
function FRFactoryIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M2 21V11l5-4v5l5-4v5l5-4v12H2z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<rect x="18" y="3" width="4" height="18" rx="0.5" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="20" y1="3" x2="20" y2="1" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

{ imQrCode — código QR }
function FRQrCodeIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<rect x="2" y="2" width="8" height="8" rx="1" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<rect x="4.5" y="4.5" width="3" height="3" fill="' + AHex + '"/>' +
    '<rect x="14" y="2" width="8" height="8" rx="1" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<rect x="16.5" y="4.5" width="3" height="3" fill="' + AHex + '"/>' +
    '<rect x="2" y="14" width="8" height="8" rx="1" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<rect x="4.5" y="16.5" width="3" height="3" fill="' + AHex + '"/>' +
    '<rect x="14" y="14" width="3" height="3" fill="' + AHex + '"/>' +
    '<rect x="19" y="14" width="3" height="3" fill="' + AHex + '"/>' +
    '<rect x="14" y="19" width="3" height="3" fill="' + AHex + '"/>' +
    '<rect x="19" y="19" width="3" height="3" fill="' + AHex + '"/>' +
    '</svg>';
end;

{ imPrinter — impressora }
function FRPrinterIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M6 9V2h12v7" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<rect x="2" y="9" width="20" height="8" rx="2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<path d="M6 17v5h12v-5" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '</svg>';
end;

{ imClipboard — prancheta }
function FRClipboardIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<rect x="8" y="2" width="8" height="4" rx="1" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<rect x="4" y="4" width="16" height="18" rx="2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<line x1="8" y1="12" x2="16" y2="12" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="8" y1="16" x2="14" y2="16" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

{ imAssignment — tarefa/designação (prancheta com check) }
function FRAssignmentIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<rect x="8" y="2" width="8" height="4" rx="1" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<rect x="4" y="4" width="16" height="18" rx="2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<path d="M9 13l2 2 4-4" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

{ imReport — relatório / gráfico com barras }
function FRReportIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<rect x="3" y="3" width="18" height="18" rx="2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '"/>' +
    '<rect x="7" y="13" width="2" height="5" rx="0.3" fill="' + AHex + '"/>' +
    '<rect x="11" y="9" width="2" height="9" rx="0.3" fill="' + AHex + '"/>' +
    '<rect x="15" y="6" width="2" height="12" rx="0.3" fill="' + AHex + '"/>' +
    '</svg>';
end;

{ imFile — arquivo / documento }
function FRFileIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8l-6-6z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<path d="M14 2v6h6" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<line x1="8" y1="13" x2="16" y2="13" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="8" y1="17" x2="14" y2="17" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

{ imKpi — KPI / indicador (velocímetro) }
function FRKpiIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M4 18a8 8 0 1116 0" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<line x1="12" y1="18" x2="15" y2="10" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '<circle cx="12" cy="18" r="1.5" fill="' + AHex + '"/>' +
    '<line x1="7" y1="18" x2="17" y2="18" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
    '</svg>';
end;

function FRLockIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<rect x="3" y="11" width="18" height="11" rx="2" ry="2" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<path d="M7 11V7a5 5 0 0110 0v4" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<circle cx="12" cy="16" r="1.5" fill="' + AHex + '"/>' +
    '</svg>';
end;

function FRShieldIconSVG(const AHex: string; AStroke: Double = 2.0): string;
var sw: string;
begin
  sw := StrokeToStr(AStroke);
  Result :=
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linejoin="round"/>' +
    '<polyline points="9 12 11 14 15 10" fill="none" stroke="' + AHex + '" stroke-width="' + sw + '" stroke-linecap="round" stroke-linejoin="round"/>' +
    '</svg>';
end;

{ Uses AStroke if > 0, otherwise falls back to ADefault.
  Avoids the repetitive 'if AStroke > 0 then ... else ...' pattern. }
function UseStroke(AStroke, ADefault: Double): Double; inline;
begin
  if AStroke > 0 then Result := AStroke else Result := ADefault;
end;

function FRGetIconSVG(AMode: TFRIconMode; const AHex: string; AStroke: Double): string;
begin
  case AMode of
    imClear:        Result := FRClearIconSVG(AHex,         UseStroke(AStroke, 3.0));
    imSearch:       Result := FRSearchIconSVG(AHex,        UseStroke(AStroke, 2.5));
    imCalendar:     Result := FRCalendarIconSVG(AHex,      UseStroke(AStroke, 2.5));
    imEyeOpen:      Result := FREyeOpenIconSVG(AHex,       UseStroke(AStroke, 2.0));
    imEyeClosed:    Result := FREyeClosedIconSVG(AHex,     UseStroke(AStroke, 2.0));
    imCopy:         Result := FRCopyIconSVG(AHex,          UseStroke(AStroke, 2.0));
    imPlus:         Result := FRPlusIconSVG(AHex,          UseStroke(AStroke, 2.5));
    imMinus:        Result := FRMinusIconSVG(AHex,         UseStroke(AStroke, 2.5));
    imHome:         Result := FRHomeIconSVG(AHex,          UseStroke(AStroke, 2.0));
    imMenu:         Result := FRMenuIconSVG(AHex,          UseStroke(AStroke, 2.5));
    imArrowBack:    Result := FRArrowBackIconSVG(AHex,     UseStroke(AStroke, 2.5));
    imArrowForward: Result := FRArrowForwardIconSVG(AHex,  UseStroke(AStroke, 2.5));
    imMoreVert:     Result := FRMoreVertIconSVG(AHex,      AStroke);  { 0 = default radius }
    imCheck:        Result := FRCheckIconSVG(AHex,         UseStroke(AStroke, 2.5));
    imEdit:         Result := FREditIconSVG(AHex,          UseStroke(AStroke, 2.0));
    imDelete:       Result := FRDeleteIconSVG(AHex,        UseStroke(AStroke, 2.0));
    imShare:        Result := FRShareIconSVG(AHex,         UseStroke(AStroke, 2.0));
    imStar:         Result := FRStarIconSVG(AHex,          UseStroke(AStroke, 2.0));
    imFavorite:     Result := FRFavoriteIconSVG(AHex,      UseStroke(AStroke, 2.0));
    imSettings:     Result := FRSettingsIconSVG(AHex,      UseStroke(AStroke, 2.0));
    imPerson:       Result := FRPersonIconSVG(AHex,        UseStroke(AStroke, 2.0));
    imNotification: Result := FRNotificationIconSVG(AHex,  UseStroke(AStroke, 2.0));
    imMail:         Result := FRMailIconSVG(AHex,          UseStroke(AStroke, 2.0));
    imDownload:     Result := FRDownloadIconSVG(AHex,      UseStroke(AStroke, 2.5));
    imUpload:       Result := FRUploadIconSVG(AHex,        UseStroke(AStroke, 2.5));
    imRefresh:      Result := FRRefreshIconSVG(AHex,       UseStroke(AStroke, 2.5));
    imFilter:       Result := FRFilterIconSVG(AHex,        UseStroke(AStroke, 2.0));
    imAttach:       Result := FRAttachIconSVG(AHex,        UseStroke(AStroke, 2.0));
    imLink:         Result := FRLinkIconSVG(AHex,          UseStroke(AStroke, 2.0));
    imNightlight:   Result := FRNightlightIconSVG(AHex,    UseStroke(AStroke, 2.0));
    imLightMode:    Result := FRLightModeIconSVG(AHex,     UseStroke(AStroke, 2.0));
    imList:         Result := FRListIconSVG(AHex,          UseStroke(AStroke, 2.5));
    imDashboard:    Result := FRDashboardIconSVG(AHex,     UseStroke(AStroke, 2.0));
    imExpandMore:   Result := FRExpandMoreIconSVG(AHex,    UseStroke(AStroke, 2.0));
    imExpandLess:   Result := FRExpandLessIconSVG(AHex,    UseStroke(AStroke, 2.0));
    imFolder:       Result := FRFolderIconSVG(AHex,        UseStroke(AStroke, 2.0));
    imFolderOpen:   Result := FRFolderOpenIconSVG(AHex,    UseStroke(AStroke, 2.0));
    imWarning:      Result := FRWarningIconSVG(AHex,       UseStroke(AStroke, 2.0));
    imInfo:         Result := FRInfoIconSVG(AHex,          UseStroke(AStroke, 2.0));
    imError:        Result := FRErrorIconSVG(AHex,         UseStroke(AStroke, 2.0));
    imSuccess:      Result := FRSuccessIconSVG(AHex,       UseStroke(AStroke, 2.0));
    imHelp:         Result := FRHelpIconSVG(AHex,          UseStroke(AStroke, 2.0));
    imLock:         Result := FRLockIconSVG(AHex,          UseStroke(AStroke, 2.0));
    imShield:       Result := FRShieldIconSVG(AHex,        UseStroke(AStroke, 2.0));
    { Financeiro }
    imMoney:        Result := FRMoneyIconSVG(AHex,         UseStroke(AStroke, 2.0));
    imCreditCard:   Result := FRCreditCardIconSVG(AHex,    UseStroke(AStroke, 2.0));
    imWallet:       Result := FRWalletIconSVG(AHex,        UseStroke(AStroke, 2.0));
    imReceipt:      Result := FRReceiptIconSVG(AHex,       UseStroke(AStroke, 2.0));
    imBarChart:     Result := FRBarChartIconSVG(AHex,      UseStroke(AStroke, 2.0));
    imPieChart:     Result := FRPieChartIconSVG(AHex,      UseStroke(AStroke, 2.0));
    imTrendUp:      Result := FRTrendUpIconSVG(AHex,       UseStroke(AStroke, 2.5));
    imTrendDown:    Result := FRTrendDownIconSVG(AHex,     UseStroke(AStroke, 2.5));
    imPercent:      Result := FRPercentIconSVG(AHex,       UseStroke(AStroke, 2.0));
    imBank:         Result := FRBankIconSVG(AHex,          UseStroke(AStroke, 2.0));
    imCalculator:   Result := FRCalculatorIconSVG(AHex,    UseStroke(AStroke, 2.0));
    imCoin:         Result := FRCoinIconSVG(AHex,          UseStroke(AStroke, 2.0));
    { Estoque / Logística }
    imBox:          Result := FRBoxIconSVG(AHex,           UseStroke(AStroke, 2.0));
    imBarcode:      Result := FRBarcodeIconSVG(AHex);
    imTruck:        Result := FRTruckIconSVG(AHex,         UseStroke(AStroke, 2.0));
    imWarehouse:    Result := FRWarehouseIconSVG(AHex,     UseStroke(AStroke, 2.0));
    imTag:          Result := FRTagIconSVG(AHex,           UseStroke(AStroke, 2.0));
    imShoppingCart: Result := FRShoppingCartIconSVG(AHex,  UseStroke(AStroke, 2.0));
    imScale:        Result := FRScaleIconSVG(AHex,         UseStroke(AStroke, 2.0));
    { Negócios / ERP }
    imStore:         Result := FRStoreIconSVG(AHex,          UseStroke(AStroke, 2.0));
    imStorefront:    Result := FRStorefrontIconSVG(AHex,     UseStroke(AStroke, 2.0));
    imLocalShipping: Result := FRLocalShippingIconSVG(AHex,  UseStroke(AStroke, 2.0));
    imRoute:         Result := FRRouteIconSVG(AHex,          UseStroke(AStroke, 2.0));
    imInventory:     Result := FRInventoryIconSVG(AHex,      UseStroke(AStroke, 2.0));
    imCashFlow:      Result := FRCashFlowIconSVG(AHex,       UseStroke(AStroke, 2.0));
    imAccountBalance:Result := FRAccountBalanceIconSVG(AHex, UseStroke(AStroke, 2.0));
    imTax:           Result := FRTaxIconSVG(AHex,            UseStroke(AStroke, 2.0));
    imInvoice:       Result := FRInvoiceIconSVG(AHex,        UseStroke(AStroke, 2.0));
    imHandshake:     Result := FRHandshakeIconSVG(AHex,      UseStroke(AStroke, 2.0));
    imFactory:       Result := FRFactoryIconSVG(AHex,        UseStroke(AStroke, 2.0));
    imQrCode:        Result := FRQrCodeIconSVG(AHex,         UseStroke(AStroke, 2.0));
    imPrinter:       Result := FRPrinterIconSVG(AHex,        UseStroke(AStroke, 2.0));
    imClipboard:     Result := FRClipboardIconSVG(AHex,      UseStroke(AStroke, 2.0));
    imAssignment:    Result := FRAssignmentIconSVG(AHex,     UseStroke(AStroke, 2.0));
    imReport:        Result := FRReportIconSVG(AHex,         UseStroke(AStroke, 2.0));
    imFile:          Result := FRFileIconSVG(AHex,           UseStroke(AStroke, 2.0));
    imKpi:           Result := FRKpiIconSVG(AHex,            UseStroke(AStroke, 2.0));
  else
    Result := '';
  end;
end;

function FRRenderSVGIcon(const ASVG: string; AW, AH: Integer): TBGRABitmap;
var
  svg: TBGRASVG;
  ctx: TBGRACanvas2D;
  iconSize, margin, offX, offY: Integer;
begin
  Result := TBGRABitmap.Create(AW, AH, BGRAPixelTransparent);
  try
    iconSize := Min(AW, AH);
    margin := iconSize div 8;
    offX := (AW - iconSize) div 2;
    offY := (AH - iconSize) div 2;
    svg := TBGRASVG.CreateFromString(ASVG);
    try
      ctx := TBGRACanvas2D.Create(Result);
      try
        svg.StretchDraw(ctx, offX + margin, offY + margin,
          iconSize - 2 * margin, iconSize - 2 * margin);
      finally
        ctx.Free;
      end;
    finally
      svg.Free;
    end;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

{ ══════════════════════════════════════════════════════════════════════════ }
{  TFRMDGlobalIconCache                                                    }
{ ══════════════════════════════════════════════════════════════════════════ }

type
  TFRMDSVGCacheDict = specialize TObjectDictionary<string, TBGRABitmap>;

  TFRMDGlobalIconCache = class
  private
    FDict: TFRMDSVGCacheDict;
  public
    constructor Create;
    destructor Destroy; override;
    function GetIcon(AMode: TFRIconMode; const AHex: string; AStroke: Double; AW, AH: Integer): TBGRABitmap;
  end;

var
  FRGlobalIconCache: TFRMDGlobalIconCache = nil;

constructor TFRMDGlobalIconCache.Create;
begin
  inherited Create;
  { Configurado para donar a propriedade e dar Free aos objetos TBGRABitmap ao Destruir/Remover }
  FDict := TFRMDSVGCacheDict.Create([doOwnsValues]);
end;

destructor TFRMDGlobalIconCache.Destroy;
begin
  FDict.Free;
  inherited Destroy;
end;

function TFRMDGlobalIconCache.GetIcon(AMode: TFRIconMode; const AHex: string; AStroke: Double; AW, AH: Integer): TBGRABitmap;
var
  svg, k: string;
  bmp: TBGRABitmap;
begin
  { Remove the check for imClear to allow caching }
  
  { Cria a Hash identificadora única da imagem }
  k := Format('%d_%s_%f_%d_%d', [Ord(AMode), AHex, AStroke, AW, AH]);
  if FDict.TryGetValue(k, bmp) then
    Exit(bmp);

  { Se não encontrou, renderiza do zero e faz cache }
  svg := FRGetIconSVG(AMode, AHex, AStroke);
  if svg = '' then Exit(nil);

  bmp := FRRenderSVGIcon(svg, AW, AH);
  if bmp <> nil then
    FDict.Add(k, bmp);

  Result := bmp;
end;

function FRGetCachedIcon(AMode: TFRIconMode; const AHex: string; AStroke: Double; AW, AH: Integer): TBGRABitmap;
begin
  if FRGlobalIconCache = nil then
    FRGlobalIconCache := TFRMDGlobalIconCache.Create;
  Result := FRGlobalIconCache.GetIcon(AMode, AHex, AStroke, AW, AH);
end;

procedure FRClearIconCache;
begin
  if Assigned(FRGlobalIconCache) then
    FreeAndNil(FRGlobalIconCache);
end;

{ ══════════════════════════════════════════════════════════════════════════ }
{  TFRMaterialIconButton                                                   }
{ ══════════════════════════════════════════════════════════════════════════ }

constructor TFRMaterialIconButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHovered      := False;
  FIconMode     := imClear;
  FNormalColor  := clGray;
  FHoverColor   := clHighlight;
  FStrokeWidth  := 0;
  FCacheNormal  := nil;
  FCacheHover   := nil;
  FCacheMode    := imClear;
  FCacheW       := 0;
  FCacheH       := 0;
  Flat := True;
end;

destructor TFRMaterialIconButton.Destroy;
begin
  FCacheNormal := nil;
  FCacheHover  := nil;
  inherited Destroy;
end;

procedure TFRMaterialIconButton.InvalidateCache;
begin
  FCacheW := 0;
  FCacheH := 0;
  Invalidate;
end;

procedure TFRMaterialIconButton.SetIconMode(AValue: TFRIconMode);
begin
  if FIconMode <> AValue then
  begin
    FIconMode := AValue;
    Invalidate;
  end;
end;

procedure TFRMaterialIconButton.RebuildCache;
var
  hexNormal, hexHover: string;
  sw: Double;
begin
  FCacheNormal := nil;
  FCacheHover  := nil;
  if (Width <= 0) or (Height <= 0) then Exit;

  hexNormal := FRColorToSVGHex(FNormalColor);
  hexHover  := FRColorToSVGHex(FHoverColor);
  sw := FStrokeWidth;

  FCacheNormal := FRGetCachedIcon(FIconMode, hexNormal, sw, Width, Height);
  FCacheHover  := FRGetCachedIcon(FIconMode, hexHover, sw, Width, Height);

  FCacheMode := FIconMode;
  FCacheW := Width;
  FCacheH := Height;
end;

procedure TFRMaterialIconButton.Paint;
var
  bmp: TBGRABitmap;
begin
  { Não preenche fundo — o parent (TFRMaterialEditBase) já pintou a região }

  if (FCacheW <> Width) or (FCacheH <> Height) or (FCacheMode <> FIconMode) then
    RebuildCache;

  if FHovered then
    bmp := FCacheHover
  else
    bmp := FCacheNormal;

  if Assigned(bmp) then
    bmp.Draw(Canvas, 0, 0, False);
end;

procedure TFRMaterialIconButton.MouseEnter;
begin
  FHovered := True;
  Invalidate;
  inherited MouseEnter;
end;

procedure TFRMaterialIconButton.MouseLeave;
begin
  FHovered := False;
  Invalidate;
  inherited MouseLeave;
end;

initialization
  FRGlobalIconCache := nil;

finalization
  if Assigned(FRGlobalIconCache) then
    FRGlobalIconCache.Free;

end.

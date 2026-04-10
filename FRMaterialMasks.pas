unit FRMaterialMasks;

{$mode objfpc}{$H+}

{ FRMaterialMasks
  Sistema de máscaras e validações PT-BR para componentes Material Design.

  Tipos de máscara (TFRTextMaskType):
    tmtNone       — sem máscara
    tmtCpfCnpj    — CPF (11 dígitos) / CNPJ (14 dígitos), autodetecção
    tmtCep        — CEP (8 dígitos)
    tmtChaveNFe   — Chave NF-e (44 dígitos)
    tmtBoleto     — Código de barras de boleto (47 dígitos)
    tmtTelefone   — Telefone (10–13 dígitos: fixo, celular, DDI)

  Estado de validação (TFRValidationState):
    vsNone        — campo vazio ou sem validação aplicável
    vsValid       — valor preenchido e válido
    vsInvalid     — valor preenchido e inválido

  Funções públicas:
    FRRemoveNonDigits    — remove tudo exceto 0-9
    FRApplyMaskPattern   — aplica máscara sobre texto puro
    FRMaskForDigits      — retorna a máscara adequada para o número de dígitos
    FRMaxLenForMask      — retorna MaxLength formatado para o tipo de máscara
    FRValidateMask       — valida o conteúdo e retorna TFRValidationState
    FRValidateCPF        — valida dígitos verificadores do CPF
    FRValidateCNPJ       — valida dígitos verificadores do CNPJ

  Licença: LGPL v3 — mesma do bgracontrols
}

interface

uses
  SysUtils, Math;

type
  TFRTextMaskType = (tmtNone, tmtCpfCnpj, tmtCep, tmtChaveNFe, tmtBoleto, tmtTelefone);

  TFRValidationState = (vsNone, vsValid, vsInvalid);

  { Filtro de entrada — restringe caracteres permitidos }
  TFRInputFilter = (ifNone, ifDigitsOnly, ifAlphaOnly, ifAlphaNumeric, ifCustom);

  { Máscara numérica — formatação automática de valores numéricos }
  TFRNumericMaskType = (nmtNone, nmtMoney, nmtWeight, nmtQuantity, nmtFloat2, nmtFloat4);

  { Modo de validação — quando executar a validação }
  TFRValidateMode = (vmOnExit, vmOnChange);

  { Evento de validação personalizada }
  TFRValidateEvent = procedure(Sender: TObject; const AText: string;
    var AState: TFRValidationState) of object;

const
  FR_MASK_CPF               = '000.000.000-00';
  FR_MASK_CNPJ              = '00.000.000/0000-00';
  FR_MASK_CEP               = '00000-000';
  FR_MASK_CHAVE_NFE         = '0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000';
  FR_MASK_BOLETO            = '00000.00000 00000.000000 00000.000000 0 00000000000000';
  FR_MASK_TELEFONE_FIXO     = '(00) 0000-0000';
  FR_MASK_TELEFONE_CEL      = '(00) 00000-0000';
  FR_MASK_TELEFONE_DDI_FIXO = '+00 (00) 0000-0000';
  FR_MASK_TELEFONE_DDI_CEL  = '+00 (00) 00000-0000';

  FR_MAXLEN_CPF_CNPJ  = 18;   { tamanho formatado do CNPJ }
  FR_MAXLEN_CEP       = 9;
  FR_MAXLEN_CHAVE_NFE = 54;
  FR_MAXLEN_BOLETO    = 54;
  FR_MAXLEN_TELEFONE  = 19;

{ Remove todos os caracteres que não são dígitos (0-9) }
function FRRemoveNonDigits(const AText: string): string;

{ Aplica a máscara sobre o texto puro (somente dígitos).
  '0' na máscara = dígito; qualquer outro caractere = literal.
  Retorna o texto formatado e posiciona o cursor no final. }
function FRApplyMaskPattern(const ADigits, AMask: string): string;

{ Retorna a máscara adequada para o tipo e número de dígitos.
  Resultado vazio = nenhuma máscara aplicável neste momento. }
function FRMaskForDigits(AMaskType: TFRTextMaskType; ADigitCount: Integer): string;

{ Retorna o MaxLength (texto formatado) para o tipo de máscara }
function FRMaxLenForMask(AMaskType: TFRTextMaskType): Integer;

{ Valida o conteúdo conforme o tipo de máscara.
  Retorna vsNone se vazio, vsValid se OK, vsInvalid se inválido. }
function FRValidateMask(AMaskType: TFRTextMaskType; const AText: string): TFRValidationState;

{ Valida CPF (11 dígitos puros, sem pontuação) — dígitos verificadores }
function FRValidateCPF(const ADigits: string): Boolean;

{ Valida CNPJ (14 dígitos puros, sem pontuação) — dígitos verificadores }
function FRValidateCNPJ(const ADigits: string): Boolean;

{ Formata um valor Currency de acordo com a máscara numérica.
  nmtMoney     → R$ 1.234,56
  nmtWeight    → 1.234,567
  nmtQuantity  → 1.234,56
  nmtFloat2    → 1.234,56
  nmtFloat4    → 1.234,5678 }
function FRFormatNumeric(AMaskType: TFRNumericMaskType; AValue: Currency): string;

{ Converte texto formatado PT-BR de volta para Currency.
  Remove tudo exceto dígitos, vírgula e sinal negativo. }
function FRParseNumericText(const AText: string): Currency;

{ Retorna o número de casas decimais para a máscara numérica }
function FRNumericDecimals(AMaskType: TFRNumericMaskType): Integer;

{ Verifica se um caractere é permitido pelo filtro de entrada }
function FRIsCharAllowed(AFilter: TFRInputFilter; AChar: Char): Boolean;

implementation

{ ══════════════════════════════════════════════════════════════════════════ }
{  Utilitários                                                              }
{ ══════════════════════════════════════════════════════════════════════════ }

function FRRemoveNonDigits(const AText: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(AText) do
    if AText[i] in ['0'..'9'] then
      Result := Result + AText[i];
end;

function FRApplyMaskPattern(const ADigits, AMask: string): string;
var
  i, j: Integer;
begin
  Result := '';
  j := 1;
  for i := 1 to Length(AMask) do
  begin
    if AMask[i] = '0' then
    begin
      if j <= Length(ADigits) then
      begin
        Result := Result + ADigits[j];
        Inc(j);
      end
      else
        Break;
    end
    else
    begin
      if j <= Length(ADigits) then
        Result := Result + AMask[i]
      else
        Break;
    end;
  end;
end;

function FRMaskForDigits(AMaskType: TFRTextMaskType; ADigitCount: Integer): string;
begin
  Result := '';
  case AMaskType of
    tmtCpfCnpj:
      if ADigitCount = 11 then
        Result := FR_MASK_CPF
      else if ADigitCount = 14 then
        Result := FR_MASK_CNPJ;
    tmtCep:
      if ADigitCount = 8 then
        Result := FR_MASK_CEP;
    tmtChaveNFe:
      if (ADigitCount > 0) and (ADigitCount <= 44) then
        Result := FR_MASK_CHAVE_NFE;
    tmtBoleto:
      if (ADigitCount > 0) and (ADigitCount <= 47) then
        Result := FR_MASK_BOLETO;
    tmtTelefone:
      if ADigitCount = 10 then
        Result := FR_MASK_TELEFONE_FIXO
      else if ADigitCount = 11 then
        Result := FR_MASK_TELEFONE_CEL
      else if ADigitCount = 12 then
        Result := FR_MASK_TELEFONE_DDI_FIXO
      else if ADigitCount = 13 then
        Result := FR_MASK_TELEFONE_DDI_CEL;
  end;
end;

function FRMaxLenForMask(AMaskType: TFRTextMaskType): Integer;
begin
  case AMaskType of
    tmtCpfCnpj:  Result := FR_MAXLEN_CPF_CNPJ;
    tmtCep:      Result := FR_MAXLEN_CEP;
    tmtChaveNFe: Result := FR_MAXLEN_CHAVE_NFE;
    tmtBoleto:   Result := FR_MAXLEN_BOLETO;
    tmtTelefone: Result := FR_MAXLEN_TELEFONE;
  else
    Result := 0;
  end;
end;

{ ══════════════════════════════════════════════════════════════════════════ }
{  Validação de CPF                                                         }
{ ══════════════════════════════════════════════════════════════════════════ }

function FRValidateCPF(const ADigits: string): Boolean;
const
  InvalidCPF: array[0..9] of string = (
    '00000000000', '11111111111', '22222222222', '33333333333', '44444444444',
    '55555555555', '66666666666', '77777777777', '88888888888', '99999999999'
  );
var
  i, d1, d2, s1, s2: Integer;
  D: string;
begin
  D := FRRemoveNonDigits(ADigits);
  if Length(D) <> 11 then
    Exit(False);

  for i := 0 to High(InvalidCPF) do
    if D = InvalidCPF[i] then
      Exit(False);

  s1 := 0;
  s2 := 0;
  for i := 1 to 9 do
  begin
    s1 := s1 + StrToInt(D[i]) * (11 - i);
    s2 := s2 + StrToInt(D[i]) * (12 - i);
  end;

  d1 := (s1 * 10) mod 11;
  if d1 = 10 then d1 := 0;

  s2 := s2 + d1 * 2;
  d2 := (s2 * 10) mod 11;
  if d2 = 10 then d2 := 0;

  Result := (d1 = StrToInt(D[10])) and (d2 = StrToInt(D[11]));
end;

{ ══════════════════════════════════════════════════════════════════════════ }
{  Validação de CNPJ                                                        }
{ ══════════════════════════════════════════════════════════════════════════ }

function FRValidateCNPJ(const ADigits: string): Boolean;
const
  InvalidCNPJ: array[0..9] of string = (
    '00000000000000', '11111111111111', '22222222222222', '33333333333333',
    '44444444444444', '55555555555555', '66666666666666', '77777777777777',
    '88888888888888', '99999999999999'
  );
  Peso1: array[1..12] of Integer = (5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2);
  Peso2: array[1..13] of Integer = (6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2);
var
  i, Soma, Digito: Integer;
  D: string;
begin
  D := FRRemoveNonDigits(ADigits);
  if Length(D) <> 14 then
    Exit(False);

  for i := 0 to High(InvalidCNPJ) do
    if D = InvalidCNPJ[i] then
      Exit(False);

  Soma := 0;
  for i := 1 to 12 do
    Soma := Soma + StrToInt(D[i]) * Peso1[i];
  Digito := 11 - (Soma mod 11);
  if Digito >= 10 then Digito := 0;
  if Digito <> StrToInt(D[13]) then
    Exit(False);

  Soma := 0;
  for i := 1 to 13 do
    Soma := Soma + StrToInt(D[i]) * Peso2[i];
  Digito := 11 - (Soma mod 11);
  if Digito >= 10 then Digito := 0;
  if Digito <> StrToInt(D[14]) then
    Exit(False);

  Result := True;
end;

{ ══════════════════════════════════════════════════════════════════════════ }
{  Validação por tipo de máscara                                            }
{ ══════════════════════════════════════════════════════════════════════════ }

function FRValidateMask(AMaskType: TFRTextMaskType; const AText: string): TFRValidationState;
var
  D: string;
  Len: Integer;
begin
  D   := FRRemoveNonDigits(AText);
  Len := Length(D);

  if Len = 0 then
    Exit(vsNone);

  case AMaskType of
    tmtCpfCnpj:
    begin
      if Len <= 11 then
      begin
        if Len < 11 then Exit(vsNone);   { ainda digitando }
        if FRValidateCPF(D) then Exit(vsValid) else Exit(vsInvalid);
      end
      else
      begin
        if Len < 14 then Exit(vsNone);
        if FRValidateCNPJ(D) then Exit(vsValid) else Exit(vsInvalid);
      end;
    end;
    tmtCep:
    begin
      if Len < 8 then Exit(vsNone);
      if Len = 8 then Exit(vsValid) else Exit(vsInvalid);
    end;
    tmtChaveNFe:
    begin
      if Len < 44 then Exit(vsNone);
      if Len = 44 then Exit(vsValid) else Exit(vsInvalid);
    end;
    tmtBoleto:
    begin
      if Len < 47 then Exit(vsNone);
      if Len = 47 then Exit(vsValid) else Exit(vsInvalid);
    end;
    tmtTelefone:
    begin
      if Len < 10 then Exit(vsNone);
      if Len in [10, 11, 12, 13] then Exit(vsValid) else Exit(vsInvalid);
    end;
  else
    Result := vsNone;
  end;
end;

{ ══════════════════════════════════════════════════════════════════════════ }
{  Formatação numérica PT-BR                                                }
{ ══════════════════════════════════════════════════════════════════════════ }

function FRNumericDecimals(AMaskType: TFRNumericMaskType): Integer;
begin
  case AMaskType of
    nmtMoney:    Result := 2;
    nmtWeight:   Result := 3;
    nmtQuantity: Result := 2;
    nmtFloat2:   Result := 2;
    nmtFloat4:   Result := 4;
  else
    Result := 0;
  end;
end;

function FRFormatNumeric(AMaskType: TFRNumericMaskType; AValue: Currency): string;
var
  FS: TFormatSettings;
  Decimals: Integer;
  FmtStr: string;
begin
  FS := DefaultFormatSettings;
  FS.DecimalSeparator  := ',';
  FS.ThousandSeparator := '.';

  Decimals := FRNumericDecimals(AMaskType);
  FmtStr := '#,##0.' + StringOfChar('0', Max(Decimals, 1));
  Result := FormatFloat(FmtStr, AValue, FS);

  if AMaskType = nmtMoney then
    Result := 'R$ ' + Result;
end;

function FRParseNumericText(const AText: string): Currency;
var
  Clean: string;
  i: Integer;
  FS: TFormatSettings;
begin
  Clean := '';
  for i := 1 to Length(AText) do
  begin
    if AText[i] in ['0'..'9', ',', '-'] then
      Clean := Clean + AText[i];
  end;

  if Clean = '' then
    Exit(0);

  FS := DefaultFormatSettings;
  FS.DecimalSeparator := ',';
  FS.ThousandSeparator := '.';

  if not TryStrToCurr(Clean, Result, FS) then
    Result := 0;
end;

{ ══════════════════════════════════════════════════════════════════════════ }
{  Filtro de entrada                                                        }
{ ══════════════════════════════════════════════════════════════════════════ }

function FRIsCharAllowed(AFilter: TFRInputFilter; AChar: Char): Boolean;
begin
  case AFilter of
    ifNone:
      Result := True;
    ifDigitsOnly:
      Result := AChar in ['0'..'9', #8];
    ifAlphaOnly:
      Result := AChar in ['a'..'z', 'A'..'Z', ' ', #8];
    ifAlphaNumeric:
      Result := AChar in ['a'..'z', 'A'..'Z', '0'..'9', ' ', #8];
    ifCustom:
      Result := True; { componente trata via AllowedChars }
  else
    Result := True;
  end;
end;

end.

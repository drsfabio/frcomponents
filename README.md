# Componentes Material Design para Lazarus

Componentes de entrada com estilo Material Design para Lazarus / Free Pascal, integrados ao pacote [BGRAControls](https://github.com/bgrabitmap/bgracontrols). Licenciado sob **LGPL v3**.

## Visão geral

Este pacote fornece quatro controles de entrada no estilo Material Design que encapsulam widgets padrão da LCL, adicionando:

- **Label flutuante** — o rótulo sobe acima do campo ao receber foco ou quando preenchido
- **Sublinhado Material** — linha fina em repouso, linha dupla colorida com foco
- **AccentColor** — cor personalizável usada no sublinhado e no label com foco
- **Variant** — três estilos visuais: `mvStandard`, `mvFilled`, `mvOutlined`
- **BorderRadius** — cantos arredondados configuráveis
- **API consistente** — todos os controles seguem as mesmas convenções visuais

| Componente | Encapsula | Uso |
|---|---|---|
| `TFRMaterialEdit` | `TEdit` | Campo de texto simples |
| `TFRMaterialMaskEdit` | `TMaskEdit` | Campo com máscara (CPF, CNPJ, telefone, CEP…) |
| `TFRMaterialCurrencyEdit` | `TEdit` (gerenciado) | Campo monetário com formatação automática |
| `TFRMaterialComboEdit` | `TComboBox` | Lista suspensa / combo editável |
| `TFRMaterialCheckComboEdit` | `TCheckListBox` (popup) | Seleção múltipla com checkboxes |
| `TFRMaterialDateEdit` | `TDateEdit` | Seletor de data com calendário popup |

---

## Coexistência com BGRAControls

Este pacote é um **fork** das units Material Design originalmente incluídas no [BGRAControls](https://github.com/bgrabitmap/bgracontrols). As unidades originais usam o prefixo `BCMaterial*`; este pacote usa o prefixo `FRMaterial*` justamente para eliminar qualquer conflito.

Você pode instalar este pacote **ao mesmo tempo** que o BGRAControls sem nenhum conflito de nomes de unit.

> **Migração do BCMaterial original (BGRAControls):** As classes foram renomeadas de `TBCMaterial*` para `TFRMaterial*`. Ao migrar, use Localizar/Substituir global no seu projeto: substitua `TBCMaterial` por `TFRMaterial` e atualize as cláusulas `uses` (`BCMaterialEdit` → `FRMaterialEdit`, `BCMaterialComboEdit` → `FRMaterialComboEdit`, etc.).

---

## Instalação no Lazarus IDE

### Pré-requisitos

Os seguintes pacotes devem estar instalados **antes** de instalar este pacote:

| Pacote | Onde obter |
|---|---|
| **LCL** | Incluído no Lazarus |
| **BGRABitmapPack** | [github.com/bgrabitmap/bgrabitmap](https://github.com/bgrabitmap/bgrabitmap) |

Caso o BGRABitmapPack ainda não esteja disponível no seu IDE, instale-o primeiro:

1. Clone ou baixe o repositório `bgrabitmap`.
2. No Lazarus: **Pacote → Abrir arquivo de pacote (.lpk)** → selecione `bgrabitmappack.lpk`.
3. Clique em **Compilar** e depois em **Usar → Instalar**. O Lazarus se reconstruirá automaticamente.

### Instalando este pacote

1. **Abrir o pacote**  
   **Pacote → Abrir arquivo de pacote (.lpk)** → selecione `materialdesign.lpk` deste repositório.

2. **Compilar**  
   Na janela do Editor de Pacotes, clique em **Compilar**.  
   As seis units (`FRMaterialEdit`, `FRMaterialMaskEdit`, `FRMaterialCurrencyEdit`, `FRMaterialComboEdit`, `FRMaterialCheckComboEdit`, `FRMaterialDateEdit`) devem compilar sem erros.

3. **Instalar**  
   Ainda no Editor de Pacotes, clique em **Usar → Instalar**.  
   O Lazarus pedirá confirmação para reconstruir o IDE — confirme com **Sim**.

4. **Verificar**  
   Após o IDE reiniciar, abra a **Paleta de Componentes** e procure pela aba **Material Design**.  
   Você deverá ver:
   - `TFRMaterialEdit`
   - `TFRMaterialMaskEdit`
   - `TFRMaterialCurrencyEdit`
   - `TFRMaterialComboEdit`
   - `TFRMaterialCheckComboEdit`
   - `TFRMaterialDateEdit`

### Adicionando ao projeto sem instalar na paleta

Se preferir não instalar na paleta do IDE, adicione o pacote como dependência do seu projeto:

1. No seu projeto, abra **Projeto → Inspetor de Projeto**.
2. Clique em **Adicionar → Novo Requisito** e escolha `materialdesign`.
3. Adicione as units necessárias na cláusula `uses` de cada formulário:

```pascal
uses
  FRMaterialEdit,
  FRMaterialMaskEdit,
  FRMaterialCurrencyEdit,
  FRMaterialComboEdit,
  FRMaterialCheckComboEdit,
  FRMaterialDateEdit;
```

### Desinstalando

1. **Pacote → Pacotes Instalados** → selecione `materialdesign` → clique em **Desinstalar**.
2. Confirme a reconstrução do IDE.

---

## TFRMaterialEdit

Campo de texto de uma linha com estilo Material Design.

### Propriedades

| Propriedade | Tipo | Padrão | Descrição |
|---|---|---|---|
| `Caption` | `TCaption` | `''` | Texto do label flutuante |
| `Text` | `TCaption` | `''` | Valor atual do campo |
| `TextHint` | `TTranslateString` | `''` | Placeholder exibido quando vazio |
| `AccentColor` | `TColor` | — | Cor do sublinhado e do label com foco |
| `DisabledColor` | `TColor` | — | Cor do sublinhado quando desabilitado |
| `ShowClearButton` | `Boolean` | `False` | Exibe botão `×` quando o campo tem texto |
| `ShowSearchButton` | `Boolean` | `False` | Exibe botão com ícone de lupa à direita do campo |
| `Variant` | `TFRMaterialVariant` | `mvStandard` | Estilo visual do campo (ver tabela abaixo) |
| `BorderRadius` | `Integer` | `0` | Raio dos cantos arredondados em pixels |
| `ReadOnly` | `Boolean` | `False` | Impede edição pelo usuário |
| `MaxLength` | `Integer` | `0` | Máximo de caracteres (0 = ilimitado) |
| `EchoMode` | `TEchoMode` | `emNormal` | Use `emPassword` para campos de senha |
| `PasswordChar` | `Char` | `#0` | Caractere de máscara para modo senha |
| `CharCase` | `TEditCharCase` | `ecNormal` | Forçar maiúsculas/minúsculas |
| `NumbersOnly` | `Boolean` | `False` | Aceitar apenas entrada numérica |
| `AutoSelect` | `Boolean` | `True` | Selecionar tudo ao receber foco |
| `LabelSpacing` | `Integer` | `4` | Pixels entre o label e o campo |
| `EditLabel` | `TBoundLabel` | — | Acesso direto ao label interno |
| `ClearButton` | `TButton` | — | Acesso direto ao botão de limpeza (somente leitura) |
| `SearchButton` | `TBitBtn` | — | Acesso direto ao botão de pesquisa (somente leitura) |

### Eventos principais

`OnChange`, `OnClick`, `OnEnter`, `OnExit`, `OnKeyDown`, `OnKeyPress`, `OnKeyUp`, `OnClearButtonClick`, `OnSearchButtonClick`, `OnEditingDone`, `OnUTF8KeyPress`

### Exemplo

```pascal
FRMaterialEdit1.Caption         := 'E-mail';
FRMaterialEdit1.TextHint        := 'usuario@exemplo.com';
FRMaterialEdit1.AccentColor     := RGBToColor(33, 150, 243);
FRMaterialEdit1.ShowClearButton  := True;
FRMaterialEdit1.ShowSearchButton := True;
```

---

## TFRMaterialComboEdit

Seletor do tipo lista suspensa com estilo Material Design. Equivalente ao `<select>` do HTML.

### Propriedades

| Propriedade | Tipo | Padrão | Descrição |
|---|---|---|---|
| `Caption` | `TCaption` | `''` | Texto do label flutuante |
| `Text` | `TCaption` | `''` | Texto atualmente exibido |
| `Items` | `TStrings` | — | Lista de opções |
| `ItemIndex` | `Integer` | `-1` | Índice do item selecionado |
| `Style` | `TComboBoxStyle` | `csDropDown` | `csDropDown` (editável) ou `csDropDownList` (somente seleção) |
| `AccentColor` | `TColor` | — | Cor do sublinhado e do label com foco |
| `DisabledColor` | `TColor` | — | Cor do sublinhado quando desabilitado |
| `Variant` | `TFRMaterialVariant` | `mvStandard` | Estilo visual do campo |
| `BorderRadius` | `Integer` | `0` | Raio dos cantos arredondados em pixels |
| `Sorted` | `Boolean` | `False` | Ordenar itens alfabeticamente |
| `DropDownCount` | `Integer` | — | Número de linhas visíveis na lista |
| `MaxLength` | `Integer` | `0` | Máximo de caracteres no modo editável |
| `ReadOnly` | `Boolean` | `False` | Desabilitar edição no modo `csDropDown` |
| `LabelSpacing` | `Integer` | `4` | Pixels entre o label e o campo |

### Eventos principais

`OnChange`, `OnEnter`, `OnExit`, `OnKeyDown`, `OnKeyPress`, `OnKeyUp`, `OnEditingDone`

### Exemplo

```pascal
FRMaterialComboEdit1.Caption       := 'País';
FRMaterialComboEdit1.Items.CommaText := 'Brasil,Argentina,Chile';
FRMaterialComboEdit1.Style         := csDropDownList;
FRMaterialComboEdit1.AccentColor   := RGBToColor(76, 175, 80);
```

---

## TFRMaterialCheckComboEdit

Campo de seleção múltipla que abre um painel flutuante com `TCheckListBox`. Equivalente ao `<select multiple>` do HTML.

### Formatos de exibição (`TCheckComboDisplayFormat`)

| Valor | Exemplo de texto exibido |
|---|---|
| `cdfCommaSeparated` | `"Item1, Item2, Item3"` |
| `cdfCountOnly` | `"3 selecionado(s)"` |
| `cdfCountAndFirst` | `"Item1 (+2)"` |

### Propriedades

| Propriedade | Tipo | Padrão | Descrição |
|---|---|---|---|
| `Caption` | `TCaption` | `''` | Texto do label flutuante |
| `Items` | `TStrings` | — | Lista de opções |
| `Checked[i]` | `Boolean` | — | Estado marcado do item `i` |
| `CheckedCount` | `Integer` | — | Quantidade de itens marcados (somente leitura) |
| `DisplayFormat` | `TCheckComboDisplayFormat` | `cdfCommaSeparated` | Como os itens selecionados são exibidos |
| `EmptyText` | `string` | `''` | Texto exibido quando nada está selecionado |
| `AccentColor` | `TColor` | — | Cor do sublinhado e do label com foco |
| `DisabledColor` | `TColor` | — | Cor do sublinhado quando desabilitado |
| `Variant` | `TFRMaterialVariant` | `mvStandard` | Estilo visual do campo |
| `BorderRadius` | `Integer` | `0` | Raio dos cantos arredondados em pixels |
| `DropDownCount` | `Integer` | — | Máximo de linhas visíveis no painel flutuante |
| `Sorted` | `Boolean` | `False` | Ordenar itens alfabeticamente |
| `LabelSpacing` | `Integer` | `4` | Pixels entre o label e o campo |

### Eventos principais

| Evento | Descrição |
|---|---|
| `OnCheckChange(Sender, AIndex, AChecked)` | Disparado quando qualquer checkbox muda de estado |
| `OnDropDownOpen` | Disparado quando o painel flutuante abre |
| `OnDropDownClose` | Disparado quando o painel flutuante fecha |

O painel fecha automaticamente ao clicar fora dele ou ao pressionar **Escape** ou **Enter**.

### Exemplo

```pascal
FRMaterialCheckComboEdit1.Caption       := 'Permissões';
FRMaterialCheckComboEdit1.Items.CommaText := 'Ler,Gravar,Executar';
FRMaterialCheckComboEdit1.DisplayFormat := cdfCountAndFirst;
FRMaterialCheckComboEdit1.EmptyText     := '(nenhum selecionado)';
FRMaterialCheckComboEdit1.Checked[0]   := True;
```

---

## TFRMaterialDateEdit

Seletor de data com label flutuante e sublinhado Material Design. Encapsula o `TDateEdit` da LCL.

### Propriedades

| Propriedade | Tipo | Padrão | Descrição |
|---|---|---|---|
| `Caption` | `TCaption` | `''` | Texto do label flutuante |
| `Date` | `TDateTime` | — | Data selecionada |
| `Text` | `TCaption` | — | Data como string formatada |
| `TextHint` | `TTranslateString` | `''` | Placeholder exibido quando vazio |
| `DateOrder` | `TDateOrder` | `doNone` | Ordem de exibição: `doDMY`, `doMDY`, `doYMD`, `doNone` |
| `DirectInput` | `Boolean` | `True` | Permite digitar a data; `False` = somente via calendário |
| `CalendarDisplaySettings` | `TDisplaySettings` | — | Controla os elementos visíveis do calendário popup |
| `AccentColor` | `TColor` | — | Cor do sublinhado e do label com foco |
| `DisabledColor` | `TColor` | — | Cor do sublinhado quando desabilitado |
| `Variant` | `TFRMaterialVariant` | `mvStandard` | Estilo visual do campo |
| `BorderRadius` | `Integer` | `0` | Raio dos cantos arredondados em pixels |
| `ShowClearButton` | `Boolean` | `False` | Exibe botão `×` para limpar a data |
| `ReadOnly` | `Boolean` | `False` | Impede edição pelo usuário |
| `LabelSpacing` | `Integer` | `4` | Pixels entre o label e o campo |
| `EditLabel` | `TBoundLabel` | — | Acesso direto ao label interno |
| `DateEdit` | `TDateEdit` | — | Acesso direto ao `TDateEdit` interno |
| `ClearButton` | `TButton` | — | Acesso direto ao botão de limpeza (somente leitura) |

### Métodos

| Método | Descrição |
|---|---|
| `ClearDate` | Limpa a data selecionada |

### Eventos principais

`OnChange`, `OnClick`, `OnEnter`, `OnExit`, `OnKeyDown`, `OnKeyPress`, `OnKeyUp`, `OnAcceptDate`, `OnCustomDate`, `OnClearButtonClick`, `OnEditingDone`, `OnUTF8KeyPress`

### Exemplo

```pascal
FRMaterialDateEdit1.Caption         := 'Data de nascimento';
FRMaterialDateEdit1.DateOrder       := doDMY;
FRMaterialDateEdit1.DirectInput     := False;
FRMaterialDateEdit1.AccentColor     := RGBToColor(156, 39, 176);
FRMaterialDateEdit1.ShowClearButton := True;
```

---

## TFRMaterialMaskEdit

Campo de texto com máscara de entrada no estilo Material Design. Encapsula o `TMaskEdit` da LCL.

### Propriedades específicas

| Propriedade | Tipo | Padrão | Descrição |
|---|---|---|---|
| `EditMask` | `string` | `''` | Máscara de entrada no formato Delphi/Lazarus |
| `MaskedText` | `string` | — | Texto **com** os literais da máscara (somente leitura) |
| `Text` | `TCaption` | `''` | Texto **sem** os literais (somente os caracteres digitados) |

As demais propriedades (`Caption`, `AccentColor`, `DisabledColor`, `Variant`, `BorderRadius`, `ShowClearButton`, `CharCase`, `MaxLength`, `AutoSelect`, `ReadOnly`, etc.) são idênticas às de `TFRMaterialEdit`.

### Sintaxe da EditMask

Formato: `<máscara>;<useLiteral>;<blankChar>`

| Caractere | Significado |
|---|---|
| `0` | Dígito obrigatório (0–9) |
| `9` | Dígito ou espaço (opcional) |
| `#` | Dígito, espaço, `+` ou `-` (opcional) |
| `L` | Letra obrigatória (A–Z, a–z) |
| `?` | Letra opcional |
| `A` | Letra ou dígito obrigatório |
| `a` | Letra ou dígito opcional |
| `C` | Qualquer caractere obrigatório |
| `c` | Qualquer caractere opcional |
| `>` | Força maiúsculas a partir daqui |
| `<` | Força minúsculas a partir daqui |
| `\` | Próximo caractere é literal |

### Máscaras prontas (Brasil)

| Dado | EditMask |
|---|---|
| Celular | `"(00) 00000-0000;0;_"` |
| Telefone fixo | `"(00) 0000-0000;0;_"` |
| CPF | `"000.000.000-00;0;_"` |
| CNPJ | `"00.000.000/0000-00;0;_"` |
| CEP | `"00000-000;0;_"` |
| Data DD/MM/AAAA | `"00/00/0000;0;_"` |
| Hora HH:MM:SS | `"00:00:00;0;_"` |
| Placa Mercosul | `">LLL-0A000;0;_"` |

### Exemplo

```pascal
uses FRMaterialMaskEdit;

// CPF com máscara visual
FRMaterialMaskEdit1.Caption      := 'CPF';
FRMaterialMaskEdit1.EditMask     := '000.000.000-00;0;_';
FRMaterialMaskEdit1.AccentColor  := RGBToColor(33, 150, 243);
FRMaterialMaskEdit1.ShowClearButton := True;

// Ler o valor sem a máscara (somente dígitos)
ShowMessage(FRMaterialMaskEdit1.Text);        // ex.: "12345678901"
// Ler o valor com a máscara formatada
ShowMessage(FRMaterialMaskEdit1.MaskedText);  // ex.: "123.456.789-01"
```

---

## TFRMaterialCurrencyEdit

Campo de entrada de valores monetários com formatação automática no estilo Material Design.

**Diferença em relação ao `TFRMaterialMaskEdit`:** a máscara do `TMaskEdit` é estática (posições fixas). Campos de moeda têm comportamento dinâmico: o valor cresce da **direita para esquerda** (centavos primeiro), com separadores reposicionados automaticamente a cada dígito digitado.

### Comportamento de entrada

| Teclas digitadas | Exibição |
|---|---|
| `1` | `R$ 0,01` |
| `12` | `R$ 0,12` |
| `123` | `R$ 1,23` |
| `12345` | `R$ 123,45` |
| `123456` | `R$ 1.234,56` |
| `-` (com `AllowNegative = True`) | inverte o sinal |
| Backspace | remove o último dígito |
| Ctrl+V | cola e extrai apenas dígitos do texto colado |

### Propriedades específicas

| Propriedade | Tipo | Padrão | Descrição |
|---|---|---|---|
| `Value` | `Currency` | `0` | Valor numérico corrente (leitura/escrita) |
| `CurrencySymbol` | `string` | `'R$'` | Prefixo exibido antes do valor; use `''` para omitir |
| `DecimalPlaces` | `Integer` | `2` | Casas decimais (0 a 4); alterar rescala o valor atual |
| `ThousandSeparator` | `Char` | `'.'` | Separador de milhar |
| `DecimalSeparator` | `Char` | `','` | Separador decimal |
| `AllowNegative` | `Boolean` | `False` | Permite valores negativos (tecla `-` inverte sinal) |

As demais propriedades (`Caption`, `AccentColor`, `DisabledColor`, `Variant`, `BorderRadius`, `ShowClearButton`, `Alignment`, `ReadOnly`, etc.) são idênticas às dos outros componentes. O alinhamento padrão é `taRightJustify`.

### Método público

| Método | Descrição |
|---|---|
| `Clear` | Zera o valor (equivale a `Value := 0`) |

### Exemplo

```pascal
uses FRMaterialCurrencyEdit;

// Configuração
FRMaterialCurrencyEdit1.Caption        := 'Valor total';
FRMaterialCurrencyEdit1.CurrencySymbol := 'R$';
FRMaterialCurrencyEdit1.DecimalPlaces  := 2;
FRMaterialCurrencyEdit1.AccentColor    := RGBToColor(33, 150, 243);
FRMaterialCurrencyEdit1.ShowClearButton := True;

// Definir valor via código
FRMaterialCurrencyEdit1.Value := 1234.56;
// Campo exibe: "R$ 1.234,56"

// Ler o valor numérico
var Total: Currency;
Total := FRMaterialCurrencyEdit1.Value;

// Sem símbolo, separadores internacionais
FRMaterialCurrencyEdit1.CurrencySymbol   := 'US$';
FRMaterialCurrencyEdit1.ThousandSeparator := ',';
FRMaterialCurrencyEdit1.DecimalSeparator  := '.';
// Campo exibe: "US$ 1,234.56"
```

---

## Comportamento comum

Todos os cinco controles compartilham as mesmas convenções visuais:

- **Em repouso**: sublinhado cinza fino abaixo do campo.
- **Com foco**: o sublinhado engrossa e assume a `AccentColor`; o label flutuante sobe para o topo e também fica em `AccentColor`.
- **Desabilitado**: o sublinhado usa a `DisabledColor`.
- A classe base `TFRMaterialEditBase<T>` é genérica; `T` é o controle LCL encapsulado.

### Variant — três estilos visuais

A propriedade `Variant: TFRMaterialVariant` está disponível em todos os quatro componentes.

| Valor | Visual | Sublinhado | Borda |
|---|---|---|---|
| `mvStandard` | Campo plano, fundo da janela | Sim | Não |
| `mvFilled` | Campo preenchido com `Color` | Sim | Não |
| `mvOutlined` | Campo contornado | Não | Sim (arredondada) |

Juntos com `BorderRadius: Integer` (raio em pixels), permitem várias combinações:

```pascal
{ Campo outlined com cantos arredondados (estilo Material 3) }
FRMaterialEdit1.Variant      := mvOutlined;
FRMaterialEdit1.BorderRadius := 4;

{ Campo preenchido com fundo claro e cantos arredondados }
FRMaterialEdit1.Variant      := mvFilled;
FRMaterialEdit1.Color        := $00F5F5F5;
FRMaterialEdit1.BorderRadius := 4;
```

---

## FRMaterialTheme — utilitários de contraste (WCAG 2.1)

A unit `FRMaterialTheme` exporta funções de acessibilidade de cor baseadas na especificação
[WCAG 2.1](https://www.w3.org/TR/WCAG21/#contrast-minimum):

```pascal
uses FRMaterialTheme;
```

| Função | Retorno | Descrição |
|---|---|---|
| `MCLuminance(AColor)` | `Single` (0..1) | Luminância relativa de uma cor |
| `MCContrastRatio(AFg, ABg)` | `Single` (1..21) | Razão de contraste WCAG entre duas cores |
| `MCContrastText(ABg)` | `clBlack` ou `clWhite` | Melhor cor de texto sobre `ABg` |

### Exemplo — cor de label com contraste automático

```pascal
{ Garante que o label seja legível independentemente do fundo do componente }
FRMaterialEdit1.Color := RGBToColor(30, 30, 30);   { fundo escuro }
FRMaterialEdit1.Font.Color := MCContrastText(FRMaterialEdit1.Color);
{ MCContrastText retorna clWhite para fundos escuros, clBlack para fundos claros }
```

### Verificar conformidade WCAG

```pascal
var
  Ratio: Single;
begin
  Ratio := MCContrastRatio(clBlack, FRMaterialEdit1.Color);
  if Ratio < 4.5 then
    ShowMessage('Contraste insuficiente para texto normal (WCAG AA)');
end;
```

---

## Licença

LGPL v3 — mesma licença do [BGRAControls](https://github.com/bgrabitmap/bgracontrols).

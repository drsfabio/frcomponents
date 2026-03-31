# Material Design 3 Component Library for Lazarus

Componentes Material Design 3 completos para Lazarus / Free Pascal, integrados ao pacote [BGRAControls](https://github.com/bgrabitmap/bgracontrols). Licenciado sob **LGPL v3**.

## Visão geral

Este pacote fornece **41 componentes visuais** + 3 unidades utilitárias que implementam a especificação Material Design 3 (Material You), incluindo:

- **Botões** — Button, ButtonIcon, SplitButton, FAB, ExtendedFAB, FABMenu
- **Controles** — Switch, CheckBox, RadioButton, Chip, SegmentedButton
- **Campos de entrada** — Edit, ComboEdit, CheckComboEdit, CurrencyEdit, DateEdit, MaskEdit, MemoEdit, SearchEdit, SpinEdit
- **Sliders / Time** — Slider, TimePicker
- **Progresso** — LinearProgress, CircularProgress, LoadingIndicator
- **Dados** — Tabs, ListView, TreeView
- **Navegação** — AppBar, Toolbar, NavBar, NavDrawer, NavRail
- **Superfícies** — Dialog, Snackbar, Tooltip, Menu, GroupBox, Divider, BottomSheet, SideSheet

### Resumo de componentes

| # | Componente | Unit | Descrição |
|---|---|---|---|
| 01 | `TFRMaterialButton` | `FRMaterial3Button` | Botão MD3 — Filled, Outlined, Text, Elevated, Tonal |
| 02 | `TFRMaterialButtonIcon` | `FRMaterial3Button` | Botão de ícone — Standard, Filled, FilledTonal, Outlined |
| 03 | `TFRMaterialSplitButton` | `FRMaterial3Button` | Botão dividido com ação + menu |
| 04 | `TFRMaterialFAB` | `FRMaterial3FAB` | Floating Action Button (Small/Regular/Large) |
| 05 | `TFRMaterialExtendedFAB` | `FRMaterial3FAB` | FAB estendido com texto |
| 06 | `TFRMaterialFABMenu` | `FRMaterial3FAB` | Speed Dial — FAB expansível com sub-itens |
| 07 | `TFRMaterialSwitch` | `FRMaterial3Toggle` | Toggle switch on/off |
| 08 | `TFRMaterialCheckBox` | `FRMaterial3Toggle` | CheckBox com tri-state |
| 09 | `TFRMaterialRadioButton` | `FRMaterial3Toggle` | RadioButton com GroupIndex |
| 10 | `TFRMaterialChip` | `FRMaterial3Chip` | Chip — Assist, Filter, Input, Suggestion |
| 11 | `TFRMaterialSegmentedButton` | `FRMaterial3Chip` | Botão segmentado (single/multi-select) |
| 12 | `TFRMaterialEdit` | `FRMaterialEdit` | Input de texto com validação, máscara, autocomplete |
| 13 | `TFRMaterialComboEdit` | `FRMaterialComboEdit` | ComboBox com floating label |
| 14 | `TFRMaterialCheckComboEdit` | `FRMaterialCheckComboEdit` | Multi-select com checkboxes |
| 15 | `TFRMaterialCurrencyEdit` | `FRMaterialCurrencyEdit` | Campo monetário (R$) |
| 16 | `TFRMaterialDateEdit` | `FRMaterialDateEdit` | Seletor de data com calendário |
| 17 | `TFRMaterialMaskEdit` | `FRMaterialMaskEdit` | Input com máscara (CPF, CNPJ, CEP) |
| 18 | `TFRMaterialMemoEdit` | `FRMaterialMemoEdit` | Editor multilinha com char counter |
| 19 | `TFRMaterialSearchEdit` | `FRMaterialSearchEdit` | Campo de busca com debounce |
| 20 | `TFRMaterialSpinEdit` | `FRMaterialSpinEdit` | Stepper numérico (+/-) |
| 21 | `TFRMaterialSlider` | `FRMaterial3Slider` | Slider contínuo ou discreto |
| 22 | `TFRMaterialTimePicker` | `FRMaterial3TimePicker` | Seletor de hora 24h / 12h |
| 23 | `TFRMaterialLinearProgress` | `FRMaterial3Progress` | Barra de progresso linear |
| 24 | `TFRMaterialCircularProgress` | `FRMaterial3Progress` | Indicador circular de progresso |
| 25 | `TFRMaterialLoadingIndicator` | `FRMaterial3Progress` | Animação de pontos pulsantes |
| 26 | `TFRMaterialTabs` | `FRMaterial3Tabs` | Tabs fixas ou scrollable |
| 27 | `TFRMaterialListView` | `FRMaterial3List` | Lista MD3 (OneLine/TwoLine/ThreeLine) |
| 28 | `TFRMaterialTreeView` | `FRMaterial3TreeView` | Árvore hierárquica com expand/collapse |
| 29 | `TFRMaterialAppBar` | `FRMaterial3AppBar` | Top App Bar (Small/Medium/Large) |
| 30 | `TFRMaterialToolbar` | `FRMaterial3AppBar` | Barra de ferramentas com ações |
| 31 | `TFRMaterialNavBar` | `FRMaterial3Nav` | Barra de navegação inferior com badges |
| 32 | `TFRMaterialNavDrawer` | `FRMaterial3Nav` | Drawer lateral de navegação (360dp) |
| 33 | `TFRMaterialNavRail` | `FRMaterial3Nav` | Rail vertical de navegação (80dp) |
| 34 | `TFRMaterialDialog` | `FRMaterial3Dialog` | Diálogo modal com botões |
| 35 | `TFRMaterialSnackbar` | `FRMaterial3Snackbar` | Toast/Snackbar com ação |
| 36 | `TFRMaterialTooltip` | `FRMaterial3Tooltip` | Tooltip flutuante |
| 37 | `TFRMaterialMenu` | `FRMaterial3Menu` | Menu popup com ícones e separadores |
| 38 | `TFRMaterialGroupBox` | `FRMaterial3Dialog` | Container com borda arredondada |
| 39 | `TFRMaterialDivider` | `FRMaterial3Divider` | Linha divisória horizontal |
| 40 | `TFRMaterialBottomSheet` | `FRMaterial3Sheet` | Painel deslizante inferior |
| 41 | `TFRMaterialSideSheet` | `FRMaterial3Sheet` | Painel deslizante lateral |

### Unidades utilitárias

| Unit | Descrição |
|---|---|
| `FRMaterial3Base` | Sistema de cores MD3, formas, helpers, classes base |
| `FRMaterialTheme` | Paletas pré-definidas (12), dark mode, utilitários WCAG 2.1 |
| `FRMaterialIcons` | 50+ ícones SVG vetoriais |
| `FRMaterialMasks` | Máscaras PT-BR (CPF, CNPJ, Telefone, CEP) |

---

## Componentes MD3 (Material Design 3)

### TFRMaterialButton

Botão MD3 com 5 estilos visuais.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `ButtonStyle` | `TFRMDButtonStyle` | `mbsFilled`, `mbsOutlined`, `mbsText`, `mbsElevated`, `mbsTonal` |
| `Caption` | `string` | Texto do botão |
| `ShowIcon` | `Boolean` | Exibir ícone à esquerda |
| `IconMode` | `TFRIconMode` | Ícone SVG (`imSearch`, `imEdit`, etc.) |
| `Enabled` | `Boolean` | Habilitar/desabilitar |

### TFRMaterialButtonIcon

Botão somente ícone com 4 estilos + suporte a toggle.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `IconStyle` | `TFRMDIconButtonStyle` | `ibsStandard`, `ibsFilled`, `ibsFilledTonal`, `ibsOutlined` |
| `IconMode` | `TFRIconMode` | Ícone SVG |
| `Toggle` | `Boolean` | Habilitar modo toggle |
| `Toggled` | `Boolean` | Estado ativo/inativo |

### TFRMaterialSplitButton

Botão dividido com ação principal e dropdown.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `ButtonStyle` | `TFRMDSplitButtonStyle` | `mbsFilled`, `mbsOutlined` |
| `Caption` | `string` | Texto da ação principal |

### TFRMaterialFAB / TFRMaterialExtendedFAB

Floating Action Button em 3 tamanhos + versão estendida com texto.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `FABSize` | `TFRMDFABSize` | `fsSmall` (40px), `fsRegular` (56px), `fsLarge` (96px) |
| `IconMode` | `TFRIconMode` | Ícone central |
| `Caption` | `string` | Texto (ExtendedFAB apenas) |
| `ShowIcon` | `Boolean` | Mostrar ícone (ExtendedFAB) |

### TFRMaterialFABMenu (Speed Dial)

FAB expansível com sub-itens de ação.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `IconMode` | `TFRIconMode` | Ícone do FAB principal |
| `Items` | `TFRMaterialFABMenuItems` | Coleção de sub-ações (Caption, IconMode, OnClick) |
| `Expanded` | `Boolean` | Estado aberto/fechado |

### TFRMaterialSwitch / TFRMaterialCheckBox / TFRMaterialRadioButton

Controles de estado on/off no estilo MD3.

| Controle | Propriedades principais |
|---|---|
| `Switch` | `Checked`, `Enabled` |
| `CheckBox` | `Checked`, `State`, `AllowGrayed`, `Caption` |
| `RadioButton` | `Checked`, `GroupIndex`, `Caption` |

### TFRMaterialChip

Chip MD3 com 4 estilos.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `ChipStyle` | `TFRMDChipStyle` | `csAssist`, `csFilter`, `csInput`, `csSuggestion` |
| `Selected` | `Boolean` | Estado selecionado |
| `Deletable` | `Boolean` | Mostrar botão de fechar (Input) |
| `ShowIcon` | `Boolean` | Mostrar ícone à esquerda |

### TFRMaterialSegmentedButton

Grupo de botões com seleção única ou múltipla.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `Items` | `TStrings` | Lista de segmentos |
| `ItemIndex` | `Integer` | Segmento selecionado |
| `MultiSelect` | `Boolean` | Permitir seleção múltipla |

### TFRMaterialSlider

Slider contínuo ou discreto com label de valor.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `Min` / `Max` | `Double` | Faixa de valores |
| `Value` | `Double` | Valor atual |
| `Discrete` | `Boolean` | Modo discreto com steps |
| `Steps` | `Integer` | Número de passos |
| `ShowValueLabel` | `Boolean` | Exibir tooltip com valor |

### TFRMaterialTimePicker

Seletor de hora com formato 24h ou 12h.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `Hour` / `Minute` | `Integer` | Hora e minuto |
| `TimeFormat` | `TFRMDTimeFormat` | `tfHour24`, `tfHour12` |
| `IsAM` | `Boolean` | AM/PM (modo 12h) |
| `TimeStr` | `string` | Hora formatada (leitura) |

### TFRMaterialLinearProgress / TFRMaterialCircularProgress

Indicadores de progresso determinado ou indeterminado.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `Value` | `Double` | 0–100 (determinado) |
| `Indeterminate` | `Boolean` | Animação infinita |
| `StrokeWidth` | `Integer` | Espessura do traço (Circular) |

### TFRMaterialLoadingIndicator

Animação de pontos pulsantes.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `DotCount` | `Integer` | Número de pontos (padrão: 3) |

### TFRMaterialTabs

Barra de tabs fixas ou scrollable.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `TabStyle` | `TFRMDTabStyle` | `tsFixed`, `tsScrollable` |
| `Tabs` | `TFRMaterialTabItems` | Coleção (Caption, IconMode) |
| `TabIndex` | `Integer` | Tab ativa |

### TFRMaterialListView

Lista MD3 com suporte a 1, 2 ou 3 linhas, ícones e texto trailing.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `ItemType` | `TFRMDListItemType` | `litOneLine`, `litTwoLine`, `litThreeLine` |
| `ShowDividers` | `Boolean` | Separadores entre itens |
| `Items` | `TFRMaterialListItems` | Coleção (Headline, SupportText, LeadingIcon, TrailingText) |

### TFRMaterialTreeView

Árvore hierárquica com expand/collapse, ícones e seleção.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `Nodes` | `TFRMaterialTreeNodes` | Nós raiz (Caption, IconMode, Children, Expanded) |
| `ShowIcons` | `Boolean` | Exibir ícones dos nós |
| `ShowDividers` | `Boolean` | Separadores entre nós |
| `ItemHeight` | `Integer` | Altura de cada nó (padrão: 48px) |
| `Indent` | `Integer` | Indentação por nível (padrão: 24px) |
| `SelectedNode` | `TFRMaterialTreeNode` | Nó selecionado |

### TFRMaterialAppBar / TFRMaterialToolbar

Top App Bar e barra de ferramentas.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `Title` | `string` | Texto do título (AppBar) |
| `NavIcon` | `TFRIconMode` | Ícone de navegação (AppBar) |
| `BarSize` | `TFRMDAppBarSize` | `absSmall`, `absMedium`, `absLarge` |
| `Actions` | `TFRMaterialAppBarActions` | Coleção de ações (IconMode, Hint, OnClick) |

### TFRMaterialNavBar / TFRMaterialNavDrawer / TFRMaterialNavRail

Componentes de navegação MD3.

| Componente | Diferencial |
|---|---|
| `NavBar` | Barra inferior (80px), itens com caption + ícone + badge |
| `NavDrawer` | Painel lateral (360dp) com HeaderTitle |
| `NavRail` | Rail vertical (80dp) com MenuIcon + FabIcon |

### TFRMaterialDialog

Diálogo modal com título, conteúdo e botões.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `Title` | `string` | Título |
| `Content` | `string` | Corpo do diálogo |
| `Buttons` | `TFRMDDialogButtons` | Conjunto: `dbYes`, `dbNo`, `dbCancel` |
| `Execute` | `TFRMDDialogResult` | Método — exibe e retorna resultado |

### TFRMaterialSnackbar

Toast/Snackbar temporário.

```pascal
FSnackbar.Show('Operação concluída!', 'DESFAZER');
```

### TFRMaterialMenu

Menu popup com ícones e separadores.

```pascal
FMenu.Items.Add.Caption := 'Copiar';
FMenu.Items.Add.IconMode := imCopy;
FMenu.Popup(X, Y);
```

### TFRMaterialBottomSheet / TFRMaterialSideSheet

Painéis deslizantes.

| Componente | Propriedade | Método |
|---|---|---|
| `BottomSheet` | `SheetHeight`, `DragHandle` | `Toggle` |
| `SideSheet` | `SheetWidth` | `Toggle` |

### FRMaterialTheme — Paletas e Dark Mode

12 paletas pré-definidas com suporte a dark mode:

```pascal
MD3LoadPalette(mpBaseline, False); { Light mode }
MD3LoadPalette(mpOcean, True);     { Dark mode }
```

Paletas: Baseline, Ocean, Forest, Sunset, Rose, Lavender, Coral, Mint, Slate, Amber, Crimson, Teal.

---

## Campos de entrada (detalhes)

A seção abaixo descreve as propriedades detalhadas dos campos de entrada originais.

---

## Coexistência com BGRAControls

Este pacote é um **fork** das units Material Design originalmente incluídas no [BGRAControls](https://github.com/bgrabitmap/bgracontrols). As unidades originais usam o prefixo `BCMaterial*`; este pacote usa o prefixo `FRMaterial*` justamente para eliminar qualquer conflito.

Você pode instalar este pacote **ao mesmo tempo** que o BGRAControls sem nenhum conflito de nomes de unit.

> **Migração do BCMaterial original (BGRAControls):** As classes foram renomeadas de `TBCMaterial*` para `TFRMaterial*`. Ao migrar, use **Localizar/Substituir** global no projeto (substitua `TBCMaterial` por `TFRMaterial`) e atualize as cláusulas `uses` conforme a tabela abaixo:

| Unit antiga (BCMaterial) | Unit nova (FRMaterial) | Classe antiga | Classe nova |
|---|---|---|---|
| `BCMaterialEdit` | `FRMaterialEdit` | `TBCMaterialEdit` | `TFRMaterialEdit` |
| `BCMaterialComboEdit` | `FRMaterialComboEdit` | `TBCMaterialComboEdit` | `TFRMaterialComboEdit` |
| `BCMaterialCheckComboEdit` | `FRMaterialCheckComboEdit` | `TBCMaterialCheckComboEdit` | `TFRMaterialCheckComboEdit` |
| `BCMaterialDateEdit` | `FRMaterialDateEdit` | `TBCMaterialDateEdit` | `TFRMaterialDateEdit` |

`TFRMaterialMaskEdit` e `TFRMaterialCurrencyEdit` são componentes novos, sem equivalente no pacote BCMaterial original.

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
   As 31 units devem compilar sem erros.

3. **Instalar**  
   Ainda no Editor de Pacotes, clique em **Usar → Instalar**.  
   O Lazarus pedirá confirmação para reconstruir o IDE — confirme com **Sim**.

4. **Verificar**  
   Após o IDE reiniciar, abra a **Paleta de Componentes** e procure pela aba **BGRA Controls**.  
   Você deverá ver os 41 componentes listados acima.

### Adicionando ao projeto sem instalar na paleta

Se preferir não instalar na paleta do IDE, adicione o pacote como dependência do seu projeto:

1. No seu projeto, abra **Projeto → Inspetor de Projeto**.
2. Clique em **Adicionar → Novo Requisito** e escolha `materialdesign`.
3. Adicione as units necessárias na cláusula `uses` de cada formulário:

```pascal
uses
  FRMaterial3Base,       { cores, helpers }
  FRMaterial3Button,     { Button, ButtonIcon, SplitButton }
  FRMaterial3FAB,        { FAB, ExtendedFAB, FABMenu }
  FRMaterial3Toggle,     { Switch, CheckBox, RadioButton }
  FRMaterial3Chip,       { Chip, SegmentedButton }
  FRMaterialEdit,        { Edit com validação/máscara }
  FRMaterialComboEdit,   { ComboBox }
  FRMaterialCheckComboEdit, { Multi-select }
  FRMaterialCurrencyEdit,   { Campo monetário }
  FRMaterialDateEdit,    { Seletor de data }
  FRMaterialMaskEdit,    { Input com máscara }
  FRMaterialMemoEdit,    { Editor multilinha }
  FRMaterialSearchEdit,  { Busca com debounce }
  FRMaterialSpinEdit,    { Stepper numérico }
  FRMaterial3Slider,     { Slider contínuo/discreto }
  FRMaterial3TimePicker,  { Seletor de hora }
  FRMaterial3Progress,   { Linear/Circular/Loading }
  FRMaterial3Tabs,       { Tabs }
  FRMaterial3List,       { ListView }
  FRMaterial3TreeView,   { TreeView hierárquica }
  FRMaterial3AppBar,     { AppBar, Toolbar }
  FRMaterial3Nav,        { NavBar, NavDrawer, NavRail }
  FRMaterial3Dialog,     { Dialog, GroupBox }
  FRMaterial3Snackbar,   { Snackbar }
  FRMaterial3Tooltip,    { Tooltip }
  FRMaterial3Menu,       { Menu popup }
  FRMaterial3Divider,    { Divider }
  FRMaterial3Sheet,      { BottomSheet, SideSheet }
  FRMaterialIcons;       { Ícones SVG }
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

| Evento | Descrição |
|---|---|
| `OnChange` | Disparado a cada alteração do texto |
| `OnClick` | Clique no campo |
| `OnEnter` / `OnExit` | Campo recebe / perde foco |
| `OnKeyDown`, `OnKeyPress`, `OnKeyUp` | Eventos de teclado padrão |
| `OnUTF8KeyPress` | Tecla pressionada (string UTF-8) |
| `OnClearButtonClick` | Botão `×` foi clicado |
| `OnEditingDone` | Edição confirmada (Enter ou perda de foco) |

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

| Parte | Valores | Significado |
|---|---|---|
| `<máscara>` | string | Padrão de entrada (ver tabela de caracteres abaixo) |
| `<useLiteral>` | `0` ou `1` | `0` → `Text` retorna somente os dígitos/letras digitados; `1` → `Text` inclui os literais da máscara |
| `<blankChar>` | qualquer char | Caractere exibido enquanto a posição ainda não foi preenchida (ex.: `_`) |

> **`Text` vs `MaskedText`**  
> - `Text` sempre retorna o conteúdo **sem** literais (somente os caracteres digitados), independente do `useLiteral`.  
> - `MaskedText` sempre retorna o conteúdo **com** literais, útil para exibir ou persistir o valor já formatado.

#### Caracteres especiais da máscara

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

Todos os seis controles compartilham as mesmas convenções visuais:

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

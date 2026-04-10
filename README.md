# Material Design 3 Component Library for Lazarus

> **v2.0** — Abril 2026

Componentes Material Design 3 completos para Lazarus / Free Pascal, integrados ao pacote [BGRAControls](https://github.com/bgrabitmap/bgracontrols). Licenciado sob **LGPL v3**.

## Visão geral

Este pacote fornece **50 componentes visuais** + 6 unidades utilitárias que implementam a especificação Material Design 3 (Material You), incluindo:

- **Botões** — Button, ButtonIcon, SplitButton, FAB, ExtendedFAB, FABMenu
- **Controles** — Switch, CheckBox, RadioButton, Chip, SegmentedButton
- **Campos de entrada** — Edit, ComboEdit, CheckComboEdit, CurrencyEdit, DateEdit, MaskEdit, MemoEdit, SearchEdit, SpinEdit
- **Sliders / Time** — Slider, TimePicker
- **Progresso** — LinearProgress, CircularProgress, LoadingIndicator
- **Dados** — Tabs, ListView, TreeView, DataGrid, PageControl, VirtualDataGrid
- **Navegação** — AppBar, Toolbar, NavBar, NavDrawer, NavRail
- **Superfícies** — Dialog, Snackbar, Tooltip, Menu, GroupBox, Divider, BottomSheet, SideSheet
- **Containers** — Card (Filled, Outlined, Elevated), GridPanel (auto-flow 12 colunas)
- **Indicadores** — Badge (Dot, Count), Carousel, DatePicker

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
| 42 | `TFRMaterialThemeManager` | `FRMaterialThemeManager` | Gerenciador de tema Light/Dark — não-visual |
| 43 | `TFRMaterialDataGrid` | `FRMaterial3DataGrid` | Tabela de dados baseada em TStringGrid com tema MD3 |
| 44 | `TFRMaterialPageControl` | `FRMaterial3PageControl` | PageControl com abas MD3, close button e ícones |
| 45 | `TFRMaterialVirtualDataGrid` | `FRMaterial3VirtualDataGrid` | Grid virtual (VirtualStringTree) com sort, filtro e edição inline |
| 46 | `TFRMaterialCard` | `FRMaterial3Card` | Card MD3 — Filled, Outlined, Elevated — container com ripple |
| 47 | `TFRMaterialBadge` | `FRMaterial3Badge` | Badge — indicador dot ou contagem (99+) |
| 48 | `TFRMaterialCarousel` | `FRMaterial3Carousel` | Carousel horizontal com auto-play e indicadores |
| 49 | `TFRMaterialDatePicker` | `FRMaterial3DatePicker` | Seletor de data com calendário mensal completo |
| 50 | `TFRMaterialGridPanel` | `FRMaterial3GridPanel` | Grid layout 12 colunas — auto-flow, ColSpan por filho, gap configurável |

### Unidades utilitárias

| Unit | Descrição |
|---|---|
| `FRMaterial3Base` | Sistema de cores MD3, formas, helpers, classes base |
| `FRMaterialTheme` | Paletas pré-definidas (12), dark mode, densidade, utilitários WCAG 2.1 |
| `FRMaterialThemeManager` | Componente não-visual para troca de tema Light/Dark em runtime |
| `FRMaterialFieldPainter` | Renderização centralizada de campos (floating label, bordas, helpers) |
| `FRMaterialInternalEdits` | Edits internos sem borda nativa (TEdit, TMaskEdit, TMemo, etc.) |
| `FRMaterialIcons` | 80+ ícones SVG vetoriais |
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
| `Density` | `TFRMDDensity` | `ddNormal` (40px), `ddCompact` (36px), `ddDense` (32px), `ddUltraDense` (28px) |
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

### TFRMaterialDataGrid

Tabela de dados baseada em `TStringGrid` com estilo Material Design 3. Suporta sort por coluna, zebra stripes e sincronização com o tema.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `Density` | `TFRMDDensity` | Compactação vertical das linhas |
| `ZebraStripes` | `Boolean` | Alterna coloração zebrada nas linhas de dados |
| `SortCol` | `Integer` | Coluna atualmente ordenada (somente leitura) |
| `SortDir` | `TFRMDSortDirection` | Direção da ordenação: `sdNone`, `sdAscending`, `sdDescending` |
| `SyncWithTheme` | `TFRMDSyncOptions` | Opções de sincronização com o tema (`toColor`, `toDensity`, `toVariant`) |
| `OnSortColumn` | `TFRMDSortEvent` | Disparado ao clicar no cabeçalho de uma coluna |

### TFRMaterialPageControl

PageControl com abas MD3, suporte a ícones, botão de fechar e posição superior/inferior.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `ActivePageIndex` | `Integer` | Índice da página ativa |
| `TabHeight` | `Integer` | Altura da barra de abas (padrão: 48px) |
| `ShowCloseButton` | `Boolean` | Exibir botão de fechar nas abas |
| `TabPosition` | `TFRTabPosition` | Posição das abas: `tpTop`, `tpBottom` |
| `BackgroundImage` | `TPicture` | Imagem de fundo da barra de abas |
| `OnChange` | `TNotifyEvent` | Disparado ao trocar de página |
| `OnCloseTab` | `TFRMDCloseTabEvent` | Disparado antes de fechar uma aba (permite vetar) |

**TFRMaterialTabPage** — cada página possui: `Caption`, `IconMode`, `ImageIndex`, `Color`.

### TFRMaterialVirtualDataGrid

Grid virtual baseado em `TLazVirtualStringTree` com sort automático, filtro por coluna e edição inline. Ideal para grandes volumes de dados.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `Density` | `TFRMDDensity` | Compactação vertical dos nós |
| `ZebraStripes` | `Boolean` | Alterna coloração zebrada |
| `AutoSort` | `Boolean` | Ordenação automática ao clicar no cabeçalho (padrão: `True`) |
| `FilterEnabled` | `Boolean` | Habilita filtro com popup por coluna (padrão: `True`) |
| `SortCol` | `Integer` | Coluna atualmente ordenada (somente leitura) |
| `SortDir` | `TFRMDSortDirection` | Direção da ordenação |
| `SyncWithTheme` | `TFRMDSyncOptions` | Sincronização com o tema |
| `OnSortColumn` | `TFRMDSortColumnEvent` | Disparado ao ordenar |
| `OnFilterApply` | `TFRMDFilterApplyEvent` | Disparado após aplicar filtro |
| `OnEditApplyValue` | `TFRMDEditApplyEvent` | Disparado para salvar valor editado |
| `OnEditGetValue` | `TFRMDEditGetValueEvent` | Disparado para obter valor da célula para edição |

### TFRMaterialCard

Card MD3 com 3 estilos visuais. Funciona como container — aceita controles filhos arrastados no IDE.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `CardStyle` | `TFRMDCardStyle` | `cssFilled`, `cssOutlined`, `cssElevated` |
| `BorderRadius` | `Integer` | Raio dos cantos (padrão: 12px) |
| `ContentPadding` | `Integer` | Padding interno (padrão: 16px) |
| `HeaderImage` | `TPicture` | Imagem no topo do card |
| `HeaderHeight` | `Integer` | Altura da imagem de cabeçalho |
| `Clickable` | `Boolean` | Habilita ripple e estado de hover |
| `OnCardClick` | `TNotifyEvent` | Disparado ao clicar no card |

### TFRMaterialBadge

Indicador de status pequeno anexado a outro controle.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `BadgeMode` | `TFRMDBadgeMode` | `bmDot` (6×6 círculo) ou `bmCount` (pill com número) |
| `Value` | `Integer` | Valor numérico exibido (modo Count) |
| `MaxValue` | `Integer` | Valor máximo antes de mostrar "99+" (padrão: 99) |
| `AttachTo` | `TControl` | Controle alvo — badge se posiciona automaticamente |
| `OffsetX` / `OffsetY` | `Integer` | Ajuste fino de posição |

### TFRMaterialCarousel

Rotador horizontal de itens com animação suave e auto-play.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `Items` | `TFRMaterialCarouselItems` | Coleção de itens (Image, Title, Subtitle) |
| `ActiveIndex` | `Integer` | Índice do item visível |
| `AutoPlay` | `Boolean` | Avançar automaticamente |
| `AutoPlayInterval` | `Integer` | Intervalo em ms (padrão: 3000) |
| `ShowIndicators` | `Boolean` | Exibir dots de página |
| `BorderRadius` | `Integer` | Raio dos cantos (padrão: 12px) |
| `OnChange` | `TFRCarouselChangeEvent` | Disparado ao mudar de item |

### TFRMaterialDatePicker

Seletor de data com calendário mensal completo no estilo MD3.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `Date` | `TDate` | Data selecionada |
| `MinDate` / `MaxDate` | `TDate` | Intervalo de datas permitidas |
| `ShowToday` | `Boolean` | Destacar o dia atual com contorno |
| `Year` / `Month` / `Day` | `Integer` | Componentes da data (somente leitura) |
| `OnChange` | `TNotifyEvent` | Disparado ao selecionar uma data |

### TFRMaterialMemoEdit

Editor multilinha com floating label, char counter e estilo MD3.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `Caption` | `TCaption` | Texto do label flutuante |
| `Text` | `string` | Conteúdo do memo |
| `Lines` | `TStrings` | Linhas do editor |
| `MaxLength` | `Integer` | Máximo de caracteres (0 = ilimitado) |
| `ShowCharCounter` | `Boolean` | Exibe contador de caracteres |
| `ScrollBars` | `TScrollStyle` | Barras de rolagem |
| `WordWrap` | `Boolean` | Quebra de linha automática |
| `Variant` | `TFRMaterialVariant` | Estilo visual do campo |
| `BorderRadius` | `Integer` | Raio dos cantos arredondados |

### TFRMaterialSearchEdit

Campo de busca com debounce integrado.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `Caption` | `TCaption` | Texto do label flutuante |
| `Text` | `string` | Texto digitado |
| `DebounceDelay` | `Integer` | Intervalo em ms antes de disparar `OnSearch` |
| `Variant` | `TFRMaterialVariant` | Estilo visual do campo |
| `OnSearch` | `TNotifyEvent` | Disparado após o debounce expirar |

### TFRMaterialSpinEdit

Stepper numérico com botões +/- no estilo MD3.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `Caption` | `TCaption` | Texto do label flutuante |
| `Value` | `Double` | Valor numérico atual |
| `MinValue` / `MaxValue` | `Double` | Faixa de valores |
| `Increment` | `Double` | Passo de incremento/decremento |
| `DecimalPlaces` | `Integer` | Casas decimais exibidas |
| `Variant` | `TFRMaterialVariant` | Estilo visual do campo |

### TFRMaterialGridPanel

Grid layout com sistema de 12 colunas (padrão MD3). Filhos são posicionados automaticamente em linhas, com wrap quando não cabem.

| Propriedade | Tipo | Descrição |
|---|---|---|
| `ColumnCount` | `Integer` | Número de colunas do grid (padrão 12, máx 24) |
| `GapH` | `Integer` | Espaçamento horizontal entre colunas (px) |
| `GapV` | `Integer` | Espaçamento vertical entre linhas (px) |
| `Items` | `TFRGridItems` | Coleção de itens — cada item associa um controle filho ao seu ColSpan |

**TFRGridItem (item da coleção)**:

| Propriedade | Tipo | Descrição |
|---|---|---|
| `Control` | `TControl` | Controle filho associado |
| `ColSpan` | `Integer` | Quantas colunas o controle ocupa (1–ColumnCount) |

**Uso no IDE:** Arraste controles para dentro do GridPanel. Um item é criado automaticamente na coleção `Items`. Defina o `ColSpan` de cada item no Object Inspector.

**Uso por código:**
```pascal
GridPanel.SetColSpan(EdCodigo, 3);  // 3 de 12 colunas
GridPanel.SetColSpan(EdNome, 9);    // completa a linha
```

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
   As 40 units devem compilar sem erros.

3. **Instalar**  
   Ainda no Editor de Pacotes, clique em **Usar → Instalar**.  
   O Lazarus pedirá confirmação para reconstruir o IDE — confirme com **Sim**.

4. **Verificar**  
   Após o IDE reiniciar, abra a **Paleta de Componentes** e procure pela aba **BGRA Controls**.  
   Você deverá ver os 50 componentes listados acima.

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
  FRMaterial3DataGrid,   { DataGrid (TStringGrid) }
  FRMaterial3PageControl, { PageControl com abas }
  FRMaterial3VirtualDataGrid, { Grid virtual com filtro/sort }
  FRMaterial3Card,       { Card (Filled, Outlined, Elevated) }
  FRMaterial3Badge,      { Badge (Dot, Count) }
  FRMaterial3Carousel,   { Carousel horizontal }
  FRMaterial3DatePicker,  { Seletor de data calendário }
  FRMaterialThemeManager, { Gerenciador de tema }
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
| `Density` | `TFRMDDensity` | `ddNormal` | Compactação vertical: Normal, Compact (−4px), Dense (−8px), UltraDense (−12px) |
| `ReadOnly` | `Boolean` | `False` | Impede edição pelo usuário |
| `MaxLength` | `Integer` | `0` | Máximo de caracteres (0 = ilimitado) |
| `EchoMode` | `TEchoMode` | `emNormal` | Use `emPassword` para campos de senha |
| `PasswordChar` | `Char` | `#0` | Caractere de máscara para modo senha |
| `CharCase` | `TEditCharCase` | `ecNormal` | Forçar maiúsculas/minúsculas |
| `NumbersOnly` | `Boolean` | `False` | Aceitar apenas entrada numérica |
| `AutoSelect` | `Boolean` | `True` | Selecionar tudo ao receber foco |
| `LabelSpacing` | `Integer` | `4` | Pixels entre o label e o campo |
| `ShowLeadingIcon` | `Boolean` | `False` | Exibe ícone à esquerda do campo |
| `LeadingIconMode` | `TFRIconMode` | `imClear` | Ícone SVG do leading icon |
| `PasswordMode` | `Boolean` | `False` | Ativa campo de senha com botão olho (toggle visibilidade) |
| `ShowCopyButton` | `Boolean` | `False` | Exibe botão de copiar texto |
| `ShowCharCounter` | `Boolean` | `False` | Exibe contador de caracteres (requer `MaxLength > 0`) |
| `MinLength` | `Integer` | `0` | Comprimento mínimo para validação |
| `ValidateMode` | `TFRMDValidateMode` | `vmOnExit` | Quando validar: ao sair do campo ou a cada tecla |
| `ValidationState` | `TFRMDValidationState` | `vsNone` | Estado atual: `vsNone`, `vsValid`, `vsInvalid` |
| `ValidColor` | `TColor` | — | Cor do sublinhado quando válido |
| `InvalidColor` | `TColor` | — | Cor do sublinhado quando inválido |
| `PrefixText` | `string` | `''` | Texto prefixo exibido antes do valor (ex.: `R$`) |
| `SuffixText` | `string` | `''` | Texto sufixo exibido após o valor (ex.: `kg`) |
| `AutoFocusNext` | `Boolean` | `False` | Avança para o próximo campo ao completar máscara |
| `Locked` | `Boolean` | `False` | Impede edição com visual diferenciado de ReadOnly |
| `LockedColor` | `TColor` | — | Cor do campo quando bloqueado |
| `ShowValidationDialog` | `Boolean` | `False` | Exibe diálogo de erro ao sair do campo inválido |
| `AutoFontSize` | `Boolean` | `False` | Ajusta tamanho da fonte automaticamente |
| `TextMask` | `TFRTextMaskType` | `tmtNone` | Máscara PT-BR automática (CPF, CNPJ, CEP, Telefone, etc.) |
| `InputFilter` | `TFRInputFilter` | `ifNone` | Filtro de entrada: `ifNone`, `ifDigits`, `ifLetters`, `ifAlphanumeric`, `ifCustom` |
| `AllowedChars` | `string` | `''` | Caracteres permitidos quando `InputFilter = ifCustom` |
| `NumericMask` | `TFRNumericMaskType` | `nmtNone` | Formatação numérica automática (moeda, decimal, inteiro) |
| `NumericValue` | `Currency` | `0` | Valor numérico quando `NumericMask` está ativo |
| `AutoCompleteEnabled` | `Boolean` | `False` | Habilita popup de autocomplete |
| `IconStrokeWidth` | `Single` | `2.0` | Espessura do traço dos ícones SVG |
| `EditLabel` | `TBoundLabel` | — | Acesso direto ao label interno |
| `ClearButton` | `TButton` | — | Acesso direto ao botão de limpeza (somente leitura) |
| `SearchButton` | `TBitBtn` | — | Acesso direto ao botão de pesquisa (somente leitura) |
| `LeadingIcon` | `TButton` | — | Acesso direto ao botão leading icon (somente leitura) |
| `EyeButton` | `TButton` | — | Acesso direto ao botão olho (somente leitura) |
| `CopyButton` | `TButton` | — | Acesso direto ao botão copiar (somente leitura) |

### Eventos principais

| Evento | Descrição |
|---|---|
| `OnChange` | Disparado a cada alteração do texto |
| `OnClick` | Clique no campo |
| `OnEnter` / `OnExit` | Campo recebe / perde foco |
| `OnKeyDown`, `OnKeyPress`, `OnKeyUp` | Eventos de teclado padrão |
| `OnUTF8KeyPress` | Tecla pressionada (string UTF-8) |
| `OnClearButtonClick` | Botão `×` foi clicado |
| `OnSearchButtonClick` | Botão de pesquisa foi clicado |
| `OnLeadingIconClick` | Leading icon foi clicado |
| `OnValidate` | Callback de validação customizada |
| `OnAutoCompleteSelect` | Item selecionado no popup de autocomplete |
| `OnEditingDone` | Edição confirmada (Enter ou perda de foco) |

### Exemplo

```pascal
{ Campo de e-mail básico }
FRMaterialEdit1.Caption         := 'E-mail';
FRMaterialEdit1.TextHint        := 'usuario@exemplo.com';
FRMaterialEdit1.AccentColor     := RGBToColor(33, 150, 243);
FRMaterialEdit1.ShowClearButton  := True;
FRMaterialEdit1.ShowSearchButton := True;

{ Campo com leading icon e validação }
FRMaterialEdit2.Caption         := 'Usuário';
FRMaterialEdit2.ShowLeadingIcon  := True;
FRMaterialEdit2.LeadingIconMode  := imPerson;
FRMaterialEdit2.MinLength        := 3;
FRMaterialEdit2.ValidateMode     := vmOnExit;

{ Campo de senha com toggle de visibilidade }
FRMaterialEdit3.Caption      := 'Senha';
FRMaterialEdit3.PasswordMode := True;

{ Campo com máscara de CPF e auto-avanço }
FRMaterialEdit4.Caption       := 'CPF';
FRMaterialEdit4.TextMask      := tmtCPF;
FRMaterialEdit4.AutoFocusNext  := True;

{ Campo com autocomplete }
FRMaterialEdit5.AutoCompleteEnabled := True;
FRMaterialEdit5.AutoCompleteItems.CommaText := 'São Paulo,Rio de Janeiro,Belo Horizonte';
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

{ Campo preenchido — cantos superiores arredondados (spec MD3) }
FRMaterialEdit1.Variant      := mvFilled;
FRMaterialEdit1.Color        := $00F5F5F5;
FRMaterialEdit1.BorderRadius := 4;
{ Nota: mvFilled agora usa apenas os cantos superiores arredondados,
  conforme a especificação MD3 oficial. }
```

### Density — compactação vertical

A propriedade `Density: TFRMDDensity` ajusta a altura dos campos e botões para formulários compactos.
Equivalente ao density scale do MD3 (0 a −3).

| Valor | Delta | Altura típica do botão |
|---|---|---|
| `ddNormal` | 0px | 40px (padrão MD3) |
| `ddCompact` | −4px | 36px |
| `ddDense` | −8px | 32px |
| `ddUltraDense` | −12px | 28px |

```pascal
{ Formulário compacto — ideal para telas com muitos campos }
FRMaterialEdit1.Density   := ddCompact;
FRMaterialButton1.Density := ddCompact;
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

## TFRMaterialThemeManager

Componente **não-visual** para troca de tema Light/Dark em runtime sem reiniciar a aplicação.
Drope-o em qualquer formulário e configure as propriedades no Object Inspector.

| Propriedade | Tipo | Padrão | Descrição |
|---|---|---|---|
| `Palette` | `TFRMDPalette` | `mpBaseline` | Paleta nomeada (usada quando `UseSeed = False`) |
| `DarkMode` | `Boolean` | `False` | `True` = esquema escuro, `False` = claro |
| `SeedColor` | `TColor` | `$006750A4` | Cor-semente para geração algorítmica |
| `UseSeed` | `Boolean` | `False` | Quando `True`, ignora `Palette` e usa `SeedColor` |

### Método

| Método | Descrição |
|---|---|
| `Apply` | Reaplicar o tema atual explicitamente |

### Exemplo

```pascal
uses FRMaterialThemeManager;

// Mudar para dark mode
ThemeManager1.DarkMode := True;

// Trocar paleta
ThemeManager1.Palette := mpBlue;

// Gerar esquema a partir de cor personalizada
ThemeManager1.SeedColor := RGBToColor(0, 98, 155);
ThemeManager1.UseSeed   := True;

// Forçar reaplicação sem mudança de property
ThemeManager1.Apply;
```

> Ao mudar qualquer propriedade, o ThemeManager atualiza `MD3Colors` globalmente
> e invalida automaticamente todos os formulários visíveis.

---

## Ícones disponíveis (`TFRIconMode`)

O pacote inclui **81 ícones SVG** organizados por categoria:

### Gerais
`imClear`, `imSearch`, `imCalendar`, `imEyeOpen`, `imEyeClosed`, `imCopy`,
`imPlus`, `imMinus`, `imHome`, `imMenu`, `imArrowBack`, `imArrowForward`,
`imMoreVert`, `imCheck`, `imEdit`, `imDelete`, `imShare`, `imStar`,
`imFavorite`, `imSettings`, `imPerson`, `imNotification`, `imMail`,
`imDownload`, `imUpload`, `imRefresh`, `imFilter`, `imAttach`, `imLink`,
`imNightlight`, `imLightMode`, `imList`, `imDashboard`,
`imExpandMore`, `imExpandLess`, `imFolder`, `imFolderOpen`,
`imWarning`, `imInfo`, `imError`, `imSuccess`, `imHelp`

### Segurança
`imLock`, `imShield`

### Financeiro
`imMoney`, `imCreditCard`, `imWallet`, `imReceipt`,
`imBarChart`, `imPieChart`, `imTrendUp`, `imTrendDown`,
`imPercent`, `imBank`, `imCalculator`, `imCoin`,
`imAccountBalance`, `imCashFlow`, `imTax`, `imInvoice`

### Estoque / Logística
`imBox`, `imBarcode`, `imTruck`, `imWarehouse`,
`imTag`, `imShoppingCart`, `imScale`,
`imLocalShipping`, `imRoute`, `imInventory`

### Negócio / ERP
`imStore`, `imStorefront`, `imHandshake`, `imFactory`,
`imQrCode`, `imPrinter`, `imClipboard`, `imAssignment`,
`imReport`, `imFile`, `imKpi`

### Uso em campos de entrada

```pascal
{ Campo de usuário }
FRMaterialEdit1.ShowLeadingIcon  := True;
FRMaterialEdit1.LeadingIconMode  := imPerson;

{ Campo de senha }
FRMaterialEdit2.PasswordMode     := True;

{ Botão com ícone de pagamento }
FRMaterialButton1.ShowIcon  := True;
FRMaterialButton1.IconMode  := imCreditCard;

{ FAB com ícone de relatório }
FRMaterialFAB1.IconMode := imReport;

{ Chip com ícone de filtro }
FRMaterialChip1.ShowIcon := True;
FRMaterialChip1.IconMode := imFilter;
```

---

## Licença

LGPL v3 — mesma licença do [BGRAControls](https://github.com/bgrabitmap/bgracontrols).

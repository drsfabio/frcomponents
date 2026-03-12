# Componentes Material Design para Lazarus

Componentes de entrada com estilo Material Design para Lazarus / Free Pascal, integrados ao pacote [BGRAControls](https://github.com/bgrabitmap/bgracontrols). Licenciado sob **LGPL v3**.

## Visão geral

Este pacote fornece quatro controles de entrada no estilo Material Design que encapsulam widgets padrão da LCL, adicionando:

- **Label flutuante** — o rótulo sobe acima do campo ao receber foco ou quando preenchido
- **Sublinhado Material** — linha fina em repouso, linha dupla colorida com foco
- **AccentColor** — cor personalizável usada no sublinhado e no label com foco
- **API consistente** — todos os controles seguem as mesmas convenções visuais

| Componente | Encapsula | Uso |
|---|---|---|
| `TBCMaterialEdit` | `TEdit` | Campo de texto simples |
| `TBCMaterialComboEdit` | `TComboBox` | Lista suspensa / combo editável |
| `TBCMaterialCheckComboEdit` | `TCheckListBox` (popup) | Seleção múltipla com checkboxes |
| `TBCMaterialDateEdit` | `TDateEdit` | Seletor de data com calendário popup |

---

## ⚠️ Aviso de conflito — usuários do BGRAControls

Este pacote é um **fork** das units Material Design originalmente incluídas no [BGRAControls](https://github.com/bgrabitmap/bgracontrols).

Se você tem o **BGRAControls instalado**, esteja ciente de que:

- O BGRAControls já inclui uma unit chamada `BCMaterialEdit`. Instalar este pacote junto com o BGRAControls causará **nomes de unit duplicados**, gerando erros de compilação como `Duplicate identifier` ou `Unit already used`.
- Os nomes das classes de componente (`TBCMaterialEdit`, etc.) são os mesmos, portanto os dois pacotes **não podem ser instalados ao mesmo tempo**.

### Abordagem recomendada

| Cenário | Ação |
|---|---|
| Você usa o BGRAControls apenas pelos componentes Material Design | Remova as units Material Design da sua instalação do BGRAControls (ou use este pacote no lugar delas). |
| Você usa o BGRAControls por outros controles (BGRASpeedButton, etc.) | Mantenha o BGRAControls instalado, mas **exclua** as units em conflito: no editor do pacote BGRAControls, remova `BCMaterialEdit` da lista de arquivos antes de instalar este pacote. |
| Você está iniciando um projeto novo | Instale apenas este pacote — ele já declara dependência direta do `BGRABitmapPack` e não requer o BGRAControls completo. |

> **Observação:** A reversão é sempre segura — você pode desinstalar este pacote e voltar à versão do BGRAControls a qualquer momento sem alterar o código-fonte do seu projeto, pois ambos expõem os mesmos nomes de classe e propriedades publicadas.

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
   As quatro units (`BCMaterialEdit`, `BCMaterialComboEdit`, `BCMaterialCheckComboEdit`, `BCMaterialDateEdit`) devem compilar sem erros.

3. **Instalar**  
   Ainda no Editor de Pacotes, clique em **Usar → Instalar**.  
   O Lazarus pedirá confirmação para reconstruir o IDE — confirme com **Sim**.

4. **Verificar**  
   Após o IDE reiniciar, abra a **Paleta de Componentes** e procure pela aba **Material Design**.  
   Você deverá ver:
   - `TBCMaterialEdit`
   - `TBCMaterialComboEdit`
   - `TBCMaterialCheckComboEdit`
   - `TBCMaterialDateEdit`

### Adicionando ao projeto sem instalar na paleta

Se preferir não instalar na paleta do IDE, adicione o pacote como dependência do seu projeto:

1. No seu projeto, abra **Projeto → Inspetor de Projeto**.
2. Clique em **Adicionar → Novo Requisito** e escolha `materialdesign`.
3. Adicione as units necessárias na cláusula `uses` de cada formulário:

```pascal
uses
  BCMaterialEdit,
  BCMaterialComboEdit,
  BCMaterialCheckComboEdit,
  BCMaterialDateEdit;
```

### Desinstalando

1. **Pacote → Pacotes Instalados** → selecione `materialdesign` → clique em **Desinstalar**.
2. Confirme a reconstrução do IDE.

---

## TBCMaterialEdit

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

### Eventos principais

`OnChange`, `OnClick`, `OnEnter`, `OnExit`, `OnKeyDown`, `OnKeyPress`, `OnKeyUp`, `OnClearButtonClick`, `OnEditingDone`, `OnUTF8KeyPress`

### Exemplo

```pascal
BCMaterialEdit1.Caption         := 'E-mail';
BCMaterialEdit1.TextHint        := 'usuario@exemplo.com';
BCMaterialEdit1.AccentColor     := RGBToColor(33, 150, 243);
BCMaterialEdit1.ShowClearButton := True;
```

---

## TBCMaterialComboEdit

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
| `Sorted` | `Boolean` | `False` | Ordenar itens alfabeticamente |
| `AutoComplete` | `Boolean` | `True` | Autocompletar enquanto digita |
| `DropDownCount` | `Integer` | — | Número de linhas visíveis na lista |
| `MaxLength` | `Integer` | `0` | Máximo de caracteres no modo editável |
| `ReadOnly` | `Boolean` | `False` | Desabilitar edição no modo `csDropDown` |
| `LabelSpacing` | `Integer` | `4` | Pixels entre o label e o campo |

### Eventos principais

`OnChange`, `OnEnter`, `OnExit`, `OnKeyDown`, `OnKeyPress`, `OnKeyUp`, `OnEditingDone`

### Exemplo

```pascal
BCMaterialComboEdit1.Caption       := 'País';
BCMaterialComboEdit1.Items.CommaText := 'Brasil,Argentina,Chile';
BCMaterialComboEdit1.Style         := csDropDownList;
BCMaterialComboEdit1.AccentColor   := RGBToColor(76, 175, 80);
```

---

## TBCMaterialCheckComboEdit

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
BCMaterialCheckComboEdit1.Caption       := 'Permissões';
BCMaterialCheckComboEdit1.Items.CommaText := 'Ler,Gravar,Executar';
BCMaterialCheckComboEdit1.DisplayFormat := cdfCountAndFirst;
BCMaterialCheckComboEdit1.EmptyText     := '(nenhum selecionado)';
BCMaterialCheckComboEdit1.Checked[0]   := True;
```

---

## TBCMaterialDateEdit

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
BCMaterialDateEdit1.Caption         := 'Data de nascimento';
BCMaterialDateEdit1.DateOrder       := doDMY;
BCMaterialDateEdit1.DirectInput     := False;
BCMaterialDateEdit1.AccentColor     := RGBToColor(156, 39, 176);
BCMaterialDateEdit1.ShowClearButton := True;
```

---

## Comportamento comum

Todos os quatro controles compartilham as mesmas convenções visuais:

- **Em repouso**: sublinhado cinza fino abaixo do campo.
- **Com foco**: o sublinhado engrossa e assume a `AccentColor`; o label flutuante sobe para o topo e também fica em `AccentColor`.
- **Desabilitado**: o sublinhado usa a `DisabledColor`.
- A classe base `TBCMaterialEditBase<T>` é genérica; `T` é o controle LCL encapsulado.

---

## Licença

LGPL v3 — mesma licença do [BGRAControls](https://github.com/bgrabitmap/bgracontrols).

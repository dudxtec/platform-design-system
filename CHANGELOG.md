## 0.3.3

Primeira entrega do plano de listas mobile (botão flutuante, filtros compactos e
revisão de contraste do escuro).

### Muda o comportamento

* `DsButton` `danger` usa o novo token `dangerSolid` com texto `onFill` (branco). No tema claro o valor não muda (vermelho 800). No escuro passa de vermelho 300 com texto escuro para vermelho 900 com texto branco (6,6:1). Hover e pressionado agora escurecem o fundo em 16% (antes usavam `dangerTone.text`, que no escuro era mais claro).
* Chip selecionado (`FilterChip`, `ChoiceChip` e similares) ganha borda de 2 px na cor primária e ✓ antes do rótulo. Só o fundo `surfaceSelected` dá 1,15:1 contra a superfície e não bastava. A borda do chip não selecionado continua 1 px em `borderStrong`.
* `DsTheme` fixa `materialTapTargetSize: padded`, para chips de 32 px e links de 36 px terem área de toque de 44 px ou mais.

### Adicionado

* Tokens em `DsColorTokens`: `dangerSolid`, `successSolid`, `fab` e `onFill`. São opcionais no construtor (padrão do tema claro), então temas próprios continuam compilando. `dangerTone.solid` e `successTone.solid` ficam para ícones, barras e bordas, que precisam do tom mais claro no escuro.
* `DsButtonVariant.success`: botão preenchido de confirmação, com `successSolid` e texto branco (5,1:1).
* `DsActionFab` e `DsFabAction`: botão flutuante de ações das listas, igual na web e no app. Uma ação executa direto; duas ou mais abrem um menu (celular: sobre fundo escurecido, primeira ação mais perto do polegar; acima de 600 px: menu ancorado, com opções que abrem dentro dele). Esc e toque fora fecham e o foco volta ao botão; some com o teclado aberto; respeita a área segura; `endOffset` desloca o botão para não cobrir um painel de detalhe. `DsActionFab.listBottomInset` (104 px) é a folga para o fim da lista.

## 0.3.2

### Muda o comportamento

* `DsAppShell`: a barra superior tem 48 px no celular (abaixo de `DsBreakpoints.mobile`), qualquer que seja a densidade. Em telas maiores continua 56 px (confortável) ou 48 px (compacta).

## 0.3.1

Correções do `DsDateField` encontradas ao aplicar a 0.3.0 nos portais, todas
ligadas ao uso com mouse.

### Corrigido

* Clicar dentro do calendário tirava o foco do campo. Quem salvava ao perder o foco gravava a data antiga antes da escolhida.
* Depois de um clique no calendário, Esc deixava de fechá-lo; dentro de um diálogo, fechava o diálogo.
* `DsPagination` estourava em telas de 320 px com muitas páginas: abaixo de 400 px saem os botões de primeira e última página e o rótulo vira "100 / 1000".

### Muda o comportamento

* Esc no calendário desfaz o que foi alterado desde a abertura (relevante no modo com hora, em que escolher o dia não fecha). Clicar fora mantém a alteração.

### Adicionado

* `DsDateField.onCommitted`: avisa quando a edição terminou e o valor mudou (escolha no calendário, Enter, ou foco saindo do campo e do calendário). É o gancho para salvar ao alterar; substitui ouvir o `focusNode`.
* `DsDateField.compact`: sem rótulo flutuante e com 32 px, para célula de tabela (`DsDateField.compactMinWidth`).
* `DsDateField.calendarInitialDate` e `prefixIcon`; `DsCalendar.initialMonth`.
* `DsButtonSize.lg` (sempre 44 px) e `DsPagination.touch`, para layouts de toque acima de 900 px.

## 0.3.0

Ajustes encontrados ao aplicar a 0.2.0 nos portais.

### Muda o comportamento

* `DsDateField` não reescreve mais o texto durante a digitação: o cursor fica onde está ao editar no meio da data, e datas incompletas são permitidas até a validação. O separador só é acrescentado quando se digita no fim do texto. `DsDateInputFormatter` segue a mesma regra.
* `DsToast` é desenhado na camada raiz, acima de diálogos e gavetas (antes ficava atrás de diálogos altos). Ganhou botão de fechar e `DsToast.dismiss()`. Não usa mais `SnackBar`.
* `DsButton` no tamanho padrão e os botões do `DsPagination` passam a 44 px abaixo de 900 px de largura (alvo de toque).

### Adicionado

* `DsDateField`: `withTime` e `showSeconds` (data e hora, com campo de hora no calendário), `controller` e `focusNode` externos, `onPicked` (data escolhida no calendário). Aceita também `aaaa-mm-dd` e oito dígitos, exibidos como `dd/mm/aaaa` ao sair do campo.
* `DsDate.tryParseDateTime`, `tryParseTime` e `formatDateTime`.
* `DsSectionCard`: `collapsible`, `initiallyExpanded`, `onExpansionChanged`.
* `DsErrorState.secondaryAction`.
* `DsKpiCard.progress` e `progressTone` (parte de um total).
* `DsFilterBar.applying`.
* `DsPage.padding`.

### Corrigido

* Esc não fechava o calendário quando ele era aberto pelo ícone.
* `DsAlert` com ação espremia o texto em telas estreitas: a ação agora vai para baixo do texto.
* `DsPageHeader` limita o título a duas linhas.
* Documentação do `DsDataTable`: o cabeçalho das colunas rola com as linhas; só a barra de ferramentas e a paginação ficam fixas.

## 0.2.0

Fundação do design system. Ver `docs/`.

### Muda a aparência de quem usa `DsTheme`

* Top bar com fundo `surface`, título em cor de texto e borda inferior (antes fundo cinza e título teal).
* `OutlinedButton` neutro (antes contorno e texto teal).
* `FilledButton` e `TextButton` passam a ter tema; `FilledButton` fica igual ao `ElevatedButton`.
* Botões com 40 px de altura e padding horizontal de 16 (antes 24 x 12).
* Campos com 40 px, borda `borderStrong` (3:1) e estados de erro e desabilitado.
* Tipografia com altura de linha definida e sem espaçamento entre letras no corpo; `titleMedium` em peso 600.
* `colorScheme.secondaryContainer` deixa de derivar do laranja.
* Tema escuro refeito sobre tokens próprios.

### Adicionado

* `DsPalette`: escalas 50–900 de teal, laranja, neutro, verde, vermelho, âmbar e azul.
* `DsColorTokens` (`context.dsColors`): tokens semânticos como `ThemeExtension`, claro e escuro, com tons (`DsTone`).
* `DsSizes`, `DsElevation`, `DsLayer`, `DsMotion`; `DsSpacing.s2`–`s80`; `DsRadius.none` e `xs`.
* Estilos `DsTypography.table`, `tableHeader`, `menu`, `kpi`, `code`.
* Temas de diálogo, bottom sheet, drawer, snackbar, tooltip, abas, chip, tabela, menus, seletor de data, progresso, lista e barra de rolagem.
* Componentes: `DsButton`, `DsBadge`, `DsAlert`, `DsToast`, `DsConfirmDialog`, `DsEmptyState`, `DsErrorState`, `DsLoadingState`, `DsAppShell`, `DsPage`, `DsPageHeader`, `DsBreadcrumb`, `DsSectionCard`, `DsKpiCard`, `DsPagination`, `DsFilterBar`, `DsDataTable`, `DsFormGrid`, `DsFieldLabel`, `DsFormActions`.
* `DsDateField`, `DsDateRangeField` e `DsCalendar`: campo de data com máscara e calendário em popover.
* `DsDensity` e `DsDensityScope`: densidade compacta automática em viewports com menos de 800 px de altura (notebooks de 14 e 15 polegadas).
* `DsAppShell`: sidebar começa recolhida abaixo de 1280 px; `sidebarCollapsed` e `onSidebarCollapsedChanged` para guardar a preferência.
* `DsBreakpoints.wide` e `DsBreakpoints.shortHeight`.
* Galeria em `example/` e documentação em `docs/`.
* Testes de contraste WCAG AA sobre os tokens semânticos.

### Obsoleto

* `DsPrimaryButton` e `DsOutlinedButton`: use `DsButton`.
* `DsColors` em código novo: use `context.dsColors`.

### Corrigido

* Três testes de responsividade que falhavam em `main` (redimensionavam o `MediaQuery` em vez da superfície).
* `DsStatChip` agora é lido como um único item por leitores de tela.

## 0.1.0

* Estrutura inicial do design system com tokens (`DsColors`, `DsSpacing`, `DsRadius`, `DsTypography`), tema (`DsTheme.light()` e `DsTheme.dark()`) e componentes base (`DsPrimaryButton`, `DsOutlinedButton`, `DsStatChip`).
* Adicionado token `DsColors.inputFill` para substituir cor hardcoded no tema.
* Adicionados tokens de dark mode em `DsColors` (`backgroundDark`, `surfaceDark`, `cardDark`, `dividerDark`, `textPrimaryDark`, `textSecondaryDark`, `textDisabledDark`, variantes de sidebar).
* Adicionados tokens `DsSpacing.xxxl` (48) e `DsSpacing.xxxxl` (64).
* Adicionado `DsTypography.darkTextTheme` para uso no tema escuro.
* Adicionado `DsTheme.dark()`.
* Criado `DsOutlinedButton`, par do `DsPrimaryButton`.
* Corrigido uso de `Colors.white` em `DsStatChip` para `DsColors.textOnPrimary`.
* Ampliada cobertura de testes.

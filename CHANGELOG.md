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

# 3. Design tokens

Os tokens têm duas camadas:

1. **Primitivos** (`DsPalette`, `DsSpacing`, `DsRadius`...): valores brutos.
2. **Semânticos** (`DsColorTokens`, lido com `context.dsColors`): o papel que a
   cor cumpre, resolvido para o tema claro ou escuro.

Telas e componentes usam só a camada semântica. `DsColors` continua existindo
para os consumidores atuais, mas é estático e não acompanha o tema.

## 3.1 Paleta primitiva

`lib/src/tokens/ds_palette.dart`

| Passo | Teal (marca) | Laranja (destaque) | Neutro | Verde | Vermelho | Âmbar | Azul |
|---|---|---|---|---|---|---|---|
| 25 | | | `#F8F9FC` | | | | |
| 50 | `#E5F2F2` | `#FFF4E5` | `#F4F6F9` | `#E8F5E9` | `#FFEBEE` | `#FFFBEB` | `#E1F5FE` |
| 100 | `#C2E0E0` | `#FFE2BF` | `#EBEEF2` | `#C8E6C9` | `#FFCDD2` | `#FEF3C7` | `#B3E5FC` |
| 200 | `#99CCCC` | `#FFCE94` | `#E1E7ED` | `#A5D6A7` | `#EF9A9A` | `#FDE68A` | `#81D4FA` |
| 300 | `#66B2B3` | `#FFB866` | `#CBD3DC` | `#81C784` | `#E57373` | `#FCD34D` | `#4FC3F7` |
| 400 | `#339C9D` | `#FFA333` | `#8592A0` | `#66BB6A` | `#EF5350` | `#FBBF24` | `#29B6F6` |
| 500 | `#1A8A8B` | `#FF9100` | `#6B7785` | `#43A047` | `#F44336` | `#F59E0B` | `#039BE5` |
| 600 | `#007172` | `#E07E00` | `#52606D` | `#388E3C` | `#E53935` | `#D97706` | `#0288D1` |
| 700 | `#005A5B` | `#B86500` | `#3E4C59` | `#2E7D32` | `#D32F2F` | `#B45309` | `#0277BD` |
| 800 | `#004445` | `#8F4E00` | `#1F2933` | `#1B5E20` | `#C62828` | `#92400E` | `#01579B` |
| 900 | `#003031` | `#663800` | `#12181F` | `#124116` | `#B71C1C` | `#78350F` | `#014374` |
| 950 | | | `#0F1214` | | | | |

Os valores que já estavam em produção foram mantidos: teal 600, 700 e 500
(antigos `primary`, `primaryDark`, `primaryLight`), laranja 500, neutros 50,
200, 500 e 800, verde 700, vermelho 800.

## 3.2 Papéis de cor

| Papel | Token | Claro | Escuro | Uso |
|---|---|---|---|---|
| Primary | `primary` | teal 600 | teal 400 | Ação principal, link, seleção, foco |
| | `primaryHover` / `primaryPressed` | teal 700 / 800 | teal 300 / 200 | Estados do botão primário |
| Secondary | `borderStrong` + `surface` | neutro 400 | neutro 500 | Botão secundário é neutro, não colorido |
| Accent | `accent` / `onAccent` | laranja 500 / neutro 900 | laranja 500 / neutro 950 | Destaque de marca, raro; nunca estado |
| Success | `successTone` | verde 700 | verde 400 | Concluído, pago, ativo |
| Warning | `warningTone` | âmbar 500 | âmbar 400 | Atenção, pendente, prazo próximo |
| Error | `dangerTone` | vermelho 800 | vermelho 300 | Falha, vencido, ação destrutiva |
| Info | `infoTone` | azul 700 | azul 300 | Contexto neutro, em andamento |
| Neutral | `neutralTone`, `text*`, `surface*`, `border` | escala neutra | escala neutra | Texto, superfícies, separadores |

Cada tom tem cinco valores: `solid`, `onSolid`, `text`, `subtle`, `border`.

### Superfícies e texto

| Token | Claro | Escuro | Uso |
|---|---|---|---|
| `canvas` | `#F4F6F9` | `#0F1214` | Fundo da página |
| `surface` | `#FFFFFF` | `#1A1E21` | Cartões, sidebar, top bar, diálogos, menus |
| `surfaceSubtle` | `#F8F9FC` | `#1F2428` | Cabeçalho de tabela, fundo de campo |
| `surfaceHover` | `#EBEEF2` | `#252B30` | Linha ou item sob o cursor; campo desabilitado |
| `surfaceSelected` | `#E5F2F2` | `#003D3E` | Linha ou item selecionado |
| `surfaceInverse` | `#1F2933` | `#E8ECF0` | Tooltip e toast |
| `border` | `#E1E7ED` | `#2D3740` | Separadores e contorno de cartão |
| `borderStrong` | `#8592A0` | `#6B7785` | Contorno de campo e de botão secundário |
| `textPrimary` | `#1F2933` | `#E8ECF0` | Texto e títulos |
| `textSecondary` | `#52606D` | `#B4BDC7` | Apoio, cabeçalho de tabela, rótulos |
| `textTertiary` | `#6B7785` | `#9AA5B1` | Placeholder e legenda, só sobre `surface` |
| `textDisabled` | `#8592A0` | `#6B7785` | Desabilitado |
| `focusRing` | teal 500 | teal 300 | Foco de teclado |

### Contraste

Calculado pela fórmula WCAG 2.1. O arquivo `test/foundation_test.dart` falha se
algum par semântico cair abaixo do mínimo, em qualquer dos dois temas.

| Par (tema claro) | Razão | Mínimo |
|---|---|---|
| `textPrimary` sobre `surface` / `canvas` | 14,8 / 13,6 | 4,5 |
| `textSecondary` sobre `surface` / `canvas` | 6,5 / 6,0 | 4,5 |
| `textTertiary` sobre `surface` | 4,6 | 4,5 |
| `onPrimary` sobre `primary` / `primaryHover` | 5,8 / 8,0 | 4,5 |
| `primary` como texto sobre `surface` | 5,8 | 4,5 |
| `onAccent` sobre `accent` | 7,9 | 4,5 |
| Branco sobre `accent` (proibido) | 2,3 | 4,5 |
| `borderStrong` sobre `surface` | 3,2 | 3,0 |
| Sucesso: `text` sobre `subtle` / `onSolid` sobre `solid` | 7,0 / 5,1 | 4,5 |
| Aviso: `text` sobre `subtle` / `onSolid` sobre `solid` | 6,8 / 8,3 | 4,5 |
| Erro: `text` sobre `subtle` / `onSolid` sobre `solid` | 5,8 / 5,6 | 4,5 |
| Info: `text` sobre `subtle` | 6,6 | 4,5 |

| Par (tema escuro) | Razão |
|---|---|
| `textPrimary` sobre `surface` | 14,1 |
| `textSecondary` sobre `surface` | 8,8 |
| `textTertiary` sobre `surface` | 6,7 |
| `onPrimary` sobre `primary` | 5,7 |
| `primary` como texto sobre `surface` | 5,1 |
| `borderStrong` sobre `surface` | 3,7 |

Valores antigos que **não** passam e por isso não entraram nos tokens
semânticos: `DsColors.textDisabled` `#9AA5B1` (2,5), `DsColors.warning`
`#ED6C02` como texto (3,1), `DsColors.info` `#0288D1` como texto (3,9).

### Gráficos

`DsPalette.chart` traz 8 cores categóricas na ordem de uso. Acima de 6 séries,
agrupe em "Outros". Série única usa `primary`. Positivo e negativo usam os tons
de sucesso e erro, sempre com rótulo.

## 3.3 Tipografia

`lib/src/tokens/ds_typography.dart`

- **Principal:** Roboto. É a fonte que o Flutter Web já entrega, então não há
  download extra nem troca de fonte durante o carregamento, e tem algarismos
  tabulares.
- **Secundária:** monoespaçada do sistema (`Roboto Mono`, `Consolas`, `Menlo`),
  só para identificadores e valores brutos.
- Base de 14 px. Tudo que é texto corrido fica entre 12 e 16 px.

| Papel | Slot / getter | Tamanho / linha | Peso | Uso |
|---|---|---|---|---|
| Display | `headlineLarge` | 32 / 40 | 700 | Número de destaque em página cheia; login |
| H1 | `headlineMedium` | 24 / 32 | 600 | Título de página |
| H2 | `headlineSmall` | 20 / 28 | 600 | Título de diálogo |
| H3 | `titleLarge` | 18 / 26 | 600 | Título na top bar |
| H4 | `titleMedium` | 16 / 24 | 600 | Título de seção e de cartão |
| Subtítulo | `titleSmall` | 14 / 20 | 600 | Abas, título de alerta |
| Body grande | `bodyLarge` | 16 / 24 | 400 | Texto de leitura em páginas públicas |
| Body | `bodyMedium` | 14 / 20 | 400 | Texto padrão, campos |
| Caption | `bodySmall` | 12 / 16 | 400 | Ajuda, erro de campo, metadados |
| Botão | `labelLarge` | 14 / 20 | 600 | Rótulo de botão |
| Label | `labelMedium` | 13 / 18 | 500 | Rótulo de campo, breadcrumb, chip |
| Overline | `labelSmall` | 11 / 16 | 600 | Título de grupo na sidebar (maiúsculas) |
| Table | `DsTypography.table` | 13 / 20 | 400 | Célula; algarismos tabulares |
| Table header | `DsTypography.tableHeader` | 12 / 16 | 600 | Cabeçalho de coluna |
| Menu | `DsTypography.menu` | 14 / 20 | 500 | Item de sidebar e de menu |
| KPI | `DsTypography.kpi` | 28 / 36 | 600 | Número do cartão de métrica |
| Code | `DsTypography.code` | 13 / 20 | 400 | Identificadores |

Regras: no máximo três tamanhos por tela além do título; peso 600 para
hierarquia, nunca 800; sem itálico; maiúsculas só no overline.

## 3.4 Espaçamento

`lib/src/tokens/ds_spacing.dart`. Grade de 4 px.

| Token | px | Quando usar |
|---|---|---|
| `s2` | 2 | Entre um ícone e seu próprio rótulo em badges |
| `s4` | 4 | Entre elementos inline colados (ícone e texto) |
| `s8` | 8 | Entre controles do mesmo grupo (botões lado a lado) |
| `s12` | 12 | Padding interno de campo e de linha densa; entre filtros |
| `s16` | 16 | Padrão: padding de cartão, entre campos, margem da página no celular |
| `s24` | 24 | Margem da página no desktop; entre cartões e seções |
| `s32` | 32 | Entre blocos de uma página |
| `s40` | 40 | Entre regiões principais |
| `s48` | 48 | Padding vertical de estados vazios e de erro |
| `s64` | 64 | Respiro em páginas avulsas (login, 404) |
| `s80` | 80 | Máximo; estados de página cheia |

Regra de proximidade: o espaço dentro de um grupo é sempre menor que o espaço
entre grupos. Os nomes antigos (`xxs` a `xxxxl`) continuam válidos; `lg` (20)
está fora da escala e não deve ser usado em código novo.

## 3.5 Raios

| Token | px | Uso |
|---|---|---|
| `none` | 0 | Gaveta lateral, barras de borda a borda |
| `xs` | 4 | Tooltip, checkbox, variação de KPI |
| `sm` | 8 | Controles: botão, campo, menu, toast |
| `md` | 12 | Contêineres: cartão, diálogo |
| `lg` | 16 | Bottom sheet |
| `pill` | 999 | Badge, chip, avatar |

## 3.6 Bordas, elevação e sombras

Superfícies são planas: `surface` com borda de 1 px em `border`. Sombra só para
o que flutua sobre a página.

| Nível | Elevação | Uso |
|---|---|---|
| `level0` | 0 | Cartões, tabelas, sidebar, top bar |
| `level1` | 1 | Barras fixas sobre conteúdo que rola |
| `level2` | 3 | Menus, popovers, seletor de data |
| `level3` | 6 | Diálogos e gavetas |
| `level4` | 8 | Toasts |

Larguras de borda: 1 px padrão; 2 px no foco de campo. `DsElevation.shadow`
gera a sombra para superfícies desenhadas à mão.

## 3.7 Camadas (z-index)

`DsLayer`. O Flutter não tem z-index: a ordem vem da árvore e do `Overlay`. Os
valores documentam a ordem pretendida e servem para ordenar filhos de `Stack`.

| Camada | Valor |
|---|---|
| `base` | 0 |
| `sticky` | 100 |
| `sidebar` | 200 |
| `topBar` | 300 |
| `dropdown` | 400 |
| `drawer` | 500 |
| `dialog` | 600 |
| `toast` | 700 |
| `tooltip` | 800 |

## 3.8 Movimento

| Token | Duração | Uso |
|---|---|---|
| `DsMotion.fast` | 100 ms | Hover, pressão, foco |
| `DsMotion.base` | 180 ms | Expandir e recolher, sidebar, abas |
| `DsMotion.slow` | 240 ms | Entrada de diálogo e gaveta |

Curva única: `easeOutCubic`. Animação só explica mudança de estado.

## 3.9 Dimensões

`DsSizes`: controle 40 px (32 px no tamanho pequeno), ícone 16/18/20/24, top bar
56, sidebar 240 (64 recolhida), linha de tabela 44, cabeçalho de tabela 40,
alvo de toque 44, largura máxima de conteúdo 1280 e de formulário 760, diálogos
400/560/720, gaveta 480.

Breakpoints (`DsBreakpoints`): celular abaixo de 600, tablet de 600 a 899,
desktop a partir de 900. `wide` (1280) e `shortHeight` (800) tratam notebooks;
ver [Layout](04-layout.md#45-notebooks-de-14-e-15-polegadas).

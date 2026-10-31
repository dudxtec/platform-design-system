# 4. Sistema de layout

Toda tela é `DsAppShell` > `DsPage` > conteúdo. Nenhuma tela desenha a própria
barra superior, sidebar ou margem.

## 4.1 Desktop (a partir de 900 px)

```
┌──────────────────────────────────────────────────────────────────────────┐
│ ☰  Marca                                   Tenant ▾   🔔   Usuário ▾     │ Top bar 56
├──────────────┬───────────────────────────────────────────────────────────┤
│ GRUPO        │  Início › Cadastros › Pessoas                 Breadcrumb  │
│ ▣ Item ativo │  Pessoas                      [Exportar] [+ Nova pessoa]  │ Cabeçalho + ações
│ ▢ Item       │  249 registros                                            │
│ ▢ Item    ↗  │                                                           │
│              │  [🔍 Buscar...      ] [Status ▾] [Período ▾]  Limpar (2)  │ Filtros
│ GRUPO        │                                                           │
│ ▢ Item       │  ┌─────────────────────────────────────────────────────┐  │
│              │  │ Conteúdo: tabela, formulário, painéis               │  │ Conteúdo
│              │  │                                                     │  │
│              │  ├─────────────────────────────────────────────────────┤  │
│              │  │ 1–20 de 249            Por página 20 ▾  ⏮ ‹ 1/13 › ⏭│  │
│              │  └─────────────────────────────────────────────────────┘  │
│ ──────────── │                                                           │
│ Rodapé       │                                                           │
└──────────────┴───────────────────────────────────────────────────────────┘
  Sidebar 240         Margem 24, largura máxima 1280, centralizado
```

## 4.2 Celular (abaixo de 600 px)

```
┌────────────────────────────┐
│ ☰  Marca            Usuário│  Top bar 56; ☰ abre a gaveta de navegação
├────────────────────────────┤
│ Cadastros › Pessoas        │
│ Pessoas                    │
│ 249 registros              │
│ [Exportar] [+ Nova pessoa] │  Ações descem para baixo do título
│                            │
│ [🔍 Buscar...            ] │  Filtros em coluna
│ [Status ▾                ] │
│                            │
│ ┌────────────────────────┐ │
│ │ Cartão por registro    │ │  Tabela vira lista de cartões
│ └────────────────────────┘ │
└────────────────────────────┘
  Margem 16
```

## 4.3 Regiões

### Top bar

- 56 px, fundo `surface`, borda inferior de 1 px. Sem cor de marca no fundo.
- Esquerda: botão de menu e marca. Direita: seletor de tenant, notificações e
  menu do usuário, nessa ordem; o menu do usuário é sempre o último e contém
  "Sair".
- Não contém ações da página nem título da página.

### Sidebar

- 240 px, recolhe para 64 px (só ícones, com tooltip). Fundo `surface`, borda à
  direita. Abaixo de 900 px vira gaveta.
- Itens de 40 px agrupados em seções com título em overline. O item ativo tem
  fundo `surfaceSelected` e texto teal em peso 600.
- Item que abre em nova aba mostra o ícone ↗ e o leitor de tela anuncia "abre
  em nova aba".
- Rótulos são substantivos ("Pessoas", "Carnês"); no máximo dois níveis.

**Decisão:** a sidebar teal escura do main-portal é substituída pela clara. Os
tokens já previam a clara; ela reduz ruído, deixa a cor de marca livre para
indicar seleção e funciona nos dois temas.

### Breadcrumb

- Presente em toda página abaixo da raiz do módulo. O último item é a página
  atual e não é link, a menos que o portal passe `onTap` (por exemplo, Ctrl + clique
  para abrir a página em nova aba).
- Reflete hierarquia, não histórico.

### Cabeçalho de página e barra de ações

`DsPageHeader`.

- Título em H1, igual ao rótulo do item de navegação. Subtítulo opcional com
  contagem ou contexto.
- Ações à direita do título; no máximo três visíveis, as demais em menu "Mais".
- Ordem: secundárias primeiro, primária por último.
- Em páginas de detalhe e formulário, botão voltar antes do título.

### Área de filtros

`DsFilterBar`, entre o cabeçalho e o conteúdo.

- Busca textual primeiro (320 px), depois os filtros mais usados; no máximo
  quatro visíveis, os demais atrás de "Mais filtros".
- "Limpar filtros (n)" aparece só quando há filtro ativo.

### Área de conteúdo

`DsPage`.

- Margem de 24 px (16 no celular). Largura máxima de 1280 px para dados e
  760 px para formulários e detalhes, centralizada.
- `scrollable: false` quando o conteúdo é uma tabela que rola por dentro, com
  cabeçalho e paginação fixos.
- 24 px entre cabeçalho e filtros, 16 px entre filtros e conteúdo, 24 px entre
  cartões.

### Rodapé

Não há rodapé global: em ferramenta de trabalho ele só ocupa altura. Existem
dois rodapés locais:

- **Rodapé de página** (`DsPage.footer`): barra fixa com as ações do
  formulário (`DsFormActions`).
- **Rodapé da sidebar** (`DsAppShell.sidebarFooter`): versão e ambiente.

## 4.4 Modo embutido

Portal aberto em iframe pelo main-portal passa `embedded: true`. O shell então
renderiza só o corpo: sem top bar e sem sidebar. O `DsPageHeader` continua,
porque o título pertence à página e não ao shell.

Hoje forms e reports desenham cabeçalho próprio dentro do iframe; com o modo
embutido isso deixa de existir.

```dart
DsAppShell(
  embedded: mainPortalContext.isEmbedded,
  sections: sections,
  selectedId: currentRoute,
  onNavigate: (item) => router.go(item.id),
  brand: const Text('Plataforma'),
  topBarActions: [TenantSelector(), UserMenu()],
  body: DsPage(
    header: DsPageHeader(title: 'Pessoas'),
    child: PersonTable(),
  ),
)
```

## 4.5 Notebooks de 14 e 15 polegadas

A maior parte dos usuários trabalha em notebook. O que limita essas telas é a
altura, não a largura.

| Tela | Escala | Viewport aproximado do navegador |
|---|---|---|
| 1366 x 768 | 100% | 1366 x 650 |
| 1920 x 1080 (14") | 150% | 1280 x 600 |
| 1920 x 1080 (15,6") | 125% | 1536 x 740 |
| Monitor 1920 x 1080 | 100% | 1920 x 950 |

Dentro do iframe do hub a altura ainda perde a top bar do main-portal.

### Densidade compacta

`DsDensity.of(context)` devolve `compact` quando o viewport tem menos de
800 px de altura (`DsBreakpoints.shortHeight`). Os componentes se ajustam
sozinhos; nenhuma tela precisa tratar isso.

| Item | Confortável | Compacto |
|---|---|---|
| Top bar | 56 (48 no celular) | 48 |
| Margem da página | 24 | 16 |
| Cabeçalho até filtros | 24 | 12 |
| Filtros até conteúdo | 16 | 12 |
| Título da página | 24 px; subtítulo na linha de baixo | 20 px; subtítulo ao lado |
| Linha de tabela | 44 | 36 |
| Cabeçalho de tabela | 40 | 36 |
| Rodapé de paginação | 56 | 40 |
| Padding do cartão de KPI | 16 | 12 |

Resultado na listagem padrão em 1280 x 600: 9 linhas visíveis com cabeçalho,
filtros e paginação na tela, contra cerca de 5 na densidade confortável.

Campos e botões continuam com 40 px: reduzir o alvo de clique não compensa o
ganho.

Para forçar uma densidade (preferência do usuário, por exemplo):

```dart
DsDensityScope(density: DsDensity.compact, child: app)
```

### Largura

- Abaixo de 1280 px (`DsBreakpoints.wide`) a sidebar começa recolhida em 64 px.
  Isso cobre 1366 x 768 com zoom de 125% e janelas lado a lado.
- A escolha do usuário prevalece. O portal guarda a preferência e a devolve:

```dart
DsAppShell(
  sidebarCollapsed: prefs.sidebarCollapsed,          // null = automático
  onSidebarCollapsedChanged: prefs.setSidebarCollapsed,
  ...
)
```

### Regras para as telas

- Listagem usa `DsPage(scrollable: false)`: cabeçalho e paginação ficam fixos e
  só as linhas rolam. Nunca duas barras de rolagem verticais.
- Ações de linha em tabela usam `IconButton` com
  `visualDensity: VisualDensity.compact`, para caber na linha de 36 px.
- Formulário longo rola por inteiro, com as ações fixas no rodapé
  (`DsPage.footer`).
- Diálogo tem no máximo 5 campos; acima disso é página. Conteúdo de diálogo
  sempre rolável.
- Nada com altura fixa maior que 400 px (o `TabBarView` de 520 px do reports
  não cabe).
- O calendário do `DsDateField` tem 312 px e abre para cima quando não há
  espaço abaixo.
- Conteúdo de borda a borda (um iframe, por exemplo) usa
  `DsPage(padding: EdgeInsets.zero)`.
- Abaixo de 900 px de largura, botões e paginação têm alvo de toque de 44 px.
- Teste toda tela nova em 1280 x 600.

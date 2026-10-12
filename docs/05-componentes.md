# 5. Biblioteca de componentes

Duas origens:

- **Componentes do pacote** (`Ds*`): existem porque a auditoria encontrou a
  mesma coisa reimplementada em mais de um portal.
- **Widgets Material tematizados**: campo de texto, seleção, abas, menu,
  tooltip, seletor de data. O `DsTheme` já os padroniza; criar um invólucro só
  repetiria a API do Flutter.

## 5.1 Inventário

| Componente | Implementação | Por que existe |
|---|---|---|
| Button | `DsButton` | 5 formas de botão primário no ecossistema; `FilledButton` sem tema |
| Input, Textarea | `TextFormField` + tema | Tema cobre todos os estados; `OutlineInputBorder()` local some |
| Select | `DropdownButtonFormField` + tema | person simulava com `PopupMenuButton` sem teclado |
| Autocomplete | `Autocomplete` / `DropdownMenu` com filtro + tema | Sem duplicação que justifique invólucro ainda |
| DatePicker | `DsDateField`, `DsDateRangeField`, `DsCalendar` | Cinco implementações de campo de data (forms, reports, person, duas no membership) |
| Modal | `AlertDialog` + tema; `DsConfirmDialog` | Confirmação reimplementada em membership, tenant e forms |
| Drawer | `Drawer` (end) + tema, 480 px | Só tema; sem uso atual que peça componente |
| Card | `Card` + tema; `DsSectionCard` | "Cartão com título" copiado 5 vezes no person |
| Table | `DsDataTable` | Três implementações de listagem |
| Tabs | `TabBar` + tema | Só tema |
| Dropdown (menu) | `PopupMenuButton` / `MenuAnchor` + tema | Só tema |
| Badge | `DsBadge` | Chip de status repetido 4 vezes no tenant, 2 em forms e reports |
| Alert | `DsAlert` | `_ErrorPanel`, `_InfoPanel`, `MaterialBanner` |
| Tooltip | `Tooltip` + tema | Só tema |
| Toast | `DsToast` | `_snack` triplicado; snackbars sem cor de estado |
| Stepper | Padrão de composição (ver Templates) | Um único uso hoje (gerar link); vira componente quando houver o segundo |
| Dashboard widget | `DsKpiCard` | Cartões de KPI do reports |
| Estados | `DsEmptyState`, `DsErrorState`, `DsLoadingState` | Ausentes ou divergentes em todos |
| Paginação | `DsPagination` | Três formatos de rodapé |
| Shell e página | `DsAppShell`, `DsPage`, `DsPageHeader`, `DsBreadcrumb` | Privados do main-portal; duplicados em forms e reports |
| Filtros | `DsFilterBar` | Busca e filtros diferentes em cada lista |
| Formulário | `DsFormGrid`, `DsFieldLabel`, `DsFormActions` | Marcação de obrigatório e rodapé de ações divergentes |

`DsPrimaryButton` e `DsOutlinedButton` estão obsoletos e delegam ao `DsButton`.
`DsStatChip` permanece para contagens em linha.

## 5.2 Button — `DsButton`

| Variante | Uso |
|---|---|
| `primary` | A ação principal da tela ou do diálogo. Uma por região |
| `secondary` | Qualquer outra ação. Contorno neutro |
| `ghost` | Baixa ênfase: cancelar, ações de barra, links de ação |
| `danger` | Confirmação destrutiva, dentro do diálogo de confirmação |

Tamanhos: `md` (40 px, padrão) e `sm` (32 px, dentro de tabela e barras).

**Estados:** padrão, hover, pressionado, foco, desabilitado, carregando.
Em `loading: true` o botão fica desabilitado, troca o ícone por um indicador e
mantém a largura.

**Correto**
- Rótulo com verbo e objeto: "Nova pessoa", "Salvar alterações", "Excluir carnê".
- Ícone à esquerda, só quando ajuda a reconhecer (adicionar, exportar).
- `loading` enquanto a requisição está em curso.

**Incorreto**
- Dois primários lado a lado.
- `danger` como ação de página; destrutivo fica em menu e confirma em diálogo.
- Botão só com ícone para ação principal. Só ícone é `IconButton` com tooltip,
  em ações de linha.
- Laranja para destacar "Novo".

**Acessibilidade:** alvo mínimo de 40 px (48 px de área de toque no celular);
foco visível; em carregamento anuncia "rótulo, carregando".

## 5.3 Input e Textarea

`TextFormField` com `InputDecoration`. Contorno, fundo `surfaceSubtle`, 40 px.

**Estados:** padrão, hover, foco (borda teal de 2 px), preenchido, erro (borda
vermelha e mensagem abaixo), desabilitado (fundo `surfaceHover`), somente
leitura.

**Correto**
- `label: DsFieldLabel('CPF', required: true)`.
- `hintText` com o formato esperado ("000.000.000-00").
- `helperText` para regra que não cabe no rótulo.
- Textarea: `minLines: 3`, `maxLines: 6`.

**Incorreto**
- Passar `border: OutlineInputBorder()` no campo. Isso anula o tema.
- Placeholder no lugar do rótulo.
- Desabilitar para indicar "somente leitura"; use `readOnly`.

**Acessibilidade:** o rótulo é o nome acessível; obrigatório é anunciado; erro
fica associado ao campo.

## 5.4 Select, Autocomplete, DatePicker

- **Select:** até cerca de 10 opções fixas. `DropdownButtonFormField`.
- **Autocomplete:** mais de 10 opções ou busca no servidor. Mostra "Nenhum
  resultado" e estado de carregamento; busca com debounce de 300 ms.
- **DatePicker:** ver 5.4.1.
- 2 a 4 opções visíveis de uma vez: use `SegmentedButton` ou rádio, não select.

### 5.4.1 Campo de data — `DsDateField`

Campo com máscara `dd/mm/aaaa` e calendário em popover preso ao campo.

```dart
DsDateField(
  label: 'Vencimento',
  value: dueDate,
  required: true,
  firstDate: DateTime.now(),
  onChanged: (date) => setState(() => dueDate = date),
)
```

**Por que popover e não o diálogo do Material.** `showDatePicker` abre um
diálogo de cerca de 570 px de altura, que mal cabe num notebook e não cabe no
iframe do hub. O popover tem 276 x 312 px, não cobre a tela e abre para cima
quando falta espaço abaixo.

**Comportamento**
- Digitar é sempre possível e é o caminho mais rápido; a máscara insere as
  barras.
- O calendário abre pelo ícone ou com Alt+Seta para baixo; fecha com Esc, ao
  escolher um dia ou ao clicar fora.
- O título do mês abre a grade de anos, para datas distantes (nascimento).
- "Hoje" seleciona a data atual; "Limpar" aparece em campo opcional preenchido.
- Dias fora de `firstDate` e `lastDate` ficam desabilitados.
- `onChanged` entrega a data quando o texto é uma data válida dentro do
  intervalo, e `null` quando deixa de ser.

**Estados:** padrão, foco, preenchido, erro, desabilitado; calendário aberto
para baixo ou para cima; dia de hoje (contorno), selecionado (preenchido), no
período (fundo suave), desabilitado.

**Validação** (dentro de `Form`): obrigatório, "Informe uma data válida
(dd/mm/aaaa).", "Informe uma data até 31/12/2020." e depois o `validator`
próprio.

**Período — `DsDateRangeField`.** Dois campos ligados, "De" e "Até". Os dois
calendários destacam o período; fim anterior ao início aparece como erro no
campo final.

```dart
DsDateRangeField(
  start: from,
  end: to,
  onChanged: (start, end) => setState(() { from = start; to = end; }),
)
```

**Correto**
- Largura mínima de 168 px (`DsDateField.minWidth`).
- `lastDate: DateTime.now()` para nascimento; `firstDate` para vencimento.

**Incorreto**
- `showDatePicker` ou `showDateRangePicker` direto na tela.
- Campo somente leitura que obriga a usar o calendário.
- Um único campo para o período.

**Acessibilidade:** o campo tem rótulo e anuncia obrigatório; cada dia é um
botão com a data por extenso; o popover é anunciado como "Calendário" com o
rótulo do campo. A grade não tem navegação por setas: o teclado percorre os
dias com Tab, e o caminho previsto para teclado é digitar a data.

**Idioma:** meses e dias da semana estão em português do Brasil dentro do
próprio componente, com a semana começando no domingo. Não depende de
`flutter_localizations` nem do idioma do navegador.

**Fora do escopo:** hora (o forms-portal tem um campo de data e hora) e
atalhos de período ("Últimos 7 dias", "Este mês"). Entram quando houver o
segundo uso.

## 5.5 Modal e Drawer

| | Modal | Drawer |
|---|---|---|
| Uso | Confirmação; formulário de até 5 campos | Detalhe ou edição rápida sem perder a lista |
| Largura | 400 / 560 / 720 | 480, à direita |
| Fecha com | Esc, botão; clique fora só se não houver dados digitados | Esc, botão, clique fora |

**Correto**
- Título é a pergunta ou a ação: "Excluir carnê?".
- Ações à direita: ghost "Cancelar", depois a primária.
- Foco inicial no primeiro campo, ou em "Cancelar" quando for destrutivo.

**Incorreto**
- Modal sobre modal.
- Formulário longo em modal (membership faz isso em 620 px); vira página.
- "Sim" e "Não" como rótulos; use o verbo da ação.

`DsConfirmDialog.show(...)` devolve `true` só na confirmação.

## 5.6 Card — `Card` e `DsSectionCard`

Fundo `surface`, borda de 1 px, raio 12, sem sombra.

- `DsSectionCard`: título H4, descrição opcional, ações à direita, divisor e
  corpo com padding de 16. `padding: EdgeInsets.zero` quando o corpo é tabela.
- **Incorreto:** cartão dentro de cartão; sombra para "destacar"; cartão
  clicável sem indicar que é clicável.

## 5.7 Table — `DsDataTable`

Ver [Formulários e tabelas](06-formularios-e-tabelas.md).

## 5.8 Tabs

`TabBar` alinhada à esquerda, indicador teal de 2 px, divisor inferior.

- Para visões irmãs do mesmo objeto (Dados, Parcelas, Histórico).
- De 2 a 6 abas; rótulo de uma ou duas palavras; contagem entre parênteses
  quando ajuda.
- **Incorreto:** abas como etapas de um processo; abas aninhadas;
  `TabBarView` com altura fixa.

## 5.9 Dropdown (menu de ações)

`PopupMenuButton` ou `MenuAnchor`. Fundo `surface`, borda, raio 8, elevação 2.

- Ações secundárias de linha ("Mais ações") e de página ("Mais").
- Itens com verbo; destrutivo por último, separado por divisor.
- **Incorreto:** esconder a ação mais usada dentro do menu.

## 5.10 Badge — `DsBadge`

Texto de 12 px em peso 600, fundo suave e borda do tom.

| Tom | Exemplos |
|---|---|
| `neutral` | Rascunho, Inativo, Cancelado |
| `info` | Em análise, Em processamento |
| `success` | Ativo, Pago, Concluído |
| `warning` | Aguardando, Vence hoje |
| `danger` | Vencida, Recusado, Bloqueado |
| `primary` | Novo, Selecionado |

- Sempre um rótulo em português; nunca o enum da API ("OPEN", "active").
- O mesmo estado tem o mesmo rótulo e o mesmo tom em todos os portais.
- **Incorreto:** badge clicável; mais de dois badges por linha; cor sem texto.

## 5.11 Alert — `DsAlert`

Mensagem persistente presa a uma página ou seção.

- Diz o que aconteceu e o próximo passo; ação opcional à direita.
- Erro de formulário inteiro fica no topo do formulário, e o formulário
  permanece preenchido.
- **Incorreto:** alerta para resultado de ação (é toast); mais de um alerta
  empilhado; substituir o conteúdo pelo alerta.
- **Acessibilidade:** aviso e erro são anunciados ao aparecer.

## 5.12 Tooltip

Fundo inverso, 12 px, aparece após 400 ms.

- Obrigatório em todo `IconButton`.
- Texto curto, sem ponto final.
- **Incorreto:** informação essencial só no tooltip; tooltip repetindo o rótulo
  visível.

## 5.13 Toast — `DsToast`

Resultado de uma ação que o usuário acabou de fazer.

- `DsToast.success(context, 'Pessoa salva.')`, `DsToast.error(...)`.
- 4 s; erro fica 8 s. Um por vez: o novo substitui o anterior.
- Frase completa no passado: "Carnê excluído."; com ação "Desfazer" quando for
  possível desfazer.
- **Incorreto:** `error.toString()`; toast de erro de validação (é inline);
  toast por trás de um modal.

## 5.14 Stepper

Para processos de 3 a 6 etapas em que a ordem importa. Ver o template "Wizard"
em [Dashboards e templates](07-dashboards-e-templates.md).

- Mostra etapa atual, concluídas e restantes, com rótulo.
- "Voltar" nunca perde dados; "Avançar" valida só a etapa atual.
- **Incorreto:** wizard para formulário que cabe em uma página.

## 5.15 Dashboard widget — `DsKpiCard`

Ver [Dashboards e templates](07-dashboards-e-templates.md).

## 5.16 Estados

| Componente | Quando | Conteúdo |
|---|---|---|
| `DsLoadingState` | Primeira carga de página ou seção | Indicador e "Carregando…" |
| `DsEmptyState` | Não há o que mostrar | Ícone, o que falta, próxima ação |
| `DsErrorState` | A carga falhou | Mensagem para o usuário e "Tentar novamente" |

Recarga com dados já na tela não troca a tela: usa a linha de progresso
(`DsDataTable.refreshing`).

Dois vazios diferentes: "ainda não há registros" oferece criar; "nenhum
resultado para o filtro" oferece limpar filtros.

# 7. Dashboards e templates

## 7.1 Sistema de dashboard

Um dashboard responde, nesta ordem: como estamos, o que exige ação, onde está o
detalhe.

```
┌────────────────────────────────────────────────────────────────────┐
│ Financeiro                              [Período ▾]   [Exportar]   │
│ Outubro de 2026                                                    │
│ ┌────────────────────────────────────────────────────────────────┐ │
│ │ ⚠ 12 cobranças vencem hoje                     Ver cobranças   │ │  Alertas
│ └────────────────────────────────────────────────────────────────┘ │
│ ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐        │
│ │ Recebidas  │ │ Aguardando │ │ Vencidas   │ │ Carnês     │        │  KPIs (até 4)
│ │ R$ 48.320  │ │ R$ 15.870  │ │ R$ 6.410   │ │ 1.249      │        │
│ │ +12,4% vs. │ │ −3,1%  86  │ │ +8,0%  31  │ │ +24 no mês │        │
│ └────────────┘ └────────────┘ └────────────┘ └────────────┘        │
│ ┌──────────────────────────────────┐ ┌───────────────────────────┐ │
│ │ Recebimentos por dia (gráfico)   │ │ Pendências                │ │  Tendência + fila
│ └──────────────────────────────────┘ └───────────────────────────┘ │
│ ┌────────────────────────────────────────────────────────────────┐ │
│ │ Por forma de pagamento (ranking)                               │ │  Detalhe
│ └────────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘
```

### KPIs e cartões métricos — `DsKpiCard`

- Rótulo, valor em 28 px com algarismos tabulares, variação e contexto.
- No máximo 4 por linha (2 no tablet, 1 no celular) e uma linha por dashboard.
- A variação informa contra o quê: "+12,4% vs. setembro". O tom reflete se é
  bom ou ruim para o negócio: "Vencidas +8%" é `danger`, não `success`.
- Cartão clicável leva à listagem já filtrada que explica o número.
- Valor já formatado em pt-BR: `R$ 48.320,00`, `1.249`, `12,4%`.
- **Incorreto:** ícone decorativo grande; fundo colorido; altura fixa; mais de
  uma métrica por cartão.

### Gráficos

- Dentro de `DsSectionCard`, com título que diz o que se vê e descrição com
  período e unidade.
- Linha para evolução no tempo; barra para comparar categorias; barra
  horizontal para ranking. Sem pizza acima de 3 fatias, sem 3D, sem eixo duplo.
- Cores de `DsPalette.chart`, na ordem. Série única em `primary`.
- Eixo Y começa em zero em barras. Linhas de grade em `border`.
- Tooltip com valor exato; legenda só com mais de uma série.
- Todo gráfico tem alternativa em tabela ("Ver dados") e estados de carga,
  vazio e erro.
- O pacote não inclui biblioteca de gráficos. Quando o primeiro portal
  precisar, a escolha e o tema entram aqui.

### Rankings

Lista ordenada com rótulo, barra proporcional e valor à direita; até 10 itens e
"Ver todos". Exemplo em `example/lib/templates/dashboard_page.dart`.

### Alertas

`DsAlert` no topo, acima dos KPIs. No máximo dois; com mais, um resumo
("3 itens precisam de atenção") que leva à central. Todo alerta tem ação.

### Pendências

Cartão com a fila de trabalho do usuário: até 5 itens, cada um com o que é, de
quem, desde quando e a ação. O vazio é uma boa notícia e diz isso: "Nada
pendente".

### Indicadores operacionais

Estado de integrações e filas: `DsBadge` com rótulo (Operando, Instável, Fora
do ar), horário da última verificação e, quando houver, o que fazer.

## 7.2 Biblioteca de templates

Cada template é uma composição de componentes existentes. Os três primeiros
estão implementados em `example/lib/templates/`.

### Dashboard

`DsPage` > `DsPageHeader` (período e exportar) > `DsAlert` > grade de
`DsKpiCard` > `DsSectionCard` com gráficos e rankings.

### CRUD padrão

`DsPage(scrollable: false)` > `DsPageHeader` (exportar e primária de criar) >
`DsFilterBar` > `DsDataTable` com `DsPagination`.

### Cadastro simples

Até 5 campos, sem seções: `AlertDialog` de 560 px com `DsFormGrid` e ações
"Cancelar" e "Salvar". Validação inline; o diálogo só fecha depois que o
servidor confirma.

### Cadastro complexo

`DsPage(maxWidth: formMaxWidth)` > `DsPageHeader` com voltar > `Form` com um
`DsSectionCard` por grupo > `DsFormActions` no rodapé fixo. Com mais de cinco
seções, índice lateral com âncoras.

### Wizard multi-etapas

```
┌────────────────────────────────────────────────────────┐
│ ←  Novo carnê                                          │
│ ① Pessoa ─── ② Plano ─── ③ Pagamento ─── ④ Revisão     │
│ ┌────────────────────────────────────────────────────┐ │
│ │ Etapa 2 de 4 · Plano                               │ │
│ │ [campos da etapa]                                  │ │
│ └────────────────────────────────────────────────────┘ │
├────────────────────────────────────────────────────────┤
│ Cancelar                          Voltar   [ Avançar ] │
└────────────────────────────────────────────────────────┘
```

Largura de formulário. Indicador com número e rótulo; concluídas ficam
clicáveis. "Avançar" valida só a etapa atual; a última etapa é uma revisão e o
botão passa a nomear a ação ("Criar carnê"). O estado sobrevive a voltar e a
recarregar.

### Tela de detalhes

`DsPageHeader` (nome do registro, `DsBadge` de status no subtítulo, "Editar" e
menu "Mais") > `DsSectionCard` com pares rótulo e valor em duas colunas > abas
para coleções relacionadas (parcelas, histórico).

### Mestre-detalhe

Lista à esquerda (360 px) e detalhe à direita, lado a lado a partir de 900 px.
Abaixo disso a lista ocupa a tela e o detalhe abre como página. O item
selecionado fica na URL.

### Configurações

Largura de formulário. Um `DsSectionCard` por assunto, cada um com seu próprio
"Salvar". Alternâncias (`Switch`) aplicam na hora, com toast. Ações perigosas
ficam num cartão final "Zona de risco".

### Relatórios

`DsPageHeader` (exportar) > `DsFilterBar` com período e `onApply` > linha de
`DsKpiCard` com os totais > `DsDataTable` com linha de total no fim. Os números
dos KPIs e da tabela vêm da mesma consulta.

### Monitoramento

Grade de cartões por serviço com `DsBadge` de estado, métrica principal e
horário da última leitura; lista de eventos recentes abaixo. Atualiza sozinho,
mostra "Atualizado há 30 s" e permite pausar.

### Central de notificações

Página com abas "Não lidas" e "Todas"; lista agrupada por dia; cada item com
título, resumo, quando e a ação; "Marcar todas como lidas" no cabeçalho. O
sino da top bar abre os cinco itens mais recentes e leva à central.

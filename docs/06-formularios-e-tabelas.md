# 6. Formulários e tabelas

## 6.1 Padrão de CRUD

Um recurso tem sempre as mesmas quatro telas, com as mesmas rotas.

| Tela | Rota | Template |
|---|---|---|
| Listagem | `/pessoas` | CRUD padrão |
| Criação | `/pessoas/nova` | Cadastro |
| Detalhe | `/pessoas/:id` | Detalhes |
| Edição | `/pessoas/:id/editar` | Cadastro |

- Criar e editar usam o mesmo formulário, em **página**. Modal só para
  formulário de até 5 campos sem seções.
- Depois de salvar: volta para a listagem (ou detalhe), com toast "Pessoa
  salva." e o registro visível.
- Excluir: menu "Mais ações" da linha ou do detalhe, com `DsConfirmDialog`
  nomeando o registro ("Excluir Ana Souza?"), nunca o identificador técnico.
- Toda tela tem URL própria e sobrevive a recarregar a página.

## 6.2 Anatomia do formulário

```
┌──────────────────────────────────────────────────────────┐
│ Cadastros › Pessoas › Nova pessoa                        │
│ ←  Nova pessoa                                           │
│                                                          │
│ ┌──────────────────────────────────────────────────────┐ │
│ │ Identificação                                        │ │  DsSectionCard
│ ├──────────────────────────────────────────────────────┤ │
│ │ [Nome completo *                                   ] │ │  DsFormFull
│ │ [CPF *                  ] [Data de nascimento    📅] │ │  DsFormGrid, 2 colunas
│ └──────────────────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────────────────┐ │
│ │ Contato                                              │ │
│ │ Usado para lembretes de cobrança.                    │ │
│ ├──────────────────────────────────────────────────────┤ │
│ │ [Telefone *             ] [E-mail                  ] │ │
│ │                            Opcional.                 │ │
│ └──────────────────────────────────────────────────────┘ │
├──────────────────────────────────────────────────────────┤
│                                   Cancelar   [ Salvar ]  │  DsPage.footer + DsFormActions
└──────────────────────────────────────────────────────────┘
  Largura máxima 760
```

- Largura máxima de 760 px. Duas colunas no desktop, uma abaixo de 600 px.
- Seções em `DsSectionCard`, da informação mais essencial para a menos.
- Ordem dos campos é a ordem de leitura e de tabulação.
- Largura do campo sugere o tamanho do dado: CPF e data em meia largura; nome e
  observações em largura cheia (`DsFormFull`).
- Ações fixas no rodapé: "Cancelar" (ghost) e a primária por último, à direita.
  A mesma ordem vale em diálogos.

## 6.3 Campos obrigatórios

- Asterisco vermelho depois do rótulo: `DsFieldLabel('Nome', required: true)`.
  O leitor de tela anuncia "Nome, obrigatório".
- Campo opcional não leva marca. Se a maioria for opcional, o texto de ajuda
  "Opcional." pode aparecer nos poucos que importam.
- O botão Salvar nunca fica desabilitado por campo faltando: o usuário clica e
  a validação mostra o que falta.

## 6.4 Validação

| Momento | O que acontece |
|---|---|
| Ao digitar | Só máscara e limite de caracteres. Nenhum erro |
| Primeiro envio | Valida tudo; foco e rolagem vão para o primeiro campo com erro |
| Depois do primeiro envio | Revalida a cada alteração (`AutovalidateMode.onUserInteraction`) |
| Resposta do servidor | Erro de campo vai para o campo; erro geral vai para um `DsAlert` no topo |

```dart
Form(
  key: _form,
  autovalidateMode: _submitted
      ? AutovalidateMode.onUserInteraction
      : AutovalidateMode.disabled,
  child: ...,
)
```

- Sempre `Form` + `TextFormField` + `validator`. Validação por snackbar depois
  do envio (membership) deixa de existir.
- Em falha, o formulário continua na tela com tudo que foi preenchido.
- Sair com alterações não salvas pede confirmação.
- Um único modo de salvar por formulário: botão **ou** salvamento automático.
  Se for automático, há indicador "Salvando…" / "Salvo às 14:32" e a falha é
  visível.

## 6.5 Mensagens de erro

Abaixo do campo, em vermelho, 12 px, até duas linhas. Dizem o que corrigir.

| Situação | Mensagem |
|---|---|
| Obrigatório vazio | Preencha este campo. |
| Formato | Informe um CPF válido. |
| Limite | Use até 120 caracteres. |
| Duplicidade | Já existe uma pessoa com este CPF. |
| Servidor indisponível | Não foi possível salvar. Tente novamente em instantes. |

Nunca: "Campo inválido", "Erro", código HTTP, `error.toString()`, texto em
inglês vindo da API.

## 6.6 Pesquisa e filtros

- **Busca rápida:** campo com lupa, primeiro da barra, 320 px. Aplica ao
  digitar com debounce de 300 ms; "×" limpa.
- **Filtros:** aplicam ao mudar. Botão "Aplicar" só para consulta cara
  (período de relatório), via `DsFilterBar.onApply`.
- **Filtros ativos:** "Limpar filtros (n)" aparece quando há algum. Mais de
  quatro filtros: os menos usados vão para "Mais filtros" em gaveta lateral.
- Filtros, busca, ordenação e página ficam na URL: recarregar ou compartilhar o
  link reproduz a mesma lista.
- Mudar filtro ou busca volta para a página 1.

## 6.7 Sistema de tabelas — `DsDataTable`

```
┌──────────────────────────────────────────────────────────────────┐
│ ☐  Nome ↑            CPF             Cidade     Status    Ações  │  40 px, fixo
├──────────────────────────────────────────────────────────────────┤
│ ☐  Ana Souza         001.482.190-00  Brasília   (Ativo)   ✎  ⋯   │  44 px
│ ☑  Bruno Carvalho    002.482.191-01  Goiânia    (Inativo) ✎  ⋯   │  selecionada
├──────────────────────────────────────────────────────────────────┤
│ 1–20 de 249                    Por página 20 ▾   ⏮ ‹ 1 de 13 › ⏭ │  fixo
└──────────────────────────────────────────────────────────────────┘
```

Com linhas selecionadas, a barra de ferramentas dá lugar à barra de lote:

```
│ 2 selecionados   [Exportar seleção] [Inativar]   Limpar seleção  │
```

### Listagens

- Linha de 44 px, texto de 13 px, cabeçalho de 12 px em peso 600 sobre
  `surfaceSubtle`. Sem zebra; hover em `surfaceHover`.
- Primeira coluna é o identificador humano (nome), e é o link para o detalhe.
- Texto à esquerda; números, valores e datas à direita, com algarismos
  tabulares. Status em `DsBadge`. Ações na última coluna.
- De 5 a 8 colunas. Acima disso, rolagem horizontal com a primeira coluna
  visível; o resto vai para o detalhe.
- Vazio em célula é "—", nunca espaço em branco ou "null".
- Abaixo de 600 px a tabela vira lista de cartões (`DsResponsiveLayout`).

### Ordenação

- No cabeçalho, com seta. Uma coluna por vez.
- **Sempre no servidor.** Ordenar só a página atual (como membership e person
  fazem hoje) dá resultado errado e é proibido.
- Ordem padrão explícita e estável (por exemplo, nome crescente).

### Paginação — `DsPagination`

- No servidor. 20 por página por padrão; opções 20, 50, 100.
- Formato único: "1–20 de 249" à esquerda; à direita, tamanho da página e
  primeira, anterior, "Página 1 de 13", próxima, última.
- O total é obrigatório. Sem total não há como saber onde a lista termina.

### Seleção múltipla

- Caixa por linha e caixa no cabeçalho, que seleciona a página atual.
- A seleção se mantém ao trocar de página e é zerada ao mudar filtro.
- A barra de lote mostra a contagem e "Limpar seleção".

### Ações rápidas (por linha)

- Até duas ações em ícone com tooltip nomeando o registro ("Editar Ana Souza");
  as demais em "Mais ações".
- Alvo de 40 px. Destrutiva sempre dentro do menu.
- Edição em linha só para um campo simples (alternar status), com retorno
  imediato e desfazer.

### Ações em lote

- Botões pequenos na barra de lote; destrutiva por último, em `danger`.
- Confirmação informa a quantidade: "Inativar 12 pessoas?".
- Resultado parcial é relatado: "10 inativadas. 2 não puderam ser alteradas."

### Exportação

- Botão secundário "Exportar" no cabeçalho da página; exporta o que os filtros
  atuais retornam, não só a página.
- Formatos em menu: Excel, CSV, PDF.
- Exportação longa é assíncrona: toast "Exportação iniciada" e aviso com link
  ao concluir.

### Estados

`DsDataTable.state`: `loading` na primeira carga, `empty`, `error` com "Tentar
novamente". Recarga (página, ordenação, filtro) mantém as linhas e mostra a
linha de progresso (`refreshing: true`).

## 6.8 Exemplo

`example/lib/templates/crud_list_page.dart` e `form_page.dart` mostram a
estrutura destes padrões com dados locais. Estado na URL, debounce da busca e
ordenação no servidor dependem do roteador e da API de cada portal e não estão
no exemplo.

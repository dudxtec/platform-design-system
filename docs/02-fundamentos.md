# 2. Fundamentos

## 2.1 Marca

**Personalidade.** Um colega experiente de operações: preciso, calmo, direto.
Não chama atenção para si; deixa o dado falar.

| Atributo | Na interface significa |
|---|---|
| Confiável | Mesmo padrão em todos os módulos; nada muda de lugar; todo erro diz o que fazer |
| Eficiente | Densidade alta, poucos cliques, teclado de ponta a ponta |
| Claro | Uma ação principal por tela; rótulos em português correto; números alinhados |
| Sóbrio | Superfícies planas, uma cor de marca, cor só com significado |

**Valores transmitidos.** Controle (o usuário sabe onde está e o que vai
acontecer), respeito ao tempo de quem passa horas no sistema, e seriedade com
dinheiro e dados pessoais.

**Posicionamento visual.** Neutros frios em quase toda a tela; teal para ação e
seleção; laranja como destaque raro de marca; verde, âmbar, vermelho e azul
apenas para estado. A referência é a família Linear, Stripe Dashboard e GitHub:
borda fina no lugar de sombra, tipografia pequena e firme, nenhum gradiente.

**Por que manter teal e laranja.** Já são a marca em produção nos portais
Flutter e no customer-bill. Trocar teria custo sem ganho de consistência. O que
muda é a disciplina de uso:

- A ação principal é sempre teal. Hoje "Novo" é laranja em person e membership;
  passa a ser teal.
- Laranja nunca carrega texto branco (2,3:1) e nunca indica estado. Aviso usa
  âmbar, para não se confundir com a marca.

## 2.2 Princípios

Obrigatórios. Em caso de conflito, vale o de número menor.

### 1. Consistência antes de criatividade

A mesma coisa tem a mesma aparência e o mesmo comportamento em todos os portais.
Uma tela nova se monta com componentes e templates existentes. Se o que existe
não serve, a mudança é feita no pacote, para todos, e não na tela.

*Teste:* um usuário do módulo de pessoas usa o de carnês sem aprender nada.

### 2. Dados em primeiro lugar

A interface existe para mostrar e alterar registros. Molduras, ícones e cor
cedem espaço ao conteúdo. Números usam algarismos tabulares e alinham à direita;
identificadores técnicos (UUID, enum) nunca aparecem crus.

*Teste:* cubra o cabeçalho e a sidebar; o que sobra ainda é útil?

### 3. Clareza acima de estética

Rótulo com verbo e objeto ("Nova pessoa", não "Novo"). Mensagem de erro diz o
que houve e o próximo passo. Português correto, com acentos. Se um elemento
precisa de explicação, ele é reescrito, não decorado com tooltip.

### 4. Uma ação principal por tela

Há no máximo um botão primário visível por região. Tudo o mais é secundário ou
ghost. Ação destrutiva nunca é a primária da tela e sempre pede confirmação
nomeando o que será afetado.

### 5. Todo estado é desenhado

Carregando, vazio, erro, parcial, desabilitado e sem permissão são telas, não
exceções. Nenhuma lista aparece em branco; nenhum erro mostra exceção técnica;
toda ação dá retorno em até 100 ms (estado do botão) e conclusão (toast).

### 6. Menos cliques, mais teclado

Filtros aplicam ao mudar. A ordem de tabulação segue a de leitura. Enter envia,
Esc fecha. Edição frequente acontece sem sair da listagem. O que o usuário faz
dez vezes por dia custa um clique.

### 7. Cor é informação

Cada cor tem um significado e só um. Estado nunca depende só da cor: há sempre
texto ou ícone. Todo par de texto e fundo atinge 4,5:1 e toda borda de controle
3:1; o pacote testa isso automaticamente.

### 8. Previsível em qualquer largura

A mesma tela funciona de 360 a 1920 px. Abaixo de 600 px a sidebar vira
gaveta, colunas viram uma, tabelas viram cartões. Nada depende de hover.

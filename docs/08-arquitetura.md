# 8. Arquitetura de frontend

O pedido original previa Next.js, Tailwind e Shadcn. A auditoria mostrou que os
portais de back-office são Flutter, e a decisão foi manter a tecnologia. Esta
seção descreve a arquitetura em Flutter; a correspondência com os arquivos
pedidos está em 8.6.

## 8.1 Estrutura do pacote

```
platform-design-system/
├── lib/
│   ├── platform_design_system.dart      único ponto de importação
│   └── src/
│       ├── tokens/
│       │   ├── ds_palette.dart          escalas primitivas 50–900
│       │   ├── ds_color_tokens.dart     tokens semânticos, claro e escuro
│       │   ├── ds_colors.dart           legado, estático
│       │   ├── ds_typography.dart
│       │   ├── ds_spacing.dart
│       │   ├── ds_radius.dart
│       │   ├── ds_foundations.dart      tamanhos, elevação, camadas, movimento
│       │   └── ds_breakpoints.dart
│       ├── theme/
│       │   └── ds_theme.dart            ThemeData claro e escuro
│       └── widgets/                     um componente por arquivo
├── test/                                contraste, tokens, componentes
├── example/                             galeria e templates de referência
└── docs/
```

## 8.2 Estrutura de um portal

Baseada no person-portal, que já é o mais organizado.

```
<modulo>-portal/lib/
├── main.dart                 só runApp
├── app.dart                  MaterialApp.router, DsTheme, providers
├── routes/                   go_router; uma rota por tela
├── core/                     config, contexto do hub, utilitários
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/             HTTP
└── presentation/
    ├── shell/                DsAppShell configurado para o portal
    ├── <recurso>/            uma pasta por recurso
    │   ├── <recurso>_list_page.dart
    │   ├── <recurso>_form_page.dart
    │   ├── <recurso>_detail_page.dart
    │   ├── <recurso>_view_model.dart
    │   └── widgets/          partes privadas do recurso
    └── shared/               widgets do portal usados por mais de um recurso
```

- Um arquivo de página tem até cerca de 400 linhas. Passou disso, extraia
  seções para `widgets/`.
- Estado de tela em view model (`provider`); `setState` só para estado local e
  efêmero.
- Roteamento com `go_router`. Filtros, ordenação e página vão na URL.

## 8.3 Onde mora cada widget

| Usado por | Fica em |
|---|---|
| Um recurso | `presentation/<recurso>/widgets/` |
| Mais de um recurso do mesmo portal | `presentation/shared/` |
| Mais de um portal | Este pacote |

Um widget sobe de nível quando aparece o segundo uso, não antes.

## 8.4 Nomenclatura

| Item | Convenção | Exemplo |
|---|---|---|
| Componente do pacote | `Ds` + substantivo | `DsDataTable` |
| Arquivo do pacote | `ds_` + snake_case | `ds_data_table.dart` |
| Variante | enum `Ds<Componente>Variant` | `DsButtonVariant.secondary` |
| Tom | `DsTone` | `DsTone.danger` |
| Token primitivo | escala + passo | `DsPalette.teal600` |
| Token semântico | papel, sem nome de cor | `surfaceSelected`, `textSecondary` |
| Espaçamento | `s` + pixels | `DsSpacing.s16` |
| Página | `<Recurso><Tipo>Page` | `PersonListPage` |
| View model | `<Recurso>ViewModel` | `PersonViewModel` |
| Rótulo de enum | extensão `label` no model | `status.label` → "Ativo" |

Parâmetros iguais têm o mesmo nome em todos os componentes: `label`, `onPressed`,
`tone`, `variant`, `size`, `loading`, `actions`.

## 8.5 Regras de uso dos tokens

Nas pastas `presentation/` dos portais é proibido:

- `Color(0x...)` e `Colors.*` (exceto `Colors.transparent`).
- `fontSize:` literal; use `Theme.of(context).textTheme` ou `DsTypography`.
- Número literal em `EdgeInsets`, `SizedBox` e `BorderRadius`; use `DsSpacing`
  e `DsRadius`.
- `OutlineInputBorder()` em campo.
- `DsColors.*` em código novo; use `context.dsColors`.

A aplicação automática dessas regras (lint customizado ou verificação por
`grep` no CI) está no plano de migração.

## 8.6 Correspondência com os arquivos pedidos

| Pedido (stack web) | Entregue (Flutter) |
|---|---|
| `tokens.ts` | `ds_palette.dart`, `ds_spacing.dart`, `ds_radius.dart`, `ds_typography.dart`, `ds_foundations.dart` |
| `tokens.css` (variáveis claro/escuro) | `ds_color_tokens.dart` (`DsColorTokens.light` / `.dark`) |
| `theme.ts` | `ds_theme.dart` |
| Configuração do Tailwind | Não se aplica; o `ThemeData` cumpre o papel |
| Estrutura dos layouts | `DsAppShell`, `DsPage`, `DsPageHeader` |
| Componentes base | `lib/src/widgets/` |

## 8.7 Estratégia de reaproveitamento

**Antes de criar um componente:**

1. Procure no pacote e no Material tematizado.
2. Veja se uma variante ou um parâmetro em componente existente resolve.
3. Confirme que há dois usos reais, em portais ou recursos diferentes.
4. Registre a justificativa no pull request e a entrada no CHANGELOG.

Um componente novo entra com: dartdoc, estados completos, tema claro e escuro,
teste de widget, página na galeria e seção em `docs/05-componentes.md`.

## 8.8 Versionamento

- Semver com tags `vX.Y.Z`. Enquanto estiver em `0.x`, o número do meio indica
  mudança visual ou de API.
- Portais apontam para tag, nunca para `main`:

```yaml
platform_design_system:
  git:
    url: https://github.com/dudxtec/platform-design-system.git
    ref: v0.2.0
```

- Todo release tem entrada no `CHANGELOG.md` com o que muda visualmente.
- `main` protegido; CI roda `flutter analyze` e `flutter test`.

## 8.9 Portais web

Os cinco portais React são páginas públicas e ficam fora deste pacote. Para
alinhá-los sem reescrever nada:

1. **Agora:** copiar os valores de `docs/03-tokens.md` para variáveis CSS em
   `:root` de cada portal (os nomes semânticos são os mesmos).
2. **Quando houver o segundo portal web ativo:** mover os tokens para um JSON
   único neste repositório e gerar dele o Dart e o CSS, para que os valores não
   possam divergir.
3. Unificar os três portais de campanha num núcleo comum é pré-requisito para
   qualquer biblioteca de componentes web valer a pena.

## 8.10 Fora do design system

A auditoria encontrou código duplicado que não é visual: handshake com o hub
(`*_portal_ready` / `main_portal_context`), cliente de autenticação, máscaras e
validação de CPF e telefone. Isso pertence a um pacote de plataforma separado,
para o design system continuar sem dependências além do Flutter.

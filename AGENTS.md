# AGENTS.md - platform-design-system

Regras para qualquer agente (humano ou IA) que altere este repositório.

## Visão geral

Pacote **Flutter** com tokens, tema e componentes base (`Ds*`) usados por todos os portais Flutter da plataforma
(main, membership, person, forms, reports, tenant). Não é um portal nem um serviço: uma mudança aqui chega aos portais
quando cada um atualiza sua dependência.

- `lib/src/tokens/`, `lib/src/theme/`, `lib/src/widgets/`: código do pacote; a API pública é exportada por `lib/platform_design_system.dart`.
- `example/`: galeria e templates (listagem, formulário, dashboard) usados para revisar visualmente.
- `docs/`: documentação do design system (fundamentos, tokens, componentes, arquitetura, adoção). Atualize o capítulo
  correspondente quando mudar o comportamento de um componente ou token.

## Regras de mudança

- **Mudança de API pública ou visual afeta todos os portais.** Prefira adicionar parâmetros opcionais a mudar os existentes.
  Remoção ou mudança de comportamento exige entrada em "Muda o comportamento" no `CHANGELOG.md`.
- Nomenclatura: componente `Ds` + substantivo, arquivo `ds_` + snake_case, variantes em `Ds<Componente>Variant`, tom em `DsTone`;
  parâmetros iguais mantêm o mesmo nome entre componentes (`label`, `onPressed`, `tone`, `variant`, `size`, `loading`, `actions`).
- Use sempre tokens (`DsSpacing`, `DsRadius`, `DsTypography`, `context.dsColors`); sem `Color(0x...)`, `fontSize` literal ou números soltos de espaçamento nos componentes.
- Um widget só entra no pacote quando é usado por mais de um portal (veja `docs/08-arquitetura.md`).
- Todo componente novo ou alterado vem com teste em `test/` e exemplo em `example/`.
- Não remova nem desabilite testes existentes.
- Sem dependência nova sem justificativa técnica; o pacote só depende do SDK do Flutter.

## Versionamento e adoção nos portais

- Os portais declaram \`ref: main\` e o \`pubspec.lock\` de cada um fixa o commit exato. Um portal só muda de versão quando alguém
  roda \`flutter pub upgrade platform_design_system\` nele e commita o novo lock (\`docs/10-adocao.md\`). Não há tags por decisão atual.
- Todo merge em \`main\` é, na prática, um release: mantenha a \`version\` do \`pubspec.yaml\` e o \`CHANGELOG.md\` atualizados
  (em \`0.x\`, o número do meio indica mudança visual ou de API).
- Não crie tags nem mude os portais para apontar para tag sem pedido explícito da pessoa responsável.
- Ao adotar uma versão nova, atualize um portal por vez, em branch própria, e confira o resultado visual antes de seguir.

## Como validar antes do PR

Use o Flutter da versão dos portais (3.41.6):

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
cd example && flutter run -d chrome   # revisão visual dos componentes alterados
```

Relate no PR quais comandos rodaram e anexe captura da galeria quando a mudança for visual.

## Padrões da plataforma

- Base comum (segurança, regras de mudança): <https://github.com/dudxtec/workflow-manager/blob/main/docs/agents-base.md>
- Como validar localmente o que o CI executa: <https://github.com/dudxtec/workflow-manager/blob/main/docs/validacao-local.md>

## Fluxo de Git

Este repositório **não tem `staging`**: crie a branch de trabalho a partir de `main` (`feat/...`, `fix/...`, `chore/...`,
`docs/...`), nunca faça commit direto em `main` e abra o PR contra `main`.

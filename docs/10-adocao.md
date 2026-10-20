# 10. Adoção nos portais

Como um portal passa a usar uma versão do pacote. Vale para os cinco que já
dependem dele (main, membership, person, forms, reports) e para o tenant.

## 10.1 Como a dependência funciona hoje

Cada portal declara o pacote por git:

```yaml
platform_design_system:
  git:
    url: https://github.com/dudxtec/platform-design-system.git
    ref: main
```

O `pubspec.lock` do portal grava o commit exato. Por isso um portal **não**
muda sozinho quando `main` avança: só muda quando alguém roda
`flutter pub upgrade` ou apaga o lock. É por isso que hoje membership e person
estão num commit e forms, main e reports em outro.

Os Dockerfiles dos portais rodam `flutter pub get`, que respeita o lock. O
deploy usa o que estiver commitado no `pubspec.lock`.

## 10.2 Publicar uma versão

No `platform-design-system`:

1. Enviar a branch e abrir o pull request.
2. Atualizar a `version` do `pubspec.yaml` e o `CHANGELOG.md`.
3. Revisar olhando a galeria (`cd example && flutter run -d chrome`).
4. Mergear em `main`.

Não há tags por decisão atual. O que mantém cada portal estável é o
`pubspec.lock`: `main` pode andar sem afetar quem não rodou o `pub upgrade`.

## 10.3 Adotar num portal

Um portal por vez, em branch própria.

**1. Confirmar a dependência** no `pubspec.yaml` do portal (`ref: main`):

```yaml
platform_design_system:
  git:
    url: https://github.com/dudxtec/platform-design-system.git
    ref: main
```

**2. Atualizar só este pacote:**

```bash
flutter pub upgrade platform_design_system
```

Confira no `pubspec.lock` que `resolved-ref` mudou.

**3. Verificar:**

```bash
flutter analyze
```

```bash
flutter test
```

A 0.2.0 não remove nada da API anterior: `DsTheme`, `DsColors`, `DsSpacing`,
`DsRadius`, `DsPrimaryButton` e `DsStatChip` continuam. O portal compila sem
alteração de código.

**4. Conferir o visual.** O que muda só por atualizar, sem tocar no código:

| Onde | Antes | Depois |
|---|---|---|
| `AppBar` | Fundo cinza, título teal | Fundo branco, título escuro, borda inferior |
| `OutlinedButton` | Contorno e texto teal | Neutro |
| `FilledButton`, `TextButton` | Padrão do Material | Com tema, iguais ao primário e ao ghost |
| Botões | Padding 24 x 12 | 40 px de altura, padding 16 |
| Campos | Borda clara, mais altos | Borda mais escura, 40 px, estados de erro |
| Texto | Espaçamento entre letras | Sem espaçamento; altura de linha definida |
| Diálogo, snackbar, tooltip, abas, tabela, menus | Padrão do Material | Com tema |

Campos que passam `border: OutlineInputBorder()` no próprio widget continuam
com a borda antiga até esse parâmetro ser removido.

Abra as telas principais em 1280 x 600 e em tela cheia.

**5. Commitar** `pubspec.yaml` e `pubspec.lock` juntos e seguir o fluxo normal
de pull request e deploy do portal.

**6. Passar a usar os componentes** (`DsButton`, `DsDateField`,
`DsDataTable`...) é trabalho separado, tela a tela, na ordem do plano de
migração interno.

## 10.4 Testar antes do merge

Para ver um portal com a branch do design system sem publicar nada, crie um
`pubspec_overrides.yaml` na raiz do portal:

```yaml
dependency_overrides:
  platform_design_system:
    path: ../platform-design-system
```

Rode `flutter pub get` e depois `flutter run -d chrome`. O portal usa o código
local, com hot reload inclusive para mudanças no pacote. **Não commite esse
arquivo**: o build do Docker não tem a pasta ao lado. Vale colocá-lo no
`.gitignore` do portal.

Para testar num ambiente publicado antes do merge, aponte `ref:` para o nome da
branch (`feat/design-system-foundation`) numa branch do portal.

## 10.5 Ordem sugerida

1. person-portal
2. reports-portal
3. main-portal
4. forms-portal
5. membership-portal
6. tenant-portal (precisa antes adicionar a dependência e trocar o tema local
   por `DsTheme.light()`)

## 10.6 Versões seguintes

- Correção sem mudança visual: aumenta o último número da `version`. Mudança
  visual ou de API: aumenta o do meio.
- Cada portal sobe quando quiser, repetindo 10.3 (`flutter pub upgrade platform_design_system`).
- Para voltar atrás, restaure o `pubspec.lock` anterior do portal (ou fixe o
  `ref:` no hash do commit anterior) e rode `flutter pub get`.
- O `CHANGELOG.md` diz o que muda visualmente em cada versão.

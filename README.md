# Platform Design System

Pacote Flutter com os tokens, o tema e os componentes base de todos os portais
da plataforma. Documentação completa em [`docs/`](docs/README.md).

## Como usar

```yaml
dependencies:
  platform_design_system:
    git:
      url: https://github.com/dudxtec/platform-design-system.git
      ref: v0.2.0 # sempre uma tag, nunca main
```

```dart
import 'package:flutter/material.dart';
import 'package:platform_design_system/platform_design_system.dart';

MaterialApp(
  theme: DsTheme.light(),
  darkTheme: DsTheme.dark(),
  home: DsAppShell(
    sections: const [
      DsNavSection(items: [
        DsNavItem(id: 'pessoas', label: 'Pessoas', icon: Icons.people_outline),
      ]),
    ],
    selectedId: 'pessoas',
    onNavigate: (item) {},
    body: DsPage(
      header: DsPageHeader(
        title: 'Pessoas',
        actions: [DsButton(label: 'Nova pessoa', onPressed: () {})],
      ),
      child: const DsEmptyState(title: 'Nenhuma pessoa cadastrada'),
    ),
  ),
);
```

## O que tem

| Camada | Conteúdo |
|---|---|
| Tokens | `DsDensity`, `DsPalette`, `DsColorTokens` (`context.dsColors`), `DsTypography`, `DsSpacing`, `DsRadius`, `DsSizes`, `DsElevation`, `DsLayer`, `DsMotion`, `DsBreakpoints` |
| Tema | `DsTheme.light()`, `DsTheme.dark()` |
| Layout | `DsAppShell`, `DsPage`, `DsPageHeader`, `DsBreadcrumb`, `DsSectionCard`, `DsFilterBar`, `DsResponsiveLayout` |
| Dados | `DsDataTable`, `DsPagination`, `DsKpiCard`, `DsBadge`, `DsStatChip` |
| Formulário | `DsButton`, `DsDateField`, `DsDateRangeField`, `DsCalendar`, `DsFormGrid`, `DsFieldLabel`, `DsFormActions` |
| Feedback | `DsAlert`, `DsToast`, `DsConfirmDialog`, `DsEmptyState`, `DsErrorState`, `DsLoadingState` |

Campos, seleção, abas, menus, tooltip e seletor de data são os widgets Material,
já padronizados pelo tema.

## Desenvolvimento

```bash
flutter analyze
```

```bash
flutter test
```

A galeria em `example/` mostra os templates e todos os componentes:

```bash
cd example && flutter run -d chrome
```

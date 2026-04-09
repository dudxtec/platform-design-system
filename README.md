# Platform Design System

Pacote Flutter com tokens, tema e componentes base da plataforma, extraído do modelo visual do `person-portal`.

## Estrutura

- `DsTheme.light()` -> tema padrão da plataforma
- `DsColors`, `DsSpacing`, `DsRadius`, `DsTypography` -> tokens de design
- `DsPrimaryButton`, `DsStatChip` -> componentes iniciais reutilizáveis

## Como usar

```yaml
dependencies:
  platform_design_system:
    git:
      url: https://github.com/dudxtec/platform-design-system.git
      ref: main
```

```dart
import 'package:flutter/material.dart';
import 'package:platform_design_system/platform_design_system.dart';

MaterialApp(
  theme: DsTheme.light(),
  home: const Scaffold(
    body: Center(
      child: DsStatChip(label: 'Total', value: '249'),
    ),
  ),
);
```

## Próximos passos recomendados

- Migrar `person-portal` para consumir este pacote
- Extrair mais componentes compartilhados (`header`, `sidebar`, `cards`)
- Adicionar catálogo visual (Storybook/Widgetbook)
- Versionar com semver (`0.x` enquanto a API visual estabiliza)
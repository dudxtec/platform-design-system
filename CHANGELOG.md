## 0.1.0

* Estrutura inicial do design system com tokens (`DsColors`, `DsSpacing`, `DsRadius`, `DsTypography`), tema (`DsTheme.light()` e `DsTheme.dark()`) e componentes base (`DsPrimaryButton`, `DsOutlinedButton`, `DsStatChip`).
* Adicionado token `DsColors.inputFill` para substituir cor hardcoded no tema.
* Adicionados tokens de dark mode em `DsColors` (`backgroundDark`, `surfaceDark`, `cardDark`, `dividerDark`, `textPrimaryDark`, `textSecondaryDark`, `textDisabledDark`, variantes de sidebar).
* Adicionados tokens `DsSpacing.xxxl` (48) e `DsSpacing.xxxxl` (64).
* Adicionado `DsTypography.darkTextTheme` para uso no tema escuro.
* Adicionado `DsTheme.dark()`.
* Criado `DsOutlinedButton`, par do `DsPrimaryButton`.
* Corrigido uso de `Colors.white` em `DsStatChip` para `DsColors.textOnPrimary`.
* Ampliada cobertura de testes.

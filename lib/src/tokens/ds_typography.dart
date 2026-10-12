import 'package:flutter/material.dart';

import '../tokens/ds_colors.dart';

/// Type scale. Base size is 14 px, tuned for data-dense screens.
///
/// | Role    | Material slot   | Size/line | Weight |
/// |---------|-----------------|-----------|--------|
/// | Display | headlineLarge   | 32/40     | 700    |
/// | H1      | headlineMedium  | 24/32     | 600    |
/// | H2      | headlineSmall   | 20/28     | 600    |
/// | H3      | titleLarge      | 18/26     | 600    |
/// | H4      | titleMedium     | 16/24     | 600    |
/// | Subhead | titleSmall      | 14/20     | 600    |
/// | Body L  | bodyLarge       | 16/24     | 400    |
/// | Body    | bodyMedium      | 14/20     | 400    |
/// | Caption | bodySmall       | 12/16     | 400    |
/// | Button  | labelLarge      | 14/20     | 600    |
/// | Label   | labelMedium     | 13/18     | 500    |
/// | Overline| labelSmall      | 11/16     | 600    |
///
/// Table, menu, KPI and code styles have no Material slot and are exposed as
/// static getters.
class DsTypography {
  DsTypography._();

  static const String fontFamily = 'Roboto';

  /// Fallback stack for [code]; no monospace font is bundled.
  static const List<String> monoFallback = <String>[
    'Roboto Mono',
    'Consolas',
    'Menlo',
    'monospace',
  ];

  static const List<FontFeature> _tabular = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static final TextTheme textTheme = build(
    primary: DsColors.textPrimary,
    secondary: DsColors.textSecondary,
  );

  static final TextTheme darkTextTheme = build(
    primary: DsColors.textPrimaryDark,
    secondary: DsColors.textSecondaryDark,
  );

  static TextTheme build({required Color primary, required Color secondary}) {
    TextStyle s(
      double size,
      double line,
      FontWeight weight, {
      Color? color,
      double spacing = 0,
    }) {
      return TextStyle(
        fontSize: size,
        height: line / size,
        fontWeight: weight,
        letterSpacing: spacing,
        color: color ?? primary,
      );
    }

    return TextTheme(
      displayLarge: s(32, 40, FontWeight.w700, spacing: -0.5),
      displayMedium: s(32, 40, FontWeight.w700, spacing: -0.5),
      displaySmall: s(24, 32, FontWeight.w600, spacing: -0.25),
      headlineLarge: s(32, 40, FontWeight.w700, spacing: -0.5),
      headlineMedium: s(24, 32, FontWeight.w600, spacing: -0.25),
      headlineSmall: s(20, 28, FontWeight.w600),
      titleLarge: s(18, 26, FontWeight.w600),
      titleMedium: s(16, 24, FontWeight.w600),
      titleSmall: s(14, 20, FontWeight.w600),
      bodyLarge: s(16, 24, FontWeight.w400),
      bodyMedium: s(14, 20, FontWeight.w400),
      bodySmall: s(12, 16, FontWeight.w400, color: secondary),
      labelLarge: s(14, 20, FontWeight.w600),
      labelMedium: s(13, 18, FontWeight.w500),
      labelSmall: s(11, 16, FontWeight.w600, color: secondary, spacing: 0.5),
    );
  }

  /// Table cell. Tabular figures keep numeric columns aligned.
  static const TextStyle table = TextStyle(
    fontSize: 13,
    height: 20 / 13,
    fontWeight: FontWeight.w400,
    fontFeatures: _tabular,
  );

  /// Table column header.
  static const TextStyle tableHeader = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  /// Sidebar and menu items.
  static const TextStyle menu = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
  );

  /// Headline number of a KPI card.
  static const TextStyle kpi = TextStyle(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    fontFeatures: _tabular,
  );

  /// Identifiers, tokens and raw values.
  static const TextStyle code = TextStyle(
    fontSize: 13,
    height: 20 / 13,
    fontWeight: FontWeight.w400,
    fontFamilyFallback: monoFallback,
  );
}

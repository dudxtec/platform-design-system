import 'package:flutter/material.dart';

import 'ds_palette.dart';

/// Semantic intent of a component (badge, alert, toast, KPI delta...).
enum DsTone { neutral, primary, success, warning, danger, info }

/// Colours of one [DsTone].
@immutable
class DsToneColors {
  const DsToneColors({
    required this.solid,
    required this.onSolid,
    required this.text,
    required this.subtle,
    required this.border,
  });

  /// Strong fill (solid badge, destructive button).
  final Color solid;

  /// Foreground on top of [solid].
  final Color onSolid;

  /// Text/icon on top of [subtle] or of a surface. At least 4.5:1 on both.
  final Color text;

  /// Soft background (badge, alert, selected row).
  final Color subtle;

  /// Border that pairs with [subtle].
  final Color border;

  static DsToneColors lerp(DsToneColors a, DsToneColors b, double t) {
    return DsToneColors(
      solid: Color.lerp(a.solid, b.solid, t)!,
      onSolid: Color.lerp(a.onSolid, b.onSolid, t)!,
      text: Color.lerp(a.text, b.text, t)!,
      subtle: Color.lerp(a.subtle, b.subtle, t)!,
      border: Color.lerp(a.border, b.border, t)!,
    );
  }
}

/// Semantic colour tokens, resolved per brightness.
///
/// Read them with `context.dsColors`. Unlike the static `DsColors`, these
/// follow the active theme, so widgets built on them work in dark mode.
@immutable
class DsColorTokens extends ThemeExtension<DsColorTokens> {
  const DsColorTokens({
    required this.canvas,
    required this.surface,
    required this.surfaceSubtle,
    required this.surfaceHover,
    required this.surfaceSelected,
    required this.surfaceInverse,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textInverse,
    required this.primary,
    required this.primaryHover,
    required this.primaryPressed,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.focusRing,
    required this.scrim,
    required this.shadow,
    required this.neutralTone,
    required this.primaryTone,
    required this.successTone,
    required this.warningTone,
    required this.dangerTone,
    required this.infoTone,
  });

  /// Page background, behind cards.
  final Color canvas;

  /// Cards, sidebar, top bar, dialogs, menus.
  final Color surface;

  /// Table header, input fill, zebra, nested areas.
  final Color surfaceSubtle;

  /// Hovered row or nav item; disabled input fill.
  final Color surfaceHover;

  /// Selected row or nav item.
  final Color surfaceSelected;

  /// Tooltip and toast background.
  final Color surfaceInverse;

  /// Decorative separators and card outlines.
  final Color border;

  /// Borders that identify a control (inputs, secondary buttons). 3:1 minimum.
  final Color borderStrong;

  final Color textPrimary;

  /// Supporting text, table headers, labels.
  final Color textSecondary;

  /// Placeholders and captions. Only on [surface].
  final Color textTertiary;
  final Color textDisabled;

  /// Text on [surfaceInverse].
  final Color textInverse;

  /// Primary action and brand.
  final Color primary;
  final Color primaryHover;
  final Color primaryPressed;
  final Color onPrimary;

  /// Brand highlight. Sparingly; never for status and never with white text.
  final Color accent;
  final Color onAccent;

  final Color focusRing;
  final Color scrim;
  final Color shadow;

  final DsToneColors neutralTone;
  final DsToneColors primaryTone;
  final DsToneColors successTone;
  final DsToneColors warningTone;
  final DsToneColors dangerTone;
  final DsToneColors infoTone;

  DsToneColors tone(DsTone tone) {
    return switch (tone) {
      DsTone.neutral => neutralTone,
      DsTone.primary => primaryTone,
      DsTone.success => successTone,
      DsTone.warning => warningTone,
      DsTone.danger => dangerTone,
      DsTone.info => infoTone,
    };
  }

  /// Tokens of the theme in [context]; falls back to [light] when the app
  /// does not use `DsTheme`.
  static DsColorTokens of(BuildContext context) {
    return Theme.of(context).extension<DsColorTokens>() ?? light;
  }

  static const DsColorTokens light = DsColorTokens(
    canvas: DsPalette.neutral50,
    surface: DsPalette.white,
    surfaceSubtle: DsPalette.neutral25,
    surfaceHover: DsPalette.neutral100,
    surfaceSelected: DsPalette.teal50,
    surfaceInverse: DsPalette.neutral800,
    border: DsPalette.neutral200,
    borderStrong: DsPalette.neutral400,
    textPrimary: DsPalette.neutral800,
    textSecondary: DsPalette.neutral600,
    textTertiary: DsPalette.neutral500,
    textDisabled: DsPalette.neutral400,
    textInverse: DsPalette.white,
    primary: DsPalette.teal600,
    primaryHover: DsPalette.teal700,
    primaryPressed: DsPalette.teal800,
    onPrimary: DsPalette.white,
    accent: DsPalette.orange500,
    onAccent: DsPalette.neutral900,
    focusRing: DsPalette.teal500,
    scrim: Color(0x8012181F),
    shadow: Color(0xFF12181F),
    neutralTone: DsToneColors(
      solid: DsPalette.neutral600,
      onSolid: DsPalette.white,
      text: DsPalette.neutral700,
      subtle: DsPalette.neutral100,
      border: DsPalette.neutral300,
    ),
    primaryTone: DsToneColors(
      solid: DsPalette.teal600,
      onSolid: DsPalette.white,
      text: DsPalette.teal700,
      subtle: DsPalette.teal50,
      border: DsPalette.teal200,
    ),
    successTone: DsToneColors(
      solid: DsPalette.green700,
      onSolid: DsPalette.white,
      text: DsPalette.green800,
      subtle: DsPalette.green50,
      border: DsPalette.green200,
    ),
    warningTone: DsToneColors(
      solid: DsPalette.amber500,
      onSolid: DsPalette.neutral900,
      text: DsPalette.amber800,
      subtle: DsPalette.amber50,
      border: DsPalette.amber200,
    ),
    dangerTone: DsToneColors(
      solid: DsPalette.red800,
      onSolid: DsPalette.white,
      text: DsPalette.red900,
      subtle: DsPalette.red50,
      border: DsPalette.red200,
    ),
    infoTone: DsToneColors(
      solid: DsPalette.blue700,
      onSolid: DsPalette.white,
      text: DsPalette.blue800,
      subtle: DsPalette.blue50,
      border: DsPalette.blue200,
    ),
  );

  static const DsColorTokens dark = DsColorTokens(
    canvas: DsPalette.neutral950,
    surface: Color(0xFF1A1E21),
    surfaceSubtle: Color(0xFF1F2428),
    surfaceHover: Color(0xFF252B30),
    surfaceSelected: Color(0xFF003D3E),
    surfaceInverse: Color(0xFFE8ECF0),
    border: Color(0xFF2D3740),
    borderStrong: DsPalette.neutral500,
    textPrimary: Color(0xFFE8ECF0),
    textSecondary: Color(0xFFB4BDC7),
    textTertiary: Color(0xFF9AA5B1),
    textDisabled: DsPalette.neutral500,
    textInverse: DsPalette.neutral900,
    primary: DsPalette.teal400,
    primaryHover: DsPalette.teal300,
    primaryPressed: DsPalette.teal200,
    onPrimary: DsPalette.neutral950,
    accent: DsPalette.orange500,
    onAccent: DsPalette.neutral950,
    focusRing: DsPalette.teal300,
    scrim: Color(0xB3000000),
    shadow: DsPalette.black,
    neutralTone: DsToneColors(
      solid: DsPalette.neutral400,
      onSolid: DsPalette.neutral950,
      text: Color(0xFFB4BDC7),
      subtle: Color(0xFF252B30),
      border: Color(0xFF3E4C59),
    ),
    primaryTone: DsToneColors(
      solid: DsPalette.teal400,
      onSolid: DsPalette.neutral950,
      text: DsPalette.teal300,
      subtle: Color(0xFF003D3E),
      border: DsPalette.teal800,
    ),
    successTone: DsToneColors(
      solid: DsPalette.green400,
      onSolid: DsPalette.neutral950,
      text: DsPalette.green300,
      subtle: Color(0xFF14301A),
      border: Color(0xFF1F4D27),
    ),
    warningTone: DsToneColors(
      solid: DsPalette.amber400,
      onSolid: DsPalette.neutral950,
      text: DsPalette.amber300,
      subtle: Color(0xFF3A2A0A),
      border: Color(0xFF5C4310),
    ),
    dangerTone: DsToneColors(
      solid: DsPalette.red300,
      onSolid: DsPalette.neutral950,
      text: DsPalette.red300,
      subtle: Color(0xFF3A1616),
      border: Color(0xFF5E2323),
    ),
    infoTone: DsToneColors(
      solid: DsPalette.blue300,
      onSolid: DsPalette.neutral950,
      text: DsPalette.blue300,
      subtle: Color(0xFF0B2A3D),
      border: Color(0xFF12425F),
    ),
  );

  @override
  DsColorTokens copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceSubtle,
    Color? surfaceHover,
    Color? surfaceSelected,
    Color? surfaceInverse,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textInverse,
    Color? primary,
    Color? primaryHover,
    Color? primaryPressed,
    Color? onPrimary,
    Color? accent,
    Color? onAccent,
    Color? focusRing,
    Color? scrim,
    Color? shadow,
    DsToneColors? neutralTone,
    DsToneColors? primaryTone,
    DsToneColors? successTone,
    DsToneColors? warningTone,
    DsToneColors? dangerTone,
    DsToneColors? infoTone,
  }) {
    return DsColorTokens(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      surfaceSelected: surfaceSelected ?? this.surfaceSelected,
      surfaceInverse: surfaceInverse ?? this.surfaceInverse,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      textInverse: textInverse ?? this.textInverse,
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      focusRing: focusRing ?? this.focusRing,
      scrim: scrim ?? this.scrim,
      shadow: shadow ?? this.shadow,
      neutralTone: neutralTone ?? this.neutralTone,
      primaryTone: primaryTone ?? this.primaryTone,
      successTone: successTone ?? this.successTone,
      warningTone: warningTone ?? this.warningTone,
      dangerTone: dangerTone ?? this.dangerTone,
      infoTone: infoTone ?? this.infoTone,
    );
  }

  @override
  DsColorTokens lerp(ThemeExtension<DsColorTokens>? other, double t) {
    if (other is! DsColorTokens) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return DsColorTokens(
      canvas: c(canvas, other.canvas),
      surface: c(surface, other.surface),
      surfaceSubtle: c(surfaceSubtle, other.surfaceSubtle),
      surfaceHover: c(surfaceHover, other.surfaceHover),
      surfaceSelected: c(surfaceSelected, other.surfaceSelected),
      surfaceInverse: c(surfaceInverse, other.surfaceInverse),
      border: c(border, other.border),
      borderStrong: c(borderStrong, other.borderStrong),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textTertiary: c(textTertiary, other.textTertiary),
      textDisabled: c(textDisabled, other.textDisabled),
      textInverse: c(textInverse, other.textInverse),
      primary: c(primary, other.primary),
      primaryHover: c(primaryHover, other.primaryHover),
      primaryPressed: c(primaryPressed, other.primaryPressed),
      onPrimary: c(onPrimary, other.onPrimary),
      accent: c(accent, other.accent),
      onAccent: c(onAccent, other.onAccent),
      focusRing: c(focusRing, other.focusRing),
      scrim: c(scrim, other.scrim),
      shadow: c(shadow, other.shadow),
      neutralTone: DsToneColors.lerp(neutralTone, other.neutralTone, t),
      primaryTone: DsToneColors.lerp(primaryTone, other.primaryTone, t),
      successTone: DsToneColors.lerp(successTone, other.successTone, t),
      warningTone: DsToneColors.lerp(warningTone, other.warningTone, t),
      dangerTone: DsToneColors.lerp(dangerTone, other.dangerTone, t),
      infoTone: DsToneColors.lerp(infoTone, other.infoTone, t),
    );
  }
}

extension DsThemeContext on BuildContext {
  /// Semantic colour tokens of the active theme.
  DsColorTokens get dsColors => DsColorTokens.of(this);
}

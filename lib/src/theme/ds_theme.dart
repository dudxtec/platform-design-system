import 'package:flutter/material.dart';

import '../tokens/ds_colors.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_typography.dart';

class DsTheme {
  DsTheme._();

  static ThemeData light() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: DsColors.primary,
      primary: DsColors.primary,
      onPrimary: DsColors.textOnPrimary,
      secondary: DsColors.accent,
      error: DsColors.error,
      surface: DsColors.surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: DsColors.background,
      fontFamily: 'Roboto',
      textTheme: DsTypography.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: DsColors.background,
        foregroundColor: DsColors.primary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: DsColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DsRadius.md),
          side: const BorderSide(color: DsColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DsColors.primary,
          foregroundColor: DsColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: DsSpacing.xl,
            vertical: DsSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DsRadius.sm),
          ),
          textStyle: DsTypography.textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DsColors.primary,
          side: const BorderSide(color: DsColors.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: DsSpacing.xl,
            vertical: DsSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DsRadius.sm),
          ),
          textStyle: DsTypography.textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DsColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DsRadius.sm),
          borderSide: const BorderSide(color: DsColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DsRadius.sm),
          borderSide: const BorderSide(color: DsColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DsRadius.sm),
          borderSide: const BorderSide(color: DsColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DsSpacing.md,
          vertical: DsSpacing.sm,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: DsColors.divider,
        thickness: 1,
        space: 0,
      ),
    );
  }

  static ThemeData dark() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: DsColors.primary,
      primary: DsColors.primaryLight,
      onPrimary: DsColors.textOnPrimary,
      secondary: DsColors.accent,
      error: DsColors.error,
      surface: DsColors.surfaceDark,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: DsColors.backgroundDark,
      fontFamily: 'Roboto',
      textTheme: DsTypography.darkTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: DsColors.backgroundDark,
        foregroundColor: DsColors.primaryLight,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: DsColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DsRadius.md),
          side: const BorderSide(color: DsColors.dividerDark),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DsColors.primaryLight,
          foregroundColor: DsColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: DsSpacing.xl,
            vertical: DsSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DsRadius.sm),
          ),
          textStyle: DsTypography.darkTextTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DsColors.primaryLight,
          side: const BorderSide(color: DsColors.primaryLight),
          padding: const EdgeInsets.symmetric(
            horizontal: DsSpacing.xl,
            vertical: DsSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DsRadius.sm),
          ),
          textStyle: DsTypography.darkTextTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DsColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DsRadius.sm),
          borderSide: const BorderSide(color: DsColors.dividerDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DsRadius.sm),
          borderSide: const BorderSide(color: DsColors.dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DsRadius.sm),
          borderSide: const BorderSide(color: DsColors.primaryLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DsSpacing.md,
          vertical: DsSpacing.sm,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: DsColors.dividerDark,
        thickness: 1,
        space: 0,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_foundations.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_typography.dart';

class DsTheme {
  DsTheme._();

  static ThemeData light() => _build(Brightness.light, DsColorTokens.light);

  static ThemeData dark() => _build(Brightness.dark, DsColorTokens.dark);

  static ThemeData _build(Brightness brightness, DsColorTokens c) {
    final TextTheme text = DsTypography.build(
      primary: c.textPrimary,
      secondary: c.textSecondary,
    );

    final ColorScheme colorScheme =
        ColorScheme.fromSeed(
          seedColor: c.primary,
          brightness: brightness,
        ).copyWith(
          primary: c.primary,
          onPrimary: c.onPrimary,
          primaryContainer: c.primaryTone.subtle,
          onPrimaryContainer: c.primaryTone.text,
          secondary: c.accent,
          onSecondary: c.onAccent,
          secondaryContainer: c.primaryTone.subtle,
          onSecondaryContainer: c.primaryTone.text,
          tertiary: c.infoTone.solid,
          onTertiary: c.infoTone.onSolid,
          error: c.dangerTone.solid,
          onError: c.dangerTone.onSolid,
          errorContainer: c.dangerTone.subtle,
          onErrorContainer: c.dangerTone.text,
          surface: c.surface,
          onSurface: c.textPrimary,
          onSurfaceVariant: c.textSecondary,
          surfaceContainerLowest: c.surface,
          surfaceContainerLow: c.surfaceSubtle,
          surfaceContainer: c.surface,
          surfaceContainerHigh: c.surface,
          surfaceContainerHighest: c.surfaceHover,
          inverseSurface: c.surfaceInverse,
          onInverseSurface: c.textInverse,
          outline: c.borderStrong,
          outlineVariant: c.border,
          shadow: c.shadow,
          scrim: c.scrim,
          surfaceTint: Colors.transparent,
        );

    final RoundedRectangleBorder controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DsRadius.sm),
    );
    const EdgeInsets controlPadding = EdgeInsets.symmetric(
      horizontal: DsSpacing.s16,
    );
    const Size controlSize = Size(64, DsSizes.controlMd);

    WidgetStateProperty<Color?> solidBackground(
      Color base,
      Color hover,
      Color pressed,
    ) {
      return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) return c.surfaceHover;
        if (states.contains(WidgetState.pressed)) return pressed;
        if (states.contains(WidgetState.hovered)) return hover;
        return base;
      });
    }

    WidgetStateProperty<Color?> foreground(Color base) {
      return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) return c.textDisabled;
        return base;
      });
    }

    final ButtonStyle solidButton = ButtonStyle(
      backgroundColor: solidBackground(
        c.primary,
        c.primaryHover,
        c.primaryPressed,
      ),
      foregroundColor: foreground(c.onPrimary),
      overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      elevation: const WidgetStatePropertyAll<double>(0),
      minimumSize: const WidgetStatePropertyAll<Size>(controlSize),
      padding: const WidgetStatePropertyAll<EdgeInsets>(controlPadding),
      shape: WidgetStatePropertyAll<OutlinedBorder>(controlShape),
      textStyle: WidgetStatePropertyAll<TextStyle?>(text.labelLarge),
      iconSize: const WidgetStatePropertyAll<double>(DsSizes.iconMd),
    );

    OutlineInputBorder inputBorder(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(DsRadius.sm),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final RoundedRectangleBorder floatingShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DsRadius.sm),
      side: BorderSide(color: c.border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      extensions: <ThemeExtension<dynamic>>[c],
      scaffoldBackgroundColor: c.canvas,
      canvasColor: c.surface,
      fontFamily: DsTypography.fontFamily,
      textTheme: text,
      splashFactory: InkRipple.splashFactory,
      // Small visuals (32 px chips, 36 px links) keep a touch area of 44 px+.
      materialTapTargetSize: MaterialTapTargetSize.padded,
      hoverColor: c.surfaceHover,
      focusColor: c.focusRing.withValues(alpha: 0.16),
      disabledColor: c.textDisabled,
      dividerColor: c.border,
      iconTheme: IconThemeData(color: c.textSecondary, size: DsSizes.iconLg),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: DsSizes.topBarHeight,
        titleTextStyle: text.titleLarge,
        shape: Border(bottom: BorderSide(color: c.border)),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DsRadius.md),
          side: BorderSide(color: c.border),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: solidButton),
      filledButtonTheme: FilledButtonThemeData(style: solidButton),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.pressed)) return c.surfaceHover;
            if (states.contains(WidgetState.hovered)) return c.surfaceSubtle;
            return c.surface;
          }),
          foregroundColor: foreground(c.textPrimary),
          overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
          side: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(color: c.border);
            }
            return BorderSide(color: c.borderStrong);
          }),
          minimumSize: const WidgetStatePropertyAll<Size>(controlSize),
          padding: const WidgetStatePropertyAll<EdgeInsets>(controlPadding),
          shape: WidgetStatePropertyAll<OutlinedBorder>(controlShape),
          textStyle: WidgetStatePropertyAll<TextStyle?>(text.labelLarge),
          iconSize: const WidgetStatePropertyAll<double>(DsSizes.iconMd),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: foreground(c.primary),
          overlayColor: WidgetStateProperty.resolveWith((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.pressed)) return c.surfaceSelected;
            if (states.contains(WidgetState.hovered)) return c.surfaceHover;
            return Colors.transparent;
          }),
          minimumSize: const WidgetStatePropertyAll<Size>(controlSize),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: DsSpacing.s12),
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(controlShape),
          textStyle: WidgetStatePropertyAll<TextStyle?>(text.labelLarge),
          iconSize: const WidgetStatePropertyAll<double>(DsSizes.iconMd),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: foreground(c.textSecondary),
          iconSize: const WidgetStatePropertyAll<double>(DsSizes.iconLg),
          shape: WidgetStatePropertyAll<OutlinedBorder>(controlShape),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        elevation: DsElevation.level2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DsRadius.md),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) return c.surfaceHover;
          return c.surfaceSubtle;
        }),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DsSpacing.s12,
          vertical: DsSpacing.s12,
        ),
        border: inputBorder(c.borderStrong),
        enabledBorder: inputBorder(c.borderStrong),
        disabledBorder: inputBorder(c.border),
        focusedBorder: inputBorder(c.primary, 2),
        errorBorder: inputBorder(c.dangerTone.solid),
        focusedErrorBorder: inputBorder(c.dangerTone.solid, 2),
        labelStyle: text.bodyMedium?.copyWith(color: c.textSecondary),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((
          Set<WidgetState> states,
        ) {
          final Color color = states.contains(WidgetState.error)
              ? c.dangerTone.text
              : states.contains(WidgetState.focused)
              ? c.primary
              : c.textSecondary;
          return TextStyle(color: color, fontWeight: FontWeight.w500);
        }),
        hintStyle: text.bodyMedium?.copyWith(color: c.textTertiary),
        helperStyle: text.bodySmall,
        errorStyle: text.bodySmall?.copyWith(color: c.dangerTone.text),
        errorMaxLines: 2,
        prefixIconColor: c.textSecondary,
        suffixIconColor: c.textSecondary,
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 0),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: DsElevation.level3,
        shadowColor: c.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DsRadius.md),
        ),
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium?.copyWith(color: c.textSecondary),
        actionsPadding: const EdgeInsets.fromLTRB(
          DsSpacing.s24,
          0,
          DsSpacing.s24,
          DsSpacing.s24,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: DsElevation.level3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DsRadius.lg),
          ),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: DsElevation.level3,
        scrimColor: c.scrim,
        shape: const RoundedRectangleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surfaceInverse,
        contentTextStyle: text.bodyMedium?.copyWith(color: c.textInverse),
        actionTextColor: c.textInverse,
        elevation: DsElevation.level4,
        shape: controlShape,
        insetPadding: const EdgeInsets.all(DsSpacing.s16),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.surfaceInverse,
          borderRadius: BorderRadius.circular(DsRadius.xs),
        ),
        textStyle: text.bodySmall?.copyWith(color: c.textInverse),
        padding: const EdgeInsets.symmetric(
          horizontal: DsSpacing.s8,
          vertical: DsSpacing.s4,
        ),
        waitDuration: const Duration(milliseconds: 400),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.primary,
        unselectedLabelColor: c.textSecondary,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: c.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: c.border,
        tabAlignment: TabAlignment.start,
        overlayColor: WidgetStatePropertyAll<Color>(c.surfaceHover),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.surfaceSelected,
        // Selected is never colour alone: the tint is only 1.15:1 against the
        // surface, so it also gets a 2 px primary border and a check mark.
        side: WidgetStateBorderSide.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return BorderSide(color: c.primary, width: 2);
          }
          return BorderSide(color: c.borderStrong);
        }),
        showCheckmark: true,
        checkmarkColor: c.primary,
        labelStyle: text.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DsRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s4),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowHeight: DsSizes.tableHeaderHeight,
        dataRowMinHeight: DsSizes.tableRowHeight,
        dataRowMaxHeight: DsSizes.tableRowHeight,
        horizontalMargin: DsSpacing.s16,
        columnSpacing: DsSpacing.s24,
        dividerThickness: 1,
        headingRowColor: WidgetStatePropertyAll<Color>(c.surfaceSubtle),
        headingTextStyle: DsTypography.tableHeader.copyWith(
          color: c.textSecondary,
        ),
        dataTextStyle: DsTypography.table.copyWith(color: c.textPrimary),
        dataRowColor: WidgetStateProperty.resolveWith((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) return c.surfaceSelected;
          if (states.contains(WidgetState.hovered)) return c.surfaceHover;
          return null;
        }),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: DsElevation.level2,
        shadowColor: c.shadow,
        shape: floatingShape,
        textStyle: DsTypography.menu.copyWith(color: c.textPrimary),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(c.surface),
          surfaceTintColor: const WidgetStatePropertyAll<Color>(
            Colors.transparent,
          ),
          elevation: const WidgetStatePropertyAll<double>(DsElevation.level2),
          shadowColor: WidgetStatePropertyAll<Color>(c.shadow),
          shape: WidgetStatePropertyAll<OutlinedBorder>(floatingShape),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: DsElevation.level3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DsRadius.md),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.border,
        circularTrackColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.textSecondary,
        textColor: c.textPrimary,
        titleTextStyle: text.bodyMedium,
        subtitleTextStyle: text.bodySmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: DsSpacing.s16),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll<double>(8),
        radius: const Radius.circular(DsRadius.pill),
        thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.dragged)) {
            return c.textTertiary;
          }
          return c.borderStrong.withValues(alpha: 0.6);
        }),
      ),
    );
  }
}

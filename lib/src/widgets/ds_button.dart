import 'package:flutter/material.dart';

import '../tokens/ds_breakpoints.dart';
import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_foundations.dart';
import '../tokens/ds_palette.dart';
import '../tokens/ds_spacing.dart';

enum DsButtonVariant {
  /// The single main action of a view.
  primary,

  /// Any other action. Neutral outline.
  secondary,

  /// Low-emphasis action: cancel, inline links, toolbar actions.
  ghost,

  /// Destructive confirmation.
  danger,

  /// Filled confirmation of a positive outcome (confirm payment, approve).
  success,
}

enum DsButtonSize {
  /// 32 px, for tables and toolbars.
  sm,

  /// 40 px; grows to 44 px on touch widths.
  md,

  /// Always 44 px. For layouts that are touch-first above 900 px too.
  lg,
}

/// The only button of the design system.
///
/// While [loading] is true the button is disabled, keeps its width and shows
/// a spinner in place of [icon].
class DsButton extends StatelessWidget {
  const DsButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DsButtonVariant.primary,
    this.size = DsButtonSize.md,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final DsButtonVariant variant;
  final DsButtonSize size;
  final IconData? icon;
  final bool loading;

  /// Fill the available width (mobile forms, dialogs on narrow screens).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    final VoidCallback? effectiveOnPressed = loading ? null : onPressed;
    final bool small = size == DsButtonSize.sm;
    // Below desktop width the pointer is a finger: default buttons grow to
    // the minimum touch target.
    final bool touch = MediaQuery.sizeOf(context).width < DsBreakpoints.tablet;
    final double height = small
        ? DsSizes.controlSm
        : touch || size == DsButtonSize.lg
        ? DsSizes.touchTarget
        : DsSizes.controlMd;

    ButtonStyle style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll<Size>(
        Size(expand ? double.infinity : 64, height),
      ),
      padding: small
          ? const WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: DsSpacing.s12),
            )
          : null,
      textStyle: small
          ? WidgetStatePropertyAll<TextStyle?>(
              Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            )
          : null,
    );

    if (variant == DsButtonVariant.danger ||
        variant == DsButtonVariant.success) {
      // Filled buttons use their own fill (white text, 4.5:1 in both themes).
      // `dangerTone.solid` and `successTone.solid` stay for icons and bars.
      final Color fill = variant == DsButtonVariant.danger
          ? c.dangerSolid
          : c.successSolid;
      // Darker, never lighter: the contrast with the white text only grows.
      final Color active = Color.alphaBlend(
        DsPalette.black.withValues(alpha: 0.16),
        fill,
      );
      style = style.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) return c.surfaceHover;
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.pressed)) {
            return active;
          }
          return fill;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) return c.textDisabled;
          return c.onFill;
        }),
      );
    }

    final Widget? leading = loading
        ? SizedBox.square(
            dimension: DsSizes.iconSm,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: c.textDisabled,
            ),
          )
        : icon == null
        ? null
        : Icon(icon);

    final Widget child = leading == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              leading,
              const SizedBox(width: DsSpacing.s8),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final Widget button = switch (variant) {
      DsButtonVariant.primary ||
      DsButtonVariant.danger ||
      DsButtonVariant.success => FilledButton(
        onPressed: effectiveOnPressed,
        style: style,
        child: child,
      ),
      DsButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: style,
        child: child,
      ),
      DsButtonVariant.ghost => TextButton(
        onPressed: effectiveOnPressed,
        style: style,
        child: child,
      ),
    };

    if (!loading) return button;
    return Semantics(
      liveRegion: true,
      label: '$label, carregando',
      child: button,
    );
  }
}

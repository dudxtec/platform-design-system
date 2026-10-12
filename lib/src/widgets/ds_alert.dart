import 'package:flutter/material.dart';

import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_foundations.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';

IconData dsToneIcon(DsTone tone) {
  return switch (tone) {
    DsTone.success => Icons.check_circle_outline,
    DsTone.warning => Icons.warning_amber_outlined,
    DsTone.danger => Icons.error_outline,
    DsTone.neutral || DsTone.primary || DsTone.info => Icons.info_outline,
  };
}

/// Persistent inline message attached to a page or section.
///
/// Use it for context that stays true while the user is on the screen
/// (filter applied, integration unavailable, form-level error). For the
/// result of an action use `DsToast`.
class DsAlert extends StatelessWidget {
  const DsAlert({
    super.key,
    required this.message,
    this.title,
    this.tone = DsTone.info,
    this.action,
    this.onClose,
  });

  final String message;
  final String? title;
  final DsTone tone;

  /// Optional inline action, usually a ghost `DsButton`.
  final Widget? action;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    final DsToneColors colors = c.tone(tone);
    final TextTheme text = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      liveRegion: tone == DsTone.danger || tone == DsTone.warning,
      child: Container(
        padding: const EdgeInsets.all(DsSpacing.s12),
        decoration: BoxDecoration(
          color: colors.subtle,
          borderRadius: BorderRadius.circular(DsRadius.sm),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(dsToneIcon(tone), size: DsSizes.iconLg, color: colors.text),
            const SizedBox(width: DsSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (title != null)
                    Text(
                      title!,
                      style: text.titleSmall?.copyWith(color: c.textPrimary),
                    ),
                  Text(
                    message,
                    style: text.bodyMedium?.copyWith(color: c.textPrimary),
                  ),
                ],
              ),
            ),
            if (action != null) ...<Widget>[
              const SizedBox(width: DsSpacing.s12),
              action!,
            ],
            if (onClose != null)
              IconButton(
                onPressed: onClose,
                tooltip: 'Fechar',
                icon: const Icon(Icons.close),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_foundations.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';

/// Status label for a record (Ativo, Vencida, Pago...).
///
/// The label carries the meaning; colour only reinforces it. Always pass a
/// human label, never a raw API enum.
class DsBadge extends StatelessWidget {
  const DsBadge({
    super.key,
    required this.label,
    this.tone = DsTone.neutral,
    this.icon,
  });

  final String label;
  final DsTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final DsToneColors colors = context.dsColors.tone(tone);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpacing.s8,
        vertical: DsSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: colors.subtle,
        borderRadius: BorderRadius.circular(DsRadius.pill),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: DsSizes.iconSm - 2, color: colors.text),
            const SizedBox(width: DsSpacing.s4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

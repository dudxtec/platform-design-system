import 'package:flutter/material.dart';

import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_density.dart';
import '../tokens/ds_foundations.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_typography.dart';

/// One headline metric of a dashboard.
///
/// [value] arrives already formatted (currency, percentage, count). [delta]
/// is the variation against the comparison period named in [helper].
class DsKpiCard extends StatelessWidget {
  const DsKpiCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.deltaTone = DsTone.neutral,
    this.helper,
    this.onTap,
  });

  final String label;
  final String value;

  /// For example "+12,4%". The sign is part of the text.
  final String? delta;

  /// Whether the variation is good or bad for the business; a rising number
  /// is not always [DsTone.success] (overdue amounts, churn).
  final DsTone deltaTone;

  /// For example "vs. mês anterior" or "32 cobranças".
  final String? helper;

  /// Drill-down to the list behind the number.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    final TextTheme text = Theme.of(context).textTheme;
    final DsToneColors tone = c.tone(deltaTone);

    final Widget content = Padding(
      padding: EdgeInsets.all(
        DsDensity.of(context).isCompact ? DsSpacing.s12 : DsSpacing.s16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: text.labelMedium?.copyWith(color: c.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: DsSizes.iconMd,
                  color: c.textTertiary,
                ),
            ],
          ),
          const SizedBox(height: DsSpacing.s8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: DsTypography.kpi.copyWith(color: c.textPrimary),
            ),
          ),
          if (delta != null || helper != null) ...<Widget>[
            const SizedBox(height: DsSpacing.s8),
            Row(
              children: <Widget>[
                if (delta != null) ...<Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DsSpacing.s4 + DsSpacing.s2,
                      vertical: DsSpacing.s2,
                    ),
                    decoration: BoxDecoration(
                      color: tone.subtle,
                      borderRadius: BorderRadius.circular(DsRadius.xs),
                    ),
                    child: Text(
                      delta!,
                      style: text.bodySmall?.copyWith(
                        color: tone.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: DsSpacing.s8),
                ],
                if (helper != null)
                  Expanded(
                    child: Text(
                      helper!,
                      style: text.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );

    final String semantics = <String>[label, value, ?delta, ?helper].join(', ');

    return Semantics(
      container: true,
      button: onTap != null,
      label: semantics,
      onTap: onTap,
      excludeSemantics: true,
      child: Card(
        child: onTap == null
            ? content
            : InkWell(onTap: onTap, hoverColor: c.surfaceHover, child: content),
      ),
    );
  }
}

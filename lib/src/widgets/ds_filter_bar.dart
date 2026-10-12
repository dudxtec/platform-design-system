import 'package:flutter/material.dart';

import '../tokens/ds_spacing.dart';
import 'ds_button.dart';

/// Filters of a list or report, above the content they affect.
///
/// Text search applies as the user types (debounced by the caller); the other
/// filters apply on change. Pass [onApply] only for expensive queries that
/// must be submitted explicitly, such as report periods.
class DsFilterBar extends StatelessWidget {
  const DsFilterBar({
    super.key,
    required this.children,
    this.activeCount = 0,
    this.onClear,
    this.onApply,
    this.applyLabel = 'Aplicar',
  });

  /// Filter fields. Give each a width (`SizedBox`), search first.
  final List<Widget> children;

  /// Number of filters that differ from the default.
  final int activeCount;

  /// Shown only while [activeCount] is greater than zero.
  final VoidCallback? onClear;
  final VoidCallback? onApply;
  final String applyLabel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DsSpacing.s12,
      runSpacing: DsSpacing.s12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        ...children,
        if (onApply != null)
          DsButton(
            label: applyLabel,
            onPressed: onApply,
            variant: DsButtonVariant.secondary,
          ),
        if (onClear != null && activeCount > 0)
          DsButton(
            label: 'Limpar filtros ($activeCount)',
            onPressed: onClear,
            variant: DsButtonVariant.ghost,
            icon: Icons.close,
          ),
      ],
    );
  }
}

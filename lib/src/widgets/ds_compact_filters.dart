import 'package:flutter/material.dart';

import '../tokens/ds_breakpoints.dart';
import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_foundations.dart';
import '../tokens/ds_spacing.dart';
import 'ds_button.dart';

/// A filter applied to a list, shown as a removable chip.
@immutable
class DsAppliedFilter {
  const DsAppliedFilter({required this.label, required this.onRemove});

  /// What the filter does: "Tags: Sócios", "Nº 1234".
  final String label;
  final VoidCallback onRemove;
}

/// Compact filters of a list, the same on phone, tablet and web.
///
/// One row with the quick [search] and a "Filtros" button (44 px) that opens
/// the rest in a sheet ([showDsFilterSheet]); [appliedFilters] below, each a
/// removable chip, with "Limpar" when there is more than one; and a line with
/// the [resultLabel] on the left and the sort link ([sort], a [DsSortLink]) on
/// the right.
class DsCompactFilters extends StatelessWidget {
  const DsCompactFilters({
    super.key,
    required this.search,
    required this.onOpenFilters,
    this.activeCount = 0,
    this.appliedFilters = const <DsAppliedFilter>[],
    this.onClear,
    this.resultLabel,
    this.sort,
  });

  /// Quick search field. It takes the free width of the first row.
  final Widget search;
  final VoidCallback onOpenFilters;

  /// Filters set in the sheet (not the search). Shown as "Filtros (n)".
  final int activeCount;
  final List<DsAppliedFilter> appliedFilters;

  /// Clears every filter. Shown when two or more chips are applied.
  final VoidCallback? onClear;

  /// "128 pessoas".
  final String? resultLabel;

  /// Usually a [DsSortLink].
  final Widget? sort;

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    final TextTheme text = Theme.of(context).textTheme;
    final bool hasSecondLine = resultLabel != null || sort != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: search),
            const SizedBox(width: DsSpacing.s8),
            _FiltersButton(count: activeCount, onPressed: onOpenFilters),
          ],
        ),
        if (appliedFilters.isNotEmpty) ...<Widget>[
          const SizedBox(height: DsSpacing.s8),
          Wrap(
            spacing: DsSpacing.s8,
            runSpacing: DsSpacing.s4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              for (final DsAppliedFilter filter in appliedFilters)
                _AppliedChip(filter: filter),
              if (onClear != null && appliedFilters.length > 1)
                TextButton(onPressed: onClear, child: const Text('Limpar')),
            ],
          ),
        ],
        if (hasSecondLine) ...<Widget>[
          const SizedBox(height: DsSpacing.s4),
          Row(
            children: <Widget>[
              if (resultLabel != null)
                Expanded(
                  child: Text(
                    resultLabel!,
                    style: text.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                )
              else
                const Spacer(),
              ?sort,
            ],
          ),
        ],
      ],
    );
  }
}

class _FiltersButton extends StatelessWidget {
  const _FiltersButton({required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DsSizes.touchTarget,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.tune, size: DsSizes.iconLg),
        label: Text(count > 0 ? 'Filtros ($count)' : 'Filtros'),
      ),
    );
  }
}

class _AppliedChip extends StatelessWidget {
  const _AppliedChip({required this.filter});

  final DsAppliedFilter filter;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: InputChip(
        label: Text(filter.label),
        onDeleted: filter.onRemove,
        deleteButtonTooltipMessage: 'Remover filtro ${filter.label}',
      ),
    );
  }
}

/// One option of a [DsSortLink].
@immutable
class DsSortOption<T> {
  const DsSortOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// "Ordenar: Nome ↑", a link that opens the sort options.
///
/// Choosing the current option flips the direction; choosing another one sorts
/// by it ascending. The caller keeps the state and applies the sort.
class DsSortLink<T> extends StatelessWidget {
  const DsSortLink({
    super.key,
    required this.options,
    required this.value,
    required this.ascending,
    required this.onSelected,
  });

  final List<DsSortOption<T>> options;
  final T value;
  final bool ascending;

  /// Called with the chosen option; the caller flips or resets the direction.
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    final TextTheme text = Theme.of(context).textTheme;
    String current = '';
    for (final DsSortOption<T> option in options) {
      if (option.value == value) current = option.label;
    }
    final String arrow = ascending ? '↑' : '↓';
    return PopupMenuButton<T>(
      tooltip: 'Ordenar',
      onSelected: onSelected,
      itemBuilder: (_) => <PopupMenuEntry<T>>[
        for (final DsSortOption<T> option in options)
          CheckedPopupMenuItem<T>(
            value: option.value,
            checked: option.value == value,
            child: Text(
              option.value == value
                  ? '${option.label} ($arrow)'
                  : option.label,
            ),
          ),
      ],
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: DsSizes.touchTarget),
        child: Center(
          widthFactor: 1,
          child: Text(
            'Ordenar: $current $arrow',
            style: text.labelLarge?.copyWith(
              color: c.primaryTone.text,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the filters [builder] builds in a bottom sheet on a phone and in a
/// dialog above [DsBreakpoints.mobile].
///
/// The sheet has "Limpar" ([onClear]) and "Aplicar". It completes with `true`
/// when the person applies and `null` when they close it; the caller reads the
/// values it kept while the sheet was open.
Future<bool?> showDsFilterSheet(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  VoidCallback? onClear,
  String applyLabel = 'Aplicar',
}) {
  final bool phone = MediaQuery.sizeOf(context).width < DsBreakpoints.mobile;
  Widget content(BuildContext inner) {
    return _FilterSheetBody(
      title: title,
      applyLabel: applyLabel,
      onClear: onClear,
      builder: builder,
    );
  }

  if (phone) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: content,
    );
  }
  return showDialog<bool>(
    context: context,
    builder: (BuildContext inner) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: DsSizes.dialogSm),
        child: content(inner),
      ),
    ),
  );
}

class _FilterSheetBody extends StatelessWidget {
  const _FilterSheetBody({
    required this.title,
    required this.applyLabel,
    required this.builder,
    this.onClear,
  });

  final String title;
  final String applyLabel;
  final WidgetBuilder builder;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        DsSpacing.s16,
        DsSpacing.s8,
        DsSpacing.s16,
        DsSpacing.s16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text(title, style: text.titleMedium)),
                if (onClear != null)
                  TextButton(
                    onPressed: () {
                      onClear!();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Limpar'),
                  ),
              ],
            ),
            const SizedBox(height: DsSpacing.s12),
            builder(context),
            const SizedBox(height: DsSpacing.s16),
            DsButton(
              label: applyLabel,
              size: DsButtonSize.lg,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }
}

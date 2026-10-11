import 'package:flutter/material.dart';

import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_spacing.dart';
import 'ds_button.dart';
import 'ds_state_view.dart';

enum DsDataState { ready, loading, empty, error }

/// Standard listing: toolbar, table, states and pagination in one card.
///
/// It wraps Material's [DataTable] (styled by `DsTheme`), so sorting and row
/// selection use the regular [DataColumn.onSort] and [DataRow.onSelectChanged]
/// callbacks. When rows are selected the toolbar is replaced by the bulk
/// action bar.
///
/// Inside a bounded height (`DsPage(scrollable: false)`) the header and the
/// pagination stay pinned and only the rows scroll.
class DsDataTable extends StatelessWidget {
  const DsDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.state = DsDataState.ready,
    this.refreshing = false,
    this.toolbar,
    this.selectedCount = 0,
    this.bulkActions = const <Widget>[],
    this.onClearSelection,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSelectAll,
    this.pagination,
    this.emptyState,
    this.errorState,
  });

  final List<DataColumn> columns;
  final List<DataRow> rows;
  final DsDataState state;

  /// Reloading with rows already on screen (page change, sort, filter). Keeps
  /// the rows and shows a progress line instead of replacing the table.
  final bool refreshing;

  /// Quick search and table-level actions (export, column settings).
  final Widget? toolbar;
  final int selectedCount;

  /// Actions over the selected rows. Destructive ones last.
  final List<Widget> bulkActions;
  final VoidCallback? onClearSelection;
  final int? sortColumnIndex;
  final bool sortAscending;
  final ValueSetter<bool?>? onSelectAll;

  /// Usually a `DsPagination`.
  final Widget? pagination;
  final Widget? emptyState;
  final Widget? errorState;

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;

    return Card(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool bounded = constraints.hasBoundedHeight;

          Widget sized(Widget child) {
            return bounded
                ? Expanded(child: child)
                : SizedBox(height: 280, child: child);
          }

          final Widget table = LayoutBuilder(
            builder: (BuildContext context, BoxConstraints inner) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: inner.maxWidth),
                  child: DataTable(
                    columns: columns,
                    rows: rows,
                    sortColumnIndex: sortColumnIndex,
                    sortAscending: sortAscending,
                    onSelectAll: onSelectAll,
                    showCheckboxColumn: onSelectAll != null,
                  ),
                ),
              );
            },
          );

          final Widget body = switch (state) {
            DsDataState.loading => sized(const DsLoadingState()),
            DsDataState.error => sized(errorState ?? const DsErrorState()),
            DsDataState.empty => sized(
              emptyState ??
                  const DsEmptyState(title: 'Nenhum registro encontrado'),
            ),
            DsDataState.ready =>
              bounded
                  ? Expanded(child: SingleChildScrollView(child: table))
                  : table,
          };

          final bool selecting = selectedCount > 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            children: <Widget>[
              if (selecting)
                _BulkBar(
                  count: selectedCount,
                  actions: bulkActions,
                  onClear: onClearSelection,
                )
              else if (toolbar != null)
                Padding(
                  padding: const EdgeInsets.all(DsSpacing.s12),
                  child: toolbar,
                ),
              if (selecting || toolbar != null) const Divider(),
              SizedBox(
                height: 2,
                child: refreshing
                    ? const LinearProgressIndicator(minHeight: 2)
                    : null,
              ),
              body,
              if (pagination != null && state == DsDataState.ready) ...<Widget>[
                Divider(color: c.border),
                pagination!,
              ],
            ],
          );
        },
      ),
    );
  }
}

class _BulkBar extends StatelessWidget {
  const _BulkBar({required this.count, required this.actions, this.onClear});

  final int count;
  final List<Widget> actions;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    return ColoredBox(
      color: c.surfaceSelected,
      child: Padding(
        padding: const EdgeInsets.all(DsSpacing.s12),
        child: Wrap(
          spacing: DsSpacing.s8,
          runSpacing: DsSpacing.s8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s4),
                child: Text(
                  count == 1 ? '1 selecionado' : '$count selecionados',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: c.primaryTone.text),
                ),
              ),
            ),
            ...actions,
            if (onClear != null)
              DsButton(
                label: 'Limpar seleção',
                onPressed: onClear,
                variant: DsButtonVariant.ghost,
                size: DsButtonSize.sm,
              ),
          ],
        ),
      ),
    );
  }
}

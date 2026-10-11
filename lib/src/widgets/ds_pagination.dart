import 'package:flutter/material.dart';

import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_spacing.dart';

/// Footer of a paginated list: range, page size and page navigation.
///
/// Pages are 1-based. Pagination is always server-side; sorting and filters
/// must be applied by the server too, never on the current page only.
class DsPagination extends StatelessWidget {
  const DsPagination({
    super.key,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.onPageChanged,
    this.pageSizeOptions = const <int>[20, 50, 100],
    this.onPageSizeChanged,
  });

  final int page;
  final int pageSize;
  final int totalItems;
  final ValueChanged<int> onPageChanged;
  final List<int> pageSizeOptions;

  /// When null the page-size selector is hidden.
  final ValueChanged<int>? onPageSizeChanged;

  int get pageCount => totalItems == 0 ? 1 : (totalItems / pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    final TextStyle? style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: c.textSecondary);

    final int first = totalItems == 0 ? 0 : (page - 1) * pageSize + 1;
    final int last = (page * pageSize).clamp(0, totalItems);
    final bool hasPrevious = page > 1;
    final bool hasNext = page < pageCount;

    Widget nav(String tooltip, IconData icon, int target, bool enabled) {
      return IconButton(
        tooltip: tooltip,
        icon: Icon(icon),
        visualDensity: VisualDensity.compact,
        onPressed: enabled ? () => onPageChanged(target) : null,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpacing.s16,
        vertical: DsSpacing.s8,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: DsSpacing.s16,
        runSpacing: DsSpacing.s8,
        children: <Widget>[
          Semantics(
            liveRegion: true,
            child: Text('$first–$last de $totalItems', style: style),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (onPageSizeChanged != null) ...<Widget>[
                Text('Por página', style: style),
                const SizedBox(width: DsSpacing.s8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: pageSize,
                    isDense: true,
                    style: style?.copyWith(color: c.textPrimary),
                    items: <DropdownMenuItem<int>>[
                      for (final int option in pageSizeOptions)
                        DropdownMenuItem<int>(
                          value: option,
                          child: Text('$option'),
                        ),
                    ],
                    onChanged: (int? value) {
                      if (value != null) onPageSizeChanged!(value);
                    },
                  ),
                ),
                const SizedBox(width: DsSpacing.s16),
              ],
              nav('Primeira página', Icons.first_page, 1, hasPrevious),
              nav('Página anterior', Icons.chevron_left, page - 1, hasPrevious),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s8),
                child: Text('Página $page de $pageCount', style: style),
              ),
              nav('Próxima página', Icons.chevron_right, page + 1, hasNext),
              nav('Última página', Icons.last_page, pageCount, hasNext),
            ],
          ),
        ],
      ),
    );
  }
}

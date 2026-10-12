import 'package:flutter/material.dart';

import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import 'ds_button.dart';

/// Date helpers shared by the calendar and the date fields. Dates are shown
/// as `dd/mm/aaaa`.
class DsDate {
  DsDate._();

  static final DateTime defaultFirst = DateTime(1900);
  static final DateTime defaultLast = DateTime(2100, 12, 31);

  static const List<String> months = <String>[
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  /// Initials from Sunday to Saturday; the week starts on Sunday.
  static const List<String> weekdayInitials = <String>[
    'D',
    'S',
    'T',
    'Q',
    'Q',
    'S',
    'S',
  ];

  static const List<String> _weekdays = <String>[
    'domingo',
    'segunda-feira',
    'terça-feira',
    'quarta-feira',
    'quinta-feira',
    'sexta-feira',
    'sábado',
  ];

  /// "Outubro de 2026".
  static String monthYear(DateTime date) {
    final String month = months[date.month - 1];
    return '${month[0].toUpperCase()}${month.substring(1)} de ${date.year}';
  }

  /// "quarta-feira, 21 de outubro de 2026".
  static String full(DateTime date) {
    return '${_weekdays[date.weekday % 7]}, ${date.day} de '
        '${months[date.month - 1]} de ${date.year}';
  }

  static String format(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/'
        '${date.year.toString().padLeft(4, '0')}';
  }

  /// Parses `dd/mm/aaaa`. Returns null for incomplete text and for dates that
  /// do not exist (31/02).
  static DateTime? tryParse(String text) {
    final Match? match = RegExp(
      r'^(\d{2})/(\d{2})/(\d{4})$',
    ).firstMatch(text.trim());
    if (match == null) return null;
    final int day = int.parse(match.group(1)!);
    final int month = int.parse(match.group(2)!);
    final int year = int.parse(match.group(3)!);
    final DateTime date = DateTime(year, month, day);
    final bool exists =
        date.year == year && date.month == month && date.day == day;
    return exists ? date : null;
  }
}

/// Month grid for picking one date.
///
/// Compact on purpose (276 x 312 px) so it fits below a field on a
/// notebook screen. It is the content of the popover opened by `DsDateField`;
/// use it directly only for an always-visible calendar.
///
/// Month and weekday names are in Brazilian Portuguese regardless of the
/// app locale, like every other label of the design system.
class DsCalendar extends StatefulWidget {
  const DsCalendar({
    super.key,
    required this.onSelected,
    this.selected,
    this.rangeStart,
    this.rangeEnd,
    this.firstDate,
    this.lastDate,
    this.onClear,
  });

  final ValueChanged<DateTime> onSelected;
  final DateTime? selected;

  /// Highlights the days between the two ends of a period. Either may be
  /// null while the period is incomplete.
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  /// Defaults to 01/01/1900.
  final DateTime? firstDate;

  /// Defaults to 31/12/2100.
  final DateTime? lastDate;

  /// Shows "Limpar" when set.
  final VoidCallback? onClear;

  static const double width = _cell * 7 + DsSpacing.s12 * 2;
  // Padding, header, gap, weekday row, six weeks, gap, footer.
  static const double height =
      DsSpacing.s12 * 2 +
      _row +
      DsSpacing.s4 +
      24 +
      _row * 6 +
      DsSpacing.s4 +
      _row;

  static const double _cell = 36;
  static const double _row = 32;

  @override
  State<DsCalendar> createState() => _DsCalendarState();
}

class _DsCalendarState extends State<DsCalendar> {
  late DateTime _month;
  bool _pickingYear = false;

  DateTime get _first =>
      DateUtils.dateOnly(widget.firstDate ?? DsDate.defaultFirst);
  DateTime get _last =>
      DateUtils.dateOnly(widget.lastDate ?? DsDate.defaultLast);

  @override
  void initState() {
    super.initState();
    final DateTime anchor = _clamp(
      widget.selected ?? widget.rangeStart ?? widget.rangeEnd ?? DateTime.now(),
    );
    _month = DateTime(anchor.year, anchor.month);
  }

  DateTime _clamp(DateTime date) {
    if (date.isBefore(_first)) return _first;
    if (date.isAfter(_last)) return _last;
    return date;
  }

  bool _enabled(DateTime day) => !day.isBefore(_first) && !day.isAfter(_last);

  bool _canGo(int delta) {
    final DateTime target = DateUtils.addMonthsToMonthDate(_month, delta);
    final DateTime end = DateTime(target.year, target.month + 1, 0);
    return !end.isBefore(_first) && !target.isAfter(_last);
  }

  void _go(int delta) {
    setState(() => _month = DateUtils.addMonthsToMonthDate(_month, delta));
  }

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    final TextTheme text = Theme.of(context).textTheme;
    final DateTime today = DateUtils.dateOnly(DateTime.now());

    return SizedBox(
      width: DsCalendar.width,
      height: DsCalendar.height,
      child: Padding(
        padding: const EdgeInsets.all(DsSpacing.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Fixed heights keep the popover the same size on every platform,
            // whatever the tap-target padding of the buttons.
            SizedBox(
              height: DsCalendar._row,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () =>
                            setState(() => _pickingYear = !_pickingYear),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, DsCalendar._row),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(
                            horizontal: DsSpacing.s8,
                          ),
                          foregroundColor: c.textPrimary,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                DsDate.monthYear(_month),
                                style: text.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              _pickingYear
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              semanticLabel: 'Escolher ano',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!_pickingYear) ...<Widget>[
                    _NavButton(
                      tooltip: 'Mês anterior',
                      icon: Icons.chevron_left,
                      onPressed: _canGo(-1) ? () => _go(-1) : null,
                    ),
                    _NavButton(
                      tooltip: 'Próximo mês',
                      icon: Icons.chevron_right,
                      onPressed: _canGo(1) ? () => _go(1) : null,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: DsSpacing.s4),
            Expanded(
              child: _pickingYear
                  ? _YearGrid(
                      first: _first.year,
                      last: _last.year,
                      current: _month.year,
                      onSelected: (int year) => setState(() {
                        final DateTime target = _clamp(
                          DateTime(year, _month.month),
                        );
                        _month = DateTime(target.year, target.month);
                        _pickingYear = false;
                      }),
                    )
                  : _buildDays(context, today),
            ),
            const SizedBox(height: DsSpacing.s4),
            SizedBox(
              height: DsCalendar._row,
              child: Row(
                children: <Widget>[
                  if (_enabled(today))
                    DsButton(
                      label: 'Hoje',
                      size: DsButtonSize.sm,
                      variant: DsButtonVariant.ghost,
                      onPressed: () => widget.onSelected(today),
                    ),
                  const Spacer(),
                  if (widget.onClear != null)
                    DsButton(
                      label: 'Limpar',
                      size: DsButtonSize.sm,
                      variant: DsButtonVariant.ghost,
                      onPressed: widget.onClear,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDays(BuildContext context, DateTime today) {
    final DsColorTokens c = context.dsColors;
    final TextTheme text = Theme.of(context).textTheme;
    // Columns run from Sunday to Saturday.
    final int offset = DateTime(_month.year, _month.month).weekday % 7;
    final int days = DateUtils.getDaysInMonth(_month.year, _month.month);
    final DateTime? start = widget.rangeStart == null
        ? null
        : DateUtils.dateOnly(widget.rangeStart!);
    final DateTime? end = widget.rangeEnd == null
        ? null
        : DateUtils.dateOnly(widget.rangeEnd!);

    return Column(
      children: <Widget>[
        ExcludeSemantics(
          child: Row(
            children: <Widget>[
              for (int i = 0; i < 7; i++)
                SizedBox(
                  width: DsCalendar._cell,
                  height: 24,
                  child: Center(
                    child: Text(
                      DsDate.weekdayInitials[i],
                      style: text.bodySmall?.copyWith(color: c.textTertiary),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Always six rows, so the popover never changes height.
        for (int week = 0; week < 6; week++)
          Row(
            children: <Widget>[
              for (int weekday = 0; weekday < 7; weekday++)
                _buildCell(
                  context,
                  week * 7 + weekday - offset + 1,
                  days,
                  today,
                  start,
                  end,
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildCell(
    BuildContext context,
    int dayNumber,
    int daysInMonth,
    DateTime today,
    DateTime? start,
    DateTime? end,
  ) {
    const Widget blank = SizedBox(
      width: DsCalendar._cell,
      height: DsCalendar._row,
    );
    if (dayNumber < 1 || dayNumber > daysInMonth) return blank;

    final DsColorTokens c = context.dsColors;
    final DateTime day = DateTime(_month.year, _month.month, dayNumber);
    final bool enabled = _enabled(day);
    final bool selected =
        DateUtils.isSameDay(day, widget.selected) ||
        DateUtils.isSameDay(day, start) ||
        DateUtils.isSameDay(day, end);
    final bool inRange =
        start != null && end != null && day.isAfter(start) && day.isBefore(end);
    final bool isToday = DateUtils.isSameDay(day, today);

    final Color foreground = !enabled
        ? c.textDisabled
        : selected
        ? c.onPrimary
        : isToday
        ? c.primary
        : c.textPrimary;

    return SizedBox(
      width: DsCalendar._cell,
      height: DsCalendar._row,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Semantics(
          button: true,
          enabled: enabled,
          selected: selected,
          label: DsDate.full(day),
          excludeSemantics: true,
          onTap: enabled ? () => widget.onSelected(day) : null,
          child: Material(
            color: selected
                ? c.primary
                : inRange
                ? c.surfaceSelected
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                inRange ? DsRadius.none : DsRadius.sm,
              ),
              side: isToday && !selected
                  ? BorderSide(color: c.primary)
                  : BorderSide.none,
            ),
            child: InkWell(
              onTap: enabled ? () => widget.onSelected(day) : null,
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DsRadius.sm),
              ),
              hoverColor: selected ? c.primaryHover : c.surfaceHover,
              child: Center(
                child: Text(
                  '$dayNumber',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: foreground,
                    fontWeight: selected || isToday
                        ? FontWeight.w600
                        : FontWeight.w400,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.tooltip, required this.icon, this.onPressed});

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: DsCalendar._row,
        height: DsCalendar._row,
      ),
    );
  }
}

class _YearGrid extends StatefulWidget {
  const _YearGrid({
    required this.first,
    required this.last,
    required this.current,
    required this.onSelected,
  });

  final int first;
  final int last;
  final int current;
  final ValueChanged<int> onSelected;

  @override
  State<_YearGrid> createState() => _YearGridState();
}

class _YearGridState extends State<_YearGrid> {
  static const int _columns = 4;
  static const double _rowHeight = 36;

  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    // Open with the current year about two rows from the top.
    final int row = (widget.current - widget.first) ~/ _columns;
    _controller = ScrollController(
      initialScrollOffset: ((row - 2) * _rowHeight).clamp(0, double.infinity),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    final TextStyle? style = Theme.of(context).textTheme.bodyMedium;

    return GridView.builder(
      controller: _controller,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
        mainAxisExtent: _rowHeight,
      ),
      itemCount: widget.last - widget.first + 1,
      itemBuilder: (BuildContext context, int index) {
        final int year = widget.first + index;
        final bool selected = year == widget.current;
        return Padding(
          padding: const EdgeInsets.all(DsSpacing.s2),
          child: Material(
            color: selected ? c.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(DsRadius.sm),
            child: InkWell(
              onTap: () => widget.onSelected(year),
              borderRadius: BorderRadius.circular(DsRadius.sm),
              hoverColor: selected ? c.primaryHover : c.surfaceHover,
              child: Center(
                child: Text(
                  '$year',
                  style: style?.copyWith(
                    color: selected ? c.onPrimary : c.textPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

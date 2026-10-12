import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_foundations.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_typography.dart';
import 'ds_button.dart';
import 'ds_calendar.dart';
import 'ds_form.dart';

/// Helps typing a date without ever rewriting what the user typed.
///
/// It only does two things: refuses characters that cannot be part of a date,
/// and adds the separator when the user is typing at the end of the text
/// ("25" becomes "25/"). Editing in the middle, deleting and pasting leave the
/// text and the cursor exactly where they are.
class DsDateInputFormatter extends TextInputFormatter {
  const DsDateInputFormatter({this.withTime = false});

  final bool withTime;

  static final RegExp _dateChars = RegExp(r'^[0-9/\-]*$');
  static final RegExp _dateTimeChars = RegExp(r'^[0-9/\-: T]*$');
  static final RegExp _day = RegExp(r'^\d{2}$');
  static final RegExp _dayMonth = RegExp(r'^\d{2}/\d{2}$');
  static final RegExp _dateHour = RegExp(r'^\d{2}/\d{2}/\d{4} \d{2}$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String text = newValue.text;
    if (!(withTime ? _dateTimeChars : _dateChars).hasMatch(text)) {
      return oldValue;
    }
    if (text.length > (withTime ? 19 : 10)) return oldValue;

    final bool appendedOneChar =
        text.length == oldValue.text.length + 1 &&
        text.startsWith(oldValue.text) &&
        newValue.selection.isCollapsed &&
        newValue.selection.baseOffset == text.length;
    if (!appendedOneChar) return newValue;

    String? separator;
    if (_day.hasMatch(text) || _dayMonth.hasMatch(text)) {
      separator = '/';
    } else if (withTime && _dateHour.hasMatch(text)) {
      separator = ':';
    }
    if (separator == null) return newValue;

    final String completed = '$text$separator';
    return TextEditingValue(
      text: completed,
      selection: TextSelection.collapsed(offset: completed.length),
    );
  }
}

/// Date input: typed as `dd/mm/aaaa` or picked from a calendar popover
/// anchored to the field.
///
/// Typing is always possible and is the fastest path. The text is never
/// rebuilt while the user edits, so the cursor stays where it is; incomplete
/// dates are allowed while typing and reported by validation. `aaaa-mm-dd` and
/// eight digits are accepted too, and shown as `dd/mm/aaaa` once the field
/// loses focus.
///
/// The calendar opens from the icon or with Alt+Down and closes with Esc; it
/// opens upwards when there is no room below. Closing it without choosing
/// keeps the text.
///
/// With [withTime] the value carries a time (`dd/mm/aaaa hh:mm`); picking a
/// day keeps the time already in the field.
///
/// Validates inside a [Form]: required, well-formed, within range, and then
/// [validator].
class DsDateField extends StatefulWidget {
  const DsDateField({
    super.key,
    required this.label,
    required this.onChanged,
    this.value,
    this.controller,
    this.focusNode,
    this.required = false,
    this.enabled = true,
    this.withTime = false,
    this.showSeconds = false,
    this.firstDate,
    this.lastDate,
    this.rangeStart,
    this.rangeEnd,
    this.helperText,
    this.validator,
    this.onSubmitted,
    this.onPicked,
    this.onCommitted,
    this.calendarInitialDate,
    this.prefixIcon,
    this.compact = false,
    this.textInputAction,
  });

  final String label;
  final DateTime? value;

  /// Called with a date when the text becomes a valid date in range, and
  /// with null when it stops being one.
  final ValueChanged<DateTime?> onChanged;

  /// For callers that need the raw text. When given, its initial text is
  /// used and [value] only applies when it changes afterwards.
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool required;
  final bool enabled;

  /// Accept and show a time after the date.
  final bool withTime;

  /// With [withTime], always show seconds. When false, seconds are shown only
  /// if they are not zero.
  final bool showSeconds;

  /// Defaults to 01/01/1900.
  final DateTime? firstDate;

  /// Defaults to 31/12/2100.
  final DateTime? lastDate;

  /// Period to highlight in the calendar; used by `DsDateRangeField`.
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final String? helperText;

  /// Extra rule, run only for a valid date in range.
  final String? Function(DateTime value)? validator;

  /// Enter in the field.
  final VoidCallback? onSubmitted;

  /// A date chosen in the calendar (not typed). Use it to save right away.
  final ValueChanged<DateTime?>? onPicked;

  /// The user finished editing and the value changed: a date was chosen in
  /// the calendar, Enter was pressed, or focus left the field and its
  /// calendar. Called with null when the field was emptied; not called while
  /// the text is not a valid date. This is the hook for saving on change —
  /// prefer it to listening to [focusNode], which also loses focus to the
  /// calendar's own time input.
  final ValueChanged<DateTime?>? onCommitted;

  /// Month shown when the calendar opens and the field has no valid date.
  /// Defaults to today.
  final DateTime? calendarInitialDate;
  final Widget? prefixIcon;

  /// For table cells: no floating label (the column header names the field;
  /// [label] is still announced) and a 32 px control.
  final bool compact;
  final TextInputAction? textInputAction;

  /// Narrowest width that shows the whole date and the calendar button.
  static const double minWidth = 168;

  /// Narrowest width of a [compact] date-only field.
  static const double compactMinWidth = 132;

  @override
  State<DsDateField> createState() => _DsDateFieldState();
}

class _DsDateFieldState extends State<DsDateField> {
  TextEditingController? _ownController;
  FocusNode? _ownFocus;
  final OverlayPortalController _popover = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();

  /// Where the popover goes, relative to the top-left corner of the field.
  Offset _popoverOffset = Offset.zero;

  /// Text when the calendar was opened; Esc goes back to it.
  String _textAtOpen = '';

  /// Text of the last value reported through `onCommitted`.
  String _committedText = '';

  static const double _timeRowHeight = 56;
  static final RegExp _eightDigits = RegExp(r'^\d{8}$');

  TextEditingController get _text => widget.controller ?? _ownController!;
  FocusNode get _focus => widget.focusNode ?? _ownFocus!;

  DateTime get _first =>
      DateUtils.dateOnly(widget.firstDate ?? DsDate.defaultFirst);
  DateTime get _last =>
      DateUtils.dateOnly(widget.lastDate ?? DsDate.defaultLast);

  double get _popoverHeight =>
      DsCalendar.height + (widget.withTime ? _timeRowHeight : 0);

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) _ownController = TextEditingController();
    if (widget.focusNode == null) _ownFocus = FocusNode();
    if (_text.text.isEmpty && widget.value != null) {
      _text.text = _format(widget.value!);
    } else {
      _normalize();
    }
    _committedText = _text.text;
    _focus.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(DsDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocus)?.removeListener(_onFocusChanged);
      if (widget.focusNode == null) _ownFocus ??= FocusNode();
      _focus.addListener(_onFocusChanged);
    }
    if (widget.controller == null && _ownController == null) {
      _ownController = TextEditingController(text: oldWidget.controller?.text);
    }
    // Follow the parent only when it disagrees with what is typed, so partial
    // input is not erased while the parent holds null.
    final DateTime? typed = _parse(_text.text);
    if (!_same(widget.value, typed) && !_same(widget.value, oldWidget.value)) {
      _text.text = widget.value == null ? '' : _format(widget.value!);
      // A value pushed by the parent is not an edit to report back.
      _committedText = _text.text;
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChanged);
    _ownController?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  bool _same(DateTime? a, DateTime? b) {
    if (a == null || b == null) return a == b;
    return widget.withTime ? a.isAtSameMomentAs(b) : DateUtils.isSameDay(a, b);
  }

  String _format(DateTime date) {
    return widget.withTime
        ? DsDate.formatDateTime(date, seconds: widget.showSeconds)
        : DsDate.format(date);
  }

  DateTime? _read(String text) {
    return widget.withTime
        ? DsDate.tryParseDateTime(text)
        : DsDate.tryParse(text);
  }

  /// The typed value, or null when incomplete, impossible or out of range.
  DateTime? _parse(String text) {
    final DateTime? date = _read(text);
    if (date == null) return null;
    final DateTime day = DateUtils.dateOnly(date);
    if (day.isBefore(_first) || day.isAfter(_last)) return null;
    return date;
  }

  /// Rewrites a complete, valid date in the canonical format. Never called
  /// while the user is typing inside the field.
  void _normalize() {
    final DateTime? date = _parse(_text.text);
    if (date == null) return;
    final String formatted = _format(date);
    if (formatted != _text.text) _text.text = formatted;
  }

  void _onFocusChanged() {
    // While the calendar is open, focus may be in its time input: the edit is
    // not over yet.
    if (!_focus.hasFocus && !_popover.isShowing) _commit();
  }

  /// Reports a finished edit, once per distinct value.
  void _commit() {
    _normalize();
    final String text = _text.text.trim();
    if (text == _committedText.trim()) return;
    final DateTime? date = _parse(text);
    if (text.isNotEmpty && date == null) return;
    _committedText = _text.text;
    widget.onCommitted?.call(date);
  }

  String? _validate(String? raw) {
    final String text = (raw ?? '').trim();
    if (text.isEmpty) {
      return widget.required ? 'Preencha este campo.' : null;
    }
    final DateTime? date = _read(text);
    if (date == null) {
      return widget.withTime
          ? 'Informe data e hora válidas (dd/mm/aaaa hh:mm).'
          : 'Informe uma data válida (dd/mm/aaaa).';
    }
    final DateTime day = DateUtils.dateOnly(date);
    if (day.isBefore(_first)) {
      return 'Informe uma data a partir de ${DsDate.format(_first)}.';
    }
    if (day.isAfter(_last)) {
      return 'Informe uma data até ${DsDate.format(_last)}.';
    }
    return widget.validator?.call(date);
  }

  void _open() {
    if (!widget.enabled || _popover.isShowing) return;
    final RenderBox? box =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      const double margin = DsSpacing.s8;
      const double gap = DsSpacing.s4;
      final Size screen = MediaQuery.sizeOf(context);
      final Offset origin = box.localToGlobal(Offset.zero);
      final Size field = box.size;
      final double height = _popoverHeight;

      // Below the field when it fits, above otherwise.
      final double below = origin.dy + field.height + gap;
      final bool fitsBelow = below + height + margin <= screen.height;
      final double above = origin.dy - gap - height;
      double top = fitsBelow || above < margin && origin.dy < screen.height / 2
          ? below
          : above;
      double left = origin.dx;

      // Then keep it on screen; on viewports smaller than the calendar the
      // top-left corner wins, so the header stays reachable.
      top = top.clamp(
        margin,
        (screen.height - height - margin).clamp(margin, double.infinity),
      );
      left = left.clamp(
        margin,
        (screen.width - DsCalendar.width - margin).clamp(
          margin,
          double.infinity,
        ),
      );
      _popoverOffset = Offset(left - origin.dx, top - origin.dy);
    }
    _textAtOpen = _text.text;
    setState(_popover.show);
    // Shortcuts (Esc) are handled around the field, so focus has to be inside
    // it even when the calendar was opened with the mouse.
    _focus.requestFocus();
  }

  void _close() {
    if (_popover.isShowing) setState(_popover.hide);
  }

  /// Esc: closes and undoes whatever was changed since the calendar opened.
  void _cancel() {
    if (!_popover.isShowing) return;
    if (_text.text != _textAtOpen) {
      _text.value = TextEditingValue(
        text: _textAtOpen,
        selection: TextSelection.collapsed(offset: _textAtOpen.length),
      );
      widget.onChanged(_parse(_textAtOpen));
    }
    _close();
    _focus.requestFocus();
  }

  /// A click outside: closes and keeps what is in the field.
  void _dismiss() {
    if (!_popover.isShowing) return;
    _close();
    if (!_focus.hasFocus) _commit();
  }

  void _setText(DateTime? date) {
    final String text = date == null ? '' : _format(date);
    _text.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _finish() {
    widget.onPicked?.call(_parse(_text.text));
    _close();
    _focus.requestFocus();
    _commit();
  }

  void _pick(DateTime? date) {
    DateTime? result = date;
    if (date != null && widget.withTime) {
      // Picking a day keeps the time that was already there.
      final DateTime? current = DsDate.tryParseDateTime(_text.text);
      result = DateTime(
        date.year,
        date.month,
        date.day,
        current?.hour ?? 0,
        current?.minute ?? 0,
        current?.second ?? 0,
      );
    }
    _setText(result);
    widget.onChanged(result);
    if (widget.withTime && result != null) {
      // Stay open so the time can be adjusted.
      setState(() {});
    } else {
      _finish();
    }
  }

  void _setTime(TimeOfDay time) {
    final DateTime? current = _parse(_text.text);
    if (current == null) return;
    final DateTime result = DateTime(
      current.year,
      current.month,
      current.day,
      time.hour,
      time.minute,
      current.second,
    );
    _setText(result);
    widget.onChanged(result);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    final DateTime? current = _parse(_text.text);

    final Widget field = CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        // Bound only while open, so Esc still closes an enclosing dialog.
        if (_popover.isShowing)
          const SingleActivator(LogicalKeyboardKey.escape): _cancel,
        const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true): _open,
      },
      child: TapRegion(
        groupId: this,
        child: CompositedTransformTarget(
          link: _link,
          child: OverlayPortal(
            controller: _popover,
            overlayChildBuilder: (BuildContext context) {
              return Align(
                alignment: Alignment.topLeft,
                child: CompositedTransformFollower(
                  link: _link,
                  offset: _popoverOffset,
                  child: TapRegion(
                    groupId: this,
                    onTapOutside: (_) => _dismiss(),
                    // Clicks in the calendar must not count as clicks outside
                    // the text field, or the field would lose focus (and with
                    // it the Esc shortcut) on every mouse click.
                    child: TextFieldTapRegion(
                      child: CallbackShortcuts(
                        // Reached when focus is in the time input.
                        bindings: <ShortcutActivator, VoidCallback>{
                          const SingleActivator(LogicalKeyboardKey.escape):
                              _cancel,
                        },
                        child: Material(
                          color: c.surface,
                          elevation: DsElevation.level2,
                          shadowColor: c.shadow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DsRadius.sm),
                            side: BorderSide(color: c.border),
                          ),
                          child: Semantics(
                            container: true,
                            label: 'Calendário, ${widget.label}',
                            explicitChildNodes: true,
                            // Scrolls only on viewports shorter than the calendar.
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.sizeOf(context).height -
                                    DsSpacing.s8 * 2,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    DsCalendar(
                                      selected: current,
                                      initialMonth: widget.calendarInitialDate,
                                      rangeStart: widget.rangeStart,
                                      rangeEnd: widget.rangeEnd,
                                      firstDate: _first,
                                      lastDate: _last,
                                      onSelected: _pick,
                                      onClear:
                                          widget.required || _text.text.isEmpty
                                          ? null
                                          : () => _pick(null),
                                    ),
                                    if (widget.withTime)
                                      _TimeRow(
                                        value: current == null
                                            ? null
                                            : TimeOfDay.fromDateTime(current),
                                        onChanged: _setTime,
                                        onDone: _finish,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: TextFormField(
              key: _fieldKey,
              controller: _text,
              focusNode: _focus,
              enabled: widget.enabled,
              keyboardType: TextInputType.datetime,
              textInputAction: widget.textInputAction,
              inputFormatters: <TextInputFormatter>[
                DsDateInputFormatter(withTime: widget.withTime),
              ],
              validator: _validate,
              onChanged: (String text) {
                // Eight bare digits can only come from a paste (typing gets
                // its separators as it goes): show them as a date at once.
                if (!widget.withTime && _eightDigits.hasMatch(text)) {
                  _normalize();
                }
                setState(() {});
                widget.onChanged(_parse(_text.text));
              },
              onFieldSubmitted: (_) {
                _commit();
                widget.onSubmitted?.call();
              },
              style: widget.compact
                  ? DsTypography.table.copyWith(color: c.textPrimary)
                  : null,
              decoration: InputDecoration(
                label: widget.compact
                    ? null
                    : DsFieldLabel(widget.label, required: widget.required),
                hintText: widget.withTime ? 'dd/mm/aaaa hh:mm' : 'dd/mm/aaaa',
                helperText: widget.helperText,
                prefixIcon: widget.prefixIcon,
                contentPadding: widget.compact
                    ? const EdgeInsets.fromLTRB(
                        DsSpacing.s8,
                        DsSpacing.s8,
                        0,
                        DsSpacing.s8,
                      )
                    : null,
                suffixIconConstraints: widget.compact
                    ? const BoxConstraints.tightFor(
                        width: DsSizes.controlSm,
                        height: DsSizes.controlSm,
                      )
                    : null,
                suffixIcon: IconButton(
                  tooltip: 'Abrir calendário',
                  icon: const Icon(Icons.calendar_today_outlined),
                  iconSize: widget.compact ? DsSizes.iconSm : DsSizes.iconMd,
                  padding: widget.compact ? EdgeInsets.zero : null,
                  onPressed: widget.enabled
                      ? (_popover.isShowing ? _close : _open)
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // Without a visible label the name still has to be announced.
    return widget.compact
        ? Semantics(label: widget.label, child: field)
        : field;
  }
}

/// Time input shown under the calendar when the field carries a time.
class _TimeRow extends StatefulWidget {
  const _TimeRow({
    required this.value,
    required this.onChanged,
    required this.onDone,
  });

  /// Null until a day is chosen.
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onChanged;
  final VoidCallback onDone;

  @override
  State<_TimeRow> createState() => _TimeRowState();
}

class _TimeRowState extends State<_TimeRow> {
  late final TextEditingController _text = TextEditingController(
    text: _formatted(widget.value),
  );

  static String _formatted(TimeOfDay? time) {
    if (time == null) return '';
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(time.hour)}:${two(time.minute)}';
  }

  @override
  void didUpdateWidget(_TimeRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A day was picked or the time changed elsewhere; do not fight typing.
    final TimeOfDay? typed = DsDate.tryParseTime(_text.text);
    if (widget.value != typed && widget.value != oldWidget.value) {
      _text.text = _formatted(widget.value);
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    return Container(
      width: DsCalendar.width,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.border)),
      ),
      padding: const EdgeInsets.all(DsSpacing.s8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _text,
              enabled: widget.value != null,
              keyboardType: TextInputType.datetime,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                LengthLimitingTextInputFormatter(5),
              ],
              decoration: const InputDecoration(
                labelText: 'Hora',
                hintText: 'hh:mm',
              ),
              onChanged: (String text) {
                final TimeOfDay? time = DsDate.tryParseTime(text);
                if (time != null) widget.onChanged(time);
              },
              onSubmitted: (_) => widget.onDone(),
            ),
          ),
          const SizedBox(width: DsSpacing.s8),
          DsButton(
            label: 'Concluir',
            variant: DsButtonVariant.secondary,
            onPressed: widget.value == null ? null : widget.onDone,
          ),
        ],
      ),
    );
  }
}

/// A period as two linked date fields ("De" and "Até").
///
/// Both calendars highlight the period. An end before the start is reported
/// on the end field.
class DsDateRangeField extends StatelessWidget {
  const DsDateRangeField({
    super.key,
    required this.onChanged,
    this.start,
    this.end,
    this.startLabel = 'De',
    this.endLabel = 'Até',
    this.required = false,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.fieldWidth = DsDateField.minWidth,
    this.onSubmitted,
  });

  final DateTime? start;
  final DateTime? end;

  /// Called with both ends whenever either changes.
  final void Function(DateTime? start, DateTime? end) onChanged;
  final String startLabel;
  final String endLabel;
  final bool required;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final double fieldWidth;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DsSpacing.s8,
      runSpacing: DsSpacing.s12,
      children: <Widget>[
        SizedBox(
          width: fieldWidth,
          child: DsDateField(
            label: startLabel,
            value: start,
            required: required,
            enabled: enabled,
            firstDate: firstDate,
            lastDate: lastDate,
            rangeStart: start,
            rangeEnd: end,
            textInputAction: TextInputAction.next,
            onChanged: (DateTime? value) => onChanged(value, end),
          ),
        ),
        SizedBox(
          width: fieldWidth,
          child: DsDateField(
            label: endLabel,
            value: end,
            required: required,
            enabled: enabled,
            firstDate: firstDate,
            lastDate: lastDate,
            rangeStart: start,
            rangeEnd: end,
            onSubmitted: onSubmitted,
            onChanged: (DateTime? value) => onChanged(start, value),
            validator: (DateTime value) {
              if (start != null && value.isBefore(DateUtils.dateOnly(start!))) {
                return 'Use uma data igual ou posterior à inicial.';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

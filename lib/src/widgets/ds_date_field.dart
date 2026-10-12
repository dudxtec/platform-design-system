import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_foundations.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import 'ds_calendar.dart';
import 'ds_form.dart';

/// Formats digits as `dd/mm/aaaa` while the user types.
class DsDateInputFormatter extends TextInputFormatter {
  const DsDateInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 8) digits = digits.substring(0, 8);
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) out.write('/');
      out.write(digits[i]);
    }
    final String text = out.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Date input: typed with a `dd/mm/aaaa` mask or picked from a calendar
/// popover anchored to the field.
///
/// Typing is always possible and is the fastest path; the calendar opens from
/// the icon or with Alt+Down and closes with Esc. The popover opens upwards
/// when there is no room below, so it works on short screens and in dialogs.
///
/// Validates inside a [Form]: required, well-formed, within range, and then
/// [validator].
class DsDateField extends StatefulWidget {
  const DsDateField({
    super.key,
    required this.label,
    required this.onChanged,
    this.value,
    this.required = false,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.rangeStart,
    this.rangeEnd,
    this.helperText,
    this.validator,
    this.onSubmitted,
    this.textInputAction,
  });

  final String label;
  final DateTime? value;

  /// Called with a date when the text becomes a valid date in range, and
  /// with null when it stops being one.
  final ValueChanged<DateTime?> onChanged;
  final bool required;
  final bool enabled;

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
  final VoidCallback? onSubmitted;
  final TextInputAction? textInputAction;

  /// Narrowest width that shows the whole date and the calendar button.
  static const double minWidth = 168;

  @override
  State<DsDateField> createState() => _DsDateFieldState();
}

class _DsDateFieldState extends State<DsDateField> {
  final TextEditingController _text = TextEditingController();
  final OverlayPortalController _popover = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final FocusNode _focus = FocusNode();
  final GlobalKey _fieldKey = GlobalKey();

  /// Where the popover goes, relative to the top-left corner of the field.
  Offset _popoverOffset = Offset.zero;

  DateTime get _first =>
      DateUtils.dateOnly(widget.firstDate ?? DsDate.defaultFirst);
  DateTime get _last =>
      DateUtils.dateOnly(widget.lastDate ?? DsDate.defaultLast);

  @override
  void initState() {
    super.initState();
    if (widget.value != null) _text.text = DsDate.format(widget.value!);
  }

  @override
  void didUpdateWidget(DsDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Follow the parent only when it disagrees with what is typed, so partial
    // input is not erased while the parent holds null.
    final DateTime? typed = _parse(_text.text);
    if (!DateUtils.isSameDay(widget.value, typed) &&
        !DateUtils.isSameDay(widget.value, oldWidget.value)) {
      _text.text = widget.value == null ? '' : DsDate.format(widget.value!);
    }
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  DateTime? _parse(String text) {
    final DateTime? date = DsDate.tryParse(text);
    if (date == null || date.isBefore(_first) || date.isAfter(_last)) {
      return null;
    }
    return date;
  }

  String? _validate(String? raw) {
    final String text = (raw ?? '').trim();
    if (text.isEmpty) {
      return widget.required ? 'Preencha este campo.' : null;
    }
    final DateTime? date = DsDate.tryParse(text);
    if (date == null) return 'Informe uma data válida (dd/mm/aaaa).';
    if (date.isBefore(_first)) {
      return 'Informe uma data a partir de ${DsDate.format(_first)}.';
    }
    if (date.isAfter(_last)) {
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

      // Below the field when it fits, above otherwise.
      final double below = origin.dy + field.height + gap;
      final bool fitsBelow =
          below + DsCalendar.height + margin <= screen.height;
      final double above = origin.dy - gap - DsCalendar.height;
      double top = fitsBelow || above < margin && origin.dy < screen.height / 2
          ? below
          : above;
      double left = origin.dx;

      // Then keep it on screen; on viewports smaller than the calendar the
      // top-left corner wins, so the header stays reachable.
      top = top.clamp(
        margin,
        (screen.height - DsCalendar.height - margin).clamp(
          margin,
          double.infinity,
        ),
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
    setState(_popover.show);
  }

  void _close() {
    if (_popover.isShowing) setState(_popover.hide);
  }

  void _select(DateTime? date) {
    _text.text = date == null ? '' : DsDate.format(date);
    widget.onChanged(date);
    _close();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    final DateTime? current = _parse(_text.text);

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        // Bound only while open, so Esc still closes an enclosing dialog.
        if (_popover.isShowing)
          const SingleActivator(LogicalKeyboardKey.escape): _close,
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
                    onTapOutside: (_) => _close(),
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
                            child: DsCalendar(
                              selected: current,
                              rangeStart: widget.rangeStart,
                              rangeEnd: widget.rangeEnd,
                              firstDate: _first,
                              lastDate: _last,
                              onSelected: _select,
                              onClear: widget.required || _text.text.isEmpty
                                  ? null
                                  : () => _select(null),
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
              inputFormatters: const <TextInputFormatter>[
                DsDateInputFormatter(),
              ],
              validator: _validate,
              onChanged: (String text) {
                setState(() {});
                widget.onChanged(_parse(text));
              },
              onFieldSubmitted: (_) => widget.onSubmitted?.call(),
              decoration: InputDecoration(
                label: DsFieldLabel(widget.label, required: widget.required),
                hintText: 'dd/mm/aaaa',
                helperText: widget.helperText,
                suffixIcon: IconButton(
                  tooltip: 'Abrir calendário',
                  icon: const Icon(Icons.calendar_today_outlined),
                  iconSize: DsSizes.iconMd,
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

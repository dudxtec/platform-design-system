import 'package:flutter/material.dart';

import '../tokens/ds_breakpoints.dart';
import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_spacing.dart';
import 'ds_button.dart';

/// Label of a form field, for `InputDecoration.label`.
///
/// Required fields get an asterisk announced as "obrigatório"; optional
/// fields get no marker.
class DsFieldLabel extends StatelessWidget {
  const DsFieldLabel(this.label, {super.key, this.required = false});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    if (!required) return Text(label);
    return Semantics(
      label: '$label, obrigatório',
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          text: label,
          children: <InlineSpan>[
            TextSpan(
              text: ' *',
              style: TextStyle(color: context.dsColors.dangerTone.text),
            ),
          ],
        ),
      ),
    );
  }
}

/// Makes a child of [DsFormGrid] take the whole row.
class DsFormFull extends StatelessWidget {
  const DsFormFull({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Lays form fields out in columns that collapse to one on narrow widths.
///
/// Field order follows reading order (left to right, top to bottom), which is
/// also the tab order.
class DsFormGrid extends StatelessWidget {
  const DsFormGrid({super.key, required this.children, this.columns = 2});

  final List<Widget> children;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final int count = width < DsBreakpoints.mobile ? 1 : columns;
        const double gap = DsSpacing.s16;
        final double cell = (width - gap * (count - 1)) / count;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final Widget child in children)
              SizedBox(
                // Floor avoids a sub-pixel overflow that would wrap the last
                // cell of a row.
                width: child is DsFormFull ? width : cell.floorToDouble(),
                child: child,
              ),
          ],
        );
      },
    );
  }
}

/// Submit and cancel actions of a form, aligned to the end.
///
/// Cancel comes first and the primary action last, on pages and in dialogs.
class DsFormActions extends StatelessWidget {
  const DsFormActions({
    super.key,
    required this.onSubmit,
    this.onCancel,
    this.submitLabel = 'Salvar',
    this.cancelLabel = 'Cancelar',
    this.loading = false,
  });

  /// Null disables the submit button.
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final String submitLabel;
  final String cancelLabel;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        if (onCancel != null) ...<Widget>[
          DsButton(
            label: cancelLabel,
            onPressed: loading ? null : onCancel,
            variant: DsButtonVariant.ghost,
          ),
          const SizedBox(width: DsSpacing.s8),
        ],
        DsButton(label: submitLabel, onPressed: onSubmit, loading: loading),
      ],
    );
  }
}

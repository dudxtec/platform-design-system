import 'dart:async';

import 'package:flutter/material.dart';

import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_foundations.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import 'ds_alert.dart';
import 'ds_button.dart';

/// Transient result of an action the user just took.
///
/// Drawn on the root overlay, so it stays visible above dialogs and drawers.
/// One at a time: a new toast replaces the current one.
class DsToast {
  DsToast._();

  static OverlayEntry? _current;

  static void show(
    BuildContext context,
    String message, {
    DsTone tone = DsTone.neutral,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    dismiss();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext context) {
        return _ToastView(
          message: message,
          tone: tone,
          actionLabel: actionLabel,
          onAction: onAction,
          onDismiss: () {
            if (entry.mounted) entry.remove();
            if (identical(_current, entry)) _current = null;
          },
        );
      },
    );
    _current = entry;
    overlay.insert(entry);
  }

  /// Removes the toast on screen, if any.
  static void dismiss() {
    final OverlayEntry? entry = _current;
    _current = null;
    if (entry != null && entry.mounted) entry.remove();
  }

  static void success(BuildContext context, String message) =>
      show(context, message, tone: DsTone.success);

  static void error(BuildContext context, String message) =>
      show(context, message, tone: DsTone.danger);
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.message,
    required this.tone,
    required this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final DsTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Errors stay longer: the user has to read and decide what to do.
    _timer = Timer(
      Duration(seconds: widget.tone == DsTone.danger ? 8 : 4),
      widget.onDismiss,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    final TextTheme text = Theme.of(context).textTheme;
    final Color iconColor = switch (widget.tone) {
      DsTone.neutral || DsTone.primary => c.textInverse,
      // Tones sit on the inverse surface, so they take the other
      // brightness' text step to stay legible.
      _ =>
        Theme.of(context).brightness == Brightness.light
            ? DsColorTokens.dark.tone(widget.tone).text
            : DsColorTokens.light.tone(widget.tone).text,
    };

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(DsSpacing.s16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Semantics(
              container: true,
              liveRegion: true,
              child: Material(
                color: c.surfaceInverse,
                elevation: DsElevation.level4,
                shadowColor: c.shadow,
                borderRadius: BorderRadius.circular(DsRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DsSpacing.s16,
                    DsSpacing.s8,
                    DsSpacing.s8,
                    DsSpacing.s8,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        dsToneIcon(widget.tone),
                        size: DsSizes.iconLg,
                        color: iconColor,
                      ),
                      const SizedBox(width: DsSpacing.s12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: text.bodyMedium?.copyWith(
                            color: c.textInverse,
                          ),
                        ),
                      ),
                      if (widget.actionLabel != null)
                        TextButton(
                          onPressed: () {
                            widget.onAction?.call();
                            widget.onDismiss();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: c.textInverse,
                          ),
                          child: Text(widget.actionLabel!),
                        ),
                      IconButton(
                        tooltip: 'Fechar',
                        onPressed: widget.onDismiss,
                        icon: Icon(Icons.close, color: c.textInverse),
                        iconSize: DsSizes.iconMd,
                        visualDensity: VisualDensity.compact,
                      ),
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

/// Confirmation before an action that cannot be undone or has side effects.
class DsConfirmDialog {
  DsConfirmDialog._();

  /// Resolves to true only when the user confirms.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Cancelar',
    bool destructive = false,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DsSizes.dialogSm),
            child: Text(message),
          ),
          actions: <Widget>[
            DsButton(
              label: cancelLabel,
              variant: DsButtonVariant.ghost,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            DsButton(
              label: confirmLabel,
              variant: destructive
                  ? DsButtonVariant.danger
                  : DsButtonVariant.primary,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }
}

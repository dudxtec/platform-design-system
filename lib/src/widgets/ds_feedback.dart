import 'package:flutter/material.dart';

import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_foundations.dart';
import '../tokens/ds_spacing.dart';
import 'ds_alert.dart';
import 'ds_button.dart';

/// Transient result of an action the user just took.
class DsToast {
  DsToast._();

  static void show(
    BuildContext context,
    String message, {
    DsTone tone = DsTone.neutral,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final DsColorTokens c = context.dsColors;
    final Color iconColor = switch (tone) {
      DsTone.neutral || DsTone.primary => c.textInverse,
      // Tones sit on the inverse surface, so they take the other
      // brightness' text step to stay legible.
      _ =>
        Theme.of(context).brightness == Brightness.light
            ? DsColorTokens.dark.tone(tone).text
            : DsColorTokens.light.tone(tone).text,
    };

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        // Errors stay longer: the user has to read and decide what to do.
        duration: Duration(seconds: tone == DsTone.danger ? 8 : 4),
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.sizeOf(context).width > 560 ? 480 : null,
        content: Row(
          children: <Widget>[
            Icon(dsToneIcon(tone), size: DsSizes.iconLg, color: iconColor),
            const SizedBox(width: DsSpacing.s12),
            Expanded(child: Text(message)),
          ],
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, tone: DsTone.success);

  static void error(BuildContext context, String message) =>
      show(context, message, tone: DsTone.danger);
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

import 'package:flutter/material.dart';

import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_spacing.dart';
import 'ds_button.dart';

class _StateView extends StatelessWidget {
  const _StateView({
    required this.leading,
    required this.title,
    this.message,
    this.action,
  });

  final Widget leading;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: DsSpacing.s24,
          vertical: DsSpacing.s48,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              leading,
              const SizedBox(height: DsSpacing.s16),
              Text(title, style: text.titleMedium, textAlign: TextAlign.center),
              if (message != null) ...<Widget>[
                const SizedBox(height: DsSpacing.s4),
                Text(
                  message!,
                  style: text.bodyMedium?.copyWith(
                    color: context.dsColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...<Widget>[
                const SizedBox(height: DsSpacing.s24),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown when a list, search or section has nothing to display.
///
/// Say what is missing and offer the next step ([action]) whenever there is
/// one: create the first record, clear the filters.
class DsEmptyState extends StatelessWidget {
  const DsEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _StateView(
      leading: Icon(icon, size: 40, color: context.dsColors.textTertiary),
      title: title,
      message: message,
      action: action,
    );
  }
}

/// Shown when loading failed. [message] must be written for the user; never
/// pass `error.toString()`.
class DsErrorState extends StatelessWidget {
  const DsErrorState({
    super.key,
    this.title = 'Não foi possível carregar',
    this.message = 'Verifique sua conexão e tente novamente.',
    this.onRetry,
    this.retryLabel = 'Tentar novamente',
    this.secondaryAction,
  });

  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String retryLabel;

  /// A way out when retrying is not enough, such as "Sair". Usually a ghost
  /// `DsButton`.
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: _StateView(
        leading: Icon(
          Icons.error_outline,
          size: 40,
          color: context.dsColors.dangerTone.solid,
        ),
        title: title,
        message: message,
        action: onRetry == null && secondaryAction == null
            ? null
            : Wrap(
                alignment: WrapAlignment.center,
                spacing: DsSpacing.s8,
                runSpacing: DsSpacing.s8,
                children: <Widget>[
                  if (onRetry != null)
                    DsButton(
                      label: retryLabel,
                      onPressed: onRetry,
                      variant: DsButtonVariant.secondary,
                      icon: Icons.refresh,
                    ),
                  ?secondaryAction,
                ],
              ),
      ),
    );
  }
}

/// Shown while the first load of a page or section is in progress.
class DsLoadingState extends StatelessWidget {
  const DsLoadingState({super.key, this.label = 'Carregando…'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: label,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(DsSpacing.s48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox.square(
                dimension: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: DsSpacing.s16),
              ExcludeSemantics(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.dsColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

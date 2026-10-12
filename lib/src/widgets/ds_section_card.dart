import 'package:flutter/material.dart';

import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_spacing.dart';

/// Titled card that groups related content: a form section, a detail block,
/// a dashboard panel.
class DsSectionCard extends StatelessWidget {
  const DsSectionCard({
    super.key,
    required this.child,
    this.title,
    this.description,
    this.actions = const <Widget>[],
    this.padding = const EdgeInsets.all(DsSpacing.s16),
  });

  final String? title;
  final String? description;
  final List<Widget> actions;
  final Widget child;

  /// Use `EdgeInsets.zero` when [child] is a table or list that goes edge to
  /// edge.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final DsColorTokens c = context.dsColors;
    final bool hasHeader = title != null || actions.isNotEmpty;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (hasHeader) ...<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DsSpacing.s16,
                vertical: DsSpacing.s12,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (title != null)
                          Semantics(
                            header: true,
                            child: Text(title!, style: text.titleMedium),
                          ),
                        if (description != null)
                          Text(
                            description!,
                            style: text.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  for (final Widget action in actions) ...<Widget>[
                    const SizedBox(width: DsSpacing.s8),
                    action,
                  ],
                ],
              ),
            ),
            const Divider(),
          ],
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

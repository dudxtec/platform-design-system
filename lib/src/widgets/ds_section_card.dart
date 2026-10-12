import 'package:flutter/material.dart';

import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_foundations.dart';
import '../tokens/ds_spacing.dart';

/// Titled card that groups related content: a form section, a detail block,
/// a dashboard panel.
///
/// With [collapsible] the header toggles the body. [onExpansionChanged] lets
/// the caller load the content only when the section is first opened.
class DsSectionCard extends StatefulWidget {
  const DsSectionCard({
    super.key,
    required this.child,
    this.title,
    this.description,
    this.actions = const <Widget>[],
    this.padding = const EdgeInsets.all(DsSpacing.s16),
    this.collapsible = false,
    this.initiallyExpanded = true,
    this.onExpansionChanged,
  });

  final String? title;
  final String? description;
  final List<Widget> actions;
  final Widget child;

  /// Use `EdgeInsets.zero` when [child] is a table or list that goes edge to
  /// edge.
  final EdgeInsets padding;

  /// Requires a [title].
  final bool collapsible;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<DsSectionCard> createState() => _DsSectionCardState();
}

class _DsSectionCardState extends State<DsSectionCard> {
  late bool _expanded = !widget.collapsible || widget.initiallyExpanded;

  void _toggle() {
    setState(() => _expanded = !_expanded);
    widget.onExpansionChanged?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final DsColorTokens c = context.dsColors;
    final bool collapsible = widget.collapsible && widget.title != null;
    final bool expanded = !collapsible || _expanded;
    final bool hasHeader = widget.title != null || widget.actions.isNotEmpty;

    final Widget titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.title != null)
          Semantics(
            header: true,
            child: Text(widget.title!, style: text.titleMedium),
          ),
        if (widget.description != null)
          Text(
            widget.description!,
            style: text.bodySmall?.copyWith(color: c.textSecondary),
          ),
      ],
    );

    final Widget header = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpacing.s16,
        vertical: DsSpacing.s12,
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: titleBlock),
          for (final Widget action in widget.actions) ...<Widget>[
            const SizedBox(width: DsSpacing.s8),
            action,
          ],
          if (collapsible) ...<Widget>[
            const SizedBox(width: DsSpacing.s8),
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              size: DsSizes.iconLg,
              color: c.textSecondary,
            ),
          ],
        ],
      ),
    );

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (hasHeader) ...<Widget>[
            if (collapsible)
              Semantics(
                button: true,
                expanded: expanded,
                child: InkWell(
                  onTap: _toggle,
                  hoverColor: c.surfaceHover,
                  child: header,
                ),
              )
            else
              header,
            if (expanded) const Divider(),
          ],
          if (expanded) Padding(padding: widget.padding, child: widget.child),
        ],
      ),
    );
  }
}

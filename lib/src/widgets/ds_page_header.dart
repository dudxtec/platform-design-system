import 'package:flutter/material.dart';

import '../tokens/ds_breakpoints.dart';
import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_foundations.dart';
import '../tokens/ds_spacing.dart';

@immutable
class DsBreadcrumbItem {
  const DsBreadcrumbItem(this.label, {this.onTap});

  final String label;

  /// Null for the current page (last item).
  final VoidCallback? onTap;
}

/// Path from the module root to the current page.
class DsBreadcrumb extends StatelessWidget {
  const DsBreadcrumb({super.key, required this.items});

  final List<DsBreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    final TextStyle? style = Theme.of(context).textTheme.labelMedium;

    final List<Widget> children = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      final DsBreadcrumbItem item = items[i];
      final bool current = i == items.length - 1;
      if (i > 0) {
        children.add(
          ExcludeSemantics(
            child: Icon(
              Icons.chevron_right,
              size: DsSizes.iconSm,
              color: c.textTertiary,
            ),
          ),
        );
      }
      final Widget label = Text(
        item.label,
        style: style?.copyWith(
          color: current ? c.textPrimary : c.textSecondary,
        ),
      );
      children.add(
        current || item.onTap == null
            ? Semantics(header: current, child: label)
            : Semantics(
                link: true,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(DsSpacing.s4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DsSpacing.s2,
                    ),
                    child: label,
                  ),
                ),
              ),
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: DsSpacing.s4,
      children: children,
    );
  }
}

/// Title block of every page: breadcrumb, title, subtitle and page actions.
///
/// At most one primary action; it goes last (rightmost).
class DsPageHeader extends StatelessWidget {
  const DsPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.breadcrumbs = const <DsBreadcrumbItem>[],
    this.actions = const <Widget>[],
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final List<DsBreadcrumbItem> breadcrumbs;
  final List<Widget> actions;

  /// Shows a back button before the title (detail and form pages).
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final DsColorTokens c = context.dsColors;

    final Widget titleBlock = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (onBack != null) ...<Widget>[
          IconButton(
            onPressed: onBack,
            tooltip: 'Voltar',
            icon: const Icon(Icons.arrow_back),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: DsSpacing.s8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(title, style: text.headlineMedium),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: DsSpacing.s4),
                Text(
                  subtitle!,
                  style: text.bodyMedium?.copyWith(color: c.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    final Widget actionBar = Wrap(
      spacing: DsSpacing.s8,
      runSpacing: DsSpacing.s8,
      children: actions,
    );

    return DsHeaderLayout(
      breadcrumb: breadcrumbs.isEmpty ? null : DsBreadcrumb(items: breadcrumbs),
      title: titleBlock,
      actions: actions.isEmpty ? null : actionBar,
    );
  }
}

/// Arranges title and actions side by side, stacking them on narrow widths.
class DsHeaderLayout extends StatelessWidget {
  const DsHeaderLayout({
    super.key,
    required this.title,
    this.breadcrumb,
    this.actions,
  });

  final Widget title;
  final Widget? breadcrumb;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stacked = constraints.maxWidth < DsBreakpoints.mobile;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (breadcrumb != null) ...<Widget>[
              breadcrumb!,
              const SizedBox(height: DsSpacing.s8),
            ],
            if (stacked || actions == null) ...<Widget>[
              title,
              if (actions != null) ...<Widget>[
                const SizedBox(height: DsSpacing.s16),
                actions!,
              ],
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: title),
                  const SizedBox(width: DsSpacing.s16),
                  actions!,
                ],
              ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../tokens/ds_breakpoints.dart';
import '../tokens/ds_density.dart';
import '../tokens/ds_foundations.dart';
import '../tokens/ds_spacing.dart';

/// Content area of a page: header, optional filters, body.
///
/// Every screen puts its content inside a [DsPage] so that padding, maximum
/// width and the vertical rhythm between regions are the same everywhere.
class DsPage extends StatelessWidget {
  const DsPage({
    super.key,
    required this.child,
    this.header,
    this.filters,
    this.footer,
    this.maxWidth = DsSizes.contentMaxWidth,
    this.scrollable = true,
  });

  /// Usually a `DsPageHeader`.
  final Widget? header;

  /// Usually a `DsFilterBar`.
  final Widget? filters;
  final Widget child;

  /// Pinned below the body (form actions, totals).
  final Widget? footer;

  /// `DsSizes.contentMaxWidth` for data pages, `DsSizes.formMaxWidth` for
  /// forms and detail pages.
  final double maxWidth;

  /// When false, [child] gets the remaining height and must scroll itself
  /// (tables with a pinned pagination footer).
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final DsDensity density = DsDensity.of(context);
        final double gutter = constraints.maxWidth < DsBreakpoints.mobile
            ? DsSpacing.s16
            : density.pageGutter;

        Widget constrain(Widget content) {
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: content,
            ),
          );
        }

        final List<Widget> top = <Widget>[
          if (header != null) ...<Widget>[
            header!,
            SizedBox(height: density.headerGap),
          ],
          if (filters != null) ...<Widget>[
            filters!,
            SizedBox(height: density.sectionGap),
          ],
        ];

        final Widget body = scrollable
            ? SingleChildScrollView(
                padding: EdgeInsets.all(gutter),
                child: constrain(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[...top, child],
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.all(gutter),
                child: constrain(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ...top,
                      Expanded(child: child),
                    ],
                  ),
                ),
              );

        if (footer == null) return body;
        return Column(
          children: <Widget>[
            Expanded(child: body),
            Material(
              color: Theme.of(context).colorScheme.surface,
              shape: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: gutter,
                  vertical: DsSpacing.s12,
                ),
                child: constrain(footer!),
              ),
            ),
          ],
        );
      },
    );
  }
}

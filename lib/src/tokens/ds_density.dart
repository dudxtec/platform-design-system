import 'package:flutter/widgets.dart';

import 'ds_breakpoints.dart';
import 'ds_spacing.dart';

/// Vertical density of the layout.
///
/// Notebooks of 14 and 15 inches leave 600 to 750 px of viewport height once
/// the browser chrome is discounted (less inside the host iframe). On those
/// the layout switches to [compact] so that lists still show a useful number
/// of rows.
enum DsDensity {
  comfortable,
  compact;

  /// Density for [context]: the nearest [DsDensityScope], or [compact] when
  /// the viewport is shorter than [DsBreakpoints.shortHeight].
  static DsDensity of(BuildContext context) {
    final DsDensityScope? scope = context
        .dependOnInheritedWidgetOfExactType<DsDensityScope>();
    if (scope != null) return scope.density;
    return MediaQuery.sizeOf(context).height < DsBreakpoints.shortHeight
        ? DsDensity.compact
        : DsDensity.comfortable;
  }

  bool get isCompact => this == DsDensity.compact;

  /// Padding around the page content on desktop widths.
  double get pageGutter => isCompact ? DsSpacing.s16 : DsSpacing.s24;

  /// Gap between the page header and what follows.
  double get headerGap => isCompact ? DsSpacing.s12 : DsSpacing.s24;

  /// Gap between filters and content.
  double get sectionGap => isCompact ? DsSpacing.s12 : DsSpacing.s16;

  double get topBarHeight => isCompact ? 48 : 56;
  double get tableRowHeight => isCompact ? 36 : 44;
  double get tableHeaderHeight => isCompact ? 36 : 40;
}

/// Forces a [DsDensity] for a subtree, for example from a user preference.
class DsDensityScope extends InheritedWidget {
  const DsDensityScope({
    super.key,
    required this.density,
    required super.child,
  });

  final DsDensity density;

  @override
  bool updateShouldNotify(DsDensityScope oldWidget) {
    return density != oldWidget.density;
  }
}

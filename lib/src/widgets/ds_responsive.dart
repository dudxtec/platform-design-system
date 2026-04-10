import 'package:flutter/material.dart';

import '../tokens/ds_breakpoints.dart';

/// Builds different UI based on the available width using [LayoutBuilder],
/// exposing the resolved [DsScreenSize] to [builder].
///
/// Prefer [DsResponsiveBuilder] over reading `context.screenSize` directly
/// when the widget is inside a constrained layout (e.g., a side panel), as
/// [LayoutBuilder] reacts to the local constraints rather than the full screen.
class DsResponsiveBuilder extends StatelessWidget {
  const DsResponsiveBuilder({super.key, required this.builder});

  /// Called with the current [BuildContext] and the resolved [DsScreenSize].
  final Widget Function(BuildContext context, DsScreenSize screenSize) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints constraints) {
        final DsScreenSize screenSize;
        if (constraints.maxWidth < DsBreakpoints.mobile) {
          screenSize = DsScreenSize.mobile;
        } else if (constraints.maxWidth < DsBreakpoints.tablet) {
          screenSize = DsScreenSize.tablet;
        } else {
          screenSize = DsScreenSize.desktop;
        }
        return builder(ctx, screenSize);
      },
    );
  }
}

/// Renders a different child widget depending on the current screen size.
///
/// Falls back gracefully: [desktop] falls back to [tablet], which falls back
/// to [mobile]. Only [mobile] is required.
///
/// ```dart
/// DsResponsiveLayout(
///   mobile: MobileView(),
///   tablet: TabletView(),
///   desktop: DesktopView(),
/// )
/// ```
class DsResponsiveLayout extends StatelessWidget {
  const DsResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Widget rendered on mobile screens (< 600 px). Always required.
  final Widget mobile;

  /// Widget rendered on tablet screens (600–899 px). Falls back to [mobile].
  final Widget? tablet;

  /// Widget rendered on desktop screens (≥ 900 px). Falls back to [tablet],
  /// then [mobile].
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return DsResponsiveBuilder(
      builder: (BuildContext ctx, DsScreenSize screenSize) {
        return switch (screenSize) {
          DsScreenSize.desktop => desktop ?? tablet ?? mobile,
          DsScreenSize.tablet => tablet ?? mobile,
          DsScreenSize.mobile => mobile,
        };
      },
    );
  }
}

/// Holds different values for each [DsScreenSize] and resolves the correct
/// one at runtime.
///
/// Only [mobile] is required; [tablet] falls back to [mobile] and [desktop]
/// falls back to [tablet], then [mobile].
///
/// ```dart
/// final columns = DsResponsiveValue<int>(mobile: 1, tablet: 2, desktop: 3);
///
/// // Inside build():
/// final count = columns.of(context);              // uses MediaQuery
/// final count = columns.resolve(DsScreenSize.tablet); // explicit
/// ```
class DsResponsiveValue<T> {
  const DsResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Value used on mobile screens.
  final T mobile;

  /// Value used on tablet screens. Falls back to [mobile] if null.
  final T? tablet;

  /// Value used on desktop screens. Falls back to [tablet], then [mobile].
  final T? desktop;

  /// Returns the value for a given [DsScreenSize].
  T resolve(DsScreenSize screenSize) {
    return switch (screenSize) {
      DsScreenSize.desktop => desktop ?? tablet ?? mobile,
      DsScreenSize.tablet => tablet ?? mobile,
      DsScreenSize.mobile => mobile,
    };
  }

  /// Resolves the value using [context]'s current screen size via [MediaQuery].
  T of(BuildContext context) => resolve(context.screenSize);
}

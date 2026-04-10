import 'package:flutter/material.dart';

/// Screen size categories used throughout the design system.
enum DsScreenSize { mobile, tablet, desktop }

/// Breakpoint constants (in logical pixels) that define the boundaries
/// between screen size categories:
/// - mobile  : width < [mobile]
/// - tablet  : [mobile] ≤ width < [tablet]
/// - desktop : width ≥ [tablet]
class DsBreakpoints {
  DsBreakpoints._();

  /// Maximum width (exclusive) considered a mobile screen.
  static const double mobile = 600;

  /// Maximum width (exclusive) considered a tablet screen.
  static const double tablet = 900;
}

/// Convenience extensions on [BuildContext] for reading the current
/// [DsScreenSize] and querying individual breakpoints.
extension DsScreenSizeContext on BuildContext {
  /// Returns the [DsScreenSize] for the current screen width.
  DsScreenSize get screenSize {
    final double width = MediaQuery.of(this).size.width;
    if (width < DsBreakpoints.mobile) return DsScreenSize.mobile;
    if (width < DsBreakpoints.tablet) return DsScreenSize.tablet;
    return DsScreenSize.desktop;
  }

  /// Whether the current screen is considered mobile.
  bool get isMobile => screenSize == DsScreenSize.mobile;

  /// Whether the current screen is considered tablet.
  bool get isTablet => screenSize == DsScreenSize.tablet;

  /// Whether the current screen is considered desktop.
  bool get isDesktop => screenSize == DsScreenSize.desktop;
}

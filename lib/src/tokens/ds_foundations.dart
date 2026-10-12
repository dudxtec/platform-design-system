import 'package:flutter/material.dart';

/// Fixed dimensions of controls and layout regions.
class DsSizes {
  DsSizes._();

  static const double controlSm = 32;

  /// Default height of buttons and inputs.
  static const double controlMd = 40;

  static const double iconSm = 16;

  /// Icons inside buttons and inputs.
  static const double iconMd = 18;

  /// Navigation and standalone icon buttons.
  static const double iconLg = 20;
  static const double iconXl = 24;

  static const double topBarHeight = 56;
  static const double sidebarWidth = 240;
  static const double sidebarCollapsedWidth = 64;
  static const double navItemHeight = 40;

  static const double tableHeaderHeight = 40;
  static const double tableRowHeight = 44;

  /// Minimum pointer target on touch layouts.
  static const double touchTarget = 44;

  /// Lists, dashboards and other data-dense pages.
  static const double contentMaxWidth = 1280;

  /// Forms and detail pages meant to be read top to bottom.
  static const double formMaxWidth = 760;

  static const double dialogSm = 400;
  static const double dialogMd = 560;
  static const double dialogLg = 720;
  static const double drawerWidth = 480;
}

/// Elevation levels. Surfaces are flat by default (border, no shadow);
/// shadows are reserved for things that float above the page.
class DsElevation {
  DsElevation._();

  static const double level0 = 0;

  /// Sticky bars over scrolling content.
  static const double level1 = 1;

  /// Menus, popovers, date pickers.
  static const double level2 = 3;

  /// Dialogs and side drawers.
  static const double level3 = 6;

  /// Toasts.
  static const double level4 = 8;

  /// Shadow for custom-painted floating surfaces; Material widgets take the
  /// numeric levels above instead.
  static List<BoxShadow> shadow(double level, Color color) {
    if (level <= 0) return const <BoxShadow>[];
    return <BoxShadow>[
      BoxShadow(
        color: color.withValues(alpha: 0.06),
        blurRadius: level * 2,
        offset: Offset(0, level / 2),
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.10),
        blurRadius: level * 4,
        offset: Offset(0, level),
      ),
    ];
  }
}

/// Stacking order.
///
/// Flutter has no z-index: order comes from the widget tree and the Navigator
/// overlay. These values document the intended order and are meant for sorting
/// children of a `Stack` or entries of an `Overlay`.
class DsLayer {
  DsLayer._();

  static const int base = 0;
  static const int sticky = 100;
  static const int sidebar = 200;
  static const int topBar = 300;
  static const int dropdown = 400;
  static const int drawer = 500;
  static const int dialog = 600;
  static const int toast = 700;
  static const int tooltip = 800;
}

/// Motion is functional only: it explains a state change and never decorates.
class DsMotion {
  DsMotion._();

  /// Hover, press and focus feedback.
  static const Duration fast = Duration(milliseconds: 100);

  /// Expand/collapse, sidebar, tabs.
  static const Duration base = Duration(milliseconds: 180);

  /// Dialogs and drawers entering.
  static const Duration slow = Duration(milliseconds: 240);

  static const Curve standard = Curves.easeOutCubic;
}

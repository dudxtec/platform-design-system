/// Spacing scale on a 4 px grid.
///
/// Prefer the numeric names (`s16`); the t-shirt names are kept for existing
/// consumers and map to the same values.
class DsSpacing {
  DsSpacing._();

  /// Hairline gap between an icon and its own label.
  static const double s2 = 2;

  /// Between tightly related inline elements (icon and text, chip content).
  static const double s4 = 4;

  /// Between elements of the same control group (buttons in a row).
  static const double s8 = 8;

  /// Vertical padding of dense rows; gap between a label and its field.
  static const double s12 = 12;

  /// Default: card padding, gap between form fields, gutters.
  static const double s16 = 16;

  /// Page padding on desktop; gap between cards and sections.
  static const double s24 = 24;

  /// Between blocks of a page (header to content).
  static const double s32 = 32;

  /// Between major page regions.
  static const double s40 = 40;

  /// Vertical padding of empty and error states.
  static const double s48 = 48;

  /// Hero spacing in standalone pages (login, 404).
  static const double s64 = 64;

  /// Maximum; reserved for full-page states.
  static const double s80 = 80;

  static const double xxs = s4;
  static const double xs = s8;
  static const double sm = s12;
  static const double md = s16;

  /// Off-scale legacy value. Use [s16] or [s24] in new code.
  static const double lg = 20;
  static const double xl = s24;
  static const double xxl = s32;
  static const double xxxl = s48;
  static const double xxxxl = s64;
}

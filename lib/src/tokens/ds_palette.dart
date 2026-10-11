import 'package:flutter/painting.dart';

/// Primitive colour scales (50–900) of the platform.
///
/// These are raw values. Widgets must not read them directly: use the semantic
/// tokens in `DsColorTokens` (via `context.dsColors`), which resolve to the
/// right step for the current brightness. The palette is public so that themes
/// and charts can reference exact steps.
class DsPalette {
  DsPalette._();

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Brand teal. 600 is the brand colour (white text reaches 5.8:1).
  static const Color teal50 = Color(0xFFE5F2F2);
  static const Color teal100 = Color(0xFFC2E0E0);
  static const Color teal200 = Color(0xFF99CCCC);
  static const Color teal300 = Color(0xFF66B2B3);
  static const Color teal400 = Color(0xFF339C9D);
  static const Color teal500 = Color(0xFF1A8A8B);
  static const Color teal600 = Color(0xFF007172);
  static const Color teal700 = Color(0xFF005A5B);
  static const Color teal800 = Color(0xFF004445);
  static const Color teal900 = Color(0xFF003031);

  // Accent orange. Never put white text on 500 (2.3:1); use neutral900.
  static const Color orange50 = Color(0xFFFFF4E5);
  static const Color orange100 = Color(0xFFFFE2BF);
  static const Color orange200 = Color(0xFFFFCE94);
  static const Color orange300 = Color(0xFFFFB866);
  static const Color orange400 = Color(0xFFFFA333);
  static const Color orange500 = Color(0xFFFF9100);
  static const Color orange600 = Color(0xFFE07E00);
  static const Color orange700 = Color(0xFFB86500);
  static const Color orange800 = Color(0xFF8F4E00);
  static const Color orange900 = Color(0xFF663800);

  // Cool neutral. 400 is the lightest step that reaches 3:1 on white, so it
  // is the minimum for control borders.
  static const Color neutral25 = Color(0xFFF8F9FC);
  static const Color neutral50 = Color(0xFFF4F6F9);
  static const Color neutral100 = Color(0xFFEBEEF2);
  static const Color neutral200 = Color(0xFFE1E7ED);
  static const Color neutral300 = Color(0xFFCBD3DC);
  static const Color neutral400 = Color(0xFF8592A0);
  static const Color neutral500 = Color(0xFF6B7785);
  static const Color neutral600 = Color(0xFF52606D);
  static const Color neutral700 = Color(0xFF3E4C59);
  static const Color neutral800 = Color(0xFF1F2933);
  static const Color neutral900 = Color(0xFF12181F);
  static const Color neutral950 = Color(0xFF0F1214);

  static const Color green50 = Color(0xFFE8F5E9);
  static const Color green100 = Color(0xFFC8E6C9);
  static const Color green200 = Color(0xFFA5D6A7);
  static const Color green300 = Color(0xFF81C784);
  static const Color green400 = Color(0xFF66BB6A);
  static const Color green500 = Color(0xFF43A047);
  static const Color green600 = Color(0xFF388E3C);
  static const Color green700 = Color(0xFF2E7D32);
  static const Color green800 = Color(0xFF1B5E20);
  static const Color green900 = Color(0xFF124116);

  static const Color red50 = Color(0xFFFFEBEE);
  static const Color red100 = Color(0xFFFFCDD2);
  static const Color red200 = Color(0xFFEF9A9A);
  static const Color red300 = Color(0xFFE57373);
  static const Color red400 = Color(0xFFEF5350);
  static const Color red500 = Color(0xFFF44336);
  static const Color red600 = Color(0xFFE53935);
  static const Color red700 = Color(0xFFD32F2F);
  static const Color red800 = Color(0xFFC62828);
  static const Color red900 = Color(0xFFB71C1C);

  // Warning uses amber, not orange, so it never reads as the brand accent.
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);

  static const Color blue50 = Color(0xFFE1F5FE);
  static const Color blue100 = Color(0xFFB3E5FC);
  static const Color blue200 = Color(0xFF81D4FA);
  static const Color blue300 = Color(0xFF4FC3F7);
  static const Color blue400 = Color(0xFF29B6F6);
  static const Color blue500 = Color(0xFF039BE5);
  static const Color blue600 = Color(0xFF0288D1);
  static const Color blue700 = Color(0xFF0277BD);
  static const Color blue800 = Color(0xFF01579B);
  static const Color blue900 = Color(0xFF014374);

  /// Categorical series for charts, ordered to keep neighbours distinguishable.
  static const List<Color> chart = <Color>[
    teal600,
    orange600,
    blue700,
    green600,
    amber700,
    neutral600,
    red700,
    teal300,
  ];
}

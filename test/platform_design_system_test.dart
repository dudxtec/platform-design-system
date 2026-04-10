import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_design_system/platform_design_system.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
Widget _buildWithSize(double width, Widget child) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: Size(width, 800)),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  // ---------------------------------------------------------------------------
  // Tokens
  // ---------------------------------------------------------------------------
  group('DsColors', () {
    test('inputFill is defined', () {
      expect(DsColors.inputFill, const Color(0xFFF8F9FC));
    });

    test('dark mode colors are defined', () {
      expect(DsColors.backgroundDark, const Color(0xFF0F1214));
      expect(DsColors.textPrimaryDark, const Color(0xFFE8ECF0));
    });
  });

  group('DsSpacing', () {
    test('scale is ordered and uses 4pt grid', () {
      expect(DsSpacing.xxs, 4);
      expect(DsSpacing.xs, 8);
      expect(DsSpacing.sm, 12);
      expect(DsSpacing.md, 16);
      expect(DsSpacing.lg, 20);
      expect(DsSpacing.xl, 24);
      expect(DsSpacing.xxl, 32);
      expect(DsSpacing.xxxl, 48);
      expect(DsSpacing.xxxxl, 64);
    });
  });

  // ---------------------------------------------------------------------------
  // Theme
  // ---------------------------------------------------------------------------
  group('DsTheme', () {
    test('light() returns a valid ThemeData with correct scaffold color', () {
      final theme = DsTheme.light();
      expect(theme.scaffoldBackgroundColor, DsColors.background);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('dark() returns a valid ThemeData with correct scaffold color', () {
      final theme = DsTheme.dark();
      expect(theme.scaffoldBackgroundColor, DsColors.backgroundDark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('light() inputDecorationTheme uses DsColors.inputFill', () {
      final theme = DsTheme.light();
      expect(theme.inputDecorationTheme.fillColor, DsColors.inputFill);
    });
  });

  // ---------------------------------------------------------------------------
  // DsStatChip
  // ---------------------------------------------------------------------------
  group('DsStatChip', () {
    testWidgets('renders label and value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: const Scaffold(
            body: DsStatChip(label: 'Total', value: '10'),
          ),
        ),
      );

      expect(find.text('Total '), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('accepts custom color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: const Scaffold(
            body: DsStatChip(
              label: 'Erros',
              value: '3',
              color: DsColors.error,
            ),
          ),
        ),
      );

      expect(find.text('Erros '), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // DsPrimaryButton
  // ---------------------------------------------------------------------------
  group('DsPrimaryButton', () {
    testWidgets('renders without icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: const Scaffold(
            body: DsPrimaryButton(label: 'Salvar'),
          ),
        ),
      );

      expect(find.text('Salvar'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: const Scaffold(
            body: DsPrimaryButton(
              label: 'Adicionar',
              icon: Icons.add,
            ),
          ),
        ),
      );

      expect(find.text('Adicionar'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onPressed callback', (WidgetTester tester) async {
      var called = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: Scaffold(
            body: DsPrimaryButton(
              label: 'OK',
              onPressed: () => called = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('OK'));
      expect(called, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // DsOutlinedButton
  // ---------------------------------------------------------------------------
  group('DsOutlinedButton', () {
    testWidgets('renders without icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: const Scaffold(
            body: DsOutlinedButton(label: 'Cancelar'),
          ),
        ),
      );

      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('renders with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: const Scaffold(
            body: DsOutlinedButton(
              label: 'Editar',
              icon: Icons.edit,
            ),
          ),
        ),
      );

      expect(find.text('Editar'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('calls onPressed callback', (WidgetTester tester) async {
      var called = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: Scaffold(
            body: DsOutlinedButton(
              label: 'Confirmar',
              onPressed: () => called = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Confirmar'));
      expect(called, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // DsBreakpoints
  // ---------------------------------------------------------------------------
  group('DsBreakpoints', () {
    test('mobile breakpoint is 600', () {
      expect(DsBreakpoints.mobile, 600);
    });

    test('tablet breakpoint is 900', () {
      expect(DsBreakpoints.tablet, 900);
    });
  });

  // ---------------------------------------------------------------------------
  // DsScreenSize context extension
  // ---------------------------------------------------------------------------
  group('DsScreenSizeContext', () {
    testWidgets('returns mobile when width < 600', (WidgetTester tester) async {
      DsScreenSize? resolved;
      await tester.pumpWidget(
        _buildWithSize(
          400,
          Builder(
            builder: (context) {
              resolved = context.screenSize;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved, DsScreenSize.mobile);
    });

    testWidgets('returns tablet when 600 ≤ width < 900',
        (WidgetTester tester) async {
      DsScreenSize? resolved;
      await tester.pumpWidget(
        _buildWithSize(
          700,
          Builder(
            builder: (context) {
              resolved = context.screenSize;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved, DsScreenSize.tablet);
    });

    testWidgets('returns desktop when width ≥ 900', (WidgetTester tester) async {
      DsScreenSize? resolved;
      await tester.pumpWidget(
        _buildWithSize(
          1200,
          Builder(
            builder: (context) {
              resolved = context.screenSize;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved, DsScreenSize.desktop);
    });

    testWidgets('isMobile / isTablet / isDesktop helpers',
        (WidgetTester tester) async {
      bool? mobile, tablet, desktop;
      await tester.pumpWidget(
        _buildWithSize(
          1024,
          Builder(
            builder: (context) {
              mobile = context.isMobile;
              tablet = context.isTablet;
              desktop = context.isDesktop;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(mobile, isFalse);
      expect(tablet, isFalse);
      expect(desktop, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // DsResponsiveLayout
  // ---------------------------------------------------------------------------
  group('DsResponsiveLayout', () {
    testWidgets('renders mobile widget on narrow screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildWithSize(
          400,
          const DsResponsiveLayout(
            mobile: Text('mobile'),
            tablet: Text('tablet'),
            desktop: Text('desktop'),
          ),
        ),
      );
      expect(find.text('mobile'), findsOneWidget);
      expect(find.text('tablet'), findsNothing);
    });

    testWidgets('renders tablet widget on medium screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildWithSize(
          700,
          const DsResponsiveLayout(
            mobile: Text('mobile'),
            tablet: Text('tablet'),
            desktop: Text('desktop'),
          ),
        ),
      );
      expect(find.text('tablet'), findsOneWidget);
    });

    testWidgets('renders desktop widget on wide screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildWithSize(
          1200,
          const DsResponsiveLayout(
            mobile: Text('mobile'),
            tablet: Text('tablet'),
            desktop: Text('desktop'),
          ),
        ),
      );
      expect(find.text('desktop'), findsOneWidget);
    });

    testWidgets('falls back to mobile when tablet and desktop are null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildWithSize(
          1200,
          const DsResponsiveLayout(mobile: Text('mobile')),
        ),
      );
      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('desktop falls back to tablet when desktop is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildWithSize(
          1200,
          const DsResponsiveLayout(
            mobile: Text('mobile'),
            tablet: Text('tablet'),
          ),
        ),
      );
      expect(find.text('tablet'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // DsResponsiveBuilder
  // ---------------------------------------------------------------------------
  group('DsResponsiveBuilder', () {
    testWidgets('exposes correct DsScreenSize to builder',
        (WidgetTester tester) async {
      DsScreenSize? captured;
      await tester.pumpWidget(
        _buildWithSize(
          500,
          DsResponsiveBuilder(
            builder: (_, size) {
              captured = size;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured, DsScreenSize.mobile);
    });
  });

  // ---------------------------------------------------------------------------
  // DsResponsiveValue
  // ---------------------------------------------------------------------------
  group('DsResponsiveValue', () {
    test('resolve returns correct value per screen size', () {
      const value = DsResponsiveValue<int>(mobile: 1, tablet: 2, desktop: 3);
      expect(value.resolve(DsScreenSize.mobile), 1);
      expect(value.resolve(DsScreenSize.tablet), 2);
      expect(value.resolve(DsScreenSize.desktop), 3);
    });

    test('resolve falls back from desktop to tablet', () {
      const value = DsResponsiveValue<int>(mobile: 1, tablet: 2);
      expect(value.resolve(DsScreenSize.desktop), 2);
    });

    test('resolve falls back from tablet and desktop to mobile', () {
      const value = DsResponsiveValue<int>(mobile: 1);
      expect(value.resolve(DsScreenSize.tablet), 1);
      expect(value.resolve(DsScreenSize.desktop), 1);
    });

    testWidgets('of(context) resolves via MediaQuery', (WidgetTester tester) async {
      int? resolved;
      const value = DsResponsiveValue<int>(mobile: 10, tablet: 20, desktop: 30);
      await tester.pumpWidget(
        _buildWithSize(
          1000,
          Builder(
            builder: (context) {
              resolved = value.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved, 30);
    });
  });
}

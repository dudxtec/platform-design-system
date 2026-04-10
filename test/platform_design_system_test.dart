import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_design_system/platform_design_system.dart';

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
}

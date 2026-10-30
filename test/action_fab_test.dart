import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_design_system/platform_design_system.dart';

const ValueKey<String> _barrier = ValueKey<String>('ds-action-fab-barrier');

Widget _host({
  required List<DsFabAction> actions,
  double width = 390,
  double endOffset = 0,
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme ?? DsTheme.light(),
    home: MediaQuery(
      data: MediaQueryData(size: Size(width, 600)),
      child: Scaffold(
        body: DsActionFab(
          actions: actions,
          endOffset: endOffset,
          child: const SizedBox.expand(),
        ),
      ),
    ),
  );
}

List<DsFabAction> _two(void Function(String) ran) {
  return <DsFabAction>[
    DsFabAction(
      label: 'Novo carnê',
      icon: Icons.receipt_long,
      onPressed: () => ran('novo'),
    ),
    DsFabAction(
      label: 'Exportar',
      icon: Icons.file_download_outlined,
      onPressed: () => ran('exportar'),
    ),
  ];
}

List<DsFabAction> _withExport(void Function(String) ran) {
  return <DsFabAction>[
    DsFabAction(
      label: 'Novo carnê',
      icon: Icons.receipt_long,
      onPressed: () => ran('novo'),
    ),
    DsFabAction(
      label: 'Exportar',
      icon: Icons.file_download_outlined,
      children: <DsFabAction>[
        DsFabAction(
          label: 'Excel',
          icon: Icons.table_chart_outlined,
          onPressed: () => ran('excel'),
        ),
        DsFabAction(
          label: 'CSV',
          icon: Icons.description_outlined,
          onPressed: () => ran('csv'),
        ),
        DsFabAction(
          label: 'PDF',
          icon: Icons.picture_as_pdf_outlined,
          onPressed: () => ran('pdf'),
        ),
      ],
    ),
  ];
}

Future<void> _openMenu(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

void main() {
  group('DsActionFab', () {
    testWidgets('without actions there is no button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(actions: const <DsFabAction>[]));

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('one action runs directly, named after the action', (
      WidgetTester tester,
    ) async {
      int calls = 0;
      await tester.pumpWidget(
        _host(
          actions: <DsFabAction>[
            DsFabAction(
              label: 'Nova pessoa',
              icon: Icons.person_add_alt,
              onPressed: () => calls++,
            ),
          ],
        ),
      );

      expect(find.byTooltip('Nova pessoa'), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(calls, 1);
      expect(find.byKey(_barrier), findsNothing);
    });

    testWidgets('two actions open a menu and the button becomes a close', (
      WidgetTester tester,
    ) async {
      String? ran;
      await tester.pumpWidget(_host(actions: _two((String v) => ran = v)));

      expect(find.byTooltip('Ações'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      await _openMenu(tester);
      expect(find.text('Novo carnê'), findsOneWidget);
      expect(find.text('Exportar'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.text('Exportar'));
      await tester.pumpAndSettle();

      expect(ran, 'exportar');
      expect(find.text('Exportar'), findsNothing);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets(
      'phone: scrim behind the menu, first action nearest the thumb',
      (WidgetTester tester) async {
        await tester.pumpWidget(_host(actions: _two((String v) {})));
        await _openMenu(tester);

        final ColoredBox scrim = tester.widget<ColoredBox>(
          find.descendant(
            of: find.byKey(_barrier),
            matching: find.byType(ColoredBox),
          ),
        );
        expect(scrim.color, DsColorTokens.light.scrim);
        expect(
          tester.getTopLeft(find.text('Novo carnê')).dy,
          greaterThan(tester.getTopLeft(find.text('Exportar')).dy),
        );

        await tester.tapAt(const Offset(40, 40));
        await tester.pumpAndSettle();
        expect(find.text('Exportar'), findsNothing);
      },
    );

    testWidgets('web: menu without scrim, tap outside closes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(actions: _two((String v) {}), width: 1280));
      await _openMenu(tester);

      final ColoredBox barrier = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byKey(_barrier),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(barrier.color, Colors.transparent);
      expect(find.text('Exportar'), findsOneWidget);

      await tester.tapAt(const Offset(40, 40));
      await tester.pumpAndSettle();
      expect(find.text('Exportar'), findsNothing);
    });

    testWidgets('web: an action with options unfolds inside the menu', (
      WidgetTester tester,
    ) async {
      String? ran;
      await tester.pumpWidget(
        _host(actions: _withExport((String v) => ran = v), width: 1280),
      );
      await _openMenu(tester);

      expect(find.text('Excel'), findsNothing);
      await tester.tap(find.text('Exportar'));
      await tester.pumpAndSettle();

      expect(find.text('Excel'), findsOneWidget);
      expect(find.text('CSV'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      expect(ran, isNull);

      await tester.tap(find.text('CSV'));
      await tester.pumpAndSettle();
      expect(ran, 'csv');
      expect(find.text('Exportar'), findsNothing);
    });

    testWidgets('phone: an action with options and no callback opens a sheet', (
      WidgetTester tester,
    ) async {
      String? ran;
      await tester.pumpWidget(
        _host(actions: _withExport((String v) => ran = v)),
      );
      await _openMenu(tester);

      await tester.tap(find.text('Exportar'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);

      await tester.tap(find.text('PDF'));
      await tester.pumpAndSettle();
      expect(ran, 'pdf');
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('Esc closes the menu and focus goes back to the button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(actions: _two((String v) {})));
      await _openMenu(tester);
      expect(find.text('Exportar'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('Exportar'), findsNothing);
      final FloatingActionButton fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(fab.focusNode!.hasFocus, isTrue);
    });

    testWidgets('hides while the keyboard is open', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(actions: _two((String v) {})));
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Physical pixels; a Scaffold would hide this from its body's MediaQuery.
      tester.view.viewInsets = const FakeViewPadding(bottom: 900);
      addTearDown(tester.view.resetViewInsets);
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsNothing);

      tester.view.resetViewInsets();
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets(
      'is 56 px and sits 16 px (phone) or 24 px (web) from the edge',
      (WidgetTester tester) async {
        await tester.pumpWidget(_host(actions: _two((String v) {})));
        expect(
          tester.getSize(find.byType(FloatingActionButton)),
          const Size(DsActionFab.size, DsActionFab.size),
        );
        Rect area = tester.getRect(find.byType(DsActionFab));
        Rect fab = tester.getRect(find.byType(FloatingActionButton));
        expect(area.bottom - fab.bottom, 16);
        expect(area.right - fab.right, 16);

        await tester.pumpWidget(
          _host(actions: _two((String v) {}), width: 1280),
        );
        area = tester.getRect(find.byType(DsActionFab));
        fab = tester.getRect(find.byType(FloatingActionButton));
        expect(area.bottom - fab.bottom, 24);
        expect(area.right - fab.right, 24);
      },
    );

    testWidgets('endOffset moves the button away from the end edge', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(actions: _two((String v) {}), width: 1280));
      final double before = tester
          .getRect(find.byType(FloatingActionButton))
          .right;

      await tester.pumpWidget(
        _host(actions: _two((String v) {}), width: 1280, endOffset: 400),
      );
      final double after = tester
          .getRect(find.byType(FloatingActionButton))
          .right;

      expect(before - after, 400);
    });

    testWidgets('uses the fab token in light and dark', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(actions: _two((String v) {})));
      FloatingActionButton fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(fab.backgroundColor, DsColorTokens.light.fab);
      expect(fab.foregroundColor, DsColorTokens.light.onFill);

      await tester.pumpWidget(
        _host(actions: _two((String v) {}), theme: DsTheme.dark()),
      );
      await tester.pumpAndSettle();
      fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(fab.backgroundColor, DsColorTokens.dark.fab);
      expect(fab.foregroundColor, DsColorTokens.dark.onFill);
    });
  });
}

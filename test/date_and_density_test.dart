import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_design_system/platform_design_system.dart';

void _setSurface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _app(Widget child) {
  return MaterialApp(
    theme: DsTheme.light(),
    home: Scaffold(body: child),
  );
}

void main() {
  group('DsDate', () {
    test('formats and parses dd/mm/aaaa', () {
      expect(DsDate.format(DateTime(2026, 3, 5)), '05/03/2026');
      expect(DsDate.tryParse('05/03/2026'), DateTime(2026, 3, 5));
    });

    test('rejects incomplete text and dates that do not exist', () {
      expect(DsDate.tryParse('05/03/20'), isNull);
      expect(DsDate.tryParse('31/02/2026'), isNull);
      expect(DsDate.tryParse('00/01/2026'), isNull);
      expect(DsDate.tryParse('2026-02-31'), isNull);
      expect(DsDate.tryParse('5/3/2026'), isNull);
    });

    test('also accepts ISO and eight digits', () {
      expect(DsDate.tryParse('2026-03-05'), DateTime(2026, 3, 5));
      expect(DsDate.tryParse('05032026'), DateTime(2026, 3, 5));
      expect(DsDate.tryParse('29/02/2024'), DateTime(2024, 2, 29));
      expect(DsDate.tryParse('29/02/2025'), isNull);
    });

    test('parses and formats date with time', () {
      expect(
        DsDate.tryParseDateTime('05/03/2026 14:30'),
        DateTime(2026, 3, 5, 14, 30),
      );
      expect(
        DsDate.tryParseDateTime('2026-03-05T14:30:45'),
        DateTime(2026, 3, 5, 14, 30, 45),
      );
      expect(DsDate.tryParseDateTime('05/03/2026'), DateTime(2026, 3, 5));
      expect(DsDate.tryParseDateTime('05/03/2026 24:00'), isNull);
      expect(DsDate.tryParseDateTime('05/03/2026 14:'), isNull);
      expect(
        DsDate.formatDateTime(DateTime(2026, 3, 5, 9, 7)),
        '05/03/2026 09:07',
      );
      expect(
        DsDate.formatDateTime(DateTime(2026, 3, 5, 9, 7, 3)),
        '05/03/2026 09:07:03',
      );
      expect(
        DsDate.formatDateTime(DateTime(2026, 3, 5, 9, 7), seconds: true),
        '05/03/2026 09:07:00',
      );
    });

    test('month and full date are in Brazilian Portuguese', () {
      expect(DsDate.monthYear(DateTime(2026, 3)), 'Março de 2026');
      expect(
        DsDate.full(DateTime(2026, 10, 21)),
        'quarta-feira, 21 de outubro de 2026',
      );
      expect(DsDate.full(DateTime(2026, 10, 11)), startsWith('domingo'));
    });
  });

  group('DsDateInputFormatter', () {
    const DsDateInputFormatter formatter = DsDateInputFormatter();

    TextEditingValue value(String text, [int? cursor]) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursor ?? text.length),
    );

    test('adds the separator only when typing at the end', () {
      expect(formatter.formatEditUpdate(value('2'), value('25')).text, '25/');
      expect(
        formatter.formatEditUpdate(value('25/1'), value('25/12')).text,
        '25/12/',
      );
      expect(
        formatter
            .formatEditUpdate(value('25/12/202'), value('25/12/2026'))
            .text,
        '25/12/2026',
      );
    });

    test('editing in the middle keeps text and cursor untouched', () {
      // Replace the month "12" by "1" with the cursor after it.
      final TextEditingValue edited = value('25/1/2026', 4);
      final TextEditingValue result = formatter.formatEditUpdate(
        value('25/12/2026', 5),
        edited,
      );
      expect(result, edited);

      // Deleting the slash does not put it back.
      final TextEditingValue deleted = value('25', 2);
      expect(formatter.formatEditUpdate(value('25/'), deleted), deleted);
    });

    test('pasting is left as it is', () {
      final TextEditingValue pasted = value('2026-03-05');
      expect(formatter.formatEditUpdate(value(''), pasted), pasted);
    });

    test(
      'refuses characters that cannot be part of a date and extra length',
      () {
        expect(
          formatter.formatEditUpdate(value('25/'), value('25/a')),
          value('25/'),
        );
        expect(
          formatter.formatEditUpdate(value('25/12/2026'), value('25/12/20261')),
          value('25/12/2026'),
        );
      },
    );

    test('with time, adds the colon after the hour', () {
      const DsDateInputFormatter withTime = DsDateInputFormatter(
        withTime: true,
      );
      expect(
        withTime
            .formatEditUpdate(value('25/12/2026 1'), value('25/12/2026 14'))
            .text,
        '25/12/2026 14:',
      );
    });
  });

  group('DsDateField', () {
    testWidgets('typing reports a date only once it is complete and valid', (
      WidgetTester tester,
    ) async {
      final List<DateTime?> changes = <DateTime?>[];
      await tester.pumpWidget(
        _app(DsDateField(label: 'Vencimento', onChanged: changes.add)),
      );
      await tester.enterText(find.byType(TextFormField), '25/12');
      expect(changes.last, isNull);
      await tester.enterText(find.byType(TextFormField), '25122026');
      expect(find.text('25/12/2026'), findsOneWidget);
      expect(changes.last, DateTime(2026, 12, 25));
    });

    testWidgets('validates required, format and range', (
      WidgetTester tester,
    ) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      await tester.pumpWidget(
        _app(
          Form(
            key: form,
            child: DsDateField(
              label: 'Nascimento',
              required: true,
              lastDate: DateTime(2020, 12, 31),
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Preencha este campo.'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '31022019');
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(
        find.text('Informe uma data válida (dd/mm/aaaa).'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextFormField), '01012021');
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Informe uma data até 31/12/2020.'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '15062019');
      expect(form.currentState!.validate(), isTrue);
    });

    testWidgets('picking a day fills the field and closes the calendar', (
      WidgetTester tester,
    ) async {
      DateTime? picked;
      await tester.pumpWidget(
        _app(
          DsDateField(
            label: 'Vencimento',
            value: DateTime(2026, 10, 5),
            onChanged: (DateTime? value) => picked = value,
          ),
        ),
      );
      expect(find.text('05/10/2026'), findsOneWidget);
      expect(find.byType(DsCalendar), findsNothing);

      await tester.tap(find.byTooltip('Abrir calendário'));
      await tester.pumpAndSettle();
      expect(find.byType(DsCalendar), findsOneWidget);

      await tester.tap(find.text('21'));
      await tester.pumpAndSettle();
      expect(picked, DateTime(2026, 10, 21));
      expect(find.text('21/10/2026'), findsOneWidget);
      expect(find.byType(DsCalendar), findsNothing);
    });

    testWidgets('month navigation and year picker', (
      WidgetTester tester,
    ) async {
      DateTime? picked;
      await tester.pumpWidget(
        _app(
          DsDateField(
            label: 'Nascimento',
            value: DateTime(2026, 10, 5),
            onChanged: (DateTime? value) => picked = value,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Abrir calendário'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Próximo mês'));
      await tester.pumpAndSettle();
      expect(find.text('Novembro de 2026'), findsOneWidget);

      await tester.tap(find.text('Novembro de 2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2024'));
      await tester.pumpAndSettle();
      expect(find.text('Novembro de 2024'), findsOneWidget);

      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();
      expect(picked, DateTime(2024, 11, 12));
    });

    testWidgets('calendar is in Portuguese without app localization', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          DsDateField(
            label: 'Data',
            value: DateTime(2026, 10, 5),
            onChanged: (_) {},
          ),
        ),
      );
      await tester.tap(find.byTooltip('Abrir calendário'));
      await tester.pumpAndSettle();
      expect(find.text('Outubro de 2026'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
      expect(find.text('Q'), findsNWidgets(2));
      expect(
        find.bySemanticsLabel('quinta-feira, 1 de outubro de 2026'),
        findsOneWidget,
      );
      // 1 October 2026 is a Thursday: fifth column, with Sunday first.
      expect(
        tester.getCenter(find.text('1')).dx,
        closeTo(tester.getCenter(find.text('Q').last).dx, 0.5),
      );
      handle.dispose();
    });

    testWidgets('Esc and outside taps close; Alt+Down opens', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: <Widget>[
              DsDateField(label: 'Data', onChanged: (_) {}),
              const SizedBox(height: 400),
              const Text('fora'),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(TextFormField));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pumpAndSettle();
      expect(find.byType(DsCalendar), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(DsCalendar), findsNothing);

      await tester.tap(find.byTooltip('Abrir calendário'));
      await tester.pumpAndSettle();
      expect(find.byType(DsCalendar), findsOneWidget);
      await tester.tap(find.text('fora'));
      await tester.pumpAndSettle();
      expect(find.byType(DsCalendar), findsNothing);
    });

    testWidgets('opens upwards and stays on screen on a short viewport', (
      WidgetTester tester,
    ) async {
      _setSurface(tester, const Size(1280, 600));
      await tester.pumpWidget(
        _app(
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: DsDateField.minWidth,
                child: DsDateField(label: 'Data', onChanged: (_) {}),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Abrir calendário'));
      await tester.pumpAndSettle();

      final Rect calendar = tester.getRect(find.byType(DsCalendar));
      final Rect field = tester.getRect(find.byType(TextFormField));
      expect(calendar.bottom, lessThanOrEqualTo(field.top));
      expect(calendar.top, greaterThanOrEqualTo(0));
      expect(calendar.right, lessThanOrEqualTo(1280));
      expect(tester.takeException(), isNull);
    });

    testWidgets('stays reachable on a viewport smaller than the calendar', (
      WidgetTester tester,
    ) async {
      _setSurface(tester, const Size(294, 301));
      await tester.pumpWidget(
        _app(
          Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              width: DsDateField.minWidth,
              child: DsDateField(label: 'Data', onChanged: (_) {}),
            ),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Abrir calendário'));
      await tester.pumpAndSettle();
      final Rect calendar = tester.getRect(find.byType(DsCalendar));
      expect(calendar.left, greaterThanOrEqualTo(0));
      expect(calendar.top, greaterThanOrEqualTo(0));
      expect(calendar.right, lessThanOrEqualTo(294));
      expect(tester.takeException(), isNull);
    });

    testWidgets('opens downwards when there is room', (
      WidgetTester tester,
    ) async {
      _setSurface(tester, const Size(1280, 700));
      await tester.pumpWidget(
        _app(
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: DsDateField.minWidth,
              child: DsDateField(label: 'Data', onChanged: (_) {}),
            ),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Abrir calendário'));
      await tester.pumpAndSettle();
      final Rect calendar = tester.getRect(find.byType(DsCalendar));
      expect(
        calendar.top,
        greaterThanOrEqualTo(tester.getRect(find.byType(TextFormField)).bottom),
      );
      expect(calendar.bottom, lessThanOrEqualTo(700));
    });

    testWidgets('days outside the allowed range cannot be picked', (
      WidgetTester tester,
    ) async {
      DateTime? picked;
      await tester.pumpWidget(
        _app(
          DsDateField(
            label: 'Data',
            value: DateTime(2026, 10, 10),
            firstDate: DateTime(2026, 10, 8),
            lastDate: DateTime(2026, 10, 20),
            onChanged: (DateTime? value) => picked = value,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Abrir calendário'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('25'));
      await tester.pumpAndSettle();
      expect(picked, isNull);
      expect(find.byType(DsCalendar), findsOneWidget);
    });

    testWidgets('follows a value set by the parent', (
      WidgetTester tester,
    ) async {
      DateTime? value;
      late StateSetter rebuild;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              rebuild = setState;
              return DsDateField(
                label: 'Data',
                value: value,
                onChanged: (DateTime? v) => setState(() => value = v),
              );
            },
          ),
        ),
      );
      // Partial typing is kept while the parent still holds null.
      await tester.enterText(find.byType(TextFormField), '05/10');
      await tester.pump();
      expect(find.text('05/10'), findsOneWidget);

      rebuild(() => value = DateTime(2026, 1, 2));
      await tester.pump();
      expect(find.text('02/01/2026'), findsOneWidget);

      rebuild(() => value = null);
      await tester.pump();
      expect(find.text('02/01/2026'), findsNothing);
    });
  });

  group('DsDateRangeField', () {
    testWidgets('reports both ends and rejects an end before the start', (
      WidgetTester tester,
    ) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      DateTime? start = DateTime(2026, 10, 10);
      DateTime? end;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Form(
                key: form,
                child: DsDateRangeField(
                  start: start,
                  end: end,
                  onChanged: (DateTime? s, DateTime? e) => setState(() {
                    start = s;
                    end = e;
                  }),
                ),
              );
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).last, '05102026');
      await tester.pump();
      expect(end, DateTime(2026, 10, 5));
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(
        find.text('Use uma data igual ou posterior à inicial.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextFormField).last, '31102026');
      await tester.pump();
      expect(form.currentState!.validate(), isTrue);
      expect(start, DateTime(2026, 10, 10));
      expect(end, DateTime(2026, 10, 31));
    });
  });

  group('DsDensity', () {
    const List<DataColumn> columns = <DataColumn>[
      DataColumn(label: Text('Nome')),
    ];
    const List<DataRow> rows = <DataRow>[
      DataRow(cells: <DataCell>[DataCell(Text('Ana'))]),
      DataRow(cells: <DataCell>[DataCell(Text('Bruno'))]),
    ];

    double rowHeight(WidgetTester tester) {
      return tester.getTopLeft(find.text('Bruno')).dy -
          tester.getTopLeft(find.text('Ana')).dy;
    }

    testWidgets('short viewports are compact, tall ones comfortable', (
      WidgetTester tester,
    ) async {
      _setSurface(tester, const Size(1366, 650));
      await tester.pumpWidget(
        _app(const DsDataTable(columns: columns, rows: rows)),
      );
      expect(rowHeight(tester), 36);

      tester.view.physicalSize = const Size(1920, 950);
      await tester.pumpAndSettle();
      expect(rowHeight(tester), 44);
    });

    testWidgets('DsDensityScope overrides the viewport', (
      WidgetTester tester,
    ) async {
      _setSurface(tester, const Size(1920, 950));
      await tester.pumpWidget(
        _app(
          const DsDensityScope(
            density: DsDensity.compact,
            child: DsDataTable(columns: columns, rows: rows),
          ),
        ),
      );
      expect(rowHeight(tester), 36);
    });

    testWidgets('compact page header puts the subtitle beside the title', (
      WidgetTester tester,
    ) async {
      _setSurface(tester, const Size(1366, 650));
      await tester.pumpWidget(
        _app(const DsPageHeader(title: 'Pessoas', subtitle: '249 registros')),
      );
      expect(
        tester.getTopLeft(find.text('249 registros')).dx,
        greaterThan(tester.getTopRight(find.text('Pessoas')).dx),
      );

      tester.view.physicalSize = const Size(1920, 950);
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('249 registros')).dy,
        greaterThanOrEqualTo(tester.getBottomLeft(find.text('Pessoas')).dy),
      );
    });
  });

  group('DsAppShell top bar height', () {
    Widget shell() {
      return MaterialApp(
        theme: DsTheme.light(),
        home: DsAppShell(
          sections: const <DsNavSection>[
            DsNavSection(
              items: <DsNavItem>[
                DsNavItem(
                  id: 'person',
                  label: 'Pessoas',
                  icon: Icons.people_outline,
                ),
              ],
            ),
          ],
          onNavigate: (_) {},
          body: const SizedBox.expand(),
        ),
      );
    }

    testWidgets('is 48 on phones and 56 on wide screens', (
      WidgetTester tester,
    ) async {
      _setSurface(tester, const Size(390, 800));
      await tester.pumpWidget(shell());
      expect(tester.getSize(find.byType(AppBar)).height, 48);

      tester.view.physicalSize = const Size(1440, 900);
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(AppBar)).height, 56);
    });
  });

  group('DsAppShell sidebar on narrow desktops', () {
    Widget shell({bool? collapsed, ValueChanged<bool>? onChanged}) {
      return MaterialApp(
        theme: DsTheme.light(),
        home: DsAppShell(
          sections: const <DsNavSection>[
            DsNavSection(
              items: <DsNavItem>[
                DsNavItem(
                  id: 'person',
                  label: 'Pessoas',
                  icon: Icons.people_outline,
                ),
              ],
            ),
          ],
          sidebarCollapsed: collapsed,
          onSidebarCollapsedChanged: onChanged,
          onNavigate: (_) {},
          body: const SizedBox.expand(),
        ),
      );
    }

    testWidgets('starts collapsed below 1280 and expanded from 1280', (
      WidgetTester tester,
    ) async {
      _setSurface(tester, const Size(1100, 650));
      await tester.pumpWidget(shell());
      expect(find.text('Pessoas'), findsNothing);
      expect(find.byTooltip('Pessoas'), findsOneWidget);

      tester.view.physicalSize = const Size(1280, 650);
      await tester.pumpAndSettle();
      expect(find.text('Pessoas'), findsOneWidget);
    });

    testWidgets('stored preference wins and toggling is reported', (
      WidgetTester tester,
    ) async {
      _setSurface(tester, const Size(1100, 650));
      final List<bool> reported = <bool>[];
      await tester.pumpWidget(shell(collapsed: false, onChanged: reported.add));
      expect(find.text('Pessoas'), findsOneWidget);

      await tester.tap(find.byTooltip('Recolher menu'));
      await tester.pumpAndSettle();
      expect(reported, <bool>[true]);
      expect(find.text('Pessoas'), findsNothing);
    });

    testWidgets('top bar is 48 px when compact', (WidgetTester tester) async {
      _setSurface(tester, const Size(1366, 650));
      await tester.pumpWidget(shell());
      expect(tester.getSize(find.byType(AppBar)).height, 48);
    });
  });
}

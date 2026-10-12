import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

Future<void> _click(WidgetTester tester, Finder finder) async {
  await tester.tap(finder, kind: PointerDeviceKind.mouse);
  await tester.pumpAndSettle();
}

void main() {
  group('DsDateField with a mouse', () {
    testWidgets('clicking inside the calendar keeps focus on the field', (
      WidgetTester tester,
    ) async {
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);
      final List<String> events = <String>[];
      focus.addListener(() => events.add('focus:${focus.hasFocus}'));

      await tester.pumpWidget(
        _app(
          DsDateField(
            label: 'Vencimento',
            focusNode: focus,
            value: DateTime(2026, 10, 20),
            onChanged: (_) {},
            onPicked: (DateTime? d) => events.add('picked:${d?.day}'),
          ),
        ),
      );
      await _click(tester, find.byTooltip('Abrir calendário'));
      expect(focus.hasFocus, isTrue);
      events.clear();

      await _click(tester, find.byTooltip('Próximo mês'));
      await _click(tester, find.byTooltip('Mês anterior'));
      expect(focus.hasFocus, isTrue);

      await _click(tester, find.text('25'));
      // No blur before the pick: a host that saves on blur would otherwise
      // save the old date first.
      expect(events, <String>['picked:25']);
      expect(focus.hasFocus, isTrue);
    });

    testWidgets('Esc after clicking in the calendar closes only the calendar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (BuildContext context) {
              return DsButton(
                label: 'Clonar',
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clonar parcela'),
                    content: SizedBox(
                      width: 320,
                      child: DsDateField(
                        label: 'Vencimento',
                        value: DateTime(2026, 10, 20),
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await _click(tester, find.text('Clonar'));
      await _click(tester, find.byTooltip('Abrir calendário'));
      await _click(tester, find.byTooltip('Próximo mês'));
      expect(find.text('Novembro de 2026'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(DsCalendar), findsNothing);
      expect(find.text('Clonar parcela'), findsOneWidget);
      expect(find.text('20/10/2026'), findsOneWidget);

      // With the calendar closed, Esc belongs to the dialog again.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Clonar parcela'), findsNothing);
    });
  });

  group('DsDateField.onCommitted', () {
    testWidgets('fires once per finished edit: pick, Enter and blur', (
      WidgetTester tester,
    ) async {
      final List<DateTime?> committed = <DateTime?>[];
      await tester.pumpWidget(
        _app(
          Column(
            children: <Widget>[
              DsDateField(
                label: 'Vencimento',
                value: DateTime(2026, 10, 20),
                onChanged: (_) {},
                onCommitted: committed.add,
              ),
              const TextField(key: Key('other')),
            ],
          ),
        ),
      );

      // Pick in the calendar.
      await _click(tester, find.byTooltip('Abrir calendário'));
      await _click(tester, find.text('25'));
      expect(committed, <DateTime?>[DateTime(2026, 10, 25)]);

      // Leaving the field without changing anything does not commit again.
      await _click(tester, find.byKey(const Key('other')));
      expect(committed, hasLength(1));

      // Typing commits on blur, not on every key.
      await tester.enterText(find.byType(TextFormField), '26/10/2026');
      expect(committed, hasLength(1));
      await _click(tester, find.byKey(const Key('other')));
      expect(committed.last, DateTime(2026, 10, 26));

      // Enter commits.
      await tester.enterText(find.byType(TextFormField), '27/10/2026');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(committed.last, DateTime(2026, 10, 27));

      // Invalid text is not committed; empty commits null.
      await tester.enterText(find.byType(TextFormField), '31/02/2026');
      await _click(tester, find.byKey(const Key('other')));
      expect(committed, hasLength(3));
      await tester.enterText(find.byType(TextFormField), '');
      await _click(tester, find.byKey(const Key('other')));
      expect(committed.last, isNull);
      expect(committed, hasLength(4));
    });

    testWidgets('closing the calendar without choosing commits nothing', (
      WidgetTester tester,
    ) async {
      final List<DateTime?> committed = <DateTime?>[];
      await tester.pumpWidget(
        _app(
          Column(
            children: <Widget>[
              DsDateField(
                label: 'Vencimento',
                value: DateTime(2026, 10, 20),
                onChanged: (_) {},
                onCommitted: committed.add,
              ),
              const SizedBox(height: 420),
              const Text('fora'),
            ],
          ),
        ),
      );
      await _click(tester, find.byTooltip('Abrir calendário'));
      await _click(tester, find.byTooltip('Próximo mês'));
      await _click(tester, find.text('fora'));
      expect(find.byType(DsCalendar), findsNothing);
      expect(committed, isEmpty);
    });
  });

  group('DsDateField with time and a mouse', () {
    testWidgets('Esc restores the value from before the calendar opened', (
      WidgetTester tester,
    ) async {
      _setSurface(tester, const Size(1280, 800));
      DateTime? value = DateTime(2026, 10, 15, 14, 30);
      final List<DateTime?> committed = <DateTime?>[];
      await tester.pumpWidget(
        _app(
          DsDateField(
            label: 'Pagamento',
            withTime: true,
            value: value,
            onChanged: (DateTime? v) => value = v,
            onCommitted: committed.add,
          ),
        ),
      );
      await _click(tester, find.byTooltip('Abrir calendário'));
      await _click(tester, find.text('20'));
      expect(find.text('20/10/2026 14:30'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(DsCalendar), findsNothing);
      expect(find.text('15/10/2026 14:30'), findsOneWidget);
      expect(value, DateTime(2026, 10, 15, 14, 30));
      expect(committed, isEmpty);
    });

    testWidgets('Esc works from the time field; Concluir commits once', (
      WidgetTester tester,
    ) async {
      _setSurface(tester, const Size(1280, 800));
      final List<DateTime?> committed = <DateTime?>[];
      await tester.pumpWidget(
        _app(
          DsDateField(
            label: 'Pagamento',
            withTime: true,
            value: DateTime(2026, 10, 15, 14, 30),
            onChanged: (_) {},
            onCommitted: committed.add,
          ),
        ),
      );
      await _click(tester, find.byTooltip('Abrir calendário'));
      await _click(tester, find.widgetWithText(TextField, 'Hora'));
      await tester.enterText(find.widgetWithText(TextField, 'Hora'), '09:15');
      await tester.pump();
      // Focus is in the popover, not in the field: still not committed.
      expect(committed, isEmpty);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(DsCalendar), findsNothing);
      expect(find.text('15/10/2026 14:30'), findsOneWidget);
      expect(committed, isEmpty);

      await _click(tester, find.byTooltip('Abrir calendário'));
      await _click(tester, find.text('20'));
      await _click(tester, find.text('Concluir'));
      expect(committed, <DateTime?>[DateTime(2026, 10, 20, 14, 30)]);
    });

    testWidgets('clicking outside keeps the change and commits it', (
      WidgetTester tester,
    ) async {
      _setSurface(tester, const Size(1280, 800));
      final List<DateTime?> committed = <DateTime?>[];
      await tester.pumpWidget(
        _app(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 240,
                child: DsDateField(
                  label: 'Pagamento',
                  withTime: true,
                  value: DateTime(2026, 10, 15, 14, 30),
                  onChanged: (_) {},
                  onCommitted: committed.add,
                ),
              ),
              const SizedBox(width: 400),
              const Text('fora'),
            ],
          ),
        ),
      );
      await _click(tester, find.byTooltip('Abrir calendário'));
      await _click(tester, find.text('20'));
      await _click(tester, find.text('fora'));
      expect(find.byType(DsCalendar), findsNothing);
      expect(find.text('20/10/2026 14:30'), findsOneWidget);
      expect(committed, <DateTime?>[DateTime(2026, 10, 20, 14, 30)]);
    });
  });

  group('DsDateField options', () {
    testWidgets('calendar opens on calendarInitialDate when empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          DsDateField(
            label: 'Nascimento',
            calendarInitialDate: DateTime(2008, 5, 10),
            prefixIcon: const Icon(Icons.cake_outlined),
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.byIcon(Icons.cake_outlined), findsOneWidget);
      await _click(tester, find.byTooltip('Abrir calendário'));
      expect(find.text('Maio de 2008'), findsOneWidget);
    });

    testWidgets('compact fits a table cell and keeps an accessible name', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: DsDateField.compactMinWidth,
              child: DsDateField(
                label: 'Vencimento',
                compact: true,
                value: DateTime(2026, 10, 20),
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      // No floating label: the column header already names the field.
      expect(find.text('Vencimento'), findsNothing);
      expect(find.bySemanticsLabel(RegExp('Vencimento')), findsWidgets);
      expect(
        tester.getSize(find.byType(TextFormField)).height,
        lessThanOrEqualTo(36),
      );
      // The whole date is visible.
      final RenderEditable editable = tester
          .renderObject(find.byType(EditableText).first)
          .descendantRenderEditable!;
      expect(editable.size.width, greaterThanOrEqualTo(80));
      handle.dispose();
    });
  });

  group('DsPagination on narrow screens', () {
    testWidgets('does not overflow at 320 px with many pages', (
      WidgetTester tester,
    ) async {
      _setSurface(tester, const Size(320, 640));
      await tester.pumpWidget(
        _app(
          DsPagination(
            page: 100,
            pageSize: 20,
            totalItems: 20000,
            onPageChanged: (_) {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byTooltip('Próxima página')).height,
        greaterThanOrEqualTo(DsSizes.touchTarget),
      );
    });

    testWidgets('touch can be forced above 900 px', (
      WidgetTester tester,
    ) async {
      _setSurface(tester, const Size(1000, 700));
      await tester.pumpWidget(
        _app(
          Column(
            children: <Widget>[
              DsPagination(
                page: 1,
                pageSize: 20,
                totalItems: 100,
                touch: true,
                onPageChanged: (_) {},
              ),
              DsButton(
                key: const Key('lg'),
                label: 'Buscar',
                size: DsButtonSize.lg,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      expect(
        tester.getSize(find.byTooltip('Próxima página')).height,
        greaterThanOrEqualTo(DsSizes.touchTarget),
      );
      expect(
        tester
            .getSize(
              find.descendant(
                of: find.byKey(const Key('lg')),
                matching: find.byType(Material),
              ),
            )
            .height,
        DsSizes.touchTarget,
      );
    });
  });
}

extension on RenderObject {
  RenderEditable? get descendantRenderEditable {
    RenderEditable? found;
    void visit(RenderObject child) {
      if (found != null) return;
      if (child is RenderEditable) {
        found = child;
        return;
      }
      child.visitChildren(visit);
    }

    if (this is RenderEditable) return this as RenderEditable;
    visitChildren(visit);
    return found;
  }
}

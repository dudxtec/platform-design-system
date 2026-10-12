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
  group('DsDateField editing', () {
    testWidgets('typing digit by digit gets the separators', (
      WidgetTester tester,
    ) async {
      DateTime? value;
      await tester.pumpWidget(
        _app(DsDateField(label: 'Data', onChanged: (DateTime? v) => value = v)),
      );
      await tester.showKeyboard(find.byType(TextFormField));
      String text = '';
      for (final String digit in '25122026'.split('')) {
        final String current = tester
            .widget<EditableText>(find.byType(EditableText))
            .controller
            .text;
        text = '$current$digit';
        tester.testTextInput.updateEditingValue(
          TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          ),
        );
        await tester.pump();
      }
      expect(find.text('25/12/2026'), findsOneWidget);
      expect(value, DateTime(2026, 12, 25));
    });

    testWidgets('editing the month keeps the cursor where it is', (
      WidgetTester tester,
    ) async {
      DateTime? value = DateTime(2026, 12, 25);
      await tester.pumpWidget(
        _app(
          DsDateField(
            label: 'Data',
            value: value,
            onChanged: (DateTime? v) => value = v,
          ),
        ),
      );
      await tester.showKeyboard(find.byType(TextFormField));

      // Delete the "2" of the month: 25/1|/2026.
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '25/1/2026',
          selection: TextSelection.collapsed(offset: 4),
        ),
      );
      await tester.pump();
      EditableText editable = tester.widget(find.byType(EditableText));
      expect(editable.controller.text, '25/1/2026');
      expect(editable.controller.selection.baseOffset, 4);
      expect(value, isNull);

      // Type "1": 25/11|/2026.
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '25/11/2026',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );
      await tester.pump();
      editable = tester.widget(find.byType(EditableText));
      expect(editable.controller.text, '25/11/2026');
      expect(editable.controller.selection.baseOffset, 5);
      expect(value, DateTime(2026, 11, 25));
    });

    testWidgets('ISO text is accepted and shown as dd/mm/aaaa on blur', (
      WidgetTester tester,
    ) async {
      DateTime? value;
      await tester.pumpWidget(
        _app(
          Column(
            children: <Widget>[
              DsDateField(label: 'Data', onChanged: (DateTime? v) => value = v),
              const TextField(key: Key('other')),
            ],
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField), '2026-03-05');
      expect(value, DateTime(2026, 3, 5));
      expect(find.text('2026-03-05'), findsOneWidget);

      await tester.tap(find.byKey(const Key('other')));
      await tester.pump();
      expect(find.text('05/03/2026'), findsOneWidget);
    });

    testWidgets('an external controller is used and normalised', (
      WidgetTester tester,
    ) async {
      final TextEditingController controller = TextEditingController(
        text: '2026-03-05',
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _app(
          DsDateField(label: 'Data', controller: controller, onChanged: (_) {}),
        ),
      );
      expect(controller.text, '05/03/2026');

      await tester.tap(find.byTooltip('Abrir calendário'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('21'));
      await tester.pumpAndSettle();
      expect(controller.text, '21/03/2026');
    });

    testWidgets('closing the calendar without choosing keeps the text', (
      WidgetTester tester,
    ) async {
      final List<DateTime?> picked = <DateTime?>[];
      await tester.pumpWidget(
        _app(
          DsDateField(
            label: 'Data',
            value: DateTime(2026, 3, 5),
            onChanged: (_) {},
            onPicked: picked.add,
          ),
        ),
      );
      // Opened with the mouse: Esc must still close it.
      await tester.tap(find.byTooltip('Abrir calendário'));
      await tester.pumpAndSettle();
      expect(find.byType(DsCalendar), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(DsCalendar), findsNothing);
      expect(find.text('05/03/2026'), findsOneWidget);
      expect(picked, isEmpty);

      await tester.tap(find.byTooltip('Abrir calendário'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('9'));
      await tester.pumpAndSettle();
      expect(picked, <DateTime?>[DateTime(2026, 3, 9)]);
    });
  });

  group('DsDateField with time', () {
    testWidgets('typed date and time are parsed; date alone is midnight', (
      WidgetTester tester,
    ) async {
      DateTime? value;
      await tester.pumpWidget(
        _app(
          DsDateField(
            label: 'Pagamento',
            withTime: true,
            onChanged: (DateTime? v) => value = v,
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField), '05/03/2026 14:30');
      expect(value, DateTime(2026, 3, 5, 14, 30));
      await tester.enterText(find.byType(TextFormField), '05/03/2026');
      expect(value, DateTime(2026, 3, 5));
      await tester.enterText(find.byType(TextFormField), '05/03/2026 25:00');
      expect(value, isNull);
    });

    testWidgets('picking a day keeps the time; the time can be edited', (
      WidgetTester tester,
    ) async {
      _setSurface(tester, const Size(1280, 800));
      DateTime? value = DateTime(2026, 3, 5, 14, 30, 45);
      final List<DateTime?> picked = <DateTime?>[];
      await tester.pumpWidget(
        _app(
          DsDateField(
            label: 'Pagamento',
            withTime: true,
            value: value,
            onChanged: (DateTime? v) => value = v,
            onPicked: picked.add,
          ),
        ),
      );
      expect(find.text('05/03/2026 14:30:45'), findsOneWidget);

      await tester.tap(find.byTooltip('Abrir calendário'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('21'));
      await tester.pumpAndSettle();
      expect(value, DateTime(2026, 3, 21, 14, 30, 45));
      // Stays open for the time.
      expect(find.byType(DsCalendar), findsOneWidget);
      expect(picked, isEmpty);

      await tester.enterText(find.widgetWithText(TextField, 'Hora'), '09:15');
      await tester.pump();
      expect(value, DateTime(2026, 3, 21, 9, 15, 45));

      await tester.tap(find.text('Concluir'));
      await tester.pumpAndSettle();
      expect(find.byType(DsCalendar), findsNothing);
      expect(picked, <DateTime?>[DateTime(2026, 3, 21, 9, 15, 45)]);
      expect(tester.takeException(), isNull);
    });
  });

  group('DsToast', () {
    testWidgets('is drawn above an open dialog and dismisses itself', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (BuildContext context) {
              return DsButton(
                label: 'Abrir',
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (BuildContext dialogContext) => AlertDialog(
                    title: const Text('Novo carnê'),
                    content: const SizedBox(width: 400, height: 520),
                    actions: <Widget>[
                      DsButton(
                        label: 'Salvar',
                        onPressed: () => DsToast.error(
                          dialogContext,
                          'Não foi possível salvar.',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar'));
      await tester.pump();

      final Finder toast = find.text('Não foi possível salvar.');
      expect(toast, findsOneWidget);
      // Hit-testable means nothing (the dialog barrier included) covers it.
      expect(toast.hitTestable(), findsOneWidget);

      await tester.pump(const Duration(seconds: 9));
      expect(toast, findsNothing);
    });

    testWidgets('a new toast replaces the current one; close button works', (
      WidgetTester tester,
    ) async {
      late BuildContext context;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (BuildContext c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      );
      DsToast.success(context, 'Primeiro');
      await tester.pump();
      DsToast.success(context, 'Segundo');
      await tester.pump();
      expect(find.text('Primeiro'), findsNothing);
      expect(find.text('Segundo'), findsOneWidget);

      await tester.tap(find.byTooltip('Fechar'));
      await tester.pump();
      expect(find.text('Segundo'), findsNothing);
    });
  });

  group('touch targets', () {
    testWidgets('default button and pagination grow to 44 below 900 px', (
      WidgetTester tester,
    ) async {
      _setSurface(tester, const Size(800, 600));
      await tester.pumpWidget(
        _app(
          Column(
            children: <Widget>[
              DsButton(key: const Key('b'), label: 'Buscar', onPressed: () {}),
              DsPagination(
                page: 1,
                pageSize: 20,
                totalItems: 100,
                onPageChanged: (_) {},
              ),
            ],
          ),
        ),
      );
      expect(
        tester
            .getSize(
              find.descendant(
                of: find.byKey(const Key('b')),
                matching: find.byType(Material),
              ),
            )
            .height,
        DsSizes.touchTarget,
      );
      expect(
        tester.getSize(find.byTooltip('Próxima página')).height,
        greaterThanOrEqualTo(DsSizes.touchTarget),
      );
    });
  });

  group('component additions', () {
    testWidgets('DsErrorState shows a second way out', (
      WidgetTester tester,
    ) async {
      int exits = 0;
      await tester.pumpWidget(
        _app(
          DsErrorState(
            onRetry: () {},
            secondaryAction: DsButton(
              label: 'Sair',
              variant: DsButtonVariant.ghost,
              onPressed: () => exits++,
            ),
          ),
        ),
      );
      expect(find.text('Tentar novamente'), findsOneWidget);
      await tester.tap(find.text('Sair'));
      expect(exits, 1);
    });

    testWidgets('DsSectionCard collapses and reports it', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];
      await tester.pumpWidget(
        _app(
          DsSectionCard(
            title: 'Notificações',
            collapsible: true,
            initiallyExpanded: false,
            onExpansionChanged: changes.add,
            child: const Text('corpo'),
          ),
        ),
      );
      expect(find.text('corpo'), findsNothing);
      await tester.tap(find.text('Notificações'));
      await tester.pump();
      expect(find.text('corpo'), findsOneWidget);
      await tester.tap(find.text('Notificações'));
      await tester.pump();
      expect(find.text('corpo'), findsNothing);
      expect(changes, <bool>[true, false]);
    });

    testWidgets('DsKpiCard draws the share bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        _app(
          const DsKpiCard(
            label: 'Recebidas',
            value: r'R$ 48.320,00',
            progress: 0.68,
            progressTone: DsTone.success,
            helper: '132 cobranças',
          ),
        ),
      );
      final LinearProgressIndicator bar = tester.widget(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, 0.68);
    });

    testWidgets('DsFilterBar blocks Apply while applying', (
      WidgetTester tester,
    ) async {
      int applied = 0;
      await tester.pumpWidget(
        _app(
          DsFilterBar(
            applying: true,
            onApply: () => applied++,
            children: const <Widget>[],
          ),
        ),
      );
      await tester.tap(find.text('Aplicar'));
      expect(applied, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('DsPage accepts edge-to-edge content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const DsPage(
            scrollable: false,
            padding: EdgeInsets.zero,
            child: SizedBox.expand(key: Key('frame')),
          ),
        ),
      );
      expect(tester.getTopLeft(find.byKey(const Key('frame'))), Offset.zero);
    });

    testWidgets('DsAlert puts the action under the text on narrow widths', (
      WidgetTester tester,
    ) async {
      _setSurface(tester, const Size(375, 700));
      await tester.pumpWidget(
        _app(
          DsAlert(
            message: 'Não foi possível carregar as organizações.',
            action: DsButton(
              label: 'Tentar novamente',
              size: DsButtonSize.sm,
              variant: DsButtonVariant.ghost,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(
        tester.getTopLeft(find.text('Tentar novamente')).dy,
        greaterThan(
          tester
              .getBottomLeft(
                find.text('Não foi possível carregar as organizações.'),
              )
              .dy,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_design_system/platform_design_system.dart';

Widget _host(Widget child, {double width = 390}) {
  return MaterialApp(
    theme: DsTheme.light(),
    home: MediaQuery(
      data: MediaQueryData(size: Size(width, 800)),
      child: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  group('DsCompactFilters', () {
    testWidgets('mostra a busca, o botão Filtros e o contador', (tester) async {
      int opened = 0;
      await tester.pumpWidget(
        _host(
          DsCompactFilters(
            search: const TextField(),
            activeCount: 2,
            onOpenFilters: () => opened++,
          ),
        ),
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Filtros (2)'), findsOneWidget);
      await tester.tap(find.text('Filtros (2)'));
      expect(opened, 1);
    });

    testWidgets('sem filtros o botão não mostra contador', (tester) async {
      await tester.pumpWidget(
        _host(
          DsCompactFilters(search: const TextField(), onOpenFilters: () {}),
        ),
      );
      expect(find.text('Filtros'), findsOneWidget);
    });

    testWidgets('o botão Filtros tem 44 px de altura', (tester) async {
      await tester.pumpWidget(
        _host(
          DsCompactFilters(search: const TextField(), onOpenFilters: () {}),
        ),
      );
      final Size size = tester.getSize(find.byType(OutlinedButton));
      expect(size.height, greaterThanOrEqualTo(44));
    });

    testWidgets('chips removem o filtro e Limpar aparece a partir de dois', (
      tester,
    ) async {
      final List<String> removed = <String>[];
      int cleared = 0;
      await tester.pumpWidget(
        _host(
          DsCompactFilters(
            search: const TextField(),
            onOpenFilters: () {},
            activeCount: 2,
            appliedFilters: <DsAppliedFilter>[
              DsAppliedFilter(label: 'Nº 10', onRemove: () => removed.add('n')),
              DsAppliedFilter(
                label: 'Tags: Sócios',
                onRemove: () => removed.add('t'),
              ),
            ],
            onClear: () => cleared++,
          ),
        ),
      );
      expect(find.text('Nº 10'), findsOneWidget);
      expect(find.text('Tags: Sócios'), findsOneWidget);

      await tester.tap(find.byTooltip('Remover filtro Nº 10'));
      expect(removed, <String>['n']);

      await tester.tap(find.text('Limpar'));
      expect(cleared, 1);
    });

    testWidgets('com um só chip não há Limpar', (tester) async {
      await tester.pumpWidget(
        _host(
          DsCompactFilters(
            search: const TextField(),
            onOpenFilters: () {},
            appliedFilters: <DsAppliedFilter>[
              DsAppliedFilter(label: 'Nº 10', onRemove: () {}),
            ],
            onClear: () {},
          ),
        ),
      );
      expect(find.text('Limpar'), findsNothing);
    });

    testWidgets('mostra a contagem e o link de ordenação', (tester) async {
      await tester.pumpWidget(
        _host(
          DsCompactFilters(
            search: const TextField(),
            onOpenFilters: () {},
            resultLabel: '128 pessoas',
            sort: DsSortLink<String>(
              options: const <DsSortOption<String>>[
                DsSortOption<String>(value: 'name', label: 'Nome'),
                DsSortOption<String>(value: 'date', label: 'Criado em'),
              ],
              value: 'name',
              ascending: true,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('128 pessoas'), findsOneWidget);
      expect(find.text('Ordenar: Nome ↑'), findsOneWidget);
    });
  });

  group('DsSortLink', () {
    testWidgets('abre as opções e devolve a escolhida', (tester) async {
      String? picked;
      await tester.pumpWidget(
        _host(
          DsSortLink<String>(
            options: const <DsSortOption<String>>[
              DsSortOption<String>(value: 'name', label: 'Nome'),
              DsSortOption<String>(value: 'date', label: 'Criado em'),
            ],
            value: 'name',
            ascending: false,
            onSelected: (String value) => picked = value,
          ),
        ),
      );
      expect(find.text('Ordenar: Nome ↓'), findsOneWidget);
      await tester.tap(find.text('Ordenar: Nome ↓'));
      await tester.pumpAndSettle();
      expect(find.text('Nome (↓)'), findsOneWidget);
      await tester.tap(find.text('Criado em'));
      await tester.pumpAndSettle();
      expect(picked, 'date');
    });
  });

  group('showDsFilterSheet', () {
    Future<void> open(WidgetTester tester, {required double width}) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: TextButton(
                onPressed: () => showDsFilterSheet(
                  context,
                  title: 'Filtros',
                  builder: (_) => const Text('conteúdo'),
                  onClear: () {},
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    testWidgets('no celular é uma folha inferior', (tester) async {
      await open(tester, width: 390);
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('conteúdo'), findsOneWidget);
      expect(find.text('Aplicar'), findsOneWidget);
      expect(find.text('Limpar'), findsOneWidget);
    });

    testWidgets('acima de 600 px é um diálogo', (tester) async {
      await open(tester, width: 1024);
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('conteúdo'), findsOneWidget);
    });

    testWidgets('Aplicar fecha devolvendo true', (tester) async {
      bool? result;
      tester.view.physicalSize = const Size(390, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: TextButton(
                onPressed: () async => result = await showDsFilterSheet(
                  context,
                  title: 'Filtros',
                  builder: (_) => const SizedBox(),
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aplicar'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });
  });
}

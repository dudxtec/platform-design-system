import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_design_system/platform_design_system.dart';

double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

Widget _app(
  Widget child, {
  ThemeData? theme,
  Size size = const Size(1280, 800),
}) {
  return MaterialApp(
    theme: theme ?? DsTheme.light(),
    home: MediaQuery(
      data: MediaQueryData(size: size),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('DsColorTokens contrast (WCAG AA)', () {
    for (final MapEntry<String, DsColorTokens> entry in <String, DsColorTokens>{
      'light': DsColorTokens.light,
      'dark': DsColorTokens.dark,
    }.entries) {
      final DsColorTokens c = entry.value;

      test('${entry.key}: text on surfaces reaches 4.5:1', () {
        expect(_contrast(c.textPrimary, c.surface), greaterThanOrEqualTo(4.5));
        expect(_contrast(c.textPrimary, c.canvas), greaterThanOrEqualTo(4.5));
        expect(
          _contrast(c.textSecondary, c.surface),
          greaterThanOrEqualTo(4.5),
        );
        expect(_contrast(c.textSecondary, c.canvas), greaterThanOrEqualTo(4.5));
        expect(_contrast(c.textTertiary, c.surface), greaterThanOrEqualTo(4.5));
        expect(
          _contrast(c.textInverse, c.surfaceInverse),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('${entry.key}: actions reach 4.5:1', () {
        expect(_contrast(c.onPrimary, c.primary), greaterThanOrEqualTo(4.5));
        expect(
          _contrast(c.onPrimary, c.primaryHover),
          greaterThanOrEqualTo(4.5),
        );
        expect(_contrast(c.primary, c.surface), greaterThanOrEqualTo(4.5));
        expect(_contrast(c.onAccent, c.accent), greaterThanOrEqualTo(4.5));
      });

      test('${entry.key}: control borders and focus ring reach 3:1', () {
        expect(_contrast(c.borderStrong, c.surface), greaterThanOrEqualTo(3));
        expect(_contrast(c.focusRing, c.surface), greaterThanOrEqualTo(3));
      });

      test('${entry.key}: every tone is legible', () {
        for (final DsTone tone in DsTone.values) {
          final DsToneColors t = c.tone(tone);
          expect(
            _contrast(t.text, t.subtle),
            greaterThanOrEqualTo(4.5),
            reason: '$tone text on subtle',
          );
          expect(
            _contrast(t.text, c.surface),
            greaterThanOrEqualTo(4.5),
            reason: '$tone text on surface',
          );
          expect(
            _contrast(t.onSolid, t.solid),
            greaterThanOrEqualTo(4.5),
            reason: '$tone onSolid on solid',
          );
        }
      });

      test('${entry.key}: filled buttons and the fab reach 4.5:1', () {
        for (final Color fill in <Color>[c.dangerSolid, c.successSolid, c.fab]) {
          expect(
            _contrast(c.onFill, fill),
            greaterThanOrEqualTo(4.5),
            reason: 'onFill on $fill',
          );
        }
      });

      test('${entry.key}: the fab and the selected chip stand out (3:1)', () {
        expect(_contrast(c.fab, c.surface), greaterThanOrEqualTo(3));
        expect(_contrast(c.fab, c.canvas), greaterThanOrEqualTo(3));
        expect(
          _contrast(c.primary, c.surfaceSelected),
          greaterThanOrEqualTo(3),
        );
        expect(_contrast(c.primary, c.surface), greaterThanOrEqualTo(3));
      });

      test('${entry.key}: danger and success keep a step for icons', () {
        // Icons, bars and borders are drawn straight on the surface.
        expect(
          _contrast(c.dangerTone.solid, c.surface),
          greaterThanOrEqualTo(3),
        );
        expect(
          _contrast(c.successTone.solid, c.surface),
          greaterThanOrEqualTo(3),
        );
      });
    }
  });

  group('tokens', () {
    test('legacy names map to the numeric scale', () {
      expect(DsSpacing.md, DsSpacing.s16);
      expect(DsSpacing.xl, DsSpacing.s24);
      expect(DsColors.primary, DsPalette.teal600);
      expect(DsColors.background, DsColorTokens.light.canvas);
    });

    test('theme exposes the tokens of its brightness', () {
      expect(DsTheme.light().extension<DsColorTokens>(), DsColorTokens.light);
      expect(DsTheme.dark().extension<DsColorTokens>(), DsColorTokens.dark);
    });

    test('lerp reaches both ends', () {
      const DsColorTokens a = DsColorTokens.light;
      const DsColorTokens b = DsColorTokens.dark;
      expect(a.lerp(b, 0).surface, a.surface);
      expect(a.lerp(b, 1).surface, b.surface);
      expect(a.lerp(b, 1).dangerTone.text, b.dangerTone.text);
    });

    test('every type style defines size and line height', () {
      final TextTheme t = DsTheme.light().textTheme;
      for (final TextStyle? s in <TextStyle?>[
        t.headlineLarge,
        t.headlineMedium,
        t.headlineSmall,
        t.titleLarge,
        t.titleMedium,
        t.titleSmall,
        t.bodyLarge,
        t.bodyMedium,
        t.bodySmall,
        t.labelLarge,
        t.labelMedium,
        t.labelSmall,
      ]) {
        expect(s?.fontSize, isNotNull);
        expect(s?.height, isNotNull);
      }
    });

    testWidgets('context.dsColors falls back to light without DsTheme', (
      WidgetTester tester,
    ) async {
      late DsColorTokens tokens;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              tokens = context.dsColors;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(tokens, DsColorTokens.light);
    });
  });

  group('DsButton', () {
    testWidgets('variants map to the themed Material buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: <Widget>[
              DsButton(label: 'A', onPressed: () {}),
              DsButton(
                label: 'B',
                onPressed: () {},
                variant: DsButtonVariant.secondary,
              ),
              DsButton(
                label: 'C',
                onPressed: () {},
                variant: DsButtonVariant.ghost,
              ),
              DsButton(
                label: 'D',
                onPressed: () {},
                variant: DsButtonVariant.danger,
              ),
            ],
          ),
        ),
      );
      expect(find.byType(FilledButton), findsNWidgets(2));
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('danger and success are filled with their own token', (
      WidgetTester tester,
    ) async {
      final Map<ThemeData, DsColorTokens> themes = <ThemeData, DsColorTokens>{
        DsTheme.light(): DsColorTokens.light,
        DsTheme.dark(): DsColorTokens.dark,
      };
      for (final MapEntry<ThemeData, DsColorTokens> entry in themes.entries) {
        await tester.pumpWidget(
          _app(
            Column(
              children: <Widget>[
                DsButton(
                  label: 'D',
                  onPressed: () {},
                  variant: DsButtonVariant.danger,
                ),
                DsButton(
                  label: 'S',
                  onPressed: () {},
                  variant: DsButtonVariant.success,
                ),
              ],
            ),
            theme: entry.key,
          ),
        );
        final DsColorTokens c = entry.value;
        final List<FilledButton> buttons = tester
            .widgetList<FilledButton>(find.byType(FilledButton))
            .toList();
        final Set<WidgetState> idle = <WidgetState>{};
        final Set<WidgetState> hovered = <WidgetState>{WidgetState.hovered};

        for (int i = 0; i < buttons.length; i++) {
          final Color fill = i == 0 ? c.dangerSolid : c.successSolid;
          final ButtonStyle style = buttons[i].style!;
          expect(style.backgroundColor!.resolve(idle), fill);
          expect(style.foregroundColor!.resolve(idle), c.onFill);

          final Color active = style.backgroundColor!.resolve(hovered)!;
          expect(active.computeLuminance(), lessThan(fill.computeLuminance()));
          expect(_contrast(c.onFill, active), greaterThanOrEqualTo(4.5));
        }
      }
    });

    testWidgets('loading disables the button and shows progress', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _app(DsButton(label: 'Salvar', loading: true, onPressed: () => taps++)),
      );
      await tester.tap(find.text('Salvar'));
      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('default height is 40 and small is 32', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Column(
            children: <Widget>[
              DsButton(key: const Key('md'), label: 'M', onPressed: () {}),
              DsButton(
                key: const Key('sm'),
                label: 'S',
                onPressed: () {},
                size: DsButtonSize.sm,
              ),
            ],
          ),
        ),
      );
      double materialHeight(String key) {
        return tester
            .getSize(
              find.descendant(
                of: find.byKey(Key(key)),
                matching: find.byType(Material),
              ),
            )
            .height;
      }

      expect(materialHeight('md'), DsSizes.controlMd);
      expect(materialHeight('sm'), DsSizes.controlSm);
    });
  });

  group('chips', () {
    test('selected has a 2 px primary border and a check mark', () {
      final Map<ThemeData, DsColorTokens> themes = <ThemeData, DsColorTokens>{
        DsTheme.light(): DsColorTokens.light,
        DsTheme.dark(): DsColorTokens.dark,
      };
      for (final MapEntry<ThemeData, DsColorTokens> entry in themes.entries) {
        final ChipThemeData chip = entry.key.chipTheme;
        final BorderSide? selected = WidgetStateProperty.resolveAs<BorderSide?>(
          chip.side,
          <WidgetState>{WidgetState.selected},
        );
        final BorderSide? idle = WidgetStateProperty.resolveAs<BorderSide?>(
          chip.side,
          <WidgetState>{},
        );

        expect(selected!.width, 2);
        expect(selected.color, entry.value.primary);
        expect(idle!.width, 1);
        expect(idle.color, entry.value.borderStrong);
        expect(chip.showCheckmark, isTrue);
      }
    });

    testWidgets('a selected FilterChip draws the 2 px border', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          FilterChip(
            label: const Text('Vencidos'),
            selected: true,
            onSelected: (bool value) {},
          ),
        ),
      );

      final Material material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(FilterChip),
              matching: find.byType(Material),
            )
            .first,
      );
      final OutlinedBorder shape = material.shape! as OutlinedBorder;
      expect(shape.side.width, 2);
      expect(shape.side.color, DsColorTokens.light.primary);
    });
  });

  group('feedback', () {
    testWidgets('DsConfirmDialog resolves true on confirm, false on cancel', (
      WidgetTester tester,
    ) async {
      bool? result;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (BuildContext context) {
              return DsButton(
                label: 'Abrir',
                onPressed: () async {
                  result = await DsConfirmDialog.show(
                    context,
                    title: 'Excluir pessoa',
                    message: 'Esta ação não pode ser desfeita.',
                    confirmLabel: 'Excluir',
                    destructive: true,
                  );
                },
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();
      expect(result, isTrue);

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('DsToast shows the message', (WidgetTester tester) async {
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (BuildContext context) {
              return DsButton(
                label: 'Salvar',
                onPressed: () => DsToast.success(context, 'Pessoa salva.'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Salvar'));
      await tester.pump();
      expect(find.text('Pessoa salva.'), findsOneWidget);
    });

    testWidgets('DsErrorState retries', (WidgetTester tester) async {
      int retries = 0;
      await tester.pumpWidget(_app(DsErrorState(onRetry: () => retries++)));
      await tester.tap(find.text('Tentar novamente'));
      expect(retries, 1);
    });
  });

  group('DsAppShell', () {
    const List<DsNavSection> sections = <DsNavSection>[
      DsNavSection(
        title: 'Módulos',
        items: <DsNavItem>[
          DsNavItem(id: 'person', label: 'Pessoas', icon: Icons.people_outline),
          DsNavItem(
            id: 'reports',
            label: 'Relatórios',
            icon: Icons.bar_chart,
            opensInNewTab: true,
          ),
        ],
      ),
    ];

    Widget shell({
      Size size = const Size(1280, 800),
      bool embedded = false,
      ValueChanged<DsNavItem>? onNavigate,
    }) {
      return MaterialApp(
        theme: DsTheme.light(),
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: DsAppShell(
            sections: sections,
            selectedId: 'person',
            embedded: embedded,
            onNavigate: onNavigate ?? (_) {},
            brand: const Text('Plataforma'),
            body: const Text('conteúdo'),
          ),
        ),
      );
    }

    testWidgets('desktop shows the sidebar and navigates', (
      WidgetTester tester,
    ) async {
      DsNavItem? tapped;
      await tester.pumpWidget(shell(onNavigate: (DsNavItem i) => tapped = i));
      expect(find.text('Pessoas'), findsOneWidget);
      await tester.tap(find.text('Relatórios'));
      expect(tapped?.id, 'reports');
    });

    testWidgets('collapsing hides labels without overflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(shell());
      await tester.tap(find.byTooltip('Recolher menu'));
      await tester.pumpAndSettle();
      expect(find.text('Pessoas'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Expandir menu'));
      await tester.pumpAndSettle();
      expect(find.text('Pessoas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mobile moves navigation to a drawer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(shell(size: const Size(390, 800)));
      expect(find.text('Pessoas'), findsNothing);
      await tester.tap(find.byTooltip('Abrir menu'));
      await tester.pumpAndSettle();
      expect(find.text('Pessoas'), findsOneWidget);
    });

    testWidgets('embedded renders only the body', (WidgetTester tester) async {
      await tester.pumpWidget(shell(embedded: true));
      expect(find.text('conteúdo'), findsOneWidget);
      expect(find.text('Plataforma'), findsNothing);
      expect(find.text('Pessoas'), findsNothing);
    });
  });

  group('DsPagination', () {
    testWidgets('shows the range and disables edges', (
      WidgetTester tester,
    ) async {
      final List<int> pages = <int>[];
      await tester.pumpWidget(
        _app(
          DsPagination(
            page: 1,
            pageSize: 20,
            totalItems: 249,
            onPageChanged: pages.add,
          ),
        ),
      );
      expect(find.text('1–20 de 249'), findsOneWidget);
      expect(find.text('Página 1 de 13'), findsOneWidget);
      await tester.tap(find.byTooltip('Página anterior'));
      expect(pages, isEmpty);
      await tester.tap(find.byTooltip('Próxima página'));
      await tester.tap(find.byTooltip('Última página'));
      expect(pages, <int>[2, 13]);
    });

    testWidgets('last page clamps the range; empty shows zero', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          DsPagination(
            page: 13,
            pageSize: 20,
            totalItems: 249,
            onPageChanged: (_) {},
          ),
        ),
      );
      expect(find.text('241–249 de 249'), findsOneWidget);

      await tester.pumpWidget(
        _app(
          DsPagination(
            page: 1,
            pageSize: 20,
            totalItems: 0,
            onPageChanged: (_) {},
          ),
        ),
      );
      expect(find.text('0–0 de 0'), findsOneWidget);
      expect(find.text('Página 1 de 1'), findsOneWidget);
    });
  });

  group('DsDataTable', () {
    const List<DataColumn> columns = <DataColumn>[
      DataColumn(label: Text('Nome')),
      DataColumn(label: Text('Status')),
    ];
    const List<DataRow> rows = <DataRow>[
      DataRow(
        cells: <DataCell>[DataCell(Text('Ana')), DataCell(Text('Ativo'))],
      ),
    ];

    testWidgets('renders rows, toolbar and pagination when ready', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const DsDataTable(
            columns: columns,
            rows: rows,
            toolbar: Text('toolbar'),
            pagination: Text('paginação'),
          ),
        ),
      );
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('toolbar'), findsOneWidget);
      expect(find.text('paginação'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('states replace the rows', (WidgetTester tester) async {
      for (final DsDataState state in <DsDataState>[
        DsDataState.loading,
        DsDataState.empty,
        DsDataState.error,
      ]) {
        await tester.pumpWidget(
          _app(DsDataTable(columns: columns, rows: rows, state: state)),
        );
        expect(find.text('Ana'), findsNothing, reason: '$state');
        expect(tester.takeException(), isNull, reason: '$state');
      }
      expect(find.text('Não foi possível carregar'), findsOneWidget);
    });

    testWidgets('selection swaps the toolbar for the bulk bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          DsDataTable(
            columns: columns,
            rows: rows,
            toolbar: const Text('toolbar'),
            selectedCount: 3,
            onClearSelection: () {},
            bulkActions: const <Widget>[Text('Exportar')],
          ),
        ),
      );
      expect(find.text('toolbar'), findsNothing);
      expect(find.text('3 selecionados'), findsOneWidget);
      expect(find.text('Exportar'), findsOneWidget);
    });

    testWidgets('works inside an unbounded scrolling page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const DsPage(
            header: DsPageHeader(title: 'Pessoas'),
            child: DsDataTable(columns: columns, rows: rows),
          ),
        ),
      );
      expect(find.text('Ana'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fills a bounded page and pins pagination', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const DsPage(
            scrollable: false,
            header: DsPageHeader(title: 'Pessoas'),
            child: DsDataTable(
              columns: columns,
              rows: rows,
              pagination: Text('paginação'),
            ),
          ),
        ),
      );
      expect(find.text('paginação'), findsOneWidget);
      expect(
        tester.getBottomLeft(find.byType(Card)).dy,
        closeTo(
          tester.getSize(find.byType(Scaffold)).height - DsSpacing.s24,
          0.5,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('layout', () {
    testWidgets('DsPageHeader stacks actions on narrow widths', (
      WidgetTester tester,
    ) async {
      Widget header() => DsPageHeader(
        title: 'Pessoas',
        subtitle: '249 registros',
        breadcrumbs: <DsBreadcrumbItem>[
          DsBreadcrumbItem('Início', onTap: () {}),
          const DsBreadcrumbItem('Cadastros'),
        ],
        actions: <Widget>[DsButton(label: 'Nova pessoa', onPressed: () {})],
      );

      await tester.pumpWidget(_app(header()));
      final double titleY = tester.getTopLeft(find.text('Pessoas')).dy;
      final double actionY = tester.getTopLeft(find.text('Nova pessoa')).dy;
      expect((actionY - titleY).abs(), lessThan(40));

      await tester.pumpWidget(
        _app(
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 360, child: header()),
          ),
        ),
      );
      expect(
        tester.getTopLeft(find.text('Nova pessoa')).dy,
        greaterThan(tester.getBottomLeft(find.text('249 registros')).dy),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('DsFormGrid uses two columns on desktop and one on mobile', (
      WidgetTester tester,
    ) async {
      Widget grid(double width) => Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: const DsFormGrid(
            children: <Widget>[
              SizedBox(key: Key('a'), height: 40),
              SizedBox(key: Key('b'), height: 40),
              DsFormFull(child: SizedBox(key: Key('c'), height: 40)),
            ],
          ),
        ),
      );

      await tester.pumpWidget(_app(grid(760)));
      expect(
        tester.getTopLeft(find.byKey(const Key('a'))).dy,
        tester.getTopLeft(find.byKey(const Key('b'))).dy,
      );
      expect(tester.getSize(find.byKey(const Key('c'))).width, 760);

      await tester.pumpWidget(_app(grid(360)));
      expect(
        tester.getTopLeft(find.byKey(const Key('b'))).dy,
        greaterThan(tester.getTopLeft(find.byKey(const Key('a'))).dy),
      );
    });

    testWidgets('display components render in dark', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _app(
          theme: DsTheme.dark(),
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                DsKpiCard(
                  label: 'Recebidas',
                  value: r'R$ 12.480,00',
                  delta: '+12,4%',
                  deltaTone: DsTone.success,
                  helper: 'vs. mês anterior',
                  onTap: () {},
                ),
                const DsBadge(label: 'Vencida', tone: DsTone.danger),
                DsAlert(
                  tone: DsTone.warning,
                  title: 'Atenção',
                  message: 'Integração indisponível.',
                  onClose: () {},
                ),
                const DsSectionCard(
                  title: 'Dados pessoais',
                  description: 'Identificação',
                  child: Text('corpo'),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text(r'R$ 12.480,00'), findsOneWidget);
      expect(find.text('Vencida'), findsOneWidget);
      expect(find.text('Integração indisponível.'), findsOneWidget);
      expect(find.text('corpo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DsFieldLabel announces required fields', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(const DsFieldLabel('Nome', required: true)));
      expect(find.bySemanticsLabel('Nome, obrigatório'), findsOneWidget);
      handle.dispose();
    });
  });
}

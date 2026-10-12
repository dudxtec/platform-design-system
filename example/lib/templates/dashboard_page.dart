import 'package:flutter/material.dart';
import 'package:platform_design_system/platform_design_system.dart';

/// Template: Dashboard. KPIs first, then alerts and pending work, then detail.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime? _from = DateTime(2026, 10);
  DateTime? _to = DateTime(2026, 10, 31);

  @override
  Widget build(BuildContext context) {
    return DsPage(
      filters: DsFilterBar(
        onApply: () => DsToast.show(context, 'Período aplicado.'),
        children: <Widget>[
          DsDateRangeField(
            start: _from,
            end: _to,
            onChanged: (DateTime? start, DateTime? end) => setState(() {
              _from = start;
              _to = end;
            }),
          ),
        ],
      ),
      header: DsPageHeader(
        title: 'Financeiro',
        subtitle: 'Outubro de 2026',
        breadcrumbs: const <DsBreadcrumbItem>[
          DsBreadcrumbItem('Início'),
          DsBreadcrumbItem('Financeiro'),
        ],
        actions: <Widget>[
          DsButton(
            label: 'Exportar',
            icon: Icons.download_outlined,
            variant: DsButtonVariant.secondary,
            onPressed: () {},
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DsAlert(
            tone: DsTone.warning,
            title: '12 cobranças vencem hoje',
            message: 'Somam R\$ 3.240,00. Envie o lembrete antes das 18h.',
            action: DsButton(
              label: 'Ver cobranças',
              variant: DsButtonVariant.ghost,
              size: DsButtonSize.sm,
              onPressed: () {},
            ),
          ),
          const SizedBox(height: DsSpacing.s16),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final int columns = constraints.maxWidth < DsBreakpoints.mobile
                  ? 1
                  : constraints.maxWidth < DsBreakpoints.tablet
                  ? 2
                  : 4;
              final double width =
                  ((constraints.maxWidth - DsSpacing.s16 * (columns - 1)) /
                          columns)
                      .floorToDouble();
              return Wrap(
                spacing: DsSpacing.s16,
                runSpacing: DsSpacing.s16,
                children: <Widget>[
                  for (final DsKpiCard card in <DsKpiCard>[
                    DsKpiCard(
                      label: 'Recebidas',
                      value: r'R$ 48.320,00',
                      delta: '+12,4%',
                      deltaTone: DsTone.success,
                      helper: 'vs. setembro',
                      onTap: () {},
                    ),
                    DsKpiCard(
                      label: 'Aguardando',
                      value: r'R$ 15.870,00',
                      delta: '−3,1%',
                      helper: '86 cobranças',
                      onTap: () {},
                    ),
                    DsKpiCard(
                      label: 'Vencidas',
                      value: r'R$ 6.410,00',
                      delta: '+8,0%',
                      deltaTone: DsTone.danger,
                      helper: '31 cobranças',
                      onTap: () {},
                    ),
                    const DsKpiCard(
                      label: 'Carnês ativos',
                      value: '1.249',
                      delta: '+24',
                      deltaTone: DsTone.success,
                      helper: 'no mês',
                    ),
                  ])
                    SizedBox(width: width, child: card),
                ],
              );
            },
          ),
          const SizedBox(height: DsSpacing.s24),
          DsSectionCard(
            title: 'Por forma de pagamento',
            description: 'Recebido no período',
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                for (final (String, String, double) row
                    in <(String, String, double)>[
                      ('Pix', r'R$ 27.940,00', 0.58),
                      ('Cartão de crédito', r'R$ 14.210,00', 0.29),
                      ('Boleto', r'R$ 6.170,00', 0.13),
                    ])
                  _RankingRow(label: row.$1, value: row.$2, share: row.$3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.label,
    required this.value,
    required this.share,
  });

  final String label;
  final String value;
  final double share;

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpacing.s16,
        vertical: DsSpacing.s12,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 160, child: Text(label, style: text.bodyMedium)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DsRadius.pill),
              child: LinearProgressIndicator(
                value: share,
                minHeight: 8,
                backgroundColor: c.surfaceHover,
                semanticsLabel: label,
                semanticsValue: '${(share * 100).round()}%',
              ),
            ),
          ),
          const SizedBox(width: DsSpacing.s16),
          SizedBox(
            width: 120,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: DsTypography.table.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:platform_design_system/platform_design_system.dart';

class ComponentsPage extends StatelessWidget {
  const ComponentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final DsColorTokens c = context.dsColors;

    Widget row(List<Widget> children) => Wrap(
      spacing: DsSpacing.s12,
      runSpacing: DsSpacing.s12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );

    return DsPage(
      header: const DsPageHeader(
        title: 'Componentes',
        subtitle: 'Todos os estados, no tema ativo.',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DsSectionCard(
            title: 'Botões',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                row(<Widget>[
                  DsButton(label: 'Salvar', onPressed: () {}),
                  DsButton(
                    label: 'Exportar',
                    icon: Icons.download_outlined,
                    variant: DsButtonVariant.secondary,
                    onPressed: () {},
                  ),
                  DsButton(
                    label: 'Cancelar',
                    variant: DsButtonVariant.ghost,
                    onPressed: () {},
                  ),
                  DsButton(
                    label: 'Excluir',
                    variant: DsButtonVariant.danger,
                    onPressed: () {},
                  ),
                  DsButton(
                    label: 'Confirmar',
                    variant: DsButtonVariant.success,
                    onPressed: () {},
                  ),
                  const DsButton(label: 'Salvando', loading: true),
                  const DsButton(label: 'Desabilitado'),
                  const DsButton(
                    label: 'Desabilitado',
                    variant: DsButtonVariant.secondary,
                  ),
                ]),
                const SizedBox(height: DsSpacing.s12),
                row(<Widget>[
                  DsButton(
                    label: 'Pequeno',
                    size: DsButtonSize.sm,
                    onPressed: () {},
                  ),
                  DsButton(
                    label: 'Pequeno',
                    size: DsButtonSize.sm,
                    variant: DsButtonVariant.secondary,
                    onPressed: () {},
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: DsSpacing.s24),
          DsSectionCard(
            title: 'Chips e botão flutuante',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                row(<Widget>[
                  FilterChip(
                    label: const Text('Ativos'),
                    selected: true,
                    onSelected: (bool value) {},
                  ),
                  FilterChip(
                    label: const Text('Vencidos'),
                    selected: false,
                    onSelected: (bool value) {},
                  ),
                ]),
                const SizedBox(height: DsSpacing.s16),
                SizedBox(
                  height: 320,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: c.border),
                      borderRadius: BorderRadius.circular(DsRadius.sm),
                    ),
                    child: DsActionFab(
                      actions: <DsFabAction>[
                        DsFabAction(
                          label: 'Novo carnê',
                          icon: Icons.receipt_long_outlined,
                          onPressed: () {},
                        ),
                        DsFabAction(
                          label: 'Exportar',
                          icon: Icons.file_download_outlined,
                          children: <DsFabAction>[
                            DsFabAction(
                              label: 'Excel',
                              icon: Icons.table_chart_outlined,
                              onPressed: () {},
                            ),
                            DsFabAction(
                              label: 'CSV',
                              icon: Icons.description_outlined,
                              onPressed: () {},
                            ),
                            DsFabAction(
                              label: 'PDF',
                              icon: Icons.picture_as_pdf_outlined,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                      child: Center(
                        child: Text(
                          'Área da lista',
                          style: text.bodyMedium?.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DsSpacing.s24),
          DsSectionCard(
            title: 'Filtros compactos',
            child: Builder(
              builder: (BuildContext context) => DsCompactFilters(
                search: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Nome, CPF, telefone ou nº',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                activeCount: 2,
                onOpenFilters: () => showDsFilterSheet(
                  context,
                  title: 'Filtros',
                  onClear: () {},
                  builder: (_) => const Text('Situação, tags e período'),
                ),
                appliedFilters: <DsAppliedFilter>[
                  DsAppliedFilter(label: 'Tags: Sócios', onRemove: () {}),
                  DsAppliedFilter(label: 'Nº 1234', onRemove: () {}),
                ],
                onClear: () {},
                resultLabel: '128 carnês',
                sort: DsSortLink<String>(
                  options: const <DsSortOption<String>>[
                    DsSortOption<String>(value: 'person', label: 'Pessoa'),
                    DsSortOption<String>(value: 'date', label: 'Criado em'),
                  ],
                  value: 'person',
                  ascending: true,
                  onSelected: (_) {},
                ),
              ),
            ),
          ),
          const SizedBox(height: DsSpacing.s24),
          DsSectionCard(
            title: 'Badges e alertas',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                row(const <Widget>[
                  DsBadge(label: 'Rascunho'),
                  DsBadge(label: 'Em análise', tone: DsTone.info),
                  DsBadge(label: 'Pago', tone: DsTone.success),
                  DsBadge(label: 'Aguardando', tone: DsTone.warning),
                  DsBadge(label: 'Vencida', tone: DsTone.danger),
                  DsBadge(label: 'Novo', tone: DsTone.primary),
                ]),
                const SizedBox(height: DsSpacing.s16),
                for (final DsTone tone in <DsTone>[
                  DsTone.info,
                  DsTone.success,
                  DsTone.warning,
                  DsTone.danger,
                ]) ...<Widget>[
                  DsAlert(
                    tone: tone,
                    title: switch (tone) {
                      DsTone.success => 'Importação concluída',
                      DsTone.warning => 'Integração instável',
                      DsTone.danger => 'Não foi possível salvar',
                      _ => 'Filtro de relatório aplicado',
                    },
                    message:
                        'Mensagem curta, com o que aconteceu e o próximo passo.',
                    onClose: () {},
                  ),
                  const SizedBox(height: DsSpacing.s8),
                ],
              ],
            ),
          ),
          const SizedBox(height: DsSpacing.s24),
          DsSectionCard(
            title: 'Feedback',
            child: row(<Widget>[
              for (final DsTone tone in <DsTone>[
                DsTone.neutral,
                DsTone.success,
                DsTone.warning,
                DsTone.danger,
              ])
                DsButton(
                  label: 'Toast ${tone.name}',
                  variant: DsButtonVariant.secondary,
                  onPressed: () =>
                      DsToast.show(context, 'Registro atualizado.', tone: tone),
                ),
              DsButton(
                label: 'Confirmação',
                variant: DsButtonVariant.secondary,
                onPressed: () => DsConfirmDialog.show(
                  context,
                  title: 'Excluir carnê?',
                  message: 'As parcelas em aberto serão canceladas.',
                  confirmLabel: 'Excluir',
                  destructive: true,
                ),
              ),
            ]),
          ),
          const SizedBox(height: DsSpacing.s24),
          DsSectionCard(
            title: 'Campos',
            child: DsFormGrid(
              columns: 3,
              children: <Widget>[
                const TextField(
                  decoration: InputDecoration(labelText: 'Padrão'),
                ),
                TextField(
                  controller: TextEditingController(text: 'Maria Souza'),
                  decoration: const InputDecoration(labelText: 'Preenchido'),
                ),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Com erro',
                    errorText: 'Informe um CPF válido.',
                  ),
                ),
                const TextField(
                  enabled: false,
                  decoration: InputDecoration(labelText: 'Desabilitado'),
                ),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Seleção'),
                  items: const <DropdownMenuItem<int>>[
                    DropdownMenuItem<int>(value: 1, child: Text('Opção 1')),
                    DropdownMenuItem<int>(value: 2, child: Text('Opção 2')),
                  ],
                  onChanged: (_) {},
                ),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Com ajuda',
                    helperText: 'Somente números.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DsSpacing.s24),
          DsSectionCard(
            title: 'Tipografia',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Display 32/40', style: text.headlineLarge),
                Text('H1 24/32', style: text.headlineMedium),
                Text('H2 20/28', style: text.headlineSmall),
                Text('H3 18/26', style: text.titleLarge),
                Text('H4 16/24', style: text.titleMedium),
                Text(
                  'Body 14/20 — texto padrão da interface',
                  style: text.bodyMedium,
                ),
                Text('Label 13/18', style: text.labelMedium),
                Text('Caption 12/16', style: text.bodySmall),
                Text(
                  'Table 13/20 — 1.234.567,89',
                  style: DsTypography.table.copyWith(color: c.textPrimary),
                ),
                Text('OVERLINE 11/16', style: text.labelSmall),
              ],
            ),
          ),
          const SizedBox(height: DsSpacing.s24),
          const DsSectionCard(
            title: 'Estados',
            padding: EdgeInsets.zero,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 240,
                    child: DsEmptyState(
                      title: 'Nenhum carnê ainda',
                      message: 'Crie o primeiro para começar a cobrar.',
                    ),
                  ),
                ),
                Expanded(child: SizedBox(height: 240, child: DsErrorState())),
                Expanded(child: SizedBox(height: 240, child: DsLoadingState())),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:platform_design_system/platform_design_system.dart';

class _Person {
  const _Person(this.name, this.cpf, this.city, this.active);

  final String name;
  final String cpf;
  final String city;
  final bool active;
}

/// Template: CRUD padrão. Header with the primary action, filters, table with
/// selection and bulk actions, pinned pagination.
class CrudListPage extends StatefulWidget {
  const CrudListPage({super.key});

  @override
  State<CrudListPage> createState() => _CrudListPageState();
}

class _CrudListPageState extends State<CrudListPage> {
  static final List<_Person> _all = List<_Person>.generate(249, (int i) {
    const List<String> names = <String>[
      'Ana Beatriz Souza',
      'Bruno Carvalho',
      'Carla Mendes',
      'Diego Fernandes',
      'Elaine Rocha',
      'Fábio Nogueira',
      'Gabriela Lima',
    ];
    const List<String> cities = <String>['Brasília', 'Goiânia', 'Anápolis'];
    final String n = (i + 1).toString().padLeft(3, '0');
    return _Person(
      names[i % names.length],
      '$n.482.19${i % 10}-0${i % 9}',
      cities[i % cities.length],
      i % 5 != 0,
    );
  });

  final Set<int> _selected = <int>{};
  String _query = '';
  String _status = 'todos';
  int _page = 1;
  int _pageSize = 20;
  bool _ascending = true;
  DsDataState _state = DsDataState.ready;

  List<_Person> get _filtered {
    final List<_Person> items = _all.where((_Person p) {
      final bool matchesQuery =
          _query.isEmpty || p.name.toLowerCase().contains(_query.toLowerCase());
      final bool matchesStatus =
          _status == 'todos' || (_status == 'ativos') == p.active;
      return matchesQuery && matchesStatus;
    }).toList();
    items.sort(
      (_Person a, _Person b) =>
          _ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
    );
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final List<_Person> filtered = _filtered;
    final int start = (_page - 1) * _pageSize;
    final List<_Person> pageItems = filtered
        .skip(start)
        .take(_pageSize)
        .toList();
    final DsDataState state = _state != DsDataState.ready
        ? _state
        : filtered.isEmpty
        ? DsDataState.empty
        : DsDataState.ready;
    final int activeFilters =
        (_query.isEmpty ? 0 : 1) + (_status == 'todos' ? 0 : 1);

    void clearFilters() => setState(() {
      _query = '';
      _status = 'todos';
      _page = 1;
    });

    return DsPage(
      scrollable: false,
      header: DsPageHeader(
        title: 'Pessoas',
        subtitle: '${_all.length} registros',
        breadcrumbs: const <DsBreadcrumbItem>[
          DsBreadcrumbItem('Início'),
          DsBreadcrumbItem('Cadastros'),
          DsBreadcrumbItem('Pessoas'),
        ],
        actions: <Widget>[
          DsButton(
            label: 'Exportar',
            icon: Icons.download_outlined,
            variant: DsButtonVariant.secondary,
            onPressed: () => DsToast.show(
              context,
              'Exportação iniciada. Avisaremos quando terminar.',
            ),
          ),
          DsButton(label: 'Nova pessoa', icon: Icons.add, onPressed: () {}),
        ],
      ),
      filters: DsFilterBar(
        activeCount: activeFilters,
        onClear: clearFilters,
        children: <Widget>[
          SizedBox(
            width: 320,
            child: TextField(
              key: ValueKey<int>(activeFilters == 0 ? 0 : 1),
              decoration: const InputDecoration(
                hintText: 'Buscar por nome',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (String value) => setState(() {
                _query = value;
                _page = 1;
              }),
            ),
          ),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              initialValue: _status,
              key: ValueKey<String>(_status),
              decoration: const InputDecoration(labelText: 'Status'),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'todos', child: Text('Todos')),
                DropdownMenuItem<String>(
                  value: 'ativos',
                  child: Text('Ativos'),
                ),
                DropdownMenuItem<String>(
                  value: 'inativos',
                  child: Text('Inativos'),
                ),
              ],
              onChanged: (String? value) => setState(() {
                _status = value ?? 'todos';
                _page = 1;
              }),
            ),
          ),
          SegmentedButton<DsDataState>(
            showSelectedIcon: false,
            segments: const <ButtonSegment<DsDataState>>[
              ButtonSegment<DsDataState>(
                value: DsDataState.ready,
                label: Text('Dados'),
              ),
              ButtonSegment<DsDataState>(
                value: DsDataState.loading,
                label: Text('Carregando'),
              ),
              ButtonSegment<DsDataState>(
                value: DsDataState.error,
                label: Text('Erro'),
              ),
            ],
            selected: <DsDataState>{_state},
            onSelectionChanged: (Set<DsDataState> value) =>
                setState(() => _state = value.first),
          ),
        ],
      ),
      child: DsDataTable(
        state: state,
        sortColumnIndex: 0,
        sortAscending: _ascending,
        selectedCount: _selected.length,
        onClearSelection: () => setState(_selected.clear),
        onSelectAll: (bool? all) => setState(() {
          for (int i = 0; i < pageItems.length; i++) {
            all == true
                ? _selected.add(start + i)
                : _selected.remove(start + i);
          }
        }),
        bulkActions: <Widget>[
          DsButton(
            label: 'Exportar seleção',
            size: DsButtonSize.sm,
            variant: DsButtonVariant.secondary,
            onPressed: () {},
          ),
          DsButton(
            label: 'Inativar',
            size: DsButtonSize.sm,
            variant: DsButtonVariant.danger,
            onPressed: () async {
              final bool ok = await DsConfirmDialog.show(
                context,
                title: 'Inativar ${_selected.length} pessoas?',
                message:
                    'Elas deixam de aparecer nas buscas. Você pode reativá-las depois.',
                confirmLabel: 'Inativar',
                destructive: true,
              );
              if (!context.mounted || !ok) return;
              DsToast.success(
                context,
                '${_selected.length} pessoas inativadas.',
              );
              setState(_selected.clear);
            },
          ),
        ],
        errorState: DsErrorState(
          onRetry: () => setState(() => _state = DsDataState.ready),
        ),
        emptyState: DsEmptyState(
          icon: Icons.search_off,
          title: 'Nenhuma pessoa encontrada',
          message: 'Ajuste a busca ou limpe os filtros.',
          action: DsButton(
            label: 'Limpar filtros',
            variant: DsButtonVariant.secondary,
            onPressed: clearFilters,
          ),
        ),
        columns: <DataColumn>[
          DataColumn(
            label: const Text('Nome'),
            onSort: (int _, bool ascending) =>
                setState(() => _ascending = ascending),
          ),
          const DataColumn(label: Text('CPF')),
          const DataColumn(label: Text('Cidade')),
          const DataColumn(label: Text('Status')),
          const DataColumn(label: Text('Ações')),
        ],
        rows: <DataRow>[
          for (int i = 0; i < pageItems.length; i++)
            DataRow(
              selected: _selected.contains(start + i),
              onSelectChanged: (bool? value) => setState(() {
                value == true
                    ? _selected.add(start + i)
                    : _selected.remove(start + i);
              }),
              cells: <DataCell>[
                DataCell(Text(pageItems[i].name)),
                DataCell(Text(pageItems[i].cpf)),
                DataCell(Text(pageItems[i].city)),
                DataCell(
                  pageItems[i].active
                      ? const DsBadge(label: 'Ativo', tone: DsTone.success)
                      : const DsBadge(label: 'Inativo'),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        tooltip: 'Editar ${pageItems[i].name}',
                        icon: const Icon(Icons.edit_outlined),
                        visualDensity: VisualDensity.compact,
                        onPressed: () {},
                      ),
                      IconButton(
                        tooltip: 'Mais ações',
                        icon: const Icon(Icons.more_horiz),
                        visualDensity: VisualDensity.compact,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
        pagination: DsPagination(
          page: _page,
          pageSize: _pageSize,
          totalItems: filtered.length,
          onPageChanged: (int page) => setState(() => _page = page),
          onPageSizeChanged: (int size) => setState(() {
            _pageSize = size;
            _page = 1;
          }),
        ),
      ),
    );
  }
}

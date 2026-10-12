import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:platform_design_system/platform_design_system.dart';

import 'templates/components_page.dart';
import 'templates/crud_list_page.dart';
import 'templates/dashboard_page.dart';
import 'templates/form_page.dart';

void main() => runApp(const GalleryApp());

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  ThemeMode _mode = Uri.base.queryParameters['theme'] == 'dark'
      ? ThemeMode.dark
      : ThemeMode.light;
  String _page = Uri.base.queryParameters['page'] ?? 'dashboard';

  static const List<DsNavSection> _sections = <DsNavSection>[
    DsNavSection(
      title: 'Templates',
      items: <DsNavItem>[
        DsNavItem(
          id: 'dashboard',
          label: 'Dashboard',
          icon: Icons.space_dashboard_outlined,
        ),
        DsNavItem(
          id: 'list',
          label: 'CRUD padrão',
          icon: Icons.table_rows_outlined,
        ),
        DsNavItem(
          id: 'form',
          label: 'Cadastro',
          icon: Icons.edit_note_outlined,
        ),
      ],
    ),
    DsNavSection(
      title: 'Referência',
      items: <DsNavItem>[
        DsNavItem(
          id: 'components',
          label: 'Componentes',
          icon: Icons.widgets_outlined,
        ),
        DsNavItem(
          id: 'docs',
          label: 'Documentação',
          icon: Icons.menu_book_outlined,
          opensInNewTab: true,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool dark = _mode == ThemeMode.dark;

    return MaterialApp(
      title: 'Design System',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const <Locale>[Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: DsTheme.light(),
      darkTheme: DsTheme.dark(),
      themeMode: _mode,
      home: DsAppShell(
        sections: _sections,
        selectedId: _page,
        embedded: Uri.base.queryParameters['embedded'] == 'true',
        onNavigate: (DsNavItem item) {
          if (item.id != 'docs') setState(() => _page = item.id);
        },
        brand: const Text('Plataforma'),
        topBarActions: <Widget>[
          IconButton(
            tooltip: dark ? 'Usar tema claro' : 'Usar tema escuro',
            icon: Icon(
              dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () =>
                setState(() => _mode = dark ? ThemeMode.light : ThemeMode.dark),
          ),
        ],
        body: switch (_page) {
          'list' => const CrudListPage(),
          'form' => FormPage(onDone: () => setState(() => _page = 'list')),
          'components' => const ComponentsPage(),
          _ => const DashboardPage(),
        },
      ),
    );
  }
}

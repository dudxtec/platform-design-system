import 'package:flutter/material.dart';

import '../tokens/ds_breakpoints.dart';
import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_density.dart';
import '../tokens/ds_foundations.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_typography.dart';

@immutable
class DsNavItem {
  const DsNavItem({
    required this.id,
    required this.label,
    required this.icon,
    this.opensInNewTab = false,
  });

  final String id;
  final String label;
  final IconData icon;

  /// Adds an "opens in new tab" affordance, so the behaviour is predictable.
  final bool opensInNewTab;
}

@immutable
class DsNavSection {
  const DsNavSection({this.title, required this.items});

  final String? title;
  final List<DsNavItem> items;
}

/// Application frame: top bar, sidebar and content.
///
/// Portals rendered inside the host (iframe) pass `embedded: true`; the shell
/// then renders only [body], so the chrome is never duplicated.
class DsAppShell extends StatefulWidget {
  const DsAppShell({
    super.key,
    required this.body,
    required this.sections,
    required this.onNavigate,
    this.selectedId,
    this.brand,
    this.topBarActions = const <Widget>[],
    this.sidebarFooter,
    this.embedded = false,
    this.sidebarCollapsed,
    this.onSidebarCollapsedChanged,
  });

  final Widget body;
  final List<DsNavSection> sections;
  final ValueChanged<DsNavItem> onNavigate;
  final String? selectedId;

  /// Logo or product name at the start of the top bar.
  final Widget? brand;

  /// Tenant selector, notifications, user menu. Rightmost is the user menu.
  final List<Widget> topBarActions;
  final Widget? sidebarFooter;
  final bool embedded;

  /// The stored preference of the user. When null the sidebar starts
  /// collapsed below `DsBreakpoints.wide` and expanded above it.
  final bool? sidebarCollapsed;

  /// Called when the user toggles the sidebar, so the portal can persist it.
  final ValueChanged<bool>? onSidebarCollapsedChanged;

  @override
  State<DsAppShell> createState() => _DsAppShellState();
}

class _DsAppShellState extends State<DsAppShell> {
  bool? _toggled;

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return widget.body;

    final DsColorTokens c = context.dsColors;
    final bool desktop = context.isDesktop;
    final bool collapsed =
        _toggled ??
        widget.sidebarCollapsed ??
        MediaQuery.sizeOf(context).width < DsBreakpoints.wide;

    Widget nav({required bool collapsed, VoidCallback? afterTap}) {
      return _DsSidebar(
        sections: widget.sections,
        selectedId: widget.selectedId,
        collapsed: collapsed,
        footer: widget.sidebarFooter,
        onNavigate: (DsNavItem item) {
          afterTap?.call();
          widget.onNavigate(item);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        // 48 px on phones whatever the density: a short screen is the scarce
        // resource there, and the touch targets inside the bar stay 44 px.
        toolbarHeight: context.isMobile
            ? DsDensity.compact.topBarHeight
            : DsDensity.of(context).topBarHeight,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              tooltip: desktop
                  ? (collapsed ? 'Expandir menu' : 'Recolher menu')
                  : 'Abrir menu',
              icon: const Icon(Icons.menu),
              onPressed: desktop
                  ? () {
                      setState(() => _toggled = !collapsed);
                      widget.onSidebarCollapsedChanged?.call(!collapsed);
                    }
                  : () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: widget.brand,
        actions: <Widget>[
          ...widget.topBarActions,
          const SizedBox(width: DsSpacing.s16),
        ],
      ),
      drawer: desktop
          ? null
          : Drawer(
              width: DsSizes.sidebarWidth + DsSpacing.s40,
              child: SafeArea(
                child: Builder(
                  builder: (BuildContext context) {
                    return nav(
                      collapsed: false,
                      afterTap: () => Navigator.of(context).pop(),
                    );
                  },
                ),
              ),
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (desktop)
            AnimatedContainer(
              duration: DsMotion.base,
              curve: DsMotion.standard,
              width: collapsed
                  ? DsSizes.sidebarCollapsedWidth
                  : DsSizes.sidebarWidth,
              decoration: BoxDecoration(
                color: c.surface,
                border: Border(right: BorderSide(color: c.border)),
              ),
              // Lay the content out at its final width so nothing overflows
              // while the container animates.
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  minWidth: collapsed
                      ? DsSizes.sidebarCollapsedWidth
                      : DsSizes.sidebarWidth,
                  maxWidth: collapsed
                      ? DsSizes.sidebarCollapsedWidth
                      : DsSizes.sidebarWidth,
                  child: nav(collapsed: collapsed),
                ),
              ),
            ),
          Expanded(child: widget.body),
        ],
      ),
    );
  }
}

class _DsSidebar extends StatelessWidget {
  const _DsSidebar({
    required this.sections,
    required this.selectedId,
    required this.collapsed,
    required this.onNavigate,
    this.footer,
  });

  final List<DsNavSection> sections;
  final String? selectedId;
  final bool collapsed;
  final ValueChanged<DsNavItem> onNavigate;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    return Semantics(
      container: true,
      label: 'Navegação principal',
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(DsSpacing.s12),
              children: <Widget>[
                for (final DsNavSection section in sections) ...<Widget>[
                  if (section.title != null && !collapsed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        DsSpacing.s12,
                        DsSpacing.s12,
                        DsSpacing.s12,
                        DsSpacing.s8,
                      ),
                      child: Text(
                        section.title!.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    )
                  else
                    const SizedBox(height: DsSpacing.s8),
                  for (final DsNavItem item in section.items)
                    _DsNavTile(
                      item: item,
                      selected: item.id == selectedId,
                      collapsed: collapsed,
                      onTap: () => onNavigate(item),
                    ),
                ],
              ],
            ),
          ),
          if (footer != null && !collapsed) ...<Widget>[
            Divider(color: c.border),
            Padding(
              padding: const EdgeInsets.all(DsSpacing.s12),
              child: footer,
            ),
          ],
        ],
      ),
    );
  }
}

class _DsNavTile extends StatelessWidget {
  const _DsNavTile({
    required this.item,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  final DsNavItem item;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    final Color foreground = selected ? c.primaryTone.text : c.textSecondary;

    final Widget tile = Padding(
      padding: const EdgeInsets.only(bottom: DsSpacing.s2),
      child: Material(
        color: selected ? c.surfaceSelected : Colors.transparent,
        borderRadius: BorderRadius.circular(DsRadius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DsRadius.sm),
          hoverColor: c.surfaceHover,
          child: SizedBox(
            height: DsSizes.navItemHeight,
            child: Row(
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: <Widget>[
                if (!collapsed) const SizedBox(width: DsSpacing.s12),
                Icon(item.icon, size: DsSizes.iconLg, color: foreground),
                if (!collapsed) ...<Widget>[
                  const SizedBox(width: DsSpacing.s12),
                  Expanded(
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      style: DsTypography.menu.copyWith(
                        color: selected ? c.primaryTone.text : c.textPrimary,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (item.opensInNewTab)
                    Padding(
                      padding: const EdgeInsets.only(right: DsSpacing.s12),
                      child: Icon(
                        Icons.open_in_new,
                        size: DsSizes.iconSm,
                        color: c.textTertiary,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    final String semanticLabel = item.opensInNewTab
        ? '${item.label}, abre em nova aba'
        : item.label;

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      onTap: onTap,
      excludeSemantics: true,
      child: collapsed ? Tooltip(message: item.label, child: tile) : tile,
    );
  }
}

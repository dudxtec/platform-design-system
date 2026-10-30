import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/ds_breakpoints.dart';
import '../tokens/ds_color_tokens.dart';
import '../tokens/ds_foundations.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_spacing.dart';

/// One action of a [DsActionFab].
@immutable
class DsFabAction {
  const DsFabAction({
    required this.label,
    required this.icon,
    this.onPressed,
    this.children = const <DsFabAction>[],
  });

  /// Verb + object: "Novo carnê", "Exportar".
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  /// Options of this action (for example Exportar: Excel, CSV, PDF).
  ///
  /// Above 600 px they open under the action, inside the same menu. On a
  /// phone, [onPressed] runs when set, so the caller can open its own sheet;
  /// otherwise a bottom sheet lists the children.
  final List<DsFabAction> children;
}

/// Floating button with the actions of a list or overview screen.
///
/// Wraps the content area and floats the button over its bottom end corner,
/// so the same widget behaves the same on web and on the app:
///
/// * no [actions]: no button (the content is returned as it is);
/// * one action: the button runs it directly;
/// * two or more: the button opens a menu and turns into a close icon. On a
///   phone the menu stacks above the button over a scrim, with the first
///   action closest to the thumb. Above 600 px it is a menu anchored above the
///   button, without scrim.
///
/// Esc and a tap outside close the menu and focus returns to the button. The
/// button hides while the keyboard is open and keeps clear of the system
/// gesture area. Give the scrollable content a bottom padding of
/// [listBottomInset] so the button never covers the last row.
class DsActionFab extends StatefulWidget {
  const DsActionFab({
    super.key,
    required this.actions,
    required this.child,
    this.endOffset = 0,
    this.hidden = false,
  });

  /// Diameter of the button.
  static const double size = 56;

  /// Bottom padding for the content behind the button: the button, its
  /// margins and some air.
  static const double listBottomInset = 104;

  final List<DsFabAction> actions;
  final Widget child;

  /// Moves the button towards the start, for example to stay left of a detail
  /// panel that is open on the same screen.
  final double endOffset;

  /// Hides the button without removing the content (a sheet is open, say).
  final bool hidden;

  @override
  State<DsActionFab> createState() => _DsActionFabState();
}

class _DsActionFabState extends State<DsActionFab> {
  final FocusNode _fabFocus = FocusNode(debugLabel: 'DsActionFab');
  bool _open = false;
  String? _expanded;

  @override
  void dispose() {
    _fabFocus.dispose();
    super.dispose();
  }

  void _close({bool restoreFocus = true}) {
    if (!_open) return;
    setState(() {
      _open = false;
      _expanded = null;
    });
    if (restoreFocus) _fabFocus.requestFocus();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      _expanded = null;
    });
  }

  void _runAndClose(VoidCallback? callback) {
    _close();
    callback?.call();
  }

  void _select(DsFabAction action, {required bool phone}) {
    if (phone) {
      if (action.onPressed != null) {
        _runAndClose(action.onPressed);
      } else if (action.children.isNotEmpty) {
        _close(restoreFocus: false);
        _showChildren(action);
      }
      return;
    }
    if (action.children.isNotEmpty) {
      setState(
        () => _expanded = _expanded == action.label ? null : action.label,
      );
      return;
    }
    _runAndClose(action.onPressed);
  }

  void _showChildren(DsFabAction action) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final DsFabAction child in action.children)
                ListTile(
                  leading: Icon(child.icon),
                  title: Text(child.label),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    child.onPressed?.call();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<DsFabAction> actions = widget.actions;
    if (actions.isEmpty) return widget.child;

    final DsColorTokens c = context.dsColors;
    final bool phone = MediaQuery.sizeOf(context).width < DsBreakpoints.mobile;
    final bool keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final bool visible = !widget.hidden && !keyboardOpen;
    final bool multi = actions.length > 1;
    final bool open = _open && multi && visible;
    final double margin = phone ? DsSpacing.s16 : DsSpacing.s24;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): _close,
      },
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: widget.child),
          if (open)
            Positioned.fill(
              child: Semantics(
                button: true,
                label: 'Fechar ações',
                onTap: _close,
                child: GestureDetector(
                  key: const ValueKey<String>('ds-action-fab-barrier'),
                  behavior: HitTestBehavior.opaque,
                  onTap: _close,
                  child: ColoredBox(
                    color: phone ? c.scrim : Colors.transparent,
                  ),
                ),
              ),
            ),
          if (visible)
            PositionedDirectional(
              end: margin + widget.endOffset,
              bottom: margin + MediaQuery.paddingOf(context).bottom,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (open) ...<Widget>[
                    if (phone)
                      _PhoneMenu(
                        actions: actions,
                        onSelect: (DsFabAction a) => _select(a, phone: true),
                      )
                    else
                      _WebMenu(
                        actions: actions,
                        expanded: _expanded,
                        onSelect: (DsFabAction a) => _select(a, phone: false),
                        onSelectChild: (DsFabAction a) =>
                            _runAndClose(a.onPressed),
                      ),
                    const SizedBox(height: DsSpacing.s12),
                  ],
                  _FabButton(
                    focusNode: _fabFocus,
                    label: multi ? 'Ações' : actions.first.label,
                    open: open,
                    expandable: multi,
                    onPressed: multi
                        ? _toggle
                        : () => actions.first.onPressed?.call(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FabButton extends StatelessWidget {
  const _FabButton({
    required this.focusNode,
    required this.label,
    required this.open,
    required this.expandable,
    required this.onPressed,
  });

  final FocusNode focusNode;
  final String label;
  final bool open;
  final bool expandable;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      expanded: expandable ? open : null,
      child: FloatingActionButton(
        focusNode: focusNode,
        heroTag: null,
        tooltip: label,
        backgroundColor: c.fab,
        foregroundColor: c.onFill,
        elevation: DsElevation.level2,
        focusElevation: DsElevation.level3,
        hoverElevation: DsElevation.level3,
        highlightElevation: DsElevation.level3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DsRadius.lg),
        ),
        onPressed: onPressed,
        child: AnimatedSwitcher(
          duration: reduceMotion ? Duration.zero : DsMotion.fast,
          child: Icon(
            open ? Icons.close : Icons.add,
            key: ValueKey<bool>(open),
            size: DsSizes.iconXl,
          ),
        ),
      ),
    );
  }
}

/// Phone: pills stacked above the button, the first action closest to it.
class _PhoneMenu extends StatelessWidget {
  const _PhoneMenu({required this.actions, required this.onSelect});

  final List<DsFabAction> actions;
  final ValueChanged<DsFabAction> onSelect;

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    final TextStyle? label = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: c.textPrimary);
    final List<DsFabAction> farthestFirst = actions.reversed.toList();

    return Semantics(
      role: SemanticsRole.menu,
      label: 'Ações',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < farthestFirst.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: DsSpacing.s8),
            Semantics(
              role: SemanticsRole.menuItem,
              child: Material(
                color: c.surface,
                elevation: DsElevation.level2,
                shadowColor: c.shadow,
                shape: StadiumBorder(side: BorderSide(color: c.border)),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  // The item nearest the button is the first action.
                  autofocus: i == farthestFirst.length - 1,
                  onTap: () => onSelect(farthestFirst[i]),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: DsSizes.touchTarget,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DsSpacing.s16,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(farthestFirst[i].label, style: label),
                          const SizedBox(width: DsSpacing.s12),
                          Icon(
                            farthestFirst[i].icon,
                            color: c.primary,
                            size: DsSizes.iconLg,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Above 600 px: a menu anchored above the button; actions with children
/// unfold inside it.
class _WebMenu extends StatelessWidget {
  const _WebMenu({
    required this.actions,
    required this.expanded,
    required this.onSelect,
    required this.onSelectChild,
  });

  final List<DsFabAction> actions;
  final String? expanded;
  final ValueChanged<DsFabAction> onSelect;
  final ValueChanged<DsFabAction> onSelectChild;

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;

    return Semantics(
      role: SemanticsRole.menu,
      label: 'Ações',
      child: Material(
        color: c.surface,
        elevation: DsElevation.level2,
        shadowColor: c.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DsRadius.sm),
          side: BorderSide(color: c.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 224, maxWidth: 320),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (int i = 0; i < actions.length; i++) ...<Widget>[
                  _MenuRow(
                    action: actions[i],
                    autofocus: i == 0,
                    expandable: actions[i].children.isNotEmpty,
                    expanded: expanded == actions[i].label,
                    onTap: () => onSelect(actions[i]),
                  ),
                  if (expanded == actions[i].label)
                    for (final DsFabAction child in actions[i].children)
                      _MenuRow(
                        action: child,
                        indent: true,
                        onTap: () => onSelectChild(child),
                      ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.action,
    required this.onTap,
    this.autofocus = false,
    this.expandable = false,
    this.expanded = false,
    this.indent = false,
  });

  final DsFabAction action;
  final VoidCallback onTap;
  final bool autofocus;
  final bool expandable;
  final bool expanded;
  final bool indent;

  @override
  Widget build(BuildContext context) {
    final DsColorTokens c = context.dsColors;
    final TextStyle? label = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: c.textPrimary);

    return Semantics(
      role: SemanticsRole.menuItem,
      expanded: expandable ? expanded : null,
      child: InkWell(
        autofocus: autofocus,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DsSizes.touchTarget),
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: indent ? DsSpacing.s40 : DsSpacing.s16,
              end: DsSpacing.s16,
            ),
            child: Row(
              children: <Widget>[
                if (!indent) ...<Widget>[
                  Icon(action.icon, color: c.primary, size: DsSizes.iconMd),
                  const SizedBox(width: DsSpacing.s12),
                ],
                Expanded(child: Text(action.label, style: label)),
                if (expandable)
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: c.textSecondary,
                    size: DsSizes.iconLg,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

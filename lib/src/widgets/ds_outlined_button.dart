import 'package:flutter/material.dart';

import 'ds_button.dart';

@Deprecated('Use DsButton(variant: DsButtonVariant.secondary).')
class DsOutlinedButton extends StatelessWidget {
  const DsOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DsButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      variant: DsButtonVariant.secondary,
    );
  }
}

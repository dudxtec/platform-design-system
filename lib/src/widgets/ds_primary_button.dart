import 'package:flutter/material.dart';

import 'ds_button.dart';

@Deprecated('Use DsButton(variant: DsButtonVariant.primary).')
class DsPrimaryButton extends StatelessWidget {
  const DsPrimaryButton({
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
    return DsButton(label: label, onPressed: onPressed, icon: icon);
  }
}

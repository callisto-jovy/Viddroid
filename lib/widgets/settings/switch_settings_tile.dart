import 'package:flutter/material.dart';

class SwitchSettingsTile extends StatelessWidget {
  final Function(bool value)? onToggle;
  final bool? toggled;

  final WidgetStateProperty<Icon?> thumbIcon = WidgetStateProperty.resolveWith<Icon?>(
    (Set<WidgetState> states) {
      // Thumb icon when the switch is selected.
      if (states.contains(WidgetState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  SwitchSettingsTile({super.key, this.onToggle, this.toggled});

  @override
  Widget build(BuildContext context) {
    return Switch(
      thumbIcon: thumbIcon,
      value: toggled ?? true,
      onChanged: onToggle,
    );
  }
}

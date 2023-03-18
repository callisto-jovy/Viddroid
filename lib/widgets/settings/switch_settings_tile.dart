import 'package:flutter/material.dart';

class SwitchSettingsTile extends StatelessWidget {
  final Function(bool value)? onToggle;
  final bool? initialValue;

  final MaterialStateProperty<Icon?> thumbIcon = MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      // Thumb icon when the switch is selected.
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  SwitchSettingsTile({super.key, this.onToggle, this.initialValue});

  @override
  Widget build(BuildContext context) {
    return Switch(
      thumbIcon: thumbIcon,
      value: initialValue ?? true,
      onChanged: onToggle,
    );
  }
}

import 'package:flutter/cupertino.dart';

class SwitchSettingsTile extends StatelessWidget {

  final Function(bool value)? onToggle;
  final bool? initialValue;

  const SwitchSettingsTile({super.key, this.onToggle, this.initialValue});

  @override
  Widget build(BuildContext context) {
    return  CupertinoSwitch(
      value: initialValue ?? true,
      onChanged: onToggle,
    );
  }
}
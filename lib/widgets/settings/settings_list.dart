import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/widgets/settings/settings_section.dart';

class SettingsList extends StatefulWidget {
  const SettingsList({
    required this.sections,
    this.physics,
    this.contentPadding,
    Key? key,
  }) : super(key: key);

  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? contentPadding;
  final List<SettingsSection> sections;

  @override
  State<SettingsList> createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
            physics: widget.physics,
            child: IntrinsicHeight(
              child: NavigationRail(
                labelType: NavigationRailLabelType.all,
                useIndicator: true,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                destinations: widget.sections
                    .map((e) => NavigationRailDestination(icon: e.icon, label: e.title))
                    .toList(),
              ),
            )),
        Expanded(child: widget.sections[_selectedIndex])
      ],
    );
  }
}

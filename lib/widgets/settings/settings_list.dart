import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/widgets/settings/settings_section.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({
    required this.sections,
    this.shrinkWrap = false,
    this.physics,
    this.brightness,
    this.contentPadding,
    Key? key,
  }) : super(key: key);

  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Brightness? brightness;
  final EdgeInsetsGeometry? contentPadding;
  final List<SettingsSection> sections;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: ListView.builder(
        physics: physics,
        shrinkWrap: shrinkWrap,
        itemCount: sections.length,
        padding: contentPadding ?? calculateDefaultPadding(context),
        itemBuilder: (BuildContext context, int index) {
          return sections[index];
        },
      ),
    );
  }

  EdgeInsets calculateDefaultPadding(BuildContext context) {
    if (MediaQuery.of(context).size.width > 810) {
      final double padding = (MediaQuery.of(context).size.width - 810) / 2;
      return EdgeInsets.symmetric(horizontal: padding);
    }
    return const EdgeInsets.symmetric(vertical: 0);
  }
}

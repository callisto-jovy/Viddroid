import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/widgets/settings/settings_tile.dart';

import '../widgets/settings/settings_list.dart';
import '../widgets/settings/settings_section.dart';
import '../widgets/snackbars.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    //TODO: Rewrite with own containers.
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: SettingsList(
          sections: [
            SettingsSection(
              title: const Text('Common'),
              tiles: [
                SettingsTile(
                    leading: const Icon(Icons.language_sharp),
                    title: const Text('Language'),
                    description: const Text('Choose the application\'s language'),
                    onPressed: (c) => ScaffoldMessenger.of(context).showSnackBar(infoSnackbar('This feature is not implemented yet')),
                    initialValue: false,
                    tileType: SettingsTileType.navigationTile,
                    enabled: true,)
              ],
              margin: const EdgeInsetsDirectional.all(20),
            )
          ],
        ));
  }
}

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
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: SettingsList(
          sections: [
            SettingsSection(
              title: const Text('Common'),
              icon: const Icon(Icons.settings),
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
            ),
            SettingsSection(
              title: const Text('Providers'),
              icon: const Icon(Icons.open_in_browser_outlined),
              tiles: [
                SettingsTile(
                  leading: const Icon(Icons.language_sharp),
                  title: const Text('Language'),
                  description: const Text('Choose the providers\'s language'),
                  onPressed: (c) => ScaffoldMessenger.of(context).showSnackBar(infoSnackbar('This feature is not implemented yet')),
                  initialValue: false,
                  tileType: SettingsTileType.navigationTile,
                  enabled: true,)
              ],
              margin: const EdgeInsetsDirectional.all(20),
            ),
            SettingsSection(
              title: const Text('Download'),
              icon: const Icon(Icons.download_for_offline_outlined),
              tiles: [
                SettingsTile(
                  leading: const Icon(Icons.speed),
                  title: const Text('Download delay'),
                  description: const Text('The delay to wait between downloads.'),
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

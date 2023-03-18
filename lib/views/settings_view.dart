import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/views/providers_view.dart';
import 'package:viddroid_flutter_desktop/widgets/settings/base_settings_tile.dart';

import '../util/setting/settings.dart';
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
                SimpleSettingsTile(
                  leading: const Icon(Icons.language_sharp),
                  title: const Text('Language'),
                  description: const Text('Choose the application\'s language.'),
                  onPressed: (c) => ScaffoldMessenger.of(context)
                      .showSnackBar(infoSnackbar('This feature is not implemented yet')),
                  tileType: SettingsTileType.navigationTile,
                ),
              ],
              margin: const EdgeInsetsDirectional.all(20),
            ),
            SettingsSection(
              title: const Text('Providers'),
              icon: const Icon(Icons.open_in_browser_outlined),
              tiles: [
                SimpleSettingsTile(
                  leading: const Icon(Icons.pageview_rounded),
                  title: const Text('Selected providers'),
                  description: const Text('Choose which providers should be searched.'),
                  tileType: SettingsTileType.navigationTile,
                  onPressed: (context) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProviderSelectionView(),
                      )),
                )
              ],
              margin: const EdgeInsetsDirectional.all(20),
            ),
            SettingsSection(
              title: const Text('Video player'),
              icon: const Icon(Icons.video_label),
              tiles: [
                SimpleSettingsTile(
                  leading: const Icon(Icons.fullscreen),
                  title: const Text('Fullscreen on play'),
                  description: const Text('Enable fullscreen mode when starting playback.'),
                  onPressed: null,
                  initialValue: Settings().get(Settings.changeFullscreen),
                  tileType: SettingsTileType.switchTile,
                  onToggle: (val) {
                    setState(() {
                      Settings().saveSetting(Settings.changeFullscreen, val);
                    });
                  },
                )
              ],
              margin: const EdgeInsetsDirectional.all(20),
            )
          ],
        ));
  }
}

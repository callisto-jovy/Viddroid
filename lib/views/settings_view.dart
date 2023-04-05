import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/constants.dart';
import 'package:viddroid_flutter_desktop/util/network/plugins/proxy_extension.dart';
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
                SimpleSettingsTile(
                  leading: const Icon(Icons.cloud),
                  title: const Text('Custom Proxy'),
                  description:
                      const Text('Set a custom proxy, which will be used for all requests.'),
                  tileType: SettingsTileType.inputTile,
                  initialValue: Settings().get(Settings.proxy),
                  formFieldHint: 'IP:port',
                  onSubmitted: (value) {
                    //TODO: Move away
                    final RegExp regex = RegExp(
                        r'(([1-9][0-9]{2}|[1-9][0-9]|[1-9])\.([1-9][0-9]|[1-9][0-9]{2}|[0-9]))\.([0-9]|[1-9][0-9]|[1-9][0-9]{2})\.([0-9]|[1-9][0-9]|[1-9][0-9]{2}):([1-9][0-9]{4}|[1-9][0-9]{3}|[1-9][0-9]{2}|[1-9][0-9]|[1-9])');

                    if (value != null && value.isNotEmpty) {
                      if (regex.hasMatch(value)) {
                        Settings().saveSetting(Settings.proxy, value);
                        dio.useProxy(value);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(successSnackbar('The proxy has been set successfully!'));
                      } else {
                        // Display error
                        ScaffoldMessenger.of(context).showSnackBar(errorSnackbar(
                            'The supplied proxy is not valid. If not already done, separate IP and port with a double colon.'));
                      }
                    } else {
                      Settings().saveSetting(Settings.proxy, value);
                      dio.useProxy(null);
                      // The proxy has been cleared.
                      ScaffoldMessenger.of(context).showSnackBar(
                          successSnackbar('The proxy has been cleared successfully!'));
                    }
                  },
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
                  toggled: Settings().get(Settings.changeFullscreen),
                  tileType: SettingsTileType.switchTile,
                  onToggle: (val) {
                    setState(() {
                      Settings().saveSetting(Settings.changeFullscreen, val);
                    });
                  },
                ),
                SimpleSettingsTile(
                  leading: const Icon(Icons.save),
                  title: const Text('Save previous player state'),
                  description: const Text('If enabled, the player\'s previous position will be saved. The next playback will start from that point on.'),
                  onPressed: null,
                  toggled: Settings().get(Settings.keepPlayback),
                  tileType: SettingsTileType.switchTile,
                  onToggle: (val) {
                    setState(() {
                      Settings().saveSetting(Settings.keepPlayback, val);
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

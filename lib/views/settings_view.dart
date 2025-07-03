import 'package:flutter/material.dart';
import 'package:viddroid/constants.dart';
import 'package:viddroid/util/extensions/string_extension.dart';
import 'package:viddroid/util/network/plugins/proxy_extension.dart';
import 'package:viddroid/views/providers_view.dart';
import 'package:viddroid/widgets/settings/base_settings_tile.dart';

import '../util/setting/settings.dart';
import '../widgets/settings/settings_list.dart';
import '../widgets/settings/settings_section.dart';
import '../widgets/snackbars.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

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
                    if (value != null && value.isNotEmpty) {
                      if (proxyRegex.hasMatch(value)) {
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
                  leading: const Icon(Icons.lightbulb),
                  title: const Text('Wakelock'),
                  description:
                      const Text("Keeps the device's display awake during video playback."),
                  onPressed: null,
                  toggled: Settings().get(Settings.wakelock),
                  tileType: SettingsTileType.switchTile,
                  onToggle: (val) {
                    setState(() {
                      Settings().saveSetting(Settings.wakelock, val);
                    });
                  },
                ),
                SimpleSettingsTile(
                  leading: const Icon(Icons.save),
                  title: const Text('Save previous player state'),
                  description: const Text(
                      "If enabled, the player's previous position will be saved. The next playback will start from that point on."),
                  onPressed: null,
                  toggled: Settings().get(Settings.keepPlayback),
                  tileType: SettingsTileType.switchTile,
                  onToggle: (val) {
                    setState(() {
                      Settings().saveSetting(Settings.keepPlayback, val);
                    });
                  },
                ),
                SimpleSettingsTile(
                  leading: const Icon(Icons.forward_30),
                  title: const Text('Skip speed'),
                  description:
                      const Text('How many seconds are skipped forward/backward (in seconds).'),
                  tileType: SettingsTileType.inputTile,
                  initialValue: Settings().get(Settings.seekSpeed).toString(),
                  formFieldHint: 'Seconds to skip',
                  onSubmitted: (value) {
                    if (value != null && value.isNotEmpty && value.isNumeric) {
                      Settings().saveSetting(Settings.seekSpeed, int.parse(value));
                    }
                  },
                )
              ],
              margin: const EdgeInsetsDirectional.all(20),
            )
          ],
        ));
  }
}

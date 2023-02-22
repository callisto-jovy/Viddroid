import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

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
          darkTheme: SettingsThemeData(
            settingsListBackground: Theme.of(context).colorScheme.surface,
            settingsSectionBackground:  Theme.of(context).colorScheme.secondaryContainer,
          ),
          sections: [
            SettingsSection(
              title: const Text('Common'),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  value: const Text('English'),
                ),
                SettingsTile.switchTile(
                  onToggle: (value) {},
                  initialValue: true,
                  leading: const Icon(Icons.format_paint),
                  title: const Text('Enable custom theme'),
                ),
                SettingsTile.switchTile(
                  onToggle: (value) {},
                  initialValue: true,
                  leading: const Icon(Icons.notifications),
                  title: const Text('Enable windows notification'),
                ),
              ],
            ),
            SettingsSection(
              title: const Text('Subtitles'),
              tiles:  <SettingsTile>[
                SettingsTile.navigation(
                  leading: const Icon(Icons.subtitles),
                  title: const Text('Default Language'),
                  value: const Text('English'),
                ),
              ],
            )
          ],
        ));
  }
}

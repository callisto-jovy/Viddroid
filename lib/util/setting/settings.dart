import 'package:localstore/localstore.dart';
import 'package:viddroid_flutter_desktop/provider/provider.dart';

import '../../provider/providers.dart';

class Settings {
  static final Settings _instance = Settings._ctor();

  Settings._ctor();

  factory Settings() {
    return _instance;
  }

  /// Keys for all the settings

  static const String settingsKey = 'settings';
  static const String selectedProviders = 'selected_providers';
  static const String changeFullscreen = 'windows_fullscreen';
  static const String proxy = 'custom_proxy';

  late CollectionRef collectionRef;

  /// Map of all the settings. This map is actually written to disk.
  Map<String, dynamic> settings = {
    selectedProviders: [],
    changeFullscreen: true,
  };

  /// Initializes all the values asynchronously
  Future<void> init() async {
    final Localstore db = Localstore.instance;
    collectionRef = db.collection('viddroid_settings');

    settings = await collectionRef.doc(settingsKey).get() ?? settings;
  }

  Future<dynamic> getFromDiskIfPossible(String key) =>
      collectionRef.doc(settingsKey).get().then((value) => value?[key] ?? settings[key]);

  dynamic get(String key) => settings[key];

  /// Updates the map and saves it to disk
  void saveSetting(String key, dynamic settingsValue) {
    settings[key] = settingsValue;
    _put(settingsKey, settings);
  }

  /// Writes the map to disk
  Future<void> _put(String key, dynamic value) {
    return collectionRef.doc(key).set(value);
  }

  /// Special case for all selected providers:

  Future<void> saveSelectedProviders(final List<SiteProvider> providers) async {
    saveSetting(selectedProviders, providers.map((e) => e.name).toList());
  }

  Future<List<SiteProvider>> getSelectedProviders() async {
    final List<dynamic> list = (await get(
          selectedProviders,
        )) ??
        Providers().siteProviders;

    if (list.isEmpty) {
      return List.empty();
    } else {
      return Providers().siteProviders.where((element) => list.contains(element.name)).toList();
    }
  }
}

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

  late CollectionRef collectionRef;

  Map<String, dynamic> settingsMap = {
    selectedProviders: [],
    changeFullscreen: true,
  };

  Future<void> init() async {
    final Localstore db = Localstore.instance;
    collectionRef = db.collection('viddroid_settings');

    settingsMap = await collectionRef.doc(settingsKey).get() ?? settingsMap;
  }

  Future<dynamic> get(String key) =>
      collectionRef.doc(settingsKey).get().then((value) => value?[key] ?? settingsMap[key]);

  Future<T> transformGet<T>(String key, dynamic type, {dynamic defaultValue}) async {
    final Map<String, dynamic>? json = await collectionRef.doc(settingsKey).get();
    if (json != null) {
      return type?.fromJson(json);
    } else {
      return defaultValue;
    }
  }

  Future<void> saveSetting(String key, dynamic settingsValue) async {
    settingsMap[key] = settingsValue;
    put(settingsKey, settingsMap);
  }

  Future<void> put(String key, dynamic value) {
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

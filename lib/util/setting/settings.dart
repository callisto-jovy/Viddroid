import 'package:hive_flutter/hive_flutter.dart';
import 'package:viddroid_flutter_desktop/provider/provider.dart';
import 'package:viddroid_flutter_desktop/provider/providers/aniflix.dart';
import 'package:viddroid_flutter_desktop/provider/providers/anime_pahe.dart';
import 'package:viddroid_flutter_desktop/provider/providers/dopebox.dart';
import 'package:viddroid_flutter_desktop/provider/providers/goku.dart';
import 'package:viddroid_flutter_desktop/provider/providers/hdtoday.dart';
import 'package:viddroid_flutter_desktop/provider/providers/movies.dart';
import 'package:viddroid_flutter_desktop/provider/providers/primewire.dart';
import 'package:viddroid_flutter_desktop/provider/providers/sflix.dart';
import 'package:viddroid_flutter_desktop/provider/providers/solarmovie.dart';
import 'package:viddroid_flutter_desktop/provider/providers/vidsrc.dart';
import 'package:viddroid_flutter_desktop/util/capsules/media.dart';

import '../../provider/providers.dart';

class Settings {
  static final Settings _instance = Settings._ctor();

  Settings._ctor();

  factory Settings() {
    return _instance;
  }

  late Box settingsBox;

  /// Keys for all the settings

  static const String selectedProviders = 'selected_providers';
  static const String changeFullscreen = 'windows_fullscreen';

  Future<void> init() async {
    // My fucking god.
    Hive.registerAdapter(Movies123Adapter());
    Hive.registerAdapter(AniflixAdapter());
    Hive.registerAdapter(AnimePaheAdapter());
    Hive.registerAdapter(DopeBoxAdapter());
    Hive.registerAdapter(GokuAdapter());
    Hive.registerAdapter(HdTodayAdapter());
    Hive.registerAdapter(SflixAdapter());
    Hive.registerAdapter(PrimeWireAdapter());
    Hive.registerAdapter(SolarMovieAdapter());
    Hive.registerAdapter(VidSrcAdapter());
    Hive.registerAdapter(TvTypeAdapter());

    settingsBox = await Hive.openBox('viddroid_settings');
  }

  dynamic get(String key, {dynamic defaultValue}) =>
      settingsBox.get(key, defaultValue: defaultValue);

  Future<void> put(String key, dynamic value) => settingsBox.put(key, value);

  /// Special case for all selected providers:

  List<SiteProvider> get getSelectedProviders {
    print(get(selectedProviders));
    return get(selectedProviders, defaultValue: Providers().siteProviders) as List<SiteProvider>;
  }
}

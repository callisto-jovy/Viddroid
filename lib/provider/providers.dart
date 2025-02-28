import 'package:dio/dio.dart';
import 'package:viddroid/constants.dart';
import 'package:viddroid/provider/provider.dart';
import 'package:viddroid/provider/providers/allmoviesforyou.dart';
import 'package:viddroid/provider/providers/anime_pahe.dart';
import 'package:viddroid/provider/providers/dopebox.dart';
import 'package:viddroid/provider/providers/goku.dart';
import 'package:viddroid/provider/providers/hdtoday.dart';
import 'package:viddroid/provider/providers/movies.dart';
import 'package:viddroid/provider/providers/primewire.dart';
import 'package:viddroid/provider/providers/sflix.dart';
import 'package:viddroid/provider/providers/solarmovie.dart';
import 'package:viddroid/provider/providers/vidsrc.dart';
import 'package:viddroid/util/capsules/fetch.dart';
import 'package:viddroid/util/capsules/search.dart';

import '../util/capsules/link.dart';
import '../util/capsules/media.dart';
import '../util/setting/settings.dart';

class Providers {
  static final Providers _instance = Providers.inst();

  factory Providers() {
    return _instance;
  }

  Providers.inst();

  final List<SiteProvider> siteProviders = [
    Movies123(),
    Sflix(),
    VidSrc(),
    AllMoviesForYou(),
    AnimePahe(),
    DopeBox(),
    HdToday(),
    PrimeWire(),
    Goku(),
    SolarMovie(),
  ];

  Future<List<SiteProvider>> providers() async => await Settings().getSelectedProviders();

  SiteProvider provider(final String apiName) {
    return siteProviders.where((element) => element.name == apiName).first;
  }

  Stream<List<SearchResponse>> search(final String query, final List<TvType> searchTypes) async* {
    final List<SiteProvider> pvds = await providers();
    for (final SiteProvider provider in pvds) {
      if (searchTypes.any((element) => provider.types.contains(element))) {
        try {
          final List<SearchResponse> searchResponses = await provider.search(query);
          yield searchResponses;
        } catch (e, trace) {
          if (e is DioException) {
            logger.e('Error while searching the url: ${e.response?.realUri}.');
          }
          logger.e('An error occurred while searching one of the providers.', error: e, stackTrace: trace);
        }
      }
    }
  }

  Future<FetchResponse> fetch(final SearchResponse searchResponse) async {
    return siteProviders.firstWhere((element) => element.name == searchResponse.apiName).fetch(searchResponse);
  }

  Stream<LinkResponse> load(final LoadRequest loadRequest) async* {
    await for (LinkResponse lr in siteProviders.firstWhere((element) => element.name == loadRequest.apiName).load(loadRequest)) {
      yield lr;
    }
  }
}

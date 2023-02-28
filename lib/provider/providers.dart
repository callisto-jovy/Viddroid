import 'package:dio/dio.dart';
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
import 'package:viddroid_flutter_desktop/util/capsules/fetch.dart';
import 'package:viddroid_flutter_desktop/util/capsules/search.dart';

import '../util/capsules/link.dart';
import '../util/capsules/media.dart';

class Providers {
  static final Providers _instance = Providers.inst();

  factory Providers() {
    return _instance;
  }

  Providers.inst();

  final List<SiteProvider> siteProviders = [
    Movies_123(),
    Sflix(),
    VidSrc(),
    Aniflix(),
    AnimePahe(),
    DopeBox(),
    HdToday(),
    PrimeWire(),
    Goku(),
    SolarMovie(),
  ];

  SiteProvider provider(final String apiName) {
    return siteProviders.where((element) => element.name == apiName).first;
  }

  Stream<List<SearchResponse>> search(final String query, final List<TvType> searchTypes) async* {
    for (final SiteProvider provider in siteProviders) {
      if (searchTypes.any((element) => provider.types.contains(element))) {
        try {
          final List<SearchResponse> searchResponses = await provider.search(query);
          print(provider);
          if(provider is Goku) {
            print(searchResponses);
          }
          yield searchResponses;
        } catch (e, trace) {
          if (e is DioError) {
            print(e.response?.realUri);
          }
          print(trace);
        }
      }
    }
  }

  Future<FetchResponse> fetch(final SearchResponse searchResponse) async {
    return siteProviders
        .firstWhere((element) => element.name == searchResponse.apiName)
        .fetch(searchResponse);
  }

  Stream<LinkResponse> load(final LoadRequest loadRequest) async* {
    await for (LinkResponse lr in siteProviders
        .firstWhere((element) => element.name == loadRequest.apiName)
        .load(loadRequest)) {
      yield lr;
    }
  }
}

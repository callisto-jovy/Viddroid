import 'package:viddroid_flutter_desktop/provider/provider.dart';
import 'package:viddroid_flutter_desktop/provider/providers/movies_co.dart';
import 'package:viddroid_flutter_desktop/provider/providers/sflix_to.dart';
import 'package:viddroid_flutter_desktop/provider/providers/vid_src_me.dart';
import 'package:viddroid_flutter_desktop/util/fetch.dart';
import 'package:viddroid_flutter_desktop/util/search.dart';

import '../util/link.dart';
import '../util/media.dart';

class Providers {
  static final Providers _instance = Providers.inst();

  factory Providers() {
    return _instance;
  }

  Providers.inst();

  final List<SiteProvider> siteProviders = [
    MoviesCo(),
    SflixTo(),
    VidSrcMe(),
  ];

  Stream<List<SearchResponse>> search(final String query, final List<TvType> searchTypes) async* {
    for (final SiteProvider provider in siteProviders) {
      if (searchTypes.every((element) => provider.types.contains(element))) {
        final List<SearchResponse> response = await provider.search(query);
        yield response;
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

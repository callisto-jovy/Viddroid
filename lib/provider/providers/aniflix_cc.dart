import 'dart:convert';

import 'package:http/http.dart';
import 'package:requests/requests.dart';
import 'package:viddroid_flutter_desktop/constants.dart';
import 'package:viddroid_flutter_desktop/extractor/extractor.dart';
import 'package:viddroid_flutter_desktop/extractor/extractors.dart';
import 'package:viddroid_flutter_desktop/provider/provider.dart';
import 'package:viddroid_flutter_desktop/util/capsules/fetch.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';
import 'package:viddroid_flutter_desktop/util/capsules/media.dart';
import 'package:viddroid_flutter_desktop/util/capsules/search.dart';
import 'package:viddroid_flutter_desktop/util/extensions/string_extension.dart';
import 'package:viddroid_flutter_desktop/watchable/episode.dart';

class AniflixCC extends SiteProvider {
  AniflixCC() : super('Aniflix', 'https://www.aniflix.cc/', [TvType.anime], 'de');

  @override
  Future<List<SearchResponse>> search(String query) async {
    //https://www.aniflix.cc/api/show/search (API)
    //Post api with param search = query

    final Response response = await simplePost('https://www.aniflix.cc/api/show/search', {
      'search': query,
    });
    response.raiseForStatus();
    final dynamic jsonList = jsonDecode(response.body);
    final List<SearchResponse> list = [];

    for (dynamic jsonObject in jsonList) {
      final String title = jsonObject['name'] ?? 'N/A';
      final String id = jsonObject['url'];
      final String? thumbnailRelative = jsonObject['cover_landscape'];
      //Description available

      final String thumbnail = 'https://www.aniflix.cc/storage/$thumbnailRelative';
      final bool isMovie = title.contains('(Movie)');

      if (isMovie) {
        list.add(MovieSearchResponse(title, id, name, thumbnail: thumbnail));
      } else {
        list.add(TvSearchResponse(title, id, name, thumbnail: thumbnail));
      }
    }

    return list;
  }

  @override
  Future<FetchResponse> fetch(final SearchResponse searchResponse) async {
    //https://www.aniflix.cc/api/show/made-in-abyss (API)
    final String url = 'https://www.aniflix.cc/api/show/${searchResponse.url}';
    final Response response = await simpleGet(url);

    response.raiseForStatus();

    final dynamic jsonObject = jsonDecode(response.body);

    final String title = jsonObject['name'] ?? 'N/A';
    final String? thumbnailRelative = jsonObject['cover_landscape'];
    //Description available
    final String thumbnail = 'https://www.aniflix.cc/storage/$thumbnailRelative';

    //There are only tv-shows with aniflix...
    final List<Episode> episodes = [];
    final dynamic seasonsList = jsonObject['seasons'];

    for (int j = 0; j < seasonsList.length; j++) {
      final dynamic seasonObject = seasonsList[j];
      final dynamic episodeList = seasonObject['episodes'];

      for (int i = 0; i < episodeList.length; i++) {
        final dynamic episodeObject = episodeList[i];
        final String name = episodeObject['name'] ?? 'N/A';

        //Episode data
        episodes.add(Episode(name, i, j, '', searchResponse.url));
      }
    }
    return TvFetchResponse(title, url, name, TvType.tv, searchResponse.url,
        episodes: episodes, seasons: seasonsList.length, backgroundImage: thumbnail);
  }

  @override
  Stream<LinkResponse> load(LoadRequest loadRequest) async* {
    //https://www.aniflix.cc/api/episode/show/made-in-abyss/season/0/episode/1
    if (loadRequest is TvLoadRequest) {
      //TODO: episodes at relative position
      final String url =
          'https://www.aniflix.cc/api/episode/show/${loadRequest.data}/season/${loadRequest.season}/episode/${loadRequest.episode + 1}';

      final Response response = await simpleGet(url);
      response.raiseForStatus();
      final dynamic streamList = jsonDecode(response.body)['streams'];

      for(final dynamic streamObject in streamList) {
        final String? streamUrl = streamObject['link'];
        if(streamUrl == null) {
          continue;
        }
        final Extractor? extractor = Extractors().findExtractor(streamUrl.extractMainUrl);
        if(extractor == null) {
          continue;
        }

        yield* extractor.extract(streamUrl);
      }
    }
  }
}

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:viddroid_flutter_desktop/constants.dart';
import 'package:viddroid_flutter_desktop/extractor/extractor.dart';
import 'package:viddroid_flutter_desktop/extractor/extractors.dart';
import 'package:viddroid_flutter_desktop/provider/provider.dart';
import 'package:viddroid_flutter_desktop/util/capsules/fetch.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';
import 'package:viddroid_flutter_desktop/util/capsules/media.dart';
import 'package:viddroid_flutter_desktop/util/capsules/search.dart';
import 'package:viddroid_flutter_desktop/util/extensions/string_extension.dart';

part 'aniflix.g.dart';

@HiveType(typeId: 4)
class Aniflix extends SiteProvider {
  Aniflix() : super('Aniflix', 'https://www.aniflix.cc/', [TvType.anime], 'de');

  @override
  Future<List<SearchResponse>> search(String query) async {
    //https://www.aniflix.cc/api/show/search (API)
    //Post api with param search = query

    final Response response = await simplePost('https://www.aniflix.cc/api/show/search',
        jsonEncode({'search': query}), //Dio does not add quotation marks
        headers: {
          'content-type': 'application/json;charset=utf-8',
        });

    final dynamic jsonList = response.data;
    final List<SearchResponse> list = [];

    for (dynamic jsonObject in jsonList) {
      final String title = jsonObject['name'] ?? 'N/A';
      final String id = jsonObject['url'];
      final String? thumbnailRelative = jsonObject['cover_portrait'];
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
    final dynamic jsonObject = response.data;

    final String title = jsonObject['name'] ?? 'N/A';
    final String? description = jsonObject['description'];

    final String? backgroundRelative = jsonObject['cover_landscape'];
    final String background = 'https://www.aniflix.cc/storage/$backgroundRelative';
    final String? thumbnailRelative = jsonObject['cover_portrait'];
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
        episodes: episodes,
        seasons: seasonsList.length,
        backgroundImage: background,
        thumbnail: thumbnail,
        description: description);
  }

  @override
  Stream<LinkResponse> load(LoadRequest loadRequest) async* {
    //https://www.aniflix.cc/api/episode/show/made-in-abyss/season/0/episode/1
    if (loadRequest is TvLoadRequest) {
      final String url =
          'https://www.aniflix.cc/api/episode/show/${loadRequest.data}/season/${loadRequest.season + 1}/episode/${loadRequest.episode + 1}';

      final Response response = await simpleGet(url);

      final dynamic streamList = response.data['streams'];

      for (final dynamic streamObject in streamList) {
        final String? streamUrl = streamObject['link'];
        if (streamUrl == null) {
          continue;
        }
        final Extractor? extractor = Extractors().findExtractor(streamUrl.extractMainUrl);
        if (extractor == null) {
          continue;
        }
        yield* extractor.extract(streamUrl, headers: {'referer': mainUrl});
      }
    }
  }
}

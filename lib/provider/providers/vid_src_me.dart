import 'package:viddroid_flutter_desktop/extractor/extractors/vid_src_extractor.dart';
import 'package:viddroid_flutter_desktop/provider/provider.dart';
import 'package:viddroid_flutter_desktop/util/iterable_extension.dart';
import 'package:viddroid_flutter_desktop/util/link.dart';
import 'package:viddroid_flutter_desktop/util/media.dart';
import 'package:viddroid_flutter_desktop/util/search.dart';
import 'package:viddroid_flutter_desktop/watchable/episode.dart';

import '../../themoviedb/the_movie_db.dart';
import '../../util/fetch.dart';

class VidSrcMe extends SiteProvider {
  VidSrcMe() : super("VidSrcMe", "https://v2.vidsrc.me", [TvType.tv, TvType.movie], 'en');

  @override
  Future<List<SearchResponse>> search(String query) async {
    //Search with themoviedb, as vidsrc is an api which only takes in imdb ids.
    final List<SearchResponse> responses = await TheMovieDbApi().search(query);

    for (var element in responses) {
      element.url = "$mainUrl/embed/${element.url}";
      element.apiName = name;
    }

    return responses;
  }

  @override
  Future<FetchResponse> fetch(SearchResponse searchResponse) async {
    if (searchResponse.type == TvType.movie) {
      return MovieFetchResponse(searchResponse.title, searchResponse.url, searchResponse.apiName,
          TvType.movie, searchResponse.id.toString(),
          thumbnail: searchResponse.thumbnail, backgroundImage: searchResponse.thumbnail);
    } else {
      final List<Episode> episodes =
          await TheMovieDbApi().getEpisodes(searchResponse.id.toString());

      return TvFetchResponse(searchResponse.title, searchResponse.url, searchResponse.apiName,
          TvType.tv, searchResponse.id.toString(),
          thumbnail: searchResponse.thumbnail,
          backgroundImage: searchResponse.thumbnail,
          episodes: episodes,
          seasons: episodes
              .unique(
                (element) => element.season,
              )
              .length);
    }
  }

  @override
  Stream<LinkResponse> load(LoadRequest loadRequest) async* {
    //TODO: Extractor classes
    //https://vidsrc.me/embed/tt0944947/2-3/
    if (loadRequest is TvLoadRequest) {
      yield* VidSrcExtractor().extract(
          '$mainUrl/embed/${loadRequest.data}/${loadRequest.season}-${loadRequest.episode}',
          headers: loadRequest.headers);
    } else if (loadRequest is MovieLoadRequest) {
      yield* VidSrcExtractor()
          .extract('$mainUrl/embed/${loadRequest.data}/', headers: loadRequest.headers);
    }
  }
}

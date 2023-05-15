import 'package:viddroid/extractor/extractors/vid_src_extractor.dart';
import 'package:viddroid/provider/provider.dart';
import 'package:viddroid/util/capsules/link.dart';
import 'package:viddroid/util/capsules/media.dart';
import 'package:viddroid/util/capsules/search.dart';
import 'package:viddroid/util/extensions/iterable_extension.dart';

import '../../util/capsules/fetch.dart';
import '../../util/movie_provider/the_movie_db.dart';

class VidSrc extends SiteProvider {
  VidSrc() : super('VidSrcMe', 'https://v2.vidsrc.me', [TvType.tv, TvType.movie], 'en');

  @override
  Future<List<SearchResponse>> search(String query) async {
    //Search with themoviedb, as vidsrc is an api which only takes in imdb ids.
    final List<SearchResponse> responses = await TheMovieDbApi().search(query);

    for (var element in responses) {
      element.url = '$mainUrl/embed/${element.url}';
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
    //https://vidsrc.me/embed/tt0944947/2-3/
    if (loadRequest is TvLoadRequest) {
      //TODO: Handle special cases
      yield* VidSrcExtractor().extract(
          '$mainUrl/embed/${loadRequest.data}/${loadRequest.season + 1}-${loadRequest.episode + 1}',
          headers: loadRequest.headers);
    } else if (loadRequest is MovieLoadRequest) {
      yield* VidSrcExtractor()
          .extract('$mainUrl/embed/${loadRequest.data}/', headers: loadRequest.headers);
    }
  }
}

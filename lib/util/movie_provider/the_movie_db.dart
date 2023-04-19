import 'package:dio/dio.dart';
import 'package:viddroid/constants.dart';

import '../../api.dart';
import '../capsules/fetch.dart';
import '../capsules/search.dart';

class TheMovieDBAPIEndpoints {
  final String endpoint;

  const TheMovieDBAPIEndpoints._internal(this.endpoint);

  @override
  String toString() => 'TheMovieDBApi-Endpoint $endpoint';

  String getEndpoint() => endpoint;

  static const searchMovie = TheMovieDBAPIEndpoints._internal('/search/movie');
  static const searchTV = TheMovieDBAPIEndpoints._internal('/search/tv');
  static const tvDetails = TheMovieDBAPIEndpoints._internal('/tv');
  static const movieDetails = TheMovieDBAPIEndpoints._internal('/movie');
  static const searchMulti = TheMovieDBAPIEndpoints._internal('/search/multi');
}

class TheMovieDBAPIImageWidth {
  final String dimensions;

  const TheMovieDBAPIImageWidth._internal(this.dimensions);

  @override
  String toString() => 'Image Dimension $dimensions';

  String getDimension() => dimensions;

  static const width300 = TheMovieDBAPIImageWidth._internal('w300');
  static const originalSize = TheMovieDBAPIImageWidth._internal('original');
  static const width500 = TheMovieDBAPIImageWidth._internal('w500');
}

const String apiv3Endpoint = 'https://api.themoviedb.org/3';

String formatEndpointSearchRequest(TheMovieDBAPIEndpoints dbapiEndpoint, String query) =>
    '$apiv3Endpoint${dbapiEndpoint.getEndpoint()}?api_key=$apiKey&page=1&query=${Uri.encodeFull(query)}';

String formatRequest(TheMovieDBAPIEndpoints dbapiEndpoint, String query,
        {String appendToResponse = '', List<String> appends = const <String>[]}) =>
    '$apiv3Endpoint${dbapiEndpoint.getEndpoint()}/$query?api_key=$apiKey&append_to_response=${appendToResponse + appends.join(',')}';

String formatPosterPath(TheMovieDBAPIImageWidth imageWidth, final String posterPath) =>
    'https://image.tmdb.org/t/p/${imageWidth.getDimension()}$posterPath';

String formatSeasonsApi(final String tvId, final int seasonIndex) =>
    '$apiv3Endpoint/tv/$tvId/season/$seasonIndex?api_key=$apiKey';

class TheMovieDbApi {
  static final TheMovieDbApi _instance = TheMovieDbApi.ctor();

  TheMovieDbApi.ctor();

  factory TheMovieDbApi() => _instance;

  Future<List<SearchResponse>> search(final String query) async {
    if (query.isEmpty) return List.empty();

    final List<SearchResponse> responses = [];

    final dynamic results = await simpleGet(
      formatEndpointSearchRequest(TheMovieDBAPIEndpoints.searchMulti, query),
    ).then((value) => value.data['results']);
    //Look up the results

    for (dynamic result in results) {
      final String mediaType = result['media_type'];
      final int? id = result['id'];
      //Skip entry
      if (id == null || result['media_type'] == 'person') {
        continue;
      }

      //Ping the different apis based on the media-type
      final String requestUrl = formatRequest(
          mediaType == 'tv'
              ? TheMovieDBAPIEndpoints.tvDetails
              : TheMovieDBAPIEndpoints.movieDetails,
          id.toString());

      final dynamic detailedResult = await simpleGet(requestUrl).then((value) => value.data);

      final String? thumbnail = detailedResult['poster_path'] != null
          ? formatPosterPath(TheMovieDBAPIImageWidth.originalSize, detailedResult['poster_path']!)
          : null;

      if (mediaType == 'tv') {
        responses.add(TvSearchResponse(
          detailedResult['name'] ?? 'N/A',
          '',
          '',
          id: id,
          thumbnail: thumbnail,
        ));
      } else {
        responses.add(MovieSearchResponse(
          detailedResult['title'] ?? 'N/A',
          '',
          '',
          id: id,
          thumbnail: thumbnail,
        ));
      }
    }
    return responses;
  }

  Future<List<Episode>> getEpisodes(final String id) async {
    final String requestUrl = formatRequest(TheMovieDBAPIEndpoints.tvDetails, id);

    final Response response = await simpleGet(requestUrl);
    final dynamic seasonsArray = response.data['seasons'];
    final List<Episode> episodes = [];

    for (int i = 0; i < seasonsArray.length; i++) {
      //Because tmdb does not send back episodes in one request, we have to ping the api again...
      final dynamic response = await simpleGet(formatSeasonsApi(id, i)).then((value) => value.data);
      final dynamic episodesArray = response['episodes'];

      final int? responseNumber = response['season_number'];

      if (responseNumber != null && responseNumber == 0) {
        //Skip extras (TODO: Add a special case for extras - find websites where they are supported)
        continue;
      }

      for (int j = 0; j < episodesArray.length; j++) {
        final dynamic episode = episodesArray[j];

        final int? episodeId = episode['id'];
        if (episodeId == null) {
          continue;
        }

        episodes.add(Episode(
            episode['name'] ?? 'N/A',
            j,
            (i != 0 ? i - 1 : i),
            episode['still_path'] != null
                ? formatPosterPath(TheMovieDBAPIImageWidth.originalSize, episode['still_path'])
                : null,
            id));
      }
    }

    return episodes;
  }
}

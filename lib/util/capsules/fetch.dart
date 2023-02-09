import 'package:viddroid_flutter_desktop/util/capsules/link.dart';

import '../../watchable/episode.dart';
import 'media.dart';

abstract class FetchResponse {
//TODO: More data to flush out the ui

  final String title;
  final String url;
  final String apiName;
  final String data;
  final TvType type;
  final String? thumbnail;
  final String? year;
  final String? duration;
  final String? backgroundImage;

  final Map<String, String>? thumbnailHeaders;

  const FetchResponse(this.title, this.url, this.apiName, this.type, this.data,
      {this.year, this.thumbnail, this.duration, this.thumbnailHeaders, this.backgroundImage});

  @override
  String toString() {
    return 'FetchResponse{title: $title, url: $url, apiName: $apiName, data: $data, type: $type, thumbnail: $thumbnail, year: $year, duration: $duration, backgroundImage: $backgroundImage, thumbnailHeaders: $thumbnailHeaders}';
  }
}

class MovieFetchResponse extends FetchResponse {
  MovieFetchResponse(super.title, super.url, super.apiName, super.type, super.data,
      {super.year, super.thumbnail, super.duration, super.thumbnailHeaders, super.backgroundImage});

  LoadRequest toLoadRequest() {
    return LoadRequest(data, type, apiName);
  }
}

class TvFetchResponse extends FetchResponse {
  final List<Episode> episodes;
  final int seasons;

  TvFetchResponse(super.title, super.url, super.apiName, super.type, super.data,
      {required this.episodes,
      required this.seasons,
      super.year,
      super.thumbnail,
      super.duration,
      super.thumbnailHeaders,
      super.backgroundImage});

  LoadRequest toLoadRequest(final int season, final int episode) {
    return TvLoadRequest(data, type, apiName, episode: episode, season: season);
  }
}

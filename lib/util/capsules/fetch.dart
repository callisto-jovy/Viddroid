import 'package:viddroid/util/capsules/link.dart';

import 'media.dart';

abstract class FetchResponse {
  final String title;
  final String url;
  final String apiName;
  final String data;
  final TvType type;
  final String? thumbnail;
  final String? year;
  final String? duration;
  final String? description;

  final String? backgroundImage;

  final Map<String, String>? thumbnailHeaders;

  const FetchResponse(this.title, this.url, this.apiName, this.type, this.data,
      {this.year,
      this.thumbnail,
      this.duration,
      this.thumbnailHeaders,
      this.backgroundImage,
      this.description});

  @override
  String toString() {
    return 'FetchResponse{title: $title, url: $url, apiName: $apiName, data: $data, type: $type, thumbnail: $thumbnail, year: $year, duration: $duration, description: $description, backgroundImage: $backgroundImage, thumbnailHeaders: $thumbnailHeaders}';
  }
}

class MovieFetchResponse extends FetchResponse {
  MovieFetchResponse(super.title, super.url, super.apiName, super.type, super.data,
      {super.year,
      super.thumbnail,
      super.duration,
      super.thumbnailHeaders,
      super.backgroundImage,
      super.description});

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
      super.backgroundImage,
      super.description});

  LoadRequest toLoadRequest(final int season, final int episode) {
    return TvLoadRequest(data, type, apiName, episode: episode, season: season);
  }
}

class Episode {
  final String _name;
  final int _index;
  final int _season;
  final String? _thumbnail;
  final String data;

  Episode(this._name, this._index, this._season, this._thumbnail, this.data);

  String? get thumbnail => _thumbnail;

  int get season => _season;

  int get index => _index;

  String get name => _name;

  @override
  String toString() {
    return 'Episode{_name: $_name, _index: $_index, _season: $_season, _thumbnail: $_thumbnail}';
  }

  String? getSeasonPosterPath() => thumbnail!;

  LoadRequest toLoadRequest() {
    return TvLoadRequest(data, TvType.tv, name, episode: index, season: season);
  }
}

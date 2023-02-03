import 'package:viddroid_flutter_desktop/util/media.dart';

class LinkResponse {
  final String? title;
  final String url;
  final String referer;
  final String source;
  final MediaQuality mediaQuality;
  final Map<String, String>? header;

  LinkResponse(this.url, this.referer, this.source, this.mediaQuality, {this.title, this.header});

  @override
  String toString() {
    return 'LinkResponse{title: $title, url: $url, referer: $referer, source: $source, mediaQuality: $mediaQuality, header: $header}';
  }
}

class LoadRequest {
  final String data;
  final TvType type;
  final Map<String, String>? headers;
  final String apiName;

  LoadRequest(this.data, this.type, this.apiName, {this.headers});

  @override
  String toString() {
    return 'LoadRequest{data: $data, type: $type, headers: $headers, apiName: $apiName}';
  }
}

class TvLoadRequest extends LoadRequest {
  final int season;
  final int episode;

  TvLoadRequest(super.data, super.type, super.apiName,
      {required this.season, required this.episode, super.headers});

  @override
  String toString() {
    return 'TvLoadRequest{season: $season, episode: $episode}';
  }
}

class MovieLoadRequest extends LoadRequest {
  MovieLoadRequest(super.data, super.type, super.apiName, {super.headers});
}

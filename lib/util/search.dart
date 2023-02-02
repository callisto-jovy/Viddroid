import 'media.dart';

abstract class SearchResponse {
  String title;
  String url;
  String apiName;
  TvType type;
  String? thumbnail;
  int? id;
  SearchQuality? searchQuality;
  Map<String, dynamic>? thumbnailHeaders;

  SearchResponse(this.title, this.url, this.apiName,
      {required this.type, this.thumbnail, this.id, this.searchQuality, this.thumbnailHeaders});
}

class MovieSearchResponse extends SearchResponse {
  MovieSearchResponse(super.title, super.url, super.apiName,
      {super.thumbnail, super.id, super.searchQuality, super.thumbnailHeaders}) : super(type: TvType.movie);
}

class TvSearchResponse extends SearchResponse {
  TvSearchResponse(super.title, super.url, super.apiName,
      {super.thumbnail, super.id, super.searchQuality, super.thumbnailHeaders}): super(type: TvType.tv);
}

enum SearchQuality {
  //TODO: Add more
  UHD,

  ///...
}

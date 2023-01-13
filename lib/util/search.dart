abstract class SearchResponse {
  String title;
  String url;
  String apiName;
  SearchType? type;
  String? thumbnail;
  int? id;
  SearchQuality? searchQuality;
  Map<String, dynamic>? thumbnailHeaders;

  SearchResponse(this.title, this.url, this.apiName,
      {this.type, this.thumbnail, this.id, this.searchQuality, this.thumbnailHeaders});
}

class MovieSearchResponse extends SearchResponse {
  MovieSearchResponse(super.title, super.url, super.apiName,
      {String? thumbnail,
      int? id,
      SearchQuality? searchQuality,
      Map<String, dynamic>? thumbnailHeaders})
      : super(
            type: SearchType.movie,
            id: id,
            searchQuality: searchQuality,
            thumbnail: thumbnail,
            thumbnailHeaders: thumbnailHeaders);
}

enum SearchQuality {
  //TODO: Add more
  P144(),
  P1080(),
}

enum SearchType {
  movie,
  tv,
  anime,
  //TODO: Add more in the future.

}

import '../util/fetch.dart';
import '../util/link.dart';
import '../util/media.dart';
import '../util/search.dart';

abstract class SiteProvider {
  final String name;
  final String mainUrl;
  final List<TvType> types;
  final String language;

  const SiteProvider(this.name, this.mainUrl, this.types, this.language);

  Future<List<SearchResponse>> search(final String query);

  Future<FetchResponse> fetch(final SearchResponse searchResponse);

  Stream<LinkResponse> load(final LoadRequest loadRequest);
}

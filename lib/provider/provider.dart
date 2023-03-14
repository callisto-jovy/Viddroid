
import 'package:hive/hive.dart';

import '../util/capsules/fetch.dart';
import '../util/capsules/link.dart';
import '../util/capsules/media.dart';
import '../util/capsules/search.dart';

abstract class SiteProvider {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String mainUrl;
  @HiveField(2)
  final List<TvType> types;
  @HiveField(3)
  final String language;

  const SiteProvider(this.name, this.mainUrl, this.types, this.language);

  Future<List<SearchResponse>> search(final String query);

  Future<FetchResponse> fetch(final SearchResponse searchResponse);

  Stream<LinkResponse> load(final LoadRequest loadRequest);
}

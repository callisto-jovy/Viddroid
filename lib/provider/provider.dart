import 'package:viddroid_flutter_desktop/provider/providers/movies_co.dart';

import '../util/search.dart';

abstract class SiteProvider  {

  final String name;
  final String mainUrl;
  final List<SearchType> types;
  final String language;

  const SiteProvider(this.name, this.mainUrl, this.types, this.language);

  Future<List<SearchResponse>> search(final String query);

}



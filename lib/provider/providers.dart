import 'package:viddroid_flutter_desktop/provider/provider.dart';
import 'package:viddroid_flutter_desktop/provider/providers/movies_co.dart';
import 'package:viddroid_flutter_desktop/provider/providers/sflix_to.dart';
import 'package:viddroid_flutter_desktop/util/search.dart';

class Providers {
  static final Providers _instance = Providers.inst();

  factory Providers() {
    return _instance;
  }

  Providers.inst();

  final List<SiteProvider> siteProviders = [
    MoviesCo(),
    SflixTo(),
  ];
  
  Stream<List<SearchResponse>> search(
      final String query, final List<SearchType> searchTypes) async* {
    for (final SiteProvider provider in siteProviders) {
      if (searchTypes.every((element) => provider.types.contains(element))) {
        final List<SearchResponse> response = await provider.search(query);
        yield response;
      }
    }
  }
}

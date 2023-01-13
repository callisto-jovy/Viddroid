import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:viddroid_flutter_desktop/provider/provider.dart';
import 'package:viddroid_flutter_desktop/util/search.dart';

import '../../constants.dart';

class SflixTo extends SiteProvider {
  SflixTo() : super('Sflix.to', 'https://sflix.to', [SearchType.tv, SearchType.movie], 'en');

  @override
  Future<List<SearchResponse>> search(String query) async {
    final Response response = await simpleGet('$mainUrl/search/${query.replaceAll(" ", "-")}');
    final Document document = parse(response.body);

    final List<Element> items = document.querySelectorAll("div.flw-item");
    return items.map((e) {
      final String href = e.querySelector('a')!.attributes['href']!;
      final String title = e.querySelector("h2.film-name")?.text ?? 'N/A';
      final bool isMovie = href.contains('/movie/');

      final String? thumbnail = e.querySelector('img')?.attributes['data-src'];

      if (isMovie) {
        return MovieSearchResponse(title, href, name, thumbnail: thumbnail);
      } else {
//TODO: Tv Searchresp
        return MovieSearchResponse(title, href, name, thumbnail: thumbnail);
      }
    }).toList();
  }
}

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:viddroid_flutter_desktop/provider/provider.dart';
import 'package:viddroid_flutter_desktop/util/search.dart';

import '../../constants.dart';

class MoviesCo extends SiteProvider {
  MoviesCo()
      : super('Movies.co', 'https://www1.123movies.co',
            [SearchType.tv, SearchType.movie], 'en');

  @override
  Future<List<SearchResponse>> search(String query) async {
    final Response response = await simpleGet('$mainUrl/search?s=$query');
    final Document document = parse(response.body);

    final List<Element> items = document.querySelectorAll("div.videosContainer .ml-mask.jt");
    return items.map((e) {
      final String href = e.attributes['href']!;
      final String title = e.attributes['title'] ?? e.attributes['oldtitle'] ?? 'N/A';
      final bool isMovie = href.contains('/movie/');
      final Element? thumbnailElement = e.querySelector(".lazy.thumb.mli-thumb");
      final String? thumbnail = thumbnailElement?.attributes['src'];

      if (isMovie) {
        return MovieSearchResponse(title, href, name, thumbnail: thumbnail);
      } else {
        //TODO: Tv Searchresp
        return MovieSearchResponse(title, href, name);
      }
    }).toList();
  }
}

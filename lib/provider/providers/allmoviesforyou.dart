import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:viddroid/constants.dart';
import 'package:viddroid/extractor/extractor.dart';
import 'package:viddroid/extractor/extractors.dart';
import 'package:viddroid/provider/provider.dart';
import 'package:viddroid/util/capsules/fetch.dart';
import 'package:viddroid/util/capsules/link.dart';
import 'package:viddroid/util/capsules/media.dart';
import 'package:viddroid/util/capsules/search.dart';
import 'package:viddroid/util/extensions/string_extension.dart';

class AllMoviesForYou extends SiteProvider {
  AllMoviesForYou()
      : super('AllMoviesForYou', 'https://allmoviesforyou.net', [TvType.tv, TvType.movie], 'eng');

  @override
  Future<List<SearchResponse>> search(String query) async {
    final Response response =
        await simpleGet('$mainUrl/?s=$query', responseType: ResponseType.plain);
    final Document document = parse(response.data);

    final List<Element> items = document.querySelectorAll('ul.MovieList > li > article > a');

    return items.map((e) {
      final String href = e.attributes['href']!;
      final String title = e.querySelector('h2.Title')?.text ?? 'N/A';
      final bool isMovie = href.contains('/movies/');

      final String thumbnail = 'https:${(e.querySelector('img')?.attributes['data-src']) ?? ''}';

      if (isMovie) {
        return MovieSearchResponse(title, href, name, thumbnail: thumbnail);
      } else {
        return TvSearchResponse(title, href, name, thumbnail: thumbnail);
      }
    }).toList();
  }

  @override
  Future<FetchResponse> fetch(SearchResponse searchResponse) async {
    final String url = searchResponse.url;
    final Response response = await simpleGet(url, responseType: ResponseType.plain);
    final Document document = parse(response.data);

    final String title = document.querySelector('h1.Title')?.text ?? 'K/A';
    final String? description = document.querySelector('div.Description > p')?.text;

    final String? year = document.querySelector('span.Date')?.text;

    final String? backgroundRelative =
        document.querySelector('div.Image > figure > img')?.attributes['src'];

    final String? backgroundImage = backgroundRelative != null ? 'http:$backgroundRelative' : null;

    final String? duration = document.querySelector('span.Time')?.text;

    if (searchResponse.type == TvType.tv) {
      final List<Episode> episodes = [];
      final List<Element> seasons =
          document.querySelectorAll('main > section.SeasonBx > div > div.Title > a');

      for (int i = 0; i < seasons.length; i++) {
        final Element seasonElement = seasons[i];
        final String? href = seasonElement.attributes['href'];
        if (href == null) {
          continue;
        }

        final Response response = await simpleGet(href, responseType: ResponseType.plain);
        final Document document = parse(response.data);

        final List<Element> episodeElements = document.querySelectorAll('table > tbody > tr');

        for (int j = 0; j < episodeElements.length; j++) {
          final Element episodeElement = episodeElements[j];
          final String name = episodeElement.querySelector('.MvTbTtl > a')?.text ?? 'Episode $j';
          final String? href = episodeElement.querySelector('.MvTbTtl > a')?.attributes['href'];

          if (href == null) {
            continue;
          }

          final String? thumbnailRelative =
              episodeElement.querySelector('.MvTbImg > img')?.attributes['src'];
          final String? thumbnail = thumbnailRelative != null ? 'http:$thumbnailRelative' : null;

          episodes.add(Episode(name, j, i, thumbnail, href));
        }
      }

      return TvFetchResponse(title, url, name, searchResponse.type, url,
          episodes: episodes,
          seasons: seasons.length,
          backgroundImage: backgroundImage,
          thumbnail: searchResponse.thumbnail,
          year: year,
          duration: duration,
          description: description);
    } else {
      return MovieFetchResponse(title, url, name, searchResponse.type, url,
          thumbnail: searchResponse.thumbnail,
          backgroundImage: backgroundImage,
          year: year,
          duration: duration,
          description: description);
    }
  }

  @override
  Stream<LinkResponse> load(LoadRequest loadRequest) async* {
    final Response response = await simpleGet(loadRequest.data, responseType: ResponseType.plain);
    final Document document = parse(response.data);

    final List<Element> iframes = document.querySelectorAll('body iframe');

    for (final Element iframe in iframes) {
      final String? src = iframe.attributes['src'];
      if (src == null) {
        continue;
      }

      if (src.contains('trembed')) {
        final Response apiResponse = await simpleGet(src, responseType: ResponseType.plain);
        final Document document = parse(apiResponse.data);

        final List<Element> iframes = document.querySelectorAll('body iframe');
        for (Element element in iframes) {
          final String link = element.attributes['src']!;
          final Extractor? extractor = Extractors().findExtractor(link.extractMainUrl);
          if (extractor == null) {
            continue;
          }
          yield* extractor.extract(link, headers: {'referer': loadRequest.data});
        }
      } else {
        final Extractor? extractor = Extractors().findExtractor(src.extractMainUrl);

        if (extractor == null) {
          continue;
        }
        yield* extractor.extract(src, headers: {'referer': loadRequest.data});
      }
    }
  }
}

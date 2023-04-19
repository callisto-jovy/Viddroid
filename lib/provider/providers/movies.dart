import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:viddroid/extractor/extractors.dart';
import 'package:viddroid/provider/provider.dart';
import 'package:viddroid/util/capsules/fetch.dart';
import 'package:viddroid/util/capsules/link.dart';
import 'package:viddroid/util/capsules/search.dart';
import 'package:viddroid/util/extensions/string_extension.dart';

import '../../constants.dart';
import '../../extractor/extractor.dart';
import '../../util/capsules/media.dart';

class Movies123 extends SiteProvider {
  Movies123() : super('Movies.co', 'https://www1.123movies.co', [TvType.tv, TvType.movie], 'en');

  @override
  Future<List<SearchResponse>> search(String query) async {
    final Response response = await simpleGet('$mainUrl/search?s=$query');
    final Document document = parse(response.data);

    final List<Element> items = document.querySelectorAll('div.videosContainer .ml-mask.jt');
    return items.map((e) {
      final String href = e.attributes['href']!;
      final String title = e.attributes['title'] ?? e.attributes['oldtitle'] ?? 'N/A';
      final bool isMovie = href.contains('/movie/');
      final Element? thumbnailElement = e.querySelector('.lazy.thumb.mli-thumb');
      final String? thumbnail = thumbnailElement?.attributes['src'];

      if (isMovie) {
        return MovieSearchResponse(title, href, name, thumbnail: thumbnail);
      } else {
        return TvSearchResponse(title, href, name, thumbnail: thumbnail);
      }
    }).toList();
  }

  @override
  Future<FetchResponse> fetch(SearchResponse searchResponse) async {
    final Response response = await simpleGet(searchResponse.url);
    final Document document = parse(response.data);
    final RegExp thumbnailRegex = RegExp(r'(?<=url\()[^)]+');

    final String title = document.querySelector('.topdescriptiondesc')?.children[0].text ??
        'N/A'; //necessary, because movies_co uses different headers, depending on the type of media.

    final String? description = document.querySelector('.topdescriptiondesc > p')?.text;
    final String? duration =
        document.querySelector('.chartdescriptionRight > ul > li > span')?.text;

    final String? year = document.querySelector('.chartdescriptionRight > ul > li > span')?.text;
    final String? styleBackgroundImage =
        document.querySelector('.thumb.mvi-cover')?.attributes['style'];
    final String? backgroundImage =
        styleBackgroundImage != null ? thumbnailRegex.stringMatch(styleBackgroundImage) : null;

    final String? thumbnail =
        document.querySelector('.topdescriptionthumb > img')?.attributes['src'];

    final bool isTv = searchResponse.url.contains('series');

    final String? url = document.querySelector('.thumb.mvi-cover')?.attributes['href'];
    if (url == null) {
      return Future.error('Url not available');
    }

    final Response watchingResponse = await simpleGet(url);
    final Document watchingDocument = parse(watchingResponse.data);

    /*
    final String playerUrl =
        watchingDocument.querySelector('.playerLock > iframe')!.attributes['src']!;

     */

    if (isTv) {
      final Element? seasonsElement =
          watchingDocument.querySelector('.espidoes_listings_area.smallContainer.clear');

      final List<Episode> episodes = [];
      final int seasons = seasonsElement == null ? 0 : seasonsElement.children.length;

      if (seasonsElement != null) {
        final List<Element> seasonElements = seasonsElement.children;

        for (int i = 0; i < seasonElements.length; i++) {
          final Element element = seasonElements[i];
          final List<Element> episodeElements =
              element.querySelector('.single_epsiode_row_right')!.children;

          for (int j = 0; j < episodeElements.length; j++) {
            final Episode episode =
                Episode('Episode $j', j, i, null, episodeElements[j].attributes['href']!);

            episodes.add(episode);
          }
        }
      }

      return TvFetchResponse(title, url, name, TvType.tv, url,
          episodes: episodes,
          seasons: seasons,
          backgroundImage: backgroundImage,
          year: year,
          thumbnail: thumbnail,
          description: description,
          duration: duration);
    } else {
      return MovieFetchResponse(title, url, name, TvType.movie, url,
          backgroundImage: backgroundImage,
          year: year,
          thumbnail: thumbnail,
          description: description,
          duration: duration);
    }
  }

  final RegExp tcRegex = RegExp(r"var tc = '(.*)'");
  final RegExp tokenRegex = RegExp(r'"_token": "(.*)"');
  final RegExp sliceRegex = RegExp(r'slice\((\d),(\d+)\)');
  final RegExp rndNumRegex = RegExp(r'\+ "(\d+)"\+"(\d+)');

  @override
  Stream<LinkResponse> load(LoadRequest loadRequest) async* {
    //.playerLock > iFrame
    //videoPlayer

    final Response response = await simpleGet(loadRequest.data);
    final Document document = parse(response.data);

    final String? url = document
        .querySelector(
            loadRequest is TvLoadRequest ? '.playerLock > iframe' : '.videoPlayer > iframe')
        ?.attributes['src'];

    if (url == null) return;

    final String responseBody = await simpleGet(url).then((value) => value.data);

    //TODO: update regex
    const String decodingAPI = 'https://gomo.to/decoding_v3.php';

    final String? tc = tcRegex.firstMatch(responseBody)?[1];
    final String? token = tokenRegex.stringMatch(responseBody);

    if (token == null || tc == null) {
      return;
    }
    final RegExpMatch? sliceMatch = sliceRegex.firstMatch(responseBody);
    final String? sliceStart = sliceMatch?[1];
    final String? sliceEnd = sliceMatch?[2];
    final RegExpMatch? rndNumMatch = rndNumRegex.firstMatch(responseBody);

    if (sliceStart == null || sliceEnd == null) {
      return;
    }

    final String xToken =
        tc.substring(int.parse(sliceStart), int.parse(sliceEnd)).split('').reversed.join() +
            (rndNumMatch != null ? (rndNumMatch.groups([1, 2]).join('')) : '');

    final Response apiResponse = await simplePost(decodingAPI, {
      'tokenCode': tc,
      '_token': token
    }, headers: {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'x-token': xToken,
      'referer': url,
    });

    if (apiResponse.statusCode == 200) {
      final dynamic jsonArray = jsonDecode(apiResponse.data);

      for (final String link in jsonArray) {
        if (link.isEmpty) {
          continue;
        }
        final Extractor? extractor = Extractors().findExtractor(link.extractMainUrl);
        if (extractor != null) {
          yield* extractor.extract(link, headers: {'referer': url});
        }
      }
    }
  }
}

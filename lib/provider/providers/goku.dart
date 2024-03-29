import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:viddroid/provider/provider.dart';
import 'package:viddroid/util/capsules/fetch.dart';
import 'package:viddroid/util/capsules/link.dart';
import 'package:viddroid/util/capsules/search.dart';
import 'package:viddroid/util/extensions/string_extension.dart';

import '../../constants.dart';
import '../../extractor/extractor.dart';
import '../../extractor/extractors.dart';
import '../../util/capsules/media.dart';

class Goku extends SiteProvider {
  Goku() : super('Goku', 'https://goku.to', [TvType.tv, TvType.movie], 'eng');

  @override
  Future<List<SearchResponse>> search(final String query) async {
    final Response response = await simpleGet('$mainUrl/ajax/movie/search?keyword=$query');
    final Document document = parse(response.data);

    final List<Element> items = document.querySelectorAll('.item');
    return items.map((e) {
      final String href = e.querySelector('div.is-watch > a')?.attributes['href'] ??
          'null'; //TODO: Fix the missing attribute

      final String title = e.querySelector('h3.movie-name')?.text ?? 'N/A';

      final bool isMovie = href.contains('/watch-movie/');

      final String? thumbnail = e.querySelector('img')?.attributes['src'];

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

    final Response response = await simpleGet('$mainUrl/$url');
    final Document document = parse(response.data);

    final String? backgroundUrl = document.querySelector('img.is-cover')?.attributes['src'];

    final Element? thumbnailElement = document.querySelector('.movie-thumbnail > img');

    final RegExp dataIdRegex = RegExp(r"(?<=.+id: ')[^']+");

    final String dataId =
        dataIdRegex.stringMatch(response.data) ?? url.substring(url.lastIndexOf('-') + 1);

    // Meta-data
    final String? thumbnail = thumbnailElement?.attributes['src'];
    final String title = thumbnailElement?.attributes['alt'] ?? 'N/A';

    final String? duration = document.querySelector('.fs-item > .duration')?.text;
    final String? year = document.querySelector('elements .col-xl-5 .row-line')?.text;

    final String? description =
        document.querySelector('.dropdown-text > .dropdown-text')?.text.trim();

    final bool isMovie = url.contains('movie');

    if (isMovie) {
      return MovieFetchResponse(title, url, name, TvType.movie, dataId,
          thumbnail: thumbnail,
          duration: duration,
          year: year,
          backgroundImage: backgroundUrl,
          description: description);
    } else {
      final Response apiSeasons = await simpleGet('$mainUrl/ajax/movie/seasons/$dataId');
      final Document seasonsDocument = parse(apiSeasons.data);

      List<Element> seasonElements =
          seasonsDocument.querySelectorAll('div.dropdown-menu.dropdown-primary > a');

      if (seasonElements.isEmpty) {
        seasonElements = seasonsDocument.querySelectorAll('div.dropdown-menu > a.dropdown-item');
      }

      final List<Episode> episodes = [];

      for (int i = 0; i < seasonElements.length; i++) {
        final Element value = seasonElements[i];
        final String? seasonId = value
            .attributes['data-id']; //Data-id has to be given. If not, the seasons would be invalid
        if (seasonId == null) {
          continue;
        }

        final Response apiEpisodes =
            await simpleGet('$mainUrl/ajax/movie/season/episodes/$seasonId');
        final Document episodesDocument = parse(apiEpisodes.data);

        List<Element> episodeElements = episodesDocument.querySelectorAll('div.item > a');

        episodeElements.asMap().forEach((index, value) {
          final String title = value.attributes['title'] ?? value.text;
          final String? episodeId = value.attributes['data-id'];
          if (episodeId == null) {
            return;
          }

          episodes.add(Episode(title, index, i, null, episodeId));
        });
      }

      return TvFetchResponse(title, url, name, TvType.tv, dataId,
          seasons: seasonElements.length,
          episodes: episodes,
          backgroundImage: backgroundUrl,
          thumbnail: thumbnail,
          duration: duration,
          description: description);
    }
  }

  @override
  Stream<LinkResponse> load(LoadRequest loadRequest) async* {
    final String url = loadRequest.type == TvType.movie
        ? '$mainUrl/ajax/movie/episodes/${loadRequest.data}'
        : '$mainUrl/ajax/movie/episode/servers/${loadRequest.data}';

    final Response response = await simpleGet(url);
    final Document document = parse(response.data);

    final List<String> ids = document
        .querySelectorAll('a')
        .where((element) => element.attributes['data-id'] != null)
        .map((e) {
      final String dataId = e.attributes['data-id']!;
      return dataId;
    }).toList();

    for (String serverId in ids) {
      final Response response = await simpleGet(
          '$mainUrl/ajax/movie/episode/server/sources/$serverId',
          responseType: ResponseType.plain);

      final Map<String, dynamic> json = jsonDecode(response.data);
      final String? link = json['data']['link'];

      if (link != null) {
        final Extractor? extractor = Extractors().findExtractor(link.extractMainUrl);
        if (extractor != null) {
          yield* extractor.extract(link);
        }
      }
    }
  }
}

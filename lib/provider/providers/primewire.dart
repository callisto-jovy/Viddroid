import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:viddroid_flutter_desktop/provider/provider.dart';
import 'package:viddroid_flutter_desktop/util/capsules/fetch.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';
import 'package:viddroid_flutter_desktop/util/capsules/media.dart';
import 'package:viddroid_flutter_desktop/util/capsules/search.dart';
import 'package:viddroid_flutter_desktop/util/extensions/string_extension.dart';

import '../../constants.dart';
import '../../extractor/extractor.dart';
import '../../extractor/extractors.dart';
import '../../watchable/episode.dart';

class PrimeWire extends SiteProvider {
  PrimeWire()
      : super(
          'Primewire',
          'https://primewire.mx',
          [
            TvType.tv,
            TvType.movie,
          ],
          'eng',
        );

  @override
  Future<List<SearchResponse>> search(String query) async {
    //Similar to sflix, and others
    final Response response = await simpleGet('$mainUrl/search/${query.replaceAll(' ', '-')}');
    final Document document = parse(response.data);

    final List<Element> items = document.querySelectorAll('.fbr-line.fbr-content');
    return items.map((e) {
      final Element titleElement = e.querySelector('.film-name > a')!;

      final String href = titleElement.attributes['href']!;
      final String title = titleElement.text;
      final bool isMovie = href.contains('/movie/');

      final String? thumbnail = e.querySelector('img')?.attributes['data-src'];

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

    //Background url
    final RegExp backgroundUrlPattern = RegExp(r'(?<=url\()[^)]+');
    final String? backgroundCss = document.querySelector('.dp-w-cover')?.attributes['style'];
    final String? backgroundUrl =
        backgroundCss == null ? null : backgroundUrlPattern.firstMatch(backgroundCss)?.group(0);
    final Element? thumbnailElement = document.querySelector('.film-poster-img');

    final List<Element> detailsElements = document.querySelectorAll('.dp-elements');

    final String dataId =
        document.querySelector('watching.detail_page-watch')?.attributes['data-id'] ??
            url.substring(url.lastIndexOf('-') + 1);

    // Meta-data
    final String? thumbnail = thumbnailElement?.attributes['src'];
    final String title = thumbnailElement?.attributes['title'] ?? 'N/A';

    final String? duration = detailsElements.length < 2 ? null : detailsElements[1].text;

    final String year = detailsElements[0].text;
    final String? description = document.querySelector('.description')?.text.trim();

    final bool isMovie = url.contains('movie');

    if (isMovie) {
      return MovieFetchResponse(title, url, name, TvType.movie, dataId,
          thumbnail: thumbnail,
          duration: duration,
          year: year,
          backgroundImage: backgroundUrl,
          description: description);
    } else {
      final Response apiSeasons = await simpleGet('$mainUrl/ajax/v2/tv/seasons/$dataId');
      final Document seasonsDocument = parse(apiSeasons.data);

      List<Element> seasonElements =
          seasonsDocument.querySelectorAll('div.dropdown-menu.dropdown-menu-new > a');

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

        final Response apiEpisodes = await simpleGet('$mainUrl/ajax/v2/season/episodes/$seasonId');
        final Document episodesDocument = parse(apiEpisodes.data);

        List<Element> episodeElements = episodesDocument.querySelectorAll('.nav-item > a');

        //   if (episodeElements.isEmpty) {
        //     episodeElements = episodesDocument.querySelectorAll('ul > li > a');
        //   }

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
        : '$mainUrl/ajax/v2/episode/servers/${loadRequest.data}';

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
      final Response response =
          await simpleGet('$mainUrl/ajax/get_link/$serverId', responseType: ResponseType.plain);

      // if (response.data.isEmpty) return;

      final Map<String, dynamic> json = jsonDecode(response.data);
      final String? link = json['link'];

      if (link != null) {
        final Extractor? extractor = Extractors().findExtractor(link.extractMainUrl);
        if (extractor != null) {
          yield* extractor.extract(link);
        }
      }
    }
  }
}

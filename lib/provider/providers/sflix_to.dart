import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:viddroid_flutter_desktop/provider/provider.dart';
import 'package:viddroid_flutter_desktop/util/fetch.dart';
import 'package:viddroid_flutter_desktop/util/link.dart';
import 'package:viddroid_flutter_desktop/util/search.dart';

import '../../constants.dart';
import '../../util/media.dart';
import '../../watchable/episode.dart';

class SflixTo extends SiteProvider {
  SflixTo() : super('Sflix.to', 'https://sflix.to', [TvType.tv, TvType.movie], 'en');

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
        return TvSearchResponse(title, href, name, thumbnail: thumbnail);
      }
    }).toList();
  }

  @override
  Future<FetchResponse> fetch(SearchResponse searchResponse) async {
    final String url = searchResponse.url;

    final Response response = await simpleGet('$mainUrl/$url');
    final Document document = parse(response.body);

    //Background url
    final RegExp backgroundUrlPattern = RegExp(r'(?<=url\()[^)]+');
    final String? backgroundCss = document.querySelector(".cover_follow")?.attributes['style'];
    final String? backgroundUrl =
        backgroundCss == null ? null : backgroundUrlPattern.firstMatch(backgroundCss)?.group(0);

    final Element detailsElement = document.querySelector('div.detail_page-watch')!;
    final Element? thumbnailElement = detailsElement.querySelector('img.film-poster-img');

    final String dataId =
        detailsElement.attributes['data-id'] ?? url.substring(url.lastIndexOf("-"));
    final String? thumbnail = thumbnailElement?.attributes['src'];
    final String title = thumbnailElement?.attributes['title'] ?? 'N/A';
    final String? duration = document.querySelector(".fs-item > .duration")?.text;
    final String? year = document.querySelector("elements .col-xl-5 .row-line")?.text;

    final bool isMovie = url.contains("movie");

    if (isMovie) {
      return MovieFetchResponse(title, url, name, TvType.movie, dataId,
          thumbnail: thumbnail, duration: duration, year: year, backgroundImage: backgroundUrl);
    } else {
      final Response apiSeasons = await simpleGet("$mainUrl/ajax/v2/tv/seasons/$dataId");
      final Document seasonsDocument = parse(apiSeasons.body);

      List<Element> seasonElements =
          seasonsDocument.querySelectorAll("div.dropdown-menu.dropdown-menu-model > a");

      if (seasonElements.isEmpty) {
        seasonElements = seasonsDocument.querySelectorAll("div.dropdown-menu > a.dropdown-item");
      }

      final List<Episode> episodes = [];

      for (int i = 0; i < seasonElements.length; i++) {
        final Element value = seasonElements[i];
        final String? seasonId = value
            .attributes['data-id']; //Data-id has to be given. If not, the seasons would be invalid
        if (seasonId == null) {
          continue;
        }

        final Response apiEpisodes = await simpleGet("$mainUrl/ajax/v2/season/episodes/$seasonId");
        final Document episodesDocument = parse(apiEpisodes.body);

        List<Element> episodeElements = episodesDocument
            .querySelectorAll("div.flw-item.film_single-item.episode-item.eps-item");
        if (episodeElements.isEmpty) {
          episodeElements = episodesDocument.querySelectorAll("ul > li > a");
        }

        episodeElements.asMap().forEach((index, value) {
          final Element? thumbnailElement = value.querySelector("img");
          final String? thumbnail = thumbnailElement?.attributes['src'];
          final String title = thumbnailElement?.attributes['title'] ?? value.text;
          final String? episodeId = value.attributes['data-id'];
          if (episodeId == null) {
            return;
          }

          episodes.add(Episode(title, index, i, thumbnail, episodeId));
        });
      }

      return TvFetchResponse(title, url, name, TvType.tv, dataId, seasons: seasonElements.length,
          episodes: episodes, backgroundImage: backgroundUrl);
    }
  }

  @override
  Stream<LinkResponse> load(LoadRequest loadRequest) async* {
    final String url = loadRequest.type == TvType.movie
        ? "$mainUrl/ajax/movie/episodes/${loadRequest.data}"
        : "$mainUrl/ajax/v2/episode/servers/${loadRequest.data}";

    final Response response = await simpleGet(url);
    final Document document = parse(response.body);

    final List<String> ids = document
        .querySelectorAll("a")
        .where((element) => element.attributes['data-id'] != null)
        .map((e) {
      final String dataId = e.attributes['data-id']!;

      //TODO: Supported streams
      return dataId;
    }).toList();

    for (String serverId in ids) {
      final Response response = await simpleGet("$mainUrl/ajax/get_link/$serverId");
      if (response.body.isEmpty) return;

      final dynamic json = jsonDecode(response.body);
      if (json['link'] != null) {
        yield LinkResponse(json['link'], '', '', MediaQuality.unknown);
      }
    }
  }
}

import 'dart:convert';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:dio/dio.dart';
import 'package:viddroid_flutter_desktop/constants.dart';
import 'package:viddroid_flutter_desktop/util/capsules/fetch.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';
import 'package:viddroid_flutter_desktop/util/capsules/media.dart';
import 'package:viddroid_flutter_desktop/util/capsules/search.dart';
import 'package:viddroid_flutter_desktop/util/extraction/js_packer.dart';
import 'package:viddroid_flutter_desktop/watchable/episode.dart';

import '../provider.dart';

class AnimePahe extends SiteProvider {
  AnimePahe()
      : super(
          'Anime Pahe',
          'https://animepahe.ru',
          [TvType.anime],
          'eng',
        );

  @override
  Future<List<SearchResponse>> search(String query) async {
    final Response response = await simpleGet('$mainUrl/api?m=search&q=$query');
    final dynamic entries = response.data['data'];

    final List<SearchResponse> responses = [];

    for (dynamic entry in entries) {
      final String title = entry['title'];
      final String thumbnail = entry['poster'];

      final bool isTv = entry['type'] == 'TV';

      if (isTv) {
        responses.add(TvSearchResponse(title, entry['session'], name, thumbnail: thumbnail));
      } else {
        responses.add(MovieSearchResponse(title, entry['session'], name, thumbnail: thumbnail));
      }
    }
    return responses;
  }

  @override
  Future<FetchResponse> fetch(SearchResponse searchResponse) async {
    //Important later on..
    final String siteUrl = '$mainUrl/anime/${searchResponse.url}';
    final Response response = await simpleGet(siteUrl);

    final Document document = parse(response.data);
    final String documentBody = response.data;

    final String title = document.querySelector('.title-wrapper > h2')?.text ?? 'N/A';
    final String? year =
        RegExp(r'<strong>Aired:</strong>[^,]*, (\d+)').firstMatch(documentBody)?.group(1);

    final String? backgroundRelative =
        document.querySelector('.anime-cover')?.attributes['data-src'];
    final String? backgroundImage = backgroundRelative == null ? null : 'https:$backgroundRelative';

    final String? thumbnail = document.querySelector('.anime-poster > a')?.attributes['href'];

    final String? description = document.querySelector('.anime-synopsis')?.text;
    final String? duration = RegExp(r'<strong>Duration:</strong>([^<]+)')
        .firstMatch(documentBody)
        ?.group(1)
        ?.substring(0, 3);

    final bool isMovie =
        document.querySelector('.col-sm-4.anime-info > p > strong > a')?.attributes['title'] ==
            'Movie';

    //This api has basically become useless, as Animepahe now embeds their videos into their site, why soever?
    final Response episodeApiResponse =
        await simpleGet('$mainUrl/api?m=release&id=${searchResponse.url}&sort=episode_asc&page=1');

    final dynamic responseJson = episodeApiResponse.data;

    if (isMovie) {
      final String referral = document.querySelector('.play')!.text;

      // final String sessionId = responseJson['data'][0]['session'];
      return MovieFetchResponse(title, referral, name, TvType.movie, referral,
          backgroundImage: backgroundImage,
          thumbnail: thumbnail,
          description: description,
          year: year,
          duration: duration);
    } else {
      final List<Episode> episodes = [];

      final int pages = responseJson['last_page'];
      //iterate through the pages

      for (int i = 1; i < pages + 1; i++) {
        final Response episodeApiResponse = await simpleGet(
            'https://animepahe.ru/api?m=release&id=${searchResponse.url}&sort=episode_asc&page=$i');
        final dynamic responseJson = episodeApiResponse.data;

        final dynamic episodesJson = responseJson['data'];

        for (int j = 0; j < episodesJson.length; j++) {
          final dynamic episode = episodesJson[j];
          final String episodeUrl = '$mainUrl/play/${searchResponse.url}/${episode['session']}';

          final String? thumbnail = episode['snapshot'];
          final String name = episode['title'] ?? 'Episode: ${episodes.length}';

          episodes.add(Episode(name, episodes.length, 0, thumbnail, episodeUrl));
        }
      }

      return TvFetchResponse(title, 'url', name, TvType.movie, '',
          seasons: 1,
          episodes: episodes,
          backgroundImage: backgroundImage,
          thumbnail: thumbnail,
          description: description,
          year: year,
          duration: duration);
    }
  }

  @override
  Stream<LinkResponse> load(LoadRequest loadRequest) async* {
    //dio.Dio().get(loadRequest.data).then((value) => print(value));
    final Response response = await simpleGet(loadRequest.data, headers: {'referer': mainUrl});
    final Document document = parse(response.data);
    final List<Element> items = document.querySelectorAll('#resolutionMenu > .dropdown-item');

    for (final Element element in items) {
      final String kwik = element.attributes['data-src']!;
      final String quality = element.attributes['data-resolution']!;

      //Extract from kwik

      final Response response = await simpleGet(kwik, headers: {'referer': mainUrl});
      final String responseBody = response.data;

      final String? scriptMatch = RegExp(r'(eval(.|\n)*?)</script>').firstMatch(responseBody)?[1];

      if (scriptMatch != null) {
        final String? unpacked = JSPacker(scriptMatch).unpack();

        //print(scriptMatch);

        if (unpacked != null) {
          final String? sourceMatch = RegExp(r"(?<=const source=')[^']+").stringMatch(unpacked);
          if (sourceMatch != null) {
            yield LinkResponse(sourceMatch, kwik, '', MediaQualityExtension.fromString(quality),
                title: 'kwick');
          }
        }
      }

    }
  }
}

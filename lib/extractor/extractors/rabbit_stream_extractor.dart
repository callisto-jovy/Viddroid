import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:viddroid_flutter_desktop/constants.dart';
import 'package:viddroid_flutter_desktop/extractor/extractor.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';
import 'package:viddroid_flutter_desktop/util/capsules/media.dart';
import 'package:viddroid_flutter_desktop/util/extraction/sflix_util.dart';

/// Works pretty much the same as doki_cloud
class RabbitStreamExtractor extends Extractor {
  RabbitStreamExtractor()
      : super('RabbitStream', 'https://rabbitstream.net', 'https://rabbitstream.net');

  @override
  Stream<LinkResponse> extract(String url, {Map<String, String>? headers}) async* {
    //link: "https://rabbitstream.net/embed-4/o3kCy4CUD4Nr?z=" --> /embed-4
    final int lastSlash = url.lastIndexOf('/');
    final String baseIframeUrl = url.substring(url.lastIndexOf('/', lastSlash - 1), lastSlash);
    final String baseIframeId = url.substring(url.lastIndexOf('/') + 1, url.lastIndexOf('?'));

    final String apiUrl = '$mainUrl/ajax$baseIframeUrl/getSources?id=$baseIframeId';

    final Response response = await simpleGet(apiUrl,
        headers: {
          'referer': url,
          'X-Requested-With': 'XMLHttpRequest',
          'Accept': '*/*',
          'Accept-Language': 'en-US,en;q=0.5',
          'Connection': 'keep-alive',
          'TE': 'trailers'
        },
        responseType: ResponseType.plain);

    final dynamic sources = jsonDecode(response.data)['sources'];
    if (sources == null) {
      return;
    }

    if (sources is String) {
      final String decrypted = decrypt(sources, 'c1d17096f2ca11b7');
      final dynamic decryptedJson = jsonDecode(decrypted);

      for (int i = 0; i < decryptedJson.length; i++) {
        final dynamic entry = decryptedJson[i];
        final String url = entry['file'];

        yield LinkResponse(url, mainUrl, '', MediaQuality.unknown, title: name);
      }
    } else {
      for (dynamic s in sources) {
        //TODO: Fetch from url
        if (s is Map) {
          print(s);
          yield LinkResponse(s['file'], mainUrl, '', MediaQuality.unknown, title: name);
        } else {}
      }
    }
  }

  Future<String> _getKey() =>
      simpleGet('https://raw.githubusercontent.com/consumet/rapidclown/rabbitstream/key.txt',
              responseType: ResponseType.plain)
          .then((value) => value.data);
}

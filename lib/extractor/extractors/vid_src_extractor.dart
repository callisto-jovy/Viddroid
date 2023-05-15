import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:viddroid/extractor/extractors.dart';
import 'package:viddroid/util/capsules/link.dart';
import 'package:viddroid/util/capsules/media.dart';
import 'package:viddroid/util/extensions/string_extension.dart';

import '../../constants.dart';
import '../extractor.dart';

class VidSrcExtractor extends Extractor {
  VidSrcExtractor() : super('VidSrc', 'https://v2.vidsrc.me', 'https://v2.vidsrc.me/embed');

  @override
  Stream<LinkResponse> extract(String url, {Map<String, String>? headers}) async* {
    final Response urlResponse = await simpleGet(url, headers: headers);
    final Document document0 = parse(urlResponse.data);

    final List<String> servers = [];
    final String? playerUrl = document0.querySelector('#player_iframe')?.attributes['src'];
    if (playerUrl == null) {
      return;
    }

    for (final Element element in document0.querySelectorAll('.source')) {
      final String? dataHash = element.attributes['data-hash'];
      if (dataHash != null && dataHash.isNotEmpty) {
        try {
          final Response resp = await simpleGet('$mainUrl/srcrcp/$dataHash',
              headers: {'referer': 'https://rcp.vidsrc.me/'});
          servers.add(resp.realUri.toString());
        } catch (e) {
          logger.e(e);
        }
      }
    }

   // print(servers);

    for (final String server in servers) {
      final String fixedLink = server.replaceAll('https://vidsrc.xyz/', 'https://embedsito.com/');

      if (fixedLink.contains('/prorcp')) {
        final Response srcResp = await simpleGet(server, headers: {'referer': mainUrl});
        final String respBody = srcResp.data;

        final RegExp m3u8Regex = RegExp(r'((https:|http:)//.*\.m3u8)');

        final String? srcm3u8 = m3u8Regex.stringMatch(respBody);

        final RegExp passRegex = RegExp(r"""['"](.*set_pass[^"']*)""");

        final String? pass =
            passRegex.firstMatch(respBody)?.group(1)?.replaceAll("^//", 'https://');

        if (pass != null && srcm3u8 != null) {
          yield LinkResponse(srcm3u8, 'https://vidsrc.stream/', pass, MediaQuality.unknown,
              title: name, header: {'TE': 'trailers'});
        }
      } else {
        final Extractor? extractor = Extractors().findExtractor(server.extractMainUrl);
        if (extractor != null) {
          yield* extractor.extract(server);
        }
      }
    }
  }
}

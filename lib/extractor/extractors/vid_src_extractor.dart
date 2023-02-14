import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:dio/dio.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';
import 'package:viddroid_flutter_desktop/util/capsules/media.dart';

import '../../constants.dart';
import '../extractor.dart';

class VidSrcExtractor extends Extractor {
  VidSrcExtractor() : super('VidSrc', 'https://v2.vidsrc.me/', 'https://v2.vidsrc.me/embed');

  @override
  Stream<LinkResponse> extract(String url, {Map<String, String>? headers}) async* {
    final Response urlResponse = await simpleGet(url, headers: headers);
    final Document document = parse(urlResponse.data);

    final List<String> servers = [];

    for (final Element element in document.querySelectorAll('div.active_source.source')) {
      final String? dataHash = element.attributes['data-hash'];
      if (dataHash != null && dataHash.isNotEmpty) {
        final Response resp = await simpleGet('${mainUrl}srcrcp/$dataHash',
            headers: {'referer': 'https://rcp.vidsrc.me/'});

        /*
        TODO: Rewrite with dio
        if (resp.request != null) {
          servers.add(resp.request!.url.toString());
        }

         */
      }
    }

    for (final String server in servers) {
      final String fixedLink = server.replaceAll('https://vidsrc.xyz/', 'https://embedsito.com/');

      if (fixedLink.contains('/srcrcp/')) {
        final Response srcResp = await simpleGet(server, headers: {'referer': mainUrl});
        final String respBody = srcResp.data;

        final RegExp m3u8Regex = RegExp(r'((https:|http:)//.*\.m3u8)');

        final String? srcm3u8 = m3u8Regex.stringMatch(respBody);

        final RegExp passRegex = RegExp(r"""['"](.*set_pass[^"']*)""");

        final String? pass =
            passRegex.firstMatch(respBody)?.group(1)?.replaceAll("^//", 'https://');

        if (pass != null && srcm3u8 != null) {
          yield LinkResponse(srcm3u8, 'https://vidsrc.stream/', pass, MediaQuality.unknown,
              title: name);
        }
      } else {
        //TODO: Redirect to other extractors
      }
    }
  }
}

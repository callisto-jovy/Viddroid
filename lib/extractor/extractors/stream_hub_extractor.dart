import 'package:dio/dio.dart';
import 'package:viddroid_flutter_desktop/constants.dart';
import 'package:viddroid_flutter_desktop/extractor/extractor.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';
import 'package:viddroid_flutter_desktop/util/capsules/media.dart';

import '../../util/extraction/js_packer.dart';

class StreamHubExtractor extends Extractor {
  StreamHubExtractor() : super('StreamHub', 'https://streamhub.to', 'https://streamhub.to');

  final RegExp evalRegex = RegExp(r"""eval((.|\n)*?)</script>""");
  final RegExp srcRegex = RegExp(r'sources:\[\{src:"(.*?)"');

  @override
  Stream<LinkResponse> extract(String url, {Map<String, String>? headers}) async* {
    final Response response =
        await simpleGet(url, headers: headers, responseType: ResponseType.plain);
    final RegExpMatch regExpMatch = evalRegex.allMatches(response.data).last;

    final String stringMatch = regExpMatch.group(0)!;

    final String? unpackedBody = JSPacker(stringMatch).unpack();

    if (unpackedBody == null) {
      return;
    }

    final String? srcMatch = srcRegex.firstMatch(unpackedBody)?.group(1);

    if (srcMatch == null) {
      return;
    }
    yield LinkResponse(srcMatch, url, '', MediaQuality.unknown, title: name);
  }
}

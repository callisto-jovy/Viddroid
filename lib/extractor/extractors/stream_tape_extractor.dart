import 'package:http/http.dart';
import 'package:requests/requests.dart';
import 'package:viddroid_flutter_desktop/extractor/extractor.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';
import 'package:viddroid_flutter_desktop/util/capsules/media.dart';

import '../../constants.dart';

class StreamTapeExtractor extends Extractor {
  StreamTapeExtractor()
      : super('StreamTape', 'https://streamtape.com', 'https://streamtape.com',
            altUrls: ['https://streamtape.net']);

  final linkRegex = RegExp(r"""'robotlink'\)\.innerHTML = '(.+?)'\+ \('(.+?)'\)""");

  @override
  Stream<LinkResponse> extract(String url, {Map<String, String>? headers}) async* {
    final Response urlResponse = await simpleGet(url, headers: headers);
    urlResponse.raiseForStatus();
    final String responseBody = urlResponse.body;
    final RegExpMatch? regExpMatch = linkRegex.firstMatch(responseBody);

    if (regExpMatch == null) {
      return;
    }

    final String directUrl = 'https:${regExpMatch[1]! + regExpMatch[2]!.substring(3)}';

    yield LinkResponse(directUrl, url, '', MediaQuality.unknown,  title: name);
  }
}

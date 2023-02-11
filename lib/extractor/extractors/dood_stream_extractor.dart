import 'package:http/http.dart';
import 'package:viddroid_flutter_desktop/constants.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';
import 'package:viddroid_flutter_desktop/util/capsules/media.dart';

import '../extractor.dart';

class DoodStreamExtractor extends Extractor {
  DoodStreamExtractor()
      : super('DoodStream', 'https://dood.la', 'https://dood.la', altUrls: [
          'https://dood.wf',
          'https://dood.cx',
          'https://dood.sh',
          'https://dood.watch',
          'https://dood.pm',
          'https://dood.to',
          'https://dood.si',
          'https://dood.ws',
          'https://dood.re',
        ]);

  @override
  Stream<LinkResponse> extract(String url, {Map<String, String>? headers}) async* {
    final Response response = await simpleGet(url);
    //response.raiseForStatus();
    final String body = response.body;

    final RegExp md5Regex = RegExp(r"/pass_md5/[^']*");
    final String? md5 = md5Regex.stringMatch(body);

    if (md5 != null) {
      final Response md5Resp = await simpleGet('$mainUrl$md5', headers: {'referer': url});
      final String mediaUrl =
          '${md5Resp.body}zUEJeL3mUN?token=${md5.substring(md5.lastIndexOf('/'))}';
      //TODO: Media quality
      const MediaQuality mediaQuality = MediaQuality.unknown;

      yield LinkResponse(mediaUrl, mainUrl, '', mediaQuality, title: name);
    }
  }
}

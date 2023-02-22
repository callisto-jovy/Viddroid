import 'package:dio/dio.dart';
import 'package:viddroid_flutter_desktop/constants.dart';
import 'package:viddroid_flutter_desktop/extractor/extractor.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';
import 'package:viddroid_flutter_desktop/util/capsules/media.dart';
import 'package:viddroid_flutter_desktop/util/extraction/js_packer.dart';

class MixDropExtractor extends Extractor {
  MixDropExtractor()
      : super('MixDrop', 'https://mixdrop.co', 'https://mixdrop.co',
            altUrls: ['https://mixdrop.bz', 'https://mixdrop.ch', 'https://mixdrop.to']);

  final srcRegex = RegExp(r"""wurl.*?=.*?"(.*?)";""");

  @override
  Stream<LinkResponse> extract(String url, {Map<String, String>? headers}) async* {
    final Response response = await simpleGet(url, headers: headers);

    final String packedBody = response.data;
    final String? unpackedBody = JSPacker(packedBody).unpack();
    if (unpackedBody == null) {
      return;
    }

    final String? stringMatch = srcRegex.firstMatch(unpackedBody)?.group(1);
    if (stringMatch == null) {
      return;
    }

    yield LinkResponse(stringMatch, url, '', MediaQuality.unknown, title: name);
  }
}

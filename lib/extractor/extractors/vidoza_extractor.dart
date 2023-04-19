import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:viddroid/constants.dart';
import 'package:viddroid/extractor/extractor.dart';
import 'package:viddroid/util/capsules/link.dart';
import 'package:viddroid/util/capsules/media.dart';

class VidozaExtractor extends Extractor {
  VidozaExtractor() : super('Vidoza', 'https://vidoza.net', 'https://vidoza.net');

  @override
  Stream<LinkResponse> extract(String url, {Map<String, String>? headers}) async* {
    final Response<String> response =
        await simpleGet(url, headers: headers, responseType: ResponseType.plain);

    if (response.data == null) {
      return;
    }

    final Document document = parse(response.data);
    final String? source = document.querySelector('#player > source')?.attributes['src'];
    final RegExp qualityRegex = RegExp(r'window\.pData(?:.|\n)+(?<=height: ?")([^"]+)');

    if (source != null) {
      yield LinkResponse(source, url, '',
          MediaQualityExtension.fromString(qualityRegex.firstMatch(response.data!)?[1]));
    }
  }
}

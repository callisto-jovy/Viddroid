import 'package:viddroid_flutter_desktop/extractor/extractor.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';

class MixDropExtractor extends Extractor {

  MixDropExtractor(): super('MixDrop', 'https://mixdrop.co', 'https://mixdrop.co', altUrls: [
    'https://mixdrop.bz',
    'https://mixdrop.ch',
    'https://mixdrop.to'
  ]);

  final srcRegex = RegExp(r"""wurl.*?=.*?"(.*?)";""");


  @override
  Stream<LinkResponse> extract(String url, {Map<String, String>? headers}) {
    // TODO: implement extract
    throw UnimplementedError();
  }

}
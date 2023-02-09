import 'package:viddroid_flutter_desktop/extractor/extractor.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';

class GomoExtractor extends Extractor {
  GomoExtractor() : super('Gomo', 'https://gomo.to', 'https://gomo.to');

  @override
  Stream<LinkResponse> extract(String url, {Map<String, String>? headers}) async* {}
}

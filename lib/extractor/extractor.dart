import '../util/link.dart';

abstract class Extractor {
  final String name;
  final String mainUrl;
  final String url;
  final Map<String, String>? headers;

  Extractor(this.name, this.mainUrl, this.url, {this.headers});

  Stream<LinkResponse> extract(final String url, {final Map<String, String>? headers});
}

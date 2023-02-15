import 'package:viddroid_flutter_desktop/util/capsules/link.dart';
import 'package:viddroid_flutter_desktop/util/download/hls_downloader.dart';

abstract class Downloader {

  final LinkResponse url;
  final String fileName;

  Downloader(this.url, {required this.fileName});

  Future<void> download();
}

class Downloaders {
  Downloader? getDownloader(final LinkResponse linkResponse) {
    //Figure out the appropriate downloader.

    return HLSDownloader(linkResponse, fileName: 'Test file');
  }
}

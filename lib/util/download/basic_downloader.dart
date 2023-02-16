import 'package:dio/dio.dart';
import 'package:viddroid_flutter_desktop/util/download/downloader.dart';

class BasicDownloader extends Downloader {
  BasicDownloader(super.url, {required super.filePath});

  @override
  Future<void> download(Function(int) progressCallback) async {
    //Simply download the mpv file.
    Dio().download(
      url.url,
      '$filePath.mp4',
      options: Options(
        headers: url.header,
      ),
      onReceiveProgress: (count, total) {
        progressCallback(((count / total) * 100).toInt());
      },
    );
    //print(await FileSaver.instance.saveFile(fileName, response.bodyBytes, 'mp4'));
  }
}

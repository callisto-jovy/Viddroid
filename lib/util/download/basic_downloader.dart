
import 'package:dio/dio.dart';
import 'package:viddroid_flutter_desktop/util/download/downloader.dart';

class BasicDownloader extends Downloader {

  BasicDownloader(super.url, {required super.fileName});

  @override
  Future<void> download() async {
    //Simply download the mpv file.
    Dio().download(url.url, 'out.mp4', onReceiveProgress: (count, total) {
      print('$count / $total');
    },);
    //print(await FileSaver.instance.saveFile(fileName, response.bodyBytes, 'mp4'));
  }
}

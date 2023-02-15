import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:jovial_misc/io_utils.dart';
import 'package:pointycastle/export.dart'; // Only for Cipher*Stream
import 'package:viddroid_flutter_desktop/constants.dart';
import 'package:viddroid_flutter_desktop/util/download/downloader.dart';
import 'package:viddroid_flutter_desktop/util/hls/hls_util.dart';

class HLSDownloader extends Downloader {
  HLSDownloader(super.url, {required super.fileName});

  @override
  Future<void> download() async {
    final HLSScanner scanner =
        HLSScanner(url.url, headers: {...?url.header, 'referer': url.referer});
    await scanner.scan();

    if (scanner.encMethod != null && scanner.encKey != null) {
      //TODO: Key not from url (not supported by any players, therefore low priority)

      final List<int> key = await simpleGet(scanner.encKey!,
              headers: {...?url.header, 'referer': url.referer}, responseType: ResponseType.bytes)
          .then((value) => value.data);

      //Download the segments, with a custom input stream

      final String str = scanner.content.first;

      // for (final String str in scanner.content) {
      final Response<ResponseBody> response = await simpleGet(str,
          headers: {...?url.header, 'referer': url.referer}, responseType: ResponseType.stream);

      //TODO: Add iv support
      final BlockCipher blockCipher = BlockCipher('AES/CBC')
        ..init(false, Para(KeyParameter(Uint8List.fromList(key)), Uint8List(0)));

      final Padding padding = Padding('PKCS7')..init();

      if (response.data != null) {
        final DecryptingStream dataInputStream =
            DecryptingStream(blockCipher, response.data!.stream, padding);

        final File file = File('0.ts');
        final IOSink ioSink = file.openWrite();
        final DataOutputSink out = DataOutputSink(ioSink);
        dataInputStream.listen((value) {
          out.writeBytes(value);
        });
        out.close();
        await ioSink.done;
      }
      // }
    }
  }
}

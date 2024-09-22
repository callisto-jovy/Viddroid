import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:pointycastle/export.dart'; // Only for Cipher*Stream
import 'package:viddroid/constants.dart';
import 'package:viddroid/util/download/downloader.dart';
import 'package:viddroid/util/extensions/string_extension.dart';
import 'package:viddroid/util/hls/hls_util.dart';

import '../file/file_util.dart';

class HLSDownloader extends Downloader {
  HLSDownloader(super.url, {required super.filePath});

  @override
  Future<void> download(Function(int) progressCallback) async {
    final Map<String, String> headers = {...?url.header, 'referer': url.referer};

    final HLSScanner scanner = HLSScanner(url.url, headers: headers);
    await scanner.scan();

    final int totalSegments = scanner.segments.length;

    final bool isEncrypted = scanner.encMethod != null && scanner.encKeyUri != null;

    BlockCipher? aesCipher;
    Padding? padding;

    if (isEncrypted) {
      //TODO: Key not from url (not supported by any players, therefore low priority)

      final Uint8List key = await simpleGet(scanner.encKeyUri!, headers: headers, responseType: ResponseType.bytes).then((value) => value.data);

      final Uint8List iv = scanner.encIv?.hexToUint8List ?? Uint8List(16);

      if (key.isEmpty) {
        return Future.error('Could not get encryption key from url.');
      }

      aesCipher = BlockCipher('AES/CBC')..init(false, ParametersWithIV(KeyParameter(key), iv));
      padding = Padding('PKCS7')..init();
    }

    final File outFile = File('$filePath.mp4');
    final IOSink ioSink = outFile.openWrite(mode: FileMode.writeOnlyAppend);

    for (int i = 0; i < totalSegments; i++) {
      final String url = scanner.segments[i];
      if (url.isEmpty) {
        continue;
      }
      try {
        if (isEncrypted) {
          await writeFromEncryptedStreamToStream(
            ioSink,
            url: url,
            blockCipher: aesCipher!, //The ciphers will be non-null
            padding: padding!,
            headers: headers,
          );
        } else {
          await writeFromStreamToStream(
            ioSink,
            url: url,
            headers: headers,
          );
        }
      } catch (e, s) {
        logger.e('An error occurred while downloading a HLS segment', error: e, stackTrace: s);
        continue;
      }
      progressCallback.call(((i / totalSegments) * 100).toInt());
    }
    await ioSink.flush();
    await ioSink.close();
    progressCallback.call(100);
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:pointycastle/export.dart'; // Only for Cipher*Stream
import 'package:viddroid_flutter_desktop/constants.dart';
import 'package:viddroid_flutter_desktop/util/download/downloader.dart';
import 'package:viddroid_flutter_desktop/util/hls/hls_util.dart';

import '../extensions/string_extension.dart';
import '../file/file_util.dart';

class HLSDownloader extends Downloader {
  HLSDownloader(super.url, {required super.filePath});

  @override
  Future<void> download(Function(int) progressCallback) async {
    final Map<String, String> headers = {...?url.header, 'referer': url.referer};

    final HLSScanner scanner = HLSScanner(url.url, headers: headers);
    await scanner.scan();

    if (scanner.encMethod != null && scanner.encKey != null) {
      //TODO: Key not from url (not supported by any players, therefore low priority)

      final Uint8List key =
          await simpleGet(scanner.encKey!, headers: headers, responseType: ResponseType.bytes)
              .then((value) => value.data);

      if (key.isEmpty) {
        return Future.error('Could not get encryption key from url.');
      }

      //TODO: Add iv support
      final BlockCipher aesCipher = BlockCipher('AES/CBC')
        ..init(false, ParametersWithIV(KeyParameter(key), Uint8List(16)));
      final Padding padding = Padding('PKCS7')..init();

      final int totalSegments = scanner.segments.length;

      final Directory tempDirectory = Directory(filePath)..createSync();

      // final File outFile = File('$filePath.mp4');
      //    final IOSink ioSink = outFile.openWrite();
      // final DataOutputSink dataOutputSink = DataOutputSink(ioSink);

      for (int i = 0; i < totalSegments; i++) {
        final String url = scanner.segments[i];
        print('Streaming $url');
        if (url.isEmpty || !Uri.parse(url).isAbsolute) {
          continue; //Skip invalid urls //TODO: Move to hls parser
        }

        //TODO: Handle errors
        await writeFromEncryptedStream(
          '$filePath/$i',
          'ts',
          url: url,
          blockCipher: aesCipher,
          padding: padding,
          headers: headers,
        );
        progressCallback.call(((i / totalSegments) * 100).toInt());
      }

      final File outFile = File('$filePath.mp4');

      final List<FileSystemEntity> files = tempDirectory.listSync()
        ..sort((a, b) =>
            int.parse(a.path.getFileNameFromPath).compareTo(int.parse(b.path.getFileNameFromPath)));

      final IOSink ioSink = outFile.openWrite(mode: FileMode.writeOnlyAppend);

      for (FileSystemEntity fileSystemEntity in files) {
        print(fileSystemEntity.path);
        final File currentFile = File(fileSystemEntity.path);
        await ioSink.addStream(currentFile.openRead());
        //  await currentFile.delete();
      }
      await ioSink.close();
      progressCallback.call(100);

      print('Done downloading');
      //Merge files.

      //  await ioSink.close();
      //  await ioSink.done;
    }
  }
}

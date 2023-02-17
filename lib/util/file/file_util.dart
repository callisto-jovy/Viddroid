import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:jovial_misc/io_utils.dart';
import 'package:pointycastle/export.dart';

import '../../constants.dart'; // Only for Cipher*Stream

Future<bool> writeFromEncryptedStream(
  final String filePath,
  final String fileSuffix, {
  final Directory? directory,
  required String url,
  required BlockCipher blockCipher,
  required Padding padding,
  final Map<String, String>? headers,
}) async {
  final Completer<bool> completer = Completer<bool>();

  final Response<ResponseBody> response =
      await simpleGet(url, headers: headers, responseType: ResponseType.stream);

  if (response.data == null) {
    return Future.error('Could not request data-stream from url $url');
  }

  final DecryptingStream dataInputStream =
      DecryptingStream(blockCipher, response.data!.stream, padding);

  final File file = File('$filePath.$fileSuffix');
  final IOSink ioSink = file.openWrite();
  final DataOutputSink out = DataOutputSink(ioSink);

  dataInputStream.listen(
    (value) {
      out.writeBytes(value);
    },
    onDone: () async {
      await ioSink.flush();
      await ioSink.close();
      completer.complete(true);
    },
  );

  return completer.future;
}

Future<bool> writeFromEncryptedStreamToStream(
  final IOSink outputSink, {
  required String url,
  required BlockCipher blockCipher,
  required Padding padding,
  final Map<String, String>? headers,
}) async {
  final Completer<bool> completer = Completer<bool>();

  final Response<ResponseBody> response =
      await simpleGet(url, headers: headers, responseType: ResponseType.stream);

  if (response.data == null) {
    return Future.error('Could not request data-stream from url $url');
  }

  final DecryptingStream dataInputStream =
      DecryptingStream(blockCipher, response.data!.stream, padding);

  dataInputStream.listen(
    (value) {
      outputSink.add(value);
    },
    onDone: () {
      completer.complete(true);
    },
  );
  return completer.future;
}

Future<bool> writeFromStreamToStream(
  final IOSink outputSink, {
  required String url,
  final Map<String, String>? headers,
}) async {
  final Completer<bool> completer = Completer<bool>();

  final Response<ResponseBody> response =
      await simpleGet(url, headers: headers, responseType: ResponseType.stream);

  if (response.data == null) {
    return Future.error('Could not request data-stream from url $url');
  }

  response.data!.stream.listen(
    (value) {
      outputSink.add(value);
    },
    onDone: () {
      completer.complete(true);
    },
  );
  return completer.future;
}

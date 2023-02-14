import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:viddroid_flutter_desktop/constants.dart';
import 'package:viddroid_flutter_desktop/extractor/extractor.dart';
import 'package:viddroid_flutter_desktop/util/capsules/link.dart';
import 'package:viddroid_flutter_desktop/util/capsules/media.dart';

///Credit partly to: https://github.com/recloudstream/cloudstream-extensions/blob/master/SflixProvider/src/main/kotlin/com/lagradost/SflixProvider.kt
class DokiCloudExtractor extends Extractor {
  DokiCloudExtractor() : super('DokiCloud', 'https://dokicloud.one', 'https://dokicloud.one');

  @override
  Stream<LinkResponse> extract(String url, {Map<String, String>? headers}) async* {
    //link: https://dokicloud.one/embed-4/ECvh21Qkfdo0?z= --> /embed-4
    final int lastSlash = url.lastIndexOf('/');
    final String baseIframeUrl = url.substring(url.lastIndexOf('/', lastSlash - 1), lastSlash);
    final String baseIframeId = url.substring(url.lastIndexOf('/') + 1, url.lastIndexOf('?'));

    final String apiUrl = '$mainUrl/ajax$baseIframeUrl/getSources?id=$baseIframeId';

    final Response response = await simpleGet(apiUrl, headers: {
      'referer': url,
      'X-Requested-With': 'XMLHttpRequest',
      'Accept': '*/*',
      'Accept-Language': 'en-US,en;q=0.5',
      'Connection': 'keep-alive',
      'TE': 'trailers'
    });

    //response.raiseForStatus();

    final dynamic sources = response.data['sources'];
    if (sources == null) {
      return;
    }

    if (sources is String) {
      print(sources);
      final String decrypted = _decrypt(sources, await _getKey());
      final dynamic decryptedJson = decrypted;
      for (int i = 0; i < decryptedJson.length; i++) {
        final dynamic entry = decryptedJson[i];
        final String url = entry['file'];

        yield LinkResponse(url, mainUrl, '', MediaQuality.unknown, title: name);
      }
    } else {
      for (dynamic s in sources) {
        //TODO: Fetch from url
        if (s is Map) {
          print(s);
          yield LinkResponse(s['file'], mainUrl, '', MediaQuality.unknown, title: name);
        } else {
        }
      }
    }
  }

  Future<String> _getKey() =>
      simpleGet('https://raw.githubusercontent.com/consumet/rapidclown/rabbitstream/key.txt')
          .then((value) => value.data);

  String _decrypt(final String input, final String key) {
    final Uint8List base64Input = base64Decode(input);
    final Uint8List keyBytes = _generateKey(base64Input.sublist(8, 16), utf8.encode(key));

    final Encrypter encrypter = Encrypter(AES(
      Key(keyBytes.sublist(0, 32)),
      mode: AESMode.cbc,
    ));

    final Encrypted encrypted = Encrypted(base64Input.sublist(16));
    final IV iv = IV(keyBytes.sublist(32));

    return encrypter.decrypt(encrypted, iv: iv);
  }

  List<int> _generateMd5(List<int> input) {
    return md5.convert(input).bytes;
  }

  Uint8List _generateKey(List<int> salt, List<int> secret) {
    List<int> key = _generateMd5(secret + salt);
    List<int> currentKey = key;

    while (currentKey.length < 48) {
      key = _generateMd5(key + secret + salt);
      currentKey += key;
    }
    //Expensive operation.
    return Uint8List.fromList(currentKey);
  }
}

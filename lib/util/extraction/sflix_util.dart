import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import 'package:encrypt/encrypt.dart';

String decrypt(final String input, final String key) {
  final Uint8List base64Input = base64Decode(input);
  final Uint8List keyBytes = _generateKey(base64Input.sublist(8, 16), utf8.encode(key));

  final Encrypter encrypter = Encrypter(AES(
    Key(keyBytes.sublist(0, 32)),
    mode: AESMode.cbc,
    padding: "PKCS7"
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
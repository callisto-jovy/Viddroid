import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

extension StringExtension on String {
  String get extractMainUrl {
    final String origin = Uri.parse(this).origin;

    return origin;
  }

  String get getFileNameFromPath {
    return substring(lastIndexOf('\\') + 1, lastIndexOf('.'));
  }

  /// Very basic!
  String get cleanWindows {
    return replaceAll("[\\*/\\\\!\\|:?<>]", "_").replaceAll("(%22)", "_");
  }

  String get toMD5 {
    return md5.convert(utf8.encode(this)).toString();
  }

  /// Taken from: https://pub.dev/documentation/eosdart/latest/eosdart/hexToUint8List.html
  Uint8List get hexToUint8List {
    if (length % 2 != 0) {
      throw 'Odd number of hex digits';
    }
    var l = length ~/ 2;
    var result = new Uint8List(l);
    for (var i = 0; i < l; ++i) {
      var x = int.parse(substring(i * 2, (2 * (i + 1))), radix: 16);
      if (x.isNaN) {
        throw 'Expected hex string';
      }
      result[i] = x;
    }
    return result;
  }
}

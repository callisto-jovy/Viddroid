import 'dart:convert';

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
}

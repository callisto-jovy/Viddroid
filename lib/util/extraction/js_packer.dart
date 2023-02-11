import 'dart:math';

/// A JSPacker.
/// Taken from: https://github.com/thitlwincoder/js_packer/blob/master/lib/js_packer.dart
/// As this library is very simple in its functionality, I decided to just take the corresponding code.
/// The library has no future updates in sight, it therefore is not necessary, to list it as a dependency.
class JSPacker {
  /// get js code
  final String packedJS;

  JSPacker(this.packedJS);

  /// detect code has match
  bool detect() {
    final js = packedJS.replaceAll(' ', '');
    final exp = RegExp('eval\\(function\\(p,a,c,k,e,(?:r|d)');
    return exp.hasMatch(js);
  }

  /// change code to value
  String? unpack() {
    try {
      /// pattern
      var exp = RegExp(
        "\\}\\s*\\('(.*)',\\s*(.*?),\\s*(\\d+),\\s*'(.*?)'\\.split\\('\\|'\\)",
        dotAll: true,
      );

      /// get value from elementAt 0
      var matches = exp.allMatches(packedJS).elementAt(0);

      /// if group count is 4
      if (matches.groupCount == 4) {
        /// get value with group
        var payload = matches.group(1)!.replaceAll("\\'", "'");
        final radixStr = matches.group(2);
        final countStr = matches.group(3);
        final sym = matches.group(4)!.split('\|');

        /// initial value
        int radix;
        int count;

        /// set radix value
        try {
          radix = int.parse(radixStr!);
        } catch (_) {
          radix = 36;
        }

        /// set count value
        try {
          count = int.parse(countStr!);
        } catch (_) {
          count = 0;
        }

        /// error condition
        if (sym.length != count) {
          throw Exception('Unknown p.a.c.k.e.r. encoding');
        }

        /// call UnBase class
        final unBase = UnBase(radix);

        /// Pattern
        exp = RegExp('\\b\\w+\\b');

        /// get value from elementAt 0
        matches = exp.allMatches(payload).elementAt(0);

        /// initial value
        var replaceOffset = 0;

        /// foreach looping
        exp.allMatches(payload).forEach((element) {
          /// get word from group 0
          final word = element.group(0);

          var value = '';

          /// change code to value
          final x = unBase.unBase(word!);

          /// set value
          if (x < sym.length) {
            value = sym[x];
          }

          if (value.isNotEmpty) {
            payload = payload.replaceRange(element.start + replaceOffset,
                element.end + replaceOffset, value);
            replaceOffset += value.length - word.length;
          }
        });

        /// return result
        return payload;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

/// UnBase Class
class UnBase {
  final String alpha_62 =
      '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final String alpha_95 =
      " !\"#\$%&\\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
  String alphabet = '';
  Map<String, int> dictionary = {};
  int radix = 0;

  UnBase(this.radix) {
    if (radix > 36) {
      if (radix < 62) {
        alphabet = alpha_62.substring(0, radix);
      } else if (radix > 62 && radix < 95) {
        alphabet = alpha_95.substring(0, radix);
      } else if (radix == 62) {
        alphabet = alpha_62;
      } else if (radix == 95) {
        alphabet = alpha_95;
      }

      for (var i = 0; i < alphabet.length; i++) {
        dictionary[alphabet.substring(i, i + 1)] = i;
      }
    }
  }

  /// change code to value
  int unBase(String str) {
    var ret = 0;

    if (alphabet.isEmpty) {
      ret = int.parse(str, radix: radix);
    } else {
      for (var i = 0; i < str.length; i++) {
        ret += pow(radix, i).toInt() *
            dictionary[str.substring(i, i + 1)]!.toInt();
      }
    }
    return ret;
  }
}
/// A JSPacker.
/// Taken from: https://github.com/thitlwincoder/js_packer/blob/master/lib/js_packer.dart & edited by me, because it seems like the original creator had no idea, what he was doint.
/// At any rate, I could've just written this myself if I looked at the implementation beforehand. The original creator just transcribed a Java unpacker (see: https://github.com/cylonu87/JsUnpacker/blob/master/JsUnpacker.java)
/// As this library is very simple in its functionality, I decided to just take the corresponding code.
/// The library has no future updates in sight, it therefore is not necessary, to list it as a dependency.
class JSPacker {
  /// get js code
  final String packedJS;

  JSPacker(this.packedJS);

  /// detect code has match
  bool detect() {
    final js = packedJS.replaceAll(' ', '');
    final exp = RegExp(r'eval\(function\(p,a,c,k,e,[rd]');
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
      RegExpMatch? match = exp.firstMatch(packedJS);

      /// if group count is 4
      if (match != null && match.groupCount == 4) {
        /// get value with group
        final String payload = match.group(1)!.replaceAll("\\'", "'");
        final String radixStr = match.group(2)!;
        final String countStr = match.group(3)!;
        final sym = match.group(4)!.split('|');

        /// initial value
        int radix = 36;
        int count = 0;

        /// set radix value
        try {
          radix = int.parse(radixStr);
        } catch (_) {}

        /// set count value
        try {
          count = int.parse(countStr);
        } catch (_) {}

        /// error condition
        if (sym.length != count) {
          throw Exception('Unknown p.a.c.k.e.r. encoding');
        }

        /// call UnBase class
        final unBase = UnBase(radix);

        exp = RegExp(r'\b\w+\b');

        int replaceOffset = 0;

        String decoded = payload;

        exp.allMatches(payload).forEach((element) {
          final String word = element.group(0)!;
          // print(word);

          /// change code to value
          final x = unBase.unBase(word);

          var value = '';

          /// set value
          if (x < sym.length) {
            value = sym[x];
          }

          if (value.isNotEmpty) {
            decoded = decoded.replaceRange(
                element.start + replaceOffset, element.end + replaceOffset, value);
            replaceOffset += (value.length - word.length);
          }
        });

        /// return result
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

class UnBase {
  static const String alpha_62 = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String alpha_95 =
      " !\"#\$%&\\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

  String? alphabet;
  final Map<String, int> dictionary = {};
  final int radix;

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

      for (var i = 0; i < alphabet!.length; i++) {
        dictionary[alphabet!.substring(i, i + 1)] = i;
      }
    }
  }

  /// The code had to be modified, as the original creator just transcribed java code (see: https://github.com/cylonu87/JsUnpacker/blob/master/JsUnpacker.java)
  /// However, Dart does not automatically use 64 bits for integers. the to int operation causes an integer overflow in certain cases. The original creator apparently had no idea, what he was doing...
  int unBase(String str) {
    BigInt ret = BigInt.zero;

    if (alphabet == null) {
      ret = BigInt.from(int.parse(str, radix: radix));
    } else {
      //Reverse the runes (support utf-16, for future traps)
      final String tmp = String.fromCharCodes(str.runes.toList().reversed);
      for (var i = 0; i < tmp.length; i++) {
        ret += (BigInt.from(radix).pow(i) * BigInt.from(dictionary[tmp.substring(i, i + 1)]!));
      }
    }
    return ret.toInt();
  }
}

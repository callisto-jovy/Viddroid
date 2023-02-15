import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:viddroid_flutter_desktop/constants.dart';

class HLSScanner {
  factory HLSScanner(String url, {Map<String, String>? headers}) {
    return HLSScanner._internal(url, headers: headers);
  }

  final Queue<String> content = Queue();
  final String _mainUrl;
  final Map<String, String>? _headers;

  String? encKey;
  String? encMethod;

  final RegExp regExp = RegExp(r'([A-Z]+)="?([^",]+)');

  HLSScanner._internal(this._mainUrl, {Map<String, String>? headers}) : _headers = headers;

  Future<void> scan() async {
    final List<String> mainLines = await _getLines(_mainUrl);
    await _scanPlaylist(mainLines);

    //Get encryption method and key
    for (final String line in mainLines) {
      if (!line.startsWith('#')) continue;

      final List<String> split = line.split(':');

      if (split.length < 2) {
        continue;
      }

      final String code = split[0];
      final String value = split
          .getRange(1, split.length)
          .join(':'); //Join (needed for urs, as they are split too. Could fix this with a regex.

      switch (code) {
        case '#EXT-X-KEY':
          //set key & method
          final Map<String, String> keyValues = dissectValue(value);
          encMethod = keyValues['METHOD'];
          encKey = keyValues['URI'];
          break;
      }
    }
  }

  Future<void> _scanPlaylist(final lines) async {
    final List<String> contentLines = lines.where((element) => !element.startsWith('#')).toList();

    for (int i = 0; i < contentLines.length; i++) {
      _scanLine(contentLines[i]);
    }
  }

  void _scanLine(final String line) async {
    final LineType lineType = _determineLineType(line);

    if (lineType == LineType.ts) {
      content.add(line);
    } else {
      final List<String> lines = await _getLines(line);
      _scanPlaylist(lines);
    }
  }

  Future<List<String>> _getLines(final String url) async {
    final Response response =
        await simpleGet(url, headers: _headers, responseType: ResponseType.plain);
    final List<String> lines = response.data.split('\n');
    return lines;
  }

  //Very basic for now..
  Map<String, String> dissectValue(final String value) {
    final Map<String, String> map = {};

    regExp.allMatches(value).forEach((element) {
      map[element[1]!] = element[2]!;
    });

    /*


    int last = 0;
    bool isEscaped = false;

    String currentKey = '';
    String currentValue = '';

    for (int i = 0; i < value.length; i++) {
      final String char = value[i];
      if (char == '\\') {
        continue;
      }
      if (char == '"') {
        isEscaped = !isEscaped;
      } 
      if(!isEscaped) {
        if (char == ',') {
          map[currentKey] = currentValue;
        } else if(char == '=') {
          currentKey = value.substring(last, i - 1);
          currentValue = value.substring(i + 1, value.indexOf(''))
          
          last = i;
        }
      }
    }
    */
    return map;
  }

  LineType _determineLineType(final String line) {
    final String extension = line.substring(line.lastIndexOf('.') + 1);

    switch (extension) {
      case 'm3u8':
        return LineType.playlist;

      default:
        return LineType.ts;
    }
  }
}

enum LineType { ts, playlist, unknown }

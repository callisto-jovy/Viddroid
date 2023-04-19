import 'package:dio/dio.dart';
import 'package:viddroid/constants.dart';

class HLSScanner {
  factory HLSScanner(String url, {Map<String, String>? headers}) {
    return HLSScanner._internal(url, headers: headers);
  }

  final List<String> segments = [];
  final String _mainUrl;
  final Map<String, String>? _headers;
  final Map<String, String> resolutions = {};

  final Map<String, dynamic> values =
      {}; // Will be used in the near future to store values in a more versatile way.

  String? encKeyUri;
  String? encMethod;
  String? encIv;

  final RegExp keyValueExp = RegExp(r'([A-Z]+)="?([^",]+)');

  HLSScanner._internal(this._mainUrl, {Map<String, String>? headers}) : _headers = headers;

  Future<void> scan() async {
    final List<String> mainLines = await _getLines(_mainUrl);

    for (int i = 0; i < mainLines.length; i++) {
      final String line = mainLines[i];

      final List<String> split = line.split(':');

      if (split.length < 2) {
        continue;
      }

      final String code = split[0];
      final String value = split
          .getRange(1, split.length)
          .join(':'); //Join (needed for urs, as they are split too. Could fix this with a regex.

      //TODO: Substring prefix
      switch (code) {
        case '#EXT-X-KEY':
          //set key & method
          final Map<String, String> keyValues = dissectValue(value);
          encMethod = keyValues['METHOD'];
          encKeyUri = keyValues['URI'];
          encIv = keyValues['IV'];
          break;
        case '#EXT-X-STREAM-INF':
          final Map<String, String> keyValues = dissectValue(value);
          final String? resolution = keyValues['RESOLUTION'];
          if (resolution != null) {
            resolutions[resolution] = mainLines[i + 1];
          }
          break;
      }
    }

    //if there are resolutions, choose the highest one. (TODO: maybe later on a fully-fledged selection)
    if (resolutions.isNotEmpty) {
      int maxResolution = 0;
      String maxRes = '';
      for (final String key in resolutions.keys) {
        final int res = int.parse(key.replaceAll('x', ''));
        if (res > maxResolution) {
          maxResolution = res;
          maxRes = key;
        }
      }

      final String? url = resolutions[maxRes];
      if (url != null) {
        final List<String> mainLines = await _getLines(url);
        await _scanPlaylist(mainLines, url);
      }
    } else {
      await _scanPlaylist(mainLines, _mainUrl);
    }
  }

  Future<void> _scanPlaylist(final lines, final String relativeUrl) async {
    final List<String> contentLines = lines.where((element) => !element.startsWith('#')).toList();

    for (int i = 0; i < contentLines.length; i++) {
      _scanLine(contentLines[i], relativeUrl);
    }
  }

  void _scanLine(final String line, final String relativeUrl) async {
    final LineType lineType = _determineLineType(line);
    if (line.isEmpty) {
      return;
    }

    if (lineType == LineType.ts) {
      //Figure out whether the linepath is relative
      if (!line.startsWith('https://') && line.substring(line.lastIndexOf('.')).isNotEmpty) {
        //Add the url path
        final String path = relativeUrl.substring(0, relativeUrl.lastIndexOf('/'));
        segments.add('$path/$line');
      } else {
        segments.add(line);
      }
    } else {
      final List<String> lines = await _getLines(line);
      _scanPlaylist(lines, relativeUrl);
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

    keyValueExp.allMatches(value).forEach((element) {
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

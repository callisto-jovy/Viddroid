import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:viddroid_flutter_desktop/provider/provider.dart';
import 'package:viddroid_flutter_desktop/provider/providers/movies_co.dart';

const String userAgent =
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36";

Future<Response> simpleGet(String url, {Map<String, String>? headers}) =>
    http.get(Uri.parse(url), headers: {...?headers, 'User-Agent': userAgent});


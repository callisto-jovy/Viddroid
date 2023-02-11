import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:requests/requests.dart';
import 'package:viddroid_flutter_desktop/util/network/interceptor.dart';

const String userAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';

const String defaultDownloadDirectory = 'download';

//While the default http package raises cloudflare's protection, Requests does not. I have to look into this some time.
Future<Response> simpleGet(String url, {Map<String, String>? headers, Interceptor? interceptor}) =>
    Requests.get(url, headers: {...?headers, 'User-Agent': userAgent}, );

Future<Response> simplePost(String url, Object? body, {Map<String, String>? headers}) =>
    http.post(Uri.parse(url), headers: {...?headers, 'User-Agent': userAgent}, body: body);

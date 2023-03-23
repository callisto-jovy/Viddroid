import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:logger/logger.dart';
import 'package:viddroid_flutter_desktop/util/network/plugins/proxy_extension.dart';

/// Global Logger
Logger logger = Logger(
    printer: PrettyPrinter(
  colors: true,
  printTime: true,
  printEmojis: true,
));

/// Default user-agent used for all requests in the project
const String userAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';

/// Base Dio instance with a preconfigured user-agent header
final Dio dio = Dio(BaseOptions(
    headers: {'user-agent': userAgent},
    connectTimeout: const Duration(seconds: 60), //TODO: Make the timeouts adjustable
    receiveTimeout: const Duration(seconds: 60)))
  ..interceptors.add(CookieManager(cookieJar));

/// CookieJar instance for dio
final CookieJar cookieJar = CookieJar();

///
/// [responseType]
Future<Response<T>> simpleGet<T>(final String url,
    {Map<String, String>? headers, ResponseType responseType = ResponseType.json}) {
  return dio.get(url,
      options: Options(
        responseType: responseType,
        headers: headers,
      ));
}

/// "Advanced" get method, which creates a separate dio instance with its own interceptors.
Future<Response<T>> advancedGet<T>(final String url,
    {Map<String, String>? headers,
    Interceptor? interceptor,
    ResponseType responseType = ResponseType.json}) {
  final Dio singleInstance = Dio(BaseOptions(headers: {'User-Agent': userAgent}));
  if (interceptor != null) {
    singleInstance.interceptors.add(interceptor);
  }

  return singleInstance.get(url, options: Options(headers: headers, responseType: responseType));
}

/// Just a simple method to post to a given url, with optional headers
Future<Response> simplePost(String url, Object? body,
        {Map<String, String>? headers, ResponseType responseType = ResponseType.json}) =>
    dio.post(
      url,
      options: Options(headers: {...?headers}, responseType: responseType),
      data: body,
    );

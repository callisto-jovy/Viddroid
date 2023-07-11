import 'dart:io' show Platform;

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logger/logger.dart';
import 'package:viddroid/util/network/plugins/proxy_extension.dart';
import 'package:viddroid/util/setting/settings.dart';

/// [RegExp] for matching proxies with the format IP:port
final RegExp proxyRegex = RegExp(
    r'(([1-9][0-9]{2}|[1-9][0-9]|[1-9])\.([1-9][0-9]|[1-9][0-9]{2}|[0-9]))\.([0-9]|[1-9][0-9]|[1-9][0-9]{2})\.([0-9]|[1-9][0-9]|[1-9][0-9]{2}):([1-9][0-9]{4}|[1-9][0-9]{3}|[1-9][0-9]{2}|[1-9][0-9]|[1-9])');

/// Global [Logger], configured to use colors and a timestamp
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
  ..useProxy(Settings().get(Settings.proxy))
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
  final Dio singleInstance = Dio(BaseOptions(headers: {'User-Agent': userAgent}))
    ..useProxy(Settings().get(Settings.proxy))
    ..interceptors.add(CookieManager(cookieJar));

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


bool get isMobile {
  if (kIsWeb) {
    return false;
  } else {
    return Platform.isIOS || Platform.isAndroid;
  }
}

bool get isDesktop {
  if (kIsWeb) {
    return false;
  } else {
    return Platform.isLinux || Platform.isFuchsia || Platform.isWindows || Platform.isMacOS;
  }
}

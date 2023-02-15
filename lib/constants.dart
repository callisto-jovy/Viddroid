import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

const String userAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';

final Dio dio = Dio(BaseOptions(headers: {'User-Agent': userAgent}));

final CookieJar cookieJar = CookieJar();

void addCookieJar() {
  dio.interceptors.add(CookieManager(cookieJar));
}

void addInterceptor(final Interceptor interceptor) {
  dio.interceptors.add(interceptor);
}

//While the default http package raises cloudflare's protection, Requests does not. I have to look into this some time.
Future<Response<T>> simpleGet<T>(final String url,
    {Map<String, String>? headers, ResponseType responseType = ResponseType.json}) {
  return dio.get(url,
      options: Options(
        responseType: responseType,
        headers: headers,
      ));
}

Future<Response> advancedGet(final String url,
    {Map<String, String>? headers,
    Interceptor? interceptor,
    ResponseType responseType = ResponseType.json}) {
  final Dio singleInstance = Dio(BaseOptions(headers: {'User-Agent': userAgent}));
  if (interceptor != null) {
    singleInstance.interceptors.add(interceptor);
  }

  return singleInstance.get(url, options: Options(headers: headers, responseType: responseType));
}

Future<Response> simplePost(String url, Object? body, {Map<String, String>? headers}) =>
    dio.post(url, options: Options(headers: {...?headers}), data: body);

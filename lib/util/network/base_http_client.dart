import 'package:http/http.dart' as http;

import 'interceptor.dart';

class BaseHttpClient extends http.BaseClient {
  final Interceptor? interceptor;

  BaseHttpClient({this.interceptor});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (interceptor != null) {
      return interceptor!.intercept(request);
    }
    return request.send();
  }
}

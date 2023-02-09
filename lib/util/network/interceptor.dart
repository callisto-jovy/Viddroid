import 'package:http/http.dart' as http;

abstract class Interceptor {
  Future<http.StreamedResponse> intercept(final http.BaseRequest request);
}

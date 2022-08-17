import 'package:lazy_http_client/lazy_http_client.dart' as lazy;

void main() {
  String googleAuthToken = '';
  var headers = lazy.Headers.gApis(googleAuthToken);
  var httpClient = lazy.HttpClient(headers: headers);
  print(httpClient);
}

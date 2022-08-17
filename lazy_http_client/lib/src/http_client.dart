import 'dart:async';
import 'package:http/http.dart' as http;

/// ### [HttpClient] class
///
/// [headers]: `FutureOr<Map<String, String>>?` type
///
/// Inspired by https://stackoverflow.com/a/56447947/1810391
class HttpClient extends http.BaseClient {
  FutureOr<Map<String, String>>? headers;
  Map<String, String> _headers = {};
  final _client = http.Client();

  HttpClient({this.headers});

  /// Auto apply [headers] to all request
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (headers != null) {
      _headers = (await headers!);
    }
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

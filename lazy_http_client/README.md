Simple http client class that will auto apply specified headers on all request.

## Features

- [HttpClient] - class inspired by https://stackoverflow.com/a/56447947/1810391
- [Headers] - collection header generator for various apis

## Getting started

```sh
flutter pub add lazy_http_client
```

## Usage

Import with `as lazy` as follow:

```dart
import 'package:lazy_http_client/lazy_http_client.dart' as lazy;

void main() {
  String googleAuthToken = '';
  var headers = lazy.Headers.gApis(googleAuthToken);
  var httpClient = lazy.HttpClient(headers: headers);
  /// ...
}
```

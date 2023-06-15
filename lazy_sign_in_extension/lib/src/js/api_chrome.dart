@JS()
library ext_api_chrome;

import 'dart:async';
import 'dart:js_util';
import 'package:js/js.dart';
import 'package:lazy_log/lazy_log.dart' as lazy;

@JS()
@anonymous
class TokenDetails {
  external bool? interactive;
  external List<String>? scopes;
  external factory TokenDetails({
    bool interactive = true,
    List<String>? scopes,
  });
}

@JS()
@anonymous
class GetAuthTokenResult {
  external String? token;
  external List? grantedScopes;
  external factory GetAuthTokenResult({
    String? token,
    List<String>? grantedScopes,
  });
}

@JS('chrome.identity.getAuthToken')
external jsGetAuthToken(TokenDetails details);

@JS('chrome.identity.clearAllCachedAuthTokens')
external jsClearAllCachedAuthTokens();

class ApiChrome {
  List<String>? scopes;

  ApiChrome({this.scopes});

  Future<GetAuthTokenResult> getAuthToken(TokenDetails details) async {
    String debugPrefix = '$runtimeType.identityGetAuthToken()';
    lazy.log(debugPrefix);

    var promise = jsGetAuthToken(details);
    return promiseToFuture(promise);
  }

  Future clearAllCachedAuthTokens() async {
    String debugPrefix = '$runtimeType.clearAllCachedAuthTokens()';
    lazy.log(debugPrefix);

    var promise = jsClearAllCachedAuthTokens();
    return promiseToFuture(promise);
  }
}

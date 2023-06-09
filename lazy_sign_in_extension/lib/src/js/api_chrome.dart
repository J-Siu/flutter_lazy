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
// external jsChromeIdentityGetAuthToken(TokenDetails details, Function callback);
external jsChromeIdentityGetAuthToken(TokenDetails details);

class ApiChrome {
  List<String>? scopes;

  ApiChrome({this.scopes});

  Future<GetAuthTokenResult> identityGetAuthToken(TokenDetails details) async {
    String debugPrefix = '$runtimeType.identityGetAuthToken()';
    lazy.log(debugPrefix);

    lazy.log("$debugPrefix:jsChromeIdentityGetAuthToken:before");
    var promise = jsChromeIdentityGetAuthToken(details);
    lazy.log("$debugPrefix:jsChromeIdentityGetAuthToken:after");

    return promiseToFuture(promise);
  }
}

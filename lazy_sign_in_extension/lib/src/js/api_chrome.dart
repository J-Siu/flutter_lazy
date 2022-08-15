@JS()
library ext_api_chrome;

import 'dart:async';
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
external jsChromeIdentityGetAuthToken(TokenDetails details, Function callback);

class ApiChrome {
  List<String>? scopes;

  ApiChrome({this.scopes});

  /// Change js callback to dart future
  Future identityGetAuthToken(TokenDetails details) async {
    String debugPrefix = '$runtimeType.identityGetAuthToken()';
    lazy.log(debugPrefix);

    Completer c = Completer();

    // Javascript callback with 2 parameters
    callback(String? token, List? scopes) {
      // js cannot assign to class object to callback
      // c.complete(JsGetAuthTokenResult(token: token, grantedScopes: scopes));
      // Create map object directly
      c.complete({'token': token, 'grantedScopes': scopes});
    }

    jsChromeIdentityGetAuthToken(details, allowInterop(callback));

    return c.future;
  }
}

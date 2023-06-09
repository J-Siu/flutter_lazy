// ignore_for_file: non_constant_identifier_names

@JS()
library ext_api_moz;

import 'dart:async';
import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:lazy_log/lazy_log.dart' as lazy;

// Check Firefox browser api
@JS('identity')
external String get jsIdentity;

@JS()
@anonymous
class IdentityDetails {
  external String url;
  external bool? interactive;
  external factory IdentityDetails({
    String url,
    bool? interactive,
  });
}

@JS('browser.identity.getRedirectURL')
external jsGetRedirectUrl();

@JS('browser.identity.launchWebAuthFlow')
external jsLaunchWebAuthFlow(IdentityDetails details);

class ApiMoz {
  List<String> scopes;
  String clientId;
  String authUrl;

  //
  // `https://accounts.google.com/o/oauth2/auth\
  // ?client_id=${CLIENT_ID}\
  // &response_type=token\
  // &redirect_uri=${encodeURIComponent(REDIRECT_URL)}\
  // &scope=${encodeURIComponent(SCOPES.join(' '))}`;

  ApiMoz({
    required this.clientId,
    this.scopes = const ['email'],
    this.authUrl = 'https://accounts.google.com/o/oauth2/auth',
  });

  String get redirectUrl => jsGetRedirectUrl();

  Uri get authUri {
    Map<String, String> query = {
      'client_id': clientId,
      'redirect_uri': Uri.encodeFull(redirectUrl),
      'response_type': 'token',
      'scope': scopes.join(' '),
    };
    return Uri.parse(authUrl).replace(queryParameters: query);
  }

  Future launchWebAuthFlow({bool interactive = false}) async {
    String debugPrefix = '$runtimeType.launchWebAuthFlow()';
    var details = IdentityDetails(
      interactive: interactive,
      url: authUri.toString(),
    );
    lazy.log('$debugPrefix:details:$details');
    var promise = jsLaunchWebAuthFlow(details);
    return promiseToFuture(promise);
  }
}

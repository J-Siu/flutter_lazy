import 'dart:convert';
import 'js/api_chrome.dart';
import 'package:http/http.dart' as http;
import 'package:lazy_log/lazy_log.dart' as lazy;
import 'package:lazy_sign_in/lazy_sign_in.dart';

/// ### Lazy [SignInExtChrome]
/// - Build in listener for account status change, and a [SignInMsg] notifier [msg]
class SignInExtChrome extends SignIn {
  // --- Internal
  String __token = '';
  String _photoUrl = '';
  final ApiChrome _api;

  /// - [clientId]
  ///   - Chrome extension use Google OAuth Chrome Application client Id
  ///   - Chrome extension use client id from manifest.json V3
  ///   - It is NOT use inside [SignInExtChrome], only for interface consistency
  /// - [scopes] : scopes for OAuth signin
  ///   - Default  `['email']` for Google api
  /// - [debugLog] : force print of log message. Default `false`
  SignInExtChrome({
    clientId = '',
    debugLog = false,
    scopes = const ['email'],
  })  : _api = ApiChrome(scopes: scopes),
        super(
          clientId: clientId,
          debugLog: debugLog,
          scopes: scopes,
        ) {
    // #region GSignInExtChrome
    String debugPrefix = '$runtimeType.GSignInExtChrome()';
    assert(clientId.isNotEmpty, '$debugPrefix:clientId cannot be empty');
    assert(Uri.base.scheme == 'chrome-extension', '$debugPrefix:Can only run as Chrome extension.');
    lazy.log('$debugPrefix:uri.base.scheme:${Uri.base.scheme}', forced: debugLog);
    // #endregion
  }

  // --- Output

  /// Return a sign in access [token] or empty string
  @override
  String get token => __token;

  /// Return sign in account avatar url
  @override
  String get photoUrl => _photoUrl;

  /// Always return empty for Chrome extension
  @override
  String get redirectUrl => '';

  /// - Return access [token] if sign-in successful,
  /// - Throw if sign in failed
  @override
  Future signInHandler({
    bool reAuthenticate = true,
    bool suppressErrors = true,
    bool silentOnly = false,
  }) async {
    // #region _signInHandlerBrowserApi
    var debugPrefix = '$runtimeType._signInHandlerBrowserApi()';

    var tokenDetails = TokenDetails(
      interactive: !silentOnly,
      scopes: scopes,
    );
    try {
      // No checking if token is empty or not,
      // just get it again as it should be fast,
      // and trigger login if necessary
      lazy.log('$debugPrefix:', forced: debugLog);
      // authTokenResult = Map{'token': token, 'grantedScopes': scopes}
      var authTokenResult = await _api.identityGetAuthToken(tokenDetails);
      // we only need token
      _token = authTokenResult['token'];
      _photoUrl = await _getPhotoUrl();
      return token;
    } catch (e) {
      lazy.log('$debugPrefix:catch:$e', forced: debugLog);
      throw ('$debugPrefix:$e');
    }
    // #endregion
  }

  /// - [token] return should always be empty
  /// - Throw on sign-out error
  @override
  Future signOutHandler() async {
    var debugPrefix = '$runtimeType.signOutHandler()';
    lazy.log(debugPrefix, forced: debugLog);
    _token = '';
  }

  /// [_token] is for internal use
  /// - Need private setter to trigger [msg]
  set _token(String v) {
    if (__token != v) {
      __token = v;
      if (v.isEmpty) _photoUrl = '';
      msg.value = SignInMsg(token: v);
    }
  }

  /// This is for browserApi
  Future<String> _getPhotoUrl() async {
    String debugPrefix = '$runtimeType.getPhotoUrl()';
    lazy.log(runtimeType);
    if (__token.isNotEmpty) {
      var url = 'https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=$__token';
      try {
        var res = await http.get(Uri.parse(url));
        var userInfo = jsonDecode(res.body);
        lazy.log('$debugPrefix:${userInfo['picture']}');
        return userInfo['picture'] ?? '';
      } catch (e) {
        lazy.log('$debugPrefix:${e.toString()}');
        return '';
      }
    } else {
      return '';
    }
  }
}

import 'dart:convert';
import 'js/api_chrome.dart';
import 'package:http/http.dart' as http;
import 'package:lazy_log/lazy_log.dart' as lazy;
import 'package:lazy_sign_in/lazy_sign_in.dart' as lazy;

/// ### Lazy [SignInExtChrome]
/// - Build in listener for account status change, and a [SignInMsg] notifier [msg]
class SignInExtChrome extends lazy.SignIn {
  // --- Internal
  bool _isSignedIn = false;
  String _token = '';
  String _displayName = '';
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
    assert(Uri.base.scheme == 'chrome-extension',
        '$debugPrefix:Can only run as Chrome extension.');
    lazy.log('$debugPrefix:uri.base.scheme:${Uri.base.scheme}',
        forced: debugLog);
    // #endregion
  }

  // --- Output

  @override
  bool get isAuthorized => true;

  @override
  bool get isSignedIn => _isSignedIn;

  @override
  String get displayName => _displayName;

  /// Return sign in account avatar url
  @override
  String get photoUrl => _photoUrl;

  /// Always return empty for Chrome extension
  @override
  String get redirectUrl => '';

  /// Return a sign in access [token] or empty string
  @override
  String get token => _token;

  /// - Return access [token] if sign-in successful,
  /// - Throw if sign in failed
  @override
  Future signIn({
    bool reAuthenticate = true,
    bool suppressErrors = true,
    bool silentOnly = false,
  }) async {
    // #region _signIn
    var debugPrefix = '$runtimeType.signIn()';

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
      GetAuthTokenResult authTokenResult =
          await _api.identityGetAuthToken(tokenDetails);
      lazy.log('$debugPrefix:authTokenResult:${authTokenResult.toString()}',
          forced: debugLog);
      // we only need token
      _token = authTokenResult.token ?? '';
      _photoUrl = await _getPhotoUrl();
      _isSignedIn = _token.isNotEmpty;
      msg.status = _isSignedIn;
    } catch (e) {
      lazy.log('$debugPrefix:catch:$e', forced: debugLog);
      throw ('$debugPrefix:$e');
    }
    // #endregion
  }

  /// - [token] return should always be empty
  /// - Throw on sign-out error
  @override
  Future signOut() async {
    var debugPrefix = '$runtimeType.signOut()';
    lazy.log(debugPrefix, forced: debugLog);
    _displayName = '';
    _photoUrl = '';
    _token = '';
    _isSignedIn = false;
    msg.status = _isSignedIn;
  }

  @override
  Future<bool> authorize() async {
    var debugPrefix = '$runtimeType.authorize()';
    lazy.log(debugPrefix, forced: debugLog);
    return true;
  }

  /// This is for browserApi
  Future<String> _getPhotoUrl() async {
    String debugPrefix = '$runtimeType._getPhotoUrl()';
    lazy.log(runtimeType);
    if (_token.isNotEmpty) {
      var url =
          "https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=$_token";
      try {
        var res = await http.get(Uri.parse(url));
        var userInfo = jsonDecode(res.body);
        lazy.log('$debugPrefix:${userInfo['picture']}');
        return userInfo['picture'] ?? '';
      } catch (e) {
        lazy.log('$debugPrefix:${e.toString()}');
        return '';
      }
    }
    return '';
  }
}

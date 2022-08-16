import 'dart:convert';
import 'js/api_moz.dart';
import 'package:http/http.dart' as http;
import 'package:lazy_log/lazy_log.dart' as lazy;
import 'package:lazy_sign_in/lazy_sign_in.dart';

/// ### Lazy [SignInExtMoz]
/// - Build in listener for account status change, and a [SignInMsg] notifier [msg]
class SignInExtMoz extends SignIn {
  // --- Internal
  String __token = '';
  String _photoUrl = '';
  final ApiMoz _api;
  //
  DateTime _apiFirefoxSignInTime = DateTime(0);
  int _apiFireFoxSignInDuration = 0; // Seconds before token expire

  /// - [clientId]
  ///   - Moz extension should use Google OAuth Web Application Client Id
  ///   - cannot be empty
  /// - [scopes] : scopes for OAuth signin
  ///   - Default  `['email']` for Google api
  /// - [debugLog] : force print of log message. Default `false`
  SignInExtMoz({
    debugLog = false,
    required clientId,
    scopes = const ['email'],
  })  : _api = ApiMoz(clientId: clientId, scopes: scopes),
        super(
          clientId: clientId,
          debugLog: debugLog,
          scopes: scopes,
        ) {
    // #region GSignIn
    String debugPrefix = '$runtimeType.GSignInExtMoz()';
    assert(clientId.isNotEmpty, '$debugPrefix:clientId cannot be empty');
    assert(Uri.base.scheme == 'moz-extension', 'Must run as moz extension.');
    lazy.log(
        '$debugPrefix:authUri.query:${_api.authUri.queryParametersAll.toString()}',
        forced: debugLog);
    lazy.log('$debugPrefix:authUri:${_api.authUri.toString()}',
        forced: debugLog);
    lazy.log('$debugPrefix:redirectUrl:${_api.redirectUrl}', forced: debugLog);
  }

  // #endregion

  // --- Output

  /// Return a sign in access [token] or empty string
  @override
  String get token => __token;

  @override
  String get photoUrl => _photoUrl;

  /// Return Firefox extension redirect url
  @override
  String get redirectUrl => _api.redirectUrl;

  /// - Return access [token] if sign-in successful,
  /// - Throw if sign in failed
  @override
  Future signInHandler({
    bool reAuthenticate = true,
    bool suppressErrors = true,
    bool silentOnly = false,
  }) async {
    // #region signInHandler
    var debugPrefix = '$runtimeType.signInHandler()';
    lazy.log(debugPrefix, forced: debugLog);

    Duration secondSinceSignIn =
        DateTime.now().toUtc().difference(_apiFirefoxSignInTime);

    if (__token.isEmpty ||
        secondSinceSignIn.inSeconds > (_apiFireFoxSignInDuration - 100)) {
      try {
        String tmpToken = '';
        // https://{redirectUri}/
        //   #access_token={token}
        //   &token_type=Bearer
        //   &expires_in={3599}
        //   &scope={scopes}
        lazy.log('$debugPrefix:_api.launchWebAuthFlow(interactive: false)',
            forced: debugLog);
        dynamic res;
        try {
          res = await _api.launchWebAuthFlow(interactive: false);
          tmpToken = _extractToken(res);
        } catch (e) {
          lazy.log(
              '$debugPrefix:_api.launchWebAuthFlow(interactive: false):catch:$e:Will continue with interaction',
              forced: debugLog);
          tmpToken = '';
        }
        if (tmpToken.isEmpty) {
          lazy.log('$debugPrefix:_api.launchWebAuthFlow(interactive: true)',
              forced: debugLog);
          res = await _api.launchWebAuthFlow(interactive: true);
        }
        lazy.log('$debugPrefix:_api.launchWebAuthFlow():res:$res',
            forced: debugLog);
        _apiFireFoxSignInDuration = _extractExpireIn(res);
        if (_apiFireFoxSignInDuration == 0)
          throw ('Something wrong, cannot get [expire_in].');
        _apiFirefoxSignInTime = DateTime.now().toUtc();
        _token = tmpToken;
        _photoUrl = await _getPhotoUrl();
        return token;
      } catch (e) {
        lazy.log('$debugPrefix:catch:$e', forced: debugLog);
        throw ('$debugPrefix:$e');
      }
    } else {
      return token;
    }
    // #endregion
  }

  /// - [token] return should always be empty
  /// - Throw on sign-out error
  @override
  Future signOutHandler() async {
    // #region signOutHandler
    var debugPrefix = '$runtimeType.signInHandler()';
    lazy.log(debugPrefix);
    _token = '';
    return _token;
    // #endregion
  }

  /// [_token] is for internal use
  /// - Need private setter to trigger [msg]
  String get _token => __token;
  set _token(String v) {
    if (__token != v) {
      __token = v;
      if (v.isEmpty) _photoUrl = '';
      msg.value = SignInMsg(token: v);
    }
  }

  Future<String> _getPhotoUrl() async {
    String debugPrefix = '$runtimeType.getPhotoUrl()';
    lazy.log(runtimeType);
    if (_token.isNotEmpty) {
      var url =
          'https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=$_token';
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

  /// expire time in seconds, have to compare with sign in time
  int _extractExpireIn(String res) {
    var debugPrefix = '$runtimeType._extractTokenExpireApiFirefox()';
    var resUri = Uri.parse(res.replaceAll('#', '?'));
    Map<String, String> resParams = resUri.queryParameters;
    resParams
        .forEach((k, v) => lazy.log('$debugPrefix:$k:$v', forced: debugLog));
    String expire = resParams['expires_in'] ?? '';
    lazy.log('$debugPrefix:expire:$expire', forced: debugLog);
    return int.tryParse(expire) ?? 0;
  }

  String _extractToken(String res) {
    var resUri = Uri.parse(res.replaceAll('#', '?'));
    Map<String, String> resParams = resUri.queryParameters;
    return resParams['access_token'] ?? '';
  }
}

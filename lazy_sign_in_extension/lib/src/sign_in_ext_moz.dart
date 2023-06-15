import 'get_photo_url.dart';
import 'js/api_moz.dart';
import 'package:lazy_extensions/lazy_extensions.dart';
import 'package:lazy_log/lazy_log.dart' as lazy;
import 'package:lazy_sign_in/lazy_sign_in.dart' as lazy;

/// ### Lazy [SignInExtMoz]
/// - Build in listener for account status change, and a [SignInMsg] notifier [msg]
class SignInExtMoz extends lazy.SignIn {
  // --- Internal
  String _displayName = '';
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
    String debugPrefix = '$runtimeType()';
    assert(clientId.isNotEmpty, '$debugPrefix:clientId cannot be empty');
    assert(Uri.base.scheme == 'moz-extension',
        '$debugPrefix: Can only run as Firefox extension.');
    lazy.log('$debugPrefix:uri.base.scheme:${Uri.base.scheme}',
        forced: debugLog);
    lazy.log('$debugPrefix:_api:${_api.jsonPretty()}', forced: debugLog);
  }

  // --- Output

  @override
  String get displayName => _displayName;

  @override
  String get photoUrl => _photoUrl;

  /// Return Firefox extension redirect url
  @override
  String get redirectUrl => _api.redirectUrl;

  /// - Throw if sign in failed
  @override
  Future signIn({
    bool reAuthenticate = false,
    bool suppressErrors = true,
    bool silentOnly = false,
  }) async {
    String debugPrefix = '$runtimeType.signIn()';
    lazy.log(debugPrefix, forced: debugLog);

    // We don't want to keep updating token.value in middle of process
    String tokenTmp = token.value;
    Duration secondSinceSignIn =
        DateTime.now().toUtc().difference(_apiFirefoxSignInTime);

    if (reAuthenticate ||
        token.value.isEmpty ||
        secondSinceSignIn.inSeconds > (_apiFireFoxSignInDuration - 100)) {
      try {
        // https://{redirectUri}/
        //   #access_token={token}
        //   &token_type=Bearer
        //   &expires_in={3599}
        //   &scope={scopes}

        dynamic res;

        if (!reAuthenticate) {
          lazy.log('$debugPrefix:_api.launchWebAuthFlow(interactive: false)',
              forced: debugLog);
          res = await _api.launchWebAuthFlow(interactive: false);
          lazy.log(
              '$debugPrefix:_api.launchWebAuthFlow(interactive: false):res:${res.toString()}',
              forced: debugLog);
          tokenTmp = _extractToken(res);
        }

        if (tokenTmp.isEmpty) {
          lazy.log('$debugPrefix:_api.launchWebAuthFlow(interactive: true)',
              forced: debugLog);
          res = await _api.launchWebAuthFlow(interactive: true);
          lazy.log(
              '$debugPrefix:_api.launchWebAuthFlow(interactive: true):res:${res.toString()}',
              forced: debugLog);
          tokenTmp = _extractToken(res);
        }

        if (_apiFireFoxSignInDuration == 0) {
          _reset();
          throw ('Something wrong, cannot get [expire_in].');
        }

        _apiFirefoxSignInTime = DateTime.now().toUtc();
        _photoUrl = await getPhotoUrl(tokenTmp);
        token.value = tokenTmp;
        isSignedIn.value = true;
      } catch (e) {
        _reset();
        lazy.log('$debugPrefix:catch:$e', forced: debugLog);
        throw ('$debugPrefix:$e');
      }
    }
  }

  @override
  Future signOut() async {
    var debugPrefix = '$runtimeType.signOut()';
    lazy.log(debugPrefix);
    _reset();
  }

  @override
  Future<bool> authorize() async {
    var debugPrefix = '$runtimeType.authorize()';
    lazy.log(debugPrefix, forced: debugLog);
    signIn();
    return true;
  }

  String _extractToken(String res) {
    String debugPrefix = '$runtimeType._extractToken()';
    Uri uri = Uri.parse(res.replaceAll('#', '?'));
    Map<String, String> params = uri.queryParameters;
    lazy.log('$debugPrefix:params:${params.jsonPretty()}', forced: debugLog);

    // expire time in seconds, have to compare with sign in time
    String expire = params['expires_in'] ?? '';
    _apiFireFoxSignInDuration = int.tryParse(expire) ?? 0;

    return params['access_token'] ?? '';
  }

  _reset() {
    _displayName = '';
    _photoUrl = '';
    isSignedIn.value = false;
    token.value = '';
  }
}

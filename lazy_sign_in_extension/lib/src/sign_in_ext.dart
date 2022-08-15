import 'package:lazy_log/lazy_log.dart' as lazy;
import 'package:lazy_sign_in/lazy_sign_in.dart' as lazy;
import 'sign_in_ext_chrome.dart' as lazy;
import 'sign_in_ext_moz.dart' as lazy;

const String _schemeMoz = 'moz-extension';
const String _schemeChrome = 'chrome-extension';

/// ### Lazy [SignInExt]
/// - Build in listener for account status change, and a [SignInMsg] notifier [msg]
/// - Auto detect chrome or firefox extension
class SignInExt extends lazy.SignIn {
  late final lazy.SignIn _api;

  /// - [clientId]
  ///   - Moz extension
  ///     - should use Google OAuth Web Application Client Id
  ///     - cannot be empty
  ///   - Chrome extension
  ///     - use Google OAuth Chrome Application client Id
  ///     - use client id from manifest.json V3
  ///     - [clientId] is NOT use when running as chrome extension, only for interface consistency
  /// - [scopes] : scopes for OAuth signin
  ///   - Default  `['email']` for Google api
  /// - [debugLog] : force print of log message. Default `false`
  SignInExt({
    debugLog = false,
    required clientId,
    scopes = const ['email'],
  }) : super(
          clientId: clientId,
          debugLog: debugLog,
          scopes: scopes,
        ) {
    // #region GSignIn
    String debugPrefix = '$runtimeType.GSignInExtMoz()';
    String scheme = Uri.base.scheme;
    assert(clientId.isNotEmpty, '$debugPrefix:clientId cannot be empty');
    assert(scheme == _schemeChrome || scheme == _schemeMoz, 'Must run as moz extension.');

    if (scheme == _schemeChrome) {
      _api = lazy.SignInExtChrome(clientId: clientId, scopes: scopes);
    }

    if (scheme == _schemeMoz) {
      _api = lazy.SignInExtMoz(clientId: clientId, scopes: scopes);
    }

    // lazy.log('$debugPrefix:authUri.query:${_api.authUri.queryParametersAll.toString()}', forced: debugLog);
    // lazy.log('$debugPrefix:authUri:${_api.authUri.toString()}', forced: debugLog);
    lazy.log('$debugPrefix:redirectUrl:${_api.redirectUrl}', forced: debugLog);
  }

  // #endregion

  // --- Output

  /// Return a sign in access [token] or empty string
  @override
  String get token => _api.token;

  @override
  String get photoUrl => _api.photoUrl;

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

    try {
      return _api.signInHandler(
        reAuthenticate: reAuthenticate,
        suppressErrors: suppressErrors,
        silentOnly: silentOnly,
      );
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
    // #region signOutHandler
    var debugPrefix = '$runtimeType.signInHandler()';
    lazy.log(debugPrefix);
    try {
      return _api.signOutHandler();
    } catch (e) {
      lazy.log('$debugPrefix:catch:$e', forced: debugLog);
      throw ('$debugPrefix:$e');
    }

    // #endregion
  }
}

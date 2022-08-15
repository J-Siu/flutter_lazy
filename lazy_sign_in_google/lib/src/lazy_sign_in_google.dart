import 'package:lazy_sign_in/lazy_sign_in.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lazy_log/lazy_log.dart' as lazy;

/// ### Lazy [SignInGoogle]
/// - Build in listener for account status change, and a [SignInMsg] notifier [msg]
/// - [GoogleSignIn] wrapper class with a [signInHandler]
class SignInGoogle extends SignIn {
  // --- Internal
  String __token = '';
  final GoogleSignIn _api;

  /// - [clientId]
  ///   - use Google OAuth Chrome Application Client Id standalone app
  ///   - use Google OAuth Web Application Client Id for webpage
  ///   - cannot be empty
  /// - [scopes] : scopes for OAuth signin
  ///   - Default  `['email']` for Google api
  /// - [debugLog] : force print of log message. Default `false`
  SignInGoogle({
    debugLog = false,
    required clientId,
    scopes = const ['email'],
  })  : _api = GoogleSignIn(clientId: clientId, scopes: scopes),
        super(
          clientId: clientId,
          debugLog: debugLog,
          scopes: scopes,
        ) {
    // #region GSignIn
    String debugPrefix = '$runtimeType.GSignInGoogleSignIn()';
    assert(clientId.isNotEmpty, '$debugPrefix:clientId cannot be empty');
    lazy.log('$debugPrefix:GoogleSignIn()', forced: debugLog);
    _api.onCurrentUserChanged.listen((_) {
      _extractToken().then((token) => _token = token);
    });
    lazy.log('$debugPrefix:GoogleSignIn().listen():done', forced: debugLog);
    // #endregion
  }

  // --- Output

  /// Return a sign in access [token] or empty string
  @override
  String get token => __token;

  /// Return sign in account avatar url
  @override
  String get photoUrl => _api.currentUser?.photoUrl ?? '';

  /// Always return empty for web/app
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
    // #region signInHandler
    var debugPrefix = '$runtimeType.signInHandler()';
    lazy.log(debugPrefix, forced: debugLog);

    try {
      String tmpToken = '';
      lazy.log('$debugPrefix:_googleSignIn.signInSilently()', forced: debugLog);
      await _api
          .signInSilently(reAuthenticate: reAuthenticate, suppressErrors: suppressErrors)
          .onError((e, _) => throw ('_googleSignIn.signInSilently():$e'));
      tmpToken = await _extractToken();

      // Sign-in silently failed -> try pop-up
      if (tmpToken.isEmpty && !silentOnly) {
        lazy.log('$debugPrefix:_googleSignIn.signIn()', forced: debugLog);
        await _api.signIn().onError((e, _) => throw ('_googleSignIn.signIn():$e'));
        tmpToken = await _extractToken();
      }

      // Sign-in failed -> throw
      if (tmpToken.isEmpty) {
        lazy.log('$debugPrefix:Sign-in failed', forced: debugLog);
        throw ('Sign-in failed');
      }

      _token = tmpToken;
      return token;
    } catch (e) {
      lazy.log('$debugPrefix:catch:$e', forced: debugLog);
      throw '$debugPrefix:catch:$e';
    }
    // #endregion
  }

  /// - [token] return should always be empty
  /// - Throw on sign-out error
  @override
  Future signOutHandler() async {
    // #region signOutHandler
    var debugPrefix = '$runtimeType.signInHandler()';
    try {
      await _api.signOut().onError((e, _) => throw ('_googleSignIn.g=signOut():error:$e'));
    } catch (error) {
      throw '$debugPrefix:catch:$error';
    }
    // #endregion
  }

  /// [_token] is for internal use
  /// - Need private setter to trigger [msg]
  set _token(String v) {
    if (__token != v) {
      __token = v;
      msg.value = SignInMsg(token: v);
    }
  }

  Future<String> _extractToken() async {
    var auth = await _api.currentUser?.authentication;
    return auth?.accessToken ?? '';
  }
}

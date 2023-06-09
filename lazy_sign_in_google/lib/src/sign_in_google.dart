import 'package:lazy_sign_in/lazy_sign_in.dart' as lazy;
import 'package:google_sign_in/google_sign_in.dart' as lazy;
import 'package:lazy_log/lazy_log.dart' as lazy;

/// ### Lazy [SignInGoogle]
/// - Build in listener for account status change, and a [SignInMsg] notifier [msg]
/// - [GoogleSignIn] wrapper class with a [signInHandler]
class SignInGoogle extends lazy.SignIn {
  // --- Internal
  bool _isAuthorized = false;
  bool _isSignedIn = false;
  String _token = '';

  final lazy.GoogleSignIn _api;

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
  })  : _api = lazy.GoogleSignIn(clientId: clientId, scopes: scopes),
        super(
          clientId: clientId,
          debugLog: debugLog,
          scopes: scopes,
        ) {
    // #region GSignIn
    String debugPrefix = '$runtimeType.SignInGoogle()';
    assert(clientId.isNotEmpty, '$debugPrefix:clientId cannot be empty');
    _api.onCurrentUserChanged.listen((_) {
      _isSignedIn = _api.currentUser != null;
      msg.status = _isSignedIn;
    });
    lazy.log('$debugPrefix:GoogleSignIn().listen():done', forced: debugLog);
    // #endregion
  }

  // --- Output

  @override
  bool get isAuthorized => _isAuthorized;

  @override
  bool get isSignedIn => _isSignedIn;

  @override
  String get displayName => _api.currentUser?.displayName ?? '';

  /// Return a sign in access [token] or empty string
  @override
  String get token => _token;

  /// Return sign in account avatar url
  @override
  String get photoUrl => _api.currentUser?.photoUrl ?? '';

  /// Always return empty for web/app
  @override
  String get redirectUrl => '';

  /// - Throw if sign in failed
  @override
  Future signIn({
    bool reAuthenticate = true,
    bool suppressErrors = true,
    bool silentOnly = false,
  }) async {
    // #region signInHandler
    var debugPrefix = '$runtimeType.signInHandler()';
    lazy.log(debugPrefix, forced: debugLog);

    try {
      lazy.log('$debugPrefix:_api.signInSilently()', forced: debugLog);
      await _api
          .signInSilently(
              reAuthenticate: reAuthenticate, suppressErrors: suppressErrors)
          .onError((e, _) => throw ('_api.signInSilently():$e'));

      // Sign-in silently failed -> try pop-up
      if (_api.currentUser == null && !silentOnly) {
        lazy.log('$debugPrefix:_api.signIn()', forced: debugLog);
        await _api.signIn().onError((e, _) => throw ('_api.signIn():$e'));
      }
    } catch (e) {
      throw '$debugPrefix:catch:$e';
    }
    // #endregion
  }

  /// - Throw on sign-out error
  @override
  Future signOut() async {
    // #region signOutHandler
    var debugPrefix = '$runtimeType.signInHandler()';
    try {
      await _api.signOut().onError((e, _) => throw ('_api.signOut():$e'));
    } catch (e) {
      throw '$debugPrefix:catch:$e';
    }
    // #endregion
  }

  @override
  Future<bool> authorize() async {
    var debugPrefix = '$runtimeType.isAuthorized()';
    lazy.log(debugPrefix, forced: debugLog);
    _isAuthorized = await _api.requestScopes(scopes);
    _token = (await _api.currentUser?.authHeaders)?['Authorization'] ?? '';
    _token = _token.replaceAll('Bearer ', '');
    return _isAuthorized;
  }
}

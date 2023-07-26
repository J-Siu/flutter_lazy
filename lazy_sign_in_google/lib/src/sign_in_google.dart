import 'package:google_sign_in/google_sign_in.dart';
import 'package:lazy_log/lazy_log.dart' as lazy;
import 'package:lazy_sign_in/lazy_sign_in.dart' as lazy;

/// ### Lazy [SignInGoogle]
/// - Build in listener for account status change.
/// - A [GoogleSignIn] wrapper class.
class SignInGoogle extends lazy.SignIn {
  final GoogleSignIn _api;

  /// - [clientId]
  ///   - use Google OAuth Chrome Application Client Id standalone app
  ///   - use Google OAuth Web Application Client Id for webpage
  ///   - cannot be empty
  /// - [scopes] : scopes for OAuth signin
  ///   - Default  `['email']` for Google api
  /// - [debugLog] : force print of log message. Default `false`
  SignInGoogle({
    required clientId,
    scopes = const ['email'],
    debugLog = false,
  })  : _api = GoogleSignIn(clientId: clientId, scopes: scopes),
        super(
          clientId: clientId,
          debugLog: debugLog,
          scopes: scopes,
        ) {
    String debugPrefix = '$runtimeType.SignInGoogle()';
    assert(clientId.isNotEmpty, '$debugPrefix:clientId cannot be empty');
    _api.onCurrentUserChanged.listen((account) {
      _apiOnUserChange(account);
    });
    lazy.log('$debugPrefix:GoogleSignIn().listen():done', forced: debugLog);
  }

  // --- Output

  @override
  String get displayName => _api.currentUser?.displayName ?? '';

  /// Return sign in account avatar url
  @override
  String get photoUrl => _api.currentUser?.photoUrl ?? '';

  /// Always return empty for web/app
  @override
  String get redirectUrl => '';

  /// - Throw if sign in failed
  @override
  Future signIn({
    bool reAuthenticate = false,
    bool suppressErrors = true,
    bool silentOnly = false,
  }) async {
    var debugPrefix = '$runtimeType.signIn()';
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
  }

  /// - Throw on sign-out error
  @override
  Future signOut() async {
    var debugPrefix = '$runtimeType.signOut()';
    try {
      await _api.signOut();
    } catch (e) {
      throw '$debugPrefix:catch:$e';
    }
  }

  @override
  Future<bool> authorize() async {
    var debugPrefix = '$runtimeType.isAuthorized()';
    lazy.log(debugPrefix, forced: debugLog);
    bool authorized = await _api.requestScopes(scopes);
    String tokenTmp =
        (await _api.currentUser?.authHeaders)?['Authorization'] ?? '';
    token.value = tokenTmp.replaceAll('Bearer ', '');
    return authorized;
  }

  void _apiOnUserChange(GoogleSignInAccount? account) {
    if (_api.currentUser == null) {
      isSignedIn.value = false;
    } else {
      isSignedIn.value = true;
    }
    // If user change, reauthorize anyway
    token.value = '';
  }
}

import 'get_photo_url.dart';
import 'js/api_chrome.dart';
import 'package:lazy_extensions/lazy_extensions.dart';
import 'package:lazy_log/lazy_log.dart' as lazy;
import 'package:lazy_sign_in/lazy_sign_in.dart' as lazy;

/// ### Lazy [SignInExtChrome]
/// - Build in listener for account status change, and a [SignInMsg] notifier [msg]
class SignInExtChrome extends lazy.SignIn {
  // --- Internal
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
    String debugPrefix = '$runtimeType.GSignInExtChrome()';
    assert(clientId.isNotEmpty, '$debugPrefix:clientId cannot be empty');
    assert(Uri.base.scheme == 'chrome-extension',
        '$debugPrefix: Can only run as Chrome extension.');
    lazy.log('$debugPrefix:uri.base.scheme:${Uri.base.scheme}',
        forced: debugLog);
    lazy.log('$debugPrefix:_api:${_api.jsonPretty()}', forced: debugLog);
  }

  // --- Output

  @override
  String get displayName => _displayName;

  /// Return sign in account avatar url
  @override
  String get photoUrl => _photoUrl;

  /// Always return empty for Chrome extension
  @override
  String get redirectUrl => '';

  /// - [reAuthenticate] has no effect in extension
  /// - Throw if sign in failed
  @override
  Future signIn({
    bool reAuthenticate = false,
    bool suppressErrors = true,
    bool silentOnly = false,
  }) async {
    var debugPrefix = '$runtimeType.signIn()';
    lazy.log('$debugPrefix:', forced: debugLog);

    var tokenDetails = TokenDetails(
      interactive: !silentOnly,
      scopes: scopes,
    );

    try {
      // No checking if token is empty or not,
      // just get it again as it should be fast,
      // and trigger login if necessary

      // authTokenResult = Map{'token': token, 'grantedScopes': scopes}
      GetAuthTokenResult authTokenResult =
          await _api.getAuthToken(tokenDetails);
      lazy.log('$debugPrefix:authTokenResult:${authTokenResult.toString()}',
          forced: debugLog);
      // we only need token
      token.value = authTokenResult.token ?? '';
      _photoUrl = await getPhotoUrl(token.value);
      isSignedIn.value = token.value.isNotEmpty;
    } catch (e) {
      _reset();
      lazy.log('$debugPrefix:catch:$e', forced: debugLog);
      throw ('$debugPrefix:$e');
    }
  }

  /// - [token] return should always be empty
  /// - Throw on sign-out error
  @override
  Future signOut() async {
    var debugPrefix = '$runtimeType.signOut()';
    lazy.log(debugPrefix, forced: debugLog);
    await _api.clearAllCachedAuthTokens();
    _reset();
  }

  @override
  Future<bool> authorize() async {
    var debugPrefix = '$runtimeType.authorize()';
    lazy.log(debugPrefix, forced: debugLog);
    signIn();
    return token.value.isNotEmpty;
  }

  _reset() {
    _displayName = '';
    _photoUrl = '';
    isSignedIn.value = false;
    token.value = '';
  }
}

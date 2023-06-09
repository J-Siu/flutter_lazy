import 'package:lazy_log/lazy_log.dart' as lazy;
import 'package:lazy_sign_in/lazy_sign_in.dart';

/// Dummy implementation of [SignIn]
class SignInDummy extends SignIn {
  /// Dummy implementation of [SignIn]
  SignInDummy({
    clientId = '',
    debugLog = false,
    scopes = const [],
  }) : super(
          clientId: '',
          debugLog: debugLog,
          scopes: scopes,
        ) {
    String debugPrefix = '$runtimeType';
    lazy.log(debugPrefix);
  }

  // --- Output

  /// Dummy implementation, always return false
  @override
  bool get isAuthorized => false;

  /// Dummy implementation, always return false
  @override
  bool get isSignedIn => false;

  /// Dummy implementation, always return ''
  @override
  String get displayName => '';

  /// Dummy implementation, always return ''
  @override
  String get photoUrl => '';

  /// Dummy implementation, always return ''
  @override
  String get redirectUrl => '';

  /// Dummy implementation, always return ''
  @override
  String get token => '';

  /// Dummy implementation, always return ''
  @override
  Future signIn({
    bool reAuthenticate = true,
    bool suppressErrors = true,
    bool silentOnly = false,
  }) async {
    return token;
  }

  /// Dummy implementation, always return ''
  @override
  Future signOut() async {
    return '';
  }

  @override
  Future<bool> authorize() async {
    return false;
  }
}

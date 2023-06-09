import 'dart:async';
import 'is_signed_in.dart';
import 'package:flutter/foundation.dart';

/// ### Lazy [SignIn]
/// - Build in listener for account status change, and a [SignInMsg] notifier [msg]
abstract class SignIn with ChangeNotifier {
  /// [scopes] of sign-in
  final List<String> scopes;

  bool debugLog = true;

  /// - Chrome Extension
  ///   - use Google OAuth **Chrome Application** client id.
  ///   - update OAuth credential app id with extension id
  /// - Firefox Extension
  ///   - use Google OAuth **Web Application** client id.
  ///   - update OAuth credential authorized redirect uri
  ///     this can be obtain by [redirectUrl]
  /// - Web
  ///   - use Google OAuth **Web Application** client id.
  ///   - update OAuth credential authorized javaScript origins
  /// - Standalone App
  ///   - use Google OAuth **Chrome Application** client id.
  ///   - update OAuth credential app id
  final String clientId;

  /// - [clientId]
  ///   - use Google OAuth Web Application Client Id for webpage, moz-extension
  ///   - use Google Oauth Chrome Application Client Id for chrome-extension and standalone app
  ///   - cannot be empty
  /// - [scopes] : scopes for OAuth signin
  ///   - Default  `['email']` for Google api
  /// - [debugLog] : force print of log message. Default `false`
  SignIn({
    required this.clientId,
    this.debugLog = false,
    this.scopes = const ['email'],
  });

  // --- Output

  /// [IsSignIn] notifier. Trigger whenever signin status changes.
  IsSignedIn msg = IsSignedIn();

  bool get isAuthorized;

  bool get isSignedIn;

  /// Return username
  String get displayName;

  /// Return sign in account avatar url
  String get photoUrl;

  /// Return redirectUri(only applicable for extension)
  String get redirectUrl;

  /// Return a sign in access [token] or empty string
  String get token;

  /// - Return access [token] if sign-in successful,
  /// - Return empty if sign in failed
  Future signIn({
    bool reAuthenticate = true,
    bool suppressErrors = true,
    bool silentOnly = false,
  });

  /// - [token] return should always be empty
  Future signOut();

  Future<bool> authorize();
}

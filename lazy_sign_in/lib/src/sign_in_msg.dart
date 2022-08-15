/// ### Lazy [SignInMsg]
/// - [status] == ([token].isNotEmpty)
/// - [token] : access token
class SignInMsg {
  bool get status => (token.isNotEmpty);
  final String token;
  SignInMsg({this.token = ''});
}

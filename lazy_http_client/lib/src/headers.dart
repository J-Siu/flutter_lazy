/// Collection of header generating functions
class Headers {
  /// - [token] : Google OAuth access token
  /// - Return authorization header for Google APIs:
  /// ```dart
  /// Map<String, String>{
  ///   'Authorization': 'Bearer $token',
  ///   'X-Goog-AuthUser': '0',
  /// };
  /// ```
  static Map<String, String> gApis(String token) {
    return {
      'Authorization': 'Bearer $token',
      'X-Goog-AuthUser': '0',
    };
  }
}

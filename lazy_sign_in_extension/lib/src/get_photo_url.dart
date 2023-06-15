import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lazy_log/lazy_log.dart' as lazy;

Future<String> getPhotoUrl(String token) async {
  String debugPrefix = 'getPhotoUrl()';
  lazy.log(debugPrefix);
  if (token.isNotEmpty) {
    var url =
        "https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=$token";
    try {
      var res = await http.get(Uri.parse(url));
      var userInfo = jsonDecode(res.body);
      lazy.log('$debugPrefix:${userInfo.toString()}');
      return userInfo['picture'] ?? '';
    } catch (e) {
      lazy.log('$debugPrefix:${e.toString()}');
    }
  }
  return '';
}

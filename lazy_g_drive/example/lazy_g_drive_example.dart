import 'package:lazy_g_drive/lazy_g_drive.dart' as lazy;
import 'package:lazy_log/lazy_log.dart' as lazy;

void main() async {
  lazy.logEnable = true;

  var gdrive = lazy.GDrive();
  // This is sample code. To get actual [token],
  // check lazy_sign_in example: https://pub.dev/packages/lazy_sign_in/example
  gdrive.token = 'Google OAuth Access Token';

  // File meta
  var fileMeta =
      lazy.gDriveFileMeta(name: 'Sample.txt', modifiedTime: DateTime.now());

  // File content
  String content = 'This is sample text.';
  var media = content.toMedia();

  // Upload
  var result = await gdrive.create(file: fileMeta, uploadMedia: media);

  lazy.log(lazy.jsonPretty(result));
}

import 'extensions/date_time.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

Future<String> byteStreamToString(Stream<List<int>> stream) =>
    (stream as ByteStream).bytesToString();
Future<String> mediaStreamToString(Stream<List<int>> stream) =>
    byteStreamToString(stream);

// --- DateTime
const defaultDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
const defaultTimestampFormat = 'yyyy-MM-dd hhmmss';

/// Return `DateTime` from [string] using supplied [format] or [defaultDateTimeFormat] = 'yyyy-MM-dd HH:mm:ss'`
DateTime dateTimeFromString(String string,
        {String format = defaultDateTimeFormat}) =>
    DateFormat(format).parse(string);

/// Shorthand for `DateTime.now()`
DateTime get now => DateTime.now();

/// Shorthand for `DateTime(0)`
DateTime get dayZero => DateTime(0);

/// Shorthand for `DateTime(0)`
DateTime get zeroDay => DateTime(0);

/// Shorthand for `DateTime.now().timestamp()`
String get timestampNow => now.toTimestamp();

/// Provided by 'package:url_launcher/url_launcher.dart'
void openUrl(String string) {
  if (string.isNotEmpty) {
    Uri? uri = Uri.tryParse(string);
    if (uri != null) {
      launchUrl(Uri.parse(string));
    }
  }
}

void htmlWindowOnClose(Function action) {
  html.window.onBeforeUnload.listen((event) async => action());
  html.window.onUnload.listen((event) async => action());
}

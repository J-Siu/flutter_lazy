import 'package:lazy_extensions/lazy_extensions.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

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

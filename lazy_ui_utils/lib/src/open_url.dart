import 'package:url_launcher/url_launcher.dart';

/// Provided by 'package:url_launcher/url_launcher.dart'
void openUrl(String string) {
  if (string.isNotEmpty) {
    Uri? uri = Uri.tryParse(string);
    if (uri != null) {
      launchUrl(Uri.parse(string));
    }
  }
}

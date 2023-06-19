import 'dart:convert';
import 'package:lazy_log/lazy_log.dart' as lazy;
import 'package:universal_html/html.dart' as html;

/// Trigger browser to save to [filename] with [content]
void download({
  required String filename,
  required List<int> content,
}) {
  // Create the link with the file
  final anchor = html.AnchorElement(
      href: 'data:application/octet-stream;base64,${base64Encode(content)}');
  anchor.target = 'blank';
  // Set filename
  anchor.download = filename;
  // Download
  if (html.document.body != null) {
    html.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
  } else {
    lazy.log('download():document.body==null');
  }
  return;
}

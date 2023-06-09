import 'dart:convert';
import 'dart:html';
import 'package:lazy_log/lazy_log.dart' as lazy;

void download(
  List<int> bytes, {
  required String downloadName,
}) {
  // Create the link with the file
  final anchor = AnchorElement(
      href: 'data:application/octet-stream;base64,${base64Encode(bytes)}');
  anchor.target = 'blank';
  // Set filename
  anchor.download = downloadName;
  // Download
  if (document.body != null) {
    document.body!.append(anchor);
    anchor.click();
    anchor.remove();
  } else {
    lazy.log('download():document.body==null');
  }
  return;
}

import 'package:universal_html/html.dart' as html;

/// Setup a callback [action] on browser unload
void htmlWindowOnClose(Function action) {
  html.window.onBeforeUnload.listen((event) async => action());
  html.window.onUnload.listen((event) async => action());
}

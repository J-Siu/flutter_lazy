import 'dart:convert';
import 'extensions/date_time.dart';
// import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

// /// turn [log] on and off
// bool logEnable = false;

// /// #### log - a wrapper of flutter's debugPrint()
// ///
// /// Enable/disable by Log.enable.
// ///
// /// - [object] - item to be logged
// /// - [forced] - force logging when [logEnable] = false
// void log(
//   Object? object, {
//   bool forced = false,
//   int? wrapWidth,
// }) {
//   if (logEnable || forced) debugPrint(object?.toString(), wrapWidth: wrapWidth);
// }

const String defaultJsonIndent = '  ';

/// Json encode [object] with supplied [indent] or [defaultJsonIndent]
String jsonPretty(Object? object, {String indent = defaultJsonIndent}) =>
    JsonEncoder.withIndent(indent).convert(object);

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

// import 'package:flutter/foundation.dart';

/// turn [log] on and off
bool logEnable = false;
bool logTimestamp = true;

/// #### log - a wrapper of dart:developer [log]
///
/// Enable/disable by Log.enable.
///
/// - [object] - item to be logged
/// - [forced] - override [logEnable] when [logEnable] = false
/// - [timestamp] - override [logTimestamp] when [logTimestamp] = false
///
/// [name], [level], [time] are passed to [dev.log]
void log(
  Object? object, {
  bool forced = false,
  bool timestamp = true,
  bool localTime = true,
}) {
  if (logEnable || forced) {
    if (logTimestamp || timestamp) {
      print("${DateTime.now().toIso8601String()} ${object.toString()}");
    } else {
      print(object.toString());
    }
  }
}

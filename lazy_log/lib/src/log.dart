// import 'package:flutter/foundation.dart';

/// turn [log] on and off
bool logEnable = false;

/// #### log - a wrapper of dart:developer [log]
///
/// Enable/disable by Log.enable.
///
/// - [object] - item to be logged
/// - [forced] - override [logEnable] when [logEnable] = false
///
/// [name], [level], [time] are passed to [dev.log]
void log(
  Object? object, {
  bool forced = false,
}) {
  if (logEnable || forced) {
    // debugPrint(object.toString());
    print(object.toString());
  }
}

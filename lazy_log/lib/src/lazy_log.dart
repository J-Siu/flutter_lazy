import 'package:flutter/foundation.dart';

/// turn [log] on and off
bool logEnable = false;

/// #### log - a wrapper of flutter's debugPrint()
///
/// Enable/disable by Log.enable.
///
/// - [object] - item to be logged
/// - [forced] - force logging when [logEnable] = false
void log(
  Object? object, {
  bool forced = false,
  int? wrapWidth,
}) {
  if (logEnable || forced) debugPrint(object?.toString(), wrapWidth: wrapWidth);
}

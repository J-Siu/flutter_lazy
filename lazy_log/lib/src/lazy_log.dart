import 'dart:developer' as dev;

/// turn [log] on and off
bool logEnable = false;

/// #### log - a wrapper of dart:developer [log]
///
/// Enable/disable by Log.enable.
///
/// - [object] - item to be logged
/// - [forced] - force logging when [logEnable] = false
void log(
  Object? object, {
  bool forced = false,
  DateTime? time,
  String name = '',
  int level = 0,
  int? wrapWidth,
}) {
  if (logEnable || forced) {
    dev.log(
      object?.toString() ?? 'null',
      level: level,
      name: name,
      time: time,
    );
  }
}

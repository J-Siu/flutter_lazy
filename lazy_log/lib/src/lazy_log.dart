import 'dart:developer' as dev;

/// turn [log] on and off
bool logEnable = false;

/// turn [log] stdout on and off
bool logStdout = true;

/// #### log - a wrapper of dart:developer [log]
///
/// Enable/disable by Log.enable.
///
/// - [object] - item to be logged
/// - [forced] - override [logEnable] when [logEnable] = false
/// - [stdout] - override [logStdout] when [logStdout] = false
///
/// [name], [level], [time] are passed to [dev.log]
void log(
  Object? object, {
  DateTime? time,
  String name = '',
  bool forced = false,
  bool stdout = false,
  int level = 0,
}) {
  if (logEnable || forced) {
    if (logStdout || stdout) {
      print(object);
    }
    dev.log(
      object?.toString() ?? 'null',
      level: level,
      name: name,
      time: time,
    );
  }
}

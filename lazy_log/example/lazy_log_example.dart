import 'package:lazy_log/lazy_log.dart' as lazy;

main() {
  lazy.logEnable = false;

  /// Override with [force]
  lazy.log('This is a test', forced: true);
}

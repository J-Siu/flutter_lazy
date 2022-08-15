import 'package:intl/intl.dart';
import '../base.dart' as lazy;

/// ### Lazy extension for [DateTime]
extension LazyExtDataTime on DateTime {
  /// Return [String] in format: [lazy.defaultTimestampFormat] = `yyyy-MM-dd hhmmss`
  String toTimestamp() => DateFormat(lazy.defaultTimestampFormat).format(this);

  /// Return [String] in supplied [format] or [lazy.defaultTimestampFormat] = `yyyy-MM-dd HH:mm:ss`
  String toFormat({String format = lazy.defaultDateTimeFormat}) => DateFormat(format).format(this);

  /// Alias to [toFormat]
  String toStringFormat({String format = lazy.defaultDateTimeFormat}) => toFormat(format: format);
}

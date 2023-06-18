import 'package:intl/intl.dart';

const String defaultDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
const String defaultTimestampFormat = 'yyyy-MM-dd hhmmss';

/// ### Lazy extension for [DateTime]
extension LazyExtDateTime on DateTime {
  static get dayZero => DateTime(0);
  static get zeroDay => DateTime(0);

  /// Return [String] in format: [defaultTimestampFormat] = `yyyy-MM-dd hhmmss`
  String toTimestamp() => DateFormat(defaultTimestampFormat).format(this);

  /// Return [String] in supplied [format] or [defaultTimestampFormat] = `yyyy-MM-dd HH:mm:ss`
  String toFormat({String format = defaultDateTimeFormat}) =>
      DateFormat(format).format(this);

  /// Alias to [toFormat]
  String toStringFormat({String format = defaultDateTimeFormat}) =>
      toFormat(format: format);
}

/// Return `DateTime` from [string] using supplied [format] or [defaultDateTimeFormat] = 'yyyy-MM-dd HH:mm:ss'`
DateTime dateTimeFromString(String string,
        {String format = defaultDateTimeFormat}) =>
    DateFormat(format).parse(string);

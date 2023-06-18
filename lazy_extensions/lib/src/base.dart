import '../lazy_extensions.dart';

/// Shorthand for `DateTime.now()`
DateTime get now => DateTime.now();

/// Shorthand for `DateTime(0)`
DateTime get dayZero => DateTime(0);

/// Shorthand for `DateTime(0)`
DateTime get zeroDay => DateTime(0);

/// Shorthand for `DateTime.now().timestamp()`
String get timestampNow => now.toTimestamp();

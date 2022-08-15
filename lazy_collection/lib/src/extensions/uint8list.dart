import 'dart:typed_data';

/// ### Lazy extension for [Uint8List]
extension LazyExtUint8List on Uint8List {
  /// Return [int] value of supplied [bytes]
  ///
  /// - [start] : starting position of [bytes] for conversion, default `0`
  /// - [end] : ending position of [bytes] for conversion, default [bytes.length]
  /// - [endian] : Endian of conversion. Default [Endian.big]
  ///
  /// Conversion length:
  /// - 1: use int8 conversion
  /// - 2: use int16 conversion
  /// - 4: use int32 conversion
  /// - 8: use int64 conversion
  ///
  /// `throw` if conversion length not equal to 1, 2, 4, 6, 8
  int toInt(
    Uint8List bytes, {
    int start = 0,
    int? end,
    Endian endian = Endian.big,
  }) {
    String debugPrefix = 'LazyExtUint8List.toInt()';
    try {
      end ??= bytes.length;
      var length = end - start;
      var byteData = ByteData.sublistView(bytes, start, end);
      int result = 0;
      switch (length) {
        case 1:
          result = byteData.getInt8(0);
          break;
        case 2:
          result = byteData.getInt16(0, endian);
          break;
        case 4:
          result = byteData.getInt32(0, endian);
          break;
        case 8:
          result = byteData.getInt64(0, endian);
          break;
        default:
          throw ('Byte list length must be 1, 2, 4, 8. Current:$length');
      }
      return result;
    } catch (e) {
      throw ('$debugPrefix:$e');
    }
  }
}

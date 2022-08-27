import 'dart:typed_data';

/// ### Lazy extension for [ByteData]
extension LazyExtByteData on ByteData {
  /// Return `this` buffer as [Uint8List]
  Uint8List toUint8List() => buffer.asUint8List(offsetInBytes, lengthInBytes);
}

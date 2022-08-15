/// ### Lazy extension for [String]
extension LazyExtString on String {
  /// Only capitalize first letter of this string
  /// - Source: https://stackoverflow.com/a/29629114/1810391
  String toCapitalized() => isNotEmpty ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  /// Capitalize first letter of all words in this string
  /// - Source: https://stackoverflow.com/a/29629114/1810391
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');

  /// Same as [codeUnits]
  List<int> toBytes() => codeUnits;

  /// Create [ByteStream] from [this]
  Stream<List<int>> toByteStream() => Future.value(codeUnits).asStream().asBroadcastStream();
}

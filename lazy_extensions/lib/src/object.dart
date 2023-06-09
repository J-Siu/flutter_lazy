import 'dart:convert';

/// Default [jsonPretty] indent with 2 spaces
const String defaultJsonIndent = '  ';

extension LazyExtObject on Object {
  /// Json encode [object] with supplied [indent] or [defaultJsonIndent]
  ///
  /// If conversion failed, return error as [String] and NOT throw.
  String jsonPretty({String indent = defaultJsonIndent}) {
    try {
      return JsonEncoder.withIndent(indent).convert(this);
    } catch (e) {
      return 'jsonPretty() failed: $e';
    }
  }
}

import 'dart:convert';

/// Default [jsonPretty] indent with 2 spaces
const String defaultJsonIndent = '  ';

/// Json encode [object] with supplied [indent] or [defaultJsonIndent]
String jsonPretty(Object? object, {String indent = defaultJsonIndent}) =>
    JsonEncoder.withIndent(indent).convert(object);

import 'package:lazy_http_client/lazy_http_client.dart' as lazy;
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final gApiHeader = lazy.Headers.gApis('');

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(gApiHeader['Authorization'], 'Bearer ');
    });
  });
}

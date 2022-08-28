import 'package:lazy_cache/lazy_cache.dart' as lazy;
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final cache = lazy.Cache();

    setUp(() {
      // Additional setup goes here.
    });

    test('Index - Empty', () {
      expect((cache.index.isEmpty), isTrue);
    });
  });
}

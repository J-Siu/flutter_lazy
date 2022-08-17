import 'package:lazy_g_drive/lazy_g_drive.dart' as lazy;
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final gDrive = lazy.GDrive();
    gDrive.token = 'dummy';

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(gDrive.token.isNotEmpty, isTrue);
    });
  });
}

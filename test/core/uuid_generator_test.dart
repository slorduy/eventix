import 'package:eventix/core/utils/uuid_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates RFC 4122 version 4 UUIDs', () {
    final first = generateUuidV4();
    final second = generateUuidV4();
    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );

    expect(uuidPattern.hasMatch(first), isTrue);
    expect(uuidPattern.hasMatch(second), isTrue);
    expect(second, isNot(first));
  });
}

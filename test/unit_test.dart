import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/game/vector.dart';

void main() {
  group('Unit tests', () {
    group('Vector', () {
      test('Addition', () async {
        expect(const Vector(1, 1) + const Vector(1, 1), const Vector(2, 2));
      });
    });
  });
}

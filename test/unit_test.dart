import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/game/vector.dart';

void main() {
  group('Unit tests', () {
    group('Vector', () {
      test('zero', () {
        expect(Vector.zero.x == 0 && Vector.zero.y == 0, true);
      });
      test('+', () {
        expect(const Vector(1, 1) + const Vector(1, 1), const Vector(2, 2));
      });
      test('-', () {
        expect(const Vector(1, 1) - const Vector(1, 1), Vector.zero);
      });
      test('*', () {
        expect(const Vector(1, 1) * Vector.zero, Vector.zero);
      });
      test('<', () {
        expect(Vector.zero < const Vector(1, 1), true);
      });
      test('>=', () {
        expect(Vector.zero >= const Vector(-1, -1), true);
      });
      test('==', () {
        expect(Vector.zero, Vector.zero);
      });
      test('toString', () {
        expect(Vector.zero.toString(), '0,0');
      });
    });
  });
}

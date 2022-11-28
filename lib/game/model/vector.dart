import 'package:flutter/material.dart';

@immutable
class Vector {
  final int x;
  final int y;

  const Vector(this.x, this.y);

  static const zero = Vector(0, 0);

  Vector operator +(Vector other) => Vector(x + other.x, y + other.y);

  Vector operator -(Vector other) => Vector(x - other.x, y - other.y);

  Vector operator *(Vector other) => Vector(x * other.x, y * other.y);

  bool operator <(Vector other) => x < other.x || y < other.y;

  bool operator >=(Vector other) => x >= other.x || y >= other.y;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Vector && x == other.x && y == other.y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '$x,$y';
}

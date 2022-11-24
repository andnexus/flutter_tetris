class Vector {
  final int x, y;

  const Vector(this.x, this.y);

  static const zero = Vector(0, 0);

  Vector operator +(Vector other) => Vector(x + other.x, y + other.y);

  Vector operator -(Vector other) => Vector(x - other.x, y - other.y);

  Vector operator *(Vector other) => Vector(x * other.x, y * other.y);

  bool operator <(Vector other) => x < other.x || y < other.y;

  bool operator >=(Vector other) => x >= other.x || y >= other.y;

  @override
  bool operator ==(Object other) => x == (other as Vector).x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '$x,$y';
}

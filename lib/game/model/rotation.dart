enum Rotation {
  zero,
  right,
  two,
  left;

  @override
  String toString() {
    switch (this) {
      case Rotation.zero:
        return '0';
      case Rotation.right:
        return 'R';
      case Rotation.two:
        return '2';
      case Rotation.left:
        return 'L';
    }
  }
}

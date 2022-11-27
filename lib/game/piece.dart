import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/game/rotation.dart';
import 'package:tetris/game/vector.dart';

Piece get nextPiece {
  final index = Random().nextInt(_pieces.length);
  return Piece(
    center: _center[index],
    color: _colors[index],
    tiles: _pieces[index],
    wallKicks: _wallKicks[index],
  );
}

class Piece {
  final Vector center;
  final Color color;
  final List<Vector> tiles = [];
  final Map<String, List<Vector>> wallKicks;

  Rotation rotation = Rotation.zero;

  Piece.empty()
      : center = Vector.zero,
        color = const Color(0xFF000000),
        wallKicks = {};

  Piece({
    required this.color,
    required this.wallKicks,
    required this.center,
    required List<List<int>> tiles,
  }) {
    tiles = tiles.reversed.toList();
    for (int yp = 0; yp < tiles.length; yp++) {
      for (int xp = 0; xp < tiles.first.length; xp++) {
        if (tiles[yp][xp] == 1) this.tiles.add(Vector(xp, yp));
      }
    }
  }

  void rotate({bool clockwise = true}) {
    final angle = clockwise ? -pi / 2 : pi / 2;
    for (int i = 0; i < tiles.length; i++) {
      final p = tiles[i];
      final px = cos(angle) * (p.x - center.x) -
          sin(angle) * (p.y - center.y) +
          center.x;
      final py = sin(angle) * (p.x - center.x) +
          cos(angle) * (p.y - center.y) +
          center.y;
      tiles[i] = Vector(px.round(), py.round());
    }
    rotation = _nextRotation(rotation, clockwise);
  }

  Vector spawnOffset(int w, int h) => Vector(
        --w ~/ 2 - tiles.map((e) => e.x).reduce(max) ~/ 2,
        --h - tiles.map((e) => e.y).reduce(max),
      );

  List<Vector> getKicks({required Rotation from, bool clockwise = true}) {
    final Rotation to = _nextRotation(from, clockwise);
    return wallKicks.isNotEmpty ? wallKicks['$from$to']! : [];
  }

  Rotation _nextRotation(Rotation rotation, bool clockwise) => Rotation
      .values[(rotation.index + (clockwise ? 1 : -1)) % Rotation.values.length];

  int get width => tiles.reduce((a, b) => a.x > b.x ? a : b).x + 1;

  int get height => tiles.reduce((a, b) => a.y > b.y ? a : b).y + 1;
}

const _pieces = [
  [
    [1, 1, 1, 1]
  ],
  [
    [1, 1],
    [1, 1],
  ],
  [
    [0, 1, 0],
    [1, 1, 1],
  ],
  [
    [1, 0, 0],
    [1, 1, 1],
  ],
  [
    [0, 0, 1],
    [1, 1, 1],
  ],
  [
    [0, 1, 1],
    [1, 1, 0],
  ],
  [
    [1, 1, 0],
    [0, 1, 1],
  ],
];

const _colors = [
  Colors.teal,
  Colors.yellow,
  Colors.purple,
  Colors.blue,
  Colors.orange,
  Colors.green,
  Colors.red,
];

const _center = [
  Vector(1, 0),
  Vector(0, 0),
  Vector(1, 0),
  Vector(1, 0),
  Vector(1, 0),
  Vector(1, 0),
  Vector(1, 0),
];

/// https://harddrop.com/wiki/SRS#Wall_Kicks
const _wallKicks = [
  _iWallKicks,
  _oWallKicks,
  _jlstzWallKicks,
  _jlstzWallKicks,
  _jlstzWallKicks,
  _jlstzWallKicks,
  _jlstzWallKicks,
];

const _jlstzWallKicks = {
  "0R": [
    Vector.zero,
    Vector(-1, 0),
    Vector(-1, 1),
    Vector(0, -2),
    Vector(-1, -2),
  ],
  "R0": [
    Vector.zero,
    Vector(1, 0),
    Vector(1, -1),
    Vector(0, 2),
    Vector(1, 2),
  ],
  "R2": [
    Vector.zero,
    Vector(1, 0),
    Vector(1, -1),
    Vector(0, 2),
    Vector(1, 2),
  ],
  "2R": [
    Vector.zero,
    Vector(-1, 0),
    Vector(-1, 1),
    Vector(0, -2),
    Vector(-1, -2),
  ],
  "2L": [
    Vector.zero,
    Vector(1, 0),
    Vector(1, 1),
    Vector(0, -2),
    Vector(1, -2),
  ],
  "L2": [
    Vector.zero,
    Vector(-1, 0),
    Vector(-1, -1),
    Vector(0, 2),
    Vector(-1, 2),
  ],
  "L0": [
    Vector.zero,
    Vector(-1, 0),
    Vector(-1, -1),
    Vector(0, 2),
    Vector(-1, 2),
  ],
  "0L": [
    Vector.zero,
    Vector(1, 0),
    Vector(1, 1),
    Vector(0, -2),
    Vector(1, -2),
  ],
};

const _iWallKicks = {
  "0R": [
    Vector.zero,
    Vector(-2, 0),
    Vector(1, 0),
    Vector(-2, -1),
    Vector(1, 2),
  ],
  "R0": [
    Vector.zero,
    Vector(2, 0),
    Vector(-1, 0),
    Vector(2, 1),
    Vector(-1, -2),
  ],
  "R2": [
    Vector.zero,
    Vector(-1, 0),
    Vector(2, 0),
    Vector(-1, 2),
    Vector(2, -1),
  ],
  "2R": [
    Vector.zero,
    Vector(1, 0),
    Vector(-2, 0),
    Vector(1, -2),
    Vector(-2, 1),
  ],
  "2L": [
    Vector.zero,
    Vector(2, 0),
    Vector(-1, 0),
    Vector(2, 1),
    Vector(-1, -2),
  ],
  "L2": [
    Vector.zero,
    Vector(-2, 0),
    Vector(1, 0),
    Vector(-2, -1),
    Vector(1, 2),
  ],
  "L0": [
    Vector.zero,
    Vector(1, 0),
    Vector(-2, 0),
    Vector(1, -2),
    Vector(-2, 1),
  ],
  "0L": [
    Vector.zero,
    Vector(-1, 0),
    Vector(2, 0),
    Vector(-1, 2),
    Vector(2, -1),
  ],
};

const _oWallKicks = {
  "0R": [
    Vector(0, 1),
  ],
  "R0": [
    Vector(0, -1),
  ],
  "R2": [
    Vector(1, 0),
  ],
  "2R": [
    Vector(-1, 0),
  ],
  "2L": [
    Vector(0, -1),
  ],
  "L2": [
    Vector(0, 1),
  ],
  "L0": [
    Vector(-1, 0),
  ],
  "0L": [
    Vector(1, 0),
  ],
};

/// https://harddrop.com/wiki/SRS#Arika_SRS
const _iWallKicksArika = {
  "0R": [
    Vector.zero,
    Vector(-2, 0),
    Vector(1, 0),
    Vector(1, 2),
    Vector(-2, -1),
  ],
  "R0": [
    Vector.zero,
    Vector(2, 0),
    Vector(-1, 0),
    Vector(2, 1),
    Vector(-1, -2),
  ],
  "R2": [
    Vector.zero,
    Vector(-1, 0),
    Vector(2, 0),
    Vector(-1, 2),
    Vector(2, -1),
  ],
  "2R": [
    Vector.zero,
    Vector(-2, 0),
    Vector(1, 0),
    Vector(-2, 1),
    Vector(1, -1),
  ],
  "2L": [
    Vector.zero,
    Vector(2, 0),
    Vector(-1, 0),
    Vector(2, 1),
    Vector(-1, -1),
  ],
  "L2": [
    Vector.zero,
    Vector(-1, 0),
    Vector(-2, 0),
    Vector(1, 2),
    Vector(-2, -1),
  ],
  "L0": [
    Vector.zero,
    Vector(-2, 0),
    Vector(1, 0),
    Vector(-2, 1),
    Vector(1, -2),
  ],
  "0L": [
    Vector.zero,
    Vector(2, 0),
    Vector(-1, 0),
    Vector(-1, 2),
    Vector(2, 1),
  ],
};

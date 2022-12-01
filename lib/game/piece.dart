import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tetris/game/rotation.dart';
import 'package:tetris/game/vector.dart';

/// https://harddrop.com/wiki/Random_Generator
List<Piece> get nextPieceBag => _tiles
    .mapIndexed((index, element) => Piece(
          center: _center[index],
          color: _colors[index],
          tiles: element,
          offsets: _offsets[index],
        ))
    .toList()
  ..shuffle(); // 7! permutations (5040)

class Piece {
  final Vector center;
  final Color color;
  final List<Vector> tiles = [];
  final Map<String, List<Vector>> offsets;

  Rotation rotation = Rotation.zero;

  Piece({
    required this.color,
    required this.offsets,
    required this.center,
    required List<List<int>> tiles,
  }) {
    tiles = tiles.reversed.toList();
    for (var yp = 0; yp < tiles.length; yp++) {
      for (var xp = 0; xp < tiles.first.length; xp++) {
        if (tiles[yp][xp] == 1) {
          this.tiles.add(Vector(xp, yp));
        }
      }
    }
  }

  Piece.empty()
      : center = Vector.zero,
        color = const Color(0xFF000000),
        offsets = {};

  void rotate({bool clockwise = true}) {
    final angle = clockwise ? -pi / 2 : pi / 2;
    for (var i = 0; i < tiles.length; i++) {
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
    final fromOffsets = offsets['$from'];
    final toOffsets = offsets['${_nextRotation(from, clockwise)}'];
    final result = <Vector>[];
    for (var index = 0; index < fromOffsets!.length + 1; index++) {
      final fromOffset = fromOffsets[index % fromOffsets.length];
      final toOffset = toOffsets![index % toOffsets.length];
      if (clockwise || fromOffsets.length == 1) {
        // o piece
        result.add(fromOffset - toOffset);
      } else {
        result.add(toOffset - fromOffset);
      }
    }
    return result;
  }

  Rotation _nextRotation(Rotation rotation, bool clockwise) => Rotation
      .values[(rotation.index + (clockwise ? 1 : -1)) % Rotation.values.length];

  int get width => tiles.reduce((a, b) => a.x > b.x ? a : b).x + 1;

  int get height => tiles.reduce((a, b) => a.y > b.y ? a : b).y + 1;
}

const _tiles = [
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
  Vector.zero,
  Vector(1, 0),
  Vector(1, 0),
  Vector(1, 0),
  Vector(1, 0),
  Vector(1, 0),
];

/// https://tetris.wiki/Super_Rotation_System#How_Guideline_SRS_Really_Works
const _offsets = [
  _iOffsetData,
  _oOffsetData,
  _jlstzOffsetData,
  _jlstzOffsetData,
  _jlstzOffsetData,
  _jlstzOffsetData,
  _jlstzOffsetData,
];

const _jlstzOffsetData = {
  '0': [Vector.zero, Vector.zero, Vector.zero, Vector.zero, Vector.zero],
  'R': [Vector.zero, Vector(1, 0), Vector(1, -1), Vector(0, 2), Vector(1, 2)],
  '2': [Vector.zero, Vector.zero, Vector.zero, Vector.zero, Vector.zero],
  'L': [
    Vector.zero,
    Vector(-1, 0),
    Vector(-1, -1),
    Vector(0, 2),
    Vector(-1, 2)
  ],
};

const _iOffsetData = {
  '0': [Vector.zero, Vector(-1, 0), Vector(2, 0), Vector(-1, 0), Vector(2, 0)],
  'R': [Vector(-1, 0), Vector.zero, Vector.zero, Vector(0, 1), Vector(0, -2)],
  '2': [
    Vector(-1, 1),
    Vector(1, 1),
    Vector(-2, 1),
    Vector(1, 0),
    Vector(-2, 0)
  ],
  'L': [Vector(0, 1), Vector(0, 1), Vector(0, 1), Vector(0, -1), Vector(0, 2)],
};

const _oOffsetData = {
  '0': [Vector.zero],
  'R': [Vector(0, -1)],
  '2': [Vector(-1, -1)],
  'L': [Vector(-1, 0)],
};

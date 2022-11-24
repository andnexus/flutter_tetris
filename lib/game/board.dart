import 'package:flutter/material.dart';
import 'package:tetris/game/piece.dart';
import 'package:tetris/game/rotation.dart';
import 'package:tetris/game/vector.dart';

class Board {
  final int x;
  final int y;
  final List<Vector> _occupied;

  Piece currentPiece;

  Vector _cursor;

  int _clearedRows = 0;

  int get clearedRows => _clearedRows;

  Board(this.x, this.y)
      : currentPiece = Piece.empty(),
        _occupied = [],
        _cursor = Vector.zero {
    start();
  }

  bool isOccupied({required int index}) =>
      _occupied.contains(_tileVectorFromIndex(index: index));

  bool isCurrentPieceTile(int index) =>
      currentPiece.tiles.contains(_tileVectorFromIndex(index: index) - _cursor);

  bool isFree({Vector offset = Vector.zero}) => currentPiece.tiles
      .where((v) => _occupied.contains(v + _cursor + offset))
      .isEmpty;

  bool inBounds({Vector offset = Vector.zero}) =>
      currentPiece.tiles
          .where((v) => v + _cursor + offset >= Vector(x, y))
          .isEmpty &&
      currentPiece.tiles
          .where((v) => v + _cursor + offset < Vector.zero)
          .isEmpty;

  bool move(Vector offset) {
    if (inBounds(offset: offset) && isFree(offset: offset)) {
      _cursor += offset;
      return true;
    }
    return false;
  }

  bool rotate({bool clockwise = true}) {
    final Rotation from = currentPiece.rotation;
    currentPiece.rotate(clockwise: clockwise);
    if (inBounds() && isFree()) {
      // always apply first kick translation to correct o piece "wobble"
      _cursor += currentPiece.getKicks(from: from, clockwise: clockwise).first;
      debugPrint("$from${currentPiece.rotation} rotated with first kick");
      return true;
    } else {
      final kicks = currentPiece.getKicks(from: from, clockwise: clockwise);
      for (var kick in kicks) {
        if (inBounds(offset: kick) && isFree(offset: kick)) {
          _cursor += kick;
          debugPrint("$from${currentPiece.rotation} rotated with kick $kick");
          return true;
        }
      }
    }
    debugPrint("Rotation reverted");
    currentPiece.rotate(clockwise: !clockwise);
    return false;
  }

  void spawn() {
    currentPiece = nextPiece;
    _cursor = currentPiece.spawnOffset(x, y);
  }

  void merge() {
    for (var element in currentPiece.tiles) {
      _occupied.add(element + _cursor);
    }
  }

  void clearRows() {
    int clearedRows = 0;
    var occupied = List.of(_occupied);
    for (int yp = y - 1; yp >= 0; yp--) {
      var result = _occupied.where((element) => element.y == yp);
      if (result.length == x) {
        clearedRows++;
        final belowVectors = occupied.where((element) => element.y < yp);
        final aboveVectors = occupied
            .where((element) => element.y > yp)
            .map((e) => e + const Vector(0, -1));
        occupied = [...belowVectors, ...aboveVectors];
        debugPrint("Cleared row $yp");
      }
    }
    _clearedRows += clearedRows;
    _occupied.clear();
    _occupied.addAll(occupied);
  }

  void start() {
    spawn();
    _occupied.clear();
    _occupied.addAll(getPredefinedOccupiedTiles());
    _clearedRows = 0;
  }

  bool isGameOver() => _occupied.where((e) => e.y == y - 1).isNotEmpty;

  Vector _tileVectorFromIndex({required int index}) {
    final xp = index % x;
    final yp = y - ((index - index % x) / x).round() - 1;
    return Vector(xp, yp);
  }

  static List<Vector> getPredefinedOccupiedTiles() {
    final board = [
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],

      // empty
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],

      // clear rows test
      //[1, 1, 1, 1, 1, 1, 1, 0, 0, 1],
      //[1, 1, 1, 1, 1, 1, 0, 0, 1, 1],
      //[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      //[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      //[0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      //[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],

      // j piece test
      //[0, 0, 0, 0, 0, 0, 0, 1, 1, 1],
      //[0, 0, 0, 0, 0, 0, 0, 0, 1, 1],
      //[0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      //[0, 0, 0, 0, 0, 1, 1, 0, 0, 1],
      //[0, 0, 0, 0, 0, 1, 1, 0, 1, 1],
      //[0, 0, 0, 0, 0, 1, 1, 0, 1, 1],

      // t piece test
      //[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      //[1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
      //[1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      //[1, 0, 1, 1, 0, 0, 0, 0, 0, 0],
      //[1, 0, 0, 1, 0, 0, 0, 0, 0, 0],
      //[1, 0, 1, 1, 0, 0, 0, 0, 0, 0],

      // i piece test
      //[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      //[1, 1, 1, 0, 0, 0, 0, 0, 0, 0],
      //[1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
      //[1, 1, 0, 1, 0, 0, 0, 0, 0, 0],
      //[1, 1, 0, 1, 1, 1, 0, 0, 0, 0],
      //[1, 1, 0, 1, 1, 1, 0, 0, 0, 0],

      // i piece test
      //[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      //[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      //[0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
      //[1, 1, 1, 0, 0, 0, 0, 1, 0, 0],
      //[1, 1, 0, 0, 0, 0, 0, 1, 0, 0],
      //[1, 0, 0, 0, 0, 1, 1, 1, 0, 0],
    ].reversed.toList();
    final List<Vector> occupied = [];
    for (int yp = 0; yp < board.length; yp++) {
      for (int xp = 0; xp < board.first.length; xp++) {
        if (board[yp][xp] == 1) occupied.add(Vector(xp, yp));
      }
    }
    return occupied;
  }
}

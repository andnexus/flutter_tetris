import 'package:flutter/material.dart';
import 'package:tetris/game/piece.dart';
import 'package:tetris/game/rotation.dart';
import 'package:tetris/game/vector.dart';

class Board {
  final int x;
  final int y;
  final List<Vector> _blocked;

  Piece currentPiece;

  Piece? holdPiece;

  List<Piece> nextPieces = [];

  Vector _cursor;

  int _clearedRows = 0;

  int get clearedRows => _clearedRows;

  Board(this.x, this.y)
      : currentPiece = Piece.empty(),
        _blocked = [],
        _cursor = Vector.zero {
    start();
  }

  bool isOccupied(i) => _blocked.contains(_tileVectorFromIndex(i));

  bool isCurrentPieceTile(i) =>
      currentPiece.tiles.contains(_tileVectorFromIndex(i) - _cursor);

  bool isFree({Vector offset = Vector.zero}) => currentPiece.tiles
      .where((v) => _blocked.contains(v + _cursor + offset))
      .isEmpty;

  bool inBounds({Vector offset = Vector.zero}) =>
      currentPiece.tiles
          .where((v) => v + _cursor + offset >= Vector(x, y))
          .isEmpty &&
      currentPiece.tiles
          .where((v) => v + _cursor + offset < Vector.zero)
          .isEmpty;

  bool move(Vector offset) {
    if (canMove(offset)) {
      _cursor += offset;
      return true;
    }
    return false;
  }

  bool canMove(Vector offset) =>
      inBounds(offset: offset) && isFree(offset: offset);

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
    if (nextPieces.length <= 3) {
      nextPieces.addAll(nextPieceBag);
    }
    currentPiece = nextPieces[0];
    nextPieces.removeAt(0);
    _cursor = currentPiece.spawnOffset(x, y);
  }

  void merge() {
    for (var element in currentPiece.tiles) {
      _blocked.add(element + _cursor);
    }
  }

  void clearRows() {
    int clearedRows = 0;
    var occupied = List.of(_blocked);
    for (int yp = y - 1; yp >= 0; yp--) {
      var result = _blocked.where((element) => element.y == yp);
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
    _blocked.clear();
    _blocked.addAll(occupied);
  }

  void hold() {
    final tmp = currentPiece;
    while (tmp.rotation != Rotation.zero) {
      tmp.rotate();
    }
    if (holdPiece == null) {
      holdPiece = tmp;
      spawn();
    } else {
      currentPiece = holdPiece!;
      holdPiece = tmp;
    }
    _cursor = currentPiece.spawnOffset(x, y);
  }

  void start() {
    spawn();
    _blocked.clear();
    _blocked.addAll(getPredefinedBlockedTiles());
    _clearedRows = 0;
    holdPiece = null;
  }

  bool isBlockOut() => _blocked.where((e) => e.y == y - 1).isNotEmpty;

  Vector _tileVectorFromIndex(int index) {
    final xp = index % x;
    final yp = y - ((index - index % x) / x).round() - 1;
    return Vector(xp, yp);
  }

  static List<Vector> getPredefinedBlockedTiles() {
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
    final List<Vector> blocked = [];
    for (int yp = 0; yp < board.length; yp++) {
      for (int xp = 0; xp < board.first.length; xp++) {
        if (board[yp][xp] == 1) blocked.add(Vector(xp, yp));
      }
    }
    return blocked;
  }
}

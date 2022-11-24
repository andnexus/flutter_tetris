import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/game/model/level.dart';
import 'package:tetris/game/model/piece.dart';
import 'package:tetris/game/model/rotation.dart';
import 'package:tetris/game/model/vector.dart';
import 'package:tetris/game/tetris_widget.dart';

class Board extends ChangeNotifier {
  static const Duration lockDelayTime = Duration(seconds: 1);
  static const int x = 10;
  static const int y = 2 * x;

  Timer? gameTimer;
  Timer? moveTimer;
  int lastMovedTime = 0;

  final List<Vector> _blocked;

  Piece currentPiece;

  Piece? holdPiece;

  final List<Piece> _nextPieces = [];

  List<Piece> get nextPieces => _nextPieces;

  Vector _cursor;

  Vector get cursor => _cursor;

  int _clearedRows = 0;

  int get clearedLines => _clearedRows;

  Board()
      : currentPiece = Piece.empty(),
        _blocked = [],
        _cursor = Vector.zero {
    moveTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (isBlockOut()) {
        moveTimer?.cancel();
        startGame();
      } else if (!canMove(const Vector(0, -1)) && isLockDelayExpired()) {
        moveTimer?.cancel();
        merge();
        clearRows();
        spawn();
        startMoveTimer();
      }
    });
    startGame();
  }

  void startMoveTimer() {
    moveTimer = Timer.periodic(getLevel(clearedLines).speed, (timer) {
      move(const Vector(0, -1));
    });
  }

  bool isLockDelayExpired() =>
      lastMovedTime <
      DateTime.now().millisecondsSinceEpoch - lockDelayTime.inMilliseconds;

  void hardDrop() {
    while (move(const Vector(0, -1))) {}
    lastMovedTime = 0;
  }

  void startGame() {
    reset();
    startMoveTimer();
  }

  bool isOccupied(Vector v) => _blocked.contains(v);

  bool isCurrentPieceTile(Vector v) => currentPiece.tiles.contains(v - _cursor);

  bool isFree({Vector offset = Vector.zero}) => currentPiece.tiles
      .where((v) => _blocked.contains(v + _cursor + offset))
      .isEmpty;

  bool inBounds({Vector offset = Vector.zero}) =>
      currentPiece.tiles
          .where((v) => v + _cursor + offset >= const Vector(x, y))
          .isEmpty &&
      currentPiece.tiles
          .where((v) => v + _cursor + offset < Vector.zero)
          .isEmpty;

  bool move(Vector offset) {
    if (canMove(offset)) {
      _cursor += offset;
      _notify();
      return true;
    }
    return false;
  }

  bool canMove(Vector offset) =>
      inBounds(offset: offset) && isFree(offset: offset);

  bool rotate({bool clockwise = true}) {
    final from = currentPiece.rotation;
    currentPiece.rotate(clockwise: clockwise);
    if (inBounds() && isFree()) {
      // always apply first kick translation to correct o piece "wobble"
      _cursor += currentPiece.getKicks(from: from, clockwise: clockwise).first;
      debugPrint('$from${currentPiece.rotation} rotated with first kick');
      _notify();
      return true;
    } else {
      final kicks = currentPiece.getKicks(from: from, clockwise: clockwise);
      for (final kick in kicks) {
        if (inBounds(offset: kick) && isFree(offset: kick)) {
          _cursor += kick;
          debugPrint('$from${currentPiece.rotation} rotated with kick $kick');
          _notify();
          return true;
        }
      }
    }
    debugPrint('Rotation reverted');
    currentPiece.rotate(clockwise: !clockwise);
    return false;
  }

  void spawn() {
    if (_nextPieces.length <= 3) {
      _nextPieces.addAll(nextPieceBag);
    }
    currentPiece = _nextPieces[0];
    _nextPieces.removeAt(0);
    _cursor = currentPiece.spawnOffset(x, y);
    _notify();
  }

  void merge() {
    for (final element in currentPiece.tiles) {
      _blocked.add(element + _cursor);
    }
  }

  void clearRows() {
    var clearedRows = 0;
    var occupied = List.of(_blocked);
    for (var yp = y - 1; yp >= 0; yp--) {
      final result = _blocked.where((element) => element.y == yp);
      if (result.length == x) {
        clearedRows++;
        final belowVectors = occupied.where((element) => element.y < yp);
        final aboveVectors = occupied
            .where((element) => element.y > yp)
            .map((e) => e + const Vector(0, -1));
        occupied = [...belowVectors, ...aboveVectors];
        debugPrint('Cleared row $yp');
      }
    }
    _clearedRows += clearedRows;
    _blocked
      ..clear()
      ..addAll(occupied);
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
    _notify();
  }

  void reset() {
    spawn();
    _blocked
      ..clear()
      ..addAll(getPredefinedBlockedTiles());
    _clearedRows = 0;
    holdPiece = null;
  }

  bool isBlockOut() => _blocked.where((e) => e.y == y - 1).isNotEmpty;

  // Map grid tile index to a vector.
  // ignore: unused_element
  Vector _tileVectorFromIndex(int index) {
    final xp = index % x;
    final yp = y - ((index - index % x) / x).round() - 1;
    return Vector(xp, yp);
  }

  void _notify() {
    lastMovedTime = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

  bool isGhostTile(Vector v) {
    var offset = const Vector(0, -1);
    while (canMove(offset)) {
      offset += const Vector(0, -1);
    }
    return currentPiece.tiles
        .contains(v - _cursor - offset - const Vector(0, 1));
  }

  Widget _getTile(Vector vector) {
    if (isOccupied(vector)) {
      return Container(color: Colors.grey);
    } else if (isCurrentPieceTile(vector)) {
      return Container(color: currentPiece.color);
    } else if (isGhostTile(vector)) {
      return Container(
        color: Colors.black,
        padding: const EdgeInsets.all(1),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: Colors.grey,
              width: 1,
            ),
          ),
        ),
      );
    }
    return Container(color: Colors.black);
  }

  List<Widget> getTiles() => List.generate(
      Board.x * Board.y, (index) => _getTile(_tileVectorFromIndex(index)));

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
    final blocked = <Vector>[];
    for (var yp = 0; yp < board.length; yp++) {
      for (var xp = 0; xp < board.first.length; xp++) {
        if (board[yp][xp] == 1) {
          blocked.add(Vector(xp, yp));
        }
      }
    }
    return blocked;
  }

  KeyEventResult onKey(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        move(const Vector(-1, 0));
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        move(const Vector(1, 0));
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        hold();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        move(const Vector(0, -1));
      } else if (event.logicalKey == LogicalKeyboardKey.keyA) {
        rotate(clockwise: false);
      } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
        rotate();
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        hardDrop();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _nextPieces.clear();
        moveTimer?.cancel();
        startGame();
      }
    }
    return KeyEventResult.handled;
  }

  void onTapUp(BuildContext context, TapUpDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final localOffset = box.globalToLocal(details.globalPosition);
    final x = localOffset.dx;
    final clockwise = x >= box.size.width / 2;
    rotate(clockwise: clockwise);
  }

  void onTouch(TouchAction action) {
    switch (action) {
      case TouchAction.right:
        move(const Vector(1, 0));
        break;
      case TouchAction.left:
        move(const Vector(-1, 0));
        break;
      case TouchAction.up:
        break;
      case TouchAction.down:
        move(const Vector(0, -1));
        break;
      case TouchAction.upEnd:
        hold();
        break;
      case TouchAction.downEnd:
        hardDrop();
        break;
    }
  }
}

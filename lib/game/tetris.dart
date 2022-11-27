import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/game/board.dart';
import 'package:tetris/game/level.dart';
import 'package:tetris/game/piece.dart';
import 'package:tetris/game/vector.dart';

/// https://harddrop.com/wiki/Gameplay_overview
class Tetris extends StatefulWidget {
  const Tetris({super.key});

  @override
  State<Tetris> createState() => _TetrisState();
}

class _TetrisState extends State<Tetris> {
  static const Duration lockDelayTime = Duration(seconds: 1);
  static const int x = 10;
  static const int y = 2 * x;

  Board board = Board(x, y);

  Timer? gameTimer;
  Timer? moveTimer;
  int lastMovedTime = 0;

  @override
  void initState() {
    moveTimer = Timer.periodic(const Duration(milliseconds: 60), (Timer timer) {
      if (board.isBlockOut()) {
        moveTimer?.cancel();
        startGame();
      } else if (!board.canMove(const Vector(0, -1)) && isLockDelayExpired()) {
        setState(() {
          moveTimer?.cancel();
          board.merge();
          board.clearRows();
          board.spawn();
          startMoveTimer();
        });
      }
    });
    startGame();
    super.initState();
  }

  void startMoveTimer() {
    moveTimer =
        Timer.periodic(getLevel(board.clearedRows).speed, (Timer timer) {
      move(const Vector(0, -1));
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: Focus(
              onKey: onKey,
              autofocus: true,
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: board.holdPiece != null
                        ? PieceView(count: 1, pieces: [board.holdPiece!])
                        : const SizedBox.shrink(),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: BoardView(board: board),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: PieceView(count: 3, pieces: board.nextPieces),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  bool isLockDelayExpired() =>
      lastMovedTime <
      DateTime.now().millisecondsSinceEpoch - lockDelayTime.inMilliseconds;

  bool move(Vector vector) {
    bool hasMoved = false;
    setState(() {
      hasMoved = board.move(vector);
      if (hasMoved) lastMovedTime = DateTime.now().millisecondsSinceEpoch;
    });
    return hasMoved;
  }

  void moveToFloor() {
    setState(() {
      while (board.move(const Vector(0, -1))) {}
      lastMovedTime = 0;
    });
  }

  bool rotate({bool clockwise = true}) {
    bool hasRotated = false;
    setState(() {
      hasRotated = board.rotate(clockwise: clockwise);
      if (hasRotated) lastMovedTime = DateTime.now().millisecondsSinceEpoch;
    });
    return hasRotated;
  }

  void startGame() {
    setState(() {
      board.start();
      startMoveTimer();
    });
  }

  void hold() {
    setState(() {
      board.hold();
    });
  }

  @override
  void dispose() {
    moveTimer?.cancel();
    gameTimer?.cancel();
    super.dispose();
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
        rotate(clockwise: true);
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        moveToFloor();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        board.nextPieces.clear();
        moveTimer?.cancel();
        startGame();
      }
    }
    return KeyEventResult.handled;
  }
}

class BoardView extends StatelessWidget {
  static const double gridDividerThickness = 2;
  static const Color gridDividerColor = Color(0xFF2F2F2F);
  final Board board;

  const BoardView({super.key, required this.board});

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: board.x / board.y,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: gridDividerColor,
              border: Border.all(
                color: gridDividerColor,
                width: gridDividerThickness,
              ),
              borderRadius: BorderRadius.circular(gridDividerThickness),
            ),
            child: GridView.count(
              primary: false,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: board.x,
              mainAxisSpacing: gridDividerThickness,
              crossAxisSpacing: gridDividerThickness,
              children: List.generate(
                board.x * board.y,
                (i) => Container(
                  color: board.isOccupied(i)
                      ? Colors.grey
                      : board.isCurrentPieceTile(i)
                          ? board.currentPiece.color
                          : Colors.black,
                ),
              ),
            ),
          ),
        ),
      );
}

class PieceView extends StatelessWidget {
  final List<Piece> pieces;
  final int count;

  const PieceView({
    super.key,
    required this.pieces,
    required this.count,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => ListView.separated(
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int i) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              pieces[i].height,
              (y) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(
                  pieces[i].width,
                  (x) => Container(
                      height: constraints.maxWidth / 6,
                      width: constraints.maxWidth / 6,
                      color: pieces[i]
                              .tiles
                              .where((element) => element == Vector(x, y))
                              .isEmpty
                          ? Colors.transparent
                          : pieces[i].color),
                ),
              ),
            ).reversed.toList(),
          ),
          separatorBuilder: (BuildContext context, int index) =>
              SizedBox(height: constraints.maxHeight / 20),
          itemCount: count,
        ),
      );
}

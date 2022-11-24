import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris/game/board.dart';
import 'package:tetris/game/level.dart';
import 'package:tetris/game/vector.dart';

class Tetris extends StatefulWidget {
  const Tetris({super.key});

  @override
  State<Tetris> createState() => _TetrisState();
}

class _TetrisState extends State<Tetris> {
  static const double gridDividerThickness = 2;
  static const Color gridDividerColor = Color(0xFF2F2F2F);

  static const int x = 10;
  static const int y = 2 * x;
  Board board = Board(x, y);

  Timer? timer;
  static const Duration operable = Duration(seconds: 1);
  DateTime lockDelay = DateTime.now();

  @override
  void initState() {
    timer = Timer.periodic(getLevel(board.clearedRows).speed, (Timer timer) {
      if (board.isGameOver()) {
        board.start();
      } else if (!move(const Vector(0, -1)) && !isLocked()) {
        board.merge();
        board.clearRows();
        board.spawn();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF323232),
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: onKey,
              child: Focus(
                onKey: (FocusNode node, RawKeyEvent event) =>
                    KeyEventResult.handled,
                autofocus: true,
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('LEVEL'),
                          Text('${getLevel(board.clearedRows).id}'),
                          const SizedBox(height: 20),
                          const Text('LINE'),
                          Text('${board.clearedRows}'),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: x / y,
                          child: Container(
                            decoration: BoxDecoration(
                              color: gridDividerColor,
                              border: Border.all(
                                color: gridDividerColor,
                                width: gridDividerThickness,
                              ),
                              borderRadius:
                                  BorderRadius.circular(gridDividerThickness),
                            ),
                            child: GridView.count(
                              primary: false,
                              crossAxisCount: x,
                              mainAxisSpacing: gridDividerThickness,
                              crossAxisSpacing: gridDividerThickness,
                              children: List.generate(
                                x * y,
                                (i) => Container(
                                  color: board.isOccupied(index: i)
                                      ? Colors.grey
                                      : board.isCurrentPieceTile(i)
                                          ? board.currentPiece.color
                                          : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  bool isLocked() => lockDelay.compareTo(DateTime.now().subtract(operable)) >= 0;

  bool move(Vector vector) {
    bool hasMoved = false;
    setState(() {
      hasMoved = board.move(vector);
    });
    return hasMoved;
  }

  void moveToFloor() {
    setState(() {
      while (board.move(const Vector(0, -1))) {}
      lockDelay = DateTime.now().subtract(operable);
    });
  }

  bool rotate({bool clockwise = true}) {
    bool hasRotated = false;
    setState(() {
      hasRotated = board.rotate(clockwise: clockwise);
    });
    return hasRotated;
  }

  void start() {
    setState(() {
      board.start();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void onKey(RawKeyEvent e) {
    if (e is RawKeyDownEvent) {
      lockDelay = DateTime.now();
      if (e.logicalKey == LogicalKeyboardKey.arrowLeft) {
        move(const Vector(-1, 0));
      } else if (e.logicalKey == LogicalKeyboardKey.arrowRight) {
        move(const Vector(1, 0));
      } else if (e.logicalKey == LogicalKeyboardKey.arrowUp) {
        move(const Vector(0, 1));
      } else if (e.logicalKey == LogicalKeyboardKey.arrowDown) {
        move(const Vector(0, -1));
      } else if (e.logicalKey == LogicalKeyboardKey.keyA) {
        rotate(clockwise: false);
      } else if (e.logicalKey == LogicalKeyboardKey.keyD) {
        rotate(clockwise: true);
      } else if (e.logicalKey == LogicalKeyboardKey.space) {
        moveToFloor();
      } else if (e.logicalKey == LogicalKeyboardKey.escape) {
        start();
      }
    }
  }
}

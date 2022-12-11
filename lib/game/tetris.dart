import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/game/board.dart';
import 'package:tetris/game/level.dart';
import 'package:tetris/game/piece.dart';
import 'package:tetris/game/touch.dart';
import 'package:tetris/game/vector.dart';

class Tetris extends StatefulWidget {
  const Tetris({Key? key}) : super(key: key);

  @override
  State<Tetris> createState() => _TetrisState();
}

class _TetrisState extends State<Tetris> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => Board(this),
        child: const TetrisView(),
      );
}

class TetrisView extends StatelessWidget {
  const TetrisView({super.key});

  @override
  Widget build(BuildContext context) => TouchDetector(
        onTapUp: (details) => context.read<Board>().onTapUp(context, details),
        onTouch: context.read<Board>().onTouch,
        child: Focus(
          onKey: context.read<Board>().onKey,
          autofocus: true,
          child: Scaffold(
            body: SafeArea(
              child: Center(
                child: LayoutBuilder(
                    builder: (context, constraints) => Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const LeftView(),
                            CenterView(constraints),
                            const RightView(),
                          ],
                        )),
              ),
            ),
          ),
        ),
      );
}

class LeftView extends StatelessWidget {
  const LeftView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final piece = context.select<Board, Piece?>((value) => value.holdPiece);
    final lines = context.select<Board, int>((value) => value.clearedLines);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        PanelView(
          topRight: false,
          bottomRight: false,
          child: Column(
            children: [const Text('HOLD'), PieceView(piece: piece)],
          ),
        ),
        const SizedBox(height: 50),
        PanelView(
          topRight: false,
          bottomRight: false,
          child: Column(
            children: [
              const Text('LEVEL'),
              Text('${getLevel(lines).id}'),
              const SizedBox(height: 10),
              const Text('LINES'),
              Text('$lines'),
            ],
          ),
        ),
      ],
    );
  }
}

class CenterView extends StatelessWidget {
  final BoxConstraints constraints;

  const CenterView(this.constraints, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      PanelView(child: BoardView(constraints));
}

class RightView extends StatelessWidget {
  const RightView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pieces = context.watch<Board>().nextPieces;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        PanelView(
          topLeft: false,
          bottomLeft: false,
          child: Column(
            children: [
              const Text('NEXT'),
              ...pieces.take(3).map((p) => PieceView(piece: p))
            ],
          ),
        ),
      ],
    );
  }
}

class BoardView extends StatelessWidget {
  final BoxConstraints constraints;

  const BoardView(this.constraints, {super.key});

  static const _divider = 1.0;

  @override
  Widget build(BuildContext context) {
    final tileDimension = voodooTileDimension(context);
    final width = tileDimension * Board.x + _divider * Board.x;
    final height = tileDimension * Board.y + _divider * Board.y;
    final gridSize = Size(width, height);

    final tiles = context.watch<Board>().getTiles();
    final gridItems = <Widget>[];
    for (var index = 0; index < tiles.length; index++) {
      BoxDecoration decoration;
      switch (tiles[index]) {
        case Tile.blank:
          decoration = const BoxDecoration(color: Colors.black);
          break;
        case Tile.blocked:
          decoration = const BoxDecoration(color: Colors.grey);
          break;
        case Tile.piece:
          final color = context.read<Board>().currentPiece.color;
          decoration = BoxDecoration(color: color);
          break;
        case Tile.ghost:
          decoration = BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: Colors.white,
              width: _divider,
            ),
          );
          break;
      }

      final item = Container(
        height: tileDimension,
        width: tileDimension,
        decoration: decoration,
      );

      if (Board.isAnimationEnabled) {
        final controller = context.read<Board>().animationController[index];

        final animation = Tween<double>(
          begin: 1,
          end: 0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.easeOut,
          ),
        );
        final animatedBuilder = AnimatedBuilder(
          animation: animation,
          builder: (context, child) => Transform(
            transform: Matrix4.diagonal3Values(1, 1, 1)
              ..rotateZ(1 - animation.value)
              ..scale(animation.value),
            alignment: FractionalOffset.center,
            child: Opacity(opacity: animation.value, child: child),
          ),
          child: item,
        );

        gridItems.add(
          Container(
            color: Colors.black,
            child: animatedBuilder,
          ),
        );
      } else {
        gridItems.add(item);
      }
    }
    return SizedBox.fromSize(
      size: gridSize,
      child: Center(
        child: Wrap(
          spacing: _divider,
          runSpacing: _divider,
          direction: Axis.horizontal,
          children: gridItems,
        ),
      ),
    );
  }

  double voodooTileDimension(BuildContext context) =>
      ([
                constraints.maxWidth,
                constraints.maxHeight,
              ].reduce(min) -
              2 * Theme.of(context).dividerTheme.thickness!) /
          (Board.y / Board.x) /
          Board.x -
      _divider;
}

class PieceView extends StatelessWidget {
  final Piece? piece;

  const PieceView({required this.piece, super.key});

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 30),
        child: piece != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  piece!.height,
                  (y) => Row(
                    children: List.generate(
                      piece!.width,
                      (x) => SizedBox.fromSize(
                        size: const Size(5, 5),
                        child: Container(
                            color: piece!.tiles
                                    .where((element) => element == Vector(x, y))
                                    .isEmpty
                                ? Colors.transparent
                                : Colors.white),
                      ),
                    ),
                  ),
                ).reversed.toList(),
              )
            : const SizedBox.shrink(),
      );
}

class PanelView extends StatelessWidget {
  final Widget child;

  final bool topLeft;

  final bool bottomLeft;

  final bool topRight;

  final bool bottomRight;

  const PanelView({
    super.key,
    required this.child,
    this.topLeft = true,
    this.bottomLeft = true,
    this.topRight = true,
    this.bottomRight = true,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;
    final thickness = Theme.of(context).dividerTheme.thickness!;
    final radius = Radius.circular(thickness);
    return Container(
      constraints: const BoxConstraints(minWidth: 60),
      decoration: BoxDecoration(
          color: dividerColor,
          border: Border.all(color: dividerColor, width: thickness),
          borderRadius: BorderRadius.only(
            topLeft: topLeft ? radius : Radius.zero,
            bottomLeft: bottomLeft ? radius : Radius.zero,
            topRight: topRight ? radius : Radius.zero,
            bottomRight: bottomRight ? radius : Radius.zero,
          )),
      child: child,
    );
  }
}

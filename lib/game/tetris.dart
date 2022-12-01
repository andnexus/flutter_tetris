import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/game/board.dart';
import 'package:tetris/game/level.dart';
import 'package:tetris/game/piece.dart';
import 'package:tetris/game/vector.dart';

class Tetris extends StatelessWidget {
  const Tetris({super.key});

  @override
  Widget build(BuildContext context) => TouchDetector(
        onTapUp: (details) => context.read<Board>().onTapUp(context, details),
        onTouch: context.read<Board>().onTouch,
        child: Scaffold(
          body: SafeArea(
            child: Focus(
              onKey: context.read<Board>().onKey,
              autofocus: true,
              child: Scaffold(
                body: SafeArea(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1 / 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: const [
                              LeftPanelView(),
                              BoardView(),
                              RightPanelView(),
                            ],
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class LeftPanelView extends StatelessWidget {
  const LeftPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    final hold = context.watch<Board>().holdPiece;
    final cleared = context.select<Board, int>((value) => value.clearedLines);
    final level = getLevel(cleared);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PanelView(
          index: 0,
          items: [
            const PanelText('HOLD'),
            if (hold != null) PreviewPieceView(piece: hold),
          ],
        ),
        const SizedBox(height: 70),
        PanelView(
          index: 0,
          items: [
            const PanelText('LEVEL'),
            PanelText('${level.id}'),
            const PanelText('LINES'),
            PanelText('$cleared'),
          ],
        ),
      ],
    );
  }
}

class RightPanelView extends StatelessWidget {
  const RightPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    final pieces = context.watch<Board>().nextPieces;
    return PanelView(
      index: 2,
      items: [
        const PanelText('NEXT'),
        ...List.generate(3, (i) => PreviewPieceView(piece: pieces[i])),
      ],
    );
  }
}

class BoardView extends StatelessWidget {
  static const borderRadius = 10.0;

  const BoardView({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = context.watch<Board>().getTiles();
    final dividerThickness = Theme.of(context).dividerTheme.thickness!;
    final dividerColor = Theme.of(context).dividerColor;
    return Flexible(
      flex: 6,
      fit: FlexFit.tight,
      child: Container(
        decoration: BoxDecoration(
          color: dividerColor,
          border: Border.all(
            color: dividerColor,
            width: borderRadius,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: GridView.count(
          crossAxisCount: Board.x,
          mainAxisSpacing: dividerThickness,
          crossAxisSpacing: dividerThickness,
          primary: false,
          shrinkWrap: true,
          children: tiles,
        ),
      ),
    );
  }
}

class PanelView extends StatelessWidget {
  static const _borderRadius = 10.0;

  final List<Widget> items;

  final int index;

  const PanelView({required this.index, required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius;
    switch (index) {
      case 0:
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(_borderRadius),
          bottomLeft: Radius.circular(_borderRadius),
        );
        break;
      case 2:
        borderRadius = const BorderRadius.only(
          topRight: Radius.circular(_borderRadius),
          bottomRight: Radius.circular(_borderRadius),
        );
        break;
      default:
        borderRadius = BorderRadius.zero;
    }
    return SizedBox(
      width: 60,
      child: Container(
        constraints: const BoxConstraints(minHeight: 75),
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor,
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: _borderRadius,
          ),
          borderRadius: borderRadius,
        ),
        child: ListView(
          shrinkWrap: true,
          primary: false,
          children: items
              .map((e) => Center(
                  child: Container(
                      constraints: const BoxConstraints(minHeight: 25),
                      child: e)))
              .toList(),
        ),
      ),
    );
  }
}

class PreviewPieceView extends StatelessWidget {
  final Piece piece;

  const PreviewPieceView({
    required this.piece,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: List.generate(
          piece.height,
          (y) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              piece.width,
              (x) => Container(
                  height: 5,
                  width: 5,
                  color: piece.tiles
                          .where((element) => element == Vector(x, y))
                          .isEmpty
                      ? Colors.transparent
                      : Colors.white),
            ),
          ),
        ).reversed.toList(),
      );
}

class PanelText extends StatelessWidget {
  final String text;

  const PanelText(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(text,
      style: Theme.of(context)
          .textTheme
          .bodyText1!
          .copyWith(fontSize: 10, fontWeight: FontWeight.bold));
}

enum TouchAction { right, left, up, down, upEnd, downEnd }

typedef TouchCallback = void Function(TouchAction action);

class TouchDetector extends StatefulWidget {
  final Widget child;
  final TouchCallback onTouch;
  final GestureTapUpCallback onTapUp;

  const TouchDetector({
    super.key,
    required this.child,
    required this.onTapUp,
    required this.onTouch,
  });

  @override
  State<TouchDetector> createState() => _TouchDetectorState();
}

class _TouchDetectorState extends State<TouchDetector> {
  static const _thresholdGlobalPositionDistance = 20;
  static const _thresholdSwipeVelocity = 1000;
  late Offset _initialOffset;
  late Offset _finalOffset;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapUp: widget.onTapUp,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: widget.child,
      );

  void onPanStart(DragStartDetails details) {
    _initialOffset = details.globalPosition;
  }

  void onPanUpdate(DragUpdateDetails details) {
    _finalOffset = details.globalPosition;

    final initialOffset = _initialOffset;
    final finalOffset = _finalOffset;

    // vertical
    final offsetDifferenceY = initialOffset.dy - finalOffset.dy;
    if (offsetDifferenceY.abs() > _thresholdGlobalPositionDistance) {
      _initialOffset = _finalOffset;
      widget.onTouch(details.delta.dy < 0 ? TouchAction.up : TouchAction.down);
    }

    // horizontal
    final offsetDifferenceX = initialOffset.dx - finalOffset.dx;
    if (offsetDifferenceX.abs() > _thresholdGlobalPositionDistance) {
      _initialOffset = _finalOffset;
      widget
          .onTouch(details.delta.dx < 0 ? TouchAction.left : TouchAction.right);
    }
  }

  void onPanEnd(DragEndDetails details) {
    // vertical
    if (details.velocity.pixelsPerSecond.dy > _thresholdSwipeVelocity) {
      widget.onTouch(TouchAction.downEnd);
    }
    if (details.velocity.pixelsPerSecond.dy < -_thresholdSwipeVelocity) {
      widget.onTouch(TouchAction.upEnd);
    }
  }
}

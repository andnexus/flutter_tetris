import 'package:flutter/material.dart';

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

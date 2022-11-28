import 'package:flutter/material.dart';

typedef SwipeCallback = void Function(SwipeDirection direction);

enum SwipeDirection { left, right, up, down }

class SwipeGestureDetector extends StatefulWidget {
  final Widget child;
  final SwipeConfig swipeConfigVertical;
  final SwipeConfig swipeConfigHorizontal;
  final HitTestBehavior behavior;
  final SwipeCallback? onVerticalSwipe;
  final SwipeCallback? onHorizontalSwipe;
  final GestureTapUpCallback? onTapUp;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  const SwipeGestureDetector({
    required this.child,
    Key? key,
    this.swipeConfigVertical = const SwipeConfig(),
    this.swipeConfigHorizontal = const SwipeConfig(),
    this.behavior = HitTestBehavior.deferToChild,
    this.onVerticalSwipe,
    this.onHorizontalSwipe,
    this.onTapUp,
    this.onDoubleTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  SwipeGestureDetectorState createState() => SwipeGestureDetectorState();
}

class SwipeGestureDetectorState extends State<SwipeGestureDetector> {
  Offset? _initialSwipeOffset;
  Offset? _finalSwipeOffset;
  SwipeDirection? _previousDirection;

  void _onVerticalDragStart(DragStartDetails details) {
    _initialSwipeOffset = details.globalPosition;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    _finalSwipeOffset = details.globalPosition;

    if (widget.swipeConfigVertical.swipeDetectionBehavior ==
        SwipeDetectionBehavior.singularOnEnd) {
      return;
    }

    final initialOffset = _initialSwipeOffset;
    final finalOffset = _finalSwipeOffset;

    if (initialOffset != null && finalOffset != null) {
      final offsetDifference = initialOffset.dy - finalOffset.dy;

      if (offsetDifference.abs() > widget.swipeConfigVertical.threshold) {
        _initialSwipeOffset =
            widget.swipeConfigVertical.swipeDetectionBehavior ==
                    SwipeDetectionBehavior.singular
                ? null
                : _finalSwipeOffset;

        final direction =
            offsetDifference > 0 ? SwipeDirection.up : SwipeDirection.down;

        if (widget.swipeConfigVertical.swipeDetectionBehavior ==
                SwipeDetectionBehavior.continuous ||
            _previousDirection == null ||
            direction != _previousDirection) {
          _previousDirection = direction;
          widget.onVerticalSwipe!(direction);
        }
      }
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (widget.swipeConfigVertical.swipeDetectionBehavior ==
        SwipeDetectionBehavior.singularOnEnd) {
      final initialOffset = _initialSwipeOffset;
      final finalOffset = _finalSwipeOffset;

      if (initialOffset != null && finalOffset != null) {
        final offsetDifference = initialOffset.dy - finalOffset.dy;

        if (offsetDifference.abs() > widget.swipeConfigVertical.threshold) {
          final direction =
              offsetDifference > 0 ? SwipeDirection.up : SwipeDirection.down;
          widget.onVerticalSwipe!(direction);
        }
      }
    }

    _initialSwipeOffset = null;
    _previousDirection = null;
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _initialSwipeOffset = details.globalPosition;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _finalSwipeOffset = details.globalPosition;

    if (widget.swipeConfigHorizontal.swipeDetectionBehavior ==
        SwipeDetectionBehavior.singularOnEnd) {
      return;
    }

    final initialOffset = _initialSwipeOffset;
    final finalOffset = _finalSwipeOffset;

    if (initialOffset != null && finalOffset != null) {
      final offsetDifference = initialOffset.dx - finalOffset.dx;

      if (offsetDifference.abs() > widget.swipeConfigHorizontal.threshold) {
        _initialSwipeOffset =
            widget.swipeConfigHorizontal.swipeDetectionBehavior ==
                    SwipeDetectionBehavior.singular
                ? null
                : _finalSwipeOffset;

        final direction =
            offsetDifference > 0 ? SwipeDirection.left : SwipeDirection.right;

        if (widget.swipeConfigHorizontal.swipeDetectionBehavior ==
                SwipeDetectionBehavior.continuous ||
            _previousDirection == null ||
            direction != _previousDirection) {
          _previousDirection = direction;
          widget.onHorizontalSwipe!(direction);
        }
      }
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (widget.swipeConfigHorizontal.swipeDetectionBehavior ==
        SwipeDetectionBehavior.singularOnEnd) {
      final initialOffset = _initialSwipeOffset;
      final finalOffset = _finalSwipeOffset;

      if (initialOffset != null && finalOffset != null) {
        final offsetDifference = initialOffset.dx - finalOffset.dx;

        if (offsetDifference.abs() > widget.swipeConfigHorizontal.threshold) {
          final direction =
              offsetDifference > 0 ? SwipeDirection.left : SwipeDirection.right;
          widget.onHorizontalSwipe!(direction);
        }
      }
    }

    _initialSwipeOffset = null;
    _previousDirection = null;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: widget.behavior,
        onTapUp: widget.onTapUp,
        onLongPress: widget.onLongPress,
        onDoubleTap: widget.onDoubleTap,
        onVerticalDragStart:
            widget.onVerticalSwipe != null ? _onVerticalDragStart : null,
        onVerticalDragUpdate:
            widget.onVerticalSwipe != null ? _onVerticalDragUpdate : null,
        onVerticalDragEnd:
            widget.onVerticalSwipe != null ? _onVerticalDragEnd : null,
        onHorizontalDragStart:
            widget.onHorizontalSwipe != null ? _onHorizontalDragStart : null,
        onHorizontalDragUpdate:
            widget.onHorizontalSwipe != null ? _onHorizontalDragUpdate : null,
        onHorizontalDragEnd:
            widget.onHorizontalSwipe != null ? _onHorizontalDragEnd : null,
        child: widget.child,
      );
}

enum SwipeDetectionBehavior {
  singular,
  singularOnEnd,
  continuous,
  continuousDistinct,
}

class SwipeConfig {
  final double threshold;
  final SwipeDetectionBehavior swipeDetectionBehavior;

  const SwipeConfig({
    this.threshold = 50.0,
    this.swipeDetectionBehavior = SwipeDetectionBehavior.singularOnEnd,
  });
}

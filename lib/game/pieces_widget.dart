import 'package:flutter/material.dart';
import 'package:tetris/game/model/piece.dart';
import 'package:tetris/game/model/vector.dart';

class PiecesWidget extends StatelessWidget {
  final List<Piece> pieces;

  const PiecesWidget({
    super.key,
    required this.pieces,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Center(
          child: Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              spacing: 50,
              children: List.generate(
                  pieces.length,
                  (i) => Wrap(
                        direction: Axis.vertical,
                        spacing: 1,
                        children: List.generate(
                          pieces[i].height,
                          (y) => Wrap(
                            direction: Axis.horizontal,
                            spacing: 1,
                            children: List.generate(
                              pieces[i].width,
                              (x) => Container(
                                  height: constraints.maxWidth / 6,
                                  width: constraints.maxWidth / 6,
                                  color: pieces[i]
                                          .tiles
                                          .where((element) =>
                                              element == Vector(x, y))
                                          .isEmpty
                                      ? Colors.transparent
                                      : pieces[i].color),
                            ),
                          ),
                        ).reversed.toList(),
                      ))),
        ),
      );
}

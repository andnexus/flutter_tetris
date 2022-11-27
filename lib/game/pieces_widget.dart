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
          itemCount: pieces.length,
        ),
      );
}

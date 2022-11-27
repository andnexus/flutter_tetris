import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/game/model/board.dart';
import 'package:tetris/game/model/vector.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final dividerColor = Theme.of(context).dividerColor;
          final thickness = Theme.of(context).dividerTheme.thickness!;
          final tile = (constraints.maxWidth - thickness) / Board.x - thickness;
          return Container(
            decoration: BoxDecoration(
              color: dividerColor,
              border: Border.all(
                color: dividerColor,
                width: thickness,
              ),
              borderRadius: BorderRadius.circular(thickness),
            ),
            child: Wrap(
              direction: Axis.vertical,
              spacing: thickness,
              children: List.generate(
                Board.y,
                (y) => Wrap(
                  direction: Axis.horizontal,
                  spacing: thickness,
                  children: List.generate(
                    Board.x,
                    (x) => Container(
                      height: tile,
                      width: tile,
                      color: context.watch<Board>().getTileColor(Vector(x, y)),
                    ),
                  ),
                ),
              ).reversed.toList(),
            ),
          );
        },
      );
}

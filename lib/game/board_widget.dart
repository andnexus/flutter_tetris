import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/game/model/board.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;
    final dividerThickness = Theme.of(context).dividerTheme.thickness!;
    return AspectRatio(
      aspectRatio: Board.x / Board.y,
      child: RepaintBoundary(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: dividerColor,
              border: Border.all(
                color: dividerColor,
                width: dividerThickness,
              ),
              borderRadius: BorderRadius.circular(dividerThickness),
            ),
            child: GridView.count(
              primary: false,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: Board.x,
              mainAxisSpacing: dividerThickness,
              crossAxisSpacing: dividerThickness,
              children: List.generate(
                Board.x * Board.y,
                (i) => Container(
                  color: context.watch<Board>().getTileColor(i),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

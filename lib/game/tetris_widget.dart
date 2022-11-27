import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/game/model/board.dart';
import 'package:tetris/game/model/piece.dart';
import 'package:tetris/game/pieces_widget.dart';

import 'board_widget.dart';

class TetrisWidget extends StatelessWidget {
  const TetrisWidget({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Focus(
            onKey: context.read<Board>().onKey,
            autofocus: true,
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: context.select<Board, Piece?>(
                              (value) => value.holdPiece) !=
                          null
                      ? PiecesWidget(count: 1, pieces: [
                          context
                              .select<Board, Piece>((value) => value.holdPiece!)
                        ])
                      : const SizedBox.shrink(),
                ),
                const Expanded(
                  flex: 3,
                  child: Center(
                    child: BoardWidget(),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: PiecesWidget(
                      count: 3,
                      pieces: context.select<Board, List<Piece>>(
                          (value) => value.nextPieces)),
                ),
              ],
            ),
          ),
        ),
      );
}

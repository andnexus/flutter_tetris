import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/game/tetris_widget.dart';

import 'game/model/board.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (BuildContext context) => Board(),
        child: MaterialApp(
          theme: ThemeData(brightness: Brightness.dark).copyWith(
            scaffoldBackgroundColor: const Color(0xFF000000),
            dividerColor: const Color(0xFF2F2F2F),
            dividerTheme: const DividerThemeData(thickness: 1),
          ),
          debugShowCheckedModeBanner: false,
          home: const TetrisWidget(),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/game/board.dart';
import 'package:tetris/game/tetris.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => Board(this),
        child: MaterialApp(
          theme: ThemeData(brightness: Brightness.dark).copyWith(
            scaffoldBackgroundColor: const Color(0xFF000000),
            dividerColor: const Color(0xFF2F2F2F),
            dividerTheme: const DividerThemeData(thickness: 1),
          ),
          debugShowCheckedModeBanner: false,
          home: const Tetris(),
        ),
      );
}

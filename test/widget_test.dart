import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/game/tetris_widget.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TetrisWidget());
  });
}

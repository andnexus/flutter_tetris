import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/game/tetris.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const Tetris());
  });
}

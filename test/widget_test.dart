import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/main.dart';

void main() {
  group('Widget tests.', () {
    testWidgets('Find text', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
      await tester.idle();
      expect(find.text('HOLD'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget tests.', () {
    testWidgets('Find text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Text('foo')));
      await tester.pumpAndSettle();
      expect(find.text('foo'), findsOneWidget);
    });
  });
}

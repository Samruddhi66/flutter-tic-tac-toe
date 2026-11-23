import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/main.dart';

void main() {
  testWidgets('players can complete a round in the UI', (WidgetTester tester) async {
    // Use a phone-sized surface so the whole screen fits without scrolling.
    tester.view.physicalSize = const Size(1080, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const TicTacToeApp());

    expect(find.text("X's turn"), findsOneWidget);

    for (final int index in <int>[0, 3, 1, 4, 2]) {
      await tester.tap(find.byKey(ValueKey<String>('cell-$index')));
      await tester.pumpAndSettle();
    }

    expect(find.text('X wins!'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);

    await tester.tap(find.text('Play again'));
    await tester.pumpAndSettle();

    expect(find.text("X's turn"), findsOneWidget);
  });
}

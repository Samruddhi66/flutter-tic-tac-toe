import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/main.dart';

void main() {
  testWidgets('setup asks for names and rounds, then declares the result',
      (WidgetTester tester) async {
    // Use a phone-sized surface so the whole screen fits without scrolling.
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const TicTacToeApp());

    expect(find.text('New match'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey<String>('x-name-field')),
      'Sam',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('o-name-field')),
      'Riya',
    );

    // Play a single match so the final result appears straight away.
    await tester.tap(find.byKey(const ValueKey<String>('rounds-minus')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('rounds-minus')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start game'));
    await tester.pumpAndSettle();

    // Names and scores are shown on the board.
    expect(find.text('Sam'), findsOneWidget);
    expect(find.text('Riya'), findsOneWidget);
    expect(find.text('Round 1 of 1'), findsOneWidget);
    expect(find.text("Sam's turn"), findsOneWidget);

    for (final int index in <int>[0, 3, 1, 4, 2]) {
      await tester.tap(find.byKey(ValueKey<String>('cell-$index')));
      await tester.pumpAndSettle();
    }

    expect(find.text('Sam wins the match 1–0'), findsOneWidget);
    expect(find.text('Match complete'), findsOneWidget);

    await tester.tap(find.text('Play again'));
    await tester.pumpAndSettle();

    expect(find.text("Sam's turn"), findsOneWidget);
    expect(find.text('0'), findsWidgets);
  });
}

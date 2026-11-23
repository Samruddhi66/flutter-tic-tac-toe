import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/game_logic.dart';

void main() {
  group('TicTacToe', () {
    test('starts empty with X to move and no score', () {
      final TicTacToe game = TicTacToe();

      expect(game.board, everyElement(isNull));
      expect(game.currentPlayer, Player.x);
      expect(game.status, GameStatus.playing);
      expect(game.movesPlayed, 0);
      expect(game.xWins + game.oWins + game.draws, 0);
    });

    test('alternates turns and ignores occupied or out of range cells', () {
      final TicTacToe game = TicTacToe();

      expect(game.play(4), isTrue);
      expect(game.board[4], Player.x);
      expect(game.currentPlayer, Player.o);

      expect(game.play(4), isFalse);
      expect(game.play(-1), isFalse);
      expect(game.play(9), isFalse);
      expect(game.currentPlayer, Player.o);

      expect(game.play(0), isTrue);
      expect(game.board[0], Player.o);
    });

    test('detects a row win for X and records the score', () {
      final TicTacToe game = TicTacToe();

      game.play(0); // X
      game.play(3); // O
      game.play(1); // X
      game.play(4); // O
      game.play(2); // X

      expect(game.status, GameStatus.won);
      expect(game.winner, Player.x);
      expect(game.winningLine, <int>[0, 1, 2]);
      expect(game.xWins, 1);
      expect(game.oWins, 0);
      expect(game.isPlaying, isFalse);

      // A finished round rejects further moves.
      expect(game.play(5), isFalse);
    });

    test('detects a diagonal win for O', () {
      final TicTacToe game = TicTacToe();

      game.play(0); // X
      game.play(2); // O
      game.play(1); // X
      game.play(4); // O
      game.play(8); // X
      game.play(6); // O

      expect(game.status, GameStatus.won);
      expect(game.winner, Player.o);
      expect(game.winningLine, <int>[2, 4, 6]);
      expect(game.oWins, 1);
    });

    test('reports a draw when the board fills with no line', () {
      final TicTacToe game = TicTacToe();

      for (final int index in <int>[0, 1, 2, 5, 3, 4, 7, 6, 8]) {
        game.play(index);
      }

      expect(game.status, GameStatus.draw);
      expect(game.winner, isNull);
      expect(game.winningLine, isNull);
      expect(game.draws, 1);
      expect(game.xWins, 0);
      expect(game.oWins, 0);
    });

    test('restart clears the board but keeps the score', () {
      final TicTacToe game = TicTacToe();

      game.play(0);
      game.play(3);
      game.play(1);
      game.play(4);
      game.play(2); // X wins

      game.restart();

      expect(game.status, GameStatus.playing);
      expect(game.board, everyElement(isNull));
      expect(game.winner, isNull);
      expect(game.winningLine, isNull);
      expect(game.currentPlayer, Player.x);
      expect(game.xWins, 1);
    });

    test('resetEverything clears the score too', () {
      final TicTacToe game = TicTacToe();

      game.play(0);
      game.play(3);
      game.play(1);
      game.play(4);
      game.play(2); // X wins

      game.resetEverything();

      expect(game.xWins, 0);
      expect(game.oWins, 0);
      expect(game.draws, 0);
      expect(game.status, GameStatus.playing);
      expect(game.board, everyElement(isNull));
    });
  });
}

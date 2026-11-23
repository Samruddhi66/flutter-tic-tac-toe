import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/game_logic.dart';

void main() {
  group('TicTacToe round', () {
    test('starts empty with X to move', () {
      final TicTacToe round = TicTacToe();

      expect(round.board, everyElement(isNull));
      expect(round.currentPlayer, Player.x);
      expect(round.status, GameStatus.playing);
      expect(round.movesPlayed, 0);
    });

    test('alternates turns and ignores occupied or out of range cells', () {
      final TicTacToe round = TicTacToe();

      expect(round.play(4), isTrue);
      expect(round.board[4], Player.x);
      expect(round.currentPlayer, Player.o);

      expect(round.play(4), isFalse);
      expect(round.play(-1), isFalse);
      expect(round.play(9), isFalse);
      expect(round.currentPlayer, Player.o);

      expect(round.play(0), isTrue);
      expect(round.board[0], Player.o);
    });

    test('detects a row win for X', () {
      final TicTacToe round = TicTacToe();

      round.play(0); // X
      round.play(3); // O
      round.play(1); // X
      round.play(4); // O
      round.play(2); // X

      expect(round.status, GameStatus.won);
      expect(round.winner, Player.x);
      expect(round.winningLine, <int>[0, 1, 2]);
      expect(round.isPlaying, isFalse);
      expect(round.play(5), isFalse);
    });

    test('detects a diagonal win for O', () {
      final TicTacToe round = TicTacToe();

      round.play(0); // X
      round.play(2); // O
      round.play(1); // X
      round.play(4); // O
      round.play(8); // X
      round.play(6); // O

      expect(round.status, GameStatus.won);
      expect(round.winner, Player.o);
      expect(round.winningLine, <int>[2, 4, 6]);
    });

    test('reports a draw when the board fills with no line', () {
      final TicTacToe round = TicTacToe();

      for (final int index in <int>[0, 1, 2, 5, 3, 4, 7, 6, 8]) {
        round.play(index);
      }

      expect(round.status, GameStatus.draw);
      expect(round.winner, isNull);
      expect(round.winningLine, isNull);
    });
  });

  group('Match', () {
    Match build({int rounds = 3}) =>
        Match(xName: 'Sam', oName: 'Riya', totalRounds: rounds);

    /// Plays out a round that X wins.
    void playXWin(Match match) {
      match.play(0); // X
      match.play(3); // O
      match.play(1); // X
      match.play(4); // O
      match.play(2); // X
    }

    /// Plays out a round that O wins.
    void playOWin(Match match) {
      match.play(0); // X
      match.play(2); // O
      match.play(1); // X
      match.play(4); // O
      match.play(8); // X
      match.play(6); // O
    }

    test('starts at round one with named players and no score', () {
      final Match match = build();

      expect(match.roundNumber, 1);
      expect(match.isOver, isFalse);
      expect(match.outcome, MatchOutcome.inProgress);
      expect(match.xName, 'Sam');
      expect(match.nameFor(Player.o), 'Riya');
      expect(match.markFor(Player.x), 'X');
      expect(match.xScore + match.oScore + match.draws, 0);
    });

    test('counts round wins and scores them for the right player', () {
      final Match match = build();

      playXWin(match);
      expect(match.xScore, 1);
      expect(match.oScore, 0);
      expect(match.playedRounds, 1);
      expect(match.isRoundOver, isTrue);
      expect(match.isOver, isFalse);
      expect(match.canPlay(0), isFalse);

      match.nextRound();
      expect(match.round.isPlaying, isTrue);
      expect(match.roundNumber, 2);

      playOWin(match);
      expect(match.scoreFor(Player.o), 1);
      expect(match.oScore, 1);
      expect(match.nameFor(Player.x), 'Sam');
    });

    test('plays every round before declaring the winner', () {
      final Match match = build();

      playXWin(match);
      match.nextRound();
      playXWin(match);

      // Sam leads 2-0 but the match is not over until round three is played.
      expect(match.isOver, isFalse);
      expect(match.outcome, MatchOutcome.inProgress);
      expect(match.resultText, isEmpty);

      match.nextRound();
      playOWin(match);

      expect(match.isOver, isTrue);
      expect(match.outcome, MatchOutcome.xWon);
      expect(match.winner, Player.x);
      expect(match.resultText, 'Sam wins the match 2–1');
      expect(match.nextRound(), isFalse);
      expect(match.play(0), isFalse);
    });

    test('declares a drawn match when wins are equal', () {
      final Match match = build(rounds: 2);

      playXWin(match);
      match.nextRound();
      playOWin(match);

      expect(match.isOver, isTrue);
      expect(match.outcome, MatchOutcome.draw);
      expect(match.winner, isNull);
      expect(match.resultText, 'Match drawn 1–1');
    });

    test('counts drawn rounds without giving anyone a point', () {
      final Match match = build(rounds: 1);

      for (final int index in <int>[0, 1, 2, 5, 3, 4, 7, 6, 8]) {
        match.play(index);
      }

      expect(match.draws, 1);
      expect(match.xScore, 0);
      expect(match.oScore, 0);
      expect(match.isOver, isTrue);
      expect(match.outcome, MatchOutcome.draw);
    });

    test('names the O player when O wins the match', () {
      final Match match = build(rounds: 1);

      playOWin(match);

      expect(match.outcome, MatchOutcome.oWon);
      expect(match.resultText, 'Riya wins the match 1–0');
    });

    test('a fresh match keeps the same settings and clears the score', () {
      final Match first = build(rounds: 1);
      playXWin(first);

      final Match next = Match(
        xName: first.xName,
        oName: first.oName,
        totalRounds: first.totalRounds,
      );

      expect(next.xScore, 0);
      expect(next.playedRounds, 0);
      expect(next.totalRounds, first.totalRounds);
    });
  });
}

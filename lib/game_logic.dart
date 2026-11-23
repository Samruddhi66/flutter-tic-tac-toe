/// Pure Dart rules for Tic Tac Toe, a multi-round match and the computer
/// opponent, kept free of Flutter imports so the logic can be unit tested on
/// its own.
library;

import 'dart:math';

/// The two players. X always moves first in a round.
enum Player { x, o }

/// How a single round ended (or that it is still running).
enum GameStatus { playing, won, draw }

/// How a whole match ended.
enum MatchOutcome { inProgress, xWon, oWon, draw }

/// How strong the computer opponent plays.
enum Difficulty {
  /// Picks a random empty cell.
  easy,

  /// Plays perfectly: it never loses a round.
  hard,
}

/// The eight lines that win a 3x3 round.
const List<List<int>> winningLines = <List<int>>[
  <int>[0, 1, 2],
  <int>[3, 4, 5],
  <int>[6, 7, 8],
  <int>[0, 3, 6],
  <int>[1, 4, 7],
  <int>[2, 5, 8],
  <int>[0, 4, 8],
  <int>[2, 4, 6],
];

/// A single 3x3 round: board, whose turn it is and the result.
class TicTacToe {
  TicTacToe() {
    _board = List<Player?>.filled(9, null);
  }

  late List<Player?> _board;

  /// The nine cells, in reading order. `null` means empty.
  List<Player?> get board => List<Player?>.unmodifiable(_board);

  /// Whose turn it is. Always [Player.x] at the start of a round.
  Player currentPlayer = Player.x;

  /// Whether the round is still being played, or how it ended.
  GameStatus status = GameStatus.playing;

  /// The player who won this round, if any.
  Player? winner;

  /// The three cells forming the winning line, if any.
  List<int>? winningLine;

  /// Number of marks currently on the board.
  int get movesPlayed => _board.where((Player? p) => p != null).length;

  /// Whether the round is still running.
  bool get isPlaying => status == GameStatus.playing;

  /// Whether [index] can receive a mark right now.
  bool canPlay(int index) =>
      isPlaying && index >= 0 && index < 9 && _board[index] == null;

  /// Marks [index] for the current player and updates the result.
  ///
  /// Returns `true` when the move was accepted. Illegal moves (an occupied
  /// cell, an out of range index, or a finished round) are ignored.
  bool play(int index) {
    if (!canPlay(index)) return false;

    _board[index] = currentPlayer;
    _updateStatus();
    if (isPlaying) {
      currentPlayer = currentPlayer == Player.x ? Player.o : Player.x;
    }
    return true;
  }

  /// Clears the board for a new round.
  void restart() {
    _board = List<Player?>.filled(9, null);
    currentPlayer = Player.x;
    status = GameStatus.playing;
    winner = null;
    winningLine = null;
  }

  void _updateStatus() {
    for (final List<int> line in winningLines) {
      final Player? first = _board[line[0]];
      if (first != null && _board[line[1]] == first && _board[line[2]] == first) {
        status = GameStatus.won;
        winner = first;
        winningLine = line;
        return;
      }
    }

    if (!_board.contains(null)) {
      status = GameStatus.draw;
      winner = null;
      winningLine = null;
    }
  }
}

/// A match between two named players over a fixed number of rounds.
///
/// Every round is played out, even when one player is already ahead, and the
/// winner is declared only after the last round.
class Match {
  Match({
    required this.xName,
    required this.oName,
    required this.totalRounds,
  }) : assert(totalRounds > 0);

  /// Display name of the player using X.
  final String xName;

  /// Display name of the player using O.
  final String oName;

  /// How many rounds the match lasts.
  final int totalRounds;

  /// The round currently being played (or the last one).
  final TicTacToe round = TicTacToe();

  /// Rounds won by each player, and drawn rounds.
  int xScore = 0;
  int oScore = 0;
  int draws = 0;

  /// How many rounds have finished.
  int playedRounds = 0;

  /// Name of [player].
  String nameFor(Player player) => player == Player.x ? xName : oName;

  /// Mark used by [player].
  String markFor(Player player) => player == Player.x ? 'X' : 'O';

  /// Rounds won by [player].
  int scoreFor(Player player) => player == Player.x ? xScore : oScore;

  /// The round being played, 1-based. Equal to [totalRounds] once the match is
  /// over.
  int get roundNumber =>
      playedRounds >= totalRounds ? totalRounds : playedRounds + 1;

  /// Whether all rounds have been played.
  bool get isOver => playedRounds >= totalRounds;

  /// Whether the current round is finished.
  bool get isRoundOver => !round.isPlaying;

  /// Whether [index] can be played right now.
  bool canPlay(int index) => !isOver && round.canPlay(index);

  /// Result of the match so far.
  MatchOutcome get outcome {
    if (!isOver) return MatchOutcome.inProgress;
    if (xScore > oScore) return MatchOutcome.xWon;
    if (oScore > xScore) return MatchOutcome.oWon;
    return MatchOutcome.draw;
  }

  /// The player who won the match, or `null` for a draw or unfinished match.
  Player? get winner {
    switch (outcome) {
      case MatchOutcome.xWon:
        return Player.x;
      case MatchOutcome.oWon:
        return Player.o;
      case MatchOutcome.draw:
      case MatchOutcome.inProgress:
        return null;
    }
  }

  /// Sentence describing the final result. Empty while the match is running.
  String get resultText {
    switch (outcome) {
      case MatchOutcome.xWon:
        return '$xName wins the match $xScore–$oScore';
      case MatchOutcome.oWon:
        return '$oName wins the match $oScore–$xScore';
      case MatchOutcome.draw:
        return 'Match drawn $xScore–$oScore';
      case MatchOutcome.inProgress:
        return '';
    }
  }

  /// Plays [index] for the current player, scoring the round when it ends.
  ///
  /// Returns `true` when the move was accepted.
  bool play(int index) {
    if (isOver || !round.isPlaying) return false;
    if (!round.play(index)) return false;

    if (!round.isPlaying) {
      playedRounds++;
      final Player? roundWinner = round.winner;
      if (roundWinner == null) {
        draws++;
      } else if (roundWinner == Player.x) {
        xScore++;
      } else {
        oScore++;
      }
    }
    return true;
  }

  /// Starts the next round. Returns `false` when the match is already over.
  bool nextRound() {
    if (isOver) return false;
    round.restart();
    return true;
  }
}

/// Picks moves for the computer player.
class ComputerOpponent {
  ComputerOpponent({
    this.mark = Player.o,
    this.difficulty = Difficulty.hard,
    Random? random,
  }) : _random = random ?? Random();

  /// The mark the computer plays.
  final Player mark;

  /// How strong the computer plays.
  final Difficulty difficulty;

  final Random _random;

  /// The mark of the human player.
  Player get opponent => mark == Player.x ? Player.o : Player.x;

  /// Whether it is the computer's turn in [round].
  bool isTurn(TicTacToe round) => round.isPlaying && round.currentPlayer == mark;

  /// Chooses a cell for this player, or `null` when no move is possible.
  int? chooseMove(TicTacToe round) {
    final List<int> moves = <int>[
      for (int i = 0; i < 9; i++)
        if (round.canPlay(i)) i,
    ];
    if (moves.isEmpty) return null;
    if (difficulty == Difficulty.easy) {
      return moves[_random.nextInt(moves.length)];
    }
    return _bestMove(round.board);
  }

  int? _bestMove(List<Player?> board) {
    int? bestMove;
    int bestScore = -1000;

    for (int i = 0; i < 9; i++) {
      if (board[i] != null) continue;
      final List<Player?> trial = List<Player?>.of(board);
      trial[i] = mark;
      final int score = _minimax(trial, opponent, 1);
      if (score > bestScore) {
        bestScore = score;
        bestMove = i;
      }
    }
    return bestMove;
  }

  /// Scores [board] for this player: high when the computer wins, low when the
  /// human does. Faster wins and slower losses score better.
  int _minimax(List<Player?> board, Player turn, int depth) {
    final Player? winner = _winnerOf(board);
    if (winner == mark) return 10 - depth;
    if (winner == opponent) return depth - 10;
    if (!board.contains(null)) return 0;

    int best = turn == mark ? -1000 : 1000;
    for (int i = 0; i < 9; i++) {
      if (board[i] != null) continue;
      board[i] = turn;
      final int score =
          _minimax(board, turn == Player.x ? Player.o : Player.x, depth + 1);
      board[i] = null;
      best = turn == mark ? max(best, score) : min(best, score);
    }
    return best;
  }

  Player? _winnerOf(List<Player?> board) {
    for (final List<int> line in winningLines) {
      final Player? first = board[line[0]];
      if (first != null && board[line[1]] == first && board[line[2]] == first) {
        return first;
      }
    }
    return null;
  }
}

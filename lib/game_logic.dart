/// Pure Dart game rules for Tic Tac Toe, kept free of Flutter imports so the
/// logic can be unit tested on its own.
library;

/// The two players. X always moves first.
enum Player { x, o }

/// How a game ended (or that it is still running).
enum GameStatus { playing, won, draw }

/// The eight lines that win a 3x3 game.
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

/// Holds the board, whose turn it is, the result and the running score.
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

  /// The player who won the current (or last) round, if any.
  Player? winner;

  /// The three cells forming the winning line, if any.
  List<int>? winningLine;

  /// Rounds won by X, by O, and drawn rounds.
  int xWins = 0;
  int oWins = 0;
  int draws = 0;

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

  /// Clears the board for a new round; keeps the score.
  void restart() {
    _board = List<Player?>.filled(9, null);
    currentPlayer = Player.x;
    status = GameStatus.playing;
    winner = null;
    winningLine = null;
  }

  /// Clears the board and the score.
  void resetEverything() {
    restart();
    xWins = 0;
    oWins = 0;
    draws = 0;
  }

  void _updateStatus() {
    for (final List<int> line in winningLines) {
      final Player? first = _board[line[0]];
      if (first != null && _board[line[1]] == first && _board[line[2]] == first) {
        status = GameStatus.won;
        winner = first;
        winningLine = line;
        if (first == Player.x) {
          xWins++;
        } else {
          oWins++;
        }
        return;
      }
    }

    if (!_board.contains(null)) {
      status = GameStatus.draw;
      winner = null;
      winningLine = null;
      draws++;
    }
  }
}

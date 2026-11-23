import 'package:flutter/material.dart';

import 'game_logic.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  static const Color _seed = Color(0xFF5B5BD6);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final TicTacToe _game = TicTacToe();

  static String _label(Player player) => player == Player.x ? 'X' : 'O';

  String get _statusText {
    switch (_game.status) {
      case GameStatus.won:
        return '${_label(_game.winner!)} wins!';
      case GameStatus.draw:
        return "It's a draw!";
      case GameStatus.playing:
        return "${_label(_game.currentPlayer)}'s turn";
    }
  }

  void _play(int index) {
    if (!_game.canPlay(index)) return;
    setState(() => _game.play(index));
  }

  void _newRound() => setState(_game.restart);

  void _resetScore() => setState(_game.resetEverything);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool finished = !_game.isPlaying;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Tic Tac Toe',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Two players, one device',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Scoreboard(game: _game),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _statusText,
                      key: ValueKey<String>(_statusText),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: finished
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBoard(theme),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _newRound,
                    icon: const Icon(Icons.replay_rounded),
                    label: Text(finished ? 'Play again' : 'Restart round'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _resetScore,
                    child: const Text('Reset score'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBoard(ThemeData theme) {
    return AspectRatio(
      aspectRatio: 1,
      child: Column(
        children: List<Widget>.generate(3, (int row) {
          return Expanded(
            child: Row(
              children: List<Widget>.generate(3, (int column) {
                return Expanded(child: _buildCell(row * 3 + column, theme));
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCell(int index, ThemeData theme) {
    final ColorScheme colors = theme.colorScheme;
    final Player? mark = _game.board[index];
    final bool isWinning = _game.winningLine?.contains(index) ?? false;
    final bool playable = _game.canPlay(index);

    final Color background = isWinning ? colors.primaryContainer : colors.surface;
    final Color markColor = isWinning
        ? colors.onPrimaryContainer
        : (mark == Player.x ? colors.primary : colors.tertiary);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey<String>('cell-$index'),
          borderRadius: BorderRadius.circular(18),
          onTap: playable ? () => _play(index) : null,
          child: Center(
            child: Text(
              mark == null ? '' : _label(mark),
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: markColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.game});

  final TicTacToe game;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Player? active = game.isPlaying ? game.currentPlayer : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ScoreTile(
              label: 'X',
              value: game.xWins,
              color: colors.primary,
              active: active == Player.x,
            ),
          ),
          Expanded(
            child: _ScoreTile(
              label: 'Draws',
              value: game.draws,
              color: colors.onSurfaceVariant,
              active: false,
            ),
          ),
          Expanded(
            child: _ScoreTile(
              label: 'O',
              value: game.oWins,
              color: colors.tertiary,
              active: active == Player.o,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({
    required this.label,
    required this.value,
    required this.color,
    required this.active,
  });

  final String label;
  final int value;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      children: <Widget>[
        Text(
          label,
          style: text.labelMedium?.copyWith(
            color: active ? color : colors.onSurfaceVariant,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$value',
          style: text.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

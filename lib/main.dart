import 'dart:async';

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
      home: const SetupPage(),
    );
  }
}

/// Asks for the game mode, both player names, the difficulty and the number of
/// rounds before the match.
class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final TextEditingController _xController = TextEditingController();
  final TextEditingController _oController = TextEditingController();
  int _rounds = 3;
  bool _vsComputer = false;
  Difficulty _difficulty = Difficulty.hard;

  @override
  void dispose() {
    _xController.dispose();
    _oController.dispose();
    super.dispose();
  }

  void _startGame() {
    final String xName = _xController.text.trim();
    final String oName = _oController.text.trim();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => GamePage(
          xName: xName.isEmpty ? 'Player 1' : xName,
          oName: _vsComputer
              ? 'Computer'
              : (oName.isEmpty ? 'Player 2' : oName),
          totalRounds: _rounds,
          vsComputer: _vsComputer,
          difficulty: _difficulty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tic Tac Toe'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'New match',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose who you are playing, then start the match.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SegmentedButton<bool>(
                    segments: const <ButtonSegment<bool>>[
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('2 players'),
                        icon: Icon(Icons.people_outline),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('vs Computer'),
                        icon: Icon(Icons.smart_toy_outlined),
                      ),
                    ],
                    selected: <bool>{_vsComputer},
                    onSelectionChanged: (Set<bool> selection) {
                      setState(() => _vsComputer = selection.first);
                    },
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    key: const ValueKey<String>('x-name-field'),
                    controller: _xController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: _vsComputer ? 'Your name (X)' : 'Player 1 (X)',
                      hintText: _vsComputer ? 'You' : 'Player 1',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (!_vsComputer) ...<Widget>[
                    const SizedBox(height: 16),
                    TextField(
                      key: const ValueKey<String>('o-name-field'),
                      controller: _oController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _startGame(),
                      decoration: const InputDecoration(
                        labelText: 'Player 2 (O)',
                        hintText: 'Player 2',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ] else ...<Widget>[
                    const SizedBox(height: 20),
                    _DifficultyPicker(
                      difficulty: _difficulty,
                      onChanged: (Difficulty value) {
                        setState(() => _difficulty = value);
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Matches to play',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Most wins takes the match',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          key: const ValueKey<String>('rounds-minus'),
                          onPressed: _rounds > 1
                              ? () => setState(() => _rounds--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          tooltip: 'Fewer matches',
                        ),
                        SizedBox(
                          width: 32,
                          child: Text(
                            '$_rounds',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          key: const ValueKey<String>('rounds-plus'),
                          onPressed: _rounds < 15
                              ? () => setState(() => _rounds++)
                              : null,
                          icon: const Icon(Icons.add_circle_outline),
                          tooltip: 'More matches',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start game'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyPicker extends StatelessWidget {
  const _DifficultyPicker({
    required this.difficulty,
    required this.onChanged,
  });

  final Difficulty difficulty;
  final ValueChanged<Difficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool hard = difficulty == Difficulty.hard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SegmentedButton<Difficulty>(
          segments: const <ButtonSegment<Difficulty>>[
            ButtonSegment<Difficulty>(
              value: Difficulty.easy,
              label: Text('Easy'),
              icon: Icon(Icons.sentiment_satisfied_alt_outlined),
            ),
            ButtonSegment<Difficulty>(
              value: Difficulty.hard,
              label: Text('Hard'),
              icon: Icon(Icons.local_fire_department_outlined),
            ),
          ],
          selected: <Difficulty>{difficulty},
          onSelectionChanged: (Set<Difficulty> selection) {
            onChanged(selection.first);
          },
        ),
        const SizedBox(height: 6),
        Text(
          hard
              ? 'Hard plays perfectly — the best you can get is a draw.'
              : 'Easy plays random moves.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.xName,
    required this.oName,
    required this.totalRounds,
    this.vsComputer = false,
    this.difficulty = Difficulty.hard,
  });

  final String xName;
  final String oName;
  final int totalRounds;
  final bool vsComputer;
  final Difficulty difficulty;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late Match _match;
  late final ComputerOpponent? _computer;
  Timer? _computerTimer;
  bool _computerThinking = false;

  @override
  void initState() {
    super.initState();
    _match = _newMatch();
    _computer = widget.vsComputer
        ? ComputerOpponent(mark: Player.o, difficulty: widget.difficulty)
        : null;
  }

  @override
  void dispose() {
    _computerTimer?.cancel();
    super.dispose();
  }

  Match _newMatch() => Match(
        xName: widget.xName,
        oName: widget.oName,
        totalRounds: widget.totalRounds,
      );

  bool get _isComputerTurn =>
      _computer != null && !_match.isOver && _computer.isTurn(_match.round);

  void _play(int index) {
    if (_computerThinking || _isComputerTurn) return;
    if (!_match.play(index)) return;
    setState(() {});
    _scheduleComputerMove();
  }

  void _scheduleComputerMove() {
    final ComputerOpponent? computer = _computer;
    if (computer == null || !computer.isTurn(_match.round) || _match.isOver) {
      return;
    }

    setState(() => _computerThinking = true);
    _computerTimer?.cancel();
    _computerTimer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      final int? move = computer.chooseMove(_match.round);
      setState(() {
        _computerThinking = false;
        if (move != null) _match.play(move);
      });
    });
  }

  void _primaryAction() {
    _computerTimer?.cancel();
    setState(() {
      _computerThinking = false;
      if (_match.isOver) {
        _match = _newMatch();
      } else if (_match.isRoundOver) {
        _match.nextRound();
      } else {
        _match.round.restart();
      }
    });
  }

  String get _primaryLabel {
    if (_match.isOver) return 'Play again';
    if (_match.isRoundOver) {
      return 'Next round (${_match.roundNumber} of ${_match.totalRounds})';
    }
    return 'Restart round';
  }

  String get _statusText {
    final TicTacToe round = _match.round;
    if (_match.isOver) return _match.resultText;
    if (_computerThinking) return '${widget.oName} is thinking…';
    if (round.status == GameStatus.won) {
      return '${_match.nameFor(round.winner!)} wins round ${_match.playedRounds}';
    }
    if (round.status == GameStatus.draw) {
      return 'Round ${_match.playedRounds} is a draw';
    }
    return "${_match.nameFor(round.currentPlayer)}'s turn";
  }

  String get _roundLabel {
    if (_match.isOver) return 'Match complete';
    final String base = 'Round ${_match.roundNumber} of ${_match.totalRounds}';
    final ComputerOpponent? computer = _computer;
    if (computer == null) return base;
    final String level =
        computer.difficulty == Difficulty.hard ? 'Hard' : 'Easy';
    return '$base · $level';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool highlighted = !_match.round.isPlaying;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            tooltip: 'New match',
            onPressed: () {
              _computerTimer?.cancel();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.group_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    _roundLabel,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Scoreboard(match: _match),
                  const SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _match.isOver
                          ? theme.colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _statusText,
                        key: ValueKey<String>(_statusText),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: highlighted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBoard(theme),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _primaryAction,
                    icon: const Icon(Icons.replay_rounded),
                    label: Text(_primaryLabel),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      _computerTimer?.cancel();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Change players'),
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
    final TicTacToe round = _match.round;
    final Player? mark = round.board[index];
    final bool isWinning = round.winningLine?.contains(index) ?? false;
    final bool playable =
        _match.canPlay(index) && !_computerThinking && !_isComputerTurn;

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
              mark == null ? '' : _match.markFor(mark),
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
  const _Scoreboard({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Player? active =
        !match.isOver && match.round.isPlaying ? match.round.currentPlayer : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ScoreTile(
              name: match.xName,
              mark: 'X',
              value: match.xScore,
              color: colors.primary,
              active: active == Player.x,
            ),
          ),
          Expanded(
            child: _ScoreTile(
              name: 'Draws',
              value: match.draws,
              color: colors.onSurfaceVariant,
              active: false,
            ),
          ),
          Expanded(
            child: _ScoreTile(
              name: match.oName,
              mark: 'O',
              value: match.oScore,
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
    required this.name,
    required this.value,
    required this.color,
    required this.active,
    this.mark,
  });

  final String name;
  final String? mark;
  final int value;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (mark != null) ...<Widget>[
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  mark!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: active ? color : colors.onSurfaceVariant,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'game_logic.dart';
import 'sound/game_sound.dart';

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
  final GameSound _sound = GameSound();
  Timer? _computerTimer;
  bool _computerThinking = false;
  bool _soundOn = true;
  bool _resultDialogShown = false;

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

  void _toggleSound() {
    setState(() {
      _soundOn = !_soundOn;
      _sound.enabled = _soundOn;
    });
  }

  void _playSounds() {
    final TicTacToe round = _match.round;
    if (_match.isOver) {
      _sound.matchWin();
    } else if (round.status == GameStatus.won) {
      _sound.win();
    } else if (round.status == GameStatus.draw) {
      _sound.draw();
    } else {
      _sound.tap();
    }
  }

  void _play(int index) {
    if (_computerThinking || _isComputerTurn) return;
    if (!_match.play(index)) return;
    setState(() {});
    _playSounds();
    _maybeShowResult();
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
      _playSounds();
      _maybeShowResult();
    });
  }

  /// Opens the winner popup once the round (or the match) is decided.
  void _maybeShowResult() {
    if (_resultDialogShown || _match.round.isPlaying) return;
    _resultDialogShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showResultDialog();
    });
  }

  Future<void> _showResultDialog() async {
    final bool matchOver = _match.isOver;
    final Player? winner = matchOver ? _match.winner : _match.round.winner;
    final ThemeData theme = Theme.of(context);

    final String title = winner == null
        ? (matchOver ? 'Match drawn' : 'Round ${_match.playedRounds} drawn')
        : '${_match.nameFor(winner)} wins!';
    final String subtitle = matchOver
        ? 'Final score ${_match.xScore} – ${_match.oScore}'
        : 'Round ${_match.playedRounds} of ${_match.totalRounds} · '
            '${_match.xScore} – ${_match.oScore}';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          key: const ValueKey<String>('result-dialog'),
          icon: Icon(
            winner == null
                ? Icons.handshake_outlined
                : Icons.emoji_events_rounded,
            size: 44,
            color: winner == null
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.primary,
          ),
          title: Text(
            title,
            key: const ValueKey<String>('result-dialog-title'),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              key: const ValueKey<String>('result-dialog-action'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _primaryAction();
              },
              child: Text(matchOver ? 'Play again' : 'Next round'),
            ),
          ],
        );
      },
    );
  }

  void _primaryAction() {
    _computerTimer?.cancel();
    _resultDialogShown = false;
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
            key: const ValueKey<String>('sound-toggle'),
            tooltip: _soundOn ? 'Mute sounds' : 'Unmute sounds',
            onPressed: _toggleSound,
            icon: Icon(
              _soundOn ? Icons.volume_up_outlined : Icons.volume_off_outlined,
            ),
          ),
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
                      duration: const Duration(milliseconds: 260),
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.94, end: 1)
                                .animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                            child: child,
                          ),
                        );
                      },
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

    final Widget cell = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isWinning ? colors.primary : colors.outlineVariant,
          width: isWinning ? 2 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey<String>('cell-$index'),
          borderRadius: BorderRadius.circular(18),
          onTap: playable ? () => _play(index) : null,
          child: Center(
            child: mark == null
                ? const SizedBox.shrink()
                : _MarkChip(
                    key: ValueKey<String>(
                      'mark-$index-${mark == Player.x ? 'x' : 'o'}',
                    ),
                    text: _match.markFor(mark),
                    color: markColor,
                  ),
          ),
        ),
      ),
    );

    if (!isWinning) return cell;

    // One soft pulse on the winning line when a round ends.
    return TweenAnimationBuilder<double>(
      key: ValueKey<String>('win-pulse-$index-${_match.playedRounds}'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeInOut,
      builder: (BuildContext context, double value, Widget? child) {
        final double pulse = math.sin(value * math.pi);
        return Transform.scale(scale: 1 + 0.05 * pulse, child: child);
      },
      child: cell,
    );
  }
}

/// The X or O mark, popping in when it is placed.
class _MarkChip extends StatelessWidget {
  const _MarkChip({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.3, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 52,
          fontWeight: FontWeight.w800,
          color: color,
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: Tween<double>(begin: 1.4, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Text(
            '$value',
            key: ValueKey<int>(value),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

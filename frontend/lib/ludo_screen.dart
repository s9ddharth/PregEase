import 'dart:math';
import 'package:flutter/material.dart';

enum LudoColor { red, green, yellow, blue }

class _LudoPlayer {
  final LudoColor color;
  final String name;
  const _LudoPlayer(this.color, this.name);
}

class _LudoToken {
  final LudoColor color;
  final int id;
  int progress; // -1 = base, 0..51 = common track, 52..57 = home lane.
  _LudoToken(this.color, this.id) : progress = -1;
}

class LudoScreen extends StatefulWidget {
  const LudoScreen({super.key});

  @override
  State<LudoScreen> createState() => _LudoScreenState();
}

class _LudoScreenState extends State<LudoScreen> {
  static const _ink = Color(0xFF26352D);
  static const _cream = Color(0xFFFFFBF5);
  static const _line = Color(0xFFE8E0D4);

  static const _path = <Point<int>>[
    Point(6, 1), Point(6, 2), Point(6, 3), Point(6, 4), Point(6, 5),
    Point(5, 6), Point(4, 6), Point(3, 6), Point(2, 6), Point(1, 6),
    Point(0, 6), Point(0, 7), Point(0, 8), Point(1, 8), Point(2, 8),
    Point(3, 8), Point(4, 8), Point(5, 8), Point(6, 9), Point(6, 10),
    Point(6, 11), Point(6, 12), Point(6, 13), Point(6, 14), Point(7, 14),
    Point(8, 14), Point(8, 13), Point(8, 12), Point(8, 11), Point(8, 10),
    Point(8, 9), Point(9, 8), Point(10, 8), Point(11, 8), Point(12, 8),
    Point(13, 8), Point(14, 8), Point(14, 7), Point(14, 6), Point(13, 6),
    Point(12, 6), Point(11, 6), Point(10, 6), Point(9, 6), Point(8, 5),
    Point(8, 4), Point(8, 3), Point(8, 2), Point(8, 1), Point(8, 0),
    Point(7, 0), Point(6, 0),
  ];

  static const _starts = {
    LudoColor.red: 0,
    LudoColor.green: 13,
    LudoColor.yellow: 26,
    LudoColor.blue: 39,
  };

  static const _homeLanes = {
    LudoColor.red: [
      Point(7, 1), Point(7, 2), Point(7, 3), Point(7, 4), Point(7, 5), Point(7, 6),
    ],
    LudoColor.green: [
      Point(1, 7), Point(2, 7), Point(3, 7), Point(4, 7), Point(5, 7), Point(6, 7),
    ],
    LudoColor.yellow: [
      Point(7, 13), Point(7, 12), Point(7, 11), Point(7, 10), Point(7, 9), Point(7, 8),
    ],
    LudoColor.blue: [
      Point(13, 7), Point(12, 7), Point(11, 7), Point(10, 7), Point(9, 7), Point(8, 7),
    ],
  };

  static const _safeIndices = {0, 8, 13, 21, 26, 34, 39, 47};

  int _playerCount = 2;
  final List<TextEditingController> _nameControllers = [
    TextEditingController(text: 'Player 1'),
    TextEditingController(text: 'Player 2'),
    TextEditingController(text: 'Player 3'),
    TextEditingController(text: 'Player 4'),
  ];
  bool _started = false;
  int _turn = 0;
  int? _dice;
  bool _rolling = false;
  bool _awaitingMove = false;
  String _status = 'Choose players to start a friendly game.';
  List<_LudoPlayer> _players = const [];
  late List<_LudoToken> _tokens;
  final _random = Random();
  int? _winnerIndex;

  @override
  void initState() {
    super.initState();
    _tokens = [];
  }

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Color _color(LudoColor color) {
    switch (color) {
      case LudoColor.red:
        return const Color(0xFFFF6262);
      case LudoColor.green:
        return const Color(0xFF52C878);
      case LudoColor.yellow:
        return const Color(0xFFFFC94A);
      case LudoColor.blue:
        return const Color(0xFF5C9CFF);
    }
  }

  Color _softColor(LudoColor color) {
    switch (color) {
      case LudoColor.red:
        return const Color(0xFFFFE3E0);
      case LudoColor.green:
        return const Color(0xFFE1F3E6);
      case LudoColor.yellow:
        return const Color(0xFFFFF0C8);
      case LudoColor.blue:
        return const Color(0xFFE3ECFF);
    }
  }

  String _emoji(LudoColor color) {
    switch (color) {
      case LudoColor.red:
        return '🔴';
      case LudoColor.green:
        return '🟢';
      case LudoColor.yellow:
        return '🟡';
      case LudoColor.blue:
        return '🔵';
    }
  }

  void _startGame() {
    final colors = <LudoColor>[
      LudoColor.red,
      LudoColor.green,
      LudoColor.yellow,
      LudoColor.blue,
    ].take(_playerCount).toList();

    setState(() {
      _players = [
        for (var i = 0; i < colors.length; i++)
          _LudoPlayer(
            colors[i],
            _nameControllers[i].text.trim().isEmpty
                ? 'Player ${i + 1}'
                : _nameControllers[i].text.trim(),
          ),
      ];
      _tokens = [
        for (final player in _players)
          for (var i = 0; i < 4; i++) _LudoToken(player.color, i),
      ];
      _started = true;
      _turn = 0;
      _dice = null;
      _rolling = false;
      _awaitingMove = false;
      _winnerIndex = null;
      _status = '${_players.first.name}, roll the dice!';
    });
  }

  void _newGame() {
    setState(() {
      _started = false;
      _dice = null;
      _winnerIndex = null;
      _status = 'Choose players to start a friendly game.';
    });
  }

  Future<void> _rollDice() async {
    if (!_started || _rolling || _awaitingMove || _winnerIndex != null) return;

    setState(() => _rolling = true);

    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 85));
      if (!mounted) return;
      setState(() => _dice = 1 + _random.nextInt(6));
    }

    final value = 1 + _random.nextInt(6);
    final player = _players[_turn];
    final legal = _legalTokens(player.color, value);

    if (!mounted) return;
    setState(() {
      _dice = value;
      _rolling = false;
      _awaitingMove = legal.isNotEmpty;
      _status = legal.isEmpty
          ? '${player.name} rolled $value. No move — next turn.'
          : legal.length == 1
              ? '${player.name}, move your highlighted token.'
              : '${player.name}, choose a token to move.';
    });

    if (legal.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 750));
      if (!mounted) return;
      _nextTurn(extra: value == 6);
    }
  }

  List<_LudoToken> _legalTokens(LudoColor color, int dice) {
    return _tokens
        .where((token) =>
            token.color == color && _canMove(token, dice))
        .toList();
  }

  bool _canMove(_LudoToken token, int dice) {
    if (token.progress == 57) return false;
    if (token.progress == -1) return dice == 6;
    return token.progress + dice <= 57;
  }

  Future<void> _moveToken(_LudoToken token) async {
    if (_dice == null || _winnerIndex != null || _rolling || !_awaitingMove) {
      return;
    }
    if (token.color != _players[_turn].color || !_canMove(token, _dice!)) {
      return;
    }

    final dice = _dice!;

    // A token in base has a special Ludo rule:
    // the first 6 only unlocks it onto its start square.
    // It must NOT travel six squares. After unlocking, the player gets
    // another roll in the same turn.
    final isUnlockingFromBase = token.progress == -1 && dice == 6;

    setState(() {
      _awaitingMove = false;
      _status = isUnlockingFromBase
          ? '${_players[_turn].name} is bringing token ${token.id + 1} into play…'
          : '${_players[_turn].name} is moving token ${token.id + 1}…';
    });

    if (isUnlockingFromBase) {
      // Move the token from the base to its start square only.
      // There is deliberately NO six-square movement here.
      if (!mounted) return;
      setState(() {
        token.progress = 0;
        _capture(token);
      });

      // Give the player time to see the token enter the board.
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      // Clear the old 6 and award the extra roll.
      _nextTurn(extra: true);
      return;
    }

    // Normal movement: move exactly one board square at a time.
    for (var step = 0; step < dice; step++) {
      if (!mounted) return;

      setState(() {
        token.progress += 1;
      });

      // Slow enough to clearly see every square.
      await Future<void>.delayed(const Duration(milliseconds: 420));
    }

    if (!mounted) return;

    setState(() {
      _capture(token);
      _status = '${_players[_turn].name} moved token ${token.id + 1}.';
    });

    if (_hasWon(token.color)) {
      setState(() {
        _winnerIndex = _turn;
        _status = '🎉 ${_players[_turn].name} wins!';
      });
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    _nextTurn(extra: dice == 6);
  }

  void _capture(_LudoToken moved) {
    final boardIndex = _commonPathIndex(moved);
    if (boardIndex == null || _safeIndices.contains(boardIndex)) return;

    for (final other in _tokens) {
      if (other == moved || other.color == moved.color) continue;
      if (_commonPathIndex(other) == boardIndex) {
        other.progress = -1;
      }
    }
  }

  int? _commonPathIndex(_LudoToken token) {
    if (token.progress < 0 || token.progress > 51) return null;
    final start = _starts[token.color]!;
    return (start + token.progress) % 52;
  }

  bool _hasWon(LudoColor color) {
    return _tokens
            .where((token) => token.color == color)
            .every((token) => token.progress == 57);
  }

  void _nextTurn({required bool extra}) {
    if (_winnerIndex != null) return;
    setState(() {
      _dice = null;
      if (!extra) {
        _turn = (_turn + 1) % _players.length;
      }
      _status = extra
          ? '${_players[_turn].name} gets another roll!'
          : '${_players[_turn].name}, roll the dice!';
    });
  }

  Point<int>? _boardPoint(_LudoToken token) {
    if (token.progress == -1 || token.progress == 57) return null;
    if (token.progress <= 51) {
      final index = _commonPathIndex(token)!;
      return _path[index];
    }
    return _homeLanes[token.color]![token.progress - 52];
  }

  List<_LudoToken> _tokensAt(Point<int> point) {
    return _tokens.where((token) => _boardPoint(token) == point).toList();
  }

  Offset _tokenOffset(int row, int col, double cell) {
    return Offset(col * cell + cell / 2, row * cell + cell / 2);
  }

  bool _isCurrentPlayerToken(_LudoToken token) =>
      _started && token.color == _players[_turn].color;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        foregroundColor: _ink,
        elevation: 0,
        title: const Text(
          'Ludo',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          if (_started)
            IconButton(
              tooltip: 'New game',
              onPressed: _newGame,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _started ? _buildGame() : _buildSetup(),
        ),
      ),
    );
  }

  Widget _buildSetup() {
    final colors = [
      LudoColor.red,
      LudoColor.green,
      LudoColor.yellow,
      LudoColor.blue,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB38E), Color(0xFFE86D76)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🎲', style: TextStyle(fontSize: 42)),
              SizedBox(height: 8),
              Text(
                'A little Ludo break?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Set up your players, then pass the phone around and play.',
                style: TextStyle(
                  color: Colors.white,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'How many players?',
          style: TextStyle(
            color: _ink,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'The full 4-colour Ludo board stays on screen.',
          style: TextStyle(color: Color(0xFF6D756D)),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            for (final count in [2, 3, 4])
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: count == 4 ? 0 : 9),
                  child: _playerCountButton(count),
                ),
              ),
          ],
        ),
        const SizedBox(height: 26),
        const Text(
          'Name your players',
          style: TextStyle(
            color: _ink,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Names make the turn screen much more fun.',
          style: TextStyle(color: Color(0xFF6D756D)),
        ),
        const SizedBox(height: 13),
        for (var i = 0; i < _playerCount; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _playerNameField(
              index: i,
              color: colors[i],
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _startGame,
            icon: const Icon(Icons.casino_rounded),
            label: const Text('Start Ludo'),
            style: FilledButton.styleFrom(
              backgroundColor: _ink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _playerCountButton(int count) {
    final selected = _playerCount == count;
    return InkWell(
      onTap: () => setState(() => _playerCount = count),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFE8DD) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFFF9478) : _line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: const TextStyle(
                color: _ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              count == 1 ? 'player' : 'players',
              style: const TextStyle(
                color: Color(0xFF737A72),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerNameField({
    required int index,
    required LudoColor color,
  }) {
    return TextField(
      controller: _nameControllers[index],
      textCapitalization: TextCapitalization.words,
      maxLength: 18,
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 13, right: 9),
          child: Center(
            widthFactor: 1,
            child: Text(
              _emoji(color),
              style: const TextStyle(fontSize: 21),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        labelText: 'Player ${index + 1}',
        hintText: 'Enter name',
        labelStyle: const TextStyle(
          color: Color(0xFF737A72),
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _color(color), width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildGame() {
    final current = _players[_turn];
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      children: [
        _buildTurnHeader(current),
        const SizedBox(height: 12),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: AspectRatio(
              aspectRatio: 1,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cell = constraints.maxWidth / 15;
                  return _buildBoard(cell);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _buildDicePanel(current),
        const SizedBox(height: 14),
        _buildPlayersRow(),
      ],
    );
  }

  Widget _buildTurnHeader(_LudoPlayer current) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: _softColor(current.color),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _color(current.color).withValues(alpha: .22)),
      ),
      child: Row(
        children: [
          Text(_emoji(current.color), style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _winnerIndex == null ? '${current.name}’s turn' : 'Game complete',
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _status,
                  style: const TextStyle(color: Color(0xFF687168), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(double cell) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _line, width: 2),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _LudoBoardPainter(
                  colors: {
                    LudoColor.red: _color(LudoColor.red),
                    LudoColor.green: _color(LudoColor.green),
                    LudoColor.yellow: _color(LudoColor.yellow),
                    LudoColor.blue: _color(LudoColor.blue),
                  },
                  path: _path,
                  starts: _starts,
                  homeLanes: _homeLanes,
                  safeIndices: _safeIndices,
                ),
              ),
            ),
            for (final token in _tokens)
              if (_boardPoint(token) != null)
                _buildToken(token, cell),
            for (final token in _tokens)
              if (token.progress == -1)
                _buildBaseToken(token, cell),
            for (final token in _tokens)
              if (token.progress == 57)
                _buildFinishedToken(token, cell),
            if (_winnerIndex != null)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withValues(alpha: .78),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                      decoration: BoxDecoration(
                        color: _softColor(_players[_winnerIndex!].color),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _color(_players[_winnerIndex!].color).withValues(alpha: .35),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 38)),
                          const SizedBox(height: 5),
                          Text(
                            '${_players[_winnerIndex!].name} wins!',
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBaseToken(_LudoToken token, double cell) {
    final point = _basePoint(token.color, token.id);
    final offset = _tokenOffset(point.x, point.y, cell);
    final legal = _dice != null &&
        _isCurrentPlayerToken(token) &&
        _canMove(token, _dice!);

    final size = max(23.0, min(32.0, cell * .72));

    return Positioned(
      left: offset.dx - size / 2,
      top: offset.dy - size / 2,
      child: GestureDetector(
        onTap: legal ? () => _moveToken(token) : null,
        child: AnimatedScale(
          scale: legal ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 320),
          child: _tokenVisual(
            token,
            size,
            legal: legal,
            base: true,
          ),
        ),
      ),
    );
  }

  Widget _buildFinishedToken(_LudoToken token, double cell) {
    final finished = _tokens
        .where((item) => item.color == token.color && item.progress == 57)
        .toList();
    final position = finished.indexOf(token);

    const center = Point<int>(7, 7);
    final spread = Offset(
      (position % 2 == 0 ? -0.22 : 0.22) * cell,
      (position ~/ 2 == 0 ? -0.22 : 0.22) * cell,
    );
    final offset = _tokenOffset(center.x, center.y, cell) + spread;
    final size = max(21.0, min(29.0, cell * .64));

    return Positioned(
      left: offset.dx - size / 2,
      top: offset.dy - size / 2,
      child: _tokenVisual(
        token,
        size,
        legal: false,
        base: false,
        finished: true,
      ),
    );
  }

  Point<int> _basePoint(LudoColor color, int id) {
    const red = [
      Point<int>(1, 1),
      Point<int>(4, 1),
      Point<int>(1, 4),
      Point<int>(4, 4),
    ];
    // Match the board quadrants painted below:
    // red = top-left, green = top-right,
    // yellow = bottom-right, blue = bottom-left.
    const green = [
      Point<int>(1, 10),
      Point<int>(4, 10),
      Point<int>(1, 13),
      Point<int>(4, 13),
    ];
    const yellow = [
      Point<int>(10, 10),
      Point<int>(13, 10),
      Point<int>(10, 13),
      Point<int>(13, 13),
    ];
    const blue = [
      Point<int>(10, 1),
      Point<int>(13, 1),
      Point<int>(10, 4),
      Point<int>(13, 4),
    ];

    final points = switch (color) {
      LudoColor.red => red,
      LudoColor.green => green,
      LudoColor.yellow => yellow,
      LudoColor.blue => blue,
    };
    return points[id.clamp(0, 3)];
  }

  Widget _tokenVisual(
    _LudoToken token,
    double size, {
    required bool legal,
    required bool base,
    bool finished = false,
  }) {
    final color = _color(token.color);
    final dark = Color.lerp(color, Colors.black, .20)!;
    final light = Color.lerp(Colors.white, color, .22)!;

    // A cleaner classic Ludo counter: colored body, raised rim,
    // white inset and a small numbered center.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-.32, -.36),
          radius: .82,
          colors: [light, color, dark],
          stops: const [0.0, .58, 1.0],
        ),
        border: Border.all(
          color: Colors.white,
          width: legal ? 2.8 : 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: legal ? .25 : .16),
            blurRadius: legal ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Raised inner ring.
          Container(
            width: size * .62,
            height: size * .62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .90),
              border: Border.all(
                color: color.withValues(alpha: .65),
                width: 1.5,
              ),
            ),
          ),
          if (finished)
            Icon(
              Icons.home_rounded,
              color: color,
              size: size * .36,
            )
          else
            Text(
              '${token.id + 1}',
              style: TextStyle(
                color: dark,
                fontSize: size * .27,
                fontWeight: FontWeight.w900,
              ),
            ),
          // Small glossy highlight.
          Positioned(
            top: size * .11,
            left: size * .20,
            child: Container(
              width: size * .20,
              height: size * .09,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .72),
                borderRadius: BorderRadius.circular(size),
              ),
            ),
          ),
          if (base && legal)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToken(_LudoToken token, double cell) {
    final point = _boardPoint(token)!;
    final offset = _tokenOffset(point.x, point.y, cell);
    final sameSpot = _tokensAt(point);
    final position = sameSpot.indexOf(token);
    final spread = sameSpot.length > 1
        ? Offset(
            (position % 2 == 0 ? -0.17 : 0.17) * cell,
            (position ~/ 2 == 0 ? -0.17 : 0.17) * cell,
          )
        : Offset.zero;

    final legal = _dice != null &&
        _isCurrentPlayerToken(token) &&
        _canMove(token, _dice!);

    final size = max(22.0, min(31.0, cell * .68));

    return Positioned(
      left: offset.dx - size / 2 + spread.dx,
      top: offset.dy - size / 2 + spread.dy,
      child: GestureDetector(
        onTap: legal ? () => _moveToken(token) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(_color(token.color), Colors.white, 0.28)!,
                _color(token.color),
                Color.lerp(_color(token.color), Colors.black, 0.10)!,
              ],
              stops: const [0.0, 0.48, 1.0],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: legal ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: legal ? .22 : .12),
                blurRadius: legal ? 9 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size * .48,
                height: size * .48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .92),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .10),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              Text(
                '${token.id + 1}',
                style: TextStyle(
                  color: _color(token.color),
                  fontSize: size * .32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDicePanel(_LudoPlayer current) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: (_rolling || _awaitingMove || _winnerIndex != null) ? null : _rollDice,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _color(current.color),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _color(current.color).withValues(alpha: .24),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _dice == null ? '🎲' : '$_dice',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _dice == null ? 29 : 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dice == null ? 'Ready?' : 'You rolled $_dice',
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _winnerIndex != null
                      ? 'Start a new game to play again.'
                      : _dice == null
                          ? 'Tap the dice to roll.'
                          : 'Tap a highlighted token to move it.',
                  style: const TextStyle(
                    color: Color(0xFF707870),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (_winnerIndex != null)
            TextButton(
              onPressed: _newGame,
              child: const Text('New game'),
            )
          else
            FilledButton(
              onPressed: _rolling ? null : _rollDice,
              style: FilledButton.styleFrom(
                backgroundColor: _ink,
                foregroundColor: Colors.white,
              ),
              child: const Text('Roll'),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayersRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < _players.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: i == _turn && _winnerIndex == null
                  ? _softColor(_players[i].color)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: i == _turn && _winnerIndex == null
                    ? _color(_players[i].color).withValues(alpha: .3)
                    : _line,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_emoji(_players[i].color), style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                Text(
                  _players[i].name,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LudoBoardPainter extends CustomPainter {
  final Map<LudoColor, Color> colors;
  final List<Point<int>> path;
  final Map<LudoColor, int> starts;
  final Map<LudoColor, List<Point<int>>> homeLanes;
  final Set<int> safeIndices;

  _LudoBoardPainter({
    required this.colors,
    required this.path,
    required this.starts,
    required this.homeLanes,
    required this.safeIndices,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 15;
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFD9D2C7);

    final fill = Paint()..style = PaintingStyle.fill;

    void rect(int row, int col, Color color) {
      fill.color = color;
      canvas.drawRect(
        Rect.fromLTWH(col * cell, row * cell, cell, cell),
        fill,
      );
      canvas.drawRect(
        Rect.fromLTWH(col * cell, row * cell, cell, cell),
        border,
      );
    }

    // Four traditional 6x6 home quadrants.
    final homes = {
      LudoColor.red: const Rect.fromLTWH(0, 0, 6, 6),
      LudoColor.green: const Rect.fromLTWH(9, 0, 6, 6),
      LudoColor.yellow: const Rect.fromLTWH(9, 9, 6, 6),
      LudoColor.blue: const Rect.fromLTWH(0, 9, 6, 6),
    };

    for (final entry in homes.entries) {
      fill.color = colors[entry.key]!.withValues(alpha: .20);
      canvas.drawRect(
        Rect.fromLTWH(
          entry.value.left * cell,
          entry.value.top * cell,
          entry.value.width * cell,
          entry.value.height * cell,
        ),
        fill,
      );
      final inner = Rect.fromLTWH(
        (entry.value.left + 1) * cell,
        (entry.value.top + 1) * cell,
        4 * cell,
        4 * cell,
      );
      fill.color = Colors.white.withValues(alpha: .88);
      canvas.drawRRect(
        RRect.fromRectAndRadius(inner, Radius.circular(cell * .35)),
        fill,
      );
      final spots = [
        Offset(inner.left + inner.width * .28, inner.top + inner.height * .28),
        Offset(inner.left + inner.width * .72, inner.top + inner.height * .28),
        Offset(inner.left + inner.width * .28, inner.top + inner.height * .72),
        Offset(inner.left + inner.width * .72, inner.top + inner.height * .72),
      ];
      for (final spot in spots) {
        fill.color = colors[entry.key]!.withValues(alpha: .27);
        canvas.drawCircle(spot, cell * .34, fill);
        fill.color = colors[entry.key]!;
        canvas.drawCircle(spot, cell * .20, fill);
      }
    }

    // Main track.
    for (var i = 0; i < path.length; i++) {
      final p = path[i];
      rect(p.x, p.y, Colors.white);
    }

    // Home lanes.
    for (final entry in homeLanes.entries) {
      for (final p in entry.value) {
        rect(p.x, p.y, colors[entry.key]!.withValues(alpha: .55));
      }
    }

    // Start cells.
    for (final entry in starts.entries) {
      final p = path[entry.value];
      rect(p.x, p.y, colors[entry.key]!.withValues(alpha: .72));
    }

    // Safe stars.
    for (final index in safeIndices) {
      final p = path[index];
      final center = Offset(p.y * cell + cell / 2, p.x * cell + cell / 2);
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '★',
          style: TextStyle(
            color: Color(0xFF8E918A),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Center home triangle.
    final center = Offset(7.5 * cell, 7.5 * cell);
    final half = 1.5 * cell;
    final redPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - half, center.dy - half)
      ..lineTo(center.dx, center.dy - half)
      ..close();
    fill.color = colors[LudoColor.red]!;
    canvas.drawPath(redPath, fill);

    final greenPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + half, center.dy - half)
      ..lineTo(center.dx + half, center.dy)
      ..close();
    fill.color = colors[LudoColor.green]!;
    canvas.drawPath(greenPath, fill);

    final yellowPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + half, center.dy + half)
      ..lineTo(center.dx, center.dy + half)
      ..close();
    fill.color = colors[LudoColor.yellow]!;
    canvas.drawPath(yellowPath, fill);

    final bluePath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - half, center.dy + half)
      ..lineTo(center.dx - half, center.dy)
      ..close();
    fill.color = colors[LudoColor.blue]!;
    canvas.drawPath(bluePath, fill);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFD4CCBF),
    );
  }

  @override
  bool shouldRepaint(covariant _LudoBoardPainter oldDelegate) => true;
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WellnessScreen extends StatefulWidget {
  final String apiBaseUrl;
  final Future<Map<String, String>> Function() authHeaders;

  const WellnessScreen({
    super.key,
    required this.apiBaseUrl,
    required this.authHeaders,
  });

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  static const Color _ink = Color(0xFF302D42);
  static const Color _muted = Color(0xFF777487);
  static const Color _coral = Color(0xFFF27679);
  static const Color _pink = Color(0xFFFFE5E9);
  static const Color _lavender = Color(0xFFEAE5FF);
  static const Color _mint = Color(0xFFDDF3E7);
  static const Color _cream = Color(0xFFFFF7E9);
  static const Color _sky = Color(0xFFE1F2FA);

  final Map<String, int> _scores = {
    'mood_score': 3,
    'stress_score': 3,
    'anxiety_score': 3,
    'sleep_score': 3,
    'support_score': 3,
  };

  final Map<String, String> _questions = {
    'mood_score': 'How has your mood been?',
    'stress_score': 'How stressed have you felt?',
    'anxiety_score': 'How anxious have you felt?',
    'sleep_score': 'How has your sleep been?',
    'support_score': 'How supported do you feel?',
  };

  final Map<String, List<String>> _labels = {
    'mood_score': ['Very low', 'Low', 'Okay', 'Good', 'Very good'],
    'stress_score': ['Very low', 'Low', 'Moderate', 'High', 'Very high'],
    'anxiety_score': ['Very low', 'Low', 'Moderate', 'High', 'Very high'],
    'sleep_score': ['Very poor', 'Poor', 'Okay', 'Good', 'Very good'],
    'support_score': ['No support', 'Little', 'Some', 'Good', 'Strong'],
  };

  final Map<String, String> _emojis = {
    'mood_score': '😊',
    'stress_score': '🌿',
    'anxiety_score': '💗',
    'sleep_score': '🌙',
    'support_score': '🤝',
  };

  final Map<String, Color> _questionColors = {
    'mood_score': _pink,
    'stress_score': _mint,
    'anxiety_score': _lavender,
    'sleep_score': _sky,
    'support_score': _cream,
  };

  bool _loading = false;
  bool _historyLoading = true;
  String? _error;
  Map<String, dynamic>? _result;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (mounted) {
      setState(() => _historyLoading = true);
    }

    try {
      final response = await http.get(
        Uri.parse('${widget.apiBaseUrl}/wellness/check-ins?limit=10'),
        headers: await widget.authHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to load wellness history.');
      }

      if (!mounted) return;
      setState(() {
        _history = jsonDecode(response.body) as List<dynamic>;
        _historyLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _historyLoading = false);
    }
  }

  Future<void> _submitCheckin() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${widget.apiBaseUrl}/wellness/check-ins'),
        headers: await widget.authHeaders(),
        body: jsonEncode(_scores),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Unable to save check-in (${response.statusCode}). '
          '${response.body}',
        );
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;

      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });

      await _loadHistory();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Widget _ratingQuestion(String key, int index) {
    final labels = _labels[key]!;
    final selectedScore = _scores[key]!;
    final tint = _questionColors[key]!;
    final scoreEmojis = key == 'mood_score'
        ? ['😔', '🙁', '😐', '🙂', '😄']
        : key == 'stress_score' || key == 'anxiety_score'
            ? ['😌', '🙂', '😐', '😟', '😣']
            : key == 'sleep_score'
                ? ['🥱', '😴', '🌙', '✨', '🌞']
                : ['🫥', '🤍', '💛', '💚', '💖'];

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0EAF0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4D3B56).withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _emojis[key]!,
                  style: const TextStyle(fontSize: 23),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CHECK-IN ${index + 1}',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 9,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _questions[key]!,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: List.generate(5, (scoreIndex) {
              final value = scoreIndex + 1;
              final selected = selectedScore == value;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: scoreIndex == 4 ? 0 : 7,
                  ),
                  child: Semantics(
                    button: true,
                    selected: selected,
                    label: '${labels[scoreIndex]}, rating $value of 5',
                    child: Material(
                      color: selected ? tint : const Color(0xFFFAF8FB),
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () => setState(() => _scores[key] = value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          constraints: const BoxConstraints(minHeight: 69),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: selected
                                  ? _coral
                                  : const Color(0xFFF0EAF0),
                              width: selected ? 1.6 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                scoreEmojis[scoreIndex],
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$value',
                                style: TextStyle(
                                  color: selected ? _ink : _muted,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: _coral,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  labels[selectedScore - 1],
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$selectedScore / 5',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFB8B5), Color(0xFFFF8C98), Color(0xFFE97891)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _coral.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -48,
            right: -25,
            child: Container(
              width: 175,
              height: 175,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 25,
            top: 48,
            child: Transform.rotate(
              angle: 0.13,
              child: const Text('🌷', style: TextStyle(fontSize: 62)),
            ),
          ),
          Positioned(
            right: 96,
            bottom: 22,
            child: Transform.rotate(
              angle: -0.16,
              child: const Text('💗', style: TextStyle(fontSize: 30)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.36),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'YOUR LITTLE MOMENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          letterSpacing: 0.9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 23),
                const SizedBox(
                  width: 245,
                  child: Text(
                    'How are you, really?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 31,
                      height: 1.05,
                      letterSpacing: -0.8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                const SizedBox(
                  width: 235,
                  child: Text(
                    'Pause, take a breath, and check in with yourself. Every feeling belongs here.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 19),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE8B5),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Text(
                    'NO RIGHT OR WRONG ANSWERS ✨',
                    style: TextStyle(
                      color: Color(0xFF76532F),
                      fontSize: 9,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _lavender,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: const Color(0xFF7969B5), size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(Object? level, Object? guidance) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_mint, Color(0xFFF1FAF4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCBE8D6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text('🌱', style: TextStyle(fontSize: 23)),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'Your check-in',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            level.toString(),
            style: const TextStyle(
              color: Color(0xFF347651),
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (guidance != null && guidance.toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              guidance.toString(),
              style: const TextStyle(
                color: _ink,
                height: 1.5,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 13),
          const Divider(color: Color(0xFFCBE8D6)),
          const SizedBox(height: 5),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 17, color: _muted),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'This check-in is a self-reflection tool, not a diagnosis. If you feel worried about your wellbeing, reach out to a healthcare professional or someone you trust.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    if (_historyLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: _coral,
          ),
        ),
      );
    }

    if (_history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _sky.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Row(
          children: [
            Text('🫧', style: TextStyle(fontSize: 31)),
            SizedBox(width: 13),
            Expanded(
              child: Text(
                'Your check-in history will appear here. Each small pause counts.',
                style: TextStyle(
                  color: _ink,
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _history.map((entry) {
        final item = Map<String, dynamic>.from(entry as Map);
        final level = item['overall_level']?.toString() ?? 'Check-in';
        final createdAt = item['created_at']?.toString() ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xFFF0EAF0)),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _questionColors[_historyColorKey(level)] ?? _pink,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: _coral,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (createdAt.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        createdAt,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFFB8B0C2),
                size: 15,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _historyColorKey(String level) {
    final value = level.toLowerCase();
    if (value.contains('good') || value.contains('low')) return 'support_score';
    if (value.contains('moderate')) return 'sleep_score';
    return 'mood_score';
  }

  @override
  Widget build(BuildContext context) {
    final level = _result?['overall_level'];
    final guidance = _result?['guidance'];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFAF8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Wellness',
          style: TextStyle(
            color: _ink,
            fontSize: 21,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF0E6DA)),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth > 760 ? 700.0 : 560.0;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
            children: [
              Center(
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHero(),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Icon(
                            Icons.spa_rounded,
                            color: Color(0xFF67A783),
                            size: 19,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Take this at your own pace',
                              style: TextStyle(
                                color: _ink,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _cream,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '5 QUESTIONS',
                              style: TextStyle(
                                color: Color(0xFF8A693A),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Choose the answer that feels closest to today. There is no need to overthink it.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 17),
                      ..._questions.keys.toList().asMap().entries.map(
                            (entry) => _ratingQuestion(entry.value, entry.key),
                          ),
                      if (_error != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8E8),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: Color(0xFFB43F4B),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Color(0xFF9B303D),
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 55,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: _coral,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _loading ? null : _submitCheckin,
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.favorite_rounded, size: 19),
                                    SizedBox(width: 9),
                                    Text(
                                      'Save my check-in',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                        ),
                      ),
                      if (level != null) _buildResult(level, guidance),
                      const SizedBox(height: 27),
                      _sectionHeading(
                        title: 'Your wellness journey',
                        subtitle: 'A gentle look back at your recent check-ins',
                        icon: Icons.auto_awesome_rounded,
                      ),
                      _buildHistory(),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _lavender.withValues(alpha: 0.58),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('🫶', style: TextStyle(fontSize: 24)),
                            SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                'A gentle reminder: your wellbeing matters, too. It is okay to ask for support and to take things one day at a time.',
                                style: TextStyle(
                                  color: _ink,
                                  fontSize: 12,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

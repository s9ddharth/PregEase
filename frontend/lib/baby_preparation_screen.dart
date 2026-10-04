import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BabyPreparationScreen extends StatefulWidget {
  final String apiBaseUrl;
  final Future<Map<String, String>> Function() authHeaders;

  const BabyPreparationScreen({
    super.key,
    required this.apiBaseUrl,
    required this.authHeaders,
  });

  @override
  State<BabyPreparationScreen> createState() => _BabyPreparationScreenState();
}

class _BabyPreparationScreenState extends State<BabyPreparationScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _data;
  final Set<String> _savingItems = {};

  static const Color _ink = Color(0xFF343044);
  static const Color _muted = Color(0xFF777487);
  static const Color _coral = Color(0xFFE98278);
  static const Color _peach = Color(0xFFFFE8DF);
  static const Color _mint = Color(0xFFE2F2E9);
  static const Color _lilac = Color(0xFFEDE6FA);
  static const Color _butter = Color(0xFFFFF1C9);

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final headers = await widget.authHeaders();
      final response = await http.get(
        Uri.parse('${widget.apiBaseUrl}/pregnancy/baby-preparation'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Could not load checklist (${response.statusCode}). ${response.body}',
        );
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;

      if (!mounted) return;
      setState(() {
        _data = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateItem(
    Map<String, dynamic> item,
    bool completed,
  ) async {
    final key = item['key'] as String;
    final week = _data?['checklist_week'] as int?;

    if (week == null) return;

    final oldValue = item['is_completed'] == true;

    setState(() {
      item['is_completed'] = completed;
      _savingItems.add(key);
    });

    try {
      final headers = await widget.authHeaders();
      final response = await http.put(
        Uri.parse(
          '${widget.apiBaseUrl}/pregnancy/baby-preparation/checklist-item',
        ),
        headers: headers,
        body: jsonEncode({
          'week': week,
          'item_key': key,
          'is_completed': completed,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Could not save checklist item (${response.statusCode}).',
        );
      }

      await _loadChecklist();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        item['is_completed'] = oldValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not save that update. Please try again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF494354),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _savingItems.remove(key));
      }
    }
  }

  Widget _buildHero(int completed, int total) {
    final progress = total <= 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE4D9), Color(0xFFFFF0D5), Color(0xFFF4E9FA)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'LITTLE STEPS, BIG LOVE',
                        style: TextStyle(
                          color: Color(0xFFC96E66),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Getting ready\nfor your little one',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 26,
                        height: 1.13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'One small step at a time. You’ve got this!',
                      style: TextStyle(
                        color: _ink.withValues(alpha: 0.72),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 82,
                height: 94,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 11,
                      right: 11,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.amber.shade700,
                        size: 18,
                      ),
                    ),
                    const Icon(
                      Icons.child_friendly_rounded,
                      size: 54,
                      color: Color(0xFFD98983),
                    ),
                    const Positioned(
                      bottom: 9,
                      child: Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFF9B789C),
                        size: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                    backgroundColor: Colors.white.withValues(alpha: 0.8),
                    valueColor: const AlwaysStoppedAnimation<Color>(_coral),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF4F9074), size: 17),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '$completed of $total tasks completed',
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                'Week ${_data?['checklist_week'] ?? '-'}',
                style: TextStyle(
                  color: _ink.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuidance(String guidance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3F7),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Color(0xFF4D8192),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              guidance,
              style: const TextStyle(
                color: Color(0xFF596E79),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(Map<String, dynamic> item, int index) {
    final key = item['key'] as String;
    final isCompleted = item['is_completed'] == true;
    final isSaving = _savingItems.contains(key);
    final title = item['title'] as String? ?? '';
    final colors = [_mint, _peach, _lilac, _butter];
    final icons = [
      Icons.checklist_rounded,
      Icons.child_care_rounded,
      Icons.home_rounded,
      Icons.favorite_border_rounded,
    ];
    final tint = colors[index % colors.length];
    final icon = icons[index % icons.length];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFF7FBF8) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? const Color(0xFFCBE6D7) : const Color(0xFFF0EDF2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF43364D).withValues(alpha: 0.025),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: isSaving ? null : () => _updateItem(item, !isCompleted),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: isCompleted ? _mint : tint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : icon,
                  color: isCompleted ? const Color(0xFF4F9074) : _ink.withValues(alpha: 0.7),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isCompleted ? _muted : _ink,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: _muted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isSaving)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: _coral,
                  ),
                )
              else
                Checkbox(
                  value: isCompleted,
                  onChanged: (value) {
                    if (value != null) _updateItem(item, value);
                  },
                  activeColor: const Color(0xFF65A585),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _coral),
          SizedBox(height: 15),
          Text(
            'Getting your checklist ready...',
            style: TextStyle(color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(color: _peach, shape: BoxShape.circle),
              child: const Icon(Icons.playlist_remove_rounded, color: _coral, size: 34),
            ),
            const SizedBox(height: 18),
            const Text(
              'Your checklist is taking a little break',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ink,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your connection and try loading it again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, height: 1.45),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _loadChecklist,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(
                backgroundColor: _coral,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = (_data?['items'] as List<dynamic>?) ?? [];
    final completed = (_data?['completed_count'] as int?) ?? 0;
    final total = (_data?['total_count'] as int?) ?? items.length;
    final guidance = _data?['guidance'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFAF8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Baby preparation',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w800, fontSize: 21),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh checklist',
            onPressed: _isLoading ? null : _loadChecklist,
            icon: const Icon(Icons.refresh_rounded, color: _ink),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  color: _coral,
                  onRefresh: _loadChecklist,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                    children: [
                      _buildHero(completed, total),
                      const SizedBox(height: 21),
                      if (guidance != null && guidance.trim().isNotEmpty) ...[
                        _buildGuidance(guidance),
                        const SizedBox(height: 22),
                      ],
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Your checklist',
                              style: TextStyle(
                                color: _ink,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.35,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _lilac,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${items.length} ${items.length == 1 ? 'task' : 'tasks'}',
                              style: const TextStyle(
                                color: Color(0xFF8067A5),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (items.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFF0EDF2)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.spa_rounded, color: _coral, size: 34),
                              SizedBox(height: 10),
                              Text(
                                'No checklist tasks right now',
                                style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Check back later for your next steps.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: _muted, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      else
                        ...items.asMap().entries.map((entry) {
                          final item = Map<String, dynamic>.from(entry.value as Map);
                          return _buildChecklistItem(item, entry.key);
                        }),
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3D9),
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.favorite_rounded, color: Color(0xFFB58A3D), size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'These tasks are general preparation guidance. Discuss personal questions with your maternity care team.',
                                style: TextStyle(color: Color(0xFF77613D), fontSize: 12, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Center(
                        child: Text(
                          'You’re preparing with love 💛',
                          style: TextStyle(
                            color: Color(0xFF9A929E),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

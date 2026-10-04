import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ActivitiesScreen extends StatefulWidget {
  final String apiBaseUrl;
  final Future<Map<String, String>> Function() authHeaders;

  const ActivitiesScreen({
    super.key,
    required this.apiBaseUrl,
    required this.authHeaders,
  });

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

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
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${widget.apiBaseUrl}/pregnancy/exercise-sleep'),
        headers: await widget.authHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to load activities (${response.statusCode}).');
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;

      if (!mounted) return;
      setState(() {
        _data = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String get _week {
    final value = _data?['content_week'] ?? _data?['current_week'] ?? '-';
    return value.toString();
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE4D9), Color(0xFFFFF0D5), Color(0xFFF7E9F7)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'YOUR DAILY WELLNESS',
                    style: TextStyle(
                      color: _coral.withValues(alpha: 0.95),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Move gently.\nRest deeply.',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 27,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Small, kind choices can help you care for yourself.',
                  style: TextStyle(
                    color: _ink.withValues(alpha: 0.72),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Pregnancy week $_week',
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 94,
            height: 118,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 13,
                  right: 13,
                  child: Icon(Icons.auto_awesome, size: 20, color: Colors.amber.shade700),
                ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4B8A8),
                    shape: BoxShape.circle,
                  ),
                ),
                const Positioned(
                  bottom: 15,
                  child: Icon(Icons.self_improvement_rounded, size: 66, color: Color(0xFF9B718F)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _asItems(dynamic content) {
    if (content == null) return [];
    if (content is List) return content;
    if (content is String && content.trim().isEmpty) return [];
    return [content];
  }

  Widget _buildContentSection({
    required String title,
    required String subtitle,
    required dynamic content,
    required IconData icon,
    required Color tint,
    required Color accent,
  }) {
    final items = _asItems(content);
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFFF0EDF2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF43364D).withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: accent, size: 24),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite_rounded, size: 13, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...items.map((item) {
            final text = item.toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.check_circle_rounded, size: 17, color: accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Color(0xFF555264),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSafetyNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.health_and_safety_outlined, color: Color(0xFF4D8192)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A gentle reminder',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Your needs can change from day to day. Follow advice from your maternity care team about which activities are right for you, and stop if something feels wrong.',
                  style: TextStyle(color: Color(0xFF596E79), fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
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
          Text('Preparing your wellness guide...', style: TextStyle(color: _muted)),
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
              child: const Icon(Icons.cloud_off_rounded, color: _coral, size: 34),
            ),
            const SizedBox(height: 18),
            const Text(
              'Your guide couldn’t load just yet',
              textAlign: TextAlign.center,
              style: TextStyle(color: _ink, fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your connection and give it another try.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, height: 1.4),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _loadActivities,
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFAF8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Move & Rest',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w800, fontSize: 21),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh guidance',
            onPressed: _loading ? null : _loadActivities,
            icon: const Icon(Icons.refresh_rounded, color: _ink),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _loading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  color: _coral,
                  onRefresh: _loadActivities,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                    children: [
                      _buildHero(),
                      const SizedBox(height: 22),
                      const Padding(
                        padding: EdgeInsets.only(left: 2, bottom: 12),
                        child: Text(
                          'A little care goes a long way',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.35,
                          ),
                        ),
                      ),
                      _buildContentSection(
                        title: 'Activities & Exercise',
                        subtitle: 'Gentle ways to keep moving',
                        content: _data?['activities'],
                        icon: Icons.directions_walk_rounded,
                        tint: _mint,
                        accent: const Color(0xFF4F9074),
                      ),
                      _buildContentSection(
                        title: 'Sleep Guidance',
                        subtitle: 'Make room for better rest',
                        content: _data?['sleep_guidance'],
                        icon: Icons.bedtime_rounded,
                        tint: _lilac,
                        accent: const Color(0xFF8871B3),
                      ),
                      _buildContentSection(
                        title: 'Precautions',
                        subtitle: 'Keep your wellbeing in mind',
                        content: _data?['precautions'],
                        icon: Icons.shield_moon_rounded,
                        tint: _butter,
                        accent: const Color(0xFFAD8740),
                      ),
                      _buildSafetyNote(),
                      const SizedBox(height: 14),
                      const Center(
                        child: Text(
                          'Go at your own pace 💛',
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

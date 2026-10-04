import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'nutrition_screen.dart';
import 'activities_screen.dart';
import 'wellness_screen.dart';

class PregnancyWeekScreen extends StatefulWidget {
  final int week;
  final String apiBaseUrl;
  final Future<Map<String, String>> Function() authHeaders;

  const PregnancyWeekScreen({
    super.key,
    required this.week,
    required this.apiBaseUrl,
    required this.authHeaders,
  });

  @override
  State<PregnancyWeekScreen> createState() => _PregnancyWeekScreenState();
}

class _PregnancyWeekScreenState extends State<PregnancyWeekScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  static const _ink = Color(0xFF26334A);
  static const _muted = Color(0xFF6C7485);
  static const _canvas = Color(0xFFFFFBF6);
  static const _coral = Color(0xFFFF786B);
  static const _purple = Color(0xFF8974E8);
  static const _mint = Color(0xFF58B99B);
  static const _yellow = Color(0xFFFFC95C);
  static const _blue = Color(0xFF68B9E8);

  @override
  void initState() {
    super.initState();
    _loadWeeklyContent();
  }

  String _babyDevelopmentAsset(String week) {
    final weekNumber = int.tryParse(week) ?? 1;
    if (weekNumber <= 4) return 'assets/images/pregnancy_week_04.png';
    if (weekNumber <= 8) return 'assets/images/pregnancy_week_08.png';
    if (weekNumber <= 12) return 'assets/images/pregnancy_week_12.png';
    if (weekNumber <= 16) return 'assets/images/pregnancy_week_16.png';
    if (weekNumber <= 20) return 'assets/images/pregnancy_week_20.png';
    if (weekNumber <= 24) return 'assets/images/pregnancy_week_24.png';
    if (weekNumber <= 28) return 'assets/images/pregnancy_week_28.png';
    if (weekNumber <= 32) return 'assets/images/pregnancy_week_32.png';
    if (weekNumber <= 36) return 'assets/images/pregnancy_week_36.png';
    return 'assets/images/pregnancy_week_40.png';
  }

  Future<void> _loadWeeklyContent() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final headers = await widget.authHeaders();
      final response = await http
          .get(
            Uri.parse('${widget.apiBaseUrl}/pregnancy/week/${widget.week}'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          setState(() {
            _error = 'The server returned an unexpected response.';
            _loading = false;
          });
          return;
        }
        setState(() {
          _data = decoded;
          _loading = false;
          _error = null;
        });
        return;
      }

      var detail = '';
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          detail = (body['detail'] ?? '').toString();
        }
      } catch (_) {
        // The server response was not JSON.
      }
      setState(() {
        _error = detail.isNotEmpty
            ? 'Unable to load week ${widget.week}: $detail (HTTP ${response.statusCode})'
            : 'Unable to load week ${widget.week} (HTTP ${response.statusCode}).';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().contains('TimeoutException')
            ? 'The server took too long to respond. Please try again.'
            : 'Could not connect to the server. Check that FastAPI is running.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _canvas,
        appBar: _appBar(),
        body: const Center(
          child: CircularProgressIndicator(color: _coral),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: _canvas,
        appBar: _appBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE8E3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      size: 42,
                      color: _coral,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Let’s try that again',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _ink,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _loadWeeklyContent,
                    style: FilledButton.styleFrom(
                      backgroundColor: _coral,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final data = _data ?? <String, dynamic>{};
    final week = data['week']?.toString() ?? widget.week.toString();
    final weekNumber = (int.tryParse(week) ?? widget.week).clamp(1, 40);
    final sources = (data['sources'] is List) ? data['sources'] as List : <dynamic>[];

    return Scaffold(
      backgroundColor: _canvas,
      appBar: _appBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 36),
        children: [
          _hero(week, weekNumber),
          const SizedBox(height: 26),
          _sectionHeader(
            eyebrow: 'GROWING TOGETHER',
            title: 'This week, in a nutshell',
            subtitle: 'Little changes, big milestones.',
          ),
          const SizedBox(height: 15),
          _growthCard(
            title: 'Baby’s growth',
            content: data['baby_growth']?.toString(),
            icon: Icons.spa_rounded,
            accent: _mint,
            background: const Color(0xFFE5F7EF),
            label: 'THE LITTLE ONE',
          ),
          const SizedBox(height: 12),
          _bodyChangesCard(data['body_changes']?.toString()),
          const SizedBox(height: 27),
          _sectionHeader(
            eyebrow: 'CARE FOR YOU',
            title: 'A little support for today',
            subtitle: 'Gentle reminders for your body and mind.',
          ),
          const SizedBox(height: 15),
          _guidanceTile(
            title: 'Eat well',
            subtitle: 'Nutrition guidance · Tap to explore',
            content: data['nutrition_guidance']?.toString(),
            icon: Icons.restaurant_rounded,
            accent: const Color(0xFFE59A32),
            background: const Color(0xFFFFF0D6),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NutritionScreen(
                  apiBaseUrl: widget.apiBaseUrl,
                  authHeaders: widget.authHeaders,
                ),
              ),
            ),
          ),
          _guidanceTile(
            title: 'Move at your pace',
            subtitle: 'Activities & everyday tips · Tap to explore',
            content: data['activities']?.toString(),
            icon: Icons.directions_walk_rounded,
            accent: const Color(0xFF398EC0),
            background: const Color(0xFFE2F4FF),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ActivitiesScreen(
                  apiBaseUrl: widget.apiBaseUrl,
                  authHeaders: widget.authHeaders,
                ),
              ),
            ),
          ),
          _guidanceTile(
            title: 'Stay safe',
            subtitle: 'Precautions to keep in mind · Tap for details',
            content: data['precautions']?.toString(),
            icon: Icons.shield_rounded,
            accent: _purple,
            background: const Color(0xFFEDE8FF),
            onTap: () => _showGuidanceDetails(
              'Stay safe',
              _contentOrFallback(data['precautions']?.toString()),
            ),
          ),
          _guidanceTile(
            title: 'Make space for your feelings',
            subtitle: 'Mental wellness · Tap to explore',
            content: data['mental_wellness']?.toString(),
            icon: Icons.favorite_rounded,
            accent: _coral,
            background: const Color(0xFFFFE7E4),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WellnessScreen(
                  apiBaseUrl: widget.apiBaseUrl,
                  authHeaders: widget.authHeaders,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _quickIdeas(),
          const SizedBox(height: 18),
          _funFact(week),
          if (sources.isNotEmpty) ...[
            const SizedBox(height: 28),
            _sectionHeader(
              eyebrow: 'TRUSTED READING',
              title: 'Explore the sources',
              subtitle: 'Learn more from the references behind this week’s guide.',
            ),
            const SizedBox(height: 14),
            ...sources.map((source) => _sourceTile(source)),
          ],
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'One week at a time. You’re doing great. ✨',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: _canvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        tooltip: 'Go back',
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded, color: _ink),
      ),
      title: const Text(
        'Your pregnancy',
        style: TextStyle(
          color: _ink,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'Share',
          onPressed: () {
            // Sharing can be connected later.
          },
          icon: const Icon(Icons.ios_share_rounded, color: _ink),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _hero(String week, int weekNumber) {
    final progress = weekNumber / 40;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD9CE),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -38,
            right: -24,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0xFFFFBBAA),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 26,
            child: Transform.rotate(
              angle: .18,
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.75),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wb_sunny_rounded, size: 15, color: Color(0xFFCE755C)),
                      SizedBox(width: 6),
                      Text(
                        'YOUR LITTLE ADVENTURE',
                        style: TextStyle(
                          color: Color(0xFF8C5146),
                          fontSize: 10,
                          letterSpacing: .9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Week $week',
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 36,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Tiny steps, wonderful things\nare happening every day.',
                  style: TextStyle(
                    color: Color(0xFF754F4A),
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 205,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        bottom: 4,
                        left: 16,
                        right: 16,
                        child: Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB6A4).withOpacity(.7),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                      Image.asset(
                        _babyDevelopmentAsset(week),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const _BabyIllustration();
                        },
                      ),
                      Positioned(
                        left: 2,
                        top: 26,
                        child: _floatingSticker(
                          icon: Icons.favorite_rounded,
                          color: const Color(0xFFFF8179),
                          size: 38,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 28,
                        child: _floatingSticker(
                          icon: Icons.star_rounded,
                          color: _yellow,
                          size: 42,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$weekNumber of 40 weeks',
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              minHeight: 9,
                              backgroundColor: Colors.white.withOpacity(.8),
                              valueColor: const AlwaysStoppedAnimation<Color>(_coral),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '${(100 * progress).round()}%',
                        style: const TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingSticker({
    required IconData icon,
    required Color color,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9E6255).withOpacity(.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: size * .58),
    );
  }

  Widget _sectionHeader({
    required String eyebrow,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: _coral,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 23,
            height: 1.18,
            fontWeight: FontWeight.w900,
            letterSpacing: -.55,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: _muted,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _growthCard({
    required String title,
    required String? content,
    required IconData icon,
    required Color accent,
    required Color background,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBubble(icon, accent, Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: accent,
                        fontSize: 9,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.eco_rounded, color: Colors.white, size: 30),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            _contentOrFallback(content),
            style: const TextStyle(color: _ink, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _bodyChangesCard(String? content) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFF1E7E2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 66,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE7E4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.favorite_rounded, color: _coral, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your body, your way',
                  style: TextStyle(color: _ink, fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                Text(
                  _contentOrFallback(content),
                  style: const TextStyle(color: _muted, fontSize: 14, height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _guidanceTile({
    required String title,
    required String subtitle,
    required String? content,
    required IconData icon,
    required Color accent,
    required Color background,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFFF0EBE6)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(23),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(23),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: accent, size: 25),
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
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: accent,
                      size: 17,
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Text(
                  _contentOrFallback(content),
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGuidanceDetails(String title, String content) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _quickIdeas() {
    final ideas = <({IconData icon, String title, String text, Color color, Color tint})>[
      (
        icon: Icons.local_drink_rounded,
        title: 'Sip often',
        text: 'Keep water nearby through the day.',
        color: const Color(0xFF398EC0),
        tint: const Color(0xFFE2F4FF),
      ),
      (
        icon: Icons.nights_stay_rounded,
        title: 'Rest counts',
        text: 'A pause is productive, too.',
        color: _purple,
        tint: const Color(0xFFEDE8FF),
      ),
      (
        icon: Icons.chat_bubble_rounded,
        title: 'Check in',
        text: 'Share how you’re feeling with someone you trust.',
        color: _coral,
        tint: const Color(0xFFFFE7E4),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tiny ideas for today',
          style: TextStyle(color: _ink, fontSize: 19, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ideas.length,
            separatorBuilder: (context, index) => const SizedBox(width: 11),
            itemBuilder: (context, index) {
              final idea = ideas[index];
              return Container(
                width: 158,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: idea.tint,
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(idea.icon, color: idea.color, size: 25),
                    const Spacer(),
                    Text(
                      idea.title,
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      idea.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted, fontSize: 11.5, height: 1.35),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _funFact(String week) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFDAF4E9),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.lightbulb_rounded, color: Color(0xFF339B7A), size: 25),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A little something to know',
                  style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Discover something interesting about week $week of your pregnancy as your journey unfolds.',
                  style: const TextStyle(color: Color(0xFF416D60), fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF339B7A), size: 21),
        ],
      ),
    );
  }

  Widget _sourceTile(dynamic source) {
    if (source is! Map) return const SizedBox.shrink();
    final organization = source['organization']?.toString() ?? 'Source';
    final title = source['title']?.toString() ?? '';
    final url = source['url']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EBE6)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE2F4FF),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.menu_book_rounded, color: Color(0xFF398EC0)),
        ),
        title: Text(
          organization,
          style: const TextStyle(color: _ink, fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: _muted, height: 1.3),
        ),
        trailing: const Icon(Icons.open_in_new_rounded, color: _blue, size: 19),
        onTap: () async {
          final uri = Uri.tryParse(url);
          if (uri == null || !(uri.isScheme('https') || uri.isScheme('http'))) return;
          final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!context.mounted) return;
          if (!opened) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open source.')),
            );
          }
        },
      ),
    );
  }

  Widget _iconBubble(IconData icon, Color background, Color foreground) {
    return Container(
      width: 47,
      height: 47,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: foreground, size: 25),
    );
  }

  String _contentOrFallback(String? content) {
    if (content == null || content.trim().isEmpty) {
      return 'More information for this week will be available soon.';
    }
    return content.trim();
  }
}

class _BabyIllustration extends StatelessWidget {
  const _BabyIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 230,
        height: 195,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 178,
              height: 178,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF2DF),
                shape: BoxShape.circle,
              ),
            ),
            Positioned(
              left: 28,
              top: 23,
              child: Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFC95C), size: 26),
            ),
            Positioned(
              right: 23,
              top: 46,
              child: Icon(Icons.favorite_rounded, color: Color(0xFFFF9B91), size: 22),
            ),
            const Icon(
              Icons.child_friendly_rounded,
              color: Color(0xFFE69A7B),
              size: 115,
            ),
            Positioned(
              bottom: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'growing with love',
                  style: TextStyle(
                    color: Color(0xFF8C5146),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

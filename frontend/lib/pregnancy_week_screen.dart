import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Use the same imports you already use in main.dart
// for apiBaseUrl and authHeaders().

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
  State<PregnancyWeekScreen> createState() =>
      _PregnancyWeekScreenState();
}

class _PregnancyWeekScreenState
    extends State<PregnancyWeekScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWeeklyContent();
  }

  Future<void> _loadWeeklyContent() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${widget.apiBaseUrl}/pregnancy/week/${widget.week}',
        ),
        headers: await widget.authHeaders(),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          setState(() {
            _data = decoded;
            _loading = false;
          });
        } else {
          setState(() {
            _error = 'Invalid response from server.';
            _loading = false;
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          _error = 'Pregnancy information is not available for this week.';
          _loading = false;
        });
      } else {
        setState(() {
          _error =
              'Unable to load pregnancy information (${response.statusCode}).';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Unable to connect to the server.';
        _loading = false;
      });
    }
  }

@override
Widget build(BuildContext context) {
  if (_loading) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2196F3),
        ),
      ),
    );
  }

  if (_error != null) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Week ${widget.week}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  final data = _data!;
  final week = data['week']?.toString() ?? widget.week.toString();

  Widget sectionCard({
    required String title,
    required String? content,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEAF1F8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF101B4C),
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  content?.isNotEmpty == true
                      ? content!
                      : 'Information will be available soon.',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF526080),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF7A86A8),
          ),
        ],
      ),
    );
  }

  return Scaffold(
    backgroundColor: const Color(0xFFF7FAFD),

    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,

      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFF101B4C),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),

      title: Text(
        'Week $week',
        style: const TextStyle(
          color: Color(0xFF101B4C),
          fontSize: 21,
          fontWeight: FontWeight.w800,
        ),
      ),

      actions: [
        IconButton(
          icon: const Icon(
            Icons.share_outlined,
            color: Color(0xFF101B4C),
          ),
          onPressed: () {
            // Sharing can be connected later.
          },
        ),
      ],
    ),

    body: ListView(
      padding: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        32,
      ),
      children: [

        // =====================================================
        // WEEK HERO
        // =====================================================

        Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            22,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF5EF),
                Color(0xFFFFE7D9),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'YOUR JOURNEY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: Color(0xFF7B4B3A),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Week $week',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7B4B3A),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // =================================================
              // BABY DEVELOPMENT IMAGE
              // =================================================

              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/pregnancy_week_$week.png',
                    fit: BoxFit.contain,

                    // Until we add the actual artwork,
                    // show a beautiful fallback.
                    errorBuilder:
                        (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.9),
                              const Color(0xFFFFE7D9),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.child_friendly_rounded,
                            size: 105,
                            color: Color(0xFFE9A17D),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Week $week',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101B4C),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Your baby is growing and changing every week.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF526080),
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // 40 WEEK PROGRESS
              // =================================================

              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value:
                            ((int.tryParse(week) ?? 1) / 40)
                                .clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.white,
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 7),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Week $week',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A6B65),
                    ),
                  ),
                  const Text(
                    'Week 40',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A6B65),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // =====================================================
        // WEEKLY INFORMATION
        // =====================================================

        sectionCard(
          title: 'Baby Growth',
          content: data['baby_growth']?.toString(),
          icon: Icons.eco_outlined,
          iconBackground: const Color(0xFFE7F7EE),
          iconColor: const Color(0xFF35A66F),
        ),

        sectionCard(
          title: 'Body Changes',
          content: data['body_changes']?.toString(),
          icon: Icons.favorite_border_rounded,
          iconBackground: const Color(0xFFFFE9ED),
          iconColor: const Color(0xFFE85D75),
        ),

        sectionCard(
          title: 'Nutrition',
          content: data['nutrition_guidance']?.toString(),
          icon: Icons.restaurant_outlined,
          iconBackground: const Color(0xFFFFF1DD),
          iconColor: const Color(0xFFF39C12),
        ),

        sectionCard(
          title: 'Tips for You',
          content: data['activities']?.toString(),
          icon: Icons.self_improvement_outlined,
          iconBackground: const Color(0xFFE6F4FF),
          iconColor: const Color(0xFF2196F3),
        ),

        sectionCard(
          title: 'Precautions',
          content: data['precautions']?.toString(),
          icon: Icons.shield_outlined,
          iconBackground: const Color(0xFFF0EAFF),
          iconColor: const Color(0xFF8067C9),
        ),

        sectionCard(
          title: 'Mental Wellness',
          content: data['mental_wellness']?.toString(),
          icon: Icons.sentiment_satisfied_alt_outlined,
          iconBackground: const Color(0xFFE5F8F6),
          iconColor: const Color(0xFF2BA99A),
        ),

        const SizedBox(height: 14),

        // =====================================================
        // YOU MAY ALSO WANT TO KNOW
        // =====================================================

        const Text(
          'You may also want to know',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF101B4C),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _WeeklyTipCard(
                icon: Icons.restaurant_outlined,
                title: 'Nutrition',
                subtitle:
                    'Ideas for healthy meals and hydration.',
                color: const Color(0xFFFFF1DD),
                iconColor: const Color(0xFFF39C12),
              ),

              const SizedBox(width: 12),

              _WeeklyTipCard(
                icon: Icons.directions_walk_outlined,
                title: 'Activities',
                subtitle:
                    'Gentle ways to stay active.',
                color: const Color(0xFFE6F4FF),
                iconColor: const Color(0xFF2196F3),
              ),

              const SizedBox(width: 12),

              _WeeklyTipCard(
                icon: Icons.bedtime_outlined,
                title: 'Rest',
                subtitle:
                    'Simple ideas for relaxation and rest.',
                color: const Color(0xFFEAF0FF),
                iconColor: const Color(0xFF5578C8),
              ),

              const SizedBox(width: 12),

              _WeeklyTipCard(
                icon: Icons.child_friendly_outlined,
                title: 'Prepare',
                subtitle:
                    'Things you may want to plan ahead.',
                color: const Color(0xFFF3E9FF),
                iconColor: const Color(0xFF8E63D2),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // =====================================================
        // FUN FACT
        // =====================================================

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF6FF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFD6ECFF),
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Color(0xFF2196F3),
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fun fact',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF101B4C),
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      'Discover something interesting about week $week of your pregnancy.',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF526080),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 26),

        // =====================================================
        // SOURCES
        // =====================================================

        const Text(
          'Sources',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF101B4C),
          ),
        ),

        const SizedBox(height: 12),

        ...((data['sources'] as List?) ?? []).map(
          (source) {
            final sourceMap =
                source as Map<String, dynamic>;

            final url =
                sourceMap['url']?.toString() ?? '';

            return Container(
              margin: const EdgeInsets.only(
                bottom: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFEAF1F8),
                ),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),

                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F4FF),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.menu_book_outlined,
                    color: Color(0xFF2196F3),
                  ),
                ),

                title: Text(
                  sourceMap['organization']
                          ?.toString() ??
                      'Source',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                subtitle: Text(
                  sourceMap['title']?.toString() ??
                      '',
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                ),

                trailing: const Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: Color(0xFF2196F3),
                ),

                onTap: () async {
                  final uri =
                      Uri.tryParse(url);

                  if (uri == null) return;

                  final opened =
                      await launchUrl(
                    uri,
                    mode: LaunchMode
                        .externalApplication,
                  );

                  if (!context.mounted) {
                    return;
                  }

                  if (!opened) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Could not open source.',
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
      ],
    ),
  );
}

  Widget _section(String title, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
class _WeeklyTipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;

  const _WeeklyTipCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 145,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFEAF1F8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),

            const Spacer(),

            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.3,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'fun_facts.dart';
import 'partner_surprises.dart';

// Keep this URL aligned with apiBaseUrl in main.dart.
// For Android Emulator, use http://10.0.2.2:8000 instead.
const String _fatherApiBaseUrl = 'http://127.0.0.1:8000';

class FatherDashboardScreen extends StatefulWidget {
  final int currentWeek;
  final VoidCallback? onSwitchProfile;

  const FatherDashboardScreen({
    super.key,
    this.currentWeek = 1,
    this.onSwitchProfile,
  });

  @override
  State<FatherDashboardScreen> createState() =>
      _FatherDashboardScreenState();
}

class _FatherDashboardScreenState extends State<FatherDashboardScreen> {
  static const Color coral = Color(0xFFFF8A80);
  static const Color peach = Color(0xFFFFE4D6);
  static const Color mint = Color(0xFFDDF5E5);
  static const Color lavender = Color(0xFFEAE4FF);
  static const Color ink = Color(0xFF39364A);

  int _currentWeek = 1;
  FunFact? _funFact;
  PartnerSurprise? _partnerSurprise;
  int _checklistWeek = 1;
  bool _loading = true;
  String? _errorMessage;
  String _fatherTipTitle = 'Your tip for this week';
  String? _fatherTip;
  bool _tipLoading = true;
  String? _tipError;
  List<Map<String, dynamic>> _tasks = [];
  final Set<String> _savingItems = {};

  @override
  void initState() {
    super.initState();
    _currentWeek = widget.currentWeek.clamp(1, 40).toInt();
    _funFact = getRandomFunFact(
      _currentWeek,
      isFather: true,
    );
    _partnerSurprise = getPartnerSurprise(_currentWeek);
    _loadChecklist();
    _loadFatherTip();
  }

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  Future<void> _loadFatherTip() async {
    if (mounted) {
      setState(() {
        _tipLoading = true;
        _tipError = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('$_fatherApiBaseUrl/pregnancy/father-tip'),
        headers: await _authHeaders(),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Unexpected father-tip response.');
        }

        final tip = decoded['tip']?.toString().trim();
        final title = decoded['title']?.toString().trim();
        final week = decoded['current_week'];

        setState(() {
          if (week != null) {
            _currentWeek = _toWeek(week, _currentWeek);
          }
          _fatherTip = (tip == null || tip.isEmpty) ? null : tip;
          _fatherTipTitle = (title == null || title.isEmpty)
              ? 'Your tip for this week'
              : title;
          _tipLoading = false;
          _tipError = _fatherTip == null
              ? 'No father tip is available for this week yet.'
              : null;
        });
      } else if (response.statusCode == 401 ||
          response.statusCode == 403) {
        setState(() {
          _tipLoading = false;
          _tipError = 'Please sign in again to load your weekly tip.';
        });
      } else {
        setState(() {
          _tipLoading = false;
          _tipError = 'Could not load this week’s tip. Pull down to try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _tipLoading = false;
        _tipError = 'Could not connect to the server to load your weekly tip.';
      });
      debugPrint('Father tip load error: $e');
    }
  }

  Future<void> _refreshDashboard() async {
    await Future.wait([
      _loadChecklist(),
      _loadFatherTip(),
    ]);
  }

  Future<void> _loadChecklist() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('$_fatherApiBaseUrl/pregnancy/baby-preparation'),
        headers: await _authHeaders(),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Unexpected checklist response.');
        }

        final rawItems = decoded['items'];
        if (rawItems is! List) {
          throw const FormatException('Checklist items were not returned.');
        }

        final parsedTasks = rawItems
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        setState(() {
          _currentWeek = _toWeek(decoded['current_week'], _currentWeek);
          _checklistWeek = _toWeek(
            decoded['checklist_week'],
            _currentWeek,
          );
          _funFact = getRandomFunFact(
            _currentWeek,
            isFather: true,
          );
          _partnerSurprise = getPartnerSurprise(_currentWeek);
          _tasks = parsedTasks;
          _loading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _tasks = [];
          _loading = false;
          _errorMessage =
              'Please create your pregnancy profile before loading the checklist.';
        });
      } else if (response.statusCode == 401 ||
          response.statusCode == 403) {
        setState(() {
          _loading = false;
          _errorMessage = 'Your session may have expired. Please sign in again.';
        });
      } else {
        setState(() {
          _loading = false;
          _errorMessage = 'Could not load your checklist. Please try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Could not connect to PregEase. Check that the API is running.';
      });
      debugPrint('Father checklist load error: $e');
    }
  }

  int _toWeek(dynamic value, int fallback) {
    final parsed = value is int ? value : int.tryParse('$value');
    if (parsed == null) return fallback;
    return parsed.clamp(1, 40).toInt();
  }

  Map<String, dynamic> _taskStyle(String key) {
    switch (key) {
      case 'discuss_support':
      case 'identify_support':
      case 'support_after_birth':
        return {
          'description': 'Make time to talk about support needs together.',
          'icon': Icons.favorite_rounded,
          'color': peach,
        };
      case 'start_notes':
      case 'review_birth_questions':
      case 'feeding_questions':
        return {
          'description': 'Write down questions to discuss with the care team.',
          'icon': Icons.menu_book_rounded,
          'color': lavender,
        };
      case 'review_budget':
      case 'baby_essentials_list':
      case 'newborn_supplies':
        return {
          'description': 'Plan practical essentials for your growing family.',
          'icon': Icons.shopping_bag_rounded,
          'color': mint,
        };
      case 'transport_plan':
      case 'transport_confirm':
      case 'transport_final':
        return {
          'description': 'Discuss and prepare a reliable transport plan.',
          'icon': Icons.directions_car_rounded,
          'color': peach,
        };
      case 'sleep_space':
      case 'safe_sleep_setup':
      case 'safe_sleep_final':
        return {
          'description': 'Review the baby’s sleep space and safety needs.',
          'icon': Icons.bed_rounded,
          'color': mint,
        };
      case 'hospital_bag':
      case 'hospital_bag_check':
      case 'documents':
      case 'care_team_contacts':
        return {
          'description': 'Check what needs to be ready before the birth.',
          'icon': Icons.checklist_rounded,
          'color': lavender,
        };
      case 'birth_preferences':
        return {
          'description': 'Discuss birth preferences with your care team.',
          'icon': Icons.chat_bubble_outline_rounded,
          'color': peach,
        };
      default:
        return {
          'description': 'Take this step together, at a pace that works for you.',
          'icon': Icons.favorite_border_rounded,
          'color': mint,
        };
    }
  }


  Future<void> _updateTask(
    Map<String, dynamic> task,
    bool isCompleted,
  ) async {
    final key = task['key']?.toString();
    if (key == null || key.isEmpty || _savingItems.contains(key)) return;

    final oldValue = task['is_completed'] == true;

    setState(() {
      task['is_completed'] = isCompleted;
      _savingItems.add(key);
    });

    try {
      final response = await http.put(
        Uri.parse(
          '$_fatherApiBaseUrl/pregnancy/baby-preparation/checklist-item',
        ),
        headers: await _authHeaders(),
        body: jsonEncode({
          'week': _checklistWeek,
          'item_key': key,
          'is_completed': isCompleted,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['is_completed'] is bool) {
          setState(() {
            task['is_completed'] = decoded['is_completed'];
          });
        }
      } else {
        setState(() {
          task['is_completed'] = oldValue;
        });
        _showMessage(_errorFromResponse(
          response,
          'Could not save this task. Please try again.',
        ));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        task['is_completed'] = oldValue;
      });
      _showMessage('Could not connect to the server. Your change was not saved.');
      debugPrint('Father checklist update error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _savingItems.remove(key);
        });
      }
    }
  }

  String _errorFromResponse(http.Response response, String fallback) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['detail'] != null) {
        return decoded['detail'].toString();
      }
    } catch (_) {}
    return fallback;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  Widget _surpriseMeta(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .75),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFE66D5A)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF68776F),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF25352F);
    const muted = Color(0xFF68776F);
    const canvas = Color(0xFFFFFBF5);
    const coral = Color(0xFFFF765F);
    const coralLight = Color(0xFFFFA46B);
    const mint = Color(0xFFDDF4E7);
    const lilac = Color(0xFFEDE5FF);
    const pink = Color(0xFFFFE2DE);
    const border = Color(0xFFF0E9E2);

    final completedCount =
        _tasks.where((task) => task['is_completed'] == true).length;

    Widget heading(String eyebrow, String title, {String? action, VoidCallback? onAction}) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: const TextStyle(
                    color: coral,
                    fontSize: 10,
                    letterSpacing: 1.7,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 22,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.6,
                  ),
                ),
              ],
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                action,
                style: const TextStyle(color: ink, fontWeight: FontWeight.w800),
              ),
            ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: canvas,
      body: SafeArea(
        child: RefreshIndicator(
          color: coral,
          onRefresh: _refreshDashboard,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 34),
            children: [
              Row(
                children: [
                  Container(
                    width: 47,
                    height: 47,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [coral, coralLight],
                      ),
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: [
                        BoxShadow(
                          color: coral.withValues(alpha: .22),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.spa_rounded, color: Colors.white, size: 27),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PregEase',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.7,
                            color: ink,
                          ),
                        ),
                        Text(
                          'A brighter little journey, together',
                          style: TextStyle(fontSize: 11.5, color: muted),
                        ),
                      ],
                    ),
                  ),
                  if (widget.onSwitchProfile != null)
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: widget.onSwitchProfile,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: border),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.swap_horiz_rounded, color: coral, size: 19),
                              SizedBox(width: 4),
                              Text(
                                'Mother',
                                style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 27),
              const Text(
                'Hello, Dad-to-be! ✨',
                style: TextStyle(
                  fontSize: 29,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.1,
                  color: ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your support is part of this beautiful journey.',
                style: TextStyle(fontSize: 13, height: 1.45, color: muted),
              ),
              const SizedBox(height: 22),

              // Pregnancy progress hero card, matching the mother's coral style.
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [coral, Color(0xFFFFA46B)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -18,
                      top: -22,
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .16),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .22),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'YOUR JOURNEY TOGETHER',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 17),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pregnancy week $_currentWeek',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      height: 1.1,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -.6,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Little steps today help build a loving tomorrow.',
                                    style: TextStyle(
                                      color: Color(0xFFFFF8F2),
                                      fontSize: 12.5,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 76,
                              height: 82,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .22),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(
                                Icons.family_restroom_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 27),

              heading('A little guidance', 'Your tip for this week'),
              const SizedBox(height: 13),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: mint,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFFCDE8D7)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.lightbulb_rounded, color: Color(0xFF438568), size: 25),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: _tipLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: LinearProgressIndicator(color: coral),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fatherTipTitle,
                                  style: const TextStyle(
                                    color: ink,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  _fatherTip ?? _tipError ?? 'Your weekly tip will appear here.',
                                  style: const TextStyle(color: ink, fontSize: 13, height: 1.5),
                                ),
                                if (_tipError != null) ...[
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: _loadFatherTip,
                                      icon: const Icon(Icons.refresh_rounded, size: 17),
                                      label: const Text('Try again'),
                                      style: TextButton.styleFrom(foregroundColor: ink),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
              ),

              if (_funFact != null) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(19),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE5FF),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFDCD1FF),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF7558B6),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fun fact · Week $_currentWeek',
                              style: const TextStyle(
                                color: ink,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              '${_funFact!.emoji}  ${_funFact!.text}',
                              style: const TextStyle(
                                color: muted,
                                fontSize: 12.5,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],


              if (_partnerSurprise != null) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFE8E2),
                        Color(0xFFFFF2E8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Color(0xFFFFD3C8)),
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
                              color: Colors.white.withValues(alpha: .85),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.card_giftcard_rounded,
                              color: Color(0xFFE66D5A),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SURPRISE YOUR PARTNER',
                                  style: TextStyle(
                                    color: Color(0xFFE66D5A),
                                    fontSize: 10,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Week $_currentWeek mission',
                                  style: const TextStyle(
                                    color: Color(0xFF25352F),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '${_partnerSurprise!.emoji}  ${_partnerSurprise!.title}',
                        style: const TextStyle(
                          color: Color(0xFF25352F),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _partnerSurprise!.description,
                        style: const TextStyle(
                          color: Color(0xFF68776F),
                          fontSize: 12.5,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _surpriseMeta(Icons.schedule_rounded, _partnerSurprise!.time),
                          const SizedBox(width: 10),
                          _surpriseMeta(Icons.payments_outlined, _partnerSurprise!.cost),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .7),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('✨', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Bonus: ${_partnerSurprise!.bonus}',
                                style: const TextStyle(
                                  color: Color(0xFF68776F),
                                  fontSize: 11.5,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              heading('One step at a time', 'Your support checklist'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Small things you can do to help today.',
                      style: const TextStyle(color: muted, fontSize: 12.5, height: 1.4),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: pink,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '$completedCount/${_tasks.length} done',
                      style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(child: CircularProgressIndicator(color: coral)),
                )
              else if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: pink, borderRadius: BorderRadius.circular(22)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: ink, height: 1.4)),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: _loadChecklist,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Try again'),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_tasks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: lilac, borderRadius: BorderRadius.circular(22)),
                  child: const Text(
                    'No checklist tasks are available for this week yet.',
                    style: TextStyle(color: ink, height: 1.4),
                  ),
                )
              else
                ..._tasks.map((task) {
                  final key = task['key']?.toString() ?? '';
                  final title = task['title']?.toString() ?? 'Preparation task';
                  final style = _taskStyle(key);
                  final isCompleted = task['is_completed'] == true;
                  final isSaving = _savingItems.contains(key);
                  final taskColor = style['color'] as Color;
                  final taskIcon = style['icon'] as IconData;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 11),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: border),
                      boxShadow: [
                        BoxShadow(
                          color: ink.withValues(alpha: .035),
                          blurRadius: 13,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CheckboxListTile(
                      value: isCompleted,
                      onChanged: isSaving
                          ? null
                          : (value) {
                              if (value != null) _updateTask(task, value);
                            },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xFF438568),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      secondary: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: taskColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(taskIcon, color: ink, size: 22),
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: ink,
                          fontSize: 13.5,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          isSaving ? 'Saving…' : style['description'] as String,
                          style: const TextStyle(color: muted, fontSize: 11.5, height: 1.4),
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(19),
                decoration: BoxDecoration(
                  color: lilac,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.people_alt_rounded, color: ink, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Showing up matters',
                            style: TextStyle(color: ink, fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'You do not have to know everything. Being present, supportive, and willing to learn matters.',
                            style: TextStyle(color: muted, height: 1.5, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
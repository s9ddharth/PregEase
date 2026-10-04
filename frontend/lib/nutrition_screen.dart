import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NutritionScreen extends StatefulWidget {
  final String apiBaseUrl;
  final Future<Map<String, String>> Function() authHeaders;

  const NutritionScreen({
    super.key,
    required this.apiBaseUrl,
    required this.authHeaders,
  });

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _generatingSuggestions = false;
  String? _error;
  String? _suggestionsError;
  Map<String, dynamic>? _aiSuggestions;
  String _selectedCuisine = 'Indian';
  String _selectedMealType = 'Any meal';

  static const Color _ink = Color(0xFF29352D);
  static const Color _muted = Color(0xFF6E796F);
  static const Color _cream = Color(0xFFFFFBF4);
  static const Color _coral = Color(0xFFFF806E);
  static const Color _green = Color(0xFF4D9A73);
  static const Color _line = Color(0xFFEDE7DB);

  @override
  void initState() {
    super.initState();
    _loadNutrition();
  }

  Future<void> _loadNutrition() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
        // Discard AI ideas generated with the previous profile preferences.
        _aiSuggestions = null;
        _suggestionsError = null;
      });
    }

    try {
      final response = await http
          .get(
            Uri.parse('${widget.apiBaseUrl}/pregnancy/nutrition'),
            headers: await widget.authHeaders(),
          )
          .timeout(const Duration(seconds: 20));

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
            _error = 'Unexpected response from server.';
            _loading = false;
          });
        }
      } else {
        var detail = '';
        try {
          final body = jsonDecode(response.body);
          if (body is Map<String, dynamic>) {
            detail = (body['detail'] ?? '').toString();
          }
        } catch (_) {}

        setState(() {
          _error = detail.isNotEmpty
              ? '$detail (HTTP ${response.statusCode})'
              : 'Unable to load nutrition (HTTP ${response.statusCode}).';
          _loading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not connect to the server. Check that FastAPI is running.';
        _loading = false;
      });
    }
  }

  Future<void> _generateAiSuggestions() async {
    if (_generatingSuggestions) return;

    setState(() {
      _generatingSuggestions = true;
      _suggestionsError = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse(
              '${widget.apiBaseUrl}/pregnancy/nutrition/suggestions',
            ),
            headers: {
              ...await widget.authHeaders(),
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'cuisine': _selectedCuisine == 'Any cuisine'
                  ? null
                  : _selectedCuisine,
              'meal_type': _selectedMealType == 'Any meal'
                  ? null
                  : _selectedMealType,
            }),
          )
          .timeout(const Duration(seconds: 120));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          setState(() {
            _aiSuggestions = decoded;
            _generatingSuggestions = false;
          });
        } else {
          setState(() {
            _suggestionsError = 'The server returned an unexpected response.';
            _generatingSuggestions = false;
          });
        }
      } else {
        var detail = '';
        try {
          final body = jsonDecode(response.body);
          if (body is Map<String, dynamic>) {
            detail = (body['detail'] ?? '').toString();
          }
        } catch (_) {}

        setState(() {
          _suggestionsError = detail.isNotEmpty
              ? '$detail (HTTP ${response.statusCode})'
              : 'Could not generate suggestions (HTTP ${response.statusCode}).';
          _generatingSuggestions = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestionsError =
            'Could not reach the AI service. Check that FastAPI and Ollama are running, then try again.';
        _generatingSuggestions = false;
      });
    }
  }

  Widget _buildAiSuggestions() {
    final result = _aiSuggestions;
    final suggestions = result?['suggestions'] is List
        ? (result!['suggestions'] as List).whereType<Map>().toList()
        : <Map>[];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            eyebrow: 'MADE WITH YOUR PREFERENCES',
            title: result?['title']?.toString() ?? 'Your AI meal ideas',
            subtitle: 'Ideas based on your pregnancy week and saved food restrictions.',
          ),
          const SizedBox(height: 14),
          if (suggestions.isEmpty)
            const Text(
              'No meal ideas were returned. Please try again.',
              style: TextStyle(color: _muted),
            )
          else
            ...suggestions.map((meal) {
              final ingredients = meal['ingredients'] is List
                  ? (meal['ingredients'] as List)
                      .map((item) => item.toString())
                      .toList()
                  : <String>[];
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F1),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal['name']?.toString() ?? 'Meal idea',
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if ((meal['description']?.toString() ?? '').isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        meal['description'].toString(),
                        style: const TextStyle(
                          color: _muted,
                          height: 1.4,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (ingredients.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Ingredients: ${ingredients.join(', ')}',
                        style: const TextStyle(
                          color: _ink,
                          height: 1.4,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          if ((result?['safety_note']?.toString() ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              result!['safety_note'].toString(),
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        foregroundColor: _ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Food & nourishment',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _loading ? null : _loadNutrition,
            icon: const Icon(Icons.sync_rounded),
            label: const Text('Sync preferences'),
            style: TextButton.styleFrom(
              foregroundColor: _ink,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 38,
                    height: 38,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: _coral,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Gathering a little nourishment…',
                    style: TextStyle(
                      color: _muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _line),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE8DD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.soup_kitchen_rounded,
                  size: 38,
                  color: Color(0xFFD96850),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Oops, the kitchen is taking a break',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _muted, height: 1.45),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _loadNutrition,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
                style: FilledButton.styleFrom(
                  backgroundColor: _ink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final data = _data ?? <String, dynamic>{};
    final guidance = data['nutrition_guidance']?.toString().trim() ?? '';
    final foods = data['foods'] is List
        ? (data['foods'] as List).whereType<Map>().toList()
        : <Map>[];
    final allergies = data['food_allergies'] is List
        ? (data['food_allergies'] as List)
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList()
        : <String>[];
    final customPreference =
        data['custom_dietary_preference']?.toString().trim() ?? '';
    final week = data['content_week'] ?? data['current_week'] ?? '-';

    return RefreshIndicator(
      color: _coral,
      onRefresh: _loadNutrition,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          _buildHero(week),
          const SizedBox(height: 24),
          if (guidance.isNotEmpty) ...[
            _sectionHeader(
              eyebrow: 'A LITTLE GUIDANCE',
              title: 'Nourish yourself, gently',
              subtitle: 'Small, steady choices are worth celebrating.',
            ),
            const SizedBox(height: 12),
            _buildGuidance(guidance),
            const SizedBox(height: 26),
          ],
          _sectionHeader(
            eyebrow: 'GOOD THINGS TO EAT',
            title: 'Your food inspiration',
            subtitle: 'Suggestions based on your preferences.',
            trailing: foods.isNotEmpty
                ? _countBadge('${foods.length} ideas')
                : null,
          ),
          const SizedBox(height: 14),
          if (foods.isEmpty)
            _emptyFoods()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 720 ? 3 : 2;
                final itemWidth =
                    (constraints.maxWidth - ((columns - 1) * 12)) / columns;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: foods.map((food) {
                    final name = food['name']?.toString().trim().isNotEmpty == true
                        ? food['name'].toString()
                        : 'Food idea';
                    final diets = food['diet_types'] is List
                        ? (food['diet_types'] as List)
                            .map((item) => item.toString())
                            .where((item) => item.trim().isNotEmpty)
                            .toList()
                        : <String>[];
                    return SizedBox(
                      width: itemWidth,
                      child: _foodTile(
                        name: name,
                        diets: diets,
                        index: foods.indexOf(food),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          const SizedBox(height: 26),
          _sectionHeader(
            eyebrow: 'A FRESH LITTLE IDEA',
            title: 'Create AI meal suggestions',
            subtitle: 'Choose what sounds good, then ask for personalized ideas.',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(23),
              border: Border.all(color: _line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cuisine',
                  style: TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCuisine,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _cream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 11,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Indian', child: Text('Indian')),
                    DropdownMenuItem(value: 'Mediterranean', child: Text('Mediterranean')),
                    DropdownMenuItem(value: 'East Asian', child: Text('East Asian')),
                    DropdownMenuItem(value: 'Western', child: Text('Western')),
                    DropdownMenuItem(value: 'Any cuisine', child: Text('Any cuisine')),
                  ],
                  onChanged: _generatingSuggestions
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _selectedCuisine = value);
                          }
                        },
                ),
                const SizedBox(height: 13),
                const Text(
                  'Meal type',
                  style: TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                DropdownButtonFormField<String>(
                  initialValue: _selectedMealType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _cream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 11,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Any meal', child: Text('Any meal')),
                    DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
                    DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                    DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
                    DropdownMenuItem(value: 'Snack', child: Text('Snack')),
                  ],
                  onChanged: _generatingSuggestions
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _selectedMealType = value);
                          }
                        },
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _generatingSuggestions ? null : _generateAiSuggestions,
                    icon: _generatingSuggestions
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome_rounded),
                    label: Text(
                      _generatingSuggestions
                          ? 'Cooking up ideas…'
                          : 'Generate AI suggestions',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _ink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                if (_suggestionsError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _suggestionsError!,
                    style: const TextStyle(
                      color: Color(0xFFB95754),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_aiSuggestions != null) ...[
            const SizedBox(height: 14),
            _buildAiSuggestions(),
          ],
          const SizedBox(height: 26),
          _buildPreferenceAndAllergies(
            allergies: allergies,
            customPreference: customPreference,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDE4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFB66A63),
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This is general nutrition information, not medical advice. Your healthcare professional can help with advice for your individual needs.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 12,
                      height: 1.45,
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

  Widget _buildHero(Object week) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 390;
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFB58E), Color(0xFFFF8877), Color(0xFFF16D70)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE77B68).withValues(alpha: 0.20),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -42,
                right: -32,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 30,
                right: compact ? 12 : 24,
                child: _foodDoodle('🍊', compact ? 30 : 38, -12),
              ),
              Positioned(
                right: compact ? 60 : 90,
                bottom: 28,
                child: _foodDoodle('🥑', compact ? 28 : 34, 10),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 18 : 23,
                  22,
                  compact ? 18 : 23,
                  23,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.23),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.32),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.spa_rounded, color: Colors.white, size: 15),
                          SizedBox(width: 6),
                          Text(
                            'NOURISHMENT, MADE GENTLE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: compact ? 220 : 255,
                      child: Text(
                        'A little more goodness for you.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 28 : 32,
                          height: 1.04,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.9,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: compact ? 215 : 245,
                      child: Text(
                        'Small, satisfying food ideas for wherever you are in your pregnancy.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE6A5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'PREGNANCY WEEK $week',
                        style: const TextStyle(
                          color: Color(0xFF69472D),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _foodDoodle(String emoji, double size, double rotation) {
    return Transform.rotate(
      angle: rotation * 3.1415926535 / 180,
      child: Container(
        width: size + 18,
        height: size + 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Text(emoji, style: TextStyle(fontSize: size * 0.72)),
      ),
    );
  }

  Widget _sectionHeader({
    required String eyebrow,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                eyebrow,
                style: const TextStyle(
                  color: Color(0xFFB66D5D),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 23,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.65,
          ),
        ),
        const SizedBox(height: 4),
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

  Widget _buildGuidance(String guidance) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4E8),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFFD5E8D5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFD0E8D0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: Color(0xFF3E805A),
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              guidance,
              style: const TextStyle(
                color: Color(0xFF3D5845),
                fontSize: 14,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _foodTile({
    required String name,
    required List<String> diets,
    required int index,
  }) {
    const palettes = [
      [Color(0xFFFFE8D9), Color(0xFFFFF8F1), Color(0xFFC76A4D)],
      [Color(0xFFDDF2DF), Color(0xFFF5FBF2), Color(0xFF4A9164)],
      [Color(0xFFFFE8A8), Color(0xFFFFFAE8), Color(0xFF946A25)],
      [Color(0xFFE8E2FF), Color(0xFFFAF8FF), Color(0xFF7869B4)],
      [Color(0xFFDDF0FA), Color(0xFFF5FBFF), Color(0xFF4387A8)],
      [Color(0xFFFFE1E8), Color(0xFFFFF7F8), Color(0xFFBC627C)],
    ];
    final palette = palettes[index % palettes.length];
    final emoji = _emojiForFood(name);

    return Container(
      constraints: const BoxConstraints(minHeight: 154),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette[0], palette[1]],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette[0]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.84),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Semantics(
                  label: 'Illustration for $name',
                  image: true,
                  child: Text(emoji, style: const TextStyle(fontSize: 32)),
                ),
              ),
              const Spacer(),
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.68),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: palette[2],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _displayFoodName(name),
            style: const TextStyle(
              color: _ink,
              fontSize: 15,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _foodDescription(name),
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // Use familiar Indian names and plain-language descriptions.
  // Dietary suitability tags are intentionally hidden because labels such as
  // "non_vegetarian" describe backend categories, not the food itself.
  String _displayFoodName(String name) {
    final value = name.toLowerCase();
    if (value.contains('tofu')) return 'Tofu (soybean paneer)';
    if (value.contains('chickpea')) return 'Chana (chickpeas)';
    if (value == 'spinach' || value.contains('spinach')) {
      return 'Palak (spinach)';
    }
    if (value.contains('brown rice')) return 'Brown rice';
    if (value.contains('papaya')) return 'Papaya';
    return name;
  }

  String _foodDescription(String name) {
    final value = name.toLowerCase();
    if (value.contains('tofu')) {
      return 'Made from soybeans; similar in texture to paneer. Contains soy.';
    }
    if (value.contains('chickpea')) {
      return 'Protein- and fibre-rich chana for curries, salads, or snacks.';
    }
    if (value.contains('spinach')) {
      return 'Palak can be added to dal, sabzi, or other cooked dishes.';
    }
    if (value.contains('brown rice')) {
      return 'A whole-grain rice option to serve with dal or sabzi.';
    }
    if (value.contains('papaya')) {
      return 'Choose ripe papaya; avoid unripe or semi-ripe papaya during pregnancy.';
    }
    return 'A food idea selected for your saved preferences.';
  }

  String _emojiForFood(String name) {
    final value = name.toLowerCase();
    if (value.contains('apple') || value.contains('berry') ||
        value.contains('banana') || value.contains('orange') ||
        value.contains('mango') || value.contains('fruit')) {
      if (value.contains('banana')) return '🍌';
      if (value.contains('orange')) return '🍊';
      if (value.contains('apple')) return '🍎';
      if (value.contains('berry')) return '🫐';
      if (value.contains('mango')) return '🥭';
      return '🍓';
    }
    if (value.contains('milk') || value.contains('yogurt') ||
        value.contains('cheese') || value.contains('curd')) {
      return '🥛';
    }
    if (value.contains('egg')) return '🥚';
    if (value.contains('fish') || value.contains('salmon')) return '🐟';
    if (value.contains('chicken') || value.contains('meat')) return '🍗';
    if (value.contains('nut') || value.contains('almond')) return '🥜';
    if (value.contains('bean') || value.contains('lentil') ||
        value.contains('dal') || value.contains('chickpea')) {
      return '🫘';
    }
    if (value.contains('rice') || value.contains('oat') ||
        value.contains('bread') || value.contains('grain')) {
      return '🍚';
    }
    if (value.contains('spinach') || value.contains('broccoli') ||
        value.contains('vegetable') || value.contains('leaf')) {
      return '🥦';
    }
    if (value.contains('avocado')) return '🥑';
    if (value.contains('water')) return '💧';
    return '🥗';
  }

  Widget _emptyFoods() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0D8),
        borderRadius: BorderRadius.circular(23),
      ),
      child: const Row(
        children: [
          Text('🥕', style: TextStyle(fontSize: 38)),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'No food suggestions are available for this week just yet.',
              style: TextStyle(
                color: _ink,
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _countBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE7D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF9B563F),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildPreferenceAndAllergies({
    required List<String> allergies,
    required String customPreference,
  }) {
    final hasAllergies = allergies.isNotEmpty;
    final hasPreference = customPreference.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          eyebrow: 'PERSONAL TO YOU',
          title: 'Your food notes',
          subtitle: 'A quick reminder of the preferences on your profile.',
        ),
        const SizedBox(height: 13),
        if (hasAllergies)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE7E5),
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: const Color(0xFFF5CFCC)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD3CF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.health_and_safety_rounded,
                    color: Color(0xFFB95754),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saved food allergies',
                        style: TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        allergies.join(' · '),
                        style: const TextStyle(
                          color: Color(0xFF8C4B4B),
                          height: 1.45,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          _noteRow(
            icon: Icons.verified_user_rounded,
            title: 'Food allergies',
            text: 'No food allergies listed on your profile.',
            background: const Color(0xFFE4F3E7),
            iconColor: const Color(0xFF43875B),
          ),
        if (hasPreference)
          _noteRow(
            icon: Icons.restaurant_menu_rounded,
            title: 'Your dietary preference',
            text: customPreference,
            background: const Color(0xFFE9E4FF),
            iconColor: const Color(0xFF7869B4),
          ),
      ],
    );
  }

  Widget _noteRow({
    required IconData icon,
    required String title,
    required String text,
    required Color background,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 25),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NutritionRecipeChef extends StatefulWidget {
  final String apiBaseUrl;
  final Future<Map<String, String>> Function() authHeaders;

  const NutritionRecipeChef({
    super.key,
    required this.apiBaseUrl,
    required this.authHeaders,
  });

  @override
  State<NutritionRecipeChef> createState() => _NutritionRecipeChefState();
}

class _NutritionRecipeChefState extends State<NutritionRecipeChef> {
  final TextEditingController _ingredientsController =
      TextEditingController();

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _recipe;
  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> _favourites = [];
  bool _storageLoaded = false;

  static const _historyKey = 'nutrition_recipe_history';
  static const _favouritesKey = 'nutrition_recipe_favourites';

  static const ink = Color(0xFF29352D);
  static const muted = Color(0xFF6E796F);
  static const coral = Color(0xFFFF806E);
  static const line = Color(0xFFEDE7DB);

  @override
  void initState() {
    super.initState();
    _loadLocalRecipes();
  }

  @override
  void dispose() {
    _ingredientsController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final historyRaw = prefs.getStringList(_historyKey) ?? [];
      final favouritesRaw = prefs.getStringList(_favouritesKey) ?? [];
      if (!mounted) return;
      setState(() {
        _history = historyRaw
            .map((e) => jsonDecode(e))
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _favourites = favouritesRaw
            .map((e) => jsonDecode(e))
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _storageLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _storageLoaded = true);
    }
  }

  Future<void> _saveLocalRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _historyKey,
      _history.map(jsonEncode).toList(),
    );
    await prefs.setStringList(
      _favouritesKey,
      _favourites.map(jsonEncode).toList(),
    );
  }

  Map<String, dynamic> _recipeData(Map<String, dynamic> response) {
    final result = response['result'];
    if (result is Map) return Map<String, dynamic>.from(result);
    return response;
  }

  String _recipeId(Map<String, dynamic> recipe) =>
      recipe['recipe_id']?.toString() ??
      '${recipe['dish_name'] ?? ''}|${recipe['description'] ?? ''}';

  bool _isFavourite(Map<String, dynamic> recipe) {
    final id = _recipeId(recipe);
    return _favourites.any((item) => _recipeId(item) == id);
  }

  Future<void> _toggleFavourite(Map<String, dynamic> recipe) async {
    final existing = _favourites.indexWhere(
      (item) => _recipeId(item) == _recipeId(recipe),
    );

    if (existing >= 0) {
      setState(() => _favourites.removeAt(existing));
      await _saveLocalRecipes();
      return;
    }

    if (_favourites.length >= 3) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can save up to 3 favourite dishes.'),
        ),
      );
      return;
    }

    setState(() {
      _favourites.insert(0, Map<String, dynamic>.from(recipe));
    });
    await _saveLocalRecipes();
  }

  Future<void> _addToHistory(Map<String, dynamic> recipe) async {
    final id = _recipeId(recipe);
    final updated = _history
        .where((item) => _recipeId(item) != id)
        .toList();
    updated.insert(0, Map<String, dynamic>.from(recipe));

    if (updated.length > 10) {
      updated.removeRange(10, updated.length);
    }

    if (!mounted) return;
    setState(() => _history = updated);
    await _saveLocalRecipes();
  }

  void _openRecipe(Map<String, dynamic> recipe) {
    setState(() => _recipe = Map<String, dynamic>.from(recipe));
  }

  Widget _savedRecipeRow(
    Map<String, dynamic> recipe, {
    required bool favourite,
  }) {
    final dish = recipe['dish_name']?.toString() ?? 'Indian dish';

    return InkWell(
      onTap: () => _openRecipe(recipe),
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Text('🍲', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                dish,
                style: const TextStyle(
                  color: ink,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(
              favourite
                  ? Icons.favorite_rounded
                  : Icons.chevron_right_rounded,
              size: 20,
              color: favourite ? coral : muted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _savedRecipes() {
    if (!_storageLoaded || (_history.isEmpty && _favourites.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_favourites.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Text(
            '❤️ Favourites',
            style: TextStyle(
              color: ink,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your saved dishes',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 6),
          ..._favourites.map((r) => _savedRecipeRow(r, favourite: true)),
        ],
        if (_history.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Text(
            '🕘 Recent food history',
            style: TextStyle(
              color: ink,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your last 10 generated dishes',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 6),
          ..._history.map((r) => _savedRecipeRow(r, favourite: false)),
        ],
      ],
    );
  }

  Future<void> _makeRecipe() async {
    final ingredients = _ingredientsController.text.trim();

    if (ingredients.isEmpty) {
      setState(() => _error = 'Tell me at least one ingredient you have.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _recipe = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${widget.apiBaseUrl}/pregnancy/nutrition/recipe'),
        headers: {
          ...await widget.authHeaders(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'ingredients': ingredients}),
      ).timeout(const Duration(seconds: 120));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final recipe = _recipeData(decoded);
          setState(() {
            _recipe = recipe;
            _loading = false;
          });
          await _addToHistory(recipe);
        } else {
          setState(() {
            _error = 'The server returned an unexpected recipe.';
            _loading = false;
          });
        }
      } else {
        String detail = '';
        try {
          final body = jsonDecode(response.body);
          if (body is Map) detail = (body['detail'] ?? '').toString();
        } catch (_) {}

        setState(() {
          _error = detail.isNotEmpty
              ? detail
              : 'Could not create the recipe. Please try again.';
          _loading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'Could not reach the AI service. Check FastAPI and Ollama, then try again.';
        _loading = false;
      });
    }
  }

  List<String> _list(dynamic value) {
    if (value is! List) return [];
    return value.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
  }

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ', style: TextStyle(color: coral, fontWeight: FontWeight.w900)),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: ink, fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      );

  Widget _section(String title, IconData icon, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: Color(0xFF6D796B)),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  color: ink,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _recipeCard() {
    final recipe = _recipe!;
    final ingredients = _list(recipe['ingredients']);
    final staples = _list(recipe['basic_staples']);
    final steps = _list(recipe['recipe_steps']);
    final benefits = _list(recipe['potential_benefits']);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🍲', style: TextStyle(fontSize: 34)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  recipe['dish_name']?.toString() ?? 'Your Indian dish',
                  style: const TextStyle(
                    color: ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => _toggleFavourite(recipe),
              icon: Icon(
                _isFavourite(recipe)
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 18,
              ),
              label: Text(_isFavourite(recipe) ? 'Favourited' : 'Add favourite'),
            ),
          ),
          if ((recipe['description']?.toString() ?? '').isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              recipe['description'].toString(),
              style: const TextStyle(color: muted, fontSize: 13, height: 1.45),
            ),
          ],
          _section(
            'Why I recommend this',
            Icons.lightbulb_rounded,
            Text(
              recipe['why_recommended']?.toString() ?? '',
              style: const TextStyle(color: ink, fontSize: 13.5, height: 1.5),
            ),
          ),
          _section(
            'What you will use',
            Icons.shopping_basket_rounded,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...ingredients.map(_bullet),
                if (staples.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Basic kitchen staples',
                    style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  ...staples.map(_bullet),
                ],
              ],
            ),
          ),
          _section(
            'How to make it',
            Icons.menu_book_rounded,
            Column(
              children: [
                for (var i = 0; i < steps.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: const Color(0xFFFFE4D5),
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Color(0xFF9B563F),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            steps[i],
                            style: const TextStyle(color: ink, fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          _section(
            'Potential benefits',
            Icons.favorite_rounded,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: benefits.map(_bullet).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF4D9272)),
              const SizedBox(width: 5),
              Text(
                recipe['cooking_time']?.toString() ?? 'About 30 minutes',
                style: const TextStyle(
                  color: Color(0xFF4D6C58),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if ((recipe['safety_note']?.toString() ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDE4),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                recipe['safety_note'].toString(),
                style: const TextStyle(color: muted, fontSize: 11.5, height: 1.45),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'A FRESH LITTLE IDEA',
          style: TextStyle(
            color: coral,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'What can I cook?',
          style: TextStyle(
            color: ink,
            fontSize: 23,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.65,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tell me what is in your kitchen and I will create an Indian dish around it.',
          style: TextStyle(color: muted, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE4D5), Color(0xFFFFF8F1)],
            ),
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: const Color(0xFFF2D5C3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('👩‍🍳', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your AI Kitchen Chef',
                      style: TextStyle(
                        color: ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text('🇮🇳', style: TextStyle(fontSize: 23)),
                ],
              ),
              const SizedBox(height: 13),
              TextField(
                controller: _ingredientsController,
                minLines: 2,
                maxLines: 4,
                onSubmitted: (_) => _makeRecipe(),
                decoration: InputDecoration(
                  hintText: 'e.g. potato, spinach, onion, tomato, rice',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.kitchen_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: const BorderSide(color: Color(0xFFE8DDD4)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: const BorderSide(color: Color(0xFFE8DDD4)),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Basic staples like salt, oil, cumin, turmeric, ginger and water are assumed.',
                style: TextStyle(color: muted, fontSize: 11.5, height: 1.35),
              ),
              const SizedBox(height: 13),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _makeRecipe,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(_loading ? 'Creating your dish…' : 'Make my dish'),
                  style: FilledButton.styleFrom(
                    backgroundColor: ink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 9),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Color(0xFFB95754),
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_recipe != null) _recipeCard(),
        _savedRecipes(),
      ],
    );
  }
}

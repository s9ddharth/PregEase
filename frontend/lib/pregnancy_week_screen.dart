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
          child: CircularProgressIndicator(),
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Week ${data['week']}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section(
            'Baby Growth',
            data['baby_growth'],
          ),
          _section(
            'Body Changes',
            data['body_changes'],
          ),
          _section(
            'Activities',
            data['activities'],
          ),
          _section(
            'Nutrition',
            data['nutrition_guidance'],
          ),
          _section(
            'Precautions',
            data['precautions'],
          ),
          _section(
            'Mental Wellness',
            data['mental_wellness'],
          ),

const SizedBox(height: 8),

const Text(
  'Sources',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 8),

...((data['sources'] as List?) ?? []).map(
  (source) {
    final sourceMap = source as Map<String, dynamic>;
    final url = sourceMap['url']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
     onTap: () async {
  final uri = Uri.tryParse(url);

  if (uri == null) return;

  final opened = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );

  if (!context.mounted) return;

  if (!opened) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open source.'),
      ),
    );
  }
},
        child: Text(
          '${sourceMap['organization']}\n'
          '${sourceMap['title']}',
          style: const TextStyle(
            fontSize: 15,
            height: 1.4,
            decoration: TextDecoration.underline,
          ),
        ),
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
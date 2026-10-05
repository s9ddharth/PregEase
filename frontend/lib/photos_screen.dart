import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'package:http/http.dart' as http;

class PregnancyPhoto {
  final String id;
  final int week;
  final String date;
  final String? caption;
  final String imageBase64;

  const PregnancyPhoto({
    required this.id,
    required this.week,
    required this.date,
    required this.caption,
    required this.imageBase64,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'week': week,
        'date': date,
        'caption': caption,
        'image': imageBase64,
      };

  factory PregnancyPhoto.fromJson(Map<String, dynamic> json) {
    return PregnancyPhoto(
      id: json['id']?.toString() ?? '',
      week: int.tryParse(json['week']?.toString() ?? '') ?? 1,
      date: json['date']?.toString() ?? '',
      caption: json['caption']?.toString(),
      imageBase64: json['image']?.toString() ?? '',
    );
  }
}

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  static const _storageKey = 'pregease_pregnancy_photos_v1';

  final ImagePicker _picker = ImagePicker();

  List<PregnancyPhoto> _photos = [];
  int _currentWeek = 1;
  bool _loading = true;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _photos = decoded
              .whereType<Map>()
              .map((item) =>
                  PregnancyPhoto.fromJson(Map<String, dynamic>.from(item)))
              .where((photo) => photo.imageBase64.isNotEmpty)
              .toList();
        }
      } catch (_) {
        _photos = [];
      }
    }

    _currentWeek = await _loadCurrentWeek();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<int> _loadCurrentWeek() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/pregnancy/profile'),
        headers: await authHeaders(),
      );

      if (response.statusCode != 200) return 1;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return 1;

      final profile = decoded['profile'];
      final source = profile is Map ? profile : decoded;

      final rawWeek = source['current_week'] ??
          source['pregnancy_week'] ??
          source['week'];

      final week = int.tryParse(rawWeek?.toString() ?? '');
      if (week == null) return 1;

      return week.clamp(1, 40);
    } catch (_) {
      return 1;
    }
  }

  Future<void> _persistPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_photos.map((photo) => photo.toJson()).toList()),
    );
  }

  Future<void> _showAddPhotoSheet() async {
    if (_adding) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFFFFFDF9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D4CB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Add a pregnancy photo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF405442),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose a photo of your journey together.',
                style: TextStyle(color: Color(0xFF77796F)),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFE4D6),
                  child: Icon(Icons.camera_alt_rounded,
                      color: Color(0xFFB95D50)),
                ),
                title: const Text('Take a photo'),
                subtitle: const Text('Use your camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEAF1E8),
                  child: Icon(Icons.photo_library_rounded,
                      color: Color(0xFF4D9272)),
                ),
                title: const Text('Choose from gallery'),
                subtitle: const Text('Pick a saved photo'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;
    await _addPhoto(source);
  }

  Future<void> _addPhoto(ImageSource source) async {
    setState(() => _adding = true);

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final encoded = base64Encode(bytes);

      final caption = await _askCaption();
      if (!mounted) return;

      final photo = PregnancyPhoto(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        week: _currentWeek,
        date: DateTime.now().toIso8601String(),
        caption: caption,
        imageBase64: encoded,
      );

      setState(() {
        _photos.insert(0, photo);
      });

      await _persistPhotos();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo saved to Week $_currentWeek ❤️'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save that photo. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _adding = false);
      }
    }
  }

  Future<String?> _askCaption() async {
    final controller = TextEditingController();

    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a caption'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 120,
          decoration: const InputDecoration(
            hintText: 'e.g. Our little bump is growing ❤️',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              controller.text.trim().isEmpty
                  ? null
                  : controller.text.trim(),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  Future<void> _deletePhoto(PregnancyPhoto photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete photo?'),
        content: const Text('This photo will be removed from your PregEase photos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _photos.removeWhere((item) => item.id == photo.id);
    });
    await _persistPhotos();
  }

  void _openPhoto(PregnancyPhoto photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PhotoViewer(photo: photo),
      ),
    );
  }

  Map<int, List<PregnancyPhoto>> get _grouped {
    final grouped = <int, List<PregnancyPhoto>>{};

    for (final photo in _photos) {
      grouped.putIfAbsent(photo.week, () => []).add(photo);
    }

    final weeks = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {
      for (final week in weeks) week: grouped[week]!,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
      appBar: AppBar(
        title: const Text(
          'Our Photos',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Add photo',
            onPressed: _adding ? null : _showAddPhotoSheet,
            icon: const Icon(Icons.add_a_photo_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adding ? null : _showAddPhotoSheet,
        icon: _adding
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_rounded),
        label: Text(_adding ? 'Saving…' : 'Add Photo'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? _EmptyPhotos(onAdd: _showAddPhotoSheet, week: _currentWeek)
              : RefreshIndicator(
                  onRefresh: _loadPhotos,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                    children: [
                      _JourneyHeader(
                        week: _currentWeek,
                        count: _photos.length,
                      ),
                      const SizedBox(height: 22),
                      ..._grouped.entries.map(
                        (entry) => _WeekSection(
                          week: entry.key,
                          photos: entry.value,
                          onTap: _openPhoto,
                          onDelete: _deletePhoto,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _JourneyHeader extends StatelessWidget {
  final int week;
  final int count;

  const _JourneyHeader({
    required this.week,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFDCCB), Color(0xFFF8EAE6)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Color(0xFFB95D50),
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your pregnancy journey',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF405442),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Week $week • $count ${count == 1 ? 'photo' : 'photos'} saved',
                  style: const TextStyle(
                    color: Color(0xFF6D6D65),
                    fontWeight: FontWeight.w600,
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

class _WeekSection extends StatelessWidget {
  final int week;
  final List<PregnancyPhoto> photos;
  final void Function(PregnancyPhoto) onTap;
  final void Function(PregnancyPhoto) onDelete;

  const _WeekSection({
    required this.week,
    required this.photos,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.favorite_border_rounded,
                size: 19,
                color: Color(0xFFB95D50),
              ),
              const SizedBox(width: 7),
              Text(
                'Week $week',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF405442),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: photos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: .86,
            ),
            itemBuilder: (context, index) {
              final photo = photos[index];

              return GestureDetector(
                onTap: () => onTap(photo),
                onLongPress: () => onDelete(photo),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(
                        base64Decode(photo.imageBase64),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFEFEAE2),
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(11, 24, 11, 10),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0xCC000000)],
                            ),
                          ),
                          child: Text(
                            photo.caption ?? 'Our little moment ❤️',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          const Text(
            'Long-press a photo to delete',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF96958D),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPhotos extends StatelessWidget {
  final VoidCallback onAdd;
  final int week;

  const _EmptyPhotos({
    required this.onAdd,
    required this.week,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 132,
              height: 132,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE8DD),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_camera_back_rounded,
                size: 62,
                color: Color(0xFFB95D50),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Start your photo journey',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: Color(0xFF405442),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save little moments from Week $week onward — the photos you will love looking back on.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                height: 1.5,
                color: Color(0xFF77796F),
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_a_photo_rounded),
              label: const Text('Add your first photo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  final PregnancyPhoto photo;

  const _PhotoViewer({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Week ${photo.week}'),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: .8,
          maxScale: 4,
          child: Image.memory(
            base64Decode(photo.imageBase64),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

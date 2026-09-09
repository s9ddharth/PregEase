import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

class CommunityFeedScreen extends StatefulWidget {
  final int communityId;
  final String communityName;
  final String description;
  final int memberCount;

  const CommunityFeedScreen({
    super.key,
    required this.communityId,
    required this.communityName,
    required this.description,
    required this.memberCount,
  });

  @override
  State<CommunityFeedScreen> createState() =>
      _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  // ==========================================================
  // PREG EASE COLORS
  // ==========================================================

  static const Color violet = Color(0xFF6C5CE7);
  static const Color violetDeep = Color(0xFF4C3FBF);
  static const Color violetPale = Color(0xFFEFECFC);

  static const Color pink = Color(0xFFFADCE0);
  static const Color pinkInk = Color(0xFFC4577A);

  static const Color ink = Color(0xFF241F35);
  static const Color inkSoft = Color(0xFF6B667F);

  static const Color background = Color(0xFFFBF9FC);
  static const Color line = Color(0x1A241F35);

  // ==========================================================
  // STATE
  // ==========================================================

  List<Map<String, dynamic>> _posts = [];

  bool _loading = true;
  String? _error;

  int _selectedTab = 0;

  // ==========================================================
  // LIFECYCLE
  // ==========================================================

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  // ==========================================================
  // LOAD POSTS
  // ==========================================================

  Future<void> _loadPosts() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$apiBaseUrl/community/${widget.communityId}/posts',
        ),
        headers: await authHeaders(),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List<dynamic> data =
            decoded is List ? decoded : [];

        setState(() {
          _posts = data
              .whereType<Map>()
              .map(
                (item) => Map<String, dynamic>.from(item),
              )
              .toList();

          _loading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _error = 'Please log in again.';
          _loading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _error = 'Community not found.';
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Unable to load community posts.';
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Community feed error: $e');

      if (!mounted) return;

      setState(() {
        _error = 'Could not connect to the server.';
        _loading = false;
      });
    }
  }

  // ==========================================================
  // CREATE POST
  // ==========================================================

  Future<void> _createPost() async {
    final controller = TextEditingController();

    final content = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: violetPale,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: violet,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Start a conversation',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Share something with other parents in this community.',
                  style: TextStyle(
                    color: inkSoft,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  maxLines: 6,
                  maxLength: 2000,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'What would you like to share?',
                    hintStyle: const TextStyle(
                      color: inkSoft,
                    ),
                    filled: true,
                    fillColor: background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: violet,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: inkSoft,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: violet,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        final text = controller.text.trim();

                        if (text.isEmpty) {
                          return;
                        }

                        Navigator.pop(dialogContext, text);
                      },
                      child: const Text(
                        'Post',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    controller.dispose();

    if (content == null || content.trim().isEmpty) {
      return;
    }

    await _submitPost(content.trim());
  }

  Future<void> _submitPost(String content) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$apiBaseUrl/community/${widget.communityId}/posts',
        ),
        headers: await authHeaders(),
        body: jsonEncode({
          'content': content,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        _showMessage(
          'Your post was created successfully.',
        );

        await _loadPosts();
      } else if (response.statusCode == 401) {
        _showMessage(
          'Your login session has expired.',
        );
      } else if (response.statusCode == 403) {
        _showMessage(
          'You need to be a member to post here.',
        );
      } else {
        _showMessage(
          'Unable to create your post.',
        );
      }
    } catch (e) {
      debugPrint('Create post error: $e');

      if (!mounted) return;

      _showMessage(
        'Could not connect to the server.',
      );
    }
  }

  // ==========================================================
  // DELETE POST
  // ==========================================================

  Future<void> _deletePost(int postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Delete post?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          content: const Text(
            'This action cannot be undone.',
            style: TextStyle(
              color: inkSoft,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: inkSoft,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(
          '$apiBaseUrl/community/${widget.communityId}/posts/$postId',
        ),
        headers: await authHeaders(),
      );

      if (!mounted) return;

      if (response.statusCode == 200 ||
          response.statusCode == 204) {
        setState(() {
          _posts.removeWhere(
            (post) => _postId(post) == postId,
          );
        });

        _showMessage('Post deleted.');
      } else if (response.statusCode == 403) {
        _showMessage(
          'You can only delete your own post.',
        );
      } else if (response.statusCode == 404) {
        _showMessage('Post not found.');
      } else {
        _showMessage(
          'Unable to delete the post.',
        );
      }
    } catch (e) {
      debugPrint('Delete post error: $e');

      if (!mounted) return;

      _showMessage(
        'Could not connect to the server.',
      );
    }
  }

  // ==========================================================
  // REPORT POST
  // ==========================================================

  Future<void> _reportPost(int postId) async {
    String selectedReason = 'spam';

    final detailsController =
        TextEditingController();

    final result =
        await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: pink,
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.flag_outlined,
                            color: pinkInk,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Report post',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Help us keep the community safe and supportive.',
                      style: TextStyle(
                        color: inkSoft,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: selectedReason,
                      decoration: InputDecoration(
                        labelText: 'Reason',
                        filled: true,
                        fillColor: background,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'spam',
                          child: Text('Spam'),
                        ),
                        DropdownMenuItem(
                          value: 'harassment',
                          child: Text('Harassment'),
                        ),
                        DropdownMenuItem(
                          value: 'hate',
                          child: Text('Hate or abuse'),
                        ),
                        DropdownMenuItem(
                          value: 'violence',
                          child: Text('Violence'),
                        ),
                        DropdownMenuItem(
                          value: 'sexual_content',
                          child: Text('Sexual content'),
                        ),
                        DropdownMenuItem(
                          value:
                              'dangerous_medical_content',
                          child: Text(
                            'Dangerous medical content',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'privacy',
                          child: Text('Privacy concern'),
                        ),
                        DropdownMenuItem(
                          value: 'other',
                          child: Text('Other'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setDialogState(() {
                          selectedReason = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: detailsController,
                      maxLines: 4,
                      maxLength: 1000,
                      decoration: InputDecoration(
                        labelText:
                            'Additional details (optional)',
                        hintText:
                            'Tell us what happened...',
                        filled: true,
                        fillColor: background,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: inkSoft,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: pinkInk,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 13,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(
                              dialogContext,
                              {
                                'reason': selectedReason,
                                'details':
                                    detailsController.text
                                        .trim(),
                              },
                            );
                          },
                          child: const Text(
                            'Submit report',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    detailsController.dispose();

    if (result == null) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
          '$apiBaseUrl/community/${widget.communityId}/posts/$postId/report',
        ),
        headers: await authHeaders(),
        body: jsonEncode({
          'reason': result['reason'],
          'details': result['details'],
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        _showMessage(
          'Thank you. The report has been submitted.',
        );
      } else if (response.statusCode == 400) {
        _showMessage(
          'You cannot report this post.',
        );
      } else if (response.statusCode == 409) {
        _showMessage(
          'You have already reported this post.',
        );
      } else if (response.statusCode == 404) {
        _showMessage('Post not found.');
      } else {
        _showMessage(
          'Unable to submit the report.',
        );
      }
    } catch (e) {
      debugPrint('Report post error: $e');

      if (!mounted) return;

      _showMessage(
        'Could not connect to the server.',
      );
    }
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  int _postId(Map<String, dynamic> post) {
    final value =
        post['id'] ?? post['post_id'];

    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // ==========================================================
  // TAB
  // ==========================================================

  void _selectTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ink,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Community',
          style: TextStyle(
            color: ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: _createPost,
              backgroundColor: violet,
              foregroundColor: Colors.white,
              icon: const Icon(
                Icons.add_rounded,
              ),
              label: const Text(
                'Create Post',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      body: RefreshIndicator(
        color: violet,
        onRefresh: _loadPosts,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            18,
            4,
            18,
            110,
          ),
          children: [
            _buildCommunityHero(),
            const SizedBox(height: 18),
            _buildTabs(),
            const SizedBox(height: 20),
            if (_selectedTab == 0)
              _buildPostsTab()
            else if (_selectedTab == 1)
              _buildAboutTab()
            else
              _buildMembersTab(),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // COMMUNITY HERO
  // ==========================================================

  Widget _buildCommunityHero() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0ECFF),
            Color(0xFFFFEEF1),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color:
                      Colors.white.withValues(
                    alpha: 0.9,
                  ),
                  borderRadius:
                      BorderRadius.circular(19),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: violet,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.communityName,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 24,
                        height: 1.1,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${widget.memberCount} members',
                      style: const TextStyle(
                        color: violetDeep,
                        fontWeight:
                            FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            widget.description,
            style: const TextStyle(
              color: inkSoft,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPill(
                icon: Icons.public_rounded,
                text: 'Public',
                background: Colors.white,
                foreground: violetDeep,
              ),
              _buildPill(
                icon: Icons.favorite_rounded,
                text: 'Supportive space',
                background: Colors.white,
                foreground: pinkInk,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String text,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: foreground,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TABS
  // ==========================================================

  Widget _buildTabs() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: line,
        ),
      ),
      child: Row(
        children: [
          _buildTab(
            index: 0,
            icon: Icons.forum_rounded,
            label: 'Posts',
          ),
          _buildTab(
            index: 1,
            icon: Icons.info_outline_rounded,
            label: 'About',
          ),
          _buildTab(
            index: 2,
            icon: Icons.people_outline_rounded,
            label: 'Members',
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final selected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectTab(index),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected
                ? violetPale
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? violetDeep
                    : inkSoft,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? violetDeep
                      : inkSoft,
                  fontWeight: selected
                      ? FontWeight.w800
                      : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // POSTS TAB
  // ==========================================================

  Widget _buildPostsTab() {
    if (_loading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_posts.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.forum_rounded,
              color: violet,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Community conversation',
              style: TextStyle(
                color: ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Share experiences, ask questions, and support other parents.',
          style: TextStyle(
            color: inkSoft,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        ..._posts.map(
          (post) => _PostCard(
            post: post,
            onDelete: () {
              _deletePost(_postId(post));
            },
            onReport: () {
              _reportPost(_postId(post));
            },
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // ABOUT TAB
  // ==========================================================

  Widget _buildAboutTab() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildInfoSection(
          icon: Icons.info_outline_rounded,
          title: 'About this community',
          child: Text(
            widget.description,
            style: const TextStyle(
              color: inkSoft,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _buildInfoSection(
          icon: Icons.people_outline_rounded,
          title: 'Community size',
          child: Text(
            '${widget.memberCount} members',
            style: const TextStyle(
              color: inkSoft,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _buildInfoSection(
          icon: Icons.shield_outlined,
          title: 'Community guidelines',
          child: const Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _GuidelineRow(
                icon:
                    Icons.favorite_border_rounded,
                text:
                    'Be kind and supportive to other parents.',
              ),
              SizedBox(height: 10),
              _GuidelineRow(
                icon:
                    Icons.verified_user_outlined,
                text:
                    'Avoid sharing unsafe or harmful medical advice.',
              ),
              SizedBox(height: 10),
              _GuidelineRow(
                icon:
                    Icons.lock_outline_rounded,
                text:
                    'Respect the privacy of other community members.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: line,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: violetPale,
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: violet,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: ink,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ==========================================================
  // MEMBERS TAB
  // ==========================================================

  Widget _buildMembersTab() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: line,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: violetPale,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: violet,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.memberCount} community members',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ink,
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Member profiles will be available here as the community member directory is connected.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: inkSoft,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LOADING
  // ==========================================================

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 70,
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: violet,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading community posts...',
            style: TextStyle(
              color: inkSoft,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // EMPTY
  // ==========================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: line,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: violetPale,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.forum_outlined,
              color: violet,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No posts yet',
            style: TextStyle(
              color: ink,
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Be the first parent to start a conversation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: inkSoft,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _createPost,
            style: FilledButton.styleFrom(
              backgroundColor: violet,
              foregroundColor:
                  Colors.white,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(
              Icons.add_rounded,
            ),
            label: const Text(
              'Create the first post',
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: line,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: inkSoft,
            size: 42,
          ),
          const SizedBox(height: 14),
          Text(
            _error ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ink,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _loadPosts,
            style:
                OutlinedButton.styleFrom(
              foregroundColor: violet,
              side: const BorderSide(
                color: violet,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// POST CARD
// ============================================================

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  const _PostCard({
    required this.post,
    required this.onDelete,
    required this.onReport,
  });

  static const Color violet =
      Color(0xFF6C5CE7);
  static const Color violetPale =
      Color(0xFFEFECFC);
  static const Color ink =
      Color(0xFF241F35);
  static const Color inkSoft =
      Color(0xFF6B667F);
  static const Color line =
      Color(0x1A241F35);

  int _postId() {
    final value =
        post['id'] ?? post['post_id'];

    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _content() {
    return post['content']
            ?.toString()
            .trim() ??
        '';
  }

  String _author() {
    final value =
        post['author_name'] ??
        post['user_name'] ??
        post['username'] ??
        post['author'];

    final text =
        value?.toString().trim() ?? '';

    return text.isEmpty
        ? 'Parent'
        : text;
  }

  String _date() {
    final value =
        post['created_at'] ??
        post['createdAt'] ??
        post['date'];

    if (value == null) {
      return '';
    }

    try {
      final date =
          DateTime.parse(
        value.toString(),
      ).toLocal();

      final now = DateTime.now();
      final difference =
          now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      }

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      }

      if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      }

      if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      }

      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: line,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(0xFFEDE9FF),
                      Color(0xFFFCE6EA),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: violet,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _author(),
                      style:
                          const TextStyle(
                        color: ink,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _date(),
                      style:
                          const TextStyle(
                        color: inkSoft,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: inkSoft,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  } else if (value ==
                      'report') {
                    onReport();
                  }
                },
                itemBuilder:
                    (context) => [
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 19,
                        ),
                        SizedBox(width: 10),
                        Text('Report post'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .delete_outline_rounded,
                          size: 19,
                        ),
                        SizedBox(width: 10),
                        Text('Delete post'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _content(),
            style: const TextStyle(
              color: ink,
              fontSize: 14.5,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: line,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: violetPale,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      Icons
                          .favorite_border_rounded,
                      size: 15,
                      color: violet,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Support',
                      style: TextStyle(
                        color: violet,
                        fontSize: 11.5,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '#${_postId()}',
                style: const TextStyle(
                  color: inkSoft,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// GUIDELINE ROW
// ============================================================

class _GuidelineRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GuidelineRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 1),
        Icon(
          icon,
          color: Color(0xFF6C5CE7),
          size: 19,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF6B667F),
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
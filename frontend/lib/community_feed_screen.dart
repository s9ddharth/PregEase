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

class _CommunityFeedScreenState
    extends State<CommunityFeedScreen> {
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  // ==========================================================
  // LOAD POSTS
  // ==========================================================

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '$apiBaseUrl/community/${widget.communityId}/posts',
        ),
        headers: await authHeaders(),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        setState(() {
          _posts = data
              .map(
                (item) =>
                    Map<String, dynamic>.from(item),
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
        return AlertDialog(
          title: const Text('Create Post'),
          content: TextField(
            controller: controller,
            maxLines: 6,
            maxLength: 2000,
            autofocus: true,
            decoration: const InputDecoration(
              hintText:
                  'What would you like to share with the community?',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();

                if (text.isEmpty) {
                  ScaffoldMessenger.of(dialogContext)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter some text.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  text,
                );
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted || content == null) {
      return;
    }

    await _submitPost(content);
  }

  // ==========================================================
  // SUBMIT POST
  // ==========================================================

  Future<void> _submitPost(String content) async {
    try {
      final headers = {
        ...await authHeaders(),
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse(
          '$apiBaseUrl/community/${widget.communityId}/posts',
        ),
        headers: headers,
        body: jsonEncode({
          'content': content,
        }),
      );

      if (!mounted) return;

      debugPrint(
        'CREATE POST STATUS: ${response.statusCode}',
      );

      debugPrint(
        'CREATE POST RESPONSE: ${response.body}',
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Post created successfully!',
            ),
          ),
        );

        await _loadPosts();
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              'Post failed (${response.statusCode})',
            ),
            content: SingleChildScrollView(
              child: SelectableText(
                response.body.isEmpty
                    ? 'The server returned an empty response.'
                    : response.body,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Connection Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
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
          title: const Text('Delete post?'),
          content: const Text(
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(
          '$apiBaseUrl/community/'
          '${widget.communityId}/posts/$postId',
        ),
        headers: await authHeaders(),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Post deleted successfully.',
            ),
          ),
        );

        await _loadPosts();
        return;
      }

      if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You can only delete your own posts.',
            ),
          ),
        );
        return;
      }

      if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Post not found.',
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to delete post '
            '(${response.statusCode}).',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not connect to the server.',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // REPORT POST
  // ==========================================================

  Future<void> _reportPost(int postId) async {
    debugPrint(
  'REPORT POST: communityId=${widget.communityId}, postId=$postId',
);
    final reasons = <String, String>{
      'harassment': 'Harassment',
      'hate': 'Hate / discrimination',
      'spam': 'Spam / scam',
      'sexual': 'Sexual content',
      'dangerous_medical':
          'Dangerous / medical misinformation',
      'privacy': 'Privacy / doxxing',
      'violence': 'Violence / threats',
      'other': 'Other',
    };


    String? selectedReason;
    final detailsController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text('Report Post'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Why are you reporting this post?',
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedReason,
                      decoration: const InputDecoration(
                        labelText: 'Reason',
                        border: OutlineInputBorder(),
                      ),
                      items: reasons.entries
                          .map(
                            (entry) =>
                                DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedReason = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: detailsController,
                      maxLines: 4,
                      maxLength: 1000,
                      decoration: const InputDecoration(
                        labelText: 'Additional details (optional)',
                        hintText:
                            'Tell us more about the issue.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: selectedReason == null
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                            true,
                          );
                        },
                  child: const Text('Report'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || result != true) {
      detailsController.dispose();
      return;
    }

    final reason = selectedReason!;
    final details = detailsController.text.trim();

    detailsController.dispose();

    try {
      final headers = {
        ...await authHeaders(),
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse(
          '$apiBaseUrl/community/'
          '${widget.communityId}/posts/$postId/report',
        ),
        headers: headers,
        body: jsonEncode({
          'reason': reason,
          'details': details.isEmpty ? null : details,
        }),
      );
      debugPrint(
  'REPORT RESPONSE: status=${response.statusCode}, body=${response.body}',
);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Report submitted successfully.',
            ),
          ),
        );
        return;
      }

      if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You cannot report your own post.',
            ),
          ),
        );
        return;
      }

      if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You have already reported this post.',
            ),
          ),
        );
        return;
      }

      if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Post not found.',
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to report post '
            '(${response.statusCode}).',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not connect to the server.',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // DATE FORMAT
  // ==========================================================

  String _formatDate(String? value) {
    if (value == null) return '';

    final date = DateTime.tryParse(value);

    if (date == null) return '';

    return '${date.day}/${date.month}/${date.year}';
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.communityName),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.communityName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              '${widget.memberCount} members',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            if (widget.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(widget.description),
            ],

            const SizedBox(height: 24),

            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              _FeedError(
                message: _error!,
                onRetry: _loadPosts,
              )
            else if (_posts.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(
                  child: Text(
                    'No posts yet.\n'
                    'Be the first to start the conversation!',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ..._posts.map(
                (post) => _PostCard(
                  postId: post['id'] as int,
                  isOwner: post['is_owner'] == true,
                  content:
                      post['content'] as String? ?? '',
                  date: _formatDate(
                    post['created_at'] as String?,
                  ),
                  onDelete: () {
                    _deletePost(
                      post['id'] as int,
                    );
                  },
                  onReport: () {
                    _reportPost(
                      post['id'] as int,
                    );
                  },
                ),
              ),
          ],
        ),
      ),

      // ========================================================
      // CREATE POST BUTTON
      // ========================================================

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _createPost,
        icon: const Icon(Icons.add),
        label: const Text('Create Post'),
      ),
    );
  }
}

// ============================================================
// POST CARD
// ============================================================

class _PostCard extends StatelessWidget {
  final int postId;
  final bool isOwner;
  final String content;
  final String date;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  const _PostCard({
    required this.postId,
    required this.isOwner,
    required this.content,
    required this.date,
    required this.onDelete,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),

                const SizedBox(width: 10),

                const Text(
                  'Parent',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                // ==================================================
                // THREE-DOT MENU
                // ==================================================

                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete();
                    }

                    if (value == 'report') {
                      onReport();
                    }
                  },
                  itemBuilder: (context) => [
                    if (isOwner)
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                            ),
                            SizedBox(width: 10),
                            Text('Delete'),
                          ],
                        ),
                      ),

                    if (!isOwner)
                      const PopupMenuItem<String>(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                            ),
                            SizedBox(width: 10),
                            Text('Report'),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FEED ERROR
// ============================================================

class _FeedError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FeedError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
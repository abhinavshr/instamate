import 'package:flutter/material.dart';
import '../services/home_service.dart';
import '../services/like_service.dart';
import '../services/comment_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _feed = [];
  bool _isLoading = true;
  String? _error;
  final Map<int, ValueNotifier<bool>> _heartAnimations = {};

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  ValueNotifier<bool> _getHeartNotifier(int index) {
    _heartAnimations[index] ??= ValueNotifier(false);
    return _heartAnimations[index]!;
  }

  Future<void> _loadFeed() async {
    try {
      final feed = await HomeService.getHomeFeed();
      setState(() {
        _feed = feed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleLike(int index) async {
    final post = _feed[index];
    final postId = post['post_id'] as int;
    final isLiked = post['is_liked'] as bool;

    if (!isLiked) {
      _getHeartNotifier(index).value = true;
      Future.delayed(const Duration(milliseconds: 800), () {
        _getHeartNotifier(index).value = false;
      });
    }

    setState(() {
      _feed[index]['is_liked'] = !isLiked;
      _feed[index]['like_count'] =
      isLiked ? post['like_count'] - 1 : post['like_count'] + 1;
    });

    try {
      await LikeService.toggleLike(postId);
    } catch (e) {
      setState(() {
        _feed[index]['is_liked'] = isLiked;
        _feed[index]['like_count'] = post['like_count'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update like')),
      );
    }
  }

  void _openComments(int postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _CommentsSheet(postId: postId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset('assets/images/logo.png', height: 32),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.message_outlined, color: Colors.black),
          ),
        ],
      ),

      body: Column(
        children: [
          _storiesSection(),
          const Divider(height: 1),
          Expanded(child: _feedSection()),
        ],
      ),
    );
  }

  // ---------------- STORIES ----------------
  Widget _storiesSection() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFfeda75),
                        Color(0xFFd62976),
                        Color(0xFF962fbf),
                        Color(0xFF4f5bd5),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const CircleAvatar(backgroundColor: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text('username', style: TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------- FEED ----------------
  Widget _feedSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadFeed, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_feed.isEmpty) {
      return const Center(child: Text('No posts yet'));
    }

    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: ListView.builder(
        itemCount: _feed.length,
        itemBuilder: (context, index) {
          final post = _feed[index];
          final media = post['media'] as List<dynamic>;
          final isLiked = post['is_liked'] as bool;
          final postId = post['post_id'] as int;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post header
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: post['profile_pic'] != null
                      ? NetworkImage(post['profile_pic'])
                      : null,
                  child: post['profile_pic'] == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                title: Text(
                  post['username'] ?? 'unknown',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.more_vert),
              ),

              // Post image with double tap to like
              GestureDetector(
                onDoubleTap: () => _toggleLike(index),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    media.isNotEmpty
                        ? media.length == 1
                        ? Image.network(
                      media[0]['media_url'],
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            height: 300,
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  size: 80, color: Colors.white),
                            ),
                          ),
                    )
                        : _slideableImages(media)
                        : Container(
                      height: 300,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.image,
                            size: 80, color: Colors.white),
                      ),
                    ),

                    // Heart animation overlay
                    ValueListenableBuilder<bool>(
                      valueListenable: _getHeartNotifier(index),
                      builder: (context, show, _) {
                        return AnimatedOpacity(
                          opacity: show ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 100,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Actions
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleLike(index),
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _openComments(postId),
                      child: const Icon(Icons.chat_bubble_outline),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.send_outlined),
                    const Spacer(),
                    const Icon(Icons.bookmark_border),
                  ],
                ),
              ),

              // Likes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${post['like_count']} likes',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              // Caption
              if (post['caption'] != null &&
                  post['caption'].toString().isNotEmpty)
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: '${post['username']} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: post['caption']),
                      ],
                    ),
                  ),
                ),

              // View all comments
              if (post['comment_count'] > 0)
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: GestureDetector(
                    onTap: () => _openComments(postId),
                    child: Text(
                      'View all ${post['comment_count']} comments',
                      style:
                      const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ),

              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }

  // ---------------- SLIDEABLE IMAGES ----------------
  Widget _slideableImages(List<dynamic> media) {
    final PageController controller = PageController();
    final ValueNotifier<int> currentPage = ValueNotifier(0);

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: media.length,
            onPageChanged: (index) => currentPage.value = index,
            itemBuilder: (context, index) {
              return Image.network(
                media[index]['media_url'],
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.broken_image,
                        size: 80, color: Colors.white),
                  ),
                ),
              );
            },
          ),

          // Dot indicators
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<int>(
              valueListenable: currentPage,
              builder: (context, page, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(media.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: page == index ? 8 : 6,
                      height: page == index ? 8 : 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: page == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                    );
                  }),
                );
              },
            ),
          ),

          // Image count badge
          Positioned(
            top: 8,
            right: 8,
            child: ValueListenableBuilder<int>(
              valueListenable: currentPage,
              builder: (context, page, _) {
                return Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${page + 1}/${media.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// COMMENTS BOTTOM SHEET
// ================================================================
class _CommentsSheet extends StatefulWidget {
  final int postId;
  const _CommentsSheet({required this.postId});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await CommentService.getPostComments(widget.postId);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await CommentService.addComment(widget.postId, text);
      _commentController.clear();
      _focusNode.unfocus();
      await _loadComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add comment')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteComment(int commentId) async {
    try {
      await CommentService.deleteComment(commentId);
      await _loadComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete comment')),
      );
    }
  }

  Future<void> _toggleCommentLike(int commentId, int index) async {
    final isLiked = _comments[index]['is_liked'] as bool? ?? false;
    final likes = _comments[index]['likes'] as int? ?? 0;

    setState(() {
      _comments[index]['is_liked'] = !isLiked;
      _comments[index]['likes'] = isLiked ? likes - 1 : likes + 1;
    });

    try {
      await CommentService.toggleCommentLike(commentId);
    } catch (e) {
      setState(() {
        _comments[index]['is_liked'] = isLiked;
        _comments[index]['likes'] = likes;
      });
    }
  }

  void _showDeleteDialog(int commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteComment(commentId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Comments',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

            const Divider(height: 1),

            // Comments list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.red)))
                  : _comments.isEmpty
                  ? const Center(
                child: Text(
                  'No comments yet.\nBe the first to comment!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                controller: scrollController,
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  final isLiked =
                      comment['is_liked'] as bool? ?? false;
                  final likes = comment['likes'] as int? ?? 0;

                  return GestureDetector(
                    onLongPress: () => _showDeleteDialog(
                        comment['id'] as int),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey,
                            backgroundImage:
                            comment['profile_pic'] != null
                                ? NetworkImage(
                                comment['profile_pic'])
                                : null,
                            child: comment['profile_pic'] == null
                                ? const Icon(Icons.person,
                                color: Colors.white,
                                size: 18)
                                : null,
                          ),
                          const SizedBox(width: 10),

                          // Comment content
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text:
                                        '${comment['username'] ?? 'unknown'} ',
                                        style: const TextStyle(
                                            fontWeight:
                                            FontWeight.bold),
                                      ),
                                      TextSpan(
                                          text: comment[
                                          'comment'] ??
                                              ''),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment['created_at'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                          // Like button
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () => _toggleCommentLike(
                                    comment['id'] as int, index),
                                child: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 16,
                                  color: isLiked
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                              ),
                              if (likes > 0)
                                Text(
                                  '$likes',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // Comment input - Instagram style
            Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isSubmitting
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child:
                    CircularProgressIndicator(strokeWidth: 2),
                  )
                      : TextButton(
                    onPressed: _submitComment,
                    child: const Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
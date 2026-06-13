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
  bool _commentsLoading = true;
  String? _error;

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isPostingComment = false;

  int? _replyingToId;
  String? _replyingToUsername;

  final Map<int, bool> _commentLikeStatus = {};
  final Map<int, int> _commentLikeCounts = {};
  final Set<int> _commentLikeLoading = {};

  // Tracks comments the user has manually liked/unliked so that
  // late-arriving results from _loadCommentLikes() don't overwrite
  // the optimistic UI state (this was causing the "like shows red
  // only after reopening" bug).
  final Set<int> _userToggledComments = {};

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _commentsLoading = true);
    try {
      final comments = await CommentService.getPostComments(widget.postId);
      if (mounted) {
        setState(() {
          _comments = comments;
          _error = null;
        });
        await _loadCommentLikes(comments);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _commentsLoading = false);
    }
  }

  Future<void> _loadCommentLikes(List<Map<String, dynamic>> comments) async {
    final futures = comments.map((comment) async {
      final id = comment['id'] as int;
      try {
        final result = await CommentService.getCommentLikes(id);
        // Skip if the user has already toggled this comment locally —
        // otherwise this late response can overwrite the optimistic
        // like state with stale server data.
        if (mounted && !_userToggledComments.contains(id)) {
          setState(() {
            _commentLikeStatus[id] = result['is_liked'] as bool;
            _commentLikeCounts[id] = result['likes'] as int;
          });
        }
      } catch (_) {
        if (mounted && !_userToggledComments.contains(id)) {
          setState(() {
            _commentLikeStatus[id] =
                (comment['is_liked'] == true) || (comment['is_liked'] == 1);
            _commentLikeCounts[id] = comment['like_count'] as int? ??
                (comment['likes'] as int? ?? 0);
          });
        }
      }
    });

    await Future.wait(futures);
  }

  Future<void> _handleCommentLike(int commentId) async {
    if (_commentLikeLoading.contains(commentId)) return;

    final wasLiked = _commentLikeStatus[commentId] ?? false;
    final previousCount = _commentLikeCounts[commentId] ?? 0;

    // Mark this comment as user-controlled so any in-flight or future
    // _loadCommentLikes responses don't override the optimistic state.
    _userToggledComments.add(commentId);

    setState(() {
      _commentLikeLoading.add(commentId);
      _commentLikeStatus[commentId] = !wasLiked;
      _commentLikeCounts[commentId] = previousCount + (wasLiked ? -1 : 1);
    });

    try {
      await CommentService.toggleCommentLike(commentId);
    } catch (_) {
      if (mounted) {
        setState(() {
          _commentLikeStatus[commentId] = wasLiked;
          _commentLikeCounts[commentId] = previousCount;
        });
        // Revert failed, allow future sync to correct state again.
        _userToggledComments.remove(commentId);
      }
    } finally {
      if (mounted) setState(() => _commentLikeLoading.remove(commentId));
    }
  }

  Future<void> _handleDeleteComment(int commentId) async {
    try {
      await CommentService.deleteComment(commentId);
      if (mounted) {
        setState(() {
          _comments.removeWhere(
                (c) => c['id'] == commentId || c['parent_id'] == commentId,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete comment: $e')),
        );
      }
    }
  }

  void _showCommentOptions(int commentId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete comment',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                _handleDeleteComment(commentId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: Colors.grey),
              title: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _handleReplyTap(int commentId, String username) {
    setState(() {
      _replyingToId = commentId;
      _replyingToUsername = username;
    });
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToId = null;
      _replyingToUsername = null;
    });
    _commentController.clear();
    _commentFocusNode.unfocus();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isPostingComment) return;

    setState(() => _isPostingComment = true);
    try {
      await CommentService.addComment(
        widget.postId,
        text,
        parentId: _replyingToId,
      );
      _commentController.clear();
      _commentFocusNode.unfocus();
      setState(() {
        _replyingToId = null;
        _replyingToUsername = null;
      });
      await _loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add comment')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPostingComment = false);
    }
  }

  List<Map<String, dynamic>> _buildCommentTree() {
    final topLevel = _comments.where((c) => c['parent_id'] == null).toList();
    final result = <Map<String, dynamic>>[];
    for (final comment in topLevel) {
      result.add({...comment, '_isReply': false});
      final replies =
      _comments.where((c) => c['parent_id'] == comment['id']).toList();
      for (final reply in replies) {
        result.add({...reply, '_isReply': true});
      }
    }
    return result;
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    final dateTime = DateTime.tryParse(timestamp);
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final isReply = comment['_isReply'] as bool;
    final commentId = comment['id'] as int;
    final isLiked = _commentLikeStatus[commentId] ?? false;
    final likeCount = _commentLikeCounts[commentId] ?? 0;
    final isLoading = _commentLikeLoading.contains(commentId);

    return Padding(
      key: ValueKey('comment_$commentId'),
      padding: EdgeInsets.only(
        left: isReply ? 52.0 : 16.0,
        right: 8,
        top: 8,
        bottom: 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 14 : 18,
            backgroundColor: Colors.grey,
            backgroundImage: comment['profile_pic'] != null
                ? NetworkImage(comment['profile_pic'])
                : null,
            child: comment['profile_pic'] == null
                ? Icon(Icons.person,
                size: isReply ? 12 : 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: '${comment['username'] ?? 'unknown'}  ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: comment['comment'] ?? ''),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatTimestamp(comment['created_at']),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _handleReplyTap(
                        commentId,
                        comment['username'] as String? ?? '',
                      ),
                      child: const Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _handleCommentLike(commentId),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  isLoading
                      ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: Colors.grey),
                  )
                      : Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 14,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  if (likeCount > 0)
                    Text(
                      '$likeCount',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showCommentOptions(commentId),
            child: const Padding(
              padding: EdgeInsets.only(left: 2, top: 2),
              child: Icon(Icons.more_vert, size: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final commentTree = _buildCommentTree();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Comments',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _commentsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.red)))
                  : commentTree.isEmpty
                  ? const Center(
                child: Text(
                  'No comments yet.\nBe the first to comment!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView(
                controller: scrollController,
                children: commentTree.map(_buildCommentItem).toList(),
              ),
            ),
            if (_replyingToUsername != null)
              Container(
                color: Colors.grey.shade100,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('Replying to ',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      '@$_replyingToUsername',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _cancelReply,
                      child:
                      const Icon(Icons.close, color: Colors.grey, size: 16),
                    ),
                  ],
                ),
              ),
            const Divider(height: 1),
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
                      focusNode: _commentFocusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                      decoration: InputDecoration(
                        hintText: _replyingToUsername != null
                            ? 'Reply to @$_replyingToUsername...'
                            : 'Add a comment...',
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
                  _isPostingComment
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : TextButton(
                    onPressed: _submitComment,
                    child: const Text(
                      'Post',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
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
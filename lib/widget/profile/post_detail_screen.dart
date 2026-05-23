import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../services/profile_service.dart';
import '../../services/like_service.dart';
import '../../services/comment_service.dart';
import '../../services/post_service.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<Map<String, dynamic>?> _postFuture;
  int _currentImageIndex = 0;

  bool _isLiked = false;
  int _likeCount = 0;
  bool _isLikeLoading = false;
  bool _likeInitialized = false;
  bool _showHeart = false;

  List<Map<String, dynamic>> _comments = [];
  bool _commentsLoading = false;

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isPostingComment = false;

  bool _isDeletingPost = false;

  int? _replyingToId;
  String? _replyingToUsername;

  final Map<int, bool> _commentLikeStatus = {};
  final Map<int, int> _commentLikeCounts = {};
  final Set<int> _commentLikeLoading = {};

  final Set<int> _deletedCommentIds = {};

  @override
  void initState() {
    super.initState();
    _postFuture = ProfileService.getMyPostById(widget.postId);
    _initLikeStatus();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initLikeStatus() async {
    try {
      final result = await LikeService.getPostLikes(widget.postId);
      if (mounted) {
        setState(() {
          _isLiked = result['isLiked'] as bool;
          _likeCount = result['totalLikes'] as int;
          _likeInitialized = true;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadComments() async {
    setState(() => _commentsLoading = true);
    try {
      final comments = await CommentService.getPostComments(widget.postId);
      if (mounted) {
        setState(() => _comments = comments);
        await _loadCommentLikes(comments);
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _commentsLoading = false);
    }
  }

  Future<void> _loadCommentLikes(List<Map<String, dynamic>> comments) async {
    final futures = comments.map((comment) async {
      final id = comment['id'] as int;
      try {
        final result = await CommentService.getCommentLikes(id);
        if (mounted) {
          setState(() {
            _commentLikeStatus[id] = result['is_liked'] as bool;
            _commentLikeCounts[id] = result['likes'] as int;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _commentLikeStatus[id] =
                (comment['is_liked'] == true) || (comment['is_liked'] == 1);
            _commentLikeCounts[id] = comment['like_count'] as int? ?? 0;
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

    setState(() {
      _commentLikeLoading.add(commentId);
      _commentLikeStatus[commentId] = !wasLiked;
      _commentLikeCounts[commentId] = previousCount + (wasLiked ? -1 : 1);
    });

    try {
      await CommentService.toggleCommentLike(commentId);
      final result = await CommentService.getCommentLikes(commentId);
      if (mounted) {
        setState(() {
          _commentLikeStatus[commentId] = result['is_liked'] as bool;
          _commentLikeCounts[commentId] = result['likes'] as int;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _commentLikeStatus[commentId] = wasLiked;
          _commentLikeCounts[commentId] = previousCount;
        });
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
          _deletedCommentIds.add(commentId);
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
      backgroundColor: Colors.grey.shade900,
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
                color: Colors.grey.shade600,
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
              leading:
              Icon(Icons.cancel_outlined, color: Colors.grey.shade400),
              title: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade400),
              ),
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

  Future<void> _handlePostComment() async {
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
      FocusScope.of(context).unfocus();
      setState(() {
        _replyingToId = null;
        _replyingToUsername = null;
      });
      await _loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post comment: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPostingComment = false);
    }
  }

  Future<void> _handleToggleLike() async {
    if (_isLikeLoading) return;
    setState(() => _isLikeLoading = true);
    try {
      await LikeService.toggleLike(widget.postId);
      final result = await LikeService.getPostLikes(widget.postId);
      if (mounted) {
        setState(() {
          _isLiked = result['isLiked'] as bool;
          _likeCount = result['totalLikes'] as int;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to like post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLikeLoading = false);
    }
  }

  Future<void> _handleDoubleTap() async {
    setState(() => _showHeart = true);
    await _handleToggleLike();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _showHeart = false);
  }

  void _showPostOptions(List<dynamic> media) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
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
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete Post',
                style:
                TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeletePost(media);
              },
            ),
            ListTile(
              leading:
              Icon(Icons.cancel_outlined, color: Colors.grey.shade400),
              title: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade400),
              ),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePost(List<dynamic> media) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Delete Post?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will permanently delete your post and all its media. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDeletePost(media);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeletePost(List<dynamic> media) async {
    setState(() => _isDeletingPost = true);
    try {
      final mediaIds = media.map((m) => m['id'] as int).toList();
      await PostService.deletePost(widget.postId, mediaIds);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeletingPost = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete post: $e')),
        );
      }
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

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final isReply = comment['_isReply'] as bool;
    final commentId = comment['id'] as int;
    final isLiked = _commentLikeStatus[commentId] ?? false;
    final likeCount = _commentLikeCounts[commentId] ?? 0;
    final isLoading = _commentLikeLoading.contains(commentId);

    return Padding(
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
            radius: isReply ? 12 : 16,
            backgroundColor: Colors.grey.shade800,
            backgroundImage: comment['profile_pic'] != null
                ? NetworkImage(comment['profile_pic'])
                : null,
            child: comment['profile_pic'] == null
                ? Icon(Icons.person,
                size: isReply ? 10 : 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${comment['username']}  ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: comment['comment'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatTimestamp(comment['created_at']),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _handleReplyTap(
                        commentId,
                        comment['username'] as String,
                      ),
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Like button
          GestureDetector(
            onTap: () => _handleCommentLike(commentId),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  isLoading
                      ? SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Colors.grey.shade600,
                    ),
                  )
                      : Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey.shade600,
                    size: 12,
                  ),
                  if (likeCount > 0)
                    Text(
                      '$likeCount',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Three-dot menu button
          GestureDetector(
            onTap: () => _showCommentOptions(commentId),
            child: Padding(
              padding: const EdgeInsets.only(left: 2, top: 2),
              child: Icon(
                Icons.more_vert,
                color: Colors.grey.shade600,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Post',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isDeletingPost
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Deleting post...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      )
          : FutureBuilder<Map<String, dynamic>?>(
        future: _postFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Post not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final post = snapshot.data!;
          final media = post['media'] as List<dynamic>;
          final commentTree = _buildCommentTree();

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey.shade800,
                              backgroundImage: post['profile_pic'] != null
                                  ? NetworkImage(post['profile_pic'])
                                  : null,
                              child: post['profile_pic'] == null
                                  ? const Icon(Icons.person,
                                  size: 16, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              post['username'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.white),
                              onPressed: () => _showPostOptions(media),
                            ),
                          ],
                        ),
                      ),
                      // Media carousel
                      if (media.isNotEmpty)
                        GestureDetector(
                          onDoubleTap: _handleDoubleTap,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CarouselSlider.builder(
                                itemCount: media.length,
                                options: CarouselOptions(
                                  height: 400,
                                  viewportFraction: 1.0,
                                  enableInfiniteScroll: false,
                                  onPageChanged: (index, reason) {
                                    setState(
                                            () => _currentImageIndex = index);
                                  },
                                ),
                                itemBuilder:
                                    (context, index, realIndex) {
                                  final mediaItem = media[index];
                                  return Container(
                                    width: double.infinity,
                                    color: Colors.black,
                                    child: Image.network(
                                      mediaItem['media_url'],
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          Container(
                                            color: Colors.grey.shade900,
                                            child: const Icon(
                                              Icons.broken_image,
                                              color: Colors.white,
                                              size: 50,
                                            ),
                                          ),
                                    ),
                                  );
                                },
                              ),
                              if (media.length > 1)
                                Positioned(
                                  bottom: 10,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: List.generate(
                                      media.length,
                                          (index) => Container(
                                        width: 6,
                                        height: 6,
                                        margin:
                                        const EdgeInsets.symmetric(
                                            horizontal: 3),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _currentImageIndex ==
                                              index
                                              ? Colors.white
                                              : Colors.white
                                              .withOpacity(0.4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (_showHeart)
                                AnimatedOpacity(
                                  opacity: _showHeart ? 1.0 : 0.0,
                                  duration:
                                  const Duration(milliseconds: 300),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 90,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      // Action row
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: _isLikeLoading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : Icon(
                                _isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isLiked
                                    ? Colors.red
                                    : Colors.white,
                              ),
                              onPressed: _isLikeLoading
                                  ? null
                                  : _handleToggleLike,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chat_bubble_outline,
                                  color: Colors.white),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.send_outlined,
                                  color: Colors.white),
                              onPressed: () {},
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                post['is_saved'] == true
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      // Like count
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _likeInitialized
                              ? '$_likeCount likes'
                              : '${post['like_count'] ?? 0} likes',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Caption
                      if (post['caption'] != null &&
                          post['caption'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${post['username']} ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: post['caption'],
                                  style: const TextStyle(
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Comments section
                      if (_commentsLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      else if (commentTree.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            'No comments yet. Be the first to comment!',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        )
                      else
                        ...commentTree.map(_buildCommentItem),
                      // Timestamp
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          _formatTimestamp(post['created_at']),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              // Replying to banner
              if (_replyingToUsername != null)
                Container(
                  color: Colors.grey.shade900,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Replying to ',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 12),
                      ),
                      Text(
                        '@$_replyingToUsername',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _cancelReply,
                        child: Icon(Icons.close,
                            color: Colors.grey.shade400, size: 16),
                      ),
                    ],
                  ),
                ),
              // Comment input bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border(
                    top: BorderSide(
                        color: Colors.grey.shade800, width: 0.5),
                  ),
                ),
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey.shade800,
                      child: const Icon(Icons.person,
                          size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        focusNode: _commentFocusNode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamilyFallback: [
                            'Apple Color Emoji',
                            'Noto Color Emoji'
                          ],
                        ),
                        cursorColor: Colors.white,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        maxLines: null,
                        enableSuggestions: true,
                        autocorrect: false,
                        decoration: InputDecoration(
                          hintText: _replyingToUsername != null
                              ? 'Reply to @$_replyingToUsername...'
                              : 'Add a comment...',
                          hintStyle: TextStyle(
                              color: Colors.grey.shade500, fontSize: 14),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    _isPostingComment
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blueAccent,
                      ),
                    )
                        : TextButton(
                      onPressed: _handlePostComment,
                      child: const Text(
                        'Post',
                        style: TextStyle(
                          color: Colors.blueAccent,
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
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
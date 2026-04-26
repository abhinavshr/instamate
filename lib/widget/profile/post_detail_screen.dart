import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../services/profile_service.dart';
import '../../services/like_service.dart';
import '../../services/comment_service.dart';

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

  @override
  void initState() {
    super.initState();
    _postFuture = ProfileService.getMyPostById(widget.postId);
    _initLikeStatus();
    _loadComments();
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
      }
    } catch (_) {}
    finally {
      if (mounted) setState(() => _commentsLoading = false);
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

  // Builds flat comment list: top-level + their replies indented
  List<Map<String, dynamic>> _buildCommentTree() {
    final topLevel = _comments.where((c) => c['parent_id'] == null).toList();
    final result = <Map<String, dynamic>>[];
    for (final comment in topLevel) {
      result.add({...comment, '_isReply': false});
      final replies = _comments
          .where((c) => c['parent_id'] == comment['id'])
          .toList();
      for (final reply in replies) {
        result.add({...reply, '_isReply': true});
      }
    }
    return result;
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final isReply = comment['_isReply'] as bool;

    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 52.0 : 16.0,
        right: 16,
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
                      onTap: () {},
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
          GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.favorite_border,
              color: Colors.grey.shade600,
              size: 12,
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
      body: FutureBuilder<Map<String, dynamic>?>(
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
                      // ── Header ──────────────────────────────────────────
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
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),

                      // ── Media ────────────────────────────────────────────
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
                                    setState(() => _currentImageIndex = index);
                                  },
                                ),
                                itemBuilder: (context, index, realIndex) {
                                  final mediaItem = media[index];
                                  return Container(
                                    width: double.infinity,
                                    color: Colors.black,
                                    child: Image.network(
                                      mediaItem['media_url'],
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Container(
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      media.length,
                                          (index) => Container(
                                        width: 6,
                                        height: 6,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 3),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _currentImageIndex == index
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (_showHeart)
                                AnimatedOpacity(
                                  opacity: _showHeart ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 90,
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // ── Action Buttons ───────────────────────────────────
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
                                color:
                                _isLiked ? Colors.red : Colors.white,
                              ),
                              onPressed:
                              _isLikeLoading ? null : _handleToggleLike,
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

                      // ── Like Count ───────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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

                      // ── Caption ──────────────────────────────────────────
                      if (post['caption'] != null &&
                          post['caption'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  style:
                                  const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      // ── Comments ─────────────────────────────────────────
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

                      // ── Timestamp ────────────────────────────────────────
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

              // ── Add Comment Bar ─────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade800, width: 0.5),
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
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle:
                          TextStyle(color: Colors.grey.shade500),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
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
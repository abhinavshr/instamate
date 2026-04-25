import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../services/profile_service.dart';
import '../../services/like_service.dart';

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

  @override
  void initState() {
    super.initState();
    _postFuture = ProfileService.getMyPostById(widget.postId);
    _initLikeStatus();
  }

  Future<void> _initLikeStatus() async {
    try {
      final isLiked = await LikeService.isPostLiked(widget.postId);
      if (mounted) {
        setState(() {
          _isLiked = isLiked;
          _likeInitialized = true;
        });
      }
    } catch (_) {}
  }

  Future<void> _handleToggleLike() async {
    if (_isLikeLoading) return;
    setState(() => _isLikeLoading = true);
    try {
      await LikeService.toggleLike(widget.postId);
      final isLiked = await LikeService.isPostLiked(widget.postId);
      setState(() {
        _isLiked = isLiked;
        _likeCount = isLiked ? _likeCount + 1 : _likeCount - 1;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to like post: $e')),
        );
      }
    } finally {
      setState(() => _isLikeLoading = false);
    }
  }

  Future<void> _handleDoubleTap() async {
    setState(() => _showHeart = true);
    await _handleToggleLike();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _showHeart = false);
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

          if (_likeCount == 0 && !_likeInitialized) {
            _likeCount = post['like_count'] ?? 0;
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

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
                              setState(() {
                                _currentImageIndex = index;
                              });
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

                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          color: _isLiked ? Colors.red : Colors.white,
                        ),
                        onPressed: _isLikeLoading ? null : _handleToggleLike,
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '$_likeCount likes',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

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
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 4),

                if (post['comment_count'] > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'View all ${post['comment_count']} comments',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
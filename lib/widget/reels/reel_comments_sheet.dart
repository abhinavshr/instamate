import 'package:flutter/material.dart';
import 'package:instamate/services/reel_service.dart';

// ─── Data Model ──────────────────────────────────────────────────────────────

class CommentData {
  final int id;
  final String comment;
  final int? parentId;
  final String createdAt;
  final int userId;
  final String username;
  final String? profilePic;
  final int likeCount;
  final bool isLiked;
  final List<CommentData> replies;

  const CommentData({
    required this.id,
    required this.comment,
    this.parentId,
    required this.createdAt,
    required this.userId,
    required this.username,
    this.profilePic,
    required this.likeCount,
    required this.isLiked,
    required this.replies,
  });

  factory CommentData.fromJson(Map<String, dynamic> json) {
    final rawReplies = json['replies'] as List<dynamic>? ?? [];
    return CommentData(
      id: json['id'] as int,
      comment: json['comment'] as String,
      parentId: json['parent_id'] as int?,
      createdAt: json['created_at'] as String,
      userId: json['user_id'] as int,
      username: json['username'] as String,
      profilePic: json['profile_pic'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      replies: rawReplies
          .map((r) => CommentData.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  String get avatarInitial =>
      username.isNotEmpty ? username[0].toUpperCase() : '?';

  Color get accentColor {
    const colors = [
      Color(0xFF9B59B6),
      Color(0xFF2196F3),
      Color(0xFFFF6B35),
      Color(0xFF4CAF50),
      Color(0xFFE91E99),
      Color(0xFFFFB300),
      Color(0xFF00BCD4),
    ];
    return colors[userId % colors.length];
  }

  String get relativeTime {
    final dt = DateTime.tryParse(createdAt);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
    return '${(diff.inDays / 365).floor()}y';
  }
}

// ─── Entry point ─────────────────────────────────────────────────────────────

void showCommentsSheet(BuildContext context, int reelId, int commentCount) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) =>
        _CommentsSheet(reelId: reelId, commentCount: commentCount),
  );
}

// ─── Sheet ───────────────────────────────────────────────────────────────────

class _CommentsSheet extends StatefulWidget {
  final int reelId;
  final int commentCount;

  const _CommentsSheet({required this.reelId, required this.commentCount});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _inputCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();

  List<CommentData> _comments = [];
  bool _loading = true;
  String? _error;
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _focusNode.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await ReelService.getReelComments(widget.reelId.toString());
      if (mounted) {
        setState(() {
          _comments = raw.map(CommentData.fromJson).toList();
          _loading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Comments error: $e');        // <-- add this
      debugPrint('❌ Stack: $stackTrace');         // <-- and this
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenH = MediaQuery.of(context).size.height;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: screenH * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(),
            const Divider(color: Color(0xFF2C2C2C), height: 1),
            Expanded(child: _buildBody()),
            const Divider(color: Color(0xFF2C2C2C), height: 1),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${widget.commentCount} comments',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: Colors.white60, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white38, strokeWidth: 2),
      );
    }

    if (_error != null) {
      // Determine error type for accurate messaging
      final isNetworkError = _error!.toLowerCase().contains('socket') ||
          _error!.toLowerCase().contains('connection') ||
          _error!.toLowerCase().contains('network') ||
          _error!.toLowerCase().contains('host') ||
          _error!.toLowerCase().contains('timeout');

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNetworkError ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                color: Colors.white38,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isNetworkError ? 'No Internet Connection' : 'Something Went Wrong',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isNetworkError
                  ? "Couldn't load comments.\nCheck your connection and try again."
                  : "Couldn't load comments.\nTap below to try again.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _fetchComments,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFF3897F0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Try Again',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_comments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                color: Colors.white24, size: 48),
            SizedBox(height: 12),
            Text(
              'No comments yet',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Start the conversation',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _comments.length,
      itemBuilder: (_, i) => _CommentTile(comment: _comments[i]),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white12,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: const Icon(Icons.person,
                  color: Colors.white38, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: _inputCtrl,
                  focusNode: _focusNode,
                  style:
                  const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: null,
                  cursorColor: Colors.white,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitComment(),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                    hintText: 'Add a comment…',
                    hintStyle:
                    TextStyle(color: Colors.white38, fontSize: 14),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _inputCtrl,
              builder: (_, val, __) {
                final hasText = val.text.trim().isNotEmpty;
                if (_posting) {
                  return const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Color(0xFF3897F0),
                      strokeWidth: 2,
                    ),
                  );
                }
                return GestureDetector(
                  onTap: hasText ? _submitComment : null,
                  child: AnimatedOpacity(
                    opacity: hasText ? 1.0 : 0.35,
                    duration: const Duration(milliseconds: 150),
                    child: const Text(
                      'Post',
                      style: TextStyle(
                        color: Color(0xFF3897F0),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComment() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _posting) return;

    _inputCtrl.clear();
    _focusNode.unfocus();

    setState(() => _posting = true);

    try {
      final result =
      await ReelService.postReelComment(widget.reelId.toString(), text);

      // Try to parse the new comment from the response, fall back to refetch
      final newCommentJson = result['comment'] as Map<String, dynamic>?;

      if (mounted) {
        setState(() {
          if (newCommentJson != null) {
            _comments.insert(0, CommentData.fromJson(newCommentJson));
          }
          _posting = false;
        });

        // If the API didn't return the created comment, just refresh the list
        if (newCommentJson == null) {
          _fetchComments();
        } else {
          // Scroll to top so the new comment is visible
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.animateTo(
              0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Post comment error: $e');
      if (mounted) {
        setState(() => _posting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to post comment. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

// ─── Comment Tile ─────────────────────────────────────────────────────────────

class _CommentTile extends StatefulWidget {
  final CommentData comment;
  final bool isReply;

  const _CommentTile({required this.comment, this.isReply = false});

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  late bool _liked;
  late int _likeCount;
  bool _showReplies = false;

  @override
  void initState() {
    super.initState();
    _liked = widget.comment.isLiked;
    _likeCount = widget.comment.likeCount;
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.comment;

    return Padding(
      padding: EdgeInsets.fromLTRB(widget.isReply ? 56 : 16, 6, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommentAvatar(comment: c),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      c.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      c.relativeTime,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  c.comment,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Reply',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (c.replies.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showReplies = !_showReplies),
                    child: Row(
                      children: [
                        Container(
                            width: 24,
                            height: 1,
                            color: Colors.white38),
                        const SizedBox(width: 8),
                        Text(
                          _showReplies
                              ? 'Hide replies'
                              : 'View ${c.replies.length} ${c.replies.length == 1 ? 'reply' : 'replies'}',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_showReplies)
                    Column(
                      children: c.replies
                          .map((r) =>
                          _CommentTile(comment: r, isReply: true))
                          .toList(),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _toggleLike,
            child: Column(
              children: [
                Icon(
                  _liked ? Icons.favorite : Icons.favorite_border,
                  color: _liked
                      ? const Color(0xFFFF3040)
                      : Colors.white54,
                  size: 16,
                ),
                if (_likeCount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$_likeCount',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Comment Avatar ───────────────────────────────────────────────────────────

class _CommentAvatar extends StatelessWidget {
  final CommentData comment;
  const _CommentAvatar({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            comment.accentColor,
            comment.accentColor.withOpacity(0.4),
          ],
        ),
      ),
      child: ClipOval(
        child: comment.profilePic != null
            ? Image.network(
          comment.profilePic!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _Initial(comment: comment),
        )
            : _Initial(comment: comment),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  final CommentData comment;
  const _Initial({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        comment.avatarInitial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
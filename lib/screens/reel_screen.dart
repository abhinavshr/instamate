import 'package:flutter/material.dart';
import 'package:instamate/widget/reels/reel_comments_sheet.dart';
import 'package:video_player/video_player.dart';
import '../services/reel_service.dart';
import '../services/auth_service.dart';

class ReelData {
  final int id;
  final String caption;
  final String videoUrl;
  final String createdAt;
  final int userId;
  final String username;
  final String? profilePic;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final int shareCount;

  const ReelData({
    required this.id,
    required this.caption,
    required this.videoUrl,
    required this.createdAt,
    required this.userId,
    required this.username,
    this.profilePic,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    this.shareCount = 0,
  });

  factory ReelData.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return ReelData(
      id: json['id'] as int,
      caption: json['caption'] as String? ?? '',
      videoUrl: json['video_url'] as String,
      createdAt: json['created_at'] as String,
      userId: user['id'] as int,
      username: user['username'] as String,
      profilePic: user['profile_pic'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      shareCount: json['share_count'] as int? ?? 0,
    );
  }

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

  String get avatarInitial =>
      username.isNotEmpty ? username[0].toUpperCase() : '?';
}

class ReelFeedPage extends StatefulWidget {
  const ReelFeedPage({super.key});

  @override
  State<ReelFeedPage> createState() => _ReelFeedPageState();
}

class _ReelFeedPageState extends State<ReelFeedPage> {
  final PageController _pageController = PageController();
  int _reelIndex = 0;

  List<ReelData> _reels = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchReels();
  }

  Future<void> _fetchReels() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await ReelService.getReels();
      setState(() {
        _reels = raw
            .map((e) => ReelData.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onReelDeleted(int reelId) {
    setState(() {
      _reels.removeWhere((r) => r.id == reelId);
      if (_reelIndex >= _reels.length && _reels.isNotEmpty) {
        _reelIndex = _reels.length - 1;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_loading)
            const Center(
                child: CircularProgressIndicator(color: Colors.white))
          else if (_error != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white54, size: 48),
                  const SizedBox(height: 12),
                  const Text('Could not load reels',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _fetchReels,
                    child: const Text('Try again',
                        style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            )
          else if (_reels.isEmpty)
              const Center(
                child: Text('No reels yet',
                    style: TextStyle(color: Colors.white54, fontSize: 16)),
              )
            else
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: _reels.length,
                onPageChanged: (i) => setState(() => _reelIndex = i),
                itemBuilder: (context, index) {
                  return ReelCard(
                    key: ValueKey(_reels[index].id),
                    reel: _reels[index],
                    isActive: index == _reelIndex,
                    onDeleted: _onReelDeleted,
                  );
                },
              ),
          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reels',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        color: Colors.white, size: 26),
                  ),
                ],
              ),
            ),
          ),
          if (_reels.isNotEmpty)
            Positioned(
              right: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_reels.length, (i) {
                    final active = i == _reelIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      width: 4,
                      height: active ? 20 : 6,
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.white38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ReelCard extends StatefulWidget {
  final ReelData reel;
  final bool isActive;
  final void Function(int reelId)? onDeleted;

  const ReelCard({
    super.key,
    required this.reel,
    required this.isActive,
    this.onDeleted,
  });

  @override
  State<ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<ReelCard>
    with SingleTickerProviderStateMixin {
  bool _liked = false;
  int _likeCount = 0;
  bool _saved = false;
  bool _showHeart = false;
  bool _isPaused = false;
  bool _likeLoading = false;
  bool _viewRecorded = false;

  bool _likeStatusLoading = false;
  bool _likeStatusError = false;

  bool _shareLoading = false;
  int _shareCount = 0;

  int? _currentUserId;
  int? _viewCount;
  bool _viewCountLoading = false;

  late AnimationController _heartCtrl;
  late Animation<double> _heartAnim;

  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    _liked = widget.reel.isLiked;
    _likeCount = widget.reel.likeCount;
    _shareCount = widget.reel.shareCount;

    _initVideo();
    _initHeartAnim();

    _fetchLikeStatus();

    if (widget.isActive) {
      _recordView();
    }

    _loadCurrentUserAndViewCount();
  }

  Future<void> _loadCurrentUserAndViewCount() async {
    final user = await AuthService.getUser();
    if (!mounted || user == null) return;

    final userId = user['id'] as int?;
    setState(() => _currentUserId = userId);

    if (userId != null && userId == widget.reel.userId) {
      _fetchViewCount();
    }
  }

  Future<void> _fetchViewCount() async {
    setState(() => _viewCountLoading = true);
    try {
      final count =
      await ReelService.getReelViewCount(widget.reel.id.toString());
      if (mounted) {
        setState(() {
          _viewCount = count;
          _viewCountLoading = false;
        });
      }
    } catch (e) {
      debugPrint('getReelViewCount error for reel ${widget.reel.id}: $e');
      if (mounted) setState(() => _viewCountLoading = false);
    }
  }

  void _recordView() {
    if (_viewRecorded) return;
    _viewRecorded = true;
    ReelService.addReelView(widget.reel.id.toString());
  }

  Future<void> _fetchLikeStatus() async {
    setState(() {
      _likeStatusLoading = true;
      _likeStatusError = false;
    });

    try {
      final status =
      await ReelService.getReelLikeStatus(widget.reel.id.toString());

      if (mounted) {
        setState(() {
          _liked = status['is_liked'] as bool;
          _likeCount = status['like_count'] as int;
          _likeStatusLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _likeStatusLoading = false;
          _likeStatusError = true;
        });
        debugPrint('getReelLikeStatus error for reel ${widget.reel.id}: $e');
      }
    }
  }

  void _initHeartAnim() {
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartAnim = Sequence([
      Tween<double>(begin: 0, end: 1.3).animate(
        CurvedAnimation(
            parent: _heartCtrl,
            curve: const Interval(0, 0.4, curve: Curves.easeOut)),
      ),
      Tween<double>(begin: 1.3, end: 0).animate(
        CurvedAnimation(
            parent: _heartCtrl,
            curve: const Interval(0.6, 1, curve: Curves.easeIn)),
      ),
    ]);
    _heartCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _showHeart = false);
      }
    });
  }

  String _playableUrl(String url) {
    if (url.toLowerCase().endsWith('.mov')) {
      return '${url.substring(0, url.length - 4)}.mp4';
    }
    return url;
  }

  Future<void> _initVideo() async {
    final ctrl = VideoPlayerController.networkUrl(
      Uri.parse(_playableUrl(widget.reel.videoUrl)),
    );
    _videoCtrl = ctrl;
    try {
      await ctrl.initialize().timeout(const Duration(seconds: 15));
      ctrl.setLooping(true);
      if (mounted) {
        setState(() => _videoReady = true);
        if (widget.isActive) ctrl.play();
      }
    } catch (e) {
      debugPrint('Video init error for ${widget.reel.videoUrl}: $e');
      if (mounted) setState(() => _videoError = true);
    }
  }

  @override
  void didUpdateWidget(ReelCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _recordView();
    }

    if (!mounted || _videoCtrl == null || !_videoReady) return;

    if (widget.isActive && !_isPaused) {
      _videoCtrl!.play();
    } else {
      _videoCtrl!.pause();
    }
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    if (_likeLoading || _likeStatusLoading) return;

    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
      _likeLoading = true;
    });

    try {
      await ReelService.toggleReelLike(widget.reel.id.toString());
    } catch (e) {
      if (mounted) {
        setState(() {
          _liked = !_liked;
          _likeCount += _liked ? 1 : -1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update like. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _likeLoading = false);
    }
  }

  Future<void> _shareReel() async {
    if (_shareLoading) return;

    setState(() => _shareLoading = true);

    try {
      await ReelService.shareReel(widget.reel.id.toString());
      if (mounted) {
        setState(() => _shareCount += 1);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reel shared successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('already shared')
            ? 'You have already shared this reel'
            : 'Failed to share reel. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _shareLoading = false);
    }
  }

  void _onDoubleTap() {
    if (!_liked) _toggleLike();
    setState(() => _showHeart = true);
    _heartCtrl.forward(from: 0);
  }

  void _onTap() {
    if (_videoCtrl == null || !_videoReady) return;
    setState(() => _isPaused = !_isPaused);
    _isPaused ? _videoCtrl!.pause() : _videoCtrl!.play();
  }

  String _fmtNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  Widget _buildLikeButton() {
    if (_likeStatusLoading) {
      return const Column(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              color: Colors.white54,
              strokeWidth: 2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '...',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return _ActionButton(
      icon: _liked ? Icons.favorite : Icons.favorite_border,
      color: _liked ? const Color(0xFFFF3040) : Colors.white,
      label: _fmtNum(_likeCount),
      onTap: _toggleLike,
      loading: _likeLoading,
    );
  }

  Future<void> _confirmAndDeleteReel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('Delete reel?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFFF3040))),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ReelService.deleteReel(widget.reel.id.toString());
      if (mounted) {
        widget.onDeleted?.call(widget.reel.id);
      }
    } catch (e) {
      debugPrint('Delete reel error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete reel. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showReelOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
              const Icon(Icons.delete_outline, color: Color(0xFFFF3040)),
              title: const Text('Delete reel',
                  style: TextStyle(color: Color(0xFFFF3040))),
              onTap: () {
                Navigator.pop(ctx);
                _confirmAndDeleteReel();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.white54),
              title: const Text('Cancel',
                  style: TextStyle(color: Colors.white54)),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reel = widget.reel;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: _onTap,
      onDoubleTap: _onDoubleTap,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _videoReady && _videoCtrl != null
                ? Positioned.fill(
              child: FittedBox(
                fit: _videoCtrl!.value.aspectRatio > 1
                    ? BoxFit.contain
                    : BoxFit.cover,
                child: SizedBox(
                  width: _videoCtrl!.value.size.width,
                  height: _videoCtrl!.value.size.height,
                  child: VideoPlayer(_videoCtrl!),
                ),
              ),
            )
                : _videoError
                ? Positioned.fill(
                child: _VideoErrorBackground(reel: reel))
                : Positioned.fill(
                child: _FallbackBackground(reel: reel)),
            if (_isPaused)
              const Center(
                child: Icon(Icons.pause_circle_filled,
                    color: Colors.white54, size: 72),
              ),
            if (_showHeart)
              Center(
                child: AnimatedBuilder(
                  animation: _heartAnim,
                  builder: (_, __) => Transform.scale(
                    scale: _heartAnim.value,
                    child: const Icon(Icons.favorite,
                        color: Colors.white, size: 100),
                  ),
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 0.75, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.88),
                    ],
                  ),
                ),
              ),
            ),
            if (_currentUserId != null && _currentUserId == reel.userId)
              Positioned(
                top: 56,
                right: 8,
                child: SafeArea(
                  bottom: false,
                  child: GestureDetector(
                    onTap: () => _showReelOptionsMenu(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.more_vert,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 10,
              bottom: 50,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: (_likeLoading || _likeStatusLoading)
                        ? null
                        : _toggleLike,
                    child: _buildLikeButton(),
                  ),
                  const SizedBox(height: 20),
                  _ActionButton(
                    icon: Icons.mode_comment_outlined,
                    label: _fmtNum(reel.commentCount),
                    onTap: () => showCommentsSheet(context, reel.id, reel.commentCount),
                  ),
                  const SizedBox(height: 20),
                  _ActionButton(
                    icon: Icons.send_outlined,
                    label: _fmtNum(_shareCount),
                    onTap: _shareReel,
                    loading: _shareLoading,
                  ),
                  const SizedBox(height: 20),
                  _ActionButton(
                    icon: _saved ? Icons.bookmark : Icons.bookmark_border,
                    color: _saved ? reel.accentColor : Colors.white,
                    label: '',
                    onTap: () => setState(() => _saved = !_saved),
                  ),
                  const SizedBox(height: 20),
                  _SpinningDisc(
                      color: reel.accentColor, initial: reel.avatarInitial),
                ],
              ),
            ),
            Positioned(
              left: 14,
              right: 70,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _Avatar(reel: reel),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          reel.username,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _FollowChip(accentColor: reel.accentColor),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (reel.caption.isNotEmpty)
                    Text(
                      reel.caption,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13.5, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 10),
                  _AudioTicker(audioName: "${reel.username}'s audio"),
                  if (_currentUserId != null &&
                      _currentUserId == reel.userId) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.visibility_outlined,
                            color: Colors.white54, size: 14),
                        const SizedBox(width: 4),
                        if (_viewCountLoading)
                          const Text(
                            '...',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 12),
                          )
                        else
                          Text(
                            '${_viewCount ?? 0} views',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackBackground extends StatelessWidget {
  final ReelData reel;
  const _FallbackBackground({required this.reel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 1.2,
          colors: [
            reel.accentColor.withOpacity(0.6),
            reel.accentColor.withOpacity(0.15),
            Colors.black,
          ],
        ),
      ),
      child: const Center(
        child:
        CircularProgressIndicator(color: Colors.white38, strokeWidth: 2),
      ),
    );
  }
}

class _VideoErrorBackground extends StatelessWidget {
  final ReelData reel;
  const _VideoErrorBackground({required this.reel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 1.2,
          colors: [
            reel.accentColor.withOpacity(0.6),
            reel.accentColor.withOpacity(0.15),
            Colors.black,
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.white54, size: 48),
            SizedBox(height: 8),
            Text('Video unavailable',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final ReelData reel;
  const _Avatar({required this.reel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [reel.accentColor, reel.accentColor.withOpacity(0.4)],
        ),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: ClipOval(
        child: reel.profilePic != null
            ? Image.network(
          reel.profilePic!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _InitialFallback(reel: reel),
        )
            : _InitialFallback(reel: reel),
      ),
    );
  }
}

class _InitialFallback extends StatelessWidget {
  final ReelData reel;
  const _InitialFallback({required this.reel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        reel.avatarInitial,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool loading;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color = Colors.white,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          loading
              ? const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2),
          )
              : Icon(icon, color: color, size: 30),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}

class _SpinningDisc extends StatefulWidget {
  final Color color;
  final String initial;
  const _SpinningDisc({required this.color, required this.initial});

  @override
  State<_SpinningDisc> createState() => _SpinningDiscState();
}

class _SpinningDiscState extends State<_SpinningDisc>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
    AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white,
              widget.color.withOpacity(0.7),
              Colors.black87,
            ],
            stops: const [0.15, 0.45, 1.0],
          ),
          border: Border.all(color: Colors.white24, width: 2),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: Colors.black),
          alignment: Alignment.center,
          child: Text(widget.initial,
              style: const TextStyle(fontSize: 6, color: Colors.white)),
        ),
      ),
    );
  }
}

class _FollowChip extends StatefulWidget {
  final Color accentColor;
  const _FollowChip({required this.accentColor});

  @override
  State<_FollowChip> createState() => _FollowChipState();
}

class _FollowChipState extends State<_FollowChip> {
  bool _following = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _following = !_following),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: _following ? Colors.transparent : Colors.white,
          border: Border.all(
            color: _following ? Colors.white54 : Colors.white,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          _following ? 'Following' : 'Follow',
          style: TextStyle(
            color: _following ? Colors.white70 : Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _AudioTicker extends StatefulWidget {
  final String audioName;
  const _AudioTicker({required this.audioName});

  @override
  State<_AudioTicker> createState() => _AudioTickerState();
}

class _AudioTickerState extends State<_AudioTicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl =
    AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
    _anim = Tween<double>(begin: 0, end: 1).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = '♪  ${widget.audioName}   •   ${widget.audioName}   •   ';
    return ClipRect(
      child: SizedBox(
        height: 20,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => FractionalTranslation(
            translation: Offset(-_anim.value, 0),
            child: Text(text + text,
                maxLines: 1,
                style:
                const TextStyle(color: Colors.white70, fontSize: 12.5)),
          ),
        ),
      ),
    );
  }
}

class Sequence<T> extends Animation<T> with AnimationWithParentMixin<T> {
  final List<Animation<T>> _children;
  Sequence(this._children);

  @override
  Animation<T> get parent => _children[0];

  @override
  T get value {
    for (final child in _children) {
      if (child.value != _children.last.value) return child.value;
    }
    return _children.last.value;
  }
}
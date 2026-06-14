import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const ReelApp());
}

class ReelApp extends StatelessWidget {
  const ReelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ReelFeedPage(),
    );
  }
}

// ─── Data Model ─────────────────────────────────────────────────────────────

class ReelData {
  final String id;
  final Color bgColor;       // placeholder for video background
  final Color accentColor;
  final String username;
  final String handle;
  final String avatarInitial;
  final String caption;
  final String audioName;
  final int likes;
  final int comments;
  final int shares;
  final List<String> tags;

  const ReelData({
    required this.id,
    required this.bgColor,
    required this.accentColor,
    required this.username,
    required this.handle,
    required this.avatarInitial,
    required this.caption,
    required this.audioName,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.tags,
  });
}

final List<ReelData> _reels = [
  ReelData(
    id: '1',
    bgColor: const Color(0xFF1A1033),
    accentColor: const Color(0xFF9B59B6),
    username: 'aurora.visuals',
    handle: '@aurora.visuals',
    avatarInitial: 'A',
    caption: 'Northern lights are nature\'s best show ✨ Captured this in Iceland last winter 🌌',
    audioName: 'Midnight Dreams – Alina Baraz',
    likes: 142300,
    comments: 2841,
    shares: 9120,
    tags: ['#aurora', '#iceland', '#northernlights', '#nature'],
  ),
  ReelData(
    id: '2',
    bgColor: const Color(0xFF0D2137),
    accentColor: const Color(0xFF2196F3),
    username: 'ocean.depths',
    handle: '@ocean.depths',
    avatarInitial: 'O',
    caption: 'The deep blue has secrets you\'ve never imagined 🌊 Free diving at 30m',
    audioName: 'Blue World – Hans Zimmer',
    likes: 88900,
    comments: 1203,
    shares: 4700,
    tags: ['#ocean', '#freediving', '#underwater', '#blue'],
  ),
  ReelData(
    id: '3',
    bgColor: const Color(0xFF1C0A00),
    accentColor: const Color(0xFFFF6B35),
    username: 'wildfire.studio',
    handle: '@wildfire.studio',
    avatarInitial: 'W',
    caption: 'Slow-motion fire is pure art 🔥 Shot at 1000fps for maximum drama',
    audioName: 'Fire – Barns Courtney',
    likes: 312000,
    comments: 5678,
    shares: 22000,
    tags: ['#fire', '#slowmo', '#cinematic', '#art'],
  ),
  ReelData(
    id: '4',
    bgColor: const Color(0xFF0A1F0A),
    accentColor: const Color(0xFF4CAF50),
    username: 'forest.whisper',
    handle: '@forest.whisper',
    avatarInitial: 'F',
    caption: 'A misty morning in the Amazon 🌿 Where every breath feels like magic',
    audioName: 'Into the Wild – LP',
    likes: 67400,
    comments: 890,
    shares: 3300,
    tags: ['#amazon', '#forest', '#nature', '#mist'],
  ),
  ReelData(
    id: '5',
    bgColor: const Color(0xFF1A0A1A),
    accentColor: const Color(0xFFE91E99),
    username: 'neon.city',
    handle: '@neon.city',
    avatarInitial: 'N',
    caption: 'Tokyo at 3AM hits different 🌃 The city never really sleeps',
    audioName: 'Synthwave Dreams – Kavinsky',
    likes: 204500,
    comments: 3412,
    shares: 15600,
    tags: ['#tokyo', '#neon', '#nightlife', '#japan'],
  ),
];

// ─── Feed Page ───────────────────────────────────────────────────────────────

class ReelFeedPage extends StatefulWidget {
  const ReelFeedPage({super.key});

  @override
  State<ReelFeedPage> createState() => _ReelFeedPageState();
}

class _ReelFeedPageState extends State<ReelFeedPage> {
  final PageController _pageController = PageController();
  int _reelIndex = 0;
  int _navIndex = 1; // index 1 = Reels tab in CustomBottomNavBar

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
          // ── Reel PageView ──
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _reels.length,
            onPageChanged: (i) => setState(() => _reelIndex = i),
            itemBuilder: (context, index) {
              return ReelCard(reel: _reels[index]);
            },
          ),

          // ── Top bar ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Scroll indicator dots ──
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

          // ── Bottom nav (CustomBottomNavBar) ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Theme(
              // Force dark theme so onBackground is white over the video
              data: ThemeData.dark().copyWith(
                scaffoldBackgroundColor: Colors.transparent,
                dividerColor: Colors.white,
              ),
              child: CustomBottomNavBar(
                currentIndex: _navIndex,
                onTap: (i) => setState(() => _navIndex = i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single Reel Card ────────────────────────────────────────────────────────

class ReelCard extends StatefulWidget {
  final ReelData reel;
  const ReelCard({super.key, required this.reel});

  @override
  State<ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<ReelCard>
    with SingleTickerProviderStateMixin {
  bool _liked = false;
  bool _saved = false;
  bool _showHeart = false;
  late AnimationController _heartCtrl;
  late Animation<double> _heartAnim;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartAnim = Sequence([
      Tween<double>(begin: 0, end: 1.3).animate(
        CurvedAnimation(parent: _heartCtrl, curve: const Interval(0, 0.4, curve: Curves.easeOut)),
      ),
      Tween<double>(begin: 1.3, end: 0).animate(
        CurvedAnimation(parent: _heartCtrl, curve: const Interval(0.6, 1, curve: Curves.easeIn)),
      ),
    ]);
    _heartCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _showHeart = false);
      }
    });
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    setState(() {
      _liked = true;
      _showHeart = true;
    });
    _heartCtrl.forward(from: 0);
  }

  String _fmtNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final reel = widget.reel;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Video placeholder (gradient) ──
            _VideoPlaceholder(reel: reel),

            // ── Double-tap heart burst ──
            if (_showHeart)
              Center(
                child: AnimatedBuilder(
                  animation: _heartAnim,
                  builder: (_, __) => Transform.scale(
                    scale: _heartAnim.value,
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),
              ),

            // ── Bottom overlay gradient ──
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

            // ── Right-side action buttons ──
            Positioned(
              right: 10,
              bottom: 100,
              child: Column(
                children: [
                  _ActionButton(
                    icon: _liked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _liked ? const Color(0xFFFF3040) : Colors.white,
                    label: _fmtNum(reel.likes + (_liked ? 1 : 0)),
                    onTap: () => setState(() => _liked = !_liked),
                  ),
                  const SizedBox(height: 20),
                  _ActionButton(
                    icon: Icons.mode_comment_outlined,
                    label: _fmtNum(reel.comments),
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  _ActionButton(
                    icon: Icons.send_outlined,
                    label: _fmtNum(reel.shares),
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  _ActionButton(
                    icon: _saved
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: _saved ? reel.accentColor : Colors.white,
                    label: '',
                    onTap: () => setState(() => _saved = !_saved),
                  ),
                  const SizedBox(height: 20),
                  // Rotating vinyl disc
                  _SpinningDisc(color: reel.accentColor, initial: reel.avatarInitial),
                ],
              ),
            ),

            // ── Bottom-left metadata ──
            Positioned(
              left: 14,
              right: 70,
              bottom: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User row
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [reel.accentColor, reel.accentColor.withOpacity(0.4)],
                          ),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          reel.avatarInitial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        reel.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _FollowChip(accentColor: reel.accentColor),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Caption
                  Text(
                    reel.caption,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Tags
                  Wrap(
                    spacing: 6,
                    children: reel.tags
                        .map((t) => Text(
                      t,
                      style: TextStyle(
                        color: reel.accentColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),

                  // Audio ticker
                  _AudioTicker(audioName: reel.audioName),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Video Placeholder ───────────────────────────────────────────────────────

class _VideoPlaceholder extends StatelessWidget {
  final ReelData reel;
  const _VideoPlaceholder({required this.reel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 1.2,
          colors: [
            reel.accentColor.withOpacity(0.6),
            reel.bgColor,
            Colors.black,
          ],
        ),
      ),
      child: CustomPaint(painter: _GridPainter()),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.8;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Action Button ───────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Spinning Disc ───────────────────────────────────────────────────────────

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
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
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
            shape: BoxShape.circle,
            color: Colors.black,
          ),
          alignment: Alignment.center,
          child: Text(
            widget.initial,
            style: const TextStyle(fontSize: 6, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ─── Follow Chip ─────────────────────────────────────────────────────────────

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

// ─── Audio Ticker ────────────────────────────────────────────────────────────

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
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
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
          builder: (_, __) {
            return FractionalTranslation(
              translation: Offset(-_anim.value, 0),
              child: Text(
                text + text,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Custom Bottom Nav Bar ───────────────────────────────────────────────────

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.6),
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            context,
            index: 0,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
          ),
          _navItem(
            context,
            index: 1,
            icon: Icons.video_library_outlined,
            activeIcon: Icons.video_library,
          ),
          _navItem(
            context,
            index: 2,
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
          ),
          _navItem(
            context,
            index: 3,
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
          ),
          _profileItem(context),
        ],
      ),
    );
  }

  Widget _navItem(
      BuildContext context, {
        required int index,
        required IconData icon,
        required IconData activeIcon,
      }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: isActive ? 1.15 : 1.0,
        child: Icon(
          isActive ? activeIcon : icon,
          size: 26,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _profileItem(BuildContext context) {
    final isActive = currentIndex == 4;

    return GestureDetector(
      onTap: () => onTap(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isActive
              ? Border.all(
            color: Theme.of(context).colorScheme.onSurface,
            width: 1.6,
          )
              : null,
        ),
        // Falls back gracefully when the asset isn't present
        child: CircleAvatar(
          radius: 12,
          backgroundColor: Colors.white24,
          child: Icon(
            Icons.person,
            size: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// ─── Animation helper: sequence two animations ───────────────────────────────

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
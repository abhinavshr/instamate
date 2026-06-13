import 'package:flutter/material.dart';
import '../services/home_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _feed = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeed();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset(
          'assets/images/logo.png',
          height: 32,
        ),
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
                      child: const CircleAvatar(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'username',
                  style: TextStyle(fontSize: 12),
                ),
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
            ElevatedButton(
              onPressed: _loadFeed,
              child: const Text('Retry'),
            ),
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

              // Post image / slideable images
              if (media.isNotEmpty)
                media.length == 1
                    ? Image.network(
                  media[0]['media_url'],
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
                )
                    : _slideableImages(media)
              else
                Container(
                  height: 300,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.image, size: 80, color: Colors.white),
                  ),
                ),

              // Actions
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.black,
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.chat_bubble_outline),
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
          // Slideable images
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
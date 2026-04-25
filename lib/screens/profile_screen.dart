import 'package:flutter/material.dart';
import 'package:instamate/screens/edit_profile_screen.dart';
import 'package:instamate/screens/setting_screen.dart';
import 'package:instamate/widget/profile/post_detail_screen.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileWithStatsFuture;
  late Future<List<dynamic>> _myPostsFuture;

  @override
  void initState() {
    super.initState();
    _profileWithStatsFuture = _fetchProfileAndStats();
    _myPostsFuture = ProfileService.getMyPosts();
  }

  Future<Map<String, dynamic>> _fetchProfileAndStats() async {
    final profile = await ProfileService.getProfile();
    final stats = await ProfileService.getProfileStats();

    return {
      'user': profile,
      'stats': stats,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileWithStatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No profile data found'));
          }

          final user = snapshot.data!['user'];
          final stats = snapshot.data!['stats'];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  title: Text(
                    user?['username'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerTitle: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add_box_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: user?['profile_pic'] != null
                            ? NetworkImage(user!['profile_pic'])
                            : null,
                        child: user?['profile_pic'] == null
                            ? const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        )
                            : null,
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?['full_name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _ProfileStat(
                                    count: stats?['total_posts']?.toString() ?? '0',
                                    label: 'Posts'),
                                _ProfileStat(
                                    count: stats?['total_followers']?.toString() ?? '0',
                                    label: 'Followers'),
                                _ProfileStat(
                                    count: stats?['total_following']?.toString() ?? '0',
                                    label: 'Following'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user?['bio'] != null)
                        Text(user['bio'])
                      else
                        const Text(
                          'No bio added',
                          style: TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );

                            setState(() {
                              _profileWithStatsFuture = _fetchProfileAndStats();
                              _myPostsFuture = ProfileService.getMyPosts();
                            });
                          },
                          child: const Text('Edit Profile'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Share Profile'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(),

                FutureBuilder<List<dynamic>>(
                  future: _myPostsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final posts = snapshot.data ?? [];

                    if (posts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No posts yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),

                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final media = post['media'] as List<dynamic>;
                        final firstMedia = media.isNotEmpty ? media[0]['media_url'] : null;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PostDetailScreen(postId: post['post_id']),
                              ),
                            );
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              firstMedia != null
                                  ? Image.network(
                                firstMedia,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.white),
                                ),
                              )
                                  : Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image, color: Colors.white),
                              ),
                              // Add overlay if post has multiple images
                              if (media.length > 1)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Icon(
                                    Icons.collections,
                                    color: Colors.white,
                                    size: 20,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String count;
  final String label;

  const _ProfileStat({
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
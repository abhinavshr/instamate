import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No profile data found'));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // APP BAR (custom)
                AppBar(
                  title: Text(
                    user['username'] ?? '',
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
                      onPressed: () {},
                    ),
                  ],
                ),

                // Profile info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: user['profile_pic'] != null
                            ? NetworkImage(user['profile_pic'])
                            : null,
                        child: user['profile_pic'] == null
                            ? const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        )
                            : null,
                      ),

                      const SizedBox(width: 16),

                      // Name & Stats
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['full_name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                _ProfileStat(count: '0', label: 'Posts'),
                                _ProfileStat(count: '0', label: 'Followers'),
                                _ProfileStat(count: '0', label: 'Following'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bio
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user['bio'] != null)
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

                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
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

                // Post Grid (placeholder)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 9,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      color: Colors.grey.shade300,
                      child:
                      const Icon(Icons.image, color: Colors.white),
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

// Profile Stat Widget
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

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:instamate/screens/auth_check_screen.dart';
import 'package:instamate/services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _privateAccount = false;
  bool _notifications = true;
  bool _dataUsage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings and activity',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Account section
          _buildSectionHeader('Your account'),
          _buildNavItem(Icons.person_outline, 'Account privacy', subtitle: 'Private'),
          _buildNavItem(Icons.lock_outline, 'Password and security'),
          _buildNavItem(Icons.smartphone, 'Apps and websites'),
          _buildNavItem(Icons.email_outlined, 'Email notifications'),
          _buildNavItem(Icons.block, 'Blocked'),

          // How you use Instagram
          _buildSectionHeader('How you use Instagram'),
          _buildNavItem(Icons.favorite_border, 'Likes'),
          _buildNavItem(Icons.comment_outlined, 'Comments'),
          _buildNavItem(Icons.share_outlined, 'Sharing and remixes'),
          _buildNavItem(Icons.video_call_outlined, 'Reels'),
          _buildNavItem(Icons.person_add_alt_1_outlined, 'Follow and invite friends'),
          _buildNavItem(Icons.notifications_outlined, 'Notifications'),
          _buildNavItem(Icons.language, 'Language'),
          _buildNavItem(Icons.translate, 'Translation'),
          _buildNavItem(Icons.schedule, 'Your activity'),
          _buildNavItem(Icons.access_time, 'Time management'),

          // What you see
          _buildSectionHeader('What you see'),
          _buildNavItem(Icons.remove_red_eye_outlined, 'Content preferences'),
          _buildNavItem(Icons.hide_source_outlined, 'Hidden words'),
          _buildNavItem(Icons.group_outlined, 'Suggested content'),

          // Who can see your content
          _buildSectionHeader('Who can see your content'),
          _buildSwitchItem(
            Icons.lock_outline,
            'Private account',
            _privateAccount,
                (v) => setState(() => _privateAccount = v),
          ),
          _buildNavItem(Icons.close, 'Close Friends'),
          _buildNavItem(Icons.people_outline, 'Blocked accounts'),
          _buildNavItem(Icons.hide_image_outlined, 'Muted accounts'),

          // Your app and media
          _buildSectionHeader('Your app and media'),
          _buildNavItem(Icons.save_alt, 'Archiving and downloading'),
          _buildNavItem(Icons.data_usage, 'Cellular data use'),
          _buildNavItem(Icons.storage, 'Original posts'),
          _buildSwitchItem(
            Icons.data_saver_on_outlined,
            'Use less mobile data',
            _dataUsage,
                (v) => setState(() => _dataUsage = v),
          ),

          // For families
          _buildSectionHeader('For families'),
          _buildNavItem(Icons.supervisor_account_outlined, 'Supervision'),
          _buildNavItem(Icons.family_restroom, 'Family center'),

          // More info
          _buildSectionHeader('More info and support'),
          _buildNavItem(Icons.help_outline, 'Help'),
          _buildNavItem(Icons.info_outline, 'About'),
          _buildNavItem(Icons.privacy_tip_outlined, 'Privacy policy'),
          _buildNavItem(Icons.article_outlined, 'Terms of service'),

          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 8),

          // Log out
          InkWell(
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Log out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Log out',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await AuthService.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthCheckScreen()),
                        (route) => false,
                  );
                }
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                'Log out',
                style: TextStyle(
                  color: Colors.red, // Instagram uses red for logout
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          // Switch accounts
          InkWell(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                'Switch accounts',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, {String? subtitle}) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black87),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
      IconData icon,
      String title,
      bool value,
      ValueChanged<bool> onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.black,
          ),
        ],
      ),
    );
  }
}
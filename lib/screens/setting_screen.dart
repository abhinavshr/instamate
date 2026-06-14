import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:instamate/screens/auth_check_screen.dart';
import 'package:instamate/services/auth_service.dart';
import 'package:instamate/services/profile_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String section;
  final bool isSwitch;
  final bool? switchValue;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.section,
    this.isSwitch = false,
    this.switchValue,
  });
}

class _SettingsPageState extends State<SettingsPage> {
  bool _privateAccount = false;
  bool _notifications = true;
  bool _dataUsage = false;
  bool _isLoadingPrivacy = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late List<_SettingsItem> _allItems;

  @override
  void initState() {
    super.initState();
    _buildAllItems();
    _loadPrivacyStatus();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _loadPrivacyStatus() async {
    try {
      final privacy = await ProfileService.checkPrivacy();
      if (privacy != null && mounted) {
        setState(() {
          final isPrivate = privacy['is_private'];
          _privateAccount = isPrivate == true || isPrivate == 1;
          _isLoadingPrivacy = false;
          _buildAllItems();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPrivacy = false;
        });
      }
    }
  }

  Future<void> _togglePrivateAccount(bool value) async {
    final previousValue = _privateAccount;

    setState(() {
      _privateAccount = value;
      _buildAllItems();
    });

    try {
      await ProfileService.updatePrivacy(value);
    } catch (e) {
      // Revert on failure
      if (mounted) {
        setState(() {
          _privateAccount = previousValue;
          _buildAllItems();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update privacy: $e')),
        );
      }
    }
  }

  void _buildAllItems() {
    _allItems = [
      // Your account
      _SettingsItem(
        icon: Icons.person_outline,
        title: 'Account privacy',
        subtitle: _privateAccount ? 'Private' : 'Public',
        section: 'Your account',
      ),
      const _SettingsItem(icon: Icons.lock_outline, title: 'Password and security', section: 'Your account'),
      const _SettingsItem(icon: Icons.smartphone, title: 'Apps and websites', section: 'Your account'),
      const _SettingsItem(icon: Icons.email_outlined, title: 'Email notifications', section: 'Your account'),
      const _SettingsItem(icon: Icons.block, title: 'Blocked', section: 'Your account'),

      // How you use Instagram
      const _SettingsItem(icon: Icons.favorite_border, title: 'Likes', section: 'How you use Instagram'),
      const _SettingsItem(icon: Icons.comment_outlined, title: 'Comments', section: 'How you use Instagram'),
      const _SettingsItem(icon: Icons.share_outlined, title: 'Sharing and remixes', section: 'How you use Instagram'),
      const _SettingsItem(icon: Icons.video_call_outlined, title: 'Reels', section: 'How you use Instagram'),
      const _SettingsItem(icon: Icons.person_add_alt_1_outlined, title: 'Follow and invite friends', section: 'How you use Instagram'),
      const _SettingsItem(icon: Icons.notifications_outlined, title: 'Notifications', section: 'How you use Instagram'),
      const _SettingsItem(icon: Icons.language, title: 'Language', section: 'How you use Instagram'),
      const _SettingsItem(icon: Icons.translate, title: 'Translation', section: 'How you use Instagram'),
      const _SettingsItem(icon: Icons.schedule, title: 'Your activity', section: 'How you use Instagram'),
      const _SettingsItem(icon: Icons.access_time, title: 'Time management', section: 'How you use Instagram'),

      // What you see
      const _SettingsItem(icon: Icons.remove_red_eye_outlined, title: 'Content preferences', section: 'What you see'),
      const _SettingsItem(icon: Icons.hide_source_outlined, title: 'Hidden words', section: 'What you see'),
      const _SettingsItem(icon: Icons.group_outlined, title: 'Suggested content', section: 'What you see'),

      // Who can see your content
      _SettingsItem(
        icon: Icons.lock_outline,
        title: 'Private account',
        section: 'Who can see your content',
        isSwitch: true,
        switchValue: _privateAccount,
      ),
      const _SettingsItem(icon: Icons.close, title: 'Close Friends', section: 'Who can see your content'),
      const _SettingsItem(icon: Icons.people_outline, title: 'Blocked accounts', section: 'Who can see your content'),
      const _SettingsItem(icon: Icons.hide_image_outlined, title: 'Muted accounts', section: 'Who can see your content'),

      // Your app and media
      const _SettingsItem(icon: Icons.save_alt, title: 'Archiving and downloading', section: 'Your app and media'),
      const _SettingsItem(icon: Icons.data_usage, title: 'Cellular data use', section: 'Your app and media'),
      const _SettingsItem(icon: Icons.storage, title: 'Original posts', section: 'Your app and media'),
      _SettingsItem(icon: Icons.data_saver_on_outlined, title: 'Use less mobile data', section: 'Your app and media', isSwitch: true, switchValue: _dataUsage),

      // For families
      const _SettingsItem(icon: Icons.supervisor_account_outlined, title: 'Supervision', section: 'For families'),
      const _SettingsItem(icon: Icons.family_restroom, title: 'Family center', section: 'For families'),

      // More info and support
      const _SettingsItem(icon: Icons.help_outline, title: 'Help', section: 'More info and support'),
      const _SettingsItem(icon: Icons.info_outline, title: 'About', section: 'More info and support'),
      const _SettingsItem(icon: Icons.privacy_tip_outlined, title: 'Privacy policy', section: 'More info and support'),
      const _SettingsItem(icon: Icons.article_outlined, title: 'Terms of service', section: 'More info and support'),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_SettingsItem> get _filteredItems {
    if (_searchQuery.isEmpty) return [];
    return _allItems.where((item) {
      return item.title.toLowerCase().contains(_searchQuery) ||
          item.section.toLowerCase().contains(_searchQuery) ||
          (item.subtitle?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearching = _searchQuery.isNotEmpty;
    final filteredItems = _filteredItems;

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
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Body: search results or full list
          Expanded(
            child: isSearching
                ? _buildSearchResults(filteredItems)
                : _buildFullList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<_SettingsItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No results for "$_searchQuery"',
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0 || items[index - 1].section != item.section)
              _buildSectionHeader(item.section),
            item.isSwitch
                ? _buildSwitchItemFromData(item)
                : _buildNavItemFromData(item),
          ],
        );
      },
    );
  }

  Widget _buildFullList() {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        // Account section
        _buildSectionHeader('Your account'),
        _buildNavItem(
          Icons.person_outline,
          'Account privacy',
          subtitle: _privateAccount ? 'Private' : 'Public',
        ),
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
          _isLoadingPrivacy ? null : _togglePrivateAccount,
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
                color: Colors.red,
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
    );
  }

  // Used for search results rendering
  Widget _buildNavItemFromData(_SettingsItem item) {
    return _buildNavItem(item.icon, item.title, subtitle: item.subtitle);
  }

  Widget _buildSwitchItemFromData(_SettingsItem item) {
    if (item.title == 'Private account') {
      return _buildSwitchItem(
        item.icon,
        item.title,
        _privateAccount,
        _isLoadingPrivacy ? null : _togglePrivateAccount,
      );
    } else if (item.title == 'Use less mobile data') {
      return _buildSwitchItem(
        item.icon,
        item.title,
        _dataUsage,
            (v) => setState(() => _dataUsage = v),
      );
    }
    return _buildNavItem(item.icon, item.title);
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
      ValueChanged<bool>? onChanged,
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
          if (_isLoadingPrivacy && title == 'Private account')
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
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
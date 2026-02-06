import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import 'edit_field_screen.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: ProfileService.getProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          final profile = snapshot.data!;
          final fullName = profile['full_name'] ?? '';
          final username = profile['username'] ?? '';
          final bio = profile['bio'] ?? '';
          final profilePic = profile['profile_pic'];

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Profile Picture
                Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: profilePic != null
                          ? NetworkImage(profilePic)
                          : const AssetImage('assets/images/user_avatar.png') as ImageProvider,
                      onBackgroundImageError: (_, __) {
                        // fallback to asset if network image fails
                      },
                      child: profilePic == null
                          ? Image.asset(
                        'assets/images/user_avatar.png',
                        width: 40,
                        height: 40,
                      )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Change profile photo',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Divider(height: 1, color: theme.dividerColor),

                // Name
                _editRow(
                  context,
                  label: 'Name',
                  value: fullName,
                ),

                // Username
                _editRow(
                  context,
                  label: 'Username',
                  value: username,
                ),

                // Bio
                _editRow(
                  context,
                  label: 'Bio',
                  value: bio,
                  maxLines: 3,
                ),

                const SizedBox(height: 8),
                Divider(height: 1, color: theme.dividerColor),

                // Switch to professional account
                ListTile(
                  title: Text(
                    'Switch to professional account',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color),
                  onTap: () {},
                ),

                Divider(height: 1, color: theme.dividerColor),

                // Personal information settings
                ListTile(
                  title: Text(
                    'Personal information settings',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color),
                  onTap: () {},
                ),

                Divider(height: 1, color: theme.dividerColor),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _editRow(
      BuildContext context, {
        required String label,
        required String value,
        int maxLines = 1,
      }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditFieldScreen(
              title: label,
              initialValue: value,
              maxLines: maxLines,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? '—' : value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

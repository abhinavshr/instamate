import 'package:flutter/material.dart';
import 'edit_field_screen.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Profile Picture
            Column(
              children: [
                const CircleAvatar(
                  radius: 45,
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150',
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Change profile photo',
                    style: TextStyle(
                      color: Color(0xFF3797EF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(height: 1),

            // Name
            _editRow(
              context,
              label: 'Name',
              value: 'Abhinav Shrestha',
            ),

            // Username
            _editRow(
              context,
              label: 'Username',
              value: 'abhinav_shrestha',
            ),

            // Bio
            _editRow(
              context,
              label: 'Bio',
              value: 'Flutter Developer 🚀\nBuilding cool apps',
              maxLines: 3,
            ),

            const SizedBox(height: 8),
            const Divider(height: 1),

            // Switch to Professional Account
            ListTile(
              title: const Text(
                'Switch to professional account',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),

            const Divider(height: 1),

            // Personal Information Settings
            ListTile(
              title: const Text(
                'Personal information settings',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),

            const Divider(height: 1),
          ],
        ),
      ),
    );
  }

  Widget _editRow(
      BuildContext context, {
        required String label,
        required String value,
        int maxLines = 1,
      }) {
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
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Expanded(
              child: Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';
import 'edit_field_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ProfileService.getProfile();
      setState(() {
        _profile = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
          ? Center(child: Text('Failed to load profile', style: theme.textTheme.bodyMedium))
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _profile!['profile_pic'] != null
                      ? NetworkImage(_profile!['profile_pic'])
                      : const AssetImage('assets/images/user_avatar.png') as ImageProvider,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _showImageSourceSheet(),
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
            _editRow(label: 'Name', value: _profile!['full_name'] ?? ''),
            _editRow(label: 'Username', value: _profile!['username'] ?? ''),
            _editRow(label: 'Bio', value: _profile!['bio'] ?? '', maxLines: 3),
            const SizedBox(height: 8),
            Divider(height: 1, color: theme.dividerColor),
            ListTile(
              title: Text(
                'Switch to professional account',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color),
              onTap: () {},
            ),
            Divider(height: 1, color: theme.dividerColor),
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
      ),
    );
  }

  // ------------------------- Edit Row -------------------------
  Widget _editRow({required String label, required String value, int maxLines = 1}) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () async {
        final newValue = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (_) => EditFieldScreen(title: label, initialValue: value, maxLines: maxLines),
          ),
        );

        if (newValue != null && newValue != value) {
          try {
            Map<String, String> updateData = {};
            switch (label) {
              case 'Name':
                updateData['fullName'] = newValue;
                break;
              case 'Username':
                updateData['username'] = newValue;
                break;
              case 'Bio':
                updateData['bio'] = newValue;
                break;
            }

            if (updateData.isNotEmpty) {
              await ProfileService.updateProfile(
                username: updateData['username'],
                fullName: updateData['fullName'],
                bio: updateData['bio'],
              );

              setState(() {
                // Update the local profile map dynamically
                if (updateData['fullName'] != null) _profile!['full_name'] = updateData['fullName'];
                if (updateData['username'] != null) _profile!['username'] = updateData['username'];
                if (updateData['bio'] != null) _profile!['bio'] = updateData['bio'];
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update profile: $e')),
            );
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(label, style: theme.textTheme.bodyMedium),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? '—' : value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------- Bottom Sheet -------------------------
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------- Pick Image -------------------------
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        // Call the updated method that handles multipart
        await ProfileService.updateProfile(profilePicFile: file);

        // Refresh the profile data from server
        await _loadProfile();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile picture: $e')),
      );
    }
  }

}

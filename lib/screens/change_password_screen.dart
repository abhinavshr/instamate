import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatelessWidget {
  final String email;
  const ChangePasswordScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Password'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create a new password for',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              Text(
                email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'New password',
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Confirm password',
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    // static for now
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password changed (static)'),
                      ),
                    );
                  },
                  child: const Text(
                    'Save password',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

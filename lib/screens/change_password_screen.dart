import 'package:flutter/material.dart';
import 'package:instamate/services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ChangePasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void _handleSavePassword() async {
    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showMessage('All fields are required');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showMessage('Passwords do not match');
      return;
    }

    setState(() => isLoading = true);

    final error = await AuthService.resetPassword(
      email: widget.email,
      otp: widget.otp,
      newPassword: passwordController.text,
    );

    setState(() => isLoading = false);

    if (error == null) {
      _showMessage('Password changed successfully');

      // Navigate to login
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      _showMessage(error);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  InputDecoration _inputDecoration(
      BuildContext context,
      String hint,
      bool isVisible,
      VoidCallback onToggle,
      ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 1.5,
        ),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? Icons.visibility_off : Icons.visibility,
          color: theme.hintColor,
        ),
        onPressed: onToggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Password'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),

              Text(
                'Create a new password',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 32),

              // 🔑 New Password
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: _inputDecoration(
                  context,
                  'New password',
                  isPasswordVisible,
                      () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 🔑 Confirm Password
              TextField(
                controller: confirmPasswordController,
                obscureText: !isConfirmPasswordVisible,
                decoration: _inputDecoration(
                  context,
                  'Confirm password',
                  isConfirmPasswordVisible,
                      () {
                    setState(() {
                      isConfirmPasswordVisible =
                      !isConfirmPasswordVisible;
                    });
                  },
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSavePassword,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  )
                      : const Text(
                    'Save password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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

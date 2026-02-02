import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widget/auth_switch_text.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  Future<void> _handleRegister() async {
    if (emailController.text.isEmpty ||
        fullNameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showMessage('All fields are required');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showMessage('Passwords do not match');
      return;
    }

    setState(() => isLoading = true);

    final error = await AuthService.register(
      email: emailController.text.trim(),
      fullName: fullNameController.text.trim(),
      username: usernameController.text.trim(),
      password: passwordController.text,
    );

    setState(() => isLoading = false);

    if (error == null) {
      _showMessage('Registration successful');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      _showMessage(error);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo (same for light & dark)
                Image.asset(
                  'assets/images/logo.png',
                  height: 70,
                ),

                const SizedBox(height: 20),

                Text(
                  'Sign up to see photos and videos from your friends.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                _inputField('Email', controller: emailController),
                const SizedBox(height: 12),

                _inputField('Full Name', controller: fullNameController),
                const SizedBox(height: 12),

                _inputField('Username', controller: usernameController),
                const SizedBox(height: 12),

                _inputField(
                  'Password',
                  controller: passwordController,
                  isPassword: true,
                  isPasswordVisible: isPasswordVisible,
                  togglePassword: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),

                const SizedBox(height: 12),

                _inputField(
                  'Confirm Password',
                  controller: confirmPasswordController,
                  isPassword: true,
                  isPasswordVisible: isConfirmPasswordVisible,
                  togglePassword: () {
                    setState(() {
                      isConfirmPasswordVisible =
                      !isConfirmPasswordVisible;
                    });
                  },
                ),

                const SizedBox(height: 16),

                Text(
                  'People who use our service may have uploaded your contact information.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.hintColor),
                ),

                const SizedBox(height: 16),

                // Sign up button
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
                    child: isLoading
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child:
                      CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'OR',
                        style: TextStyle(color: theme.hintColor),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 24),

                // Login link
                AuthSwitchText(
                  normalText: "Have an account? ",
                  actionText: "Log in",
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(
      String hint, {
        required TextEditingController controller,
        bool isPassword = false,
        bool isPasswordVisible = false,
        VoidCallback? togglePassword,
      }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !isPasswordVisible : false,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordVisible
                ? Icons.visibility_off
                : Icons.visibility,
          ),
          onPressed: togglePassword,
        )
            : null,
      ),
    );
  }
}

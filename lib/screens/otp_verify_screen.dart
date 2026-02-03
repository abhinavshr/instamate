import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'change_password_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String email;
  const OtpVerifyScreen({super.key, required this.email});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  bool isLoading = false;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_otpCode.length != 6) {
      _showMessage('Enter complete OTP');
      return;
    }

    setState(() => isLoading = true);

    final error = await AuthService.verifyOtp(
      email: widget.email,
      otp: _otpCode,
    );

    setState(() => isLoading = false);

    if (error == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChangePasswordScreen(email: widget.email),
        ),
      );
    } else {
      _showMessage(error);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: const Text('Verify OTP'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),

                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.dividerColor,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 42,
                    color: theme.colorScheme.onBackground,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Enter security code',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                Text(
                  'Please enter the 6-digit code sent to',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.hintColor),
                ),
                const SizedBox(height: 6),

                Text(
                  widget.email,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return _otpBox(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      nextFocus:
                      index < 5 ? _focusNodes[index + 1] : null,
                      prevFocus:
                      index > 0 ? _focusNodes[index - 1] : null,
                      isDark: isDark,
                      context: context,
                    );
                  }),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _verifyOtp,
                    child: isLoading
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Verify',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Didn't receive the code?",
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.hintColor),
                ),
                TextButton(
                  onPressed: () {
                    // static resend
                  },
                  child: const Text('Resend OTP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _otpBox({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required FocusNode? nextFocus,
    required FocusNode? prevFocus,
    required bool isDark,
  }) {
    return SizedBox(
      width: 48,
      height: 54,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor:
          isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
            BorderSide(color: Theme.of(context).dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.6,
            ),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && nextFocus != null) {
            nextFocus.requestFocus();
          } else if (value.isEmpty && prevFocus != null) {
            prevFocus.requestFocus();
          }
        },
      ),
    );
  }
}

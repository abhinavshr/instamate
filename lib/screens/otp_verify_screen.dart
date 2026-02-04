import 'dart:async';
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

  // 🔥 Resend OTP timer
  int _resendSeconds = 120;
  bool _canResend = false;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  // ---------------- VERIFY OTP ----------------
  Future<void> _verifyOtp() async {
    if (_otpCode.length != 6) {
      _showMessage('Enter complete OTP', false);
      return;
    }

    setState(() => isLoading = true);

    final error = await AuthService.verifyOtp(
      email: widget.email,
      otp: _otpCode,
    );

    setState(() => isLoading = false);

    if (error == null) {
      _showMessage('OTP verified successfully', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChangePasswordScreen(
            email: widget.email,
            otp: _otpCode,
          ),
        ),
      );
    } else {
      _showMessage(error, false);
    }
  }

  // ---------------- RESEND OTP ----------------
  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() => isLoading = true);

    final error = await AuthService.resendOtp(email: widget.email);

    setState(() => isLoading = false);

    if (error == null) {
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();

      _showMessage('OTP resent successfully', true);
      _startResendTimer();
    } else {
      _showMessage(error, false);
    }
  }

  // ---------------- TIMER ----------------
  void _startResendTimer() {
    _canResend = false;
    _resendSeconds = 120;

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  // ---------------- UI MESSAGE ----------------
  void _showMessage(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isSuccess ? const Color(0xFF3797EF) : Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
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
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF3797EF),
        ),
        title: Text(
          'Verify OTP',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF3797EF),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),

                Icon(Icons.lock_outline, size: 80),

                const SizedBox(height: 24),

                Text(
                  'Enter security code',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                Text(
                  'We sent a 6-digit code to',
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
                      child: CircularProgressIndicator(strokeWidth: 2),
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
                  onPressed:
                  _canResend && !isLoading ? _resendOtp : null,
                  child: Text(
                    _canResend
                        ? 'Resend OTP'
                        : 'Resend in ${_resendSeconds}s',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- OTP BOX ----------------
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
        decoration: const InputDecoration(counterText: ''),
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

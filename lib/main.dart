import 'package:flutter/material.dart';
import 'package:instamate/screens/auth_check_screen.dart';
import 'constants/app_theme.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Instagram Clone',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const BackendCheckWrapper(),
    );
  }
}

// ── Backend health-check wrapper ──────────────────────────────────────────────

class BackendCheckWrapper extends StatefulWidget {
  const BackendCheckWrapper({super.key});

  @override
  State<BackendCheckWrapper> createState() => _BackendCheckWrapperState();
}

class _BackendCheckWrapperState extends State<BackendCheckWrapper> {
  // Possible states: checking | online | offline
  String _status = 'checking';

  static const String _healthUrl = 'http://10.0.2.2:5000/health';

  @override
  void initState() {
    super.initState();
    _checkBackend();
  }

  Future<void> _checkBackend() async {
    setState(() => _status = 'checking');
    try {
      final response = await http
          .get(Uri.parse(_healthUrl))
          .timeout(const Duration(seconds: 5));

      setState(() {
        _status = (response.statusCode >= 200 && response.statusCode < 300)
            ? 'online'
            : 'offline';
      });
    } on TimeoutException {
      setState(() => _status = 'offline');
    } catch (_) {
      setState(() => _status = 'offline');
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_status) {
      'checking' => const _CheckingScreen(),
      'online'   => const AuthCheckScreen(),
      _          => _OfflineScreen(onRetry: _checkBackend),
    };
  }
}

// ── Checking screen (spinner) ─────────────────────────────────────────────────

class _CheckingScreen extends StatelessWidget {
  const _CheckingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting…', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ── Offline screen ────────────────────────────────────────────────────────────

class _OfflineScreen extends StatelessWidget {
  const _OfflineScreen({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 72,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Server Unreachable',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'We couldn\'t connect to the backend.\n'
                      'Please make sure the server is running and try again.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:instamate/screens/profile_screen.dart';
import 'package:instamate/screens/reel_screen.dart';
import 'package:instamate/widget/custom_bottom_navbar.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = const [
      HomeScreen(),
      ReelFeedPage(),
      _PageText(title: 'Message'),
      _PageText(title: 'Search'),
      ProfileScreen()
    ];
  }

  void _onTabChanged(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}

/// 🔹 Temporary placeholder pages
class _PageText extends StatelessWidget {
  final String title;
  const _PageText({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Text(
        title,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

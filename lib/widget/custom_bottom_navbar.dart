import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.6),
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            context,
            index: 0,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
          ),
          _navItem(
            context,
            index: 1,
            icon: Icons.video_library_outlined,
            activeIcon: Icons.video_library,
          ),
          _navItem(
            context,
            index: 2,
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
          ),
          _navItem(
            context,
            index: 3,
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
          ),
          _profileItem(context),
        ],
      ),
    );
  }

  Widget _navItem(
      BuildContext context, {
        required int index,
        required IconData icon,
        required IconData activeIcon,
      }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: isActive ? 1.15 : 1.0,
        child: Icon(
          isActive ? activeIcon : icon,
          size: 26,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
    );
  }

  Widget _profileItem(BuildContext context) {
    final isActive = currentIndex == 4;

    return GestureDetector(
      onTap: () => onTap(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isActive
              ? Border.all(
            color: Theme.of(context).colorScheme.onBackground,
            width: 1.6,
          )
              : null,
        ),
        child: const CircleAvatar(
          radius: 12,
          backgroundImage: AssetImage('assets/images/user_avatar.png'),
        ),
      ),
    );
  }
}

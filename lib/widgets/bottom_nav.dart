import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../theme/theme_tokens.dart';

class BottomNav extends StatelessWidget {
  final int index;
  final Function(int) onTap;

  const BottomNav({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.3 * 255).round()),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: GNav(
          selectedIndex: index,
          onTabChange: onTap,
          backgroundColor: Colors.transparent,
          color: isDark ? Colors.grey[400] : AppColors.gray,
          activeColor: AppColors.blue,
          tabBackgroundColor: isDark ? AppColors.darkCard : AppColors.lightGray,
          gap: 8,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          tabs: const [
            GButton(icon: Icons.inbox_outlined, text: 'Inbox'),
            GButton(icon: Icons.today, text: 'Today'),
            GButton(icon: Icons.calendar_month_outlined, text: 'Upcoming'),
            GButton(icon: Icons.settings_outlined, text: 'Settings'),
          ],
        ),
      ),
    );
  }
}

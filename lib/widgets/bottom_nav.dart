import 'package:flutter/material.dart';
import '../theme/theme_tokens.dart';

class BottomNav extends StatelessWidget {
  final int index;
  final Function(int) onTap;

  const BottomNav({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    List<IconData> icons = [
      Icons.inbox_outlined,
      Icons.today,
      Icons.calendar_month_outlined,
      Icons.settings_outlined,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.3 * 255).round()),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          icons.length,
          (i) => GestureDetector(
            onTap: () => onTap(i),
            child: Icon(
              icons[i],
              size: 30,
              color: i == index
                  ? AppColors.blue
                  : (isDark ? Colors.grey[400] : AppColors.gray),
            ),
          ),
        ),
      ),
    );
  }
}

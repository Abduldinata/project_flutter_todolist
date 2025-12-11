import 'package:flutter/material.dart';
import '../theme/colors.dart';

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
      Icons.filter_list,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.bg,
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha((0.3 * 255).round()),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                ),
              ]
            : [
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(-4, -4),
                  blurRadius: 8,
                ),
                const BoxShadow(
                  color: Color(0xFFBEBEBE),
                  offset: Offset(6, 6),
                  blurRadius: 12,
                ),
              ],
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

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class BottomNav extends StatelessWidget {
  final int index;
  final Function(int) onTap;

  const BottomNav({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    List<IconData> icons = [
      Icons.inbox_outlined,
      Icons.today,
      Icons.calendar_month_outlined,
      Icons.filter_list,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
          BoxShadow(
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
              color: i == index ? AppColors.blue : AppColors.gray,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../utils/app_style.dart';
import '../theme/colors.dart';
import '../utils/neumorphic_decoration.dart';

class NeumorphicButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const NeumorphicButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 26),
        decoration: isDark
            ? BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[800]!),
              )
            : Neu.convex,
        child: Text(
          label,
          style: AppStyle.normal.copyWith(
            color: AppColors.blue,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

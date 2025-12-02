import 'package:flutter/material.dart';
import '../utils/app_style.dart';
import '../utils/app_colors.dart';
import '../utils/neumorphic_decoration.dart';

class NeumorphicButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const NeumorphicButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 26),
        decoration: Neu.convex,
        child: Text(
          label,
          style: AppStyle.normal.copyWith(color: AppColors.blue),
        ),
      ),
    );
  }
}

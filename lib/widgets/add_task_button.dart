import 'package:flutter/material.dart';
import '../theme/theme_tokens.dart';
import '../services/sound_service.dart';

class AddTaskButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddTaskButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FloatingActionButton(
      onPressed: () {
        SoundService().playSound(SoundType.tap);
        onTap();
      },
      tooltip: 'Tambah Task',
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 64,
        height: 64,
        decoration: isDark ? NeuDark.convex : Neu.convex,
        child: Center(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.blue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(Icons.add, size: 28, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

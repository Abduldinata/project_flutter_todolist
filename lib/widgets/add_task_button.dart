import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/theme_tokens.dart';
import '../theme/theme_controller.dart';
import '../services/sound_service.dart';

class AddTaskButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddTaskButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final themeController = Get.find<ThemeController>();
      final accentColor = themeController.accentColor.value;
      
      return FloatingActionButton(
        onPressed: () {
          SoundService().playSound(SoundType.addTask);
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
                color: accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.4),
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
    });
  }
}

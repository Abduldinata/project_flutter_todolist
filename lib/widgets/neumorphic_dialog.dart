import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_colors.dart';
import '../utils/app_style.dart';
import '../utils/neumorphic_decoration.dart';
import 'neumorphic_button.dart';

class NeumorphicDialog extends StatelessWidget {
  final String title;
  final String message;
  final DialogType type;
  final VoidCallback? onConfirm;
  final String? confirmText;

  const NeumorphicDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = DialogType.info,
    this.onConfirm,
    this.confirmText,
  });

  static void show({
    required String title,
    required String message,
    DialogType type = DialogType.info,
    VoidCallback? onConfirm,
    String? confirmText,
  }) {
    Get.dialog(
      NeumorphicDialog(
        title: title,
        message: message,
        type: type,
        onConfirm: onConfirm,
        confirmText: confirmText,
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: isDark
            ? BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[800]!),
              )
            : Neu.convex.copyWith(borderRadius: BorderRadius.circular(25)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon based on type
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : AppColors.bg,
                shape: BoxShape.circle,
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.5 * 255).round()),
                          blurRadius: 8,
                        ),
                      ]
                    : Neu.pressed.boxShadow,
              ),
              child: Icon(type.icon, size: 32, color: type.color),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: AppStyle.title.copyWith(
                fontSize: 20,
                color: isDark ? Colors.white : AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: AppStyle.normal.copyWith(
                color: isDark ? Colors.grey[300] : AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                if (onConfirm != null) ...[
                  Expanded(
                    child: NeumorphicButton(
                      label: 'Batal',
                      onTap: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: NeumorphicButton(
                    label: confirmText ?? 'OK',
                    onTap: () {
                      Get.back();
                      if (onConfirm != null) onConfirm!();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum DialogType {
  success,
  error,
  warning,
  info;

  IconData get icon {
    switch (this) {
      case DialogType.success:
        return Icons.check_rounded;
      case DialogType.error:
        return Icons.close_rounded;
      case DialogType.warning:
        return Icons.warning_rounded;
      case DialogType.info:
        return Icons.info_rounded;
    }
  }

  Color get color {
    switch (this) {
      case DialogType.success:
        return AppColors.success;
      case DialogType.error:
        return AppColors.danger;
      case DialogType.warning:
        return Colors.orange;
      case DialogType.info:
        return AppColors.blue;
    }
  }
}

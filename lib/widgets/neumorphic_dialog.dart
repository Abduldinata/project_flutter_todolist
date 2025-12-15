import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/theme_tokens.dart';

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
        decoration: FlatStyle.card(isDark: isDark),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon based on type
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: type.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(type.icon, size: 32, color: type.color),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                if (onConfirm != null) ...[
                  Expanded(
                    child: _buildButton(
                      label: 'Cancel',
                      isDark: isDark,
                      isPrimary: false,
                      onTap: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: _buildButton(
                    label: confirmText ?? 'OK',
                    isDark: isDark,
                    isPrimary: true,
                    color: type.color,
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

  Widget _buildButton({
    required String label,
    required bool isDark,
    required bool isPrimary,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary
              ? (color ?? AppColors.blue)
              : (isDark ? AppColors.darkSurface : Colors.grey[200]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isPrimary
                  ? Colors.white
                  : (isDark ? Colors.white : AppColors.text),
            ),
          ),
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

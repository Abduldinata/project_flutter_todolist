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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: Neu.convex.copyWith(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon based on type
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bg,
                shape: BoxShape.circle,
                boxShadow: Neu.pressed.boxShadow,
              ),
              child: Icon(
                type.icon,
                size: 32,
                color: type.color,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: AppStyle.title.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: AppStyle.normal,
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
                      // color: AppColors.text.withOpacity(0.1),
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
                    // color: AppColors.blue,
                    // textColor: Colors.white,
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

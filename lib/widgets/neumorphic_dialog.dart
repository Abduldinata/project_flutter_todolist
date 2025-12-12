import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/neumorphic_decoration.dart';
import 'neumorphic_button.dart';

class NeumorphicDialog extends StatelessWidget {
  final String title;
  final String message;
  final DialogType type;
  final VoidCallback? onConfirm;
  final String? confirmText;
  final String? cancelText;
  final bool showCancel;

  const NeumorphicDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = DialogType.info,
    this.onConfirm,
    this.confirmText,
    this.cancelText,
    this.showCancel = true,
  });

  static Future<bool?> show({
    required String title,
    required String message,
    DialogType type = DialogType.info,
    VoidCallback? onConfirm,
    String? confirmText,
    String? cancelText,
    bool showCancel = true,
    bool barrierDismissible = false,
  }) {
    return Get.dialog<bool>(
      NeumorphicDialog(
        title: title,
        message: message,
        type: type,
        onConfirm: onConfirm,
        confirmText: confirmText,
        cancelText: cancelText,
        showCancel: showCancel,
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: Neu.convex(context).copyWith(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon based on type
            Container(
              padding: const EdgeInsets.all(16),
              decoration: Neu.pressed(context).copyWith(
                shape: BoxShape.circle,
              ),
              child: Icon(
                type.icon,
                size: 32,
                color: type.color(context),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                // Cancel Button
                if (onConfirm != null && showCancel) ...[
                  Expanded(
                    child: NeumorphicButton(
                      label: cancelText ?? 'Batal',
                      onTap: () => Get.back(result: false),
                      textColor: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                
                // Confirm/OK Button
                Expanded(
                  child: NeumorphicButton(
                    label: confirmText ?? 'OK',
                    onTap: () {
                      Get.back(result: true);
                      if (onConfirm != null) {
                        onConfirm!();
                      }
                    },
                    textColor: type.color(context),
                    backgroundColor: type.color(context).withOpacity(0.1),
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

  Color color(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (this) {
      case DialogType.success:
        return Colors.green;
      case DialogType.error:
        return colorScheme.error;
      case DialogType.warning:
        return Colors.orange;
      case DialogType.info:
        return colorScheme.primary;
    }
  }
}
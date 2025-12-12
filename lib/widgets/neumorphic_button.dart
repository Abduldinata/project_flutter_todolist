import 'package:flutter/material.dart';

class NeumorphicButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? backgroundColor;
  final bool fullWidth;

  const NeumorphicButton({
    super.key,
    required this.label,
    required this.onTap,
    this.textColor,
    this.backgroundColor,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Import NeuDecoration di sini
    final NeuDecoration = BoxDecoration(
      color: backgroundColor ?? colorScheme.surface,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        // Shadow atas kiri (light)
        BoxShadow(
          color: colorScheme.onSurface.withOpacity(0.1),
          offset: const Offset(-3, -3),
          blurRadius: 8,
          spreadRadius: 1,
        ),
        // Shadow bawah kanan (dark)
        BoxShadow(
          color: colorScheme.onSurface.withOpacity(0.2),
          offset: const Offset(3, 3),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 26),
        decoration: NeuDecoration,
        child: Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: textColor ?? colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
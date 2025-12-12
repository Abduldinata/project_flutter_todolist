import 'package:flutter/material.dart';
import '../theme/theme_tokens.dart';

class AppTheme {
  static ThemeData light() {
    final scheme = AppColors.lightScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: AppTypography.toTextTheme(scheme),

      cardTheme: CardThemeData(
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          final isSelected = states.contains(WidgetState.selected);
          // ON -> primary, OFF -> putih / surface
          return isSelected ? scheme.primary : scheme.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary.withValues(alpha: 0.2)
              : scheme.outlineVariant,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = AppColors.darkScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: AppTypography.toTextTheme(scheme),

      cardTheme: CardThemeData(
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          final isSelected = states.contains(WidgetState.selected);
          // ON -> biru, OFF -> abu-abu terang
          return isSelected ? scheme.primary : scheme.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          final isSelected = states.contains(WidgetState.selected);
          // ON -> biru transparan, OFF -> abu-abu gelap
          return isSelected
              ? scheme.primary.withValues(alpha: 0.35)
              : scheme.surfaceContainerHighest;
        }),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

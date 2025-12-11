import 'package:flutter/material.dart';
import 'colors.dart';

class AppTypography {
  // Style dasar (mengambil dari style yang kamu punya sebelumnya)

  static const title = TextStyle(
    color: AppColors.text,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const subtitle = TextStyle(
    color: AppColors.text,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const body = TextStyle(
    color: AppColors.text,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const small = TextStyle(
    color: AppColors.gray,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const link = TextStyle(
    fontSize: 15,
    decoration: TextDecoration.underline,
    color: AppColors.gray,
  );

  /// Konversi ke TextTheme supaya bisa dipakai global:
  /// Theme.of(context).textTheme.bodyLarge, titleLarge, dll.
    static TextTheme toTextTheme(ColorScheme scheme) {
    final baseColor = scheme.onSurface;

    return TextTheme(
      headlineLarge: title.copyWith(color: baseColor),
      titleLarge: subtitle.copyWith(color: baseColor),

      bodyLarge: body.copyWith(color: baseColor),
      bodyMedium: body.copyWith(fontSize: 15, color: baseColor),

      bodySmall: small.copyWith(color: scheme.onSurface.withOpacity(0.7)),

      labelLarge: button.copyWith(color: scheme.onPrimary),

      labelMedium: link.copyWith(
        color: scheme.primary,
        decoration: TextDecoration.underline,
      ),
    );
  }

}

import 'package:flutter/material.dart';

class AppColors {
  /// Warna utama (light)
  static const bg = Color(0xFFFFF9F1); // background neumorphism
  static const blue = Color(0xFF007AFF); // iOS blue
  static const text = Color(0xFF222222);
  static const gray = Color(0xFF9E9E9E);
  static const danger = Color(0xFFE53935);
  static const success = Color(0xFF43A047);

  /// Warna tambahan untuk dark mode
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const lightSurface = Colors.white;

  /// Abu-abu untuk komponen (contoh: priority chip)
  static const priorityUnselectedDark = Color(0xFF2C2C2C);
  static const prioritySelectedDark = Color(0xFF505050);

  /// ColorScheme untuk light theme
  static const ColorScheme lightScheme = ColorScheme.light(
    primary: blue,
    secondary: blue,
    surface: lightSurface,
    onSurface: text,
    error: danger,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onError: Colors.white,
  );

  /// ColorScheme untuk dark theme
  static const ColorScheme darkScheme = ColorScheme.dark(
    primary: blue,
    secondary: blue,
    surface: darkSurface,
    onSurface: Colors.white,
    error: danger,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onError: Colors.white,
  );
}

class AppTypography {
  // Style dasar
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

  /// Mengubah ke TextTheme supaya bisa dipakai:
  /// Theme.of(context).textTheme.bodyLarge, dst.
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

class AppStyle {
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

  static const normal = TextStyle(
    color: AppColors.text,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const smallGray = TextStyle(
    color: AppColors.gray,
    fontSize: 13,
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
}

// Kelas untuk mendefinisikan dekorasi Neumorphism
class Neu {
  // Dekorasi Concave (cekung) - Digunakan untuk latar belakang dialog besar
  static BoxDecoration get concave => BoxDecoration(
    color: AppColors.bg,
    borderRadius: BorderRadius.circular(25),
    boxShadow: [
      BoxShadow(
        color: Colors.white, // Bayangan terang di atas/kiri
        offset: const Offset(-6, -6),
        blurRadius: 10,
      ),
      BoxShadow(
        color: AppColors.text.withAlpha(128), // Bayangan gelap di bawah/kanan
        offset: const Offset(6, 6),
        blurRadius: 10,
      ),
    ],
  );

  // Dekorasi Convex (cembung) - Digunakan untuk input field dan tombol biasa
  static BoxDecoration get convex => BoxDecoration(
    color: AppColors.bg,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: AppColors.text.withAlpha(128), // Bayangan gelap di atas/kiri
        offset: const Offset(-4, -4),
        blurRadius: 8,
      ),
      BoxShadow(
        color: Colors.white, // Bayangan terang di bawah/kanan
        offset: const Offset(4, 4),
        blurRadius: 8,
      ),
    ],
  );

  // Dekorasi Pressed (Tertekan) - Digunakan untuk tombol yang aktif atau dipilih (seperti Prioritas)
  static BoxDecoration get pressed => BoxDecoration(
    color: AppColors.bg,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      // Bayangan dimasukkan (inverse shadow)
      BoxShadow(
        color: AppColors.text.withAlpha(128),
        offset: const Offset(4, 4),
        blurRadius: 8,
        spreadRadius: -1,
      ),
      BoxShadow(
        color: Colors.white.withAlpha(128),
        offset: const Offset(-4, -4),
        blurRadius: 8,
        spreadRadius: -1,
      ),
    ],
  );
}

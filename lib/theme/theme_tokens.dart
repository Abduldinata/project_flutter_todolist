import 'package:flutter/material.dart';

class AppColors {
  /// Warna utama sesuai gambar (biru yang lebih soft)
  static const bg = Color(0xFFF8F9FA); // Background lebih terang seperti gambar
  static const blue = Color(0xFF4A6FA5); // Biru lebih soft seperti di gambar
  static const accentBlue = Color(0xFF6C8DC3); // Untuk highlight
  static const text = Color(0xFF2C3E50); // Text lebih gelap
  static const gray = Color(0xFF95A5A6);
  static const lightGray = Color(0xFFECF0F1);
  static const danger = Color(0xFFE74C3C);
  static const success = Color(0xFF2ECC71);
  static const warning = Color(0xFFF39C12);

  /// Warna untuk progress/percentage (sesuai gambar)
  static const progressBg = Color(0xFFE8EDF5);
  static const progressFill = Color(0xFF6C8DC3);

  /// Warna untuk dark mode - lebih harmonis dengan gambar
  static const darkBg = Color(0xFF0F1525); // Background gelap lebih dalam
  static const darkSurface = Color(0xFF1A2235); // Surface lebih gelap
  static const darkCard = Color(0xFF212A3E); // Untuk card dan container
  static const darkText = Color(0xFFE6E9F0); // Text lebih terang untuk kontras
  static const lightSurface = Colors.white;

  /// Abu-abu untuk komponen (contoh: priority chip)
  static const priorityUnselectedDark = Color(0xFF2C2C2C);
  static const prioritySelectedDark = Color(0xFF505050);

  /// ColorScheme untuk light theme
  static const ColorScheme lightScheme = ColorScheme.light(
    primary: blue,
    primaryContainer: Color(0xFFD6E4FF),
    secondary: accentBlue,
    secondaryContainer: Color(0xFFE8EDF5),
    surface: lightSurface,
    onSurface: text,
    error: danger,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onError: Colors.white,
    outline: Color(0xFFD1D5DB),
    outlineVariant: Color(0xFFE5E7EB),
    surfaceContainerHighest: Color(0xFFF1F5F9),
  );

  /// ColorScheme untuk dark theme - lebih harmonis
  static const ColorScheme darkScheme = ColorScheme.dark(
    primary: Color(0xFF7BA4FF), // Biru lebih terang untuk dark mode
    primaryContainer: Color(0xFF2A3F66),
    secondary: Color(0xFF94A9D6),
    secondaryContainer: Color(0xFF2D3B54),
    surface: darkSurface,
    onSurface: darkText,
    error: Color(0xFFFF8A80),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onError: Colors.black,
    outline: Color(0xFF455472),
    outlineVariant: Color(0xFF374151),
    surfaceContainerHighest: Color(0xFF374462),
  );
}

class AppTypography {
  // Sesuai gambar: font lebih clean dan modern
  static const title = TextStyle(
    color: AppColors.text,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const subtitle = TextStyle(
    color: AppColors.text,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static const body = TextStyle(
    color: AppColors.text,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const bodyBold = TextStyle(
    color: AppColors.text,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const small = TextStyle(
    color: AppColors.gray,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const caption = TextStyle(
    color: AppColors.gray,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  /// TextTheme untuk Material 3
  static TextTheme toTextTheme(ColorScheme scheme) {
    final baseColor = scheme.onSurface;
    final secondaryColor = scheme.onSurface.withAlpha(179); // 0.7 opacity

    return TextTheme(
      displayLarge: title.copyWith(color: baseColor),
      displayMedium: title.copyWith(fontSize: 28, color: baseColor),

      titleLarge: subtitle.copyWith(color: baseColor),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),

      bodyLarge: body.copyWith(color: baseColor),
      bodyMedium: body.copyWith(fontSize: 15, color: baseColor),

      bodySmall: small.copyWith(color: secondaryColor),
      labelSmall: caption.copyWith(color: secondaryColor),

      labelLarge: button.copyWith(color: scheme.onPrimary),

      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: scheme.primary,
        decoration: TextDecoration.underline,
      ),
    );
  }
}

class AppStyle {
  static const title = TextStyle(
    color: AppColors.text,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const subtitle = TextStyle(
    color: AppColors.text,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static const normal = TextStyle(
    color: AppColors.text,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const smallGray = TextStyle(
    color: AppColors.gray,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const link = TextStyle(
    fontSize: 15,
    decoration: TextDecoration.underline,
    color: AppColors.blue,
    fontWeight: FontWeight.w500,
  );
}

// Neumorphism yang lebih soft seperti di gambar
class Neu {
  // Concave - untuk card/list items (lebih subtle)
  static BoxDecoration get concave => BoxDecoration(
    color: AppColors.lightSurface,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.white.withAlpha(204), // 0.8 opacity
        offset: const Offset(-6, -6),
        blurRadius: 12,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withAlpha(13), // 0.05 opacity
        offset: const Offset(6, 6),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ],
    border: Border.all(
      color: Colors.white.withAlpha(77), // 0.3 opacity
      width: 1,
    ),
  );

  // Convex - untuk input fields (lebih ringan)
  static BoxDecoration get convex => BoxDecoration(
    color: AppColors.lightSurface,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(13), // 0.05 opacity
        offset: const Offset(-4, -4),
        blurRadius: 8,
      ),
      BoxShadow(
        color: Colors.white.withAlpha(204), // 0.8 opacity
        offset: const Offset(4, 4),
        blurRadius: 8,
      ),
    ],
  );

  // Pressed - untuk selected state
  static BoxDecoration get pressed => BoxDecoration(
    color: AppColors.lightSurface,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(13), // 0.05 opacity
        offset: const Offset(3, 3),
        blurRadius: 5,
        spreadRadius: -2,
      ),
      BoxShadow(
        color: Colors.white.withAlpha(204), // 0.8 opacity
        offset: const Offset(-3, -3),
        blurRadius: 5,
        spreadRadius: -2,
      ),
    ],
  );
}

// Neumorphism untuk dark mode
class NeuDark {
  // Concave - untuk card/list items dark mode
  static BoxDecoration get concave => BoxDecoration(
    color: AppColors.darkCard,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.white.withAlpha(5), // Highlight sangat halus
        offset: const Offset(-4, -4),
        blurRadius: 8,
      ),
      BoxShadow(
        color: Colors.black.withAlpha(128), // Shadow lebih dalam
        offset: const Offset(4, 4),
        blurRadius: 12,
      ),
    ],
    border: Border.all(color: Colors.white.withAlpha(10), width: 1),
  );

  // Convex - untuk input fields dark mode
  static BoxDecoration get convex => BoxDecoration(
    color: AppColors.darkCard,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(128),
        offset: const Offset(-4, -4),
        blurRadius: 8,
      ),
      BoxShadow(
        color: Colors.white.withAlpha(5),
        offset: const Offset(4, 4),
        blurRadius: 8,
      ),
    ],
  );

  // Pressed - untuk selected state dark mode
  static BoxDecoration get pressed => BoxDecoration(
    color: AppColors.darkCard,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(128),
        offset: const Offset(2, 2),
        blurRadius: 4,
        spreadRadius: -1,
      ),
      BoxShadow(
        color: Colors.white.withAlpha(5),
        offset: const Offset(-2, -2),
        blurRadius: 4,
        spreadRadius: -1,
      ),
    ],
  );

  // Flat - untuk background sections dark mode
  static BoxDecoration get flat => BoxDecoration(
    color: AppColors.darkBg,
    borderRadius: BorderRadius.circular(20),
  );
}

// Flat style tanpa neumorphic (modern flat design)
class FlatStyle {
  // Card - untuk card/list items (flat dengan shadow ringan)
  static BoxDecoration card({required bool isDark}) => BoxDecoration(
    color: isDark ? AppColors.darkCard : Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.08),
        offset: const Offset(0, 2),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
  );

  // Input - untuk input fields (flat dengan border)
  static BoxDecoration input({required bool isDark}) => BoxDecoration(
    color: isDark ? AppColors.darkCard : Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.grey.withValues(alpha: 0.2),
      width: 1,
    ),
  );

  // Button - untuk buttons (flat dengan hover effect)
  static BoxDecoration button({required bool isDark, Color? color}) => BoxDecoration(
    color: color ?? (isDark ? AppColors.darkSurface : Colors.grey[100]),
    borderRadius: BorderRadius.circular(12),
  );

  // Container - untuk general containers
  static BoxDecoration container({required bool isDark}) => BoxDecoration(
    color: isDark ? AppColors.darkCard : Colors.white,
    borderRadius: BorderRadius.circular(16),
  );
}
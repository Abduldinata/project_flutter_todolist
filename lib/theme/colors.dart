import 'package:flutter/material.dart';

class AppColors {
  /// Warna utama yang sudah kamu pakai sebelumnya
  static const bg = Color(0xFFfff9f1); // background neumorphism
  static const blue = Color(0xFF007AFF); // iOS blue
  static const text = Color(0xFF222222);
  static const gray = Color(0xFF9E9E9E);
  static const danger = Color(0xFFE53935);
  static const success = Color(0xFF43A047);

  // Warna tambahan untuk dark mode
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const lightSurface = Colors.white;

  /// ColorScheme untuk light theme (tanpa set background/onBackground manual)
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

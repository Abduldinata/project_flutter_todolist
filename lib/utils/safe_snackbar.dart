import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// Helper untuk menampilkan snackbar yang aman setelah navigasi
class SafeSnackbar {
  /// Show snackbar dengan delay otomatis untuk mencegah crash saat transisi
  static void show({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? colorText,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
    int delayMs = 100, // Delay 100ms untuk aman dari transisi
  }) {
    // Gunakan scheduleMicrotask + delay untuk memastikan frame render selesai
    Future.delayed(Duration(milliseconds: delayMs), () {
      try {
        Get.snackbar(
          title,
          message,
          backgroundColor: backgroundColor,
          colorText: colorText ?? Colors.white,
          snackPosition: position,
          duration: duration,
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
        );
      } catch (e) {
        // Jika error (misal context sudah dispose), print ke log
        debugPrint('SafeSnackbar error: $e');
      }
    });
  }

  /// Show success snackbar
  static void success(String message, {String title = 'Success'}) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Show error snackbar
  static void error(String message, {String title = 'Error'}) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  /// Show info snackbar
  static void info(String message, {String title = 'Info'}) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  /// Show warning snackbar
  static void warning(String message, {String title = 'Warning'}) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }
}

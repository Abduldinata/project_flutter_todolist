import 'package:flutter/material.dart';
import 'app_colors.dart';

class Neu {
  // Card utama / container
  static BoxDecoration concave = BoxDecoration(
    color: AppColors.bg,
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
      BoxShadow(color: Color(0xFFBEBEBE), offset: Offset(6, 6), blurRadius: 12),
    ],
  );

  // Tombol / input menonjol
  static BoxDecoration convex = BoxDecoration(
    color: AppColors.bg,
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(color: Colors.white, offset: Offset(4, 4), blurRadius: 8),
      BoxShadow(
        color: Color(0xFFBEBEBE),
        offset: Offset(-6, -6),
        blurRadius: 12,
      ),
    ],
  );
}

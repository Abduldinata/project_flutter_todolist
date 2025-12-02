import 'package:flutter/material.dart';
import 'app_colors.dart'; 

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
        color: AppColors.text.withOpacity(0.2), // Bayangan gelap di bawah/kanan
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
        color: AppColors.text.withOpacity(0.2), // Bayangan gelap di atas/kiri
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
        color: AppColors.text.withOpacity(0.1),
        offset: const Offset(4, 4),
        blurRadius: 8,
        spreadRadius: -1,
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.9),
        offset: const Offset(-4, -4),
        blurRadius: 8,
        spreadRadius: -1,
      ),
    ],
  );
}
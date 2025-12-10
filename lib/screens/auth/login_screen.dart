import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/neumorphic_dialog.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_style.dart';
import '../../utils/app_colors.dart';
import '../../utils/neumorphic_decoration.dart';
import '../../widgets/neumorphic_textfield.dart';
import '../../widgets/neumorphic_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _service = SupabaseService();
  bool _isLoading = false;
  bool _showPassword = false;

  Future<void> _handleLogin() async {
    // Validasi input
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Email dan password harus diisi');
      return;
    }

    // Validasi format email
    if (!GetUtils.isEmail(_emailController.text.trim())) {
      _showError('Format email tidak valid');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _service.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (response.user != null) {
        NeumorphicDialog.show(
          title: 'Berhasil',
          message: 'Login berhasil! Selamat datang ${response.user!.email}',
          type: DialogType.success,
        );

        // Tunggu sebentar agar user bisa lihat pesan sukses
        await Future.delayed(const Duration(milliseconds: 1500));
        Get.offAllNamed(AppRoutes.inbox);
      }
    } catch (e) {
      String errorMessage = _parseError(e.toString());
      _showError(errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _parseError(String error) {
    // Network errors
    if (error.contains('SocketException') ||
        error.contains('Failed host lookup') ||
        error.contains('Network is unreachable')) {
      return '❌ Tidak ada koneksi internet\n\nPastikan:\n• WiFi atau data seluler aktif\n• Koneksi internet stabil\n• Tidak ada firewall yang memblokir';
    }

    // Timeout errors
    if (error.contains('TimeoutException') || error.contains('timed out')) {
      return '⏱️ Koneksi timeout\n\nKoneksi terlalu lambat atau server tidak merespons';
    }

    // Auth errors
    if (error.contains('Invalid login credentials') ||
        error.contains('Invalid email or password')) {
      return '🔐 Email atau password salah\n\nPeriksa kembali email dan password Anda';
    }

    if (error.contains('Email not confirmed')) {
      return '📧 Email belum diverifikasi\n\nCek inbox email Anda dan klik link verifikasi';
    }

    if (error.contains('User not found')) {
      return '👤 Akun tidak ditemukan\n\nSilakan daftar terlebih dahulu';
    }

    // SSL/Certificate errors
    if (error.contains('CERTIFICATE') || error.contains('SSL')) {
      return '🔒 Error sertifikat SSL\n\nMungkin ada masalah dengan keamanan koneksi';
    }

    // Generic error
    return '⚠️ Login gagal\n\n${error.length > 100 ? "${error.substring(0, 100)}..." : error}';
  }

  void _showError(String message) {
    NeumorphicDialog.show(
      title: 'Error',
      message: message,
      type: DialogType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
          // optional overlay untuk meningkatkan kontras teks
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha((0.25 * 255).round()),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo atau Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: Neu.concave,
                      child: const Icon(
                        Icons.checklist_rounded,
                        size: 60,
                        color: AppColors.blue,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Title
                    Text('Login', style: AppStyle.title),
                    const SizedBox(height: 10),
                    Text('Masuk ke akun Anda', style: AppStyle.smallGray),
                    const SizedBox(height: 40),

                    // Email Field
                    NeumorphicTextField(
                      controller: _emailController,
                      hint: 'Email',
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    NeumorphicTextField(
                      controller: _passwordController,
                      hint: 'Password',
                      obscure: !_showPassword,
                      textInputAction: TextInputAction
                          .done, // Mengubah icon keyboard menjadi "Selesai" atau "Centang"
                      onSubmitted: (_) {
                        // Memanggil fungsi login ketika tombol enter ditekan
                        _handleLogin();
                      },
                      suffix: IconButton(
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.text.withAlpha((0.6 * 255).round()),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Login Button
                    _isLoading
                        ? Container(
                            padding: const EdgeInsets.all(14),
                            decoration: Neu.convex,
                            child: const CircularProgressIndicator(
                              color: AppColors.blue,
                            ),
                          )
                        : NeumorphicButton(label: 'Login', onTap: _handleLogin),
                    const SizedBox(height: 30),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Don\'t have an account? ', style: AppStyle.smallGray),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.register),
                          child: Text(
                            'Sign Up',
                            style: AppStyle.link.copyWith(
                              color: AppColors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

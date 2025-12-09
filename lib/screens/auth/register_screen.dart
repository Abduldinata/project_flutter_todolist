import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_style.dart';
import '../../utils/app_colors.dart';
import '../../utils/neumorphic_decoration.dart';
import '../../widgets/neumorphic_textfield.dart';
import '../../widgets/neumorphic_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _service = SupabaseService();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    // Validasi input
    if (_usernameController.text.trim().isEmpty) {
      _showError('Username harus diisi');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showError('Email harus diisi');
      return;
    }

    if (!GetUtils.isEmail(_emailController.text.trim())) {
      _showError('Format email tidak valid');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError('Password minimal 6 karakter');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Password dan konfirmasi password tidak sama');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _service.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _usernameController.text.trim(),
      );

      if (response.user != null) {
        Get.snackbar(
          'Berhasil',
          'Registrasi berhasil! Silakan cek email untuk verifikasi',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(AppRoutes.login);
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
      return '❌ Tidak ada koneksi internet\n\nPastikan:\n• WiFi atau data seluler aktif\n• Koneksi internet stabil';
    }

    // Timeout errors
    if (error.contains('TimeoutException') || error.contains('timed out')) {
      return '⏱️ Koneksi timeout\n\nKoneksi terlalu lambat atau server tidak merespons';
    }

    // Auth errors
    if (error.contains('User already registered') ||
        error.contains('already been registered')) {
      return '👤 Email sudah terdaftar\n\nGunakan email lain atau silakan login';
    }

    if (error.contains('Password should be at least')) {
      return '🔐 Password terlalu pendek\n\nPassword minimal 6 karakter';
    }

    if (error.contains('Unable to validate email address')) {
      return '📧 Format email tidak valid\n\nPeriksa kembali email Anda';
    }

    // Generic error
    return '⚠️ Registrasi gagal\n\n${error.length > 100 ? "${error.substring(0, 100)}..." : error}';
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: AppColors.danger,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(16),
      snackPosition: SnackPosition.TOP,
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
                    // Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: Neu.concave,
                      child: const Icon(
                        Icons.person_add_rounded,
                        size: 60,
                        color: AppColors.blue,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Title
                    Text('Daftar', style: AppStyle.title),
                    const SizedBox(height: 10),
                    Text('Buat akun baru', style: AppStyle.smallGray),
                    const SizedBox(height: 40),

                    // Username Field
                    NeumorphicTextField(
                      controller: _usernameController,
                      hint: 'Username',
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    NeumorphicTextField(
                      controller: _emailController,
                      hint: 'Email',
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    NeumorphicTextField(
                      controller: _passwordController,
                      hint: 'Password (min. 6 karakter)',
                      obscure: true,
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password Field
                    NeumorphicTextField(
                      controller: _confirmPasswordController,
                      hint: 'Konfirmasi Password',
                      obscure: true,
                    ),
                    const SizedBox(height: 40),

                    // Register Button
                    _isLoading
                        ? Container(
                            padding: const EdgeInsets.all(14),
                            decoration: Neu.convex,
                            child: const CircularProgressIndicator(
                              color: AppColors.blue,
                            ),
                          )
                        : NeumorphicButton(
                            label: 'Daftar',
                            onTap: _handleRegister,
                          ),
                    const SizedBox(height: 30),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sudah punya akun? ', style: AppStyle.smallGray),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Text(
                            'Masuk',
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

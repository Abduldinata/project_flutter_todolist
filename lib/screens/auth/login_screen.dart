import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Service & State Variables
  late final SupabaseService _service;
  late final StreamSubscription<AuthState> _authSubscription;

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _service = SupabaseService();

    // 🟢 PERBAIKAN PENTING DI SINI (SOLUSI CRASH):
    // Kita hanya mengandalkan listener untuk navigasi di WEB.
    // Di Mobile, navigasi akan dihandle manual oleh tombol (await) agar
    // bisa menampilkan Dialog Sukses terlebih dahulu tanpa tabrakan.
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (kIsWeb) {
        final session = data.session;
        if (session != null && mounted) {
          // Cek agar tidak redirect berulang
          if (Get.currentRoute == AppRoutes.login) {
            // Gunakan postFrameCallback agar aman saat rebuild
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed(AppRoutes.inbox);
            });
          }
        }
      }
    });
  }

  // --- LOGIC LOGIN EMAIL ---
  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Email dan password harus diisi');
      return;
    }

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
        if (mounted) {
          NeumorphicDialog.show(
            title: 'Berhasil',
            message: 'Login berhasil! Selamat datang.',
            type: DialogType.success,
          );

          // Delay sedikit untuk UX, lalu navigasi manual (Mobile & Web non-redirect)
          await Future.delayed(const Duration(milliseconds: 1500));
          Get.offAllNamed(AppRoutes.inbox);
        }
      }
    } catch (e) {
      _showError(_parseError(e.toString()));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- LOGIC LOGIN GOOGLE ---
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      // 1. Panggil Service
      final response = await _service.signInWithGoogle();

      // 2. Handle Hasil (KHUSUS MOBILE)
      // Jika di Web, halaman biasanya sudah redirect/reload, jadi kode di bawah skip.
      // Jika di Mobile, kita handle navigasi di sini (karena listener dimatikan untuk mobile).
      if (!kIsWeb && response.user != null) {
        if (mounted) {
          NeumorphicDialog.show(
            title: 'Berhasil',
            message: 'Login dengan Google berhasil!',
            type: DialogType.success,
          );

          await Future.delayed(const Duration(milliseconds: 1000));
          Get.offAllNamed(AppRoutes.inbox);
        }
      }
    } catch (e) {
      // Parse error agar user friendly
      String errorMessage = _parseGoogleError(e.toString());

      // Jangan tampilkan popup error jika user hanya membatalkan login (Back button)
      if (!errorMessage.toLowerCase().contains('dibatalkan')) {
        _showError(errorMessage);
      } else {
        debugPrint("User cancelled Google Sign In");
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  // --- ERROR PARSING ---
  String _parseError(String error) {
    if (error.contains('SocketException') ||
        error.contains('Failed host lookup') ||
        error.contains('Network is unreachable')) {
      return '❌ Tidak ada koneksi internet';
    }
    if (error.contains('Invalid login credentials') ||
        error.contains('Invalid email or password')) {
      return '🔐 Email atau password salah';
    }
    if (error.contains('Email not confirmed')) {
      return '📧 Email belum diverifikasi. Cek inbox Anda.';
    }
    return '⚠️ Login gagal: ${error.length > 100 ? "${error.substring(0, 100)}..." : error}';
  }

  String _parseGoogleError(String error) {
    if (error.contains('sign in cancelled') || error.contains('canceled')) {
      return 'Login dibatalkan';
    }
    if (error.contains('network error') || error.contains('SocketException')) {
      return '❌ Periksa koneksi internet Anda';
    }
    if (error.contains('10') || error.contains('SIGN_IN_FAILED')) {
      return '⚠️ Konfigurasi Error:\nPastikan SHA-1 Fingerprint sudah didaftarkan di Google Cloud Console untuk Android.';
    }
    return '⚠️ Gagal login Google: $error';
  }

  void _showError(String message) {
    NeumorphicDialog.show(
      title: 'Info',
      message: message,
      type: DialogType.error,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authSubscription.cancel(); // Wajib cancel listener
    super.dispose();
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
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
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleLogin(),
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

                    // Login Button (Email)
                    _isLoading
                        ? Container(
                            padding: const EdgeInsets.all(14),
                            decoration: Neu.convex,
                            child: const CircularProgressIndicator(
                              color: AppColors.blue,
                            ),
                          )
                        : NeumorphicButton(
                            label: 'Login dengan Email',
                            onTap: _handleLogin,
                          ),

                    const SizedBox(height: 20),

                    // OR Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppColors.text.withAlpha(
                              (0.3 * 255).round(),
                            ),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('atau', style: AppStyle.smallGray),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.text.withAlpha(
                              (0.3 * 255).round(),
                            ),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Google Sign In Button
                    _isGoogleLoading
                        ? Container(
                            padding: const EdgeInsets.all(14),
                            decoration: Neu.convex,
                            child: const CircularProgressIndicator(
                              color: AppColors.blue,
                            ),
                          )
                        : Container(
                            decoration: Neu.convex,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: _handleGoogleSignIn,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 24,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/icon_google.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Login dengan Google',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.text,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                    const SizedBox(height: 30),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Belum punya akun? ', style: AppStyle.smallGray),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.register),
                          child: Text(
                            'Daftar',
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
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../widgets/neumorphic_dialog.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_style.dart';
import '../../utils/app_colors.dart';
import '../../utils/neumorphic_decoration.dart';
import '../../widgets/neumorphic_textfield.dart';
import '../../widgets/neumorphic_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();

    // Listen for auth state changes (untuk web OAuth redirect)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && mounted) {
        // User berhasil login via OAuth redirect
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.currentRoute == AppRoutes.login) {
            Get.offAllNamed(AppRoutes.inbox);
          }
        });
      }
    });
  }

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

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      if (kIsWeb) {
        // Untuk web, gunakan OAuth flow (akan redirect)
        await _service.signInWithGoogle();
        // OAuth flow akan redirect, jadi loading tetap aktif
        // State change listener akan handle navigation setelah redirect
      } else {
        // Untuk mobile, gunakan Google Sign-In package
        final response = await _service.signInWithGoogle();

        if (response.user != null) {
          NeumorphicDialog.show(
            title: 'Berhasil',
            message: 'Login dengan Google berhasil!',
            type: DialogType.success,
          );

          await Future.delayed(const Duration(milliseconds: 1500));
          Get.offAllNamed(AppRoutes.inbox);
        }
      }
    } catch (e) {
      String errorMessage = _parseGoogleError(e.toString());
      _showError(errorMessage);

      if (mounted) {
        setState(() => _isGoogleLoading = false);
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

  String _parseGoogleError(String error) {
    if (error.contains('sign in cancelled') || error.contains('canceled')) {
      return 'Login dengan Google dibatalkan';
    }

    if (error.contains('popup_closed')) {
      return 'Popup login Google ditutup sebelum selesai';
    }

    if (error.contains('redirect_uri_mismatch')) {
      return '⚠️ Konfigurasi Google OAuth salah\n\nRedirect URI tidak sesuai. Hubungi developer.';
    }

    if (error.contains('network error') || error.contains('SocketException')) {
      return '❌ Tidak ada koneksi internet\n\nPastikan koneksi internet aktif untuk login dengan Google';
    }

    if (error.contains('sign_in_failed') || error.contains('SIGN_IN_FAILED')) {
      return '⚠️ Gagal login dengan Google\n\nPastikan:\n• Google Play Services terinstall (Android)\n• Akun Google tersedia di device';
    }

    return '⚠️ Gagal login dengan Google\n\n$error';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

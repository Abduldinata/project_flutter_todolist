import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/neumorphic_dialog.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../../theme/theme_tokens.dart';
import 'forgot_password_screen.dart';

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
  final bool _isAppleLoading = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _service = SupabaseService();

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (kIsWeb) {
        final session = data.session;
        if (session != null && mounted) {
          if (Get.currentRoute == AppRoutes.login) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed(AppRoutes.inbox);
            });
          }
        }
      }
    });
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Email and password are required');
      return;
    }

    if (!GetUtils.isEmail(_emailController.text.trim())) {
      _showError('Invalid email format');
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
            title: 'Success',
            message: 'Login successful! Welcome back.',
            type: DialogType.success,
          );

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

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      final response = await _service.signInWithGoogle();

      if (!kIsWeb && response.user != null) {
        if (mounted) {
          NeumorphicDialog.show(
            title: 'Success',
            message: 'Google sign in successful!',
            type: DialogType.success,
          );

          await Future.delayed(const Duration(milliseconds: 1000));
          Get.offAllNamed(AppRoutes.inbox);
        }
      }
    } catch (e) {
      String errorMessage = _parseGoogleError(e.toString());

      if (!errorMessage.toLowerCase().contains('cancelled') &&
          !errorMessage.toLowerCase().contains('dibatalkan')) {
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

  Future<void> _handleAppleSignIn() async {
    // Apple Sign In - can be implemented later
    _showError('Apple Sign In coming soon');
  }

  String _parseError(String error) {
    if (error.contains('SocketException') ||
        error.contains('Failed host lookup') ||
        error.contains('Network is unreachable')) {
      return '❌ No internet connection';
    }
    if (error.contains('Invalid login credentials') ||
        error.contains('Invalid email or password')) {
      return '🔐 Invalid email or password';
    }
    if (error.contains('Email not confirmed')) {
      return '📧 Email not verified. Please check your inbox.';
    }
    return '⚠️ Login failed: ${error.length > 100 ? "${error.substring(0, 100)}..." : error}';
  }

  String _parseGoogleError(String error) {
    if (error.contains('sign in cancelled') || error.contains('canceled')) {
      return 'Sign in cancelled';
    }
    if (error.contains('network error') || error.contains('SocketException')) {
      return '❌ Please check your internet connection';
    }
    if (error.contains('10') || error.contains('SIGN_IN_FAILED')) {
      return '⚠️ Configuration Error:\nPlease ensure SHA-1 Fingerprint is registered in Google Cloud Console for Android.';
    }
    return '⚠️ Google sign in failed: $error';
  }

  void _showError(String message) {
    NeumorphicDialog.show(
      title: 'Error',
      message: message,
      type: DialogType.error,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Icon(Icons.check_circle, size: 40, color: AppColors.blue),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Welcome Text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.text,
                  ),
                  children: [
                    const TextSpan(text: 'Welcome To '),
                    TextSpan(
                      text: 'DoList',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please sign in to access your workspace',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),

              const SizedBox(height: 40),

              // Email Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'user@example.com',
                    icon: Icons.email_outlined,
                    isDark: isDark,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    hint: '••••••••',
                    icon: _showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    isDark: isDark,
                    obscure: !_showPassword,
                    onIconTap: () {
                      setState(() => _showPassword = !_showPassword);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: AppColors.blue, fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Log In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? Container(
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 30),

              // Or continue with
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Social Login Buttons
              Row(
                children: [
                  // Google Button
                  Expanded(
                    child: _buildSocialButton(
                      onTap: _isGoogleLoading ? null : _handleGoogleSignIn,
                      isDark: isDark,
                      isLoading: _isGoogleLoading,
                      icon: Image.asset(
                        'assets/images/icon_google.png',
                        width: 20,
                        height: 20,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.g_mobiledata, size: 20);
                        },
                      ),
                      label: 'Google',
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Apple Button
                  Expanded(
                    child: _buildSocialButton(
                      onTap: _isAppleLoading ? null : _handleAppleSignIn,
                      isDark: isDark,
                      isLoading: _isAppleLoading,
                      icon: Image.asset(
                        'assets/images/icon_apple.png',
                        width: 20,
                        height: 20,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.apple,
                            size: 20,
                            color: isDark ? Colors.white : Colors.black,
                          );
                        },
                      ),
                      label: 'Apple',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.register),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool obscure = false,
    VoidCallback? onIconTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        textInputAction: controller == _passwordController
            ? TextInputAction.done
            : TextInputAction.next,
        onSubmitted: controller == _passwordController
            ? (_) => _handleLogin()
            : null,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.text,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[400],
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: IconButton(
            onPressed: onIconTap,
            icon: Icon(
              icon,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback? onTap,
    required bool isDark,
    required bool isLoading,
    required Widget icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(child: icon),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.text,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

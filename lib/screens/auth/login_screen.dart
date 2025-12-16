import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/neumorphic_dialog.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../../theme/theme_tokens.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../services/sound_service.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
      SoundService().playSound(SoundType.error);
      _showError('Email and password are required');
      return;
    }

    if (!GetUtils.isEmail(_emailController.text.trim())) {
      SoundService().playSound(SoundType.error);
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
          SoundService().playSound(SoundType.success);
          
          try {
            final taskController = Get.find<TaskController>();
            final profileController = Get.find<ProfileController>();
            await taskController.loadAllTasks(forceRefresh: true);
            await profileController.loadProfile(forceRefresh: true);
          } catch (e) {
            debugPrint("Error refreshing controllers after login: $e");
          }

          Get.snackbar("Success", "Login successful! Welcome back.");
          await Future.delayed(const Duration(milliseconds: 1500));
          Get.offAllNamed(AppRoutes.inbox);
        }
      }
    } catch (e) {
      SoundService().playSound(SoundType.error);
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
          try {
            final taskController = Get.find<TaskController>();
            final profileController = Get.find<ProfileController>();
            await taskController.loadAllTasks(forceRefresh: true);
            await profileController.loadProfile(forceRefresh: true);
          } catch (e) {
            debugPrint("Error refreshing controllers after Google login: $e");
          }

          SoundService().playSound(SoundType.success);

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
      SoundService().playSound(SoundType.error);
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

              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          SoundService().playSound(SoundType.tap);
                          _handleLogin();
                        },
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

              Row(
                children: [
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
      onTap: () {
        if (onTap != null) {
          SoundService().playSound(SoundType.tap);
          onTap();
        }
      },
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.blue,
                  ),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/neumorphic_dialog.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../../theme/theme_tokens.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _service = SupabaseService();
  
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  final bool _isAppleLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _agreeToTerms = false;

  Future<void> _handleRegister() async {
    // Validasi input
    if (_emailController.text.trim().isEmpty) {
      _showError('Email address is required');
      return;
    }

    if (!GetUtils.isEmail(_emailController.text.trim())) {
      _showError('Invalid email format');
      return;
    }

    if (_passwordController.text.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    if (!_agreeToTerms) {
      _showError('Please agree to the Terms of Service and Privacy Policy');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Extract username from email (before @)
      final email = _emailController.text.trim();
      final username = email.split('@')[0];

      final response = await _service.signUp(
        email,
        _passwordController.text,
        username,
      );

      if (response.user != null) {
        if (mounted) {
          NeumorphicDialog.show(
            title: 'Success',
            message: 'Account created successfully! Please check your email for verification.',
            type: DialogType.success,
          );

          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            Get.offAllNamed(AppRoutes.login);
          }
        }
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
      final response = await _service.signInWithGoogle();

      if (response.user != null && mounted) {
        NeumorphicDialog.show(
          title: 'Success',
          message: 'Account created successfully!',
          type: DialogType.success,
        );

        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) {
          Get.offAllNamed(AppRoutes.inbox);
        }
      }
    } catch (e) {
      String errorMessage = _parseGoogleError(e.toString());
      if (!errorMessage.toLowerCase().contains('cancelled') &&
          !errorMessage.toLowerCase().contains('dibatalkan')) {
        _showError(errorMessage);
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
    // Network errors
    if (error.contains('SocketException') ||
        error.contains('Failed host lookup') ||
        error.contains('Network is unreachable')) {
      return '❌ No internet connection';
    }

    // Timeout errors
    if (error.contains('TimeoutException') || error.contains('timed out')) {
      return '⏱️ Connection timeout';
    }

    // Auth errors
    if (error.contains('User already registered') ||
        error.contains('already been registered')) {
      return '👤 Email already registered\n\nUse a different email or sign in';
    }

    if (error.contains('Password should be at least')) {
      return '🔐 Password too short\n\nPassword must be at least 8 characters';
    }

    if (error.contains('Unable to validate email address')) {
      return '📧 Invalid email format\n\nPlease check your email address';
    }

    // Generic error
    return '⚠️ Registration failed\n\n${error.length > 100 ? "${error.substring(0, 100)}..." : error}';
  }

  String _parseGoogleError(String error) {
    if (error.contains('sign in cancelled') || error.contains('canceled')) {
      return 'Sign in cancelled';
    }
    if (error.contains('network error') || error.contains('SocketException')) {
      return '❌ Please check your internet connection';
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Back Button
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : AppColors.text,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join thousands of users organizing their life with focus and clarity.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),

              const SizedBox(height: 40),

              // Email Address Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email Address',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'name@example.com',
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
                    hint: 'Min. 8 characters',
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

              const SizedBox(height: 20),

              // Confirm Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hint: 'Re-enter password',
                    icon: _showConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    isDark: isDark,
                    obscure: !_showConfirmPassword,
                    onIconTap: () {
                      setState(() => _showConfirmPassword = !_showConfirmPassword);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Terms and Privacy Agreement
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => _agreeToTerms = !_agreeToTerms);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 12, top: 2),
                      decoration: BoxDecoration(
                        color: _agreeToTerms ? AppColors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _agreeToTerms
                              ? AppColors.blue
                              : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                          width: 2,
                        ),
                      ),
                      child: _agreeToTerms
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  // Terms of Service
                                  _showError('Terms of Service coming soon');
                                },
                                child: Text(
                                  'Terms of Service',
                                  style: TextStyle(
                                    color: AppColors.blue,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  // Privacy Policy
                                  _showError('Privacy Policy coming soon');
                                },
                                child: Text(
                                  'Privacy Policy.',
                                  style: TextStyle(
                                    color: AppColors.blue,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Create Account Button
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
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 30),

              // OR REGISTER WITH
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
                      'OR REGISTER WITH',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        letterSpacing: 1.2,
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
                      icon: Icon(
                        Icons.apple,
                        size: 20,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      label: 'Apple',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already a member? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      'Log In',
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
        textInputAction: controller == _confirmPasswordController
            ? TextInputAction.done
            : TextInputAction.next,
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

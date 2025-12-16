import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/loading_widget.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? token;
  final String? type;

  const ResetPasswordScreen({super.key, this.token, this.type});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _service = SupabaseService();

  bool _isLoading = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isTokenValid = false;

  @override
  void initState() {
    super.initState();
    _checkTokenValidity();
  }

  Future<void> _checkTokenValidity() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      setState(() {
        _isTokenValid = true;
      });
      debugPrint('Recovery session found, token is valid');
    } else {
      debugPrint('No recovery session found');
      await Future.delayed(const Duration(milliseconds: 500));

      final sessionAfterDelay = Supabase.instance.client.auth.currentSession;
      if (sessionAfterDelay != null) {
        setState(() {
          _isTokenValid = true;
        });
        debugPrint('Recovery session found after delay');
      } else {
        Get.snackbar(
          "Error",
          "Link reset password tidak valid atau sudah kedaluwarsa. Silakan request reset password baru.",
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Get.offAllNamed('/login');
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_isTokenValid) {
      Get.snackbar(
        "Error",
        "Link reset password tidak valid. Silakan request reset password baru.",
      );
      return;
    }

    if (_newPasswordController.text.length < 8) {
      Get.snackbar("Validasi", "Password baru harus minimal 8 karakter");
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      Get.snackbar("Validasi", "Password baru dan konfirmasi tidak cocok");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _service.resetPasswordWithToken(_newPasswordController.text);

      if (mounted) {
        Get.snackbar("Success", "Password berhasil direset!");

        await Supabase.instance.client.auth.signOut();

        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Get.offAllNamed('/login');
        }
      }
    } catch (e) {
      String errorMessage = _parseError(e.toString());
      Get.snackbar("Error", errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _parseError(String error) {
    if (error.contains('Password harus minimal')) {
      return 'Password baru harus minimal 8 karakter';
    }

    if (error.contains('token') ||
        error.contains('expired') ||
        error.contains('invalid')) {
      return 'Link reset password tidak valid atau sudah kedaluwarsa. Silakan request reset password baru.';
    }

    if (error.contains('network') || error.contains('SocketException')) {
      return 'Periksa koneksi internet Anda';
    }

    return error.length > 100 ? "${error.substring(0, 100)}..." : error;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.offAllNamed('/login'),
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppColors.text,
          ),
        ),
        title: Text(
          'Reset Password',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: (isDark ? NeuDark.concave : Neu.concave).copyWith(
                  border: Border.all(
                    color: isDark
                        ? Colors.blue.withValues(alpha: 0.3)
                        : Colors.blue.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.blue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Masukkan password baru Anda. Password harus minimal 8 karakter.',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password Baru',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _newPasswordController,
                    hint: 'Min. 8 karakter',
                    icon: _showNewPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    isDark: isDark,
                    obscure: !_showNewPassword,
                    onIconTap: () {
                      setState(() => _showNewPassword = !_showNewPassword);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Konfirmasi Password Baru',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hint: 'Ulangi password baru',
                    icon: _showConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    isDark: isDark,
                    obscure: !_showConfirmPassword,
                    onIconTap: () {
                      setState(
                        () => _showConfirmPassword = !_showConfirmPassword,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const LoadingButton()
                    : ElevatedButton(
                        onPressed: _isTokenValid ? _resetPassword : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _isTokenValid ? 'Reset Password' : 'Validating...',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
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
      clipBehavior: Clip.antiAlias,
      decoration: (isDark ? NeuDark.convex : Neu.convex).copyWith(
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        textInputAction: controller == _confirmPasswordController
            ? TextInputAction.done
            : TextInputAction.next,
        onSubmitted: (_) {
          if (controller == _confirmPasswordController) {
            _resetPassword();
          }
        },
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
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/supabase_service.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/loading_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _service = SupabaseService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    // Validasi email
    if (_emailController.text.trim().isEmpty) {
      Get.snackbar("Validasi", "Email harus diisi");
      return;
    }

    if (!GetUtils.isEmail(_emailController.text.trim())) {
      Get.snackbar("Validasi", "Format email tidak valid");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _service.resetPassword(_emailController.text.trim());

      if (mounted) {
        Get.snackbar(
          "Success",
          "Link reset password telah dikirim ke email Anda. Silakan cek inbox email Anda.",
        );

        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pop(context);
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
    if (error.contains('Format email tidak valid')) {
      return 'Format email tidak valid';
    }

    if (error.contains('User not found') || error.contains('not found')) {
      return 'Email tidak terdaftar';
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
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppColors.text,
          ),
        ),
        title: Text(
          'Forgot Password',
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

              // Info
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
                        'Kami akan mengirimkan link reset password ke email Anda',
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

              // Email Field
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
                  Container(
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
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _resetPassword(),
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.text,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'name@example.com',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Reset Password Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const LoadingButton()
                    : ElevatedButton(
                        onPressed: _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Send Reset Link',
                          style: TextStyle(
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
}

import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Required for Get.snackbar()
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/loading_widget.dart';
import '../../services/sound_service.dart';
import '../../utils/constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _service = SupabaseService();

  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    // Validasi input
    if (_currentPasswordController.text.isEmpty) {
      _showError('Password saat ini harus diisi');
      return;
    }

    if (_newPasswordController.text.length < 8) {
      _showError('Password baru harus minimal 8 karakter');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('Password baru dan konfirmasi tidak cocok');
      return;
    }

    if (_currentPasswordController.text == _newPasswordController.text) {
      _showError('Password baru harus berbeda dengan password saat ini');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Verifikasi password saat ini dengan mencoba sign in
      final user = Supabase.instance.client.auth.currentUser;
      if (user?.email == null) {
        throw Exception('User tidak ditemukan');
      }

      // Coba sign in dengan email dan password saat ini untuk verifikasi
      // Kita perlu membuat instance baru agar tidak logout dari session saat ini
      final SupabaseClient tempClient = SupabaseClient(
        supabaseUrl,
        supabaseAnonKey,
      );
      
      try {
        await tempClient.auth.signInWithPassword(
          email: user!.email!,
          password: _currentPasswordController.text,
        );
        // Sign out dari temp client
        await tempClient.auth.signOut();
      } catch (e) {
        throw Exception('Password saat ini salah');
      }

      // Update password baru
      await _service.updatePassword(_newPasswordController.text);

      if (mounted) {
        // Tampilkan snackbar success
        SoundService().playSound(SoundType.success);
        Get.snackbar("Success", "Password berhasil diubah!");

        // Kembali ke halaman sebelumnya (Profile Screen)
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
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

  String _parseError(String error) {
    if (error.contains('Password saat ini salah') ||
        error.contains('Invalid login credentials')) {
      return '❌ Password saat ini salah';
    }

    if (error.contains('Password harus minimal')) {
      return '🔐 Password baru harus minimal 8 karakter';
    }

    if (error.contains('network') || error.contains('SocketException')) {
      return '❌ Periksa koneksi internet Anda';
    }

    return '⚠️ Gagal mengubah password\n\n${error.length > 100 ? "${error.substring(0, 100)}..." : error}';
  }

  void _showError(String message) {
    Get.snackbar("Error", message);
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
          onPressed: () {
            SoundService().playSound(SoundType.undo);
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppColors.text,
          ),
        ),
        title: Text(
          'Change Password',
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
                        'Password harus minimal 8 karakter',
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

              // Current Password
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password Saat Ini',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _currentPasswordController,
                    hint: 'Masukkan password saat ini',
                    icon: _showCurrentPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    isDark: isDark,
                    obscure: !_showCurrentPassword,
                    onIconTap: () {
                      SoundService().playSound(SoundType.tap);
                      setState(
                        () => _showCurrentPassword = !_showCurrentPassword,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // New Password
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

              // Confirm Password
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

              // Change Password Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const LoadingButton()
                    : ElevatedButton(
                        onPressed: _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Change Password',
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

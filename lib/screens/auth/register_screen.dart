import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';
import '../../utils/app_routes.dart';
import '../../services/supabase_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final SupabaseService _supabase = SupabaseService();

  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final username = usernameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();
    final confirm = confirmCtrl.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      Get.snackbar("Validasi", "Semua field harus diisi!");
      return;
    }
    if (!email.contains("@")) {
      Get.snackbar("Validasi", "Format email tidak valid");
      return;
    }
    if (password.length < 6) {
      Get.snackbar("Validasi", "Password minimal 6 karakter");
      return;
    }
    if (password != confirm) {
      Get.snackbar("Validasi", "Konfirmasi password tidak sesuai");
      return;
    }

    setState(() => loading = true);

    try {
      /// ‼ WAJIB 3 param karena SupabaseService kamu seperti ini
      final res = await _supabase.signUp(email, password, username);

      if (res.user == null) {
        Get.snackbar("Gagal", "Registrasi gagal");
        return;
      }

      /// ⛔ Profile TIDAK di-insert manual — trigger sudah jalan
      Get.snackbar(
        "Sukses",
        "Akun berhasil dibuat, silakan login",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _neuField(
    TextEditingController c,
    String hint, {
    bool obscure = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
          BoxShadow(
            color: Color(0xFFBEBEBE),
            offset: Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextField(
        controller: c,
        obscureText: obscure,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Register", style: AppStyle.title),
                const SizedBox(height: 28),

                _neuField(usernameCtrl, "Username"),
                const SizedBox(height: 18),

                _neuField(emailCtrl, "Email"),
                const SizedBox(height: 18),

                _neuField(passCtrl, "Password", obscure: true),
                const SizedBox(height: 18),

                _neuField(confirmCtrl, "Konfirmasi Password", obscure: true),
                const SizedBox(height: 28),

                loading
                    ? const Center(child: CircularProgressIndicator())
                    : GestureDetector(
                        onTap: _register,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.white,
                                offset: Offset(-4, -4),
                                blurRadius: 6,
                              ),
                              BoxShadow(
                                color: Color(0xFFBEBEBE),
                                offset: Offset(6, 6),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Text("Daftar", style: AppStyle.button),
                        ),
                      ),

                const SizedBox(height: 22),

                Center(
                  child: GestureDetector(
                    onTap: () => Get.offAllNamed(AppRoutes.login),
                    child: Text(
                      "Sudah punya akun? Login",
                      style: AppStyle.link,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';
import '../../widgets/neumorphic_textfield.dart';
import '../../widgets/neumorphic_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _supabase = SupabaseService();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final res = await _supabase.signIn(
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      if (res.user != null) {
        Get.snackbar('Sukses', 'Berhasil login!');
        Get.offAllNamed(AppRoutes.inbox);
      } else {
        Get.snackbar('Error', 'Email atau password salah.');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Login", style: AppStyle.title),
              const SizedBox(height: 30),

              NeumorphicTextField(controller: emailCtrl, hint: "Email"),
              const SizedBox(height: 16),

              Stack(
                children: [
                  NeumorphicTextField(
                    controller: passCtrl,
                    hint: "Password",
                    obscure: !_showPassword,
                  ),

                  Positioned(
                    right: 14,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              _isLoading
                  ? const CircularProgressIndicator()
                  : NeumorphicButton(label: "Masuk", onTap: _login),

              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.register),
                child: const Text(
                  "Belum punya akun? Daftar",
                  style: AppStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

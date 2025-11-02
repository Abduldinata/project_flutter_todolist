import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';

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

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase.signIn(
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      if (response.user != null) {
        Get.snackbar('Sukses', 'Berhasil login!');
        Get.offAllNamed(AppRoutes.home);
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
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _login, child: const Text('Login')),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.register),
              child: const Text("Belum punya akun? Daftar di sini"),
            ),
          ],
        ),
      ),
    );
  }
}

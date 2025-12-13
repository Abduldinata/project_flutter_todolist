import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ⚠️ DIAMBIL DARI FILE JSON ANDA (Tipe: Web Application)
  // Ini digunakan sebagai 'clientId' di Web, dan 'serverClientId' di Android.
  static const String _webClientId =
      '465634447182-gkgen1p8fj7bottaj291ip1g9c23fhkp.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn;

  SupabaseService() {
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: _webClientId, // Wajib untuk Android
    );
  }

  // ===============================
  // 🚀 GOOGLE SIGN IN (FIXED)
  // ===============================

  Future<AuthResponse> signInWithGoogle() async {
    try {
      // --- FLOW MOBILE (Native) ---

      // 1. Trigger Google Sign In Native
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw 'Login dibatalkan oleh user';
      }

      // 2. Ambil token dari Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Tidak dapat mengambil ID Token dari Google. Pastikan Web Client ID benar.';
      }

      // 3. Tukar token Google dengan Session Supabase
      final AuthResponse response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOutGoogle() async {
    if (!kIsWeb) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
    await _client.auth.signOut();
  }

  // ===============================
  // 👤 PROFILE FUNCTIONS
  // ===============================

  Future<Map<String, dynamic>?> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return response;
  }

  Future<void> updateProfile({
    required String username,
    String? hobby,
    String? bio,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? phone,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User belum login.');

    final updates = {
      'username': username,
      if (hobby != null) 'hobby': hobby,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth.toIso8601String().split('T')[0], // Format: YYYY-MM-DD
      if (phone != null) 'phone': phone,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _client.from('profiles').update(updates).eq('id', user.id);
  }

  // ===============================
  // 🖼️ STORAGE FUNCTIONS
  // ===============================

  Future<String> uploadImage(File file, String bucket, String fileName) async {
    final storage = _client.storage.from(bucket);
    try {
      await storage.remove([fileName]);
    } catch (_) {}
    await storage.upload(fileName, file);
    return storage.getPublicUrl(fileName);
  }

  Future<String> uploadImageBytes(
    List<int> bytes,
    String bucket,
    String fileName,
  ) async {
    final storage = _client.storage.from(bucket);
    try {
      await storage.remove([fileName]);
    } catch (_) {}
    final Uint8List uint8list = Uint8List.fromList(bytes);
    await storage.uploadBinary(fileName, uint8list);
    return storage.getPublicUrl(fileName);
  }

  // ===============================
  // 🔐 AUTH FUNCTIONS (EMAIL)
  // ===============================

  Future<AuthResponse> signUp(
    String email,
    String password,
    String username,
  ) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );

    // Fallback: Jika trigger gagal, buat profile secara manual
    if (response.user != null) {
      try {
        // Tunggu sebentar untuk trigger selesai
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Cek apakah profile sudah dibuat oleh trigger
        final profile = await getProfile();
        if (profile == null) {
          // Jika profile belum ada, buat secara manual
          await _client.from('profiles').insert({
            'id': response.user!.id,
            'username': username,
            'email': email,
            'hobby': null,
            'bio': null,
            'avatar_url': null,
            'date_of_birth': null,
            'phone': null,
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      } catch (e) {
        // Jika gagal membuat profile, log error tapi tidak throw
        // User sudah terdaftar, profile bisa dibuat nanti
        debugPrint('Warning: Failed to create profile: $e');
      }
    }

    return response;
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await signOutGoogle();
  }

  // ===============================
  // 🔑 PASSWORD FUNCTIONS
  // ===============================

  /// Update password user yang sedang login
  /// Membutuhkan password lama untuk verifikasi (opsional di Supabase)
  Future<void> updatePassword(String newPassword) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User belum login.');

    // Validasi password baru
    if (newPassword.length < 8) {
      throw Exception('Password harus minimal 8 karakter');
    }

    // Update password melalui Supabase Auth
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // ===============================
  // 📝 TASK FUNCTIONS
  // ===============================

  Future<List<Task>> getTasks() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('tasks')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).map((data) => Task.fromJson(data)).toList();
  }

  Future<void> addTask(String title, String description) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User belum login');

    await _client.from('tasks').insert({
      'user_id': user.id,
      'title': title,
      'description': description,
      'is_done': false,
    });
  }

  Future<void> updateTaskStatus(int id, bool isDone) async {
    await _client.from('tasks').update({'is_done': isDone}).eq('id', id);
  }

  Future<void> deleteTask(int id) async {
    await _client.from('tasks').delete().eq('id', id);
  }
}

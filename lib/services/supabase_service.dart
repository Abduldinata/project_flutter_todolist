import 'dart:io'; // untuk class File (mobile)
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import 'dart:typed_data';

class SupabaseService {
  // ✅ Supabase client instance
  final SupabaseClient _client = Supabase.instance.client;

  // ===============================
  // 🔹 PROFILE FUNCTIONS
  // ===============================

  // Ambil data profil user dari tabel 'profiles'
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

  // Update data profil user
  Future<void> updateProfile({
    required String username,
    String? hobby,
    String? bio,
    String? avatarUrl,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User belum login.');

    final updates = {
      'username': username,
      if (hobby != null) 'hobby': hobby,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _client.from('profiles').update(updates).eq('id', user.id);
  }

  // Upload file gambar (mobile)
  Future<String> uploadImage(File file, String bucket, String fileName) async {
    final storage = _client.storage.from(bucket);

    // Cek apakah file dengan nama yang sama sudah ada, hapus dulu biar tidak error
    try {
      await storage.remove([fileName]);
    } catch (_) {}

    await storage.upload(fileName, file);
    return storage.getPublicUrl(fileName);
  }

  // Upload file gambar (web - bytes)
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
  // 🔹 AUTH FUNCTIONS
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
    return response;
  }

  Future<AuthResponse> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ===============================
  // 🔹 TASK FUNCTIONS (TIDAK DIUBAH)
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

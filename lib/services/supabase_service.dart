import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  static const String _webClientId =
      '465634447182-gkgen1p8fj7bottaj291ip1g9c23fhkp.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn;

  SupabaseService() {
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: _webClientId, // Wajib untuk Android
    );
  }

  Future<AuthResponse> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw 'Login dibatalkan oleh user';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Tidak dapat mengambil ID Token dari Google. Pastikan Web Client ID benar.';
      }

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
      if (dateOfBirth != null)
        'date_of_birth': dateOfBirth.toIso8601String().split(
          'T',
        )[0], // Format: YYYY-MM-DD
      if (phone != null) 'phone': phone,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _client.from('profiles').update(updates).eq('id', user.id);
  }

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

    if (response.user != null) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));

        final profile = await getProfile();
        if (profile == null) {
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

  Future<void> updatePassword(String newPassword) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User belum login.');

    if (newPassword.length < 8) {
      throw Exception('Password harus minimal 8 karakter');
    }

    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> resetPasswordWithToken(String newPassword) async {
    if (newPassword.length < 8) {
      throw Exception('Password harus minimal 8 karakter');
    }

    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      throw Exception('Email harus diisi');
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      throw Exception('Format email tidak valid');
    }

    const redirectUrl = 'todolist://reset-password';

    await _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: redirectUrl,
    );
  }

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

  Future<void> updateTaskStatus(String id, bool isDone) async {
    await _client.from('tasks').update({'is_done': isDone}).eq('id', id);
  }

  Future<void> deleteTask(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }

  Future<void> deleteAccount() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User belum login.');

    try {
      await _client.from('tasks').delete().eq('user_id', user.id);
      try {
        final profile = await getProfile();
        if (profile != null && profile['avatar_url'] != null) {
          final avatarUrl = profile['avatar_url'] as String;
          final fileName = avatarUrl.split('/').last.split('?').first;
          if (fileName.isNotEmpty) {
            try {
              await _client.storage.from('avatars').remove([fileName]);
            } catch (e) {
              debugPrint('Warning: Failed to delete avatar: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('Warning: Failed to delete avatar: $e');
      }

      await _client.from('profiles').delete().eq('id', user.id);

      try {
        await _client.rpc('delete_user_account', params: {'user_id': user.id});
        debugPrint('User account deleted from auth successfully');
      } catch (e) {
        debugPrint('Warning: Could not delete user from auth: $e');
        debugPrint(
          'Note: User data has been deleted, but auth account may still exist.',
        );
        debugPrint(
          'Please create the delete_user_account function in Supabase or contact admin.',
        );
      }
      await signOut();
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }
}

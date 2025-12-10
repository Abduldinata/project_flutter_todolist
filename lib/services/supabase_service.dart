import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Untuk web, clientId harus diset
    clientId: kIsWeb
        ? '465634447182-gkgen1p8fj7bottaj291ip1g9c23fhkp.apps.googleusercontent.com' // Ganti dengan Web Client ID Anda
        : null, // Untuk Android/iOS, tidak perlu clientId
  );

  // ===============================
  // 🔹 GOOGLE SIGN IN (FIXED)
  // ===============================

  Future<AuthResponse> signInWithGoogle() async {
    try {
      // For WEB: Use Supabase OAuth flow (recommended)
      if (kIsWeb) {
        final response = await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? Uri.base.toString() : null,
        );

        if (!response) {
          throw Exception('Failed to initiate Google sign-in');
        }

        // Return empty response as the actual auth happens via redirect
        // The session will be available after redirect
        return AuthResponse(
          session: _client.auth.currentSession,
          user: _client.auth.currentUser,
        );
      }

      // For MOBILE: Use Google Sign-In package
      // 1. Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // User cancelled the sign-in
      if (googleUser == null) {
        throw Exception('sign in cancelled');
      }

      // 2. Obtain auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Check if we got the tokens
      if (googleAuth.idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      // 3. Sign in with Supabase using OAuth
      final AuthResponse response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      // 4. Check if sign in was successful
      if (response.user == null) {
        throw Exception('Failed to sign in with Supabase');
      }

      // 5. Create or update profile
      await _createOrUpdateProfileFromGoogle(
        response.user!.id,
        googleUser.email,
        googleUser.displayName ?? googleUser.email.split('@')[0],
        googleUser.photoUrl,
      );

      return response;
    } on Exception catch (e) {
      // Re-throw exceptions as-is
      rethrow;
    } catch (e) {
      // Wrap other errors in Exception
      throw Exception('Google sign-in error: $e');
    }
  }

  Future<void> _createOrUpdateProfileFromGoogle(
    String userId,
    String email,
    String username,
    String? avatarUrl,
  ) async {
    try {
      // Check if profile exists
      final existingProfile = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      final now = DateTime.now().toIso8601String();

      if (existingProfile == null) {
        // Create new profile
        await _client.from('profiles').insert({
          'id': userId,
          'email': email,
          'username': username,
          'avatar_url': avatarUrl,
          'created_at': now,
          'updated_at': now,
        });
      } else {
        // Update existing profile with Google info if needed
        await _client
            .from('profiles')
            .update({
              'avatar_url': avatarUrl ?? existingProfile['avatar_url'],
              'updated_at': now,
            })
            .eq('id', userId);
      }
    } catch (e) {
      debugPrint('Error creating/updating profile from Google: $e');
      // Don't throw - profile creation is not critical for sign-in
    }
  }

  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Error signing out from Google: $e');
    }
    await _client.auth.signOut();
  }

  // ===============================
  // 🔹 PROFILE FUNCTIONS
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
  // 🔹 TASK FUNCTIONS
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

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/profile_model.dart';
import '../services/supabase_service.dart';

class ProfileController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();

  // Observable data
  final Rx<Profile?> profile = Rx<Profile?>(null);
  final RxBool isLoading = false.obs;

  // Cache untuk profile
  DateTime? _lastLoadTime;
  static const Duration cacheDuration = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    // Load profile saat pertama kali controller dibuat
    loadProfile();
  }

  // Load profile dari server
  Future<void> loadProfile({bool forceRefresh = false}) async {
    // Jika tidak force refresh dan cache masih valid, skip loading
    if (!forceRefresh && _isCacheValid()) {
      return;
    }

    try {
      isLoading.value = true;
      final data = await _supabaseService.getProfile();
      if (data != null) {
        profile.value = Profile.fromJson(data);
        _lastLoadTime = DateTime.now();
      } else {
        profile.value = null;
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Cek apakah cache masih valid
  bool _isCacheValid() {
    if (_lastLoadTime == null) return false;
    final now = DateTime.now();
    return now.difference(_lastLoadTime!) < cacheDuration;
  }

  // Update profile
  Future<void> updateProfile({
    required String username,
    String? hobby,
    String? bio,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? phone,
  }) async {
    try {
      await _supabaseService.updateProfile(
        username: username,
        hobby: hobby,
        bio: bio,
        avatarUrl: avatarUrl,
        dateOfBirth: dateOfBirth,
        phone: phone,
      );
      // Reload profile setelah update
      await loadProfile(forceRefresh: true);
    } catch (e) {
      debugPrint("Error updating profile: $e");
      rethrow;
    }
  }

  // Refresh profile (force reload)
  Future<void> refreshProfile() async {
    await loadProfile(forceRefresh: true);
  }
}

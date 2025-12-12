import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/profile_model.dart';
import '../../services/supabase_service.dart';
import '../../theme/theme_tokens.dart';
import '../../utils/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  Profile? _profile;

  bool _isLoading = true;
  bool _isEditing = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _hobbyController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getProfile();
      if (data != null) {
        final p = Profile.fromJson(data);
        setState(() {
          _profile = p;
          _usernameController.text = p.username;
          _hobbyController.text = p.hobby ?? '';
          _bioController.text = p.bio ?? '';
        });
      }
    } catch (e) {
      Get.snackbar("Error", "$e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      late String imageUrl;

      if (kIsWeb) {
        imageUrl = await _supabaseService.uploadImageBytes(
          await picked.readAsBytes(),
          'avatars',
          fileName,
        );
      } else {
        imageUrl = await _supabaseService.uploadImage(
          File(picked.path),
          'avatars',
          fileName,
        );
      }

      await _supabaseService.updateProfile(
        username: _profile?.username ?? '',
        avatarUrl: imageUrl,
      );

      await _loadProfile();
      Get.snackbar("Sukses", "Avatar diperbarui");
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }

  Future<void> _save() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      Get.snackbar("Validasi", "Nama tidak boleh kosong");
      return;
    }

    try {
      await _supabaseService.updateProfile(
        username: username,
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        hobby: _hobbyController.text.trim().isEmpty
            ? null
            : _hobbyController.text.trim(),
      );
      setState(() => _isEditing = false);
      await _loadProfile();
      Get.snackbar("Sukses", "Profil diperbarui");
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }

  Future<void> _logout() async {
    await _supabaseService.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    final p = _profile;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 6),
              // Back button (icon only)
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back),
                    color: isDark ? AppColors.darkText : AppColors.text,
                    tooltip: 'Kembali',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  "Profile",
                  style: AppStyle.title.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // AVATAR
              GestureDetector(
                onTap: _isEditing ? _uploadAvatar : null,
                child: Container(
                  decoration: isDark ? NeuDark.convex : Neu.convex,
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        (p?.avatarUrl != null &&
                            (p!.avatarUrl ?? '').isNotEmpty)
                        ? NetworkImage(p.avatarUrl!)
                        : null,
                    backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                    child:
                        (p?.avatarUrl == null || (p!.avatarUrl ?? '').isEmpty)
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: isDark
                                ? AppColors.darkText.withAlpha(128)
                                : Colors.grey,
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // USERNAME (tampak besar saat tidak edit)
              if (!_isEditing)
                Text(
                  p?.username ?? "",
                  style: AppStyle.subtitle.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.text,
                  ),
                ),

              const SizedBox(height: 22),

              // --- FORM TILES ---
              _tile(
                "Nama",
                _usernameController,
                editable: _isEditing,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 16),
              _tile(
                "Bio",
                _bioController,
                editable: _isEditing,
                maxLines: 3,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 16),
              _tile(
                "Hobi",
                _hobbyController,
                editable: _isEditing,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 22),

              // --- BUTTONS ---
              if (_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _save,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: isDark ? NeuDark.convex : Neu.convex,
                          child: Text(
                            "Simpan",
                            textAlign: TextAlign.center,
                            style: AppStyle.normal.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isEditing = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: isDark ? NeuDark.convex : Neu.convex,
                          child: Text(
                            "Batal",
                            textAlign: TextAlign.center,
                            style: AppStyle.normal.copyWith(
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else ...[
                GestureDetector(
                  onTap: () => setState(() => _isEditing = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    decoration: isDark ? NeuDark.convex : Neu.convex,
                    child: Text(
                      "Ubah Profil",
                      textAlign: TextAlign.center,
                      style: AppStyle.normal.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _logout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    decoration: isDark ? NeuDark.convex : Neu.convex,
                    child: Text(
                      "Logout",
                      textAlign: TextAlign.center,
                      style: AppStyle.normal.copyWith(
                        color: isDark ? AppColors.darkText : AppColors.text,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(
    String title,
    TextEditingController controller, {
    bool editable = false,
    int maxLines = 1,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: isDark ? NeuDark.concave : Neu.concave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyle.smallGray.copyWith(
              color: isDark
                  ? AppColors.darkText.withAlpha(179)
                  : AppColors.gray,
            ),
          ),
          const SizedBox(height: 6),
          editable
              ? TextField(
                  controller: controller,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.darkText.withAlpha(128)
                          : Colors.grey,
                    ),
                  ),
                  style: AppStyle.normal.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.text,
                  ),
                )
              : Text(
                  controller.text.isEmpty ? "-" : controller.text,
                  style: AppStyle.normal.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.text,
                  ),
                ),
        ],
      ),
    );
  }
}

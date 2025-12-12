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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final p = _profile;

    return Scaffold(
      backgroundColor: AppColors.bg,
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
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.text,
                    tooltip: 'Kembali',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Center(child: Text("Profile", style: AppStyle.title)),
              const SizedBox(height: 30),

              // AVATAR
              GestureDetector(
                onTap: _isEditing ? _uploadAvatar : null,
                child: Container(
                  decoration: Neu.convex,
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        (p?.avatarUrl != null &&
                            (p!.avatarUrl ?? '').isNotEmpty)
                        ? NetworkImage(p.avatarUrl!)
                        : null,
                    backgroundColor: Colors.white,
                    child:
                        (p?.avatarUrl == null || (p!.avatarUrl ?? '').isEmpty)
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // USERNAME (tampak besar saat tidak edit)
              if (!_isEditing)
                Text(p?.username ?? "", style: AppStyle.subtitle),

              const SizedBox(height: 22),

              // --- FORM TILES ---
              _tile("Nama", _usernameController, editable: _isEditing),
              const SizedBox(height: 16),
              _tile("Bio", _bioController, editable: _isEditing, maxLines: 3),
              const SizedBox(height: 16),
              _tile("Hobi", _hobbyController, editable: _isEditing),
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
                          decoration: Neu.convex,
                          child: Text(
                            "Simpan",
                            textAlign: TextAlign.center,
                            style: AppStyle.normal.copyWith(
                              color: AppColors.blue,
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
                          decoration: Neu.convex,
                          child: const Text(
                            "Batal",
                            textAlign: TextAlign.center,
                            style: AppStyle.normal,
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
                    decoration: Neu.convex,
                    child: Text(
                      "Ubah Profil",
                      textAlign: TextAlign.center,
                      style: AppStyle.normal.copyWith(color: AppColors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _logout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    decoration: Neu.convex,
                    child: const Text(
                      "Logout",
                      textAlign: TextAlign.center,
                      style: AppStyle.normal,
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
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: Neu.concave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppStyle.smallGray),
          const SizedBox(height: 6),
          editable
              ? TextField(
                  controller: controller,
                  maxLines: maxLines,
                  decoration: const InputDecoration(border: InputBorder.none),
                  style: AppStyle.normal,
                )
              : Text(
                  controller.text.isEmpty ? "-" : controller.text,
                  style: AppStyle.normal,
                ),
        ],
      ),
    );
  }
}

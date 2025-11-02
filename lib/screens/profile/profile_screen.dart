import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/supabase_service.dart';
import '../../models/profile_model.dart';
import '../../utils/app_routes.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
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

  @override
  void dispose() {
    _usernameController.dispose();
    _hobbyController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getProfile();
      if (data != null) {
        final profile = Profile.fromJson(data);
        if (!mounted) return;
        setState(() {
          _profile = profile;
          _usernameController.text = profile.username;
          _hobbyController.text = profile.hobby ?? '';
          _bioController.text = profile.bio ?? '';
        });
      } else {
        Get.snackbar(
          'Info',
          'Profil belum ditemukan.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat profil: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        Get.snackbar(
          'Error',
          'Sesi tidak valid. Silakan login ulang.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      String imageUrl;

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        imageUrl = await _supabaseService.uploadImageBytes(
          bytes,
          'avatars',
          fileName,
        );
      } else {
        final file = File(picked.path);
        imageUrl = await _supabaseService.uploadImage(
          file,
          'avatars',
          fileName,
        );
      }

      await _supabaseService.updateProfile(
        username: _profile?.username ?? '',
        avatarUrl: imageUrl,
      );

      await _loadProfile();
      Get.snackbar(
        'Sukses',
        'Foto profil berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal upload avatar: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveProfile() async {
    final username = _usernameController.text.trim();
    final hobby = _hobbyController.text.trim();
    final bio = _bioController.text.trim();

    if (username.isEmpty) {
      Get.snackbar(
        'Validasi',
        'Nama tidak boleh kosong',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await _supabaseService.updateProfile(
        username: username,
        hobby: hobby.isEmpty ? null : hobby,
        bio: bio.isEmpty ? null : bio,
      );

      Get.snackbar(
        'Sukses',
        'Profil berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      if (!mounted) return;
      setState(() {
        _isEditing = false;
      });
      await _loadProfile();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan profil: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profile = _profile;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text("Profil ${profile?.username ?? 'Pengguna'}"),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
          shrinkWrap: true,
          children: [
            GestureDetector(
              onTap: _isEditing ? _uploadAvatar : null, // aktif hanya saat edit
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          (profile?.avatarUrl != null &&
                              (profile!.avatarUrl ?? '').isNotEmpty)
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      child:
                          (profile?.avatarUrl == null ||
                              (profile!.avatarUrl ?? '').isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.white,
                            )
                          : null,
                    ),

                    // Overlay kecil saat mode edit
                    if (_isEditing)
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),

                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            if (!_isEditing)
              Text(
                profile?.username ?? "Belum ada nama",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            const SizedBox(height: 24),

            // === TILES ===
            if (_isEditing)
              _buildTile(
                Icons.person,
                "Nama",
                profile?.username ?? "-",
                controller: _usernameController,
                editable: _isEditing,
              ),
            if (_isEditing) const SizedBox(height: 16),

            _buildTile(
              Icons.info,
              "Bio",
              profile?.bio ?? "-",
              controller: _bioController,
              editable: _isEditing,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            _buildTile(
              Icons.videogame_asset,
              "Hobi",
              profile?.hobby ?? "-",
              controller: _hobbyController,
              editable: _isEditing,
            ),
            const SizedBox(height: 16),

            _buildTile(Icons.email, "Email", profile?.email ?? "-"),
            const SizedBox(height: 24),

            // === BUTTONS ===
            if (_isEditing) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text("Simpan"),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => setState(() => _isEditing = false),
                icon: const Icon(Icons.cancel),
                label: const Text("Batal"),
              ),
            ] else ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit),
                label: const Text("Ubah Data Profil"),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String title,
    String subtitle, {
    TextEditingController? controller,
    bool editable = false,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: editable
            ? TextField(
                controller: controller,
                maxLines: 1,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Masukkan $title',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                ),
              )
            : Text(subtitle),
        trailing: editable ? const Icon(Icons.add_circle_outline) : null,
      ),
    );
  }
}

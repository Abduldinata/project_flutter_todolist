import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/profile_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/neumorphic_decoration.dart';

class EditProfileScreen extends StatefulWidget {
  final Profile? profile;
  final VoidCallback onProfileUpdated;

  const EditProfileScreen({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late TextEditingController _usernameController;
  late TextEditingController _hobbyController;
  late TextEditingController _bioController;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile?.username ?? '');
    _hobbyController = TextEditingController(text: widget.profile?.hobby ?? '');
    _bioController = TextEditingController(text: widget.profile?.bio ?? '');
    
    // Listen for changes
    _usernameController.addListener(_checkChanges);
    _hobbyController.addListener(_checkChanges);
    _bioController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final hasChanges = 
        _usernameController.text != (widget.profile?.username ?? '') ||
        _hobbyController.text != (widget.profile?.hobby ?? '') ||
        _bioController.text != (widget.profile?.bio ?? '');
    
    if (_hasChanges != hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  // GANTI bagian _saveProfile():
Future<void> _saveProfile() async {
  final username = _usernameController.text.trim();
  if (username.isEmpty) {
    Get.snackbar(
      "Validasi", 
      "Nama tidak boleh kosong",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  if (_isSaving) return; // ✅ Prevent double tap
  
  setState(() => _isSaving = true);
  
  try {
    await _supabaseService.updateProfile(
      username: username,
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      hobby: _hobbyController.text.trim().isEmpty ? null : _hobbyController.text.trim(),
    );

    // ✅ Panggil callback untuk refresh profile
    widget.onProfileUpdated();
    
    // ✅ Tunggu sebentar lalu back
    await Future.delayed(const Duration(milliseconds: 300));
    
    // ✅ Gunakan Navigator.pop dengan context asli
    if (mounted) {
      Navigator.of(context).pop();
    }
    
    // ✅ Show success snackbar di ProfileScreen (akan muncul otomatis)
    
  } catch (e) {
    // ✅ Show error di screen ini
    if (mounted) {
      Get.snackbar(
        "Error", 
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}

  void _handleBack() {
    if (_hasChanges && !_isSaving) {
      // Tampilkan konfirmasi jika ada perubahan
      Get.dialog(
        AlertDialog(
          title: const Text("Batal Edit?"),
          content: const Text("Ada perubahan yang belum disimpan. Yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Lanjut Edit"),
            ),
            TextButton(
              onPressed: () {
                Get.back(); // Tutup dialog
                Get.back(); // Kembali ke profile screen
              },
              child: const Text(
                "Keluar",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    } else {
      Get.back();
    }
  }

  Widget _formField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: Neu.concave(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ✅ FIXED: Header dengan back button yang berfungsi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back Button
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _handleBack,
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      decoration: Neu.convex(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                  
                  // Title
                  Text(
                    "Edit Profile",
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Loading Indicator atau placeholder
                  Container(
                    width: 40,
                    child: _isSaving 
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const SizedBox(),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Form
              _formField(
                context,
                label: "Nama",
                controller: _usernameController,
              ),
              _formField(
                context,
                label: "Bio",
                controller: _bioController,
                maxLines: 3,
              ),
              _formField(
                context,
                label: "Hobi",
                controller: _hobbyController,
              ),
              const SizedBox(height: 30),

              // Save Button
              GestureDetector(
                onTap: _isSaving ? null : _saveProfile,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity,
                  decoration: _isSaving
                      ? Neu.convex(context).copyWith(
                          color: colorScheme.onSurface.withOpacity(0.1),
                        )
                      : Neu.convex(context).copyWith(
                          boxShadow: [
                            ...Neu.convex(context).boxShadow!,
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.4),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                  child: _isSaving
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Menyimpan...",
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Text(
                            "Simpan Perubahan",
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.removeListener(_checkChanges);
    _hobbyController.removeListener(_checkChanges);
    _bioController.removeListener(_checkChanges);
    _usernameController.dispose();
    _hobbyController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
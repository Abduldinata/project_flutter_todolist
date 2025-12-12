import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/profile_model.dart';
import '../../services/supabase_service.dart';
import '../../utils/neumorphic_decoration.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getProfile();
      if (data != null && mounted) {
        setState(() => _profile = Profile.fromJson(data));
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar("Error", "$e");
      }
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

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    final p = _profile;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Get.back();
                      } else {
                        Get.offAllNamed(AppRoutes.inbox);
                      }
                    },
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
                  
                  Text(
                    "Profile",
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Edit Button - FIXED
                  GestureDetector(
                    onTap: p != null
                        ? () {
                            Get.toNamed(
                              AppRoutes.editProfile,
                              arguments: {
                                'profile': p,
                                'onProfileUpdated': _loadProfile,
                              },
                            );
                          }
                        : null,
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      decoration: Neu.convex(context),
                      child: Icon(
                        Icons.edit,
                        color: p != null
                            ? colorScheme.primary
                            : colorScheme.onSurface.withOpacity(0.3),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Avatar
              Stack(
                children: [
                  GestureDetector(
                    onTap: _uploadAvatar,
                    child: Container(
                      decoration: Neu.convex(context),
                      padding: const EdgeInsets.all(8),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: (p?.avatarUrl != null &&
                                (p!.avatarUrl ?? '').isNotEmpty)
                            ? NetworkImage(p.avatarUrl!)
                            : null,
                        backgroundColor: colorScheme.surface,
                        child: (p?.avatarUrl == null ||
                                (p!.avatarUrl ?? '').isEmpty)
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: colorScheme.onSurface.withOpacity(0.5),
                              )
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _uploadAvatar,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                p?.username ?? "User",
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (p?.bio?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    p!.bio!,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              // Info Cards
              _infoCard(
                context,
                icon: Icons.person_outline,
                title: "Nama",
                value: p?.username ?? "-",
              ),
              const SizedBox(height: 16),
              _infoCard(
                context,
                icon: Icons.description_outlined,
                title: "Bio",
                value: p?.bio?.isNotEmpty == true ? p!.bio! : "-",
              ),
              const SizedBox(height: 16),
              _infoCard(
                context,
                icon: Icons.sports_basketball_outlined,
                title: "Hobi",
                value: p?.hobby?.isNotEmpty == true ? p!.hobby! : "-",
              ),
              const SizedBox(height: 40), // ✅ Spacing tanpa info helper

              // Logout Button saja
              GestureDetector(
                onTap: _logout,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity,
                  decoration: Neu.convex(context).copyWith(
                    boxShadow: [
                      ...Neu.convex(context).boxShadow!,
                      BoxShadow(
                        color: colorScheme.error.withOpacity(0.3),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout,
                        size: 20,
                        color: colorScheme.error,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Logout",
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: Neu.concave(context),
      child: Row(
        children: [
          Icon(
            icon,
            color: colorScheme.onSurface.withOpacity(0.7),
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    color: value == "-"
                        ? colorScheme.onSurface.withOpacity(0.5)
                        : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
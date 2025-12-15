import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_service.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/task_controller.dart';
import '../../theme/theme_tokens.dart';
import '../../utils/app_routes.dart';
import '../../widgets/loading_widget.dart';
import '../../auth_storage.dart';
import '../auth/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _profileController = Get.find<ProfileController>();
  final SupabaseService _supabaseService = SupabaseService();

  bool _isEditing = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _hobbyController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    // Hanya load jika data belum ada atau cache sudah expired
    if (_profileController.profile.value == null) {
      _profileController.loadProfile().then((_) {
        _updateControllers();
      });
    } else {
      _updateControllers();
    }

    // Listen untuk perubahan profile
    ever(_profileController.profile, (_) {
      _updateControllers();
    });
  }

  void _updateControllers() {
    final p = _profileController.profile.value;
    if (p != null) {
      final user = Supabase.instance.client.auth.currentUser;
      _usernameController.text = p.username;
      _hobbyController.text = p.hobby ?? '';
      _bioController.text = p.bio ?? '';
      _emailController.text = p.email ?? user?.email ?? '';
      _phoneController.text = p.phone ?? '';
      _dateOfBirth = p.dateOfBirth;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _hobbyController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
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

      final currentProfile = _profileController.profile.value;
      if (currentProfile != null) {
        await _profileController.updateProfile(
          username: currentProfile.username,
          avatarUrl: imageUrl,
        );
      }

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
      await _profileController.updateProfile(
        username: username,
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        hobby: _hobbyController.text.trim().isEmpty
            ? null
            : _hobbyController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        dateOfBirth: _dateOfBirth,
      );
      setState(() => _isEditing = false);
      _updateControllers();
      Get.snackbar("Sukses", "Profil diperbarui");
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }

  Future<void> _handleDeleteAccount(bool isDark) async {
    // Show confirmation dialog
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text(
          "Delete Account",
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Are you sure you want to delete your account?\n\n"
          "This will permanently delete:\n"
          "• All your tasks\n"
          "• Your profile data\n"
          "• Your avatar\n\n"
          "This action cannot be undone.",
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete Account"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading dialog
    Get.dialog(
      PopScope(
        canPop: false, // Prevent back button
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Loading indicator
                CircularProgressIndicator(
                  color: AppColors.blue,
                ),
                const SizedBox(height: 20),
                // Text
                Text(
                  "Deleting account...",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );

    try {
      // 1. Delete account from Supabase (tasks, profile, avatar)
      await _supabaseService.deleteAccount();

      // 2. Clear all local storage
      await AuthStorage.logout();
      await AuthStorage.clearTasksOffline();
      await AuthStorage.clearProfileOffline();

      // 3. Clear controllers
      final taskController = Get.find<TaskController>();
      final profileController = Get.find<ProfileController>();
      taskController.clearAllData();
      profileController.clearAllData();

      // 4. Close loading dialog
      Get.back();

      // 5. Show success message and navigate to login
      Get.snackbar(
        "Account Deleted",
        "Your account has been successfully deleted.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // 6. Navigate to login screen
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed(AppRoutes.login);
      });
    } catch (e) {
      // Close loading dialog
      Get.back();

      // Show error message
      Get.snackbar(
        "Error",
        "Failed to delete account: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      if (_profileController.isLoading.value) {
        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
          body: ProfileLoading(isDark: isDark),
        );
      }

      final p = _profileController.profile.value;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.arrow_back),
                      color: isDark ? AppColors.darkText : AppColors.text,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          _isEditing ? "Edit Profile" : "Profile",
                          style: AppStyle.title.copyWith(
                            color: isDark ? AppColors.darkText : AppColors.text,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
                const SizedBox(height: 20),

                // AVATAR with camera icon overlay
                Stack(
                  alignment: Alignment.center,
                  children: [
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
                          backgroundColor: isDark
                              ? AppColors.darkCard
                              : Colors.white,
                          child:
                              (p?.avatarUrl == null ||
                                  (p!.avatarUrl ?? '').isEmpty)
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: isDark
                                      ? AppColors.darkText.withValues(
                                          alpha: 0.5,
                                        )
                                      : Colors.grey,
                                )
                              : null,
                        ),
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _uploadAvatar,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkCard
                                    : Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // USERNAME with PRO badge (optional)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      p?.username ?? "",
                      style: AppStyle.subtitle.copyWith(
                        color: isDark ? AppColors.darkText : AppColors.text,
                      ),
                    ),
                    // PRO Badge (optional - bisa diaktifkan jika ada premium)
                    // const SizedBox(width: 8),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 8,
                    //     vertical: 4,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: AppColors.blue,
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child: const Text(
                    //     'PRO',
                    //     style: TextStyle(
                    //       color: Colors.white,
                    //       fontSize: 10,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),

                if (_isEditing) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _uploadAvatar,
                    child: Text(
                      "Change Profile Photo",
                      style: TextStyle(
                        color: AppColors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // PERSONAL DETAILS Section
                _buildSectionTitle("PERSONAL DETAILS", isDark),
                const SizedBox(height: 12),
                _tile(
                  "Name",
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
                _buildDateOfBirthTile(isDark, colorScheme),
                const SizedBox(height: 32),

                // CONTACT INFO Section
                _buildSectionTitle("CONTACT INFO", isDark),
                const SizedBox(height: 12),
                _tile(
                  "Email",
                  _emailController,
                  editable: false, // Email usually not editable
                  isDark: isDark,
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 16),
                _tile(
                  "Phone",
                  _phoneController,
                  editable: _isEditing,
                  isDark: isDark,
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 32),

                // ACCOUNT Section
                _buildSectionTitle("ACCOUNT", isDark),
                const SizedBox(height: 12),
                _buildAccountOptions(isDark, colorScheme),
                const SizedBox(height: 32),

                // Save Changes Button (only when editing)
                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => setState(() => _isEditing = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      width: double.infinity,
                      decoration: isDark ? NeuDark.convex : Neu.convex,
                      child: Text(
                        "Edit Profile",
                        textAlign: TextAlign.center,
                        style: AppStyle.normal.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
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

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }

  Widget _buildDateOfBirthTile(bool isDark, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _isEditing
          ? () async {
              final picked = await showDatePicker(
                context: context,
                initialDate:
                    _dateOfBirth ??
                    DateTime.now().subtract(const Duration(days: 365 * 25)),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: isDark
                          ? colorScheme.copyWith(
                              surface: colorScheme.surface,
                              onSurface: Colors.white,
                            )
                          : colorScheme,
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() => _dateOfBirth = picked);
              }
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: isDark ? NeuDark.concave : Neu.concave,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Date of Birth",
                  style: AppStyle.smallGray.copyWith(
                    color: isDark
                        ? AppColors.darkText.withValues(alpha: 0.7)
                        : AppColors.gray,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _dateOfBirth == null
                      ? "-"
                      : "${_dateOfBirth!.day} ${_getMonthName(_dateOfBirth!.month)} ${_dateOfBirth!.year}",
                  style: AppStyle.normal.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.text,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: isDark
                  ? AppColors.darkText.withValues(alpha: 0.5)
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Widget _buildAccountOptions(bool isDark, ColorScheme colorScheme) {
    final user = Supabase.instance.client.auth.currentUser;
    final providers = user?.appMetadata != null
        ? user!.appMetadata['providers'] as List<dynamic>?
        : null;
    final linkedAccounts =
        providers
            ?.map((p) {
              final str = p.toString();
              return str.isNotEmpty
                  ? str[0].toUpperCase() + str.substring(1)
                  : str;
            })
            .join(', ') ??
        '';

    return Column(
      children: [
        _buildAccountOption(
          "Change Password",
          icon: Icons.lock_outline,
          onTap: () {
            debugPrint(
              'Change Password tapped - navigating to ${AppRoutes.changePassword}',
            );
            try {
              // Gunakan Navigator.push sebagai alternatif yang lebih reliable
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            } catch (e) {
              debugPrint('Error navigating to change password: $e');
              Get.snackbar(
                'Error',
                'Gagal membuka halaman Change Password: $e',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
          isDark: isDark,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 12),
        _buildAccountOption(
          "Linked Accounts",
          icon: Icons.link,
          trailing: Text(
            linkedAccounts.isEmpty ? "None" : linkedAccounts,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          onTap: null,
          isDark: isDark,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 12),
        _buildAccountOption(
          "Delete Account",
          icon: Icons.delete_outline,
          textColor: Colors.red,
          onTap: () => _handleDeleteAccount(isDark),
          isDark: isDark,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildAccountOption(
    String title, {
    required IconData icon,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: isDark ? NeuDark.concave : Neu.concave,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color:
                        textColor ??
                        (isDark ? AppColors.darkText : AppColors.text),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: AppStyle.normal.copyWith(
                      color:
                          textColor ??
                          (isDark ? AppColors.darkText : AppColors.text),
                    ),
                  ),
                ],
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

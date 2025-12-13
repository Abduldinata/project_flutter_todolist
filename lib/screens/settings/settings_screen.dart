import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/theme_tokens.dart';
import '../../theme/theme_controller.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../../models/profile_model.dart';
import '../home/profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeController _themeController = Get.find<ThemeController>();
  final SupabaseService _supabaseService = SupabaseService();
  final _box = GetStorage();
  
  int navIndex = 3;
  Profile? _profile;
  
  // Preferences
  bool _notificationsEnabled = true;
  String _startOfWeek = 'Monday';
  bool _soundEffectsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadPreferences();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _supabaseService.getProfile();
      if (data != null && mounted) {
        setState(() {
          _profile = Profile.fromJson(data);
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
  }

  void _loadPreferences() {
    _notificationsEnabled = _box.read('notifications_enabled') ?? true;
    _startOfWeek = _box.read('start_of_week') ?? 'Monday';
    _soundEffectsEnabled = _box.read('sound_effects_enabled') ?? false;
  }

  void _savePreference(String key, dynamic value) {
    _box.write(key, value);
  }

  Future<void> _handleLogout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabaseService.signOut();
        Get.offAllNamed(AppRoutes.login);
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to log out: ${e.toString()}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void _showStartOfWeekPicker() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: days.map((day) {
            return ListTile(
              title: Text(day),
              onTap: () {
                setState(() => _startOfWeek = day);
                _savePreference('start_of_week', day);
                Get.back();
              },
              trailing: _startOfWeek == day
                  ? Icon(Icons.check, color: AppColors.blue)
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }

  bool get isDark {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white : AppColors.text,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Settings',
                        style: AppStyle.title.copyWith(
                          color: isDark ? Colors.white : AppColors.text,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Profile Section
                    _buildProfileCard(user, scheme),
                    const SizedBox(height: 32),

                    // Personalization Section
                    _buildSectionTitle('PERSONALIZATION'),
                    const SizedBox(height: 12),
                    _buildPersonalizationCard(scheme),
                    const SizedBox(height: 32),

                    // Preferences Section
                    _buildSectionTitle('PREFERENCES'),
                    const SizedBox(height: 12),
                    _buildPreferencesCard(scheme),
                    const SizedBox(height: 32),

                    // Support & About Section
                    _buildSectionTitle('SUPPORT & ABOUT'),
                    const SizedBox(height: 12),
                    _buildSupportCard(scheme),
                    const SizedBox(height: 32),

                    // Log Out Button
                    _buildLogOutButton(),
                    const SizedBox(height: 20),

                    // Version & Copyright
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Version 2.4.0 (Build 1024)',
                            style: AppStyle.smallGray.copyWith(
                              color: isDark 
                                  ? Colors.grey[500] 
                                  : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '© 2023 TASKFLOW INC.',
                            style: AppStyle.smallGray.copyWith(
                              color: isDark 
                                  ? Colors.grey[600] 
                                  : Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        index: navIndex,
        onTap: (i) {
          if (i == navIndex) return;
          setState(() => navIndex = i);
          if (i == 0) Get.offAllNamed("/inbox");
          if (i == 1) Get.offAllNamed("/today");
          if (i == 2) Get.offAllNamed("/upcoming");
          if (i == 3) Get.offAllNamed("/settings");
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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

  Widget _buildProfileCard(User? user, ColorScheme scheme) {
    final email = user?.email ?? _profile?.email ?? 'user@example.com';
    final username = _profile?.username ?? 
        user?.userMetadata?['username']?.toString() ?? 
        'User';
    final avatarUrl = _profile?.avatarUrl;

    return GestureDetector(
      onTap: () {
        // Navigate to profile screen
        Get.to(() => const ProfileScreen());
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: isDark ? NeuDark.concave : Neu.concave,
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.blue.withOpacity(0.1),
                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null || avatarUrl.isEmpty
                      ? Text(
                          username.isNotEmpty ? username[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Name & Email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          username,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.text,
                          ),
                        ),
                      ),
                      // PRO Badge (optional - bisa diaktifkan jika ada premium)
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
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizationCard(ColorScheme scheme) {
    return Container(
      decoration: isDark ? NeuDark.concave : Neu.concave,
      child: Column(
        children: [
          // App Theme
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.dark_mode,
                  color: AppColors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'App Theme',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : AppColors.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(() {
              final currentMode = _themeController.themeMode.value;
              return SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text('Light'),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text('System'),
                  ),
                ],
                selected: {currentMode},
                onSelectionChanged: (Set<ThemeMode> newSelection) {
                  _themeController.setThemeMode(newSelection.first);
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.blue,
                  selectedForegroundColor: Colors.white,
                  backgroundColor: isDark 
                      ? AppColors.darkSurface 
                      : Colors.grey[200],
                  foregroundColor: isDark 
                      ? Colors.grey[300] 
                      : Colors.grey[700],
                ),
              );
            }),
          ),
          const Divider(height: 1),
          // Accent Color
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Colors.purple[400],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Accent Color',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : AppColors.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(ColorScheme scheme) {
    return Container(
      decoration: isDark ? NeuDark.concave : Neu.concave,
      child: Column(
        children: [
          // Notifications
          _buildPreferenceItem(
            icon: Icons.notifications,
            iconColor: Colors.red,
            title: 'Notifications',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                _savePreference('notifications_enabled', value);
              },
              activeColor: AppColors.blue,
            ),
          ),
          const Divider(height: 1),
          // Start of Week
          _buildPreferenceItem(
            icon: Icons.calendar_today,
            iconColor: Colors.green,
            title: 'Start of Week',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _startOfWeek,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
            onTap: _showStartOfWeekPicker,
          ),
          const Divider(height: 1),
          // Sound Effects
          _buildPreferenceItem(
            icon: Icons.volume_up,
            iconColor: Colors.orange,
            title: 'Sound Effects',
            trailing: Switch(
              value: _soundEffectsEnabled,
              onChanged: (value) {
                setState(() => _soundEffectsEnabled = value);
                _savePreference('sound_effects_enabled', value);
              },
              activeColor: AppColors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : AppColors.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(ColorScheme scheme) {
    return Container(
      decoration: isDark ? NeuDark.concave : Neu.concave,
      child: Column(
        children: [
          _buildSupportItem(
            icon: Icons.help_outline,
            iconColor: AppColors.blue,
            title: 'Help Center',
            onTap: () {
              Get.snackbar(
                'Info',
                'Help Center coming soon',
                backgroundColor: AppColors.blue,
                colorText: Colors.white,
              );
            },
          ),
          const Divider(height: 1),
          _buildSupportItem(
            icon: Icons.lock_outline,
            iconColor: Colors.teal,
            title: 'Privacy Policy',
            onTap: () {
              Get.snackbar(
                'Info',
                'Privacy Policy coming soon',
                backgroundColor: AppColors.blue,
                colorText: Colors.white,
              );
            },
          ),
          const Divider(height: 1),
          _buildSupportItem(
            icon: Icons.description_outlined,
            iconColor: Colors.grey,
            title: 'Terms of Service',
            onTap: () {
              Get.snackbar(
                'Info',
                'Terms of Service coming soon',
                backgroundColor: AppColors.blue,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : AppColors.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogOutButton() {
    return GestureDetector(
      onTap: _handleLogout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            'Log Out',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}

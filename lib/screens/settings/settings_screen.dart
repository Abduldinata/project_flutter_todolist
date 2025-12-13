import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';
import '../../theme/theme_controller.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeController _themeController = Get.find<ThemeController>();
  final SupabaseService _supabaseService = SupabaseService();
  int navIndex = 3;

  Future<void> _handleLogout() async {
    final confirm = await Get.dialog(
      AlertDialog(
        title: const Text("Logout"),
        content: const Text("Yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabaseService.signOut();
        Get.offAllNamed(AppRoutes.login);
        Get.snackbar(
          "Success",
          "Berhasil logout",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          "Error",
          "Gagal logout: ${e.toString()}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pengaturan",
                    style: AppStyle.title.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      decoration: (isDark ? NeuDark.convex : Neu.convex),
                      child: Icon(
                        Icons.arrow_back,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Settings List
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Dark Mode Toggle Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: (isDark ? NeuDark.concave : Neu.concave)
                            .copyWith(color: scheme.surface),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Obx(
                                  () => Icon(
                                    _themeController.isDarkMode.value
                                        ? Icons.dark_mode
                                        : Icons.light_mode,
                                    color: AppColors.blue,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Dark Mode",
                                  style: AppStyle.subtitle.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            Obx(
                              () => Switch(
                                value: _themeController.isDarkMode.value,
                                onChanged: (value) {
                                  _themeController.toggleTheme();
                                },
                                activeThumbColor: AppColors.blue,
                                activeTrackColor: AppColors.blue.withValues(alpha: 0.3),
                                inactiveThumbColor: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[400],
                                inactiveTrackColor: isDark
                                    ? Colors.grey[800]!.withValues(alpha: 0.5)
                                    : Colors.grey[300]!.withValues(alpha: 0.5),
                                trackOutlineColor: WidgetStateProperty.resolveWith(
                                  (states) => states.contains(WidgetState.selected)
                                      ? AppColors.blue
                                      : (isDark ? Colors.grey[700] : Colors.grey[400]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tentang Aplikasi Card
                      GestureDetector(
                        onTap: () {
                          Get.dialog(
                            AlertDialog(
                              title: const Text("Tentang Aplikasi"),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("To-Do List App"),
                                  SizedBox(height: 8),
                                  Text("Versi: 1.0.0"),
                                  SizedBox(height: 8),
                                  Text(
                                    "Aplikasi manajemen tugas yang membantu Anda mengorganisir aktivitas sehari-hari.",
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text("Tutup"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: (isDark ? NeuDark.concave : Neu.concave)
                              .copyWith(color: scheme.surface),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.blue,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Tentang Aplikasi",
                                    style: AppStyle.subtitle.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: scheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bantuan & Dukungan Card
                      GestureDetector(
                        onTap: () {
                          Get.snackbar(
                            "Info",
                            "Fitur bantuan akan segera hadir",
                            backgroundColor: Colors.blue,
                            colorText: Colors.white,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: (isDark ? NeuDark.concave : Neu.concave)
                              .copyWith(color: scheme.surface),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.help_outline,
                                    color: AppColors.blue,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Bantuan & Dukungan",
                                    style: AppStyle.subtitle.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: scheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Profil Card
                      GestureDetector(
                        onTap: () {
                          Get.snackbar(
                            "Info",
                            "Fitur profil akan segera hadir",
                            backgroundColor: Colors.blue,
                            colorText: Colors.white,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: (isDark ? NeuDark.concave : Neu.concave)
                              .copyWith(color: scheme.surface),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    color: AppColors.blue,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Profil",
                                    style: AppStyle.subtitle.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: scheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Export Data Card
                      GestureDetector(
                        onTap: () {
                          Get.snackbar(
                            "Info",
                            "Fitur export data akan segera hadir",
                            backgroundColor: Colors.blue,
                            colorText: Colors.white,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: (isDark ? NeuDark.concave : Neu.concave)
                              .copyWith(color: scheme.surface),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.download_outlined,
                                    color: AppColors.blue,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Export Data",
                                    style: AppStyle.subtitle.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: scheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Hapus Semua Data Card
                      GestureDetector(
                        onTap: () async {
                          final confirm = await Get.dialog(
                            AlertDialog(
                              title: const Text("Hapus Semua Data"),
                              content: const Text(
                                "Yakin ingin menghapus semua data? Tindakan ini tidak dapat dibatalkan.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(result: false),
                                  child: const Text("Batal"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Get.back(result: true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text(
                                    "Hapus",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            Get.snackbar(
                              "Info",
                              "Fitur hapus data akan segera hadir",
                              backgroundColor: Colors.blue,
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: (isDark ? NeuDark.concave : Neu.concave)
                              .copyWith(color: scheme.surface),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Hapus Semua Data",
                                    style: AppStyle.subtitle.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: scheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Logout Button
                      GestureDetector(
                        onTap: _handleLogout,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          decoration: (isDark ? NeuDark.convex : Neu.convex)
                              .copyWith(
                            color: Colors.red.withValues(alpha: 0.1),
                            boxShadow: [
                              ...?(isDark ? NeuDark.convex : Neu.convex)
                                  .boxShadow,
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.2),
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
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Logout",
                                style: AppStyle.normal.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
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
      ),

      bottomNavigationBar: BottomNav(
        index: navIndex,
        onTap: (i) {
          if (i == navIndex) return;
          setState(() => navIndex = i);
          if (i == 0) Get.offAllNamed("/inbox");
          if (i == 1) Get.offAllNamed("/today");
          if (i == 2) Get.offAllNamed("/upcoming");
          if (i == 3) Get.offAllNamed("/filter");
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_list_project/models/profile_model.dart';
import 'package:to_do_list_project/screens/edit_task/edit_task_screen.dart';
import 'package:to_do_list_project/screens/settings/settings_screen.dart';
import 'package:to_do_list_project/screens/task_detail/task_detail_screen.dart';

import 'utils/constants.dart';
import 'utils/app_routes.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

// screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/inbox_screen.dart';
import 'screens/home/today_screen.dart';
import 'screens/home/upcoming_screen.dart';
import 'screens/home/filter_screen.dart';

import 'screens/home/profile_screen.dart';
import 'screens/edit_profile/edit_profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // ✅ cek session supabase: kalau ada berarti login masih aktif
  final session = Supabase.instance.client.auth.currentSession;
  final initialRoute = (session != null) ? AppRoutes.inbox : AppRoutes.login;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());
  final String initialRoute;

  MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'To-Do List App',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),

        // ✅ route awal sesuai session
        initialRoute: initialRoute,

        getPages: [
          // AUTH
          GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
          GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),

          // HOME PAGES
          GetPage(name: AppRoutes.inbox, page: () => const InboxScreen()),
          GetPage(name: AppRoutes.today, page: () => const TodayScreen()),
          GetPage(name: AppRoutes.upcoming, page: () => const UpcomingScreen()),
          GetPage(name: AppRoutes.filter, page: () => const FilterScreen()),
          GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),

          // Profile
          GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
                    
          // Di main.dart - getPages:
          GetPage(
            name: AppRoutes.editProfile, 
            page: () {
              final args = Get.arguments;
              if (args != null && args is Map<String, dynamic>) {
                // ✅ Cast arguments dengan benar
                final profile = args['profile'] as Profile?;
                final onProfileUpdated = args['onProfileUpdated'] as VoidCallback?;
                
                if (profile != null && onProfileUpdated != null) {
                  return EditProfileScreen(
                    profile: profile,
                    onProfileUpdated: onProfileUpdated,
                  );
                }
              }
              // Fallback: redirect ke profile
              return const ProfileScreen();
            }
          ),

           // Task Detail & Edit dengan arguments
          GetPage(
            name: AppRoutes.taskDetail,
            page: () {
              final args = Get.arguments;
              if (args != null && args is Map<String, dynamic> && args.containsKey('task')) {
                return TaskDetailScreen(task: args['task']);
              }
              return const Scaffold(
                body: Center(child: Text("Tidak dapat membuka detail task")),
              );
            },
          ),
          
          GetPage(
            name: AppRoutes.editTask,
            page: () {
              final args = Get.arguments;
              if (args != null && args is Map<String, dynamic> && args.containsKey('task')) {
                return EditTaskScreen(task: args['task']);
              }
              return const Scaffold(
                body: Center(child: Text("Tidak dapat membuka edit task")),
              );
            },
          ),

        ],
      ),
    );
  }
}

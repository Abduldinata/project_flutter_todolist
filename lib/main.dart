import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'utils/constants.dart';
import 'utils/app_routes.dart';
import 'theme/theme_app.dart';
import 'theme/theme_controller.dart';

// screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/change_password_screen.dart';
import 'screens/home/inbox_screen.dart';
import 'screens/home/today_screen.dart';
import 'screens/home/upcoming_screen.dart';
import 'screens/home/filter_screen.dart';
import 'screens/settings/settings_screen.dart';

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
        themeMode: themeController.themeMode.value,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),

        // ✅ route awal sesuai session
        initialRoute: initialRoute,

        getPages: [
          // AUTH
          GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
          GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),
          GetPage(name: AppRoutes.changePassword, page: () => const ChangePasswordScreen()),

          // HOME PAGES
          GetPage(name: AppRoutes.inbox, page: () => const InboxScreen()),
          GetPage(name: AppRoutes.today, page: () => const TodayScreen()),
          GetPage(name: AppRoutes.upcoming, page: () => const UpcomingScreen()),
          GetPage(name: AppRoutes.filter, page: () => const FilterScreen()),
          GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
        ],
      ),
    );
  }
}

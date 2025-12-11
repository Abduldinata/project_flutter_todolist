import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/constants.dart';
import 'utils/app_routes.dart';
import 'utils/app_theme.dart';
import 'theme/theme_controller.dart';

// screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/inbox_screen.dart';
import 'screens/home/today_screen.dart';
import 'screens/home/upcoming_screen.dart';
import 'screens/home/filter_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'To-Do List App',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        initialRoute: AppRoutes.login,
        getPages: [
          // AUTH
          GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
          GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),

          // HOME PAGES (bottom nav)
          GetPage(name: AppRoutes.inbox, page: () => const InboxScreen()),
          GetPage(name: AppRoutes.today, page: () => const TodayScreen()),
          GetPage(name: AppRoutes.upcoming, page: () => const UpcomingScreen()),
          GetPage(name: AppRoutes.filter, page: () => const FilterScreen()),
        ],
      ),
    );
  }
}

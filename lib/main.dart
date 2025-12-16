import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

import 'utils/constants.dart';
import 'utils/app_routes.dart';
import 'theme/theme_app.dart';
import 'theme/theme_controller.dart';
import 'controllers/task_controller.dart';
import 'controllers/profile_controller.dart';
import 'services/connectivity_service.dart';
import 'services/sound_service.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/change_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/home/inbox_screen.dart';
import 'screens/home/today_screen.dart';
import 'screens/home/upcoming_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/help_center_screen.dart';
import 'screens/settings/privacy_policy_screen.dart';
import 'screens/settings/terms_of_service_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // Initialize and preload sounds
  SoundService().preloadAllSounds();

  final session = Supabase.instance.client.auth.currentSession;
  final initialRoute = (session != null) ? AppRoutes.inbox : AppRoutes.login;

  _setupDeepLinkHandler();

  runApp(MyApp(initialRoute: initialRoute));
}

void _setupDeepLinkHandler() {
  final appLinks = AppLinks();

  appLinks.uriLinkStream.listen(
    (uri) {
      debugPrint('Deep link received: $uri');

      if (uri.host == 'reset-password') {
        final token = uri.queryParameters['token'];
        final type = uri.queryParameters['type'];

        debugPrint('Reset password deep link - token: $token, type: $type');
        Get.toNamed(
          AppRoutes.resetPassword,
          arguments: {'token': token, 'type': type},
        );
      }
    },
    onError: (err) {
      debugPrint('Deep link error: $err');
    },
  );

  appLinks.getInitialLink().then((uri) {
    if (uri != null) {
      debugPrint('Initial deep link: $uri');
      if (uri.host == 'reset-password') {
        final token = uri.queryParameters['token'];
        final type = uri.queryParameters['type'];

        Future.delayed(const Duration(milliseconds: 500), () {
          Get.toNamed(
            AppRoutes.resetPassword,
            arguments: {'token': token, 'type': type},
          );
        });
      }
    }
  });
}

class MyApp extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());
  final ConnectivityService connectivityService = Get.put(
    ConnectivityService(),
  );
  final TaskController taskController = Get.put(TaskController());
  final ProfileController profileController = Get.put(ProfileController());
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

        initialRoute: initialRoute,

        getPages: [
          GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
          GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),
          GetPage(
            name: AppRoutes.changePassword,
            page: () => const ChangePasswordScreen(),
          ),
          GetPage(
            name: AppRoutes.resetPassword,
            page: () {
              final args = Get.arguments as Map<String, dynamic>?;
              return ResetPasswordScreen(
                token: args?['token'],
                type: args?['type'],
              );
            },
          ),

          GetPage(name: AppRoutes.inbox, page: () => const InboxScreen(), transition: Transition.noTransition),
          GetPage(name: AppRoutes.today, page: () => const TodayScreen(), transition: Transition.noTransition),
          GetPage(name: AppRoutes.upcoming, page: () => const UpcomingScreen(), transition: Transition.noTransition),
          GetPage(name: AppRoutes.settings, page: () => const SettingsScreen(), transition: Transition.fadeIn), // Settings boleh pakai fade
          GetPage(name: AppRoutes.helpCenter, page: () => const HelpCenterScreen()),
          GetPage(name: AppRoutes.privacyPolicy, page: () => const PrivacyPolicyScreen()),
          GetPage(name: AppRoutes.termsOfService, page: () => const TermsOfServiceScreen()),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'theme_tokens.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'themeMode';
  final _accentColorKey = 'accent_color';
  Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  Rx<Color> accentColor = AppColors.blue.obs;

  @override
  void onInit() {
    super.onInit();
    themeMode.value = _loadTheme();
    accentColor.value = _loadAccentColor();
  }

  /// Dipakai di GetMaterialApp.themeMode
  ThemeMode get theme => _loadTheme();

  ThemeMode _loadTheme() {
    final saved = _box.read(_key);
    if (saved == null) return ThemeMode.system;
    if (saved == 'light') return ThemeMode.light;
    if (saved == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  void _saveTheme(ThemeMode mode) {
    String value = 'system';
    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';
    _box.write(_key, value);
  }

  void setThemeMode(ThemeMode mode) {
    Get.changeThemeMode(mode);
    _saveTheme(mode);
    themeMode.value = mode;
  }

  void toggleTheme() {
    final current = _loadTheme();
    final newMode = current == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    setThemeMode(newMode);
  }

  bool get isDarkMode {
    final current = _loadTheme();
    if (current == ThemeMode.system) {
      return Get.context != null 
          ? MediaQuery.of(Get.context!).platformBrightness == Brightness.dark
          : false;
    }
    return current == ThemeMode.dark;
  }

  Color _loadAccentColor() {
    final saved = _box.read(_accentColorKey);
    if (saved == null) return AppColors.blue;
    return Color(saved as int);
  }

  void _saveAccentColor(Color color) {
    _box.write(_accentColorKey, color.toARGB32());
  }

  void setAccentColor(Color color) {
    _saveAccentColor(color);
    accentColor.value = color;
    // Note: AppColors.blue is const and can't be changed at runtime
    // The accentColor.value will be used throughout the app via Obx
  }

  // Helper method untuk mendapatkan accent color yang sedang aktif
  Color getAccentColor() {
    return accentColor.value;
  }
}

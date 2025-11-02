import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';
  RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _loadTheme();
  }

  ThemeMode get theme => _loadTheme() ? ThemeMode.dark : ThemeMode.light;

  bool _loadTheme() => _box.read(_key) ?? false;

  void _saveTheme(bool isDarkModeValue) => _box.write(_key, isDarkModeValue);

  void toggleTheme() {
    final newMode = !_loadTheme();
    Get.changeThemeMode(newMode ? ThemeMode.dark : ThemeMode.light);
    _saveTheme(newMode);
    isDarkMode.value = newMode;
  }
}

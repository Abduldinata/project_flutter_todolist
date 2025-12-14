import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _kLoggedIn = 'logged_in';
  static const _kToken = 'token';
  static const _kTasks = 'offline_tasks';
  static const _kTasksLastSync = 'tasks_last_sync';
  static const _kProfile = 'offline_profile';

  // ===============================
  // AUTH STORAGE
  // ===============================
  static Future<void> saveLogin({required String token}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, true);
    await prefs.setString(_kToken, token);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLoggedIn) ?? false;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLoggedIn);
    await prefs.remove(_kToken);
    await prefs.remove(_kTasks);
    await prefs.remove(_kTasksLastSync);
    await prefs.remove(_kProfile);
  }

  // ===============================
  // OFFLINE TASKS STORAGE
  // ===============================

  /// Simpan tasks ke local storage untuk offline access
  static Future<void> saveTasksOffline(List<Map<String, dynamic>> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = jsonEncode(tasks);
      await prefs.setString(_kTasks, tasksJson);
      await prefs.setString(_kTasksLastSync, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint("Error saving tasks offline: $e");
    }
  }

  /// Load tasks dari local storage
  static Future<List<Map<String, dynamic>>> loadTasksOffline() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_kTasks);
      if (tasksJson != null && tasksJson.isNotEmpty) {
        final List<dynamic> tasksList = jsonDecode(tasksJson);
        return tasksList
            .map((task) => Map<String, dynamic>.from(task))
            .toList();
      }
    } catch (e) {
      debugPrint("Error loading tasks offline: $e");
    }
    return [];
  }

  /// Get last sync time
  static Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncStr = prefs.getString(_kTasksLastSync);
      if (lastSyncStr != null) {
        return DateTime.parse(lastSyncStr);
      }
    } catch (e) {
      debugPrint("Error getting last sync time: $e");
    }
    return null;
  }

  /// Clear offline tasks
  static Future<void> clearTasksOffline() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kTasks);
      await prefs.remove(_kTasksLastSync);
    } catch (e) {
      debugPrint("Error clearing tasks offline: $e");
    }
  }

  // ===============================
  // OFFLINE PROFILE STORAGE
  // ===============================

  /// Simpan profile ke local storage untuk offline access
  static Future<void> saveProfileOffline(Map<String, dynamic> profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = jsonEncode(profile);
      await prefs.setString(_kProfile, profileJson);
    } catch (e) {
      debugPrint("Error saving profile offline: $e");
    }
  }

  /// Load profile dari local storage
  static Future<Map<String, dynamic>?> loadProfileOffline() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_kProfile);
      if (profileJson != null && profileJson.isNotEmpty) {
        return Map<String, dynamic>.from(jsonDecode(profileJson));
      }
    } catch (e) {
      debugPrint("Error loading profile offline: $e");
    }
    return null;
  }

  /// Clear offline profile
  static Future<void> clearProfileOffline() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kProfile);
    } catch (e) {
      debugPrint("Error clearing profile offline: $e");
    }
  }
}

import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme/theme_tokens.dart';

/// Utility class untuk task-related functions
/// Menghilangkan duplikasi logic task di seluruh codebase
class TaskUtils {
  /// Get category dari priority string
  /// Return: "High", "Medium", atau "Low"
  static String getCategoryFromPriority(String? priority) {
    if (priority == null) return 'Medium';
    final p = priority.toLowerCase();

    if (p == 'high' || p == 'urgent') {
      return 'High';
    } else if (p == 'medium') {
      return 'Medium';
    } else if (p == 'low') {
      return 'Low';
    }
    return 'Medium';
  }

  /// Get color untuk priority
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return Colors.red;
      case 'medium':
        return AppColors.blue;
      case 'low':
        return Colors.green;
      default:
        return AppColors.blue;
    }
  }

  /// Get label untuk priority
  static String getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return "High";
      case 'medium':
        return "Medium";
      case 'low':
        return "Low";
      default:
        return "Medium";
    }
  }

  /// Get priority info (color dan label) sebagai tuple
  static (Color, String) getPriorityInfo(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return (Colors.red, "High");
      case 'medium':
        return (AppColors.blue, "Medium");
      case 'low':
        return (Colors.green, "Low");
      default:
        return (AppColors.blue, "Medium");
    }
  }

  /// Cek apakah task sudah lewat tanggal hari ini (overdue)
  static bool isTaskOverdue(Task task) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(task.date.year, task.date.month, task.date.day);
    return taskDate.isBefore(today);
  }

  /// Cek apakah task untuk hari ini
  static bool isTodayTask(Task task) {
    final taskDate = task.date;
    final now = DateTime.now();
    return taskDate.year == now.year &&
        taskDate.month == now.month &&
        taskDate.day == now.day;
  }

  /// Cek apakah task untuk minggu depan
  static bool isNextWeekTask(Task task) {
    final taskDate = task.date;
    final now = DateTime.now();
    final nextWeekStart = now.add(Duration(days: 7 - now.weekday));
    return taskDate.isAfter(nextWeekStart.subtract(const Duration(days: 1)));
  }

  /// Cek apakah task untuk besok
  static bool isTomorrowTask(Task task) {
    final taskDate = task.date;
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    return taskDate.year == tomorrow.year &&
        taskDate.month == tomorrow.month &&
        taskDate.day == tomorrow.day;
  }
}


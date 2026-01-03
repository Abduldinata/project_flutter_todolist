import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../screens/add_task/add_task_popup.dart';

/// Extension untuk task handlers
/// Menghilangkan duplikasi handler di inbox_screen, today_screen, upcoming_screen
extension TaskHandlers on BuildContext {
  /// Handler untuk toggle task completion
  /// Menggunakan TaskController dan menampilkan error jika gagal
  Future<void> handleToggleTaskCompletion(
    String taskId,
    bool currentValue,
  ) async {
    try {
      final taskController = Get.find<TaskController>();
      await taskController.toggleTaskCompletion(taskId, currentValue);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Handler untuk add task
  /// Membuka AddTaskPopup dan menambahkan task jika berhasil
  Future<void> handleAddTask() async {
    final taskController = Get.find<TaskController>();

    final result = await Navigator.push(
      this,
      MaterialPageRoute(builder: (ctx) => const AddTaskPopup()),
    );

    if (result != null &&
        result['text'] != null &&
        result['date'] != null) {
      try {
        await taskController.addTask(
          title: result['text'].toString(),
          date: result['date'] as DateTime,
          description: result['description']?.toString(),
          priority: result['priority']?.toString(),
        );
        Get.snackbar(
          "Success",
          "Task added successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to add task: ${e.toString()}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}


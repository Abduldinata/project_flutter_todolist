import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/task_service.dart';
import '../services/connectivity_service.dart';
import '../services/sound_service.dart';
import '../services/notification_service.dart';
import '../auth_storage.dart';

class TaskController extends GetxController {
  final TaskService _taskService = TaskService();
  ConnectivityService? _connectivityService;

  final RxList<Map<String, dynamic>> allTasks = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isOfflineMode = false.obs;
  final RxString lastRefreshTime = ''.obs;

  DateTime? _lastLoadTime;
  static const Duration cacheDuration = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    _initConnectivityService();
    loadAllTasks(); // Load immediately, no delay
  }

  void _initConnectivityService() {
    try {
      _connectivityService = Get.find<ConnectivityService>();
      debugPrint("ConnectivityService found");
    } catch (e) {
      debugPrint("ConnectivityService not found, will check manually");
      // No retry delay, try to find it when needed
    }
  }

  Future<void> loadAllTasks({bool forceRefresh = false}) async {
    if (allTasks.isEmpty) {
      debugPrint("allTasks is empty, forcing load...");
      forceRefresh = true;
    }

    if (!forceRefresh && _isCacheValid() && allTasks.isNotEmpty) {
      debugPrint(
        "Cache masih valid, skip loading. Tasks count: ${allTasks.length}",
      );
      return;
    }

    _initConnectivityService();
    final isConnected = await _checkConnection();
    isOfflineMode.value = !isConnected;
    debugPrint(
      "Connection status: $isConnected, Offline mode: ${isOfflineMode.value}",
    );

    if (!isConnected) {
      debugPrint("Offline mode: Loading tasks from local storage");
      await _loadFromOffline();
      if (allTasks.isEmpty) {
        debugPrint(
          "Still empty after offline load, trying server once more...",
        );
        try {
          final fetchedTasks = await _taskService.getAllTasks();
          if (fetchedTasks.isNotEmpty) {
            allTasks.value = fetchedTasks;
            _lastLoadTime = DateTime.now();
            await AuthStorage.saveTasksOffline(fetchedTasks);
            isOfflineMode.value = false;
            debugPrint(
              "Successfully loaded ${fetchedTasks.length} tasks from server",
            );
          }
        } catch (e) {
          debugPrint("Server still unavailable: $e");
        }
      }
      return;
    }

    try {
      isLoading.value = true;
      debugPrint("Loading tasks from server...");
      final fetchedTasks = await _taskService.getAllTasks();
      debugPrint("Fetched ${fetchedTasks.length} tasks from server");

      allTasks.value = fetchedTasks;
      _lastLoadTime = DateTime.now();
      lastRefreshTime.value = DateTime.now().toString();
      await AuthStorage.saveTasksOffline(fetchedTasks);
      debugPrint("Tasks loaded successfully: ${fetchedTasks.length} tasks");
    } catch (e) {
      debugPrint("Error loading tasks from server: $e");
      isOfflineMode.value = true;
      await _loadFromOffline();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFromOffline() async {
    try {
      isLoading.value = true;
      debugPrint("Loading from offline storage...");
      final offlineTasks = await AuthStorage.loadTasksOffline();
      if (offlineTasks.isNotEmpty) {
        allTasks.value = offlineTasks;
        final lastSync = await AuthStorage.getLastSyncTime();
        if (lastSync != null) {
          lastRefreshTime.value =
              "Last sync: ${_formatDateTime(lastSync)} (Offline)";
        } else {
          lastRefreshTime.value = "Offline mode";
        }
        debugPrint("Loaded ${offlineTasks.length} tasks from offline storage");
      } else {
        if (allTasks.isEmpty) {
          allTasks.clear();
          lastRefreshTime.value = "No offline data available";
          debugPrint("No offline data available");
        } else {
          debugPrint(
            "No offline data, but keeping existing ${allTasks.length} tasks",
          );
        }
      }
    } catch (e) {
      debugPrint("Error loading offline tasks: $e");
      if (allTasks.isEmpty) {
        allTasks.clear();
        lastRefreshTime.value = "Error loading data";
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _checkConnection() async {
    if (_connectivityService != null) {
      // No delay, check immediately
      return _connectivityService!.isConnected.value;
    }
    try {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      final isConnected = result.any((r) => r != ConnectivityResult.none);
      debugPrint(
        "Connection check result: $isConnected (${result.toString()})",
      );
      return isConnected;
    } catch (e) {
      debugPrint("Error checking connection: $e");
      return false;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  bool _isCacheValid() {
    if (_lastLoadTime == null || allTasks.isEmpty) return false;
    final now = DateTime.now();
    return now.difference(_lastLoadTime!) < cacheDuration;
  }

  List<Map<String, dynamic>> getInboxTasks() {
    return allTasks.toList();
  }

  List<Map<String, dynamic>> getTodayTasks() {
    final now = DateTime.now();
    return allTasks.where((task) {
      final taskDate = _parseDate(task['date']);
      if (taskDate == null) return false;
      return taskDate.year == now.year &&
          taskDate.month == now.month &&
          taskDate.day == now.day;
    }).toList();
  }

  List<Map<String, dynamic>> getUpcomingTasks() {
    final now = DateTime.now();
    return allTasks.where((task) {
      final taskDate = _parseDate(task['date']);
      if (taskDate == null) return false;
      return taskDate.isAfter(now.subtract(const Duration(days: 1)));
    }).toList();
  }

  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    try {
      final dateStr = dateValue.toString().split('T')[0];
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    } catch (e) {
      debugPrint("Error parsing date: $e");
    }
    return null;
  }

  Future<void> toggleTaskCompletion(String taskId, bool currentValue) async {
    if (isOfflineMode.value) {
      SoundService().playSound(SoundType.error);
      Get.snackbar(
        "Offline Mode",
        "Cannot update tasks while offline. Please check your internet connection.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _taskService.updateCompleted(taskId, !currentValue);
      final taskIndex = allTasks.indexWhere(
        (task) => task['id']?.toString() == taskId,
      );
      if (taskIndex != -1) {
        allTasks[taskIndex] = {
          ...allTasks[taskIndex],
          'is_done': !currentValue,
        };
        await AuthStorage.saveTasksOffline(allTasks.toList());

        // Play sound and handle notification
        if (!currentValue) {
          // Task completed
          SoundService().playSound(SoundType.complete);
          // Cancel notification for completed task
          final taskIdInt = int.tryParse(taskId);
          if (taskIdInt != null) {
            await NotificationService().cancelNotification(taskIdInt);
          }
        } else {
          // Task uncompleted - reschedule notification if date is in future
          SoundService().playSound(SoundType.undo);
          final task = allTasks[taskIndex];
          final taskDate = _parseDate(task['date']);
          if (taskDate != null && taskDate.isAfter(DateTime.now())) {
            final taskIdInt = int.tryParse(taskId);
            if (taskIdInt != null) {
              await NotificationService().scheduleTaskNotification(
                id: taskIdInt,
                title: 'Task Reminder',
                body: task['title'] ?? 'You have a task due',
                scheduledDate: taskDate,
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error toggling task: $e");
      SoundService().playSound(SoundType.error);
      Get.snackbar(
        "Error",
        "Failed to update task: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  Future<void> addTask({
    required String title,
    required DateTime date,
    String? description,
    String? priority,
  }) async {
    try {
      await _taskService.insertTask(
        title: title,
        date: date,
        description: description,
        priority: priority,
      );
      await loadAllTasks(forceRefresh: true);

      // Play success sound
      SoundService().playSound(SoundType.addTask);

      // Schedule notification if date is in future
      if (date.isAfter(DateTime.now()) && allTasks.isNotEmpty) {
        final newTask = allTasks.firstWhere(
          (task) => task['title'] == title,
          orElse: () => {},
        );
        if (newTask.isNotEmpty) {
          final taskId = newTask['id'];
          if (taskId != null) {
            final taskIdInt = int.tryParse(taskId.toString());
            if (taskIdInt != null) {
              await NotificationService().scheduleTaskNotification(
                id: taskIdInt,
                title: 'Task Reminder',
                body: title,
                scheduledDate: date,
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error adding task: $e");
      SoundService().playSound(SoundType.error);
      Get.snackbar(
        "Error",
        "Failed to add task: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  Future<void> updateTask({
    required String taskId,
    String? title,
    DateTime? date,
    String? description,
    String? priority,
  }) async {
    if (isOfflineMode.value) {
      SoundService().playSound(SoundType.error);
      Get.snackbar(
        "Offline Mode",
        "Cannot update tasks while offline. Please check your internet connection.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Update task di server
      await _taskService.updateTask(
        taskId: taskId,
        title: title,
        date: date,
        description: description,
        priority: priority,
      );

      // Reload tasks after update
      await loadAllTasks(forceRefresh: true);
      SoundService().playSound(SoundType.success);

      // Update notification if date changed and is in future
      if (date != null && date.isAfter(DateTime.now())) {
        final taskIdInt = int.tryParse(taskId);
        if (taskIdInt != null) {
          await NotificationService().scheduleTaskNotification(
            id: taskIdInt,
            title: 'Task Reminder',
            body: title ?? 'You have a task due',
            scheduledDate: date,
          );
        }
      } else if (date != null && date.isBefore(DateTime.now())) {
        // Cancel notification if date is in the past
        final taskIdInt = int.tryParse(taskId);
        if (taskIdInt != null) {
          await NotificationService().cancelNotification(taskIdInt);
        }
      }
    } catch (e) {
      debugPrint("Error updating task: $e");
      SoundService().playSound(SoundType.error);
      Get.snackbar(
        "Error",
        "Failed to update task: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    if (isOfflineMode.value) {
      SoundService().playSound(SoundType.error);
      Get.snackbar(
        "Offline Mode",
        "Cannot delete tasks while offline. Please check your internet connection.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _taskService.deleteTask(taskId);
      allTasks.removeWhere((task) => task['id']?.toString() == taskId);
      await AuthStorage.saveTasksOffline(allTasks.toList());

      // Play delete sound
      SoundService().playSound(SoundType.delete);

      // Cancel notification for deleted task
      final taskIdInt = int.tryParse(taskId);
      if (taskIdInt != null) {
        await NotificationService().cancelNotification(taskIdInt);
      }
    } catch (e) {
      debugPrint("Error deleting task: $e");
      SoundService().playSound(SoundType.error);
      Get.snackbar(
        "Error",
        "Failed to delete task: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  Future<void> refreshTasks() async {
    await loadAllTasks(forceRefresh: true);
  }

  void clearAllData() {
    allTasks.clear();
    isLoading.value = false;
    isOfflineMode.value = false;
    lastRefreshTime.value = '';
    _lastLoadTime = null;
  }
}

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/task_service.dart';
import '../services/connectivity_service.dart';
import '../auth_storage.dart';

class TaskController extends GetxController {
  final TaskService _taskService = TaskService();
  ConnectivityService? _connectivityService;

  // Observable data
  final RxList<Map<String, dynamic>> allTasks = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isOfflineMode = false.obs;
  final RxString lastRefreshTime = ''.obs;

  // Cache untuk filtered tasks
  DateTime? _lastLoadTime;
  static const Duration cacheDuration = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    // Coba dapatkan ConnectivityService jika sudah diinisialisasi
    _initConnectivityService();
    // Load tasks saat pertama kali controller dibuat
    // Delay sedikit untuk memastikan semua service sudah siap
    Future.delayed(const Duration(milliseconds: 300), () {
      loadAllTasks();
    });
  }

  // Initialize ConnectivityService dengan retry
  void _initConnectivityService() {
    try {
      _connectivityService = Get.find<ConnectivityService>();
      debugPrint("ConnectivityService found");
    } catch (e) {
      debugPrint("ConnectivityService not found, will check manually");
      // Retry setelah delay
      Future.delayed(const Duration(milliseconds: 200), () {
        try {
          _connectivityService = Get.find<ConnectivityService>();
          debugPrint("ConnectivityService found on retry");
        } catch (e2) {
          debugPrint("ConnectivityService still not found after retry");
        }
      });
    }
  }

  // Load semua tasks dari server atau offline storage
  Future<void> loadAllTasks({bool forceRefresh = false}) async {
    // Jika allTasks kosong, selalu force load
    if (allTasks.isEmpty) {
      debugPrint("allTasks is empty, forcing load...");
      forceRefresh = true;
    }

    // Jika tidak force refresh dan cache masih valid, skip loading
    if (!forceRefresh && _isCacheValid() && allTasks.isNotEmpty) {
      debugPrint(
        "Cache masih valid, skip loading. Tasks count: ${allTasks.length}",
      );
      return;
    }

    // Pastikan ConnectivityService sudah di-init
    _initConnectivityService();

    // Cek koneksi internet
    final isConnected = await _checkConnection();
    isOfflineMode.value = !isConnected;
    debugPrint(
      "Connection status: $isConnected, Offline mode: ${isOfflineMode.value}",
    );

    // Jika offline, load dari local storage
    if (!isConnected) {
      debugPrint("Offline mode: Loading tasks from local storage");
      await _loadFromOffline();
      // Jika masih kosong setelah load offline, coba load dari server sekali lagi (mungkin koneksi kembali)
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

    // Jika online, coba load dari server
    try {
      isLoading.value = true;
      debugPrint("Loading tasks from server...");
      final fetchedTasks = await _taskService.getAllTasks();
      debugPrint("Fetched ${fetchedTasks.length} tasks from server");

      // Update tasks bahkan jika empty (bisa jadi user memang belum punya task)
      allTasks.value = fetchedTasks;
      _lastLoadTime = DateTime.now();
      lastRefreshTime.value = DateTime.now().toString();

      // Simpan ke offline storage (bahkan jika empty)
      await AuthStorage.saveTasksOffline(fetchedTasks);
      debugPrint("Tasks loaded successfully: ${fetchedTasks.length} tasks");
    } catch (e) {
      debugPrint("Error loading tasks from server: $e");
      // Jika error, coba load dari offline storage
      isOfflineMode.value = true;
      await _loadFromOffline();
    } finally {
      isLoading.value = false;
    }
  }

  // Load tasks dari offline storage
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
        // Jika tidak ada offline data dan allTasks juga kosong, set empty
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
      // Jangan clear jika sudah ada data
      if (allTasks.isEmpty) {
        allTasks.clear();
        lastRefreshTime.value = "Error loading data";
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Cek koneksi internet
  Future<bool> _checkConnection() async {
    // Coba gunakan ConnectivityService jika tersedia
    if (_connectivityService != null) {
      // Tunggu sedikit untuk memastikan ConnectivityService sudah initialized
      await Future.delayed(const Duration(milliseconds: 100));
      return _connectivityService!.isConnected.value;
    }
    // Fallback: cek manual
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
      // Jika error, anggap offline dan load dari cache
      return false;
    }
  }

  // Format datetime untuk display
  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  // Cek apakah cache masih valid
  bool _isCacheValid() {
    // Jika belum pernah load atau allTasks kosong, cache tidak valid
    if (_lastLoadTime == null || allTasks.isEmpty) return false;
    final now = DateTime.now();
    return now.difference(_lastLoadTime!) < cacheDuration;
  }

  // Get tasks untuk inbox (semua tasks)
  List<Map<String, dynamic>> getInboxTasks() {
    return allTasks.toList();
  }

  // Get tasks untuk today (tasks dengan date hari ini)
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

  // Get upcoming tasks
  List<Map<String, dynamic>> getUpcomingTasks() {
    final now = DateTime.now();
    return allTasks.where((task) {
      final taskDate = _parseDate(task['date']);
      if (taskDate == null) return false;
      return taskDate.isAfter(now.subtract(const Duration(days: 1)));
    }).toList();
  }

  // Parse date helper
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

  // Toggle task completion (disabled saat offline)
  Future<void> toggleTaskCompletion(String taskId, bool currentValue) async {
    if (isOfflineMode.value) {
      Get.snackbar(
        "Offline Mode",
        "Cannot update tasks while offline. Please check your internet connection.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _taskService.updateCompleted(taskId, !currentValue);
      // Update local data tanpa reload semua
      final taskIndex = allTasks.indexWhere(
        (task) => task['id']?.toString() == taskId,
      );
      if (taskIndex != -1) {
        allTasks[taskIndex] = {
          ...allTasks[taskIndex],
          'is_done': !currentValue,
        };
        // Update offline storage juga
        await AuthStorage.saveTasksOffline(allTasks.toList());
      }
    } catch (e) {
      debugPrint("Error toggling task: $e");
      Get.snackbar(
        "Error",
        "Failed to update task: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  // Add new task
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
      // Reload tasks setelah add
      await loadAllTasks(forceRefresh: true);
    } catch (e) {
      debugPrint("Error adding task: $e");
      Get.snackbar(
        "Error",
        "Failed to add task: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  // Update task (disabled saat offline)
  Future<void> updateTask({
    required String taskId,
    String? title,
    DateTime? date,
    String? description,
    String? priority,
  }) async {
    if (isOfflineMode.value) {
      Get.snackbar(
        "Offline Mode",
        "Cannot update tasks while offline. Please check your internet connection.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Update via service
      // Note: Anda perlu menambahkan method updateTask di TaskService jika belum ada
      await loadAllTasks(forceRefresh: true);
    } catch (e) {
      debugPrint("Error updating task: $e");
      Get.snackbar(
        "Error",
        "Failed to update task: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  // Delete task (disabled saat offline)
  Future<void> deleteTask(String taskId) async {
    if (isOfflineMode.value) {
      Get.snackbar(
        "Offline Mode",
        "Cannot delete tasks while offline. Please check your internet connection.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _taskService.deleteTask(taskId);
      // Remove dari local data
      allTasks.removeWhere((task) => task['id']?.toString() == taskId);
      // Update offline storage
      await AuthStorage.saveTasksOffline(allTasks.toList());
    } catch (e) {
      debugPrint("Error deleting task: $e");
      Get.snackbar(
        "Error",
        "Failed to delete task: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  // Refresh tasks (force reload)
  Future<void> refreshTasks() async {
    await loadAllTasks(forceRefresh: true);
  }

  // Clear all data (untuk logout)
  void clearAllData() {
    allTasks.clear();
    isLoading.value = false;
    isOfflineMode.value = false;
    lastRefreshTime.value = '';
    _lastLoadTime = null;
  }
}

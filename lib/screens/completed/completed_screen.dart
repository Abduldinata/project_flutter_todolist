// screens/completed/completed_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/task_tile.dart';
import '../../services/task_service.dart';

class CompletedScreen extends StatefulWidget {
  const CompletedScreen({super.key});

  @override
  State<CompletedScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  final TaskService _taskService = TaskService();
  List<Map<String, dynamic>> tasks = [];
  bool loading = true;

// completed_screen.dart - Update line 25
Future<void> loadTasks() async {
  setState(() => loading = true);
  try {
    // COBA DUA OPTION INI:
    // Option 1: Jika fungsi namanya getCompletedTasks
    // final fetchedTasks = await _taskService.getCompletedTasks();
    
    // Option 2: Jika fungsi namanya getCompleted (yang ada di kode sebelumnya)
    final fetchedTasks = await _taskService.getCompleted();
    
    setState(() => tasks = fetchedTasks);
  } catch (e) {
    debugPrint("Error loading completed tasks: $e");
    Get.snackbar(
      "Error",
      "Gagal memuat tasks: ${e.toString()}",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
  setState(() => loading = false);
}

  Future<void> _toggleTaskCompletion(String taskId, bool currentValue) async {
    try {
      await _taskService.updateCompleted(taskId, !currentValue);
      await loadTasks();
    } catch (e) {
      Get.snackbar("Error", "Gagal update: $e");
    }
  }

  Future<void> _deleteTask(String taskId, String title) async {
    final confirm = await Get.dialog(
      AlertDialog(
        title: const Text("Hapus Task"),
        content: Text("Yakin hapus '$title'?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _taskService.deleteTask(taskId);
        await loadTasks();
        Get.snackbar("Success", "Task berhasil dihapus");
      } catch (e) {
        Get.snackbar("Error", "Gagal menghapus: $e");
      }
    }
  }

  Future<void> _deleteAllCompleted() async {
    final confirm = await Get.dialog(
      AlertDialog(
        title: const Text("Hapus Semua"),
        content: const Text("Yakin hapus semua task yang sudah selesai?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus Semua", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        for (var task in tasks) {
          final taskId = task['id']?.toString();
          if (taskId != null) {
            await _taskService.deleteTask(taskId);
          }
        }
        await loadTasks();
        Get.snackbar("Success", "Semua task selesai dihapus");
      } catch (e) {
        Get.snackbar("Error", "Gagal menghapus: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text("Completed Tasks", style: AppStyle.title),
        actions: [
          if (tasks.isNotEmpty)
            IconButton(
              onPressed: _deleteAllCompleted,
              icon: const Icon(Icons.delete_sweep),
              tooltip: "Hapus Semua",
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    offset: const Offset(-4, -4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: const Color(0xFFBEBEBE),
                    offset: const Offset(4, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.check_circle,
                    value: tasks.length.toString(),
                    label: "Total Selesai",
                    color: Colors.green,
                  ),
                  _buildStatItem(
                    icon: Icons.timelapse,
                    value: _getOldestCompletedDate(),
                    label: "Terlama",
                    color: Colors.orange,
                  ),
                ],
              ),
            ),

            // Task List
            Expanded(
              child: _buildTaskList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(height: 8),
        Text(value, style: AppStyle.subtitle.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(label, style: AppStyle.smallGray),
      ],
    );
  }

  Widget _buildTaskList() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              "Belum ada task yang selesai",
              style: AppStyle.smallGray,
            ),
            const SizedBox(height: 8),
            Text(
              "Selesaikan task dari Today atau Upcoming",
              style: AppStyle.smallGray.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (_, index) {
        final task = tasks[index];
        
        return TaskTile(
          task: task,
          onToggleCompletion: (taskId, currentValue) => 
              _toggleTaskCompletion(taskId, currentValue),
          onDelete: (taskId, title) => _deleteTask(taskId, title),
          // ✅ Biarkan null untuk default behavior
          onTap: null,
        );
      },
    );
  }

  String _getOldestCompletedDate() {
    if (tasks.isEmpty) return "-";
    
    DateTime? oldestDate;
    for (var task in tasks) {
      final dateStr = task['updated_at'] ?? task['created_at'];
      if (dateStr != null) {
        try {
          final date = DateTime.parse(dateStr);
          if (oldestDate == null || date.isBefore(oldestDate)) {
            oldestDate = date;
          }
        } catch (e) {
          continue;
        }
      }
    }
    
    return oldestDate != null 
        ? "${oldestDate.day}/${oldestDate.month}"
        : "-";
  }
}
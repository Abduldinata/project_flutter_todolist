import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/add_task_button.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/task_tile.dart';
import '../../services/task_service.dart';
import '../search/search_popup.dart';
import 'profile_screen.dart';
import '../add_task/add_task_popup.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final TaskService _taskService = TaskService();
  List<Map<String, dynamic>> allTasks = [];
  bool loading = true;
  int navIndex = 0;

  Future<void> loadTasks() async {
    setState(() => loading = true);
    try {
      final fetchedTasks = await _taskService.getAllTasks();
      setState(() => allTasks = fetchedTasks);
    } catch (e) {
      debugPrint("Error loading inbox tasks: $e");
      Get.snackbar(
        "Error",
        "Gagal memuat tasks: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _toggleTaskCompletion(String taskId, bool currentValue) async {
    try {
      await _taskService.updateCompleted(taskId, !currentValue);
      await loadTasks();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal update: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
        Get.snackbar(
          "Success",
          "Task berhasil dihapus",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          "Error",
          "Gagal menghapus: ${e.toString()}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // Helper untuk cek apakah task hari ini (lebih aman: parse YYYY-MM-DD saja)
  bool _isTodayTask(Map<String, dynamic> task) {
    try {
      final taskDateStr = task['date']?.toString() ?? '';
      if (taskDateStr.isEmpty) return false;

      final key = taskDateStr.split('T').first; // YYYY-MM-DD
      final parts = key.split('-');
      if (parts.length != 3) return false;

      final taskDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final now = DateTime.now();

      return taskDate.year == now.year &&
          taskDate.month == now.month &&
          taskDate.day == now.day;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Filter tasks berdasarkan kategori
    final todayTasks = allTasks
        .where(
          (task) => _isTodayTask(task) && (task['is_done'] ?? false) == false,
        )
        .toList();

    final historyTasks = allTasks
        .where((task) => (task['is_done'] ?? false) == true)
        .toList();

    final otherTasks = allTasks
        .where(
          (task) => !_isTodayTask(task) && (task['is_done'] ?? false) == false,
        )
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Top bar: title + icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Inbox",
                    style: AppStyle.title.copyWith(color: scheme.onSurface),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (ctx) => const SearchPopup(),
                          );
                        },
                        icon: Icon(
                          Icons.search,
                          size: 26,
                          color: scheme.onSurface,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.to(() => const ProfileScreen()),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: scheme.surface,
                          child: Icon(
                            Icons.person,
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Loading indicator
              if (loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (allTasks.isEmpty)
                // Empty state
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: scheme.onSurface.withValues(alpha: 0.35),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Inbox kosong",
                          style: AppStyle.smallGray.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tambahkan task pertama kamu",
                          style: AppStyle.smallGray.copyWith(
                            fontSize: 12,
                            color: scheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Task List
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Today Section
                        if (todayTasks.isNotEmpty) ...[
                          _buildSectionHeader(
                            context,
                            "Hari Ini",
                            todayTasks.length,
                          ),
                          ...todayTasks.map(
                            (task) => TaskTile(
                              task: task,
                              onToggleCompletion: _toggleTaskCompletion,
                              onDelete: _deleteTask,
                              showDate: false,
                              compactMode: false,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // History/Completed Section
                        if (historyTasks.isNotEmpty) ...[
                          _buildSectionHeader(
                            context,
                            "History (Selesai)",
                            historyTasks.length,
                          ),
                          ...historyTasks.map(
                            (task) => TaskTile(
                              task: task,
                              onToggleCompletion: _toggleTaskCompletion,
                              onDelete: _deleteTask,
                              showDate: true,
                              compactMode: true,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Upcoming/Other Tasks
                        if (otherTasks.isNotEmpty) ...[
                          _buildSectionHeader(
                            context,
                            "Lainnya",
                            otherTasks.length,
                          ),
                          ...otherTasks.map(
                            (task) => TaskTile(
                              task: task,
                              onToggleCompletion: _toggleTaskCompletion,
                              onDelete: _deleteTask,
                              showDate: true,
                              compactMode: false,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      floatingActionButton: AddTaskButton(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const AddTaskPopup()),
          );

          if (result != null &&
              result['text'] != null &&
              result['date'] != null) {
            try {
              await _taskService.insertTask(
                title: result['text'].toString(),
                date: result['date'] as DateTime,
                description: result['description']?.toString(),
                priority: result['priority']?.toString(),
              );
              await loadTasks();
              Get.snackbar(
                "Success",
                "Task berhasil ditambahkan",
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            } catch (e) {
              Get.snackbar(
                "Error",
                "Gagal menambahkan task: ${e.toString()}",
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          }
        },
      ),

      bottomNavigationBar: BottomNav(
        index: navIndex,
        onTap: (i) {
          if (i == navIndex) return;
          setState(() => navIndex = i);
          if (i == 1) Get.offAllNamed("/today");
          if (i == 2) Get.offAllNamed("/upcoming");
          if (i == 3) Get.offAllNamed("/filter");
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: AppStyle.subtitle.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: AppStyle.smallGray.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

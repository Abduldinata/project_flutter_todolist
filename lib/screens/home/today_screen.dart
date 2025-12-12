import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/add_task_button.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/task_tile.dart';
import '../../services/task_service.dart';
import '../completed/completed_screen.dart';
import '../add_task/add_task_popup.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final TaskService _taskService = TaskService();
  List<Map<String, dynamic>> tasks = [];
  bool loading = true;
  int navIndex = 1;

  Future<void> loadTasks() async {
    setState(() => loading = true);
    try {
      final fetchedTasks = await _taskService.getTasksByDate(DateTime.now());
      debugPrint("DEBUG Tasks: ${fetchedTasks.length} items");
      setState(() => tasks = fetchedTasks);
    } catch (e) {
      debugPrint("Error loading tasks: $e");
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

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final DateTime now = DateTime.now();
    final String formatted =
        "${now.day} ${_month(now.month)} · ${_weekday(now.weekday)}";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today",
                    style: AppStyle.title.copyWith(color: scheme.onSurface),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const CompletedScreen()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Completed",
                            style: AppStyle.normal.copyWith(
                              color: scheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  formatted,
                  style: AppStyle.smallGray.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // TASK LIST
              Expanded(child: _buildTaskList()),
            ],
          ),
        ),
      ),

      // ADD TASK BUTTON
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

      // BOTTOM NAV
      bottomNavigationBar: BottomNav(
        index: navIndex,
        onTap: (i) {
          if (i == navIndex) return;
          setState(() => navIndex = i);
          if (i == 0) Get.offAllNamed("/inbox");
          if (i == 2) Get.offAllNamed("/upcoming");
          if (i == 3) Get.offAllNamed("/filter");
        },
      ),
    );
  }

  Widget _buildTaskList() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
              color: scheme.onSurface.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            Text(
              "Belum ada tugas untuk hari ini",
              style: AppStyle.smallGray.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tambahkan tugas baru dengan tombol +",
              style: AppStyle.smallGray.copyWith(
                fontSize: 12,
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
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
          showDate: false,
          compactMode: false,
        );
      },
    );
  }

  // FORMAT NAMA HARI & BULAN
  String _weekday(int d) {
    const days = [
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jumat",
      "Sabtu",
      "Minggu",
    ];
    return days[d - 1];
  }

  String _month(int m) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];
    return months[m - 1];
  }
}

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadTasks();
    });
  }

  Future<void> loadTasks() async {
    if (!mounted) return;

    setState(() => loading = true);
    try {
      final fetchedTasks = await _taskService.getTasksByDate(DateTime.now());
      if (!mounted) return;
      setState(() => tasks = fetchedTasks);
    } catch (e) {
      debugPrint("Error loading tasks: $e");
      if (!mounted) return;
      Get.snackbar(
        "Error",
        "Gagal memuat tasks: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (!mounted) return;
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
    final confirm = await Get.dialog<bool>(
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
          duration: const Duration(seconds: 2),
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final DateTime now = DateTime.now();
    final String formatted =
        "${now.day} ${_month(now.month)} ${now.year} · ${_weekday(now.weekday)}";

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today",
                        style: AppStyle.title.copyWith(color: scheme.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatted,
                        style: AppStyle.smallGray.copyWith(
                          color: scheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const CompletedScreen()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.12),
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Progress Indicator
              if (tasks.isNotEmpty) ...[
                _buildProgressIndicator(),
                const SizedBox(height: 20),
              ],

              // TASK LIST
              Expanded(
                child: RefreshIndicator(
                  onRefresh: loadTasks,
                  child: _buildTaskList(),
                ),
              ),
            ],
          ),
        ),
      ),

      // ADD TASK BUTTON
      floatingActionButton: AddTaskButton(
        onTap: () async {
          final result = await Get.to<Map<String, dynamic>>(
            () => const AddTaskPopup(),
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
                duration: const Duration(seconds: 2),
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
          switch (i) {
            case 0:
              Get.offAllNamed("/inbox");
              break;
            case 2:
              Get.offAllNamed("/upcoming");
              break;
            case 3:
              Get.offAllNamed("/filter");
              break;
            default:
              Get.offAllNamed("/today");
          }
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final completedCount = tasks
        .where((task) => task['is_done'] == true)
        .length;
    final totalCount = tasks.length;
    final percentage = totalCount > 0 ? (completedCount / totalCount) : 0.0;

    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Progress Hari Ini",
              style: AppStyle.subtitle.copyWith(color: scheme.onSurface),
            ),
            Text(
              "${(percentage * 100).toInt()}%",
              style: AppStyle.normal.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: scheme.surface,
          color: scheme.primary,
          borderRadius: BorderRadius.circular(10),
          minHeight: 10,
        ),
        const SizedBox(height: 8),
        Text(
          "$completedCount dari $totalCount task selesai",
          style: AppStyle.smallGray.copyWith(
            color: scheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList() {
    final scheme = Theme.of(context).colorScheme;

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
              color: scheme.onSurface.withOpacity(0.35),
            ),
            const SizedBox(height: 16),
            Text(
              "Belum ada tugas untuk hari ini",
              style: AppStyle.subtitle.copyWith(
                color: scheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Tambahkan tugas baru dengan tombol + di bawah",
                style: AppStyle.smallGray.copyWith(
                  color: scheme.onSurface.withOpacity(0.55),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (_, index) {
        final task = tasks[index];
        return TaskTile(
          task: task,
          onToggleCompletion: _toggleTaskCompletion,
          onDelete: _deleteTask,
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

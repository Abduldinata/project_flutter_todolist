import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/add_task_button.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/task_tile.dart';
import '../../services/task_service.dart';
import '../add_task/add_task_popup.dart';

class UpcomingScreen extends StatefulWidget {
  const UpcomingScreen({super.key});

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  final TaskService _taskService = TaskService();

  List<Map<String, dynamic>> tasks = [];
  List<DateTime> upcomingDates = []; // daftar tanggal unik dari tasks
  bool loading = true;
  int navIndex = 2;

  Future<void> loadTasks() async {
    setState(() => loading = true);
    try {
      final fetchedTasks = await _taskService.getUpcomingTasks();

      // ekstrak tanggal unik (tanpa setState di dalam helper)
      final dates = _extractUniqueDates(fetchedTasks);

      setState(() {
        tasks = fetchedTasks;
        upcomingDates = dates;
      });
    } catch (e) {
      debugPrint("Error loading upcoming tasks: $e");
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

  // Ekstrak tanggal unik dari tasks (lebih aman, tidak memanggil setState)
  List<DateTime> _extractUniqueDates(List<Map<String, dynamic>> taskList) {
    final Set<String> dateKeys = {};
    final List<DateTime> dates = [];

    for (final task in taskList) {
      final raw = task['date']?.toString();
      if (raw == null || raw.isEmpty) continue;

      // Kunci unik tanggal (ambil YYYY-MM-DD saja)
      final key = raw.split('T').first;

      if (!dateKeys.contains(key)) {
        dateKeys.add(key);
        try {
          // Parse aman untuk "YYYY-MM-DD"
          final parts = key.split('-');
          if (parts.length == 3) {
            final y = int.parse(parts[0]);
            final m = int.parse(parts[1]);
            final d = int.parse(parts[2]);
            dates.add(DateTime(y, m, d));
          }
        } catch (e) {
          debugPrint("Error parsing date: $raw");
        }
      }
    }

    dates.sort((a, b) => a.compareTo(b));
    return dates;
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
    final isDark = theme.brightness == Brightness.dark;

    final bg = theme.scaffoldBackgroundColor;

    // Shadow neumorphic adaptif (dark/light)
    final shadowLight = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : Colors.white.withValues(alpha: 0.9);

    final shadowDark = isDark
        ? Colors.black.withValues(alpha: 0.80)
        : const Color(0xFFBEBEBE).withValues(alpha: 0.9);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Upcoming",
                style: AppStyle.title.copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: 10),

              // Dynamic Dates Bar
              if (upcomingDates.isNotEmpty) ...[
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: upcomingDates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final d = upcomingDates[i];

                      return Container(
                        width: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: shadowLight,
                              offset: const Offset(-3, -3),
                              blurRadius: 6,
                            ),
                            BoxShadow(
                              color: shadowDark,
                              offset: const Offset(4, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              d.day.toString(),
                              style: AppStyle.normal.copyWith(
                                color: scheme.onSurface,
                              ),
                            ),
                            Text(
                              _monthShort(d.month),
                              style: TextStyle(
                                fontSize: 10,
                                color: scheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              Text(
                "Tugas yang akan datang",
                style: AppStyle.subtitle.copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: 12),

              Expanded(child: _buildTaskList()),
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
          if (i == 0) Get.offAllNamed("/inbox");
          if (i == 1) Get.offAllNamed("/today");
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
              Icons.calendar_today_outlined,
              size: 64,
              color: scheme.onSurface.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            Text(
              "Belum ada tugas upcoming",
              style: AppStyle.smallGray.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tambah task dengan tanggal besok atau seterusnya",
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
          showDate: true,
          compactMode: false,
        );
      },
    );
  }

  String _monthShort(int m) {
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

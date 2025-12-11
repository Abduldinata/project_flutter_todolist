import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/colors.dart';
import '../../utils/app_style.dart';
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
  List<DateTime> upcomingDates = []; // ✅ Daftar tanggal unik dari tasks
  bool loading = true;
  int navIndex = 2;

  Future<void> loadTasks() async {
    setState(() => loading = true);
    try {
      final fetchedTasks = await _taskService.getUpcomingTasks();
      setState(() {
        tasks = fetchedTasks;
        // ✅ Ekstrak tanggal unik dari tasks
        _extractUniqueDates(fetchedTasks);
      });
    } catch (e) {
      debugPrint("Error loading upcoming tasks: $e");
      Get.snackbar(
        "Error",
        "Gagal memuat tasks: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    setState(() => loading = false);
  }

  // ✅ Method untuk ekstrak tanggal unik dari tasks
  void _extractUniqueDates(List<Map<String, dynamic>> taskList) {
    final Set<String> dateStrings = {};
    final List<DateTime> dates = [];

    for (final task in taskList) {
      final dateStr = task['date']?.toString();
      if (dateStr != null && dateStr.isNotEmpty) {
        // Hanya tambah tanggal yang belum ada
        if (!dateStrings.contains(dateStr)) {
          dateStrings.add(dateStr);
          try {
            // Parse string ke DateTime
            final date = DateTime.parse(dateStr.split('T')[0]);
            dates.add(date);
          } catch (e) {
            debugPrint("Error parsing date: $dateStr");
          }
        }
      }
    }

    // ✅ Urutkan dari tanggal terdekat ke terjauh
    dates.sort((a, b) => a.compareTo(b));
    setState(() => upcomingDates = dates);
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Upcoming", style: AppStyle.title),
              const SizedBox(height: 10),

              // ✅ DYNAMIC DATES BAR - Hanya tampilkan jika ada upcomingDates
              if (upcomingDates.isNotEmpty) ...[
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: upcomingDates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final d = upcomingDates[i];
                      return Container(
                        width: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.white,
                              offset: Offset(-3, -3),
                              blurRadius: 6,
                            ),
                            BoxShadow(
                              color: Color(0xFFBEBEBE),
                              offset: Offset(4, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              d.day.toString(),
                              style: AppStyle.normal,
                            ),
                            Text(
                              _monthShort(d.month),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
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

              Text("Tugas yang akan datang", style: AppStyle.subtitle),
              const SizedBox(height: 12),

              // Task List
              Expanded(
                child: _buildTaskList(),
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

          if (result != null && result['text'] != null && result['date'] != null) {
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
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              "Belum ada tugas upcoming",
              style: AppStyle.smallGray,
            ),
            const SizedBox(height: 8),
            Text(
              "Tambah task dengan tanggal besok atau seterusnya",
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
          showDate: true,
          compactMode: false,
        );
      },
    );
  }

  // Helper functions
  String _monthShort(int m) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];
    return months[m - 1];
  }
}
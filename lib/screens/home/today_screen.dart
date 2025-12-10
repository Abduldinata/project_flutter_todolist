import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';
import '../../widgets/add_task_button.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/task_tile.dart'; // ✅ IMPORT TASK TILE
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
      debugPrint("DEBUG Tasks: ${fetchedTasks.length} items"); // Debug
      setState(() => tasks = fetchedTasks);
    } catch (e) {
      debugPrint("Error loading tasks: $e");
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
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
    final DateTime now = DateTime.now();
    final String formatted =
        "${now.day} ${_month(now.month)} · ${_weekday(now.weekday)}";

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Today", style: AppStyle.title),
                  GestureDetector(
                    onTap: () => Get.to(() => const CompletedScreen()),
                    child: Text(
                      "Completed >",
                      style: AppStyle.normal.copyWith(color: AppColors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(formatted, style: AppStyle.smallGray),
              ),
              const SizedBox(height: 20),

              // TASK LIST
              Expanded(
                child: _buildTaskList(),
              ),
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

          if (result != null && result['text'] != null && result['date'] != null) {
            try {
              await _taskService.insertTask(
              title: result['text'].toString(),
              date: result['date'] as DateTime,
              description: result['description']?.toString(), // ✅ Kirim description
              priority: result['priority']?.toString(),       // ✅ Kirim priority
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
              "Belum ada tugas untuk hari ini",
              style: AppStyle.smallGray,
            ),
            const SizedBox(height: 8),
            Text(
              "Tambahkan tugas baru dengan tombol +",
              style: AppStyle.smallGray.copyWith(fontSize: 12),
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
        
      // Di _buildTaskList() - LINE YANG PERLU DIPERBAIKI:
      return TaskTile(
        task: task,
        onToggleCompletion: (taskId, currentValue) => 
            _toggleTaskCompletion(taskId, currentValue),
        onDelete: (taskId, title) => _deleteTask(taskId, title),
        // ❌ HAPUS INI jika ada:
        // onTap: () {
        //   Get.snackbar("Info", "Detail task: ${task['title']}");
        // },
        
        // ✅ ATAU BIARKAN KOSONG (null):
        onTap: null,
      );
      },
    );
  }

  // FORMAT NAMA HARI & BULAN
  String _weekday(int d) {
    const days = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"];
    return days[d - 1];
  }

  String _month(int m) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];
    return months[m - 1];
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';
import '../../widgets/add_task_button.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/task_tile.dart';
import '../../services/task_service.dart';
import '../search/search_popup.dart';
import '../profile/profile_screen.dart';
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
      print("Error loading inbox tasks: $e");
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

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ KALKULASI DATA DI SINI (sebelum return)
    final now = DateTime.now();
    final todayFormatted = 
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    final todayTasks = allTasks.where((task) => 
        task['date'] == todayFormatted && (task['is_done'] ?? false) == false
    ).toList();
    
    final historyTasks = allTasks.where((task) => 
        (task['is_done'] ?? false) == true
    ).toList();
    
    final otherTasks = allTasks.where((task) => 
        !todayTasks.contains(task) && !historyTasks.contains(task)
    ).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Top bar: title + icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Inbox", style: AppStyle.title),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (ctx) => const SearchPopup(),
                          );
                        },
                        icon: const Icon(Icons.search, size: 26),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const ProfileScreen());
                        },
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Colors.grey),
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
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
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
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Inbox kosong",
                          style: AppStyle.smallGray,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tambahkan task pertama kamu",
                          style: AppStyle.smallGray.copyWith(fontSize: 12),
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
                          _buildSectionHeader("Hari Ini", todayTasks.length),
                          ...todayTasks.map((task) => TaskTile(
                            task: task,
                            onToggleCompletion: _toggleTaskCompletion,
                            onDelete: _deleteTask,
                          )).toList(),
                          const SizedBox(height: 24),
                        ],

                        // History/Completed Section
                        if (historyTasks.isNotEmpty) ...[
                          _buildSectionHeader("History (Selesai)", historyTasks.length),
                          ...historyTasks.map((task) => TaskTile(
                            task: task,
                            onToggleCompletion: _toggleTaskCompletion,
                            onDelete: _deleteTask,
                          )).toList(),
                          const SizedBox(height: 24),
                        ],

                        // Upcoming/Other Tasks
                        if (otherTasks.isNotEmpty) ...[
                          _buildSectionHeader("Lainnya", otherTasks.length),
                          ...otherTasks.map((task) => TaskTile(
                            task: task,
                            onToggleCompletion: _toggleTaskCompletion,
                            onDelete: _deleteTask,
                          )).toList(),
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
          if (i == 1) Get.offAllNamed("/today");
          if (i == 2) Get.offAllNamed("/upcoming");
          if (i == 3) Get.offAllNamed("/filter");
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(title, style: AppStyle.subtitle),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: AppStyle.smallGray.copyWith(
                color: AppColors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';
import '../../widgets/add_task_button.dart';
import '../../widgets/bottom_nav.dart';
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
  List tasks = [];
  bool loading = true;
  int navIndex = 1;

  Future<void> loadTasks() async {
    setState(() => loading = true);
    try {
      tasks = await _taskService.getTasksByDate(DateTime.now());
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
    setState(() => loading = false);
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
              // TITLE
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

              // LIST TASK
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : tasks.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada tugas untuk hari ini",
                          style: AppStyle.smallGray,
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: tasks.length,
                        itemBuilder: (_, i) {
                          final t = tasks[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.white,
                                  offset: Offset(-4, -4),
                                  blurRadius: 8,
                                ),
                                BoxShadow(
                                  color: Color(0xFFBEBEBE),
                                  offset: Offset(6, 6),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: t['is_done'] ?? false,
                                  onChanged: (v) async {
                                    await _taskService.updateCompleted(
                                      t['id'].toString(),
                                      v!,
                                    );
                                    loadTasks();
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    t['title'],
                                    style: AppStyle.normal.copyWith(
                                      decoration: (t['is_done'] ?? false)
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onLongPress: () async {
                                    await _taskService.deleteTask(
                                      t['id'].toString(),
                                    );
                                    loadTasks();
                                    Get.snackbar(
                                      "Delete",
                                      "Task berhasil dihapus",
                                    );
                                  },
                                  child: const Icon(Icons.more_vert),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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

          if (result != null) {
            await _taskService.insertTask(result['text'], result['date']);
            loadTasks();
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

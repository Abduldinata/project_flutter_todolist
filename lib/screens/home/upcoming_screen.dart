import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';
import '../../widgets/add_task_button.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/task_service.dart';
import '../add_task/add_task_popup.dart';

class UpcomingScreen extends StatefulWidget {
  const UpcomingScreen({super.key});

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  final TaskService _taskService = TaskService();

  List tasks = [];
  bool loading = true;
  int navIndex = 2;

  Future<void> loadTasks() async {
    setState(() => loading = true);
    try {
      tasks = await _taskService.getUpcomingTasks();
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
    final now = DateTime.now();
    final weekDates = List.generate(
      6,
      (i) => now.add(Duration(days: i + 1)), // besok dan seterusnya
    );

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

              // Bar tanggal kecil (mirip wireframe)
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: weekDates.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final d = weekDates[i];
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
                      child: Text(d.day.toString(), style: AppStyle.normal),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              Text("Tugas yang akan datang", style: AppStyle.subtitle),
              const SizedBox(height: 12),

              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : tasks.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada tugas upcoming",
                          style: AppStyle.smallGray,
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: tasks.length,
                        itemBuilder: (_, i) {
                          final t = tasks[i];
                          final created = DateTime.tryParse(
                            t['created_at']?.toString() ?? '',
                          );
                          final createdStr = created == null
                              ? ''
                              : "${created.day} ${_month(created.month)}";

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
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t['title'] ?? '',
                                        style: AppStyle.normal.copyWith(
                                          decoration: (t['is_done'] ?? false)
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      if (createdStr.isNotEmpty)
                                        Text(
                                          createdStr,
                                          style: AppStyle.smallGray,
                                        ),
                                    ],
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
                                      "Task upcoming dihapus",
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

      floatingActionButton: AddTaskButton(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const AddTaskPopup()),
          );

          if (result != null) {
            await _taskService.insertTask(
              result['text'],
              // kalau kamu tidak pakai kolom date di DB,
              // cukup simpan description atau abaikan tanggal
              result['date'],
            );
            loadTasks();
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

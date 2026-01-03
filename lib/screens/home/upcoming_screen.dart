import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/task_card.dart';
import '../../widgets/add_task_button.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../add_task/add_task_popup.dart';

class UpcomingScreen extends StatefulWidget {
  const UpcomingScreen({super.key});

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  final TaskController _taskController = Get.find<TaskController>();

  int navIndex = 2;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _taskController.loadAllTasks();
  }

  List<DateTime> _getDateRange() {
    final now = DateTime.now();
    final dates = <DateTime>[];
    for (int i = 0; i < 7; i++) {
      dates.add(now.add(Duration(days: i)));
    }
    return dates;
  }

  String _getDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _getDayNumber(DateTime date) {
    return date.day.toString();
  }

  String _formatSectionDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow ${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
    }

    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _getNextWeekRange() {
    final now = DateTime.now();
    final nextWeekStart = now.add(Duration(days: 7 - now.weekday));
    final nextWeekEnd = nextWeekStart.add(const Duration(days: 6));

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[nextWeekStart.month - 1]} ${nextWeekStart.day} - ${months[nextWeekEnd.month - 1]} ${nextWeekEnd.day}';
  }

  Map<String, List<Task>> _groupTasksByDate(List<Task> tasks) {
    final grouped = <String, List<Task>>{};

    for (final task in tasks) {
      final date = task.date;

      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final nextWeekStart = now.add(Duration(days: 7 - now.weekday));

      String key;
      if (date.year == tomorrow.year &&
          date.month == tomorrow.month &&
          date.day == tomorrow.day) {
        key = 'tomorrow';
      } else if (date.isAfter(
        nextWeekStart.subtract(const Duration(days: 1)),
      )) {
        key = 'next_week';
      } else {
        key =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(task);
    }

    grouped.forEach((key, taskList) {
      taskList.sort((a, b) {
        return a.date.compareTo(b.date);
      });
    });

    return grouped;
  }

  int _getNextWeekTaskCount(List<Task> tasks) {
    final now = DateTime.now();
    final nextWeekStart = now.add(Duration(days: 7 - now.weekday));

    return tasks.where((task) {
      return task.date.isAfter(nextWeekStart.subtract(const Duration(days: 1)));
    }).length;
  }

  Future<void> _toggleTaskCompletion(String taskId, bool currentValue) async {
    try {
      await _taskController.toggleTaskCompletion(taskId, currentValue);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final tasks = _taskController.getUpcomingTasks();

      if (tasks.isNotEmpty && selectedDate == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final firstDate = tasks[0].date;
          setState(() {
            selectedDate = firstDate;
          });
        });
      }

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
        body: Column(
          children: [
            Obx(() {
              if (_taskController.isOfflineMode.value) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  color: Colors.orange.withValues(alpha: 0.9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Offline Mode - View only',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            Expanded(
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Upcoming',
                            style: AppStyle.title.copyWith(
                              color: isDark ? Colors.white : AppColors.text,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            size: 24,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _getDateRange().length,
                        itemBuilder: (context, index) {
                          final date = _getDateRange()[index];
                          final isSelected =
                              selectedDate != null &&
                              selectedDate!.year == date.year &&
                              selectedDate!.month == date.month &&
                              selectedDate!.day == date.day;
                          final hasTasks = tasks.any((task) {
                            final taskDate = task.date;
                            return taskDate.year == date.year &&
                                taskDate.month == date.month &&
                                taskDate.day == date.day;
                          });

                          return GestureDetector(
                            onTap: () {
                              setState(() => selectedDate = date);
                            },
                            child: Container(
                              width: 60,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.blue
                                          : (isDark
                                                ? AppColors.darkCard
                                                : Colors.white),
                                      shape: BoxShape.circle,
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.blue
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _getDayName(date),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: isSelected
                                                  ? Colors.white
                                                  : (isDark
                                                        ? Colors.grey[400]
                                                        : Colors.grey[700]),
                                            ),
                                          ),
                                          Text(
                                            _getDayNumber(date),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : (isDark
                                                        ? Colors.white
                                                        : AppColors.text),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: hasTasks
                                          ? (isSelected
                                                ? Colors.white
                                                : AppColors.blue)
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: _taskController.isLoading.value
                          ? TaskCardLoading(isDark: isDark)
                          : tasks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 64,
                                    color: isDark
                                        ? Colors.grey[600]
                                        : Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No upcoming tasks',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _buildTaskList(isDark, tasks),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
                await _taskController.addTask(
                  title: result['text'].toString(),
                  date: result['date'] as DateTime,
                  description: result['description']?.toString(),
                  priority: result['priority']?.toString(),
                );
                Get.snackbar(
                  "Success",
                  "Task added successfully",
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  "Error",
                  "Failed to add task: ${e.toString()}",
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
            if (i == 3) Get.offAllNamed("/settings");
          },
        ),
      );
    });
  }

  Widget _buildTaskList(bool isDark, List<Task> tasks) {
    final grouped = _groupTasksByDate(tasks);
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'tomorrow') return -1;
        if (b == 'tomorrow') return 1;
        if (a == 'next_week') {
          if (b == 'next_week') return 0;
          return 1;
        }
        if (b == 'next_week') return -1;
        return a.compareTo(b);
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: sortedKeys.length + 1, // +1 for next week summary
      itemBuilder: (context, index) {
        if (index == sortedKeys.length) {
          final nextWeekCount = _getNextWeekTaskCount(tasks);
          if (nextWeekCount == 0) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 20),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: isDark ? NeuDark.concave : Neu.concave,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.view_list,
                        color: AppColors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$nextWeekCount Tasks Scheduled',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getNextWeekRange(),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final key = sortedKeys[index];
        final taskList = grouped[key]!;
        final firstTask = taskList.first;
        final taskDate = firstTask.date;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                key == 'tomorrow'
                    ? _formatSectionDate(taskDate)
                    : key == 'next_week'
                    ? 'Next Week'
                    : _formatSectionDate(taskDate),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.text,
                ),
              ),
            ),
            ...taskList.map(
              (task) => TaskCard(
                task: task,
                onToggleCompletion: _toggleTaskCompletion,
              ),
            ),
          ],
        );
      },
    );
  }
}

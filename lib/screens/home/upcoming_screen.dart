import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/loading_widget.dart';
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
  bool loading = true;
  int navIndex = 2;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    setState(() => loading = true);
    try {
      final fetchedTasks = await _taskService.getUpcomingTasks();
      setState(() {
        tasks = fetchedTasks;
        if (fetchedTasks.isNotEmpty && selectedDate == null) {
          // Set selected date to first upcoming date
          final firstDate = _parseDate(fetchedTasks[0]['date']);
          if (firstDate != null) {
            selectedDate = firstDate;
          }
        }
      });
    } catch (e) {
      debugPrint("Error loading upcoming tasks: $e");
      Get.snackbar(
        "Error",
        "Failed to load tasks: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => loading = false);
    }
  }

  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    try {
      final dateStr = dateValue.toString().split('T')[0];
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    } catch (e) {
      debugPrint("Error parsing date: $e");
    }
    return null;
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

  Map<String, List<Map<String, dynamic>>> _groupTasksByDate() {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final task in tasks) {
      final date = _parseDate(task['date']);
      if (date == null) continue;

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

    // Sort tasks within each group
    grouped.forEach((key, taskList) {
      taskList.sort((a, b) {
        final dateA = _parseDate(a['date']);
        final dateB = _parseDate(b['date']);
        if (dateA == null || dateB == null) return 0;
        return dateA.compareTo(dateB);
      });
    });

    return grouped;
  }

  int _getNextWeekTaskCount() {
    final now = DateTime.now();
    final nextWeekStart = now.add(Duration(days: 7 - now.weekday));

    return tasks.where((task) {
      final date = _parseDate(task['date']);
      if (date == null) return false;
      return date.isAfter(nextWeekStart.subtract(const Duration(days: 1)));
    }).length;
  }

  Future<void> _toggleTaskCompletion(String taskId, bool currentValue) async {
    try {
      await _taskService.updateCompleted(taskId, !currentValue);
      await loadTasks();
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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

            // Date Selector
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
                    final taskDate = _parseDate(task['date']);
                    return taskDate != null &&
                        taskDate.year == date.year &&
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
                                        color: AppColors.blue.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                  ? (isSelected ? Colors.white : AppColors.blue)
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

            // Task List
            Expanded(
              child: loading
                  ? TaskCardLoading(isDark: isDark)
                  : tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
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
                  : _buildTaskList(isDark),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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
        backgroundColor: AppColors.blue,
        child: const Icon(Icons.add, color: Colors.white),
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
  }

  Widget _buildTaskList(bool isDark) {
    final grouped = _groupTasksByDate();
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
          // Next Week Summary Card
          final nextWeekCount = _getNextWeekTaskCount();
          if (nextWeekCount == 0) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 20),
            child: GestureDetector(
              onTap: () {
                // Scroll to next week section or show next week tasks
              },
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
        final taskDate = _parseDate(firstTask['date']);
        if (taskDate == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: 24),
            // Section Header
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
            // Task Cards
            ...taskList.map((task) => _buildTaskCard(task, isDark)),
          ],
        );
      },
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, bool isDark) {
    final taskId = task['id']?.toString() ?? '';
    final title = task['title']?.toString() ?? 'No Title';
    final isDone = task['is_done'] ?? false;
    final priority = task['priority']?.toString() ?? 'medium';

    // Mock time and category for now (can be extended later)
    final time = '10:00 AM'; // Default, can be from task['time'] if available
    final category = priority == 'high' ? 'Urgent' : 'Work'; // Default category

    final hasHighPriority = priority == 'high' || priority == 'urgent';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: isDark ? NeuDark.concave : Neu.concave,
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () {
              if (taskId.isNotEmpty) {
                _toggleTaskCompletion(taskId, isDone);
              }
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDone ? AppColors.blue : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone
                      ? AppColors.blue
                      : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          // Task Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDone
                        ? (isDark ? Colors.grey[600] : Colors.grey[400])
                        : (isDark ? Colors.white : AppColors.text),
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (hasHighPriority)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Urgent',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Flag Icon
          Icon(
            Icons.flag,
            color: hasHighPriority
                ? Colors.orange
                : (isDark ? Colors.grey[600] : Colors.grey[400]),
            size: 20,
          ),
        ],
      ),
    );
  }
}

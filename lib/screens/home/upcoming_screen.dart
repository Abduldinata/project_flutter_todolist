import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/add_task_button.dart';
import '../../controllers/task_controller.dart';
import '../add_task/add_task_popup.dart';
import '../task_detail/task_detail_screen.dart';
import '../../services/sound_service.dart';
import '../../utils/app_routes.dart';

class UpcomingScreen extends StatefulWidget {
  const UpcomingScreen({super.key});

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  final TaskController _taskController = Get.find<TaskController>();
  final _box = GetStorage();

  int navIndex = 2;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _taskController.loadAllTasks();
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

  bool _isTodayTask(Map<String, dynamic> task) {
    final taskDate = _parseDate(task['date']);
    if (taskDate == null) return false;
    final now = DateTime.now();
    return taskDate.year == now.year &&
        taskDate.month == now.month &&
        taskDate.day == now.day;
  }

  bool _isNextWeekTask(Map<String, dynamic> task) {
    final taskDate = _parseDate(task['date']);
    if (taskDate == null) return false;
    
    final now = DateTime.now();
    final startOfWeek = _box.read('start_of_week') ?? 'Monday';
    
    // Get start day index
    int startDayIndex = 1;
    switch (startOfWeek) {
      case 'Monday': startDayIndex = 1; break;
      case 'Tuesday': startDayIndex = 2; break;
      case 'Wednesday': startDayIndex = 3; break;
      case 'Thursday': startDayIndex = 4; break;
      case 'Friday': startDayIndex = 5; break;
      case 'Saturday': startDayIndex = 6; break;
      case 'Sunday': startDayIndex = 7; break;
    }
    
    // Calculate next week start
    int daysToNextWeek = ((startDayIndex - now.weekday) % 7) + 7;
    if (daysToNextWeek == 7 && now.weekday == startDayIndex) {
      daysToNextWeek = 7;
    }
    final nextWeekStart = now.add(Duration(days: daysToNextWeek));
    
    return taskDate.isAfter(nextWeekStart.subtract(const Duration(days: 1)));
  }

  String _getCategoryFromPriority(String? priority) {
    if (priority == null) return 'Medium';
    final p = priority.toLowerCase();

    if (p == 'high' || p == 'urgent') {
      return 'High';
    } else if (p == 'medium') {
      return 'Medium';
    } else {
      return 'Low';
    }
  }

  Color _getCategoryColor(String category) {
    final c = category.toLowerCase();
    if (c == 'high' || c == 'urgent') {
      return Colors.red;
    } else if (c == 'medium') {
      return AppColors.blue;
    } else {
      return Colors.green;
    }
  }

  List<DateTime> _getDateRange() {
    final now = DateTime.now();
    final startOfWeek = _box.read('start_of_week') ?? 'Monday';
    
    // Get start day index (1 = Monday, 7 = Sunday)
    int startDayIndex = 1; // Default Monday
    switch (startOfWeek) {
      case 'Monday': startDayIndex = 1; break;
      case 'Tuesday': startDayIndex = 2; break;
      case 'Wednesday': startDayIndex = 3; break;
      case 'Thursday': startDayIndex = 4; break;
      case 'Friday': startDayIndex = 5; break;
      case 'Saturday': startDayIndex = 6; break;
      case 'Sunday': startDayIndex = 7; break;
    }
    
    // Calculate days to add based on start of week
    int daysToAdd = (startDayIndex - now.weekday) % 7;
    if (daysToAdd > 0) daysToAdd -= 7; // Go back to start of week
    
    final weekStart = now.add(Duration(days: daysToAdd));
    final dates = <DateTime>[];
    for (int i = 0; i < 7; i++) {
      dates.add(weekStart.add(Duration(days: i)));
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
    final startOfWeek = _box.read('start_of_week') ?? 'Monday';
    
    // Get start day index
    int startDayIndex = 1;
    switch (startOfWeek) {
      case 'Monday': startDayIndex = 1; break;
      case 'Tuesday': startDayIndex = 2; break;
      case 'Wednesday': startDayIndex = 3; break;
      case 'Thursday': startDayIndex = 4; break;
      case 'Friday': startDayIndex = 5; break;
      case 'Saturday': startDayIndex = 6; break;
      case 'Sunday': startDayIndex = 7; break;
    }
    
    // Calculate next week start
    int daysToNextWeek = ((startDayIndex - now.weekday) % 7) + 7;
    if (daysToNextWeek == 7 && now.weekday == startDayIndex) {
      daysToNextWeek = 7; // If today is start of week, next week is in 7 days
    }
    
    final nextWeekStart = now.add(Duration(days: daysToNextWeek));
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

  Map<String, List<Map<String, dynamic>>> _groupTasksByDate(
    List<Map<String, dynamic>> tasks,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    final startOfWeek = _box.read('start_of_week') ?? 'Monday';
    
    // Get start day index
    int startDayIndex = 1;
    switch (startOfWeek) {
      case 'Monday': startDayIndex = 1; break;
      case 'Tuesday': startDayIndex = 2; break;
      case 'Wednesday': startDayIndex = 3; break;
      case 'Thursday': startDayIndex = 4; break;
      case 'Friday': startDayIndex = 5; break;
      case 'Saturday': startDayIndex = 6; break;
      case 'Sunday': startDayIndex = 7; break;
    }

    for (final task in tasks) {
      final date = _parseDate(task['date']);
      if (date == null) continue;

      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      
      // Calculate next week start based on start_of_week preference
      int daysToNextWeek = ((startDayIndex - now.weekday) % 7) + 7;
      if (daysToNextWeek == 7 && now.weekday == startDayIndex) {
        daysToNextWeek = 7;
      }
      final nextWeekStart = now.add(Duration(days: daysToNextWeek));

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
        final dateA = _parseDate(a['date']);
        final dateB = _parseDate(b['date']);
        if (dateA == null || dateB == null) return 0;
        return dateA.compareTo(dateB);
      });
    });

    return grouped;
  }

  int _getNextWeekTaskCount(List<Map<String, dynamic>> tasks) {
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
          final firstDate = _parseDate(tasks[0]['date']);
          if (firstDate != null) {
            setState(() {
              selectedDate = firstDate;
            });
          }
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
            if (i == 0) Get.offAllNamed(AppRoutes.inbox);
            if (i == 1) Get.offAllNamed(AppRoutes.today);
            if (i == 3) Get.offAllNamed(AppRoutes.settings);
          },
        ),
      );
    });
  }

  Widget _buildTaskList(bool isDark, List<Map<String, dynamic>> tasks) {
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
              onTap: () {
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
            ...taskList.map((task) => _buildTaskCard(task, isDark)),
          ],
        );
      },
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, bool isDark) {
    final taskId = task['id']?.toString() ?? '';
    final title = task['title']?.toString() ?? 'No Title';
    final description = task['description']?.toString();
    final isDone = task['is_done'] ?? false;
    final priority = task['priority']?.toString() ?? 'medium';
    final category = _getCategoryFromPriority(priority);
    final isToday = _isTodayTask(task);
    final isNextWeek = _isNextWeekTask(task);
    final isHighPriority =
        priority.toLowerCase() == 'high' || priority.toLowerCase() == 'urgent';

    final categoryColor = _getCategoryColor(category);

    return GestureDetector(
      onTap: () {
        SoundService().playSound(SoundType.tap);
        Get.to(() => TaskDetailScreen(task: task));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: isDark ? NeuDark.concave : Neu.concave,
        child: Row(
          children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDone
                                ? (isDark ? Colors.grey[600] : Colors.grey[400])
                                : (isDark ? Colors.white : AppColors.text),
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: categoryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isToday)
                        Text(
                          'Due Today',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        )
                      else if (isNextWeek)
                        Text(
                          'Next Week',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        )
                      else if (isHighPriority)
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'High Priority',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDone
                            ? (isDark ? Colors.grey[600] : Colors.grey[400])
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              isHighPriority ? Icons.flag : Icons.flag_outlined,
              color: isHighPriority
                  ? Colors.orange
                  : (isDark ? Colors.grey[600] : Colors.grey[400]),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

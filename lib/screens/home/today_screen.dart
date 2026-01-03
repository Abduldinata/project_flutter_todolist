import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/add_task_button.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/task_card.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/task_model.dart';
import '../add_task/add_task_popup.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final TaskController _taskController = Get.find<TaskController>();
  final ProfileController _profileController = Get.find<ProfileController>();

  int navIndex = 1;

  @override
  void initState() {
    super.initState();
    _taskController.loadAllTasks();
    if (_profileController.profile.value == null) {
      _profileController.loadProfile();
    }
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
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

    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  List<Task> _getHighPriorityTasks(List<Task> tasks) {
    return tasks.where((task) {
      if (task.isDone == true) return false;
      final priority = task.priority.toLowerCase();
      return priority == 'high' || priority == 'urgent';
    }).toList();
  }

  List<Task> _getUpcomingTasks(List<Task> tasks) {
    return tasks.where((task) {
      if (task.isDone == true) return false;
      final priority = task.priority.toLowerCase();
      return priority != 'high' && priority != 'urgent';
    }).toList();
  }

  List<Task> _getCompletedTasks(List<Task> tasks) {
    return tasks.where((task) => task.isDone == true).toList();
  }

  double _getProgressPercentage(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((task) => task.isDone == true).length;
    return completed / tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final tasks = _taskController.getTodayTasks();
      final highPriorityTasks = _getHighPriorityTasks(tasks);
      final upcomingTasks = _getUpcomingTasks(tasks);
      final completedTasks = _getCompletedTasks(tasks);
      final progress = _getProgressPercentage(tasks);
      final completedCount = tasks.where((task) => task.isDone == true).length;
      final remainingCount = tasks.length - completedCount;

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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        final profile = _profileController.profile.value;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.blue.withValues(
                                    alpha: 0.1,
                                  ),
                                  backgroundImage:
                                      (profile?.avatarUrl?.isNotEmpty ?? false)
                                      ? NetworkImage(profile!.avatarUrl!)
                                      : null,
                                  child: (profile?.avatarUrl?.isEmpty ?? true)
                                      ? Text(
                                          profile?.username != null &&
                                                  profile!.username.isNotEmpty
                                              ? profile.username[0]
                                                    .toUpperCase()
                                              : 'U',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.blue,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getGreeting(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                          letterSpacing: 1.2,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        profile?.username ?? 'User',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.text,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 24),

                      Text(
                        'Today',
                        style: AppStyle.title.copyWith(
                          color: isDark ? Colors.white : AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getFormattedDate(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (tasks.isNotEmpty && !_taskController.isLoading.value)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: isDark ? NeuDark.concave : Neu.concave,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DAILY PROGRESS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Keep it up, you're doing great!",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: isDark
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.blue,
                                            ),
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '${(progress * 100).toInt()}%',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$completedCount of ${tasks.length} completed',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '$remainingCount remaining',
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
                        ),

                      if (tasks.isNotEmpty && !_taskController.isLoading.value)
                        const SizedBox(height: 24),

                      if (_taskController.isLoading.value) ...[
                        TodayTaskLoading(isDark: isDark),
                      ] else ...[
                        if (highPriorityTasks.isNotEmpty) ...[
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'HIGH PRIORITY',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...highPriorityTasks.map(
                            (task) => TaskCard(
                              task: task,
                              onToggleCompletion: _toggleTaskCompletion,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        if (upcomingTasks.isNotEmpty) ...[
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'UPCOMING',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...upcomingTasks.map(
                            (task) => TaskCard(
                              task: task,
                              onToggleCompletion: _toggleTaskCompletion,
                            ),
                          ),
                        ],

                        if (completedTasks.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[600]
                                      : Colors.grey[400],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'HISTORY',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...completedTasks.map(
                            (task) => TaskCard(
                              task: task,
                              onToggleCompletion: _toggleTaskCompletion,
                            ),
                          ),
                        ],

                        if (tasks.isEmpty) ...[
                          const SizedBox(height: 40),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 64,
                                  color: isDark
                                      ? Colors.grey[600]
                                      : Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No tasks for today',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
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
            switch (i) {
              case 0:
                Get.offAllNamed("/inbox");
                break;
              case 2:
                Get.offAllNamed("/upcoming");
                break;
              case 3:
                Get.offAllNamed("/settings");
                break;
              default:
                Get.offAllNamed("/today");
            }
          },
        ),
      );
    });
  }
}

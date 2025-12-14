import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';
import '../../widgets/add_task_button.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/loading_widget.dart';
import '../../services/task_service.dart';
import '../../services/supabase_service.dart';
import '../../models/profile_model.dart';
import '../add_task/add_task_popup.dart';
import '../task_detail/task_detail_screen.dart';
import '../../utils/app_routes.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final TaskService _taskService = TaskService();
  final SupabaseService _supabaseService = SupabaseService();

  List<Map<String, dynamic>> tasks = [];
  Profile? _profile;
  bool loading = true;
  bool loadingProfile = true;
  int navIndex = 1;

  @override
  void initState() {
    super.initState();
    loadTasks();
    loadProfile();
  }

  Future<void> loadTasks() async {
    if (!mounted) return;

    setState(() => loading = true);

    try {
      final fetchedTasks = await _taskService.getTasksByDate(DateTime.now());
      if (!mounted) return;
      setState(() => tasks = fetchedTasks);
    } catch (e) {
      debugPrint("Error loading tasks: $e");
      if (!mounted) return;
      Get.snackbar(
        "Error",
        "Failed to load tasks: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> loadProfile() async {
    try {
      final data = await _supabaseService.getProfile();
      if (mounted && data != null) {
        setState(() {
          _profile = Profile.fromJson(data);
          loadingProfile = false;
        });
      } else if (mounted) {
        setState(() => loadingProfile = false);
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
      if (mounted) {
        setState(() => loadingProfile = false);
      }
    }
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

  List<Map<String, dynamic>> _getHighPriorityTasks() {
    return tasks.where((task) {
      if ((task['is_done'] ?? false) == true) return false;
      final priority = task['priority']?.toString() ?? 'medium';
      return priority.toLowerCase() == 'high' ||
          priority.toLowerCase() == 'urgent';
    }).toList();
  }

  List<Map<String, dynamic>> _getUpcomingTasks() {
    return tasks.where((task) {
      if ((task['is_done'] ?? false) == true) return false;
      final priority = task['priority']?.toString() ?? 'medium';
      return priority.toLowerCase() != 'high' &&
          priority.toLowerCase() != 'urgent';
    }).toList();
  }

  List<Map<String, dynamic>> _getCompletedTasks() {
    return tasks.where((task) {
      return (task['is_done'] ?? false) == true;
    }).toList();
  }

  double _getProgressPercentage() {
    if (tasks.isEmpty) return 0.0;
    final completed = tasks
        .where((task) => (task['is_done'] ?? false) == true)
        .length;
    return completed / tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final highPriorityTasks = _getHighPriorityTasks();
    final upcomingTasks = _getUpcomingTasks();
    final completedTasks = _getCompletedTasks();
    final progress = _getProgressPercentage();
    final completedCount = tasks
        .where((task) => (task['is_done'] ?? false) == true)
        .length;
    final remainingCount = tasks.length - completedCount;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Avatar and Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                        backgroundImage:
                            _profile?.avatarUrl != null &&
                                _profile!.avatarUrl!.isNotEmpty
                            ? NetworkImage(_profile!.avatarUrl!)
                            : null,
                        child:
                            _profile?.avatarUrl == null ||
                                _profile!.avatarUrl!.isEmpty
                            ? Text(
                                _profile?.username.isNotEmpty == true
                                    ? _profile!.username[0].toUpperCase()
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _profile?.username ?? 'User',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Get.toNamed(AppRoutes.settings),
                    icon: Icon(
                      Icons.settings,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      size: 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Title
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

              // Daily Progress Card
              if (tasks.isNotEmpty && !loading)
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
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Keep it up, you're doing great!",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
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
                                valueColor: AlwaysStoppedAnimation<Color>(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

              if (tasks.isNotEmpty && !loading) const SizedBox(height: 24),

              // Loading State - hanya task cards
              if (loading) ...[
                TodayTaskLoading(isDark: isDark),
              ] else ...[
                // High Priority Section
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
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...highPriorityTasks.map(
                    (task) =>
                        _buildTaskCard(task, isDark, isHighPriority: true),
                  ),
                  const SizedBox(height: 24),
                ],

                // Upcoming Section
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
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...upcomingTasks.map(
                    (task) =>
                        _buildTaskCard(task, isDark, isHighPriority: false),
                  ),
                ],

                // History Section
                if (completedTasks.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'HISTORY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...completedTasks.map(
                    (task) =>
                        _buildTaskCard(task, isDark, isHighPriority: false),
                  ),
                ],

                // Empty State
                if (tasks.isEmpty) ...[
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks for today',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
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
  }

  Widget _buildTaskCard(
    Map<String, dynamic> task,
    bool isDark, {
    required bool isHighPriority,
  }) {
    final taskId = task['id']?.toString() ?? '';
    final title = task['title']?.toString() ?? 'No Title';
    final description = task['description']?.toString();
    final isDone = task['is_done'] ?? false;
    final priority = task['priority']?.toString() ?? 'medium';
    final category = _getCategoryFromPriority(priority);
    final isToday = _isTodayTask(task);
    final isNextWeek = _isNextWeekTask(task);
    final isHighPriorityTask =
        priority.toLowerCase() == 'high' || priority.toLowerCase() == 'urgent';

    final categoryColor = _getCategoryColor(category);

    return GestureDetector(
      onTap: () {
        Get.to(() => TaskDetailScreen(task: task));
      },
      child: Container(
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
                  // Title with Priority and Due Date on the right
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
                      // Priority Tag
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
                      // Date/Status Info
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
                      else if (isHighPriorityTask)
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
                  // Description below title
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
            // Flag/Icon
            Icon(
              isHighPriorityTask ? Icons.flag : Icons.flag_outlined,
              color: isHighPriorityTask
                  ? Colors.orange
                  : (isDark ? Colors.grey[600] : Colors.grey[400]),
              size: 20,
            ),
          ],
        ),
      ),
    );
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
    final nextWeek = now.add(const Duration(days: 7));
    return taskDate.year == nextWeek.year &&
        taskDate.month == nextWeek.month &&
        taskDate.day == nextWeek.day;
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

  String _getCategoryFromPriority(String? priority) {
    if (priority == null) return 'Medium';
    final p = priority.toLowerCase();

    // Return priority directly (High, Medium, Low)
    if (p == 'high' || p == 'urgent') {
      return 'High';
    } else if (p == 'medium') {
      return 'Medium';
    } else if (p == 'low') {
      return 'Low';
    }
    return 'Medium';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'high':
      case 'urgent':
        return Colors.red;
      case 'medium':
        return AppColors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

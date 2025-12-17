import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/theme_tokens.dart';
import '../controllers/task_controller.dart';
import '../screens/task_detail/task_detail_screen.dart';

class TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final Function(String taskId, bool currentValue) onToggleCompletion;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleCompletion,
    this.onTap,
  });

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
    final nextWeekStart = now.add(Duration(days: 7 - now.weekday));
    return taskDate.isAfter(nextWeekStart.subtract(const Duration(days: 1)));
  }

  String _getCategoryFromPriority(String? priority) {
    if (priority == null) return 'Medium';
    final p = priority.toLowerCase();

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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      final taskController = Get.find<TaskController>();
      final updatedTask = taskController.allTasks.firstWhere(
        (t) => t['id']?.toString() == task['id']?.toString(),
        orElse: () => task,
      );

      final taskId = updatedTask['id']?.toString() ?? '';
      final title = updatedTask['title']?.toString() ?? 'No Title';
      final description = updatedTask['description']?.toString();
      final isDone = updatedTask['is_done'] ?? false;
      final priority = updatedTask['priority']?.toString() ?? 'medium';
      final category = _getCategoryFromPriority(priority);
      final isToday = _isTodayTask(updatedTask);
      final isNextWeek = _isNextWeekTask(updatedTask);
      final isHighPriority =
          priority.toLowerCase() == 'high' ||
          priority.toLowerCase() == 'urgent';

      final categoryColor = _getCategoryColor(category);

      return GestureDetector(
        onTap:
            onTap ??
            () {
              Get.to(() => TaskDetailScreen(task: updatedTask));
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
                    onToggleCompletion(taskId, isDone);
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
                                  ? (isDark
                                        ? Colors.grey[600]
                                        : Colors.grey[400])
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
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          )
                        else if (isNextWeek)
                          Text(
                            'Next Week',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
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
    });
  }
}

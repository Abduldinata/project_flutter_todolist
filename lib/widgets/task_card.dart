import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/theme_tokens.dart';
import '../controllers/task_controller.dart';
import '../screens/task_detail/task_detail_screen.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(String taskId, bool currentValue) onToggleCompletion;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleCompletion,
    this.onTap,
  });

  bool _isTodayTask(Task task) {
    final taskDate = task.date;
    final now = DateTime.now();
    return taskDate.year == now.year &&
        taskDate.month == now.month &&
        taskDate.day == now.day;
  }

  bool _isNextWeekTask(Task task) {
    final taskDate = task.date;
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final taskController = Get.find<TaskController>();
    final currentTaskId = task.id.toString();

    // Optimasi: Gunakan Obx dengan selector yang lebih spesifik
    // Obx akan hanya rebuild jika task dengan ID ini berubah di allTasks
    // Dengan mengakses task spesifik via indexWhere, GetX akan track perubahan
    // pada task tersebut, bukan seluruh list
    return Obx(() {
      // Cari task di list - GetX akan track perubahan pada elemen ini
      final taskIndex = taskController.allTasks.indexWhere(
        (t) => t.id.toString() == currentTaskId,
      );

      // Gunakan task dari controller jika ada update, jika tidak gunakan task awal
      final updatedTask = taskIndex != -1
          ? taskController.allTasks[taskIndex]
          : task;

      final updatedTaskId = updatedTask.id.toString();
      final title = updatedTask.title;
      final description = updatedTask.description;
      final isDone = updatedTask.isDone;
      final priority = updatedTask.priority;
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
                  if (updatedTaskId.isNotEmpty) {
                    onToggleCompletion(updatedTaskId, isDone);
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
                          flex: 3,
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
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Category badge - tidak perlu Flexible karena ukuran fixed
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
                        // Labels - wrap dengan Flexible untuk prevent overflow
                        if (isToday)
                          Flexible(
                            child: Text(
                              'Due Today',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else if (isNextWeek)
                          Flexible(
                            child: Text(
                              'Next Week',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else if (isHighPriority)
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
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
                                Flexible(
                                  child: Text(
                                    'High Priority',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
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

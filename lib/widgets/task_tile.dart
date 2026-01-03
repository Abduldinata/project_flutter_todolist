import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_project/screens/edit_task/edit_task_screen.dart';
import '../theme/theme_tokens.dart';
import '../screens/task_detail/task_detail_screen.dart';
import '../models/task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final Function(String taskId, bool currentValue) onToggleCompletion;
  final Function(String taskId, String title) onDelete;
  final VoidCallback? onTap;
  final bool showDate;
  final bool compactMode;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggleCompletion,
    required this.onDelete,
    this.onTap,
    this.showDate = true,
    this.compactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    final taskId = task.id.toString();
    final title = task.title;
    final isDone = task.isDone;
    final description = task.description;
    final date = task.date.toIso8601String().split('T')[0];

    return GestureDetector(
      onTap:
          onTap ??
          () {
            Get.to(() => TaskDetailScreen(task: task));
          },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        // Ganti bagian yang menggunakan hardcoded colors:
        decoration: isDark
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              )
            : Neu.concave,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: () {
                  if (taskId.isNotEmpty) {
                    onToggleCompletion(taskId, isDone);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: isDone
                      ? BoxDecoration(
                          color: AppColors.blue,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isDark
                              ? [
                                  BoxShadow(
                                    color: AppColors.blue.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: AppColors.blue.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                  ),
                                ],
                        )
                      : BoxDecoration(
                          color: isDark
                              ? scheme.surfaceContainerHighest
                              : scheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? scheme.outline.withValues(alpha: 0.5)
                                : scheme.outline,
                            width: 2,
                          ),
                          boxShadow: isDark
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
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
                      style: AppStyle.normal.copyWith(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone
                            ? Colors.grey
                            : (isDark ? Colors.white : AppColors.text),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    if (description != null &&
                        description.isNotEmpty &&
                        !compactMode)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          description.length > 60
                              ? '${description.substring(0, 60)}...'
                              : description,
                          style: AppStyle.smallGray.copyWith(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey,
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),

                    if (showDate)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(date),
                              style: AppStyle.smallGray.copyWith(
                                fontSize: 11,
                                color: isDark ? Colors.grey[500] : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // More Options Button
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'detail',
                    child: Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 20,
                          color: isDark ? Colors.white : AppColors.text,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Lihat Detail",
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          size: 20,
                          color: isDark ? Colors.white : AppColors.text,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Edit",
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, size: 20, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text(
                          "Hapus",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'detail') {
                    Get.to(() => TaskDetailScreen(task: task));
                  } else if (value == 'edit') {
                    Get.to(() => EditTaskScreen(task: task));
                  } else if (value == 'delete') {
                    onDelete(taskId, title);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final parts = dateString.split('T')[0].split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[2]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[0]);
        return "$day/${month.toString().padLeft(2, '0')}/$year";
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }
}

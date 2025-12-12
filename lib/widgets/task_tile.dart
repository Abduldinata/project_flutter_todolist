// widgets/task_tile.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/neumorphic_decoration.dart';
import '../screens/task_detail/task_detail_screen.dart'; // IMPORT
import '../screens/edit_task/edit_task_screen.dart'; // IMPORT

class TaskTile extends StatelessWidget {
  final Map<String, dynamic> task;
  final Future<void> Function(String taskId, bool currentValue) onToggleCompletion;
  final Future<void> Function(String taskId, String title) onDelete;
  final VoidCallback? onTaskUpdated; // Callback ketika task diupdate
  final bool showDelete;
  final bool showDate;
  final bool compactMode;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggleCompletion,
    required this.onDelete,
    this.onTap, // TAMBAHKAN INI
    this.onTaskUpdated,
    this.showDelete = true,
    this.showDate = true,
    this.compactMode = false,
  });
  final VoidCallback? onTap; // TAMBAHKAN INI

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Color _getPriorityColor(String priority, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (priority.toLowerCase()) {
      case 'high':
        return colorScheme.error;
      case 'medium':
        return colorScheme.tertiary;
      case 'low':
        return colorScheme.secondary;
      default:
        return colorScheme.onSurface.withOpacity(0.5);
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return "Tinggi";
      case 'medium':
        return "Sedang";
      case 'low':
        return "Rendah";
      default:
        return priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final title = task['title']?.toString() ?? 'No Title';
    final description = task['description']?.toString();
    final priority = task['priority']?.toString() ?? 'medium';
    final isDone = task['is_done'] ?? false;
    final dateStr = task['date']?.toString();

    DateTime? taskDate;
    if (dateStr != null && dateStr.isNotEmpty) {
      try {
        taskDate = DateTime.parse("${dateStr}T00:00:00Z");
      } catch (e) {
        debugPrint("Error parsing date: $e");
      }
    }

    return GestureDetector(
      onTap: () {
        // Navigasi ke TaskDetailScreen yang sudah ada
        Get.to(() => TaskDetailScreen(task: task))?.then((value) {
          // Refresh jika ada perubahan
          if (onTaskUpdated != null) {
            onTaskUpdated!();
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: Neu.concave(context).copyWith(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            GestureDetector(
              onTap: () {
                final taskId = task['id']?.toString();
                if (taskId != null) {
                  onToggleCompletion(taskId, isDone);
                }
              },
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 16, top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone 
                    ? colorScheme.primary.withOpacity(0.1)
                    : colorScheme.surface,
                  border: Border.all(
                    color: isDone 
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: isDone
                    ? Icon(
                        Icons.check,
                        size: 18,
                        color: colorScheme.primary,
                      )
                    : null,
              ),
            ),

            // Task Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with Priority and Three-dot Menu
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDone
                                ? colorScheme.onSurface.withOpacity(0.6)
                                : colorScheme.onSurface,
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Priority Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority, context)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getPriorityLabel(priority),
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: _getPriorityColor(priority, context),
                          ),
                        ),
                      ),
                      
                      // Three-dot Menu Button
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: 20,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          // Lihat Detail
                          PopupMenuItem<String>(
                            value: 'view_detail',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 18,
                                  color: colorScheme.onSurface,
                                ),
                                const SizedBox(width: 8),
                                Text('Lihat Detail'),
                              ],
                            ),
                          ),
                          
                          // Edit Task
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: colorScheme.onSurface,
                                ),
                                const SizedBox(width: 8),
                                Text('Edit Task'),
                              ],
                            ),
                          ),
                          
                          // Hapus Task
                          if (showDelete)
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: colorScheme.error,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Hapus Task',
                                    style: TextStyle(color: colorScheme.error),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        onSelected: (String value) {
                          final taskId = task['id']?.toString();
                          final taskTitle = task['title']?.toString() ?? 'task';
                          
                          switch (value) {
                            case 'view_detail':
                              // Navigasi ke TaskDetailScreen
                              Get.to(() => TaskDetailScreen(task: task))?.then((value) {
                                if (onTaskUpdated != null) {
                                  onTaskUpdated!();
                                }
                              });
                              break;
                              
                            case 'edit':
                              // Navigasi ke EditTaskScreen
                              Get.to(() => EditTaskScreen(task: task))?.then((updated) {
                                if (updated == true && onTaskUpdated != null) {
                                  onTaskUpdated!();
                                }
                              });
                              break;
                              
                            case 'delete':
                              // Tampilkan konfirmasi delete
                              Get.dialog(
                                AlertDialog(
                                  title: const Text("Hapus Task"),
                                  content: Text("Yakin hapus '$taskTitle'?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text("Batal"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Get.back();
                                        if (taskId != null) {
                                          onDelete(taskId, taskTitle);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.error,
                                      ),
                                      child: Text(
                                        "Hapus",
                                        style: TextStyle(color: colorScheme.onError),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              break;
                          }
                        },
                      ),
                    ],
                  ),

                  // Description
                  if (description?.isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    Text(
                      description!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Date
                  if (showDate && taskDate != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(taskDate),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
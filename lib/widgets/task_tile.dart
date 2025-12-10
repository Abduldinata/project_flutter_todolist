// widgets/task_tile.dart - VERSI DENGAN PARAMETER showDate
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_project/screens/edit_task/edit_task_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_style.dart';
import '../utils/neumorphic_decoration.dart';
import '../screens/task_detail/task_detail_screen.dart';

class TaskTile extends StatelessWidget {
  final Map<String, dynamic> task;
  final Function(String taskId, bool currentValue) onToggleCompletion;
  final Function(String taskId, String title) onDelete;
  final VoidCallback? onTap;
  final bool showDate; // ✅ PARAMETER BARU
  final bool compactMode; // ✅ PARAMETER BARU

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggleCompletion,
    required this.onDelete,
    this.onTap,
    this.showDate = true, // ✅ DEFAULT: true
    this.compactMode = false, // ✅ DEFAULT: false
  });

  @override
  Widget build(BuildContext context) {
    final taskId = task['id']?.toString() ?? '';
    final title = task['title']?.toString() ?? 'No Title';
    final isDone = task['is_done'] ?? false;
    final description = task['description']?.toString();
    final date = task['date']?.toString();

    return GestureDetector(
      onTap: onTap ?? () {
        Get.to(() => TaskDetailScreen(task: task));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: Neu.concave,
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
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: isDone
                      ? Neu.pressed.copyWith(
                          color: AppColors.blue.withAlpha((0.8 * 255).round()),
                        )
                      : Neu.convex,
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
                        color: isDone ? Colors.grey : AppColors.text,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // ✅ DESKRIPSI: Tampilkan jika tidak compactMode
                    if (description != null && description.isNotEmpty && !compactMode)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          description.length > 60
                              ? '${description.substring(0, 60)}...'
                              : description,
                          style: AppStyle.smallGray.copyWith(
                            fontSize: 12,
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),

                    // ✅ TANGGAL: Hanya tampilkan jika showDate = true
                    if (date != null && date.isNotEmpty && showDate)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(date),
                              style: AppStyle.smallGray.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // More Options Button (sama seperti sebelumnya)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'detail',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 20, color: AppColors.text),
                        const SizedBox(width: 8),
                        const Text("Lihat Detail"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20, color: AppColors.text),
                        const SizedBox(width: 8),
                        const Text("Edit"),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
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
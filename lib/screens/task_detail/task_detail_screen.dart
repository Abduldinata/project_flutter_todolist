// screens/task_detail/task_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/neumorphic_decoration.dart';
import '../../services/task_service.dart';
import '../../utils/app_routes.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TaskService _taskService = TaskService();
  late Map<String, dynamic> _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  void _refreshTask() async {
    try {
      final taskId = _task['id']?.toString();
      if (taskId != null) {
        final response = await _taskService.getTaskById(taskId);
        if (response != null) {
          setState(() {
            _task = response;
          });
        }
      }
    } catch (e) {
      debugPrint("Error refreshing task: $e");
    }
  }

  Future<void> _toggleCompletion() async {
    try {
      final taskId = _task['id']?.toString();
      final currentStatus = _task['is_done'] ?? false;

      if (taskId != null) {
        await _taskService.updateCompleted(taskId, !currentStatus);
        _refreshTask();
        Get.snackbar(
          "Success",
          currentStatus
              ? "Task ditandai belum selesai"
              : "Task ditandai selesai",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal update status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    final title = _task['title']?.toString() ?? 'No Title';
    final description = _task['description']?.toString();
    final dateStr = _task['date']?.toString();
    final priority = _task['priority']?.toString() ?? 'medium';
    final isDone = _task['is_done'] ?? false;
    final createdAt = _task['created_at']?.toString();
    final updatedAt = _task['updated_at']?.toString();

    DateTime? taskDate;
    if (dateStr != null && dateStr.isNotEmpty) {
      try {
        taskDate = DateTime.parse("${dateStr}T00:00:00Z");
      } catch (e) {
        debugPrint("Error parsing date: $e");
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withAlpha((0.05 * 255).round()),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Back Button
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (Get.isSnackbarOpen) {
                        Get.closeCurrentSnackbar();
                      }
                      Get.back();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      decoration: Neu.convex(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Detail Task",
                      style: textTheme.titleLarge?.copyWith(fontSize: 20),
                    ),
                  ),
                  // Edit Button
                  IconButton(
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.editTask,
                        arguments: {'task': _task},
                      )?.then((updated) {
                        if (updated == true) {
                          _refreshTask();
                        }
                      });
                    },
                    icon: Icon(Icons.edit, color: colorScheme.onSurface),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: Neu.concave(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isDone ? Colors.green : Colors.orange,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isDone ? "SELESAI" : "BELUM SELESAI",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _buildPriorityBadge(context, priority),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: textTheme.titleLarge?.copyWith(fontSize: 22),
                          ),
                        ],
                      ),
                    ),

                    // Description Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: Neu.concave(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Deskripsi",
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: Neu.convex(context),
                            child: Text(
                              description?.isNotEmpty == true
                                  ? description!
                                  : "Tidak ada deskripsi",
                              style: description?.isNotEmpty == true
                                  ? textTheme.bodyMedium
                                  : textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                      fontStyle: FontStyle.italic,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: Neu.concave(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Informasi Task",
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            context,
                            icon: Icons.calendar_today,
                            label: "Tanggal Jatuh Tempo:",
                            value: taskDate != null
                                ? _formatDateDisplay(taskDate)
                                : "Tidak ditentukan",
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            icon: Icons.timelapse,
                            label: "Dibuat pada:",
                            value: createdAt != null
                                ? _formatDateTime(createdAt)
                                : "-",
                          ),
                          if (updatedAt != null) ...[
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              context,
                              icon: Icons.update,
                              label: "Terakhir diupdate:",
                              value: _formatDateTime(updatedAt),
                            ),
                          ],
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            icon: Icons.priority_high,
                            label: "Prioritas:",
                            value: _getPriorityLabel(priority),
                            valueColor: _getPriorityColor(context, priority),
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _toggleCompletion,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: Neu.convex(context).copyWith(
                                boxShadow: [
                                  ...Neu.convex(context).boxShadow!,
                                  BoxShadow(
                                    color: (isDone ? Colors.orange : Colors.green)
                                        .withAlpha((0.3 * 255).round()),
                                    offset: const Offset(0, 4),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  isDone
                                      ? "Tandai Belum Selesai"
                                      : "Tandai Selesai",
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: isDone
                                        ? Colors.orange
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () async {
                            final confirm = await Get.dialog(
                              AlertDialog(
                                title: const Text("Hapus Task"),
                                content: Text("Yakin hapus '$title'?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: const Text("Batal"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Get.back(result: true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.error,
                                    ),
                                    child: Text(
                                      "Hapus",
                                      style: TextStyle(
                                          color: colorScheme.onError),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              try {
                                await _taskService.deleteTask(
                                  _task['id'].toString(),
                                );
                                if (Get.isSnackbarOpen) {
                                  Get.closeCurrentSnackbar();
                                }
                                Get.back();
                                Get.snackbar(
                                  "Success",
                                  "Task berhasil dihapus",
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                );
                              } catch (e) {
                                Get.snackbar("Error", "Gagal menghapus: $e");
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            decoration: Neu.convex(context).copyWith(
                              boxShadow: [
                                ...Neu.convex(context).boxShadow!,
                                BoxShadow(
                                  color: colorScheme.error.withAlpha(
                                    (0.3 * 255).round(),
                                  ),
                                  offset: const Offset(0, 4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(Icons.delete, color: colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(BuildContext context, String priority) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final (color, label) = _getPriorityInfo(context, priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getPriorityIcon(priority), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  (Color, String) _getPriorityInfo(BuildContext context, String priority) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (priority.toLowerCase()) {
      case 'high':
        return (colorScheme.error, "TINGGI");
      case 'medium':
        return (colorScheme.tertiary, "SEDANG");
      case 'low':
        return (colorScheme.secondary, "RENDAH");
      default:
        return (colorScheme.onSurface.withOpacity(0.5), priority.toUpperCase());
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      case 'low':
        return Icons.check_circle;
      default:
        return Icons.circle;
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

  Color _getPriorityColor(BuildContext context, String priority) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (priority.toLowerCase()) {
      case 'high':
        return colorScheme.error;
      case 'medium':
        return colorScheme.tertiary;
      case 'low':
        return colorScheme.secondary;
      default:
        return colorScheme.onSurface;
    }
  }

  String _formatDateDisplay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(date.year, date.month, date.day);

    if (taskDay == today) {
      return "Hari Ini (${date.day}/${date.month}/${date.year})";
    } else if (taskDay == today.add(const Duration(days: 1))) {
      return "Besok (${date.day}/${date.month}/${date.year})";
    } else if (taskDay == today.subtract(const Duration(days: 1))) {
      return "Kemarin (${date.day}/${date.month}/${date.year})";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateTimeStr;
    }
  }
}
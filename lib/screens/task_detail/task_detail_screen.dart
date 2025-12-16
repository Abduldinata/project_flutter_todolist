// screens/task_detail/task_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';
import '../../services/task_service.dart';
import '../../services/sound_service.dart';
import '../edit_task/edit_task_screen.dart';

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
        // Fetch task terbaru dari database
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
        // Play sound effect
        if (currentStatus) {
          // Unchecking (Complete -> Incomplete)
          SoundService().playSound(SoundType.undo);
        } else {
          // Checking (Incomplete -> Complete)
          SoundService().playSound(SoundType.complete);
        }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan back button dan actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      SoundService().playSound(SoundType.undo);
                      Get.back();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: isDark ? NeuDark.convex : Neu.convex,
                      child: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.white : AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Detail Task",
                      style: AppStyle.title.copyWith(
                        fontSize: 20,
                        color: isDark ? Colors.white : AppColors.text,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      SoundService().playSound(SoundType.tap);
                      Get.to(() => EditTaskScreen(task: _task))?.then((
                        updated,
                      ) {
                        if (updated == true) {
                          _refreshTask();
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: isDark ? NeuDark.convex : Neu.convex,
                      child: Icon(
                        Icons.edit,
                        color: isDark ? Colors.white : AppColors.text,
                      ),
                    ),
                  ),
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
                      decoration: isDark ? NeuDark.concave : Neu.concave,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : Colors.orange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isDone ? "Selesai" : "Belum Selesai",
                                  style: TextStyle(
                                    color: isDone
                                        ? Colors.green
                                        : Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              _buildPriorityBadge(priority),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: AppStyle.title.copyWith(
                              fontSize: 22,
                              color: isDark ? Colors.white : AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Description Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: isDark ? NeuDark.concave : Neu.concave,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Deskripsi",
                            style: AppStyle.subtitle.copyWith(
                              fontSize: 16,
                              color: isDark ? Colors.white : AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: isDark ? NeuDark.convex : Neu.convex,
                            child: Text(
                              description?.isNotEmpty == true
                                  ? description!
                                  : "Tidak ada deskripsi",
                              style: description?.isNotEmpty == true
                                  ? AppStyle.normal.copyWith(
                                      color: isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[700],
                                    )
                                  : AppStyle.smallGray.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[500],
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
                      decoration: isDark ? NeuDark.concave : Neu.concave,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Informasi Task",
                            style: AppStyle.subtitle.copyWith(
                              fontSize: 16,
                              color: isDark ? Colors.white : AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            label: "Tanggal Jatuh Tempo:",
                            value: taskDate != null
                                ? _formatDateDisplay(taskDate)
                                : "Tidak ditentukan",
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.timelapse,
                            label: "Dibuat pada:",
                            value: createdAt != null
                                ? _formatDateTime(createdAt)
                                : "-",
                          ),
                          if (updatedAt != null) ...[
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              icon: Icons.update,
                              label: "Terakhir diupdate:",
                              value: _formatDateTime(updatedAt),
                            ),
                          ],
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.priority_high,
                            label: "Prioritas:",
                            value: _getPriorityLabel(priority),
                            valueColor: _getPriorityColor(priority),
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
                              decoration: (isDark ? NeuDark.convex : Neu.convex)
                                  .copyWith(
                                    boxShadow: [
                                      ...?(isDark ? NeuDark.convex : Neu.convex)
                                          .boxShadow,
                                      BoxShadow(
                                        color:
                                            (isDone
                                                    ? Colors.orange
                                                    : Colors.green)
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
                                  style: AppStyle.normal.copyWith(
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
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text(
                                      "Hapus",
                                      style: TextStyle(color: Colors.white),
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
                                // Play sound effect
                                SoundService().playSound(SoundType.delete);
                                Get.back(); // Kembali ke screen sebelumnya
                                Get.snackbar(
                                  "Success",
                                  "Task berhasil dihapus",
                                  backgroundColor: Colors.green,
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
                            decoration: (isDark ? NeuDark.convex : Neu.convex)
                                .copyWith(
                                  boxShadow: [
                                    ...?(isDark ? NeuDark.convex : Neu.convex)
                                        .boxShadow,
                                    BoxShadow(
                                      color: Colors.red.withAlpha(
                                        (0.3 * 255).round(),
                                      ),
                                      offset: const Offset(0, 4),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                            child: const Icon(Icons.delete, color: Colors.red),
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

  Widget _buildPriorityBadge(String priority) {
    final (color, label) = _getPriorityInfo(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyle.smallGray.copyWith(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppStyle.normal.copyWith(
                  color: valueColor ?? (isDark ? Colors.white : AppColors.text),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  (Color, String) _getPriorityInfo(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return (Colors.red, "High");
      case 'medium':
        return (AppColors.blue, "Medium");
      case 'low':
        return (Colors.green, "Low");
      default:
        return (Colors.grey, "Medium");
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return "High";
      case 'medium':
        return "Medium";
      case 'low':
        return "Low";
      default:
        return "Medium";
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return Colors.red;
      case 'medium':
        return AppColors.blue;
      case 'low':
        return Colors.green;
      default:
        return AppColors.blue;
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

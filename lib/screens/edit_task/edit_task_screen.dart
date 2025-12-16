// screens/edit_task/edit_task_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/theme_tokens.dart';
import '../../services/task_service.dart';
import '../../widgets/loading_widget.dart';
import '../../services/sound_service.dart';

enum Priority { high, medium, low }

class EditTaskScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late DateTime _selectedDate;
  late Priority _selectedPriority;
  final TaskService _taskService = TaskService();
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers dengan data task
    _titleCtrl = TextEditingController(
      text: widget.task['title']?.toString() ?? '',
    );
    _descCtrl = TextEditingController(
      text: widget.task['description']?.toString() ?? '',
    );

    // Parse date
    try {
      final dateStr = widget.task['date']?.toString();
      if (dateStr != null) {
        _selectedDate = DateTime.parse(dateStr);
      } else {
        _selectedDate = DateTime.now();
      }
    } catch (e) {
      _selectedDate = DateTime.now();
    }

    // Parse priority
    final priorityStr =
        widget.task['priority']?.toString().toLowerCase() ?? 'medium';
    _selectedPriority = _stringToPriority(priorityStr);
  }

  Priority _stringToPriority(String str) {
    switch (str) {
      case 'high':
        return Priority.high;
      case 'low':
        return Priority.low;
      default:
        return Priority.medium;
    }
  }

  String _priorityToString(Priority priority) {
    switch (priority) {
      case Priority.high:
        return "high";
      case Priority.medium:
        return "medium";
      case Priority.low:
        return "low";
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> _updateTask() async {
    if (_titleCtrl.text.isEmpty) {
      Get.snackbar("Error", "Nama tugas tidak boleh kosong");
      return;
    }

    setState(() => _loading = true);
    try {
      final taskId = widget.task['id']?.toString();
      if (taskId == null) throw "Task ID tidak valid";

      await _taskService.updateTask(
        taskId: taskId,
        title: _titleCtrl.text,
        description: _descCtrl.text.isEmpty ? null : _descCtrl.text,
        date: _selectedDate,
        priority: _priorityToString(_selectedPriority),
      );

      SoundService().playSound(SoundType.success);
      Get.back(result: true); // Kirim signal bahwa task diupdate
      Get.snackbar("Success", "Task berhasil diupdate");
    } catch (e) {
      Get.snackbar("Error", "Gagal update: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildPriorityButton(BuildContext context, Priority priority) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedPriority == priority;

    final bgColor = isSelected ? scheme.primary : scheme.surface;
    final textColor = isSelected
        ? scheme.onPrimary
        : scheme.onSurface.withValues(alpha: 0.8);

    String label;
    switch (priority) {
      case Priority.high:
        label = "High";
        break;
      case Priority.medium:
        label = "Medium";
        break;
      case Priority.low:
        label = "Low";
        break;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = priority),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        clipBehavior: Clip.antiAlias,
        decoration:
            (isSelected
                    ? (isDark ? NeuDark.pressed : Neu.pressed)
                    : (isDark ? NeuDark.convex : Neu.convex))
                .copyWith(
                  color: bgColor,
                  border: Border.all(
                    color: isSelected
                        ? (isDark
                              ? scheme.primary.withValues(alpha: 0.5)
                              : scheme.primary.withValues(alpha: 0.3))
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.2)),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
        child: Text(
          label,
          style: AppStyle.normal.copyWith(
            color: textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final surface = scheme.surface;
    final textColor = scheme.onSurface;
    final hintColor = scheme.onSurface.withValues(alpha: 0.55);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
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
                  Text(
                    "Edit Task",
                    style: AppStyle.title.copyWith(
                      color: isDark ? Colors.white : AppColors.text,
                    ),
                  ),
                  const Spacer(),
                  if (_loading) const LoadingWidget(width: 24, height: 24),
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    clipBehavior: Clip.antiAlias,
                    decoration: (isDark ? NeuDark.concave : Neu.concave)
                        .copyWith(
                          color: surface,
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: (isDark ? NeuDark.convex : Neu.convex)
                              .copyWith(
                                color: surface,
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                          child: TextField(
                            controller: _titleCtrl,
                            style: AppStyle.normal.copyWith(color: textColor),
                            decoration: InputDecoration(
                              hintText: "Nama Tugas*",
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              hintStyle: AppStyle.smallGray.copyWith(
                                color: hintColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Description
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: (isDark ? NeuDark.convex : Neu.convex)
                              .copyWith(
                                color: surface,
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                          child: TextField(
                            controller: _descCtrl,
                            maxLines: 3,
                            style: AppStyle.normal.copyWith(color: textColor),
                            decoration: InputDecoration(
                              hintText: "Deskripsi/Catatan (Opsional)",
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              hintStyle: AppStyle.smallGray.copyWith(
                                color: hintColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Priority
                        Text(
                          "Prioritas:",
                          style: AppStyle.subtitle.copyWith(color: textColor),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPriorityButton(context, Priority.high),
                            _buildPriorityButton(context, Priority.medium),
                            _buildPriorityButton(context, Priority.low),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Date
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              builder: (context, child) {
                                return Theme(
                                  data: theme.copyWith(
                                    dialogTheme: DialogThemeData(
                                      backgroundColor: scheme.surface,
                                    ),
                                    colorScheme: isDark
                                        ? scheme.copyWith(
                                            surface: scheme.surface,
                                            onSurface: Colors.white,
                                          )
                                        : scheme,
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            clipBehavior: Clip.antiAlias,
                            decoration: (isDark ? NeuDark.convex : Neu.convex)
                                .copyWith(
                                  color: surface,
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.grey.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Jatuh Tempo: ${_formatDate(_selectedDate)}",
                                  style: AppStyle.normal.copyWith(
                                    color: textColor,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: textColor,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Cancel
                            GestureDetector(
                              onTap: () {
                                SoundService().playSound(SoundType.undo);
                                Get.back();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 28,
                                ),
                                clipBehavior: Clip.antiAlias,
                                decoration:
                                    (isDark ? NeuDark.convex : Neu.convex)
                                        .copyWith(
                                          color: surface,
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.1,
                                                  )
                                                : Colors.grey.withValues(
                                                    alpha: 0.2,
                                                  ),
                                            width: 1,
                                          ),
                                        ),
                                child: Text(
                                  "Batal",
                                  style: AppStyle.normal.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // Save
                            GestureDetector(
                              onTap: _updateTask,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 28,
                                ),
                                clipBehavior: Clip.antiAlias,
                                decoration:
                                    (isDark ? NeuDark.convex : Neu.convex)
                                        .copyWith(
                                          color: surface,
                                          border: Border.all(
                                            color: scheme.primary.withValues(
                                              alpha: 0.4,
                                            ),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            ...?(isDark
                                                    ? NeuDark.convex
                                                    : Neu.convex)
                                                .boxShadow,
                                            BoxShadow(
                                              color: scheme.primary.withValues(
                                                alpha: 0.35,
                                              ),
                                              offset: const Offset(0, 4),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                child: Text(
                                  "Simpan",
                                  style: AppStyle.normal.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }
}

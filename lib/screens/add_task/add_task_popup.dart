import 'package:flutter/material.dart';
import '../../theme/theme_tokens.dart';
import '../../services/sound_service.dart';

enum Priority { high, medium, low }

class AddTaskPopup extends StatefulWidget {
  const AddTaskPopup({super.key});

  @override
  State<AddTaskPopup> createState() => _AddTaskPopupState();
}

class _AddTaskPopupState extends State<AddTaskPopup> {
  final TextEditingController taskCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  DateTime? selectedDate;
  Priority selectedPriority = Priority.medium;

  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";

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

  String _priorityLabel(Priority p) {
    switch (p) {
      case Priority.high:
        return "Tinggi";
      case Priority.medium:
        return "Sedang";
      case Priority.low:
        return "Rendah";
    }
  }

  Widget _buildPriorityButton(BuildContext context, Priority priority) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedPriority == priority;

    final bgColor = isSelected ? scheme.primary : scheme.surface;
    final textColor = isSelected
        ? scheme.onPrimary
        : scheme.onSurface.withValues(alpha: 0.8);

    return GestureDetector(
      onTap: () => setState(() => selectedPriority = priority),
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
          _priorityLabel(priority),
          style: AppStyle.normal.copyWith(
            color: textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _saveTask() {
    if (taskCtrl.text.trim().isEmpty) {
      _showError("Nama tugas tidak boleh kosong");
      return;
    }
    if (selectedDate == null) {
      _showError("Pilih tanggal jatuh tempo");
      return;
    }

    Navigator.pop(context, {
      "text": taskCtrl.text.trim(),
      "description": descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      "date": selectedDate!,
      "priority": _priorityToString(selectedPriority),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final surface = scheme.surface;
    final textColor = scheme.onSurface;
    final hintColor = scheme.onSurface.withValues(alpha: 0.55);
    final iconHintColor = scheme.onSurface.withValues(alpha: 0.5);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.92),
      body: Center(
        child: Container(
          width: 330,
          padding: const EdgeInsets.all(24),
          clipBehavior: Clip.antiAlias,
          decoration: (isDark ? NeuDark.concave : Neu.concave).copyWith(
            color: surface,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Task",
                style: AppStyle.title.copyWith(color: textColor),
              ),
              const SizedBox(height: 20),

              Container(
                clipBehavior: Clip.antiAlias,
                decoration: (isDark ? NeuDark.convex : Neu.convex).copyWith(
                  color: surface,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: taskCtrl,
                  style: AppStyle.normal.copyWith(color: textColor),
                  decoration: InputDecoration(
                    hintText: "Nama Tugas*",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    hintStyle: AppStyle.smallGray.copyWith(color: hintColor),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Container(
                clipBehavior: Clip.antiAlias,
                decoration: (isDark ? NeuDark.convex : Neu.convex).copyWith(
                  color: surface,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  style: AppStyle.normal.copyWith(color: textColor),
                  decoration: InputDecoration(
                    hintText: "Deskripsi/Catatan (Opsional)",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    hintStyle: AppStyle.smallGray.copyWith(color: hintColor),
                  ),
                ),
              ),
              const SizedBox(height: 18),

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

              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
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
                    setState(() => selectedDate = picked);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: (isDark ? NeuDark.convex : Neu.convex).copyWith(
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
                        selectedDate == null
                            ? "Pilih Tanggal Jatuh Tempo*"
                            : "Jatuh Tempo: ${_formatDate(selectedDate!)}",
                        style: AppStyle.normal.copyWith(
                          color: selectedDate == null ? hintColor : textColor,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today_outlined,
                        color: selectedDate == null ? iconHintColor : textColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                       SoundService().playSound(SoundType.undo);
                       Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 28,
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
                      child: Text(
                        "Batal",
                        style: AppStyle.normal.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: _saveTask,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 28,
                      ),
                      clipBehavior: Clip.antiAlias,
                      decoration: (isDark ? NeuDark.convex : Neu.convex)
                          .copyWith(
                            color: surface,
                            border: Border.all(
                              color: scheme.primary.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              ...?(isDark ? NeuDark.convex : Neu.convex)
                                  .boxShadow,
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.35),
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
    );
  }

  @override
  void dispose() {
    taskCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }
}

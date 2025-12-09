// screens/edit_task/edit_task_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';
import '../../utils/neumorphic_decoration.dart';
import '../../services/task_service.dart';

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
    _titleCtrl = TextEditingController(text: widget.task['title']?.toString() ?? '');
    _descCtrl = TextEditingController(text: widget.task['description']?.toString() ?? '');
    
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
    final priorityStr = widget.task['priority']?.toString()?.toLowerCase() ?? 'medium';
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

      Get.back(result: true); // Kirim signal bahwa task diupdate
      Get.snackbar("Success", "Task berhasil diupdate");
    } catch (e) {
      Get.snackbar("Error", "Gagal update: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildPriorityButton(Priority priority, String label) {
    bool isSelected = _selectedPriority == priority;
    Color accentColor;
    
    switch (priority) {
      case Priority.high:
        accentColor = Colors.red.shade600;
        break;
      case Priority.medium:
        accentColor = Colors.orange.shade600;
        break;
      case Priority.low:
        accentColor = Colors.green.shade600;
        break;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = priority),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: isSelected
            ? Neu.pressed.copyWith(color: accentColor.withOpacity(0.8))
            : Neu.convex,
        child: Text(
          label,
          style: AppStyle.normal.copyWith(
            color: isSelected ? Colors.white : AppColors.text,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: Neu.convex,
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text("Edit Task", style: AppStyle.title),
                  const Spacer(),
                  if (_loading) const CircularProgressIndicator(),
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: Neu.concave,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: Neu.convex,
                          child: TextField(
                            controller: _titleCtrl,
                            decoration: const InputDecoration(
                              hintText: "Nama Tugas",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Description
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: Neu.convex,
                          child: TextField(
                            controller: _descCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: "Deskripsi (Opsional)",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Priority
                        const Text("Prioritas:", style: AppStyle.subtitle),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPriorityButton(Priority.high, "Tinggi"),
                            _buildPriorityButton(Priority.medium, "Sedang"),
                            _buildPriorityButton(Priority.low, "Rendah"),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Date
                        GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            decoration: Neu.convex,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Tanggal: ${_formatDate(_selectedDate)}",
                                  style: AppStyle.normal,
                                ),
                                Icon(Icons.calendar_today_outlined, color: AppColors.text),
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
                              onTap: () => Get.back(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 26,
                                ),
                                decoration: Neu.convex,
                                child: const Text("Batal", style: AppStyle.normal),
                              ),
                            ),

                            // Save
                            GestureDetector(
                              onTap: _updateTask,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 26,
                                ),
                                decoration: Neu.convex.copyWith(
                                  boxShadow: [
                                    ...Neu.convex.boxShadow!,
                                    BoxShadow(
                                      color: AppColors.blue.withOpacity(0.3),
                                      offset: const Offset(0, 4),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "Simpan",
                                  style: AppStyle.normal.copyWith(
                                    color: AppColors.blue,
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
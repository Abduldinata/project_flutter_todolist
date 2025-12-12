// screens/edit_task/edit_task_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/task_service.dart';
import '../../utils/neumorphic_decoration.dart';

enum Priority { high, medium, low }

class EditTaskScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback? onTaskUpdated;

  const EditTaskScreen({
    super.key, 
    required this.task,
    this.onTaskUpdated,
  });

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
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();

    _titleCtrl = TextEditingController(
      text: widget.task['title']?.toString() ?? '',
    );
    _descCtrl = TextEditingController(
      text: widget.task['description']?.toString() ?? '',
    );

    try {
      final dateStr = widget.task['date']?.toString();
      if (dateStr != null && dateStr.isNotEmpty) {
        _selectedDate = DateTime.parse(dateStr);
      } else {
        _selectedDate = DateTime.now();
      }
    } catch (e) {
      _selectedDate = DateTime.now();
    }

    final priorityStr = widget.task['priority']?.toString().toLowerCase() ?? 'medium';
    _selectedPriority = _stringToPriority(priorityStr);
    
    // Listen for changes
    _titleCtrl.addListener(_checkChanges);
    _descCtrl.addListener(_checkChanges);
  }

  void _checkChanges() {
    final hasChanges = 
        _titleCtrl.text != (widget.task['title']?.toString() ?? '') ||
        _descCtrl.text != (widget.task['description']?.toString() ?? '') ||
        _selectedDate.toString().split('T').first != 
          (widget.task['date']?.toString() ?? '').split('T').first ||
        _priorityToString(_selectedPriority) != (widget.task['priority']?.toString() ?? '');
    
    if (_hasChanges != hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  Priority _stringToPriority(String str) {
    switch (str) {
      case 'high':
        return Priority.high;
      case 'low':
        return Priority.low;
      case 'medium':
        return Priority.medium;
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

  // ❌ HAPUS fungsi _formatDate karena tidak digunakan
  // String _formatDate(DateTime date) {
  //   return "${date.day}/${date.month}/${date.year}";
  // }

  Future<void> _updateTask() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      Get.snackbar("Error", "Nama tugas tidak boleh kosong");
      return;
    }

    if (_loading) return;
    
    setState(() => _loading = true);
    try {
      final taskId = widget.task['id']?.toString();
      if (taskId == null) throw "Task ID tidak valid";

      await _taskService.updateTask(
        taskId: taskId,
        title: title,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        date: _selectedDate,
        priority: _priorityToString(_selectedPriority),
      );

      if (widget.onTaskUpdated != null) {
        widget.onTaskUpdated!();
      }
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      Get.back(result: true);
      
      Get.snackbar(
        "Success", 
        "Task berhasil diupdate",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
    } catch (e) {
      Get.snackbar("Error", "Gagal update: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleBack() {
    if (_hasChanges && !_loading) {
      Get.dialog(
        AlertDialog(
          title: const Text("Batal Edit?"),
          content: const Text("Ada perubahan yang belum disimpan. Yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Lanjut Edit"),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: const Text(
                "Keluar",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    } else {
      Get.back();
    }
  }

  // ❌ HAPUS fungsi _buildPriorityButton dan ganti dengan inline widget
  // Widget _buildPriorityButton(BuildContext context, Priority priority, String label) {
  //   ...
  // }

  // Fungsi helper untuk format tanggal yang akan digunakan di UI
  String _formatDateForDisplay(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Helper function untuk priority button (inline di build)
    Widget _buildPriorityButton(Priority priority, String label) {
      bool isSelected = _selectedPriority == priority;
      Color accentColor;
      
      switch (priority) {
        case Priority.high:
          accentColor = colorScheme.error;
          break;
        case Priority.medium:
          accentColor = colorScheme.tertiary;
          break;
        case Priority.low:
          accentColor = colorScheme.secondary;
          break;
      }

      return GestureDetector(
        onTap: () => setState(() => _selectedPriority = priority),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: isSelected
              ? BoxDecoration(
                  color: accentColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                )
              : Neu.convex(context),
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: isSelected ? Colors.white : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _handleBack,
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      decoration: Neu.convex(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: _loading 
                            ? colorScheme.onSurface.withOpacity(0.3)
                            : colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                  
                  Text(
                    "Edit Task",
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  Container(
                    width: 40,
                    child: _loading 
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const SizedBox(),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: Neu.concave(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: Neu.convex(context),
                          child: TextField(
                            controller: _titleCtrl,
                            decoration: InputDecoration(
                              hintText: "Nama Tugas",
                              hintStyle: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                              border: InputBorder.none,
                            ),
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Description
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: Neu.convex(context),
                          child: TextField(
                            controller: _descCtrl,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: "Deskripsi (Opsional)",
                              hintStyle: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                              border: InputBorder.none,
                            ),
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Priority
                        Text("Prioritas:", style: textTheme.titleMedium),
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
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: colorScheme.primary,
                                      onPrimary: colorScheme.onPrimary,
                                      surface: colorScheme.surface,
                                      onSurface: colorScheme.onSurface,
                                    ),
                                    dialogBackgroundColor: colorScheme.surface,
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null && picked != _selectedDate) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            decoration: Neu.convex(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Tanggal: ${_formatDateForDisplay(_selectedDate)}", // ✅ Gunakan fungsi baru
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: colorScheme.onSurface,
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
                            GestureDetector(
                              onTap: _loading ? null : _handleBack,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 26,
                                ),
                                decoration: Neu.convex(context),
                                child: Text(
                                  "Batal",
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: _loading
                                        ? colorScheme.onSurface.withOpacity(0.3)
                                        : colorScheme.onSurface.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: _loading ? null : _updateTask,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 26,
                                ),
                                decoration: _loading
                                    ? Neu.convex(context).copyWith(
                                        color: colorScheme.onSurface.withOpacity(0.1),
                                      )
                                    : Neu.convex(context).copyWith(
                                        boxShadow: [
                                          ...Neu.convex(context).boxShadow!,
                                          BoxShadow(
                                            color: colorScheme.primary.withOpacity(0.4),
                                            offset: const Offset(0, 4),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Text(
                                        "Simpan",
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.primary,
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
    _titleCtrl.removeListener(_checkChanges);
    _descCtrl.removeListener(_checkChanges);
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../utils/app_style.dart';
import '../../utils/neumorphic_decoration.dart';

// Enum untuk Prioritas Tugas
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

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // Helper untuk convert Priority ke String
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

  // Widget untuk tombol Prioritas dengan style Neumorphism
  Widget _buildPriorityButton(Priority priority, String label) {
    bool isSelected = selectedPriority == priority;

    // Tentukan warna aksen berdasarkan prioritas
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
      onTap: () {
        setState(() {
          selectedPriority = priority;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: isSelected
            ? Neu.pressed.copyWith(
                color: accentColor.withAlpha((0.8 * 255).round()),
              )
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _saveTask() {
    // Validasi input
    if (taskCtrl.text.isEmpty) {
      _showError("Nama tugas tidak boleh kosong");
      return;
    }

    if (selectedDate == null) {
      _showError("Pilih tanggal jatuh tempo");
      return;
    }

    Navigator.pop(context, {
      "text": taskCtrl.text,
      "description": descCtrl.text.isEmpty ? null : descCtrl.text,
      "date": selectedDate!,
      "priority": _priorityToString(selectedPriority), // ✅ Kirim priority
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg.withAlpha((0.9 * 255).round()),
      body: Center(
        child: Container(
          width: 330,
          padding: const EdgeInsets.all(22),
          decoration: Neu.concave,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Add Task", style: AppStyle.title),
              const SizedBox(height: 20),

              // 1. Nama Tugas (Task Title) - REQUIRED
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: Neu.convex,
                child: TextField(
                  controller: taskCtrl,
                  decoration: InputDecoration(
                    hintText: "Nama Tugas*",
                    border: InputBorder.none,
                    errorText: taskCtrl.text.isEmpty ? null : null,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 2. Deskripsi Tugas (Task Description) - OPTIONAL
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: Neu.convex,
                child: TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Deskripsi/Catatan (Opsional)",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 3. Pilihan Prioritas - FUTURE FEATURE
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

              // 4. Date selector (Tanggal Jatuh Tempo) - REQUIRED
              GestureDetector(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
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
                        selectedDate == null
                            ? "Pilih Tanggal Jatuh Tempo*"
                            : "Jatuh Tempo: ${_formatDate(selectedDate!)}",
                        style: AppStyle.normal.copyWith(
                          color: selectedDate == null
                              ? Colors.grey
                              : AppColors.text,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today_outlined,
                        color: selectedDate == null
                            ? Colors.grey
                            : AppColors.text,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // Button row (Cancel and Save)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 26,
                      ),
                      decoration: Neu.convex,
                      child: const Text("Batal", style: AppStyle.normal),
                    ),
                  ),

                  // Save Button
                  GestureDetector(
                    onTap: _saveTask,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 26,
                      ),
                      decoration: Neu.convex.copyWith(
                        boxShadow: [
                          ...Neu.convex.boxShadow!,
                          BoxShadow(
                            color: AppColors.blue.withAlpha(128),
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
    );
  }
}

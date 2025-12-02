import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
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
  final TextEditingController descCtrl = TextEditingController(); // Controller baru untuk Deskripsi
  DateTime? selectedDate;
  Priority selectedPriority = Priority.medium; // State untuk Prioritas, default Medium

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
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
            ? Neu.pressed.copyWith(color: accentColor.withOpacity(0.8)) // Efek tertekan dan berwarna jika terpilih
            : Neu.convex, // Efek terangkat jika tidak terpilih
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
      backgroundColor: AppColors.bg.withOpacity(0.9), // Menggunakan AppColors.bg Anda
      body: Center(
        child: Container(
          width: 330,
          padding: const EdgeInsets.all(22),
          decoration: Neu.concave, // Background Neumorphism besar
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Add Task", style: AppStyle.title),
              const SizedBox(height: 20),

              // 1. Nama Tugas (Task Title)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: Neu.convex,
                child: TextField(
                  controller: taskCtrl,
                  decoration: const InputDecoration(
                    hintText: "Nama Tugas (Contoh: Beli Kopi)",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 2. Deskripsi Tugas (Task Description)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: Neu.convex,
                child: TextField(
                  controller: descCtrl,
                  maxLines: 3, // Memungkinkan input deskripsi yang lebih panjang
                  decoration: const InputDecoration(
                    hintText: "Deskripsi/Catatan (Opsional)",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 3. Pilihan Prioritas
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

              // 4. Date selector (Tanggal Jatuh Tempo)
              GestureDetector(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
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
                            ? "Tanggal Jatuh Tempo"
                            : "Jatuh Tempo: ${_formatDate(selectedDate!)}",
                        style: AppStyle.normal,
                      ),
                      Icon(Icons.calendar_today_outlined, color: AppColors.text),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // Button row (Cancel and Save)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 26,
                      ),
                      decoration: Neu.convex,
                      child: const Text("Cancel", style: AppStyle.normal),
                    ),
                  ),

                  // Save
                  GestureDetector(
                    onTap: () {
                      if (taskCtrl.text.isEmpty) {
                        // Secara opsional, tambahkan feedback UI (Toast/Snackbar) di sini
                        return; 
                      }
                      
                      // Mengembalikan data lengkap ke widget pemanggil
                      Navigator.pop(context, {
                        "title": taskCtrl.text,
                        "description": descCtrl.text,
                        "date": selectedDate ?? DateTime.now(),
                        "priority": selectedPriority.name, // Mengirim nama enum (high/medium/low)
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 26,
                      ),
                      decoration: Neu.convex.copyWith(
                        boxShadow: [
                          // Memberikan sedikit warna pada tombol Save (seperti di screenshot Anda)
                          ...Neu.convex.boxShadow!,
                          BoxShadow(
                            color: AppColors.blue.withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        "Save",
                        style: AppStyle.normal.copyWith(color: AppColors.blue, fontWeight: FontWeight.bold),
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
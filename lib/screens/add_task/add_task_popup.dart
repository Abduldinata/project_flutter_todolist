import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';
import '../../utils/neumorphic_decoration.dart';

class AddTaskPopup extends StatefulWidget {
  const AddTaskPopup({super.key});

  @override
  State<AddTaskPopup> createState() => _AddTaskPopupState();
}

class _AddTaskPopupState extends State<AddTaskPopup> {
  final TextEditingController taskCtrl = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg.withValues(alpha: 0.9),
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

              // Textfield
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: Neu.convex,
                child: TextField(
                  controller: taskCtrl,
                  decoration: const InputDecoration(
                    hintText: "Text",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Date selector
              GestureDetector(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
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
                  child: Text(
                    selectedDate == null
                        ? "Today"
                        : "${selectedDate!.day} / ${selectedDate!.month} / ${selectedDate!.year}",
                    style: AppStyle.normal,
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // Button row
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
                      Navigator.pop(context, {
                        "text": taskCtrl.text,
                        "date": selectedDate ?? DateTime.now(),
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 26,
                      ),
                      decoration: Neu.convex,
                      child: Text(
                        "Save",
                        style: AppStyle.normal.copyWith(color: AppColors.blue),
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
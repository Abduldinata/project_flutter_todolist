import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';
import '../../widgets/add_task_button.dart';

class CompletedScreen extends StatefulWidget {
  const CompletedScreen({super.key});

  @override
  State<CompletedScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  int navIndex = 1; // posisi Today jika ingin akses dari Today
  // atau bisa bikin route sendiri tanpa bottom nav

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Completed", style: AppStyle.title),
              const SizedBox(height: 22),

              const Text("✓ text 1", style: AppStyle.normal),
              const Text("✓ text 2", style: AppStyle.normal),
              const Text("✓ text 3", style: AppStyle.normal),
              const Text("✓ text 4", style: AppStyle.normal),

              const SizedBox(height: 26),
              const Text("End", style: AppStyle.subtitle),
            ],
          ),
        ),
      ),

      // Completed TIDAK menggunakan bottom nav — sesuai UI
      // Floating Add Task bisa aktif / bisa nonaktif (opsional)
      floatingActionButton: AddTaskButton(
        onTap: () {
          // buka popup tambah task
        },
      ),
      
    );
  }
}

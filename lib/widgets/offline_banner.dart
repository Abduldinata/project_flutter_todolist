import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';

/// Reusable widget untuk menampilkan offline mode banner
/// Menghilangkan duplikasi di inbox_screen, today_screen, upcoming_screen
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Obx(() {
      if (taskController.isOfflineMode.value) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          color: Colors.orange.withValues(alpha: 0.9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Offline Mode - View only',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}


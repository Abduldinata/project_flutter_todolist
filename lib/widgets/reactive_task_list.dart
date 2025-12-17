import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import 'task_card.dart';

class ReactiveTaskList extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final Function(String taskId, bool currentValue) onToggleCompletion;
  final VoidCallback? onTaskTap;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final Widget? emptyWidget;

  const ReactiveTaskList({
    super.key,
    required this.tasks,
    required this.onToggleCompletion,
    this.onTaskTap,
    this.padding,
    this.physics,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final taskController = Get.find<TaskController>();
      
      if (tasks.isEmpty) {
        return emptyWidget ?? const SizedBox.shrink();
      }

      return ListView.builder(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
        physics: physics ?? const BouncingScrollPhysics(),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final updatedTask = taskController.allTasks.firstWhere(
            (t) => t['id']?.toString() == task['id']?.toString(),
            orElse: () => task,
          );
          
          return TaskCard(
            task: updatedTask,
            onToggleCompletion: onToggleCompletion,
            onTap: onTaskTap,
          );
        },
      );
    });
  }
}


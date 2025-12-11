import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AddTaskButton extends StatelessWidget {
  final Function() onTap;
  const AddTaskButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.blue,
      shape: const CircleBorder(),
      onPressed: onTap,
      child: const Icon(Icons.add, size: 32, color: Colors.white),
    );
  }
}

import 'package:flutter/material.dart';

class AddTaskButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddTaskButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return FloatingActionButton(
      onPressed: onTap,
      tooltip: 'Tambah Task',
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 6,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, size: 32),
    );
  }
}

import 'package:flutter/material.dart';
import '../../domain/enums/task_priority.dart';

class PriorityChipWidget extends StatelessWidget {
  final TaskPriority priority;
  const PriorityChipWidget({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case TaskPriority.low:
        color = Colors.green;
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        break;
      case TaskPriority.high:
        color = Colors.red;
        break;
    }
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      label: Text(priority.displayName, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}

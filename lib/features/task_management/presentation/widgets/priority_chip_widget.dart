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
      label: Text(priority.displayName),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}

import 'package:flutter/material.dart';

enum TaskFilter {
  all(
    displayName: 'All Tasks',
    icon: Icons.copy_all,
  ),
  completed(
    displayName: 'Completed',
    icon: Icons.check_circle_outline,
  ),
  pending(
    displayName: 'Pending',
    icon: Icons.pending_actions,
  );

  const TaskFilter({
    required this.displayName,
    required this.icon,
  });

  final String displayName;
  final IconData icon;
}

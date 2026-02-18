import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task_entity.dart';
import 'priority_chip_widget.dart';

class TaskItemWidget extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  const TaskItemWidget({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  String _formatDate() {
    if (task.dueDate == null) return '';
    return DateFormat('dd/MM/yyyy').format(task.dueDate!);
  }

  String _formatTimeRange(BuildContext context) {
    if (task.startTime == null || task.endTime == null) {
      return '';
    }
    final start = task.startTime!.format(context);
    final end = task.endTime!.format(context);
    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;
    final hasTimeRange = task.startTime != null && task.endTime != null;

    return Dismissible(
      key: ValueKey(task.id),
      direction:
          isCompleted ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: isCompleted ? null : (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Checkbox(
              key: ValueKey(task.isCompleted),
              value: task.isCompleted,
              onChanged: (_) => onToggleComplete(),
            ),
          ),
          title: Text(
            task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              // Date and Time Range Row
              if (task.dueDate != null)
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 13, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (hasTimeRange) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.access_time,
                          size: 13,
                          color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatTimeRange(context),
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              // Description
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
              // Priority
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: PriorityChipWidget(priority: task.priority),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: isCompleted ? null : onTap,
            color: isCompleted ? Colors.grey : null,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ),
      ),
    );
  }
}

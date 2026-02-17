import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;
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
        child: ListTile(
          onTap: onTap,
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description != null && task.description!.isNotEmpty)
                Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              Row(
                children: [
                  PriorityChipWidget(priority: task.priority),
                  const SizedBox(width: 16),
                  if (task.dueDate != null) ...[
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text(
                      '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: isCompleted ? null : onTap,
            color: isCompleted ? Colors.grey : null,
          ),
        ),
      ),
    );
  }
}

import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/enums/task_filter.dart';

sealed class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

final class TaskInitial extends TaskState {
  const TaskInitial();
}

final class TaskLoading extends TaskState {
  const TaskLoading();
}

final class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;
  final TaskFilter currentFilter;

  const TaskLoaded({
    required this.tasks,
    this.currentFilter = TaskFilter.all,
  });

  List<TaskEntity> get filteredTasks {
    switch (currentFilter) {
      case TaskFilter.all:
        return tasks;
      case TaskFilter.completed:
        return tasks.where((task) => task.isCompleted).toList();
      case TaskFilter.pending:
        return tasks.where((task) => !task.isCompleted).toList();
    }
  }

  @override
  List<Object?> get props => [tasks, currentFilter];

  TaskLoaded copyWith({
    List<TaskEntity>? tasks,
    TaskFilter? currentFilter,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

final class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

final class TaskOperationInProgress extends TaskState {
  final List<TaskEntity> currentTasks;
  final TaskFilter currentFilter;

  const TaskOperationInProgress({
    required this.currentTasks,
    required this.currentFilter,
  });

  @override
  List<Object?> get props => [currentTasks, currentFilter];
}

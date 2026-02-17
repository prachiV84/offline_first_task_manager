import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/enums/task_filter.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/filter_chips_widget.dart';
import '../widgets/task_item_widget.dart';
import 'add_edit_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          BlocBuilder<TaskCubit, TaskState>(
            builder: (context, state) {
              if (state is TaskLoaded) {
                return FilterChipsWidget(
                  currentFilter: state.currentFilter,
                  onFilterChanged: (filter) {
                    context.read<TaskCubit>().changeFilter(filter);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Task list
          Expanded(
            child: BlocBuilder<TaskCubit, TaskState>(
              builder: (context, state) {
                return switch (state) {
                  TaskInitial() => const Center(
                      child: Text('Welcome! Loading your tasks...'),
                    ),
                  TaskLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  TaskError(:final message) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(message, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<TaskCubit>().loadTasks(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  TaskOperationInProgress(
                    :final currentTasks,
                    :final currentFilter
                  ) =>
                    _buildTaskList(
                      context,
                      _filterTasks(currentTasks, currentFilter),
                      isLoading: true,
                    ),
                  TaskLoaded(:final filteredTasks) => filteredTasks.isEmpty
                      ? const EmptyStateWidget()
                      : _buildTaskList(context, filteredTasks),
                };
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    List tasks, {
    bool isLoading = false,
  }) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskItemWidget(
              task: task,
              onTap: () => _navigateToEditTask(context, task),
              onToggleComplete: () {
                context.read<TaskCubit>().toggleCompletion(task);
              },
              onDelete: () {
                final cubit = context.read<TaskCubit>();
                cubit.removeTask(task.id);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Task deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        cubit.createTask(task);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
        if (isLoading)
          Container(
            color: Colors.black12,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  List _filterTasks(List tasks, TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return tasks;
      case TaskFilter.completed:
        return tasks.where((task) => task.isCompleted).toList();
      case TaskFilter.pending:
        return tasks.where((task) => !task.isCompleted).toList();
    }
  }

  void _navigateToAddTask(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TaskCubit>(),
          child: const AddEditTaskScreen(),
        ),
      ),
    );
  }

  void _navigateToEditTask(BuildContext context, task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TaskCubit>(),
          child: AddEditTaskScreen(task: task),
        ),
      ),
    );
  }
}

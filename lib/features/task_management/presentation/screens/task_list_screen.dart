import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/enums/task_filter.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/filter_chips_widget.dart';
import '../widgets/task_item_widget.dart';
import 'add_edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'date';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Master'),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _sortBy = value;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'date', child: Text('Sort by Due Date')),
                    const PopupMenuItem(
                        value: 'priority', child: Text('Sort by Priority')),
                  ],
                  icon: Icon(
                    Icons.filter_alt_outlined,
                    color: Theme.of(context).iconTheme.color,
                    size: 32,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search tasks by title...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
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
            Expanded(
              child: BlocBuilder<TaskCubit, TaskState>(
                builder: (context, state) {
                  List filtered = [];
                  if (state is TaskLoaded) {
                    filtered = state.filteredTasks
                        .where((task) => task.title
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();
                    if (_sortBy == 'priority') {
                      filtered.sort((a, b) =>
                          b.priority.value.compareTo(a.priority.value));
                    } else if (_sortBy == 'date') {
                      filtered.sort((a, b) {
                        if (a.dueDate == null && b.dueDate == null) return 0;
                        if (a.dueDate == null) return 1;
                        if (b.dueDate == null) return -1;
                        return a.dueDate!.compareTo(b.dueDate!);
                      });
                    } else if (_sortBy == 'today') {
                      final today = DateTime.now();
                      filtered = filtered
                          .where((task) =>
                              task.dueDate != null &&
                              task.dueDate!.year == today.year &&
                              task.dueDate!.month == today.month &&
                              task.dueDate!.day == today.day)
                          .toList();
                    } else if (_sortBy == 'upcoming') {
                      final now = DateTime.now();
                      filtered = filtered
                          .where((task) =>
                              task.dueDate != null &&
                              task.dueDate!.isAfter(now))
                          .toList();
                    }
                  }
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
                            const Icon(Icons.error,
                                size: 64, color: Colors.red),
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
                    TaskLoaded() => filtered.isEmpty
                        ? const EmptyStateWidget()
                        : _buildTaskList(context, filtered),
                  };
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddTask(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task', style: TextStyle(fontSize: 16)),
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
                    content: const Text('Task deleted'),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_clean/core/helper/filter_helper.dart';
import 'package:task_manager_clean/features/task_management/domain/entities/task_entity.dart';
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
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchAndFilterBar(),
            _buildFilterChips(),
            _buildTaskList(),
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

  /// Search bar and sort button
  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
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
              const PopupMenuItem(value: 'today', child: Text('Today')),
              const PopupMenuItem(value: 'upcoming', child: Text('Upcoming')),
            ],
            icon: Icon(
              Icons.filter_alt_outlined,
              color: Theme.of(context).iconTheme.color,
              size: 32,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }

  /// Filter chips (All, Completed, Pending)
  Widget _buildFilterChips() {
    return BlocBuilder<TaskCubit, TaskState>(
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
    );
  }

  /// Task list with filtering and sorting
  Widget _buildTaskList() {
    return Expanded(
      child: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          return switch (state) {
            TaskInitial() => const Center(
                child: Text('Welcome! Loading your tasks...'),
              ),
            TaskLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            TaskError(:final message) => _buildErrorState(message),
            TaskOperationInProgress(
              :final currentTasks,
              :final currentFilter
            ) =>
              _buildTaskListContent(
                TaskFilterHelper.filterByStatus(currentTasks, currentFilter),
                isLoading: true,
              ),
            TaskLoaded(
              :final filteredTasks,
              :final currentFilter,
            ) =>
              _buildTaskListContent(
                _applyAllFilters(filteredTasks, currentFilter),
              ),
          };
        },
      ),
    );
  }

  /// Apply search and sort filters to tasks
  List<TaskEntity> _applyAllFilters(
    List<TaskEntity> tasks,
    TaskFilter currentFilter,
  ) {
    // First apply status filter
    final statusFiltered =
        TaskFilterHelper.filterByStatus(tasks, currentFilter);
    // Then apply search and sort
    return TaskFilterHelper.applyFilters(
      statusFiltered,
      _searchQuery,
      _sortBy,
    );
  }

  /// Task list content
  Widget _buildTaskListContent(
    List<TaskEntity> tasks, {
    bool isLoading = false,
  }) {
    return Stack(
      children: [
        tasks.isEmpty
            ? const EmptyStateWidget()
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskItemWidget(
                    task: task,
                    onTap: () => _navigateToEditTask(context, task),
                    onToggleComplete: () {
                      context.read<TaskCubit>().toggleCompletion(task);
                    },
                    onDelete: () => _handleTaskDelete(context, task),
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

  /// Error state
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<TaskCubit>().loadTasks(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Handle task deletion with undo
  void _handleTaskDelete(BuildContext context, TaskEntity task) {
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

  void _navigateToEditTask(BuildContext context, TaskEntity task) {
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

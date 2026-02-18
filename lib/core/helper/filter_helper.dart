import 'package:task_manager_clean/features/task_management/domain/entities/task_entity.dart';
import 'package:task_manager_clean/features/task_management/domain/enums/task_filter.dart'
    show TaskFilter;

class TaskFilterHelper {
  /// Filter tasks based on search query
  static List<TaskEntity> filterBySearch(
    List<TaskEntity> tasks,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return tasks;
    return tasks
        .where((task) =>
            task.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  /// Sort tasks based on sort type
  static List<TaskEntity> sortTasks(
    List<TaskEntity> tasks,
    String sortBy,
  ) {
    final sortedTasks = List<TaskEntity>.from(tasks);

    switch (sortBy) {
      case 'priority':
        sortedTasks
            .sort((a, b) => b.priority.value.compareTo(a.priority.value));
        break;
      case 'date':
        sortedTasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case 'today':
        sortedTasks.retainWhere((task) => _isToday(task.dueDate));
        break;
      case 'upcoming':
        sortedTasks.retainWhere((task) => _isUpcoming(task.dueDate));
        break;
    }
    return sortedTasks;
  }

  /// Apply both search and sort filters
  static List<TaskEntity> applyFilters(
    List<TaskEntity> tasks,
    String searchQuery,
    String sortBy,
  ) {
    var filtered = filterBySearch(tasks, searchQuery);
    return sortTasks(filtered, sortBy);
  }

  /// Check if date is today
  static bool _isToday(DateTime? date) {
    if (date == null) return false;
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  /// Check if date is in the future
  static bool _isUpcoming(DateTime? date) {
    if (date == null) return false;
    return date.isAfter(DateTime.now());
  }

  /// Filter tasks by status (all, completed, pending)
  static List<TaskEntity> filterByStatus(
    List<TaskEntity> tasks,
    TaskFilter filter,
  ) {
    switch (filter) {
      case TaskFilter.all:
        return tasks;
      case TaskFilter.completed:
        return tasks.where((task) => task.isCompleted).toList();
      case TaskFilter.pending:
        return tasks.where((task) => !task.isCompleted).toList();
    }
  }
}

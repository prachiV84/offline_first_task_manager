enum TaskPriority {
  low(value: 0, displayName: 'Low'),
  medium(value: 1, displayName: 'Medium'),
  high(value: 2, displayName: 'High');

  const TaskPriority({
    required this.value,
    required this.displayName,
  });

  final int value;
  final String displayName;

  static TaskPriority fromValue(int value) {
    return TaskPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => TaskPriority.medium,
    );
  }
}

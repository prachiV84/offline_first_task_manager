enum TaskFilter {
  all('All Tasks'),
  completed('Completed'),
  pending('Pending');

  const TaskFilter(this.displayName);

  final String displayName;
}

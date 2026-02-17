import 'package:flutter/material.dart';
import '../../domain/enums/task_filter.dart';

class FilterChipsWidget extends StatelessWidget {
  final TaskFilter currentFilter;
  final ValueChanged<TaskFilter> onFilterChanged;
  const FilterChipsWidget(
      {super.key, required this.currentFilter, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: TaskFilter.values.map((filter) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(filter.displayName),
              selected: currentFilter == filter,
              onSelected: (_) => onFilterChanged(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}

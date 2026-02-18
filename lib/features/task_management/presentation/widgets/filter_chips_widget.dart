import 'package:flutter/material.dart';
import '../../domain/enums/task_filter.dart';

class FilterChipsWidget extends StatelessWidget {
  final TaskFilter currentFilter;
  final ValueChanged<TaskFilter> onFilterChanged;

  const FilterChipsWidget({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Wrap(
        spacing: 12.0,
        children: TaskFilter.values.map((filter) {
          final bool isSelected = currentFilter == filter;

          return ChoiceChip(
            avatar: Icon(
              filter.icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            label: Text(filter.displayName),
            showCheckmark: false,
            selected: isSelected,
            selectedColor: Theme.of(context).primaryColorLight,
            onSelected: (bool selected) => onFilterChanged(filter),
          );
        }).toList(),
      ),
    );
  }
}

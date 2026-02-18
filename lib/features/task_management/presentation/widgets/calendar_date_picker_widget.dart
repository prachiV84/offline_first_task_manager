import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomCalendarDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onPressed;
  final String label;
  final bool isRequired;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CustomCalendarDatePicker({
    super.key,
    required this.selectedDate,
    required this.onPressed,
    this.label = 'Date',
    this.isRequired = false,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  selectedDate == null
                      ? '-'
                      : DateFormat.yMMMd().format(selectedDate!),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

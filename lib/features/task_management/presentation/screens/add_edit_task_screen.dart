import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_clean/features/task_management/presentation/widgets/calendar_date_picker_widget.dart';
import 'package:task_manager_clean/features/task_management/presentation/widgets/calender_time_range_picker.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/enums/task_priority.dart';
import '../cubit/task_cubit.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskEntity? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  TaskPriority _priority = TaskPriority.medium;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');
    _dueDate = task?.dueDate;
    _startTime = task?.startTime;
    _endTime = task?.endTime;
    _priority = task?.priority ?? TaskPriority.medium;
    _isCompleted = task?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate time range if both times are set
      if (_startTime != null && _endTime != null) {
        final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
        final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
        if (startMinutes >= endMinutes) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('End time must be after start time'),
            ),
          );
          return;
        }
      }

      final isEdit = widget.task != null;
      final id = isEdit ? widget.task!.id : const Uuid().v4();
      final now = DateTime.now();
      final task = TaskEntity(
        id: id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dueDate: _dueDate,
        startTime: _startTime,
        endTime: _endTime,
        priority: _priority,
        isCompleted: _isCompleted,
        createdAt: isEdit ? widget.task!.createdAt : now,
        updatedAt: now,
      );
      if (isEdit) {
        context.read<TaskCubit>().modifyTask(task);
      } else {
        context.read<TaskCubit>().createTask(task);
      }
      Navigator.pop(context);
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title *'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Calendar date picker
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Due Date',
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 8),
                  CustomCalendarDatePicker(
                    selectedDate: _dueDate,
                    onPressed: _pickDueDate,
                    label: 'Due Date',
                    isRequired: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Time range picker (only show if date is selected)
              if (_dueDate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time Range',
                      style: Theme.of(context).textTheme.labelSmall,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 8),
                    TimeRangePicker(
                      startTime: _startTime,
                      endTime: _endTime,
                      onStartTimeChanged: (time) {
                        setState(() => _startTime = time);
                      },
                      onEndTimeChanged: (time) {
                        setState(() => _endTime = time);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Priority dropdown
              DropdownButtonFormField<TaskPriority>(
                decoration: const InputDecoration(labelText: 'Priority'),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _priority = value);
                },
              ),
              const SizedBox(height: 16),

              if (widget.task != null)
                CheckboxListTile(
                  value: _isCompleted,
                  onChanged: (val) =>
                      setState(() => _isCompleted = val ?? false),
                  title: const Text('Mark as completed'),
                ),
              const SizedBox(height: 24),

              //  Save button/Add button
              ElevatedButton(
                onPressed: _saveTask,
                child: Text(widget.task == null ? 'Add Task' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

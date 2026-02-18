import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../enums/task_priority.dart';

/// Domain entity representing a task with support for time ranges
class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.startTime,
    required this.endTime,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        dueDate,
        startTime,
        endTime,
        priority,
        isCompleted,
        createdAt,
        updatedAt,
      ];
}

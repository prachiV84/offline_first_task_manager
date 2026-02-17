import 'package:hive/hive.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/enums/task_priority.dart';

part 'task_model.g.dart';

// Data model for Hive storage which is step 1.
// step 2 run flutter pub run build_runner build to generate the adapter (task_model.g.dart)

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final DateTime? dueDate;

  @HiveField(4)
  final int priority;

  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert data model to domain entity
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: TaskPriority.fromValue(priority),
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create data model from domain entity
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      priority: entity.priority.value,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

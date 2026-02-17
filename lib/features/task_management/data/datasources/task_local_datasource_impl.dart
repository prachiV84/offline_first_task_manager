import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/task_model.dart';
import 'task_local_datasource.dart';

/// step 3 Local data source implementation using Hive
class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  static const String boxName = 'tasks_box';
  final Box<TaskModel> taskBox;

  TaskLocalDataSourceImpl({required this.taskBox});

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final tasks = taskBox.values.toList();
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    } catch (e) {
      throw CacheException('Failed to load tasks: [${e.toString()}');
    }
  }

  @override
  Future<void> addTask(TaskModel task) async {
    try {
      await taskBox.put(task.id, task);
    } catch (e) {
      throw CacheException('Failed to add task: [${e.toString()}');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      if (!taskBox.containsKey(task.id)) {
        throw const CacheException('Task not found');
      }
      await taskBox.put(task.id, task);
    } catch (e) {
      throw CacheException('Failed to update task: [${e.toString()}');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await taskBox.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete task: [${e.toString()}');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await taskBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear tasks: [${e.toString()}');
    }
  }
}

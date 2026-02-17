import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class ToggleTaskCompletion implements UseCase<void, TaskEntity> {
  final TaskRepository repository;

  const ToggleTaskCompletion(this.repository);

  @override
  Future<Either<Failure, void>> call(TaskEntity task) async {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now(),
    );

    return await repository.updateTask(updatedTask);
  }
}

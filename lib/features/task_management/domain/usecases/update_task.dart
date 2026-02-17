import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTask implements UseCase<void, TaskEntity> {
  final TaskRepository repository;

  const UpdateTask(this.repository);

  @override
  Future<Either<Failure, void>> call(TaskEntity task) async {
    if (task.title.trim().isEmpty) {
      return const Left(ValidationFailure('Task title cannot be empty'));
    }

    return await repository.updateTask(task);
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/enums/task_filter.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_all_tasks.dart';
import '../../domain/usecases/toggle_task_completion.dart';
import '../../domain/usecases/update_task.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final GetAllTasks getAllTasks;
  final AddTask addTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;
  final ToggleTaskCompletion toggleTaskCompletion;

  TaskCubit({
    required this.getAllTasks,
    required this.addTask,
    required this.updateTask,
    required this.deleteTask,
    required this.toggleTaskCompletion,
  }) : super(const TaskInitial());

  Future<void> loadTasks() async {
    emit(const TaskLoading());
    final result = await getAllTasks(const NoParams());
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => emit(TaskLoaded(tasks: tasks)),
    );
  }

  Future<void> createTask(TaskEntity task) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      emit(TaskOperationInProgress(
        currentTasks: currentState.tasks,
        currentFilter: currentState.currentFilter,
      ));
    }
    final result = await addTask(task);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) => loadTasks(),
    );
  }

  Future<void> modifyTask(TaskEntity task) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      emit(TaskOperationInProgress(
        currentTasks: currentState.tasks,
        currentFilter: currentState.currentFilter,
      ));
    }
    final result = await updateTask(task);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) => loadTasks(),
    );
  }

  /// Delete task
  Future<void> removeTask(String id) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      emit(TaskOperationInProgress(
        currentTasks: currentState.tasks,
        currentFilter: currentState.currentFilter,
      ));
    }
    final result = await deleteTask(id);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) => loadTasks(),
    );
  }

  Future<void> toggleCompletion(TaskEntity task) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final updatedTasks = currentState.tasks.map((t) {
        if (t.id == task.id) {
          return t.copyWith(isCompleted: !t.isCompleted);
        }
        return t;
      }).toList();
      emit(currentState.copyWith(tasks: updatedTasks));
    }
    final result = await toggleTaskCompletion(task);
    result.fold(
      (failure) {
        emit(TaskError(failure.message));
        loadTasks();
      },
      (_) => loadTasks(),
    );
  }

  void changeFilter(TaskFilter filter) {
    final currentState = state;
    if (currentState is TaskLoaded) {
      emit(currentState.copyWith(currentFilter: filter));
    }
  }
}

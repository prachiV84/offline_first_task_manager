import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/task_management/data/datasources/task_local_datasource.dart';
import 'features/task_management/data/datasources/task_local_datasource_impl.dart';
import 'features/task_management/data/models/task_model.dart';
import 'features/task_management/data/repositories/task_repository_impl.dart';
import 'features/task_management/domain/repositories/task_repository.dart';
import 'features/task_management/domain/usecases/add_task.dart';
import 'features/task_management/domain/usecases/delete_task.dart';
import 'features/task_management/domain/usecases/get_all_tasks.dart';
import 'features/task_management/domain/usecases/toggle_task_completion.dart';
import 'features/task_management/domain/usecases/update_task.dart';
import 'features/task_management/presentation/cubit/task_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Task Management
  // Cubit
  sl.registerFactory(
    () => TaskCubit(
      getAllTasks: sl(),
      addTask: sl(),
      updateTask: sl(),
      deleteTask: sl(),
      toggleTaskCompletion: sl(),
    ),
  );
  // Use cases
  sl.registerLazySingleton(() => GetAllTasks(sl()));
  sl.registerLazySingleton(() => AddTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));
  sl.registerLazySingleton(() => ToggleTaskCompletion(sl()));
  // Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(localDataSource: sl()),
  );
  // Data sources
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(taskBox: sl()),
  );
  //! External
  final taskBox = await Hive.openBox<TaskModel>(
    TaskLocalDataSourceImpl.boxName,
  );
  sl.registerLazySingleton(() => taskBox);
}

import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base UseCase interface
/// Follows: Interface Segregation Principle
/// All use cases implement this contract
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// For use cases that don't need parameters
class NoParams {
  const NoParams();
}

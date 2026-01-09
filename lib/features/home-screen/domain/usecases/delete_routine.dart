import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/usecases/usecase.dart';
import 'package:skin_sync/features/home-screen/domain/repositories/routine_repository.dart';

class DeleteRoutine implements UseCase<void, DeleteRoutineParams> {
  final RoutineRepository repository;

  DeleteRoutine(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteRoutineParams params) {
    return repository.deleteRoutine(params.userId, params.routineId);
  }
}

class DeleteRoutineParams extends Equatable {
  final String userId;
  final String routineId;

  const DeleteRoutineParams({
    required this.userId,
    required this.routineId,
  });

  @override
  List<Object?> get props => [userId, routineId];
}

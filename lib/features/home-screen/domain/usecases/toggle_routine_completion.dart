import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/usecases/usecase.dart';
import 'package:skin_sync/features/home-screen/domain/entities/routine_entity.dart';
import 'package:skin_sync/features/home-screen/domain/repositories/routine_repository.dart';

class ToggleRoutineCompletion
    implements UseCase<RoutineEntity, ToggleRoutineCompletionParams> {
  final RoutineRepository repository;

  ToggleRoutineCompletion(this.repository);

  @override
  Future<Either<Failure, RoutineEntity>> call(
    ToggleRoutineCompletionParams params,
  ) {
    return repository.toggleRoutineCompletion(
      userId: params.userId,
      routineId: params.routineId,
      date: params.date,
      completionDates: params.completionDates,
    );
  }
}

class ToggleRoutineCompletionParams extends Equatable {
  final String userId;
  final String routineId;
  final DateTime date;
  final List<DateTime> completionDates;

  const ToggleRoutineCompletionParams({
    required this.userId,
    required this.routineId,
    required this.date,
    required this.completionDates,
  });

  @override
  List<Object?> get props => [userId, routineId, date, completionDates];
}

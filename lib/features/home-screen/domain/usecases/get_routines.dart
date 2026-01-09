import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/usecases/usecase.dart';
import 'package:skin_sync/features/home-screen/domain/entities/routine_entity.dart';
import 'package:skin_sync/features/home-screen/domain/repositories/routine_repository.dart';

class GetRoutines implements UseCase<List<RoutineEntity>, GetRoutinesParams> {
  final RoutineRepository repository;

  GetRoutines(this.repository);

  @override
  Future<Either<Failure, List<RoutineEntity>>> call(GetRoutinesParams params) {
    return repository.getRoutines(params.userId);
  }
}

class GetRoutinesParams extends Equatable {
  final String userId;

  const GetRoutinesParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

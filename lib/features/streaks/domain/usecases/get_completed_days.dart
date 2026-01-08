import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/usecases/usecase.dart';
import 'package:skin_sync/features/streaks/domain/repositories/streaks_repository.dart';

class GetCompletedDays implements UseCase<List<String>, GetCompletedDaysParams> {
  final StreaksRepository repository;

  GetCompletedDays(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(GetCompletedDaysParams params) {
    return repository.getCompletedDays(params.userId);
  }
}

class GetCompletedDaysParams extends Equatable {
  final String userId;

  const GetCompletedDaysParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

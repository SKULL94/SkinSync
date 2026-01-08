import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/usecases/usecase.dart';
import 'package:skin_sync/features/history/domain/entities/history_entity.dart';
import 'package:skin_sync/features/history/domain/repositories/history_repository.dart';

class GetHistories implements UseCase<List<HistoryEntity>, GetHistoriesParams> {
  final HistoryRepository repository;

  GetHistories(this.repository);

  @override
  Future<Either<Failure, List<HistoryEntity>>> call(GetHistoriesParams params) {
    return repository.getHistories(params.userId);
  }
}

class GetHistoriesParams extends Equatable {
  final String userId;

  const GetHistoriesParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/usecases/usecase.dart';
import 'package:skin_sync/features/history/domain/repositories/history_repository.dart';

class SyncHistories implements UseCase<void, SyncHistoriesParams> {
  final HistoryRepository repository;

  SyncHistories(this.repository);

  @override
  Future<Either<Failure, void>> call(SyncHistoriesParams params) {
    return repository.syncHistories(params.userId);
  }
}

class SyncHistoriesParams extends Equatable {
  final String userId;

  const SyncHistoriesParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

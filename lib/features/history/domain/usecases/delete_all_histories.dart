import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/usecases/usecase.dart';
import 'package:skin_sync/features/history/domain/repositories/history_repository.dart';

class DeleteAllHistories implements UseCase<void, DeleteAllHistoriesParams> {
  final HistoryRepository repository;

  DeleteAllHistories(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteAllHistoriesParams params) {
    return repository.deleteAllHistories(params.userId);
  }
}

class DeleteAllHistoriesParams extends Equatable {
  final String userId;

  const DeleteAllHistoriesParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

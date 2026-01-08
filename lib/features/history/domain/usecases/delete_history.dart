import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/usecases/usecase.dart';
import 'package:skin_sync/features/history/domain/repositories/history_repository.dart';

class DeleteHistory implements UseCase<void, DeleteHistoryParams> {
  final HistoryRepository repository;

  DeleteHistory(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteHistoryParams params) {
    return repository.deleteHistory(params.id);
  }
}

class DeleteHistoryParams extends Equatable {
  final String id;

  const DeleteHistoryParams({required this.id});

  @override
  List<Object?> get props => [id];
}

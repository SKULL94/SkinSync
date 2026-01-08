import 'package:dartz/dartz.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/features/history/domain/entities/history_entity.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<HistoryEntity>>> getHistories(String userId);
  Future<Either<Failure, void>> deleteHistory(String id);
  Future<Either<Failure, void>> deleteAllHistories(String userId);
  Future<Either<Failure, void>> syncHistories(String userId);
}

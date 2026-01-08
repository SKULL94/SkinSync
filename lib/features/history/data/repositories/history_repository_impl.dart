import 'package:dartz/dartz.dart';
import 'package:skin_sync/core/error/exceptions.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/services/network_info.dart';
import 'package:skin_sync/features/history/data/datasources/history_local_data_source.dart';
import 'package:skin_sync/features/history/data/datasources/history_remote_data_source.dart';
import 'package:skin_sync/features/history/domain/entities/history_entity.dart';
import 'package:skin_sync/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource localDataSource;
  final HistoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HistoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<HistoryEntity>>> getHistories(
    String userId,
  ) async {
    try {
      final localHistories = await localDataSource.getHistories(userId);
      return Right(localHistories);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHistory(String id) async {
    try {
      await localDataSource.deleteHistory(id);
      await remoteDataSource.deleteHistory(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllHistories(String userId) async {
    try {
      await localDataSource.deleteAllHistories();
      await remoteDataSource.deleteAllHistories(userId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncHistories(String userId) async {
    try {
      final remoteHistories = await remoteDataSource.getHistories(userId);
      final localHistories = await localDataSource.getHistories(userId);

      for (final remoteHistory in remoteHistories) {
        final existsLocally = localHistories.any((h) => h.id == remoteHistory.id);
        if (!existsLocally) {
          await localDataSource.insertHistory(remoteHistory);
        }
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}

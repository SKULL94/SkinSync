import 'package:dartz/dartz.dart';
import 'package:skin_sync/core/error/exceptions.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/services/network_info.dart';
import 'package:skin_sync/features/streaks/data/datasources/streaks_remote_data_source.dart';
import 'package:skin_sync/features/streaks/domain/repositories/streaks_repository.dart';

class StreaksRepositoryImpl implements StreaksRepository {
  final StreaksRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  StreaksRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<String>>> getCompletedDays(String userId) async {
    try {
      final completedDays = await remoteDataSource.getCompletedDays(userId);
      return Right(completedDays);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}

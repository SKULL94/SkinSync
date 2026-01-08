import 'package:dartz/dartz.dart';
import 'package:skin_sync/core/error/failures.dart';

abstract class StreaksRepository {
  Future<Either<Failure, List<String>>> getCompletedDays(String userId);
}

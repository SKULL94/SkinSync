import 'package:dartz/dartz.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/features/home/domain/entities/dashboard_entity.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardEntity>> getDashboardData();
  Future<Either<Failure, WeatherEntity>> getWeather({
    required double latitude,
    required double longitude,
  });
  Future<Either<Failure, String>> getAIInsight();
}

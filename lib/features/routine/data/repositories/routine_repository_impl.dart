import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:skin_sync/core/error/exceptions.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/services/network_info.dart';
import 'package:skin_sync/features/routine/data/datasources/routine_local_data_source.dart';
import 'package:skin_sync/features/routine/data/datasources/routine_remote_data_source.dart';
import 'package:skin_sync/features/routine/data/models/routine_model.dart';
import 'package:skin_sync/features/routine/domain/entities/routine_entity.dart';
import 'package:skin_sync/features/routine/domain/repositories/routine_repository.dart';
import 'package:uuid/uuid.dart';

class RoutineRepositoryImpl implements RoutineRepository {
  final RoutineRemoteDataSource remoteDataSource;
  final RoutineLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final Uuid _uuid = const Uuid();

  RoutineRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<RoutineEntity>>> getRoutines(
    String userId,
  ) async {
    try {
      final routines = await remoteDataSource.getRoutines(userId);
      return Right(routines);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoutineEntity>> createRoutine({
    required String name,
    required String description,
    required TimeOfDay time,
    required String userId,
    required DateTime startDate,
    DateTime? endDate,
    File? iconFile,
  }) async {
    try {
      final routineId = _uuid.v4();
      String? iconPath;

      if (iconFile != null) {
        iconPath = await localDataSource.saveIcon(routineId, iconFile);
      }

      final routine = RoutineModel(
        id: routineId,
        name: name,
        description: description,
        time: time,
        userId: userId,
        createdDate: DateTime.now().toLocal(),
        imagePath: '',
        localIconPath: iconPath ?? '',
        startDate: startDate.toLocal(),
        endDate: endDate?.toLocal(),
        completionDates: const [],
      );

      await remoteDataSource.createRoutine(userId, routine);
      return Right(routine);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRoutine(
    String userId,
    String routineId,
  ) async {
    try {
      await remoteDataSource.deleteRoutine(userId, routineId);
      await localDataSource.deleteIcon(routineId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoutineEntity>> toggleRoutineCompletion({
    required String userId,
    required String routineId,
    required DateTime date,
    required List<DateTime> completionDates,
  }) async {
    try {
      final newDates = List<DateTime>.from(completionDates);
      final dateOnly = DateTime(date.year, date.month, date.day);
      final isCompleted = completionDates.any(
        (d) =>
            d.year == dateOnly.year &&
            d.month == dateOnly.month &&
            d.day == dateOnly.day,
      );

      if (isCompleted) {
        newDates.removeWhere(
          (d) =>
              d.year == dateOnly.year &&
              d.month == dateOnly.month &&
              d.day == dateOnly.day,
        );
      } else {
        newDates.add(dateOnly);
      }

      await remoteDataSource.updateRoutineCompletion(
        userId,
        routineId,
        newDates,
      );

      return Right(
        RoutineEntity(
          id: routineId,
          name: '',
          description: '',
          time: TimeOfDay.now(),
          userId: userId,
          createdDate: DateTime.now(),
          startDate: DateTime.now(),
          completionDates: newDates,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> saveLocalIcon(
    String routineId,
    File iconFile,
  ) async {
    try {
      final path = await localDataSource.saveIcon(routineId, iconFile);
      return Right(path);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}

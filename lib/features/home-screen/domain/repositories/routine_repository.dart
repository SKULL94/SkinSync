import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/features/home-screen/domain/entities/routine_entity.dart';

abstract class RoutineRepository {
  Future<Either<Failure, List<RoutineEntity>>> getRoutines(String userId);
  Future<Either<Failure, RoutineEntity>> createRoutine({
    required String name,
    required String description,
    required TimeOfDay time,
    required String userId,
    required DateTime startDate,
    DateTime? endDate,
    File? iconFile,
  });
  Future<Either<Failure, void>> deleteRoutine(String userId, String routineId);
  Future<Either<Failure, RoutineEntity>> toggleRoutineCompletion({
    required String userId,
    required String routineId,
    required DateTime date,
    required List<DateTime> completionDates,
  });
  Future<Either<Failure, String>> saveLocalIcon(
      String routineId, File iconFile);
}

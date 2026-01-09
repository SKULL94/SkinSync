import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/usecases/usecase.dart';
import 'package:skin_sync/features/home-screen/domain/entities/routine_entity.dart';
import 'package:skin_sync/features/home-screen/domain/repositories/routine_repository.dart';

class CreateRoutine implements UseCase<RoutineEntity, CreateRoutineParams> {
  final RoutineRepository repository;

  CreateRoutine(this.repository);

  @override
  Future<Either<Failure, RoutineEntity>> call(CreateRoutineParams params) {
    return repository.createRoutine(
      name: params.name,
      description: params.description,
      time: params.time,
      userId: params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
      iconFile: params.iconFile,
    );
  }
}

class CreateRoutineParams extends Equatable {
  final String name;
  final String description;
  final TimeOfDay time;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final File? iconFile;

  const CreateRoutineParams({
    required this.name,
    required this.description,
    required this.time,
    required this.userId,
    required this.startDate,
    this.endDate,
    this.iconFile,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        time,
        userId,
        startDate,
        endDate,
        iconFile,
      ];
}

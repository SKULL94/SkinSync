import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/usecases/usecase.dart';
import 'package:skin_sync/features/skin_analysis/domain/entities/analysis_result_entity.dart';
import 'package:skin_sync/features/skin_analysis/domain/repositories/skin_analysis_repository.dart';

class AnalyzeImage
    implements UseCase<List<AnalysisResultEntity>, AnalyzeImageParams> {
  final SkinAnalysisRepository repository;

  AnalyzeImage(this.repository);

  @override
  Future<Either<Failure, List<AnalysisResultEntity>>> call(
    AnalyzeImageParams params,
  ) {
    return repository.analyzeImage(params.imageFile);
  }
}

class AnalyzeImageParams extends Equatable {
  final File imageFile;

  const AnalyzeImageParams({required this.imageFile});

  @override
  List<Object?> get props => [imageFile];
}

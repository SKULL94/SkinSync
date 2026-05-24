import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/usecases/usecase.dart';
import 'package:skin_sync/features/skin_analysis/domain/entities/analysis_result_entity.dart';
import 'package:skin_sync/features/skin_analysis/domain/entities/ai_analysis_entity.dart';
import 'package:skin_sync/features/skin_analysis/domain/repositories/skin_analysis_repository.dart';

class SaveAnalysis implements UseCase<void, SaveAnalysisParams> {
  final SkinAnalysisRepository repository;

  SaveAnalysis(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveAnalysisParams params) {
    return repository.saveAnalysis(
      userId: params.userId,
      imageFile: params.imageFile,
      results: params.results,
      aiAnalysis: params.aiAnalysis,
    );
  }
}

class SaveAnalysisParams extends Equatable {
  final String userId;
  final File imageFile;
  final List<AnalysisResultEntity> results;
  final AIAnalysisEntity? aiAnalysis;

  const SaveAnalysisParams({
    required this.userId,
    required this.imageFile,
    required this.results,
    this.aiAnalysis,
  });

  @override
  List<Object?> get props => [userId, imageFile, results, aiAnalysis];
}

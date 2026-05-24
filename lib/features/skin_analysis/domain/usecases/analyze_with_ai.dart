import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/usecases/usecase.dart';
import 'package:skin_sync/features/skin_analysis/domain/entities/ai_analysis_entity.dart';
import 'package:skin_sync/features/skin_analysis/domain/repositories/skin_analysis_repository.dart';

class AnalyzeWithAI implements UseCase<AIAnalysisEntity, AnalyzeWithAIParams> {
  final SkinAnalysisRepository repository;

  AnalyzeWithAI(this.repository);

  @override
  Future<Either<Failure, AIAnalysisEntity>> call(AnalyzeWithAIParams params) {
    return repository.analyzeWithAI(params.imageFile);
  }
}

class AnalyzeWithAIParams extends Equatable {
  final File imageFile;

  const AnalyzeWithAIParams({required this.imageFile});

  @override
  List<Object?> get props => [imageFile];
}

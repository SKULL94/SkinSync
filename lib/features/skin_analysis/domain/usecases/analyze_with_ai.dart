import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/usecases/usecase.dart';
import 'package:skin_sync/features/skin_analysis/data/models/ai_analysis_model.dart';
import 'package:skin_sync/features/skin_analysis/domain/repositories/skin_analysis_repository.dart';

class AnalyzeWithAI implements UseCase<AIAnalysisModel, AnalyzeWithAIParams> {
  final SkinAnalysisRepository repository;

  AnalyzeWithAI(this.repository);

  @override
  Future<Either<Failure, AIAnalysisModel>> call(AnalyzeWithAIParams params) {
    return repository.analyzeWithAI(params.imageFile);
  }
}

class AnalyzeWithAIParams extends Equatable {
  final File imageFile;

  const AnalyzeWithAIParams({required this.imageFile});

  @override
  List<Object?> get props => [imageFile];
}

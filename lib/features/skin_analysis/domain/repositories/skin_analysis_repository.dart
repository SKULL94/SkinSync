import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/features/skin_analysis/domain/entities/analysis_result_entity.dart';

abstract class SkinAnalysisRepository {
  Future<Either<Failure, List<AnalysisResultEntity>>> analyzeImage(File image);
  Future<Either<Failure, void>> saveAnalysis({
    required String userId,
    required File imageFile,
    required List<AnalysisResultEntity> results,
  });
}

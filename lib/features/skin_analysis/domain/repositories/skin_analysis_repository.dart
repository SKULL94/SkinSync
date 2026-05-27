import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/features/skin_analysis/data/models/analysis_result_model.dart';
import 'package:skin_sync/features/skin_analysis/data/models/ai_analysis_model.dart';

abstract class SkinAnalysisRepository {
  Future<Either<Failure, List<AnalysisResultModel>>> analyzeImage(File image);

  Future<Either<Failure, AIAnalysisModel>> analyzeWithAI(File image);

  Future<Either<Failure, void>> saveAnalysis({
    required String userId,
    required File imageFile,
    required List<AnalysisResultModel> results,
    AIAnalysisModel? aiAnalysis,
  });
}

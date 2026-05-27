import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/features/skin_analysis/data/models/ai_analysis_model.dart';

abstract class SkinAnalysisRepository {
  /// Validates if the image contains valid skin
  Future<Either<Failure, bool>> validateImage(File image);

  /// Analyzes skin image with Gemini AI
  Future<Either<Failure, AIAnalysisModel>> analyzeWithAI(File image);

  /// Saves analysis results
  Future<Either<Failure, void>> saveAnalysis({
    required String userId,
    required File imageFile,
    required AIAnalysisModel aiAnalysis,
  });
}

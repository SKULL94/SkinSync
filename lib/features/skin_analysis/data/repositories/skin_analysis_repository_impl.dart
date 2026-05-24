import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:skin_sync/core/error/exceptions.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/services/network_info.dart';
import 'package:skin_sync/features/skin_analysis/data/datasources/skin_analysis_local_data_source.dart';
import 'package:skin_sync/features/skin_analysis/data/datasources/skin_analysis_remote_data_source.dart';
import 'package:skin_sync/features/skin_analysis/data/models/analysis_result_model.dart';
import 'package:skin_sync/features/skin_analysis/data/models/ai_analysis_model.dart';
import 'package:skin_sync/features/skin_analysis/domain/entities/analysis_result_entity.dart';
import 'package:skin_sync/features/skin_analysis/domain/entities/ai_analysis_entity.dart';
import 'package:skin_sync/features/skin_analysis/domain/repositories/skin_analysis_repository.dart';

class SkinAnalysisRepositoryImpl implements SkinAnalysisRepository {
  final SkinAnalysisLocalDataSource localDataSource;
  final SkinAnalysisRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SkinAnalysisRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<AnalysisResultEntity>>> analyzeImage(
    File image,
  ) async {
    try {
      final results = await localDataSource.analyzeImage(image);
      return Right(results);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AIAnalysisEntity>> analyzeWithAI(File image) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Left(NetworkFailure(message: 'No internet connection'));
      }

      final result = await remoteDataSource.analyzeWithAI(image);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveAnalysis({
    required String userId,
    required File imageFile,
    required List<AnalysisResultEntity> results,
    AIAnalysisEntity? aiAnalysis,
  }) async {
    try {
      final models = results
          .map((r) => AnalysisResultModel.fromEntity(r))
          .toList();

      AIAnalysisModel? aiModel;
      if (aiAnalysis != null) {
        aiModel = AIAnalysisModel(
          overallScore: aiAnalysis.overallScore,
          needsProfessionalAssessment: aiAnalysis.needsProfessionalAssessment,
          metrics: SkinMetricsModel(
            texture: aiAnalysis.metrics.texture,
            clarity: aiAnalysis.metrics.clarity,
            oiliness: aiAnalysis.metrics.oiliness,
            hydration: aiAnalysis.metrics.hydration,
            poreVisibility: aiAnalysis.metrics.poreVisibility,
            firmness: aiAnalysis.metrics.firmness,
          ),
          detectedConcerns: aiAnalysis.detectedConcerns,
          severity: aiAnalysis.severity,
          skinType: aiAnalysis.skinType,
          recommendations: aiAnalysis.recommendations,
          ingredientsToLookFor: aiAnalysis.ingredientsToLookFor,
          aiInsight: aiAnalysis.aiInsight,
          disclaimerRequired: aiAnalysis.disclaimerRequired,
        );
      }

      await remoteDataSource.saveAnalysis(
        userId: userId,
        imageFile: imageFile,
        results: models,
        aiAnalysis: aiModel,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}

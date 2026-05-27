import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:skin_sync/core/error/exceptions.dart';
import 'package:skin_sync/core/error/failures.dart';
import 'package:skin_sync/core/services/network_info.dart';
import 'package:skin_sync/features/skin_analysis/data/datasources/skin_analysis_local_data_source.dart';
import 'package:skin_sync/features/skin_analysis/data/datasources/skin_analysis_remote_data_source.dart';
import 'package:skin_sync/features/skin_analysis/data/models/ai_analysis_model.dart';
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
  Future<Either<Failure, bool>> validateImage(File image) async {
    try {
      // Prepare image (fix orientation)
      final preparedImage = await localDataSource.prepareImage(image);

      // Validate if it's a skin image
      final isValid = await localDataSource.validateSkinImage(preparedImage);

      if (!isValid) {
        return const Left(
          ValidationFailure(message: 'Please capture a clear image of your skin'),
        );
      }

      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AIAnalysisModel>> analyzeWithAI(File image) async {
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
    required AIAnalysisModel aiAnalysis,
  }) async {
    try {
      await remoteDataSource.saveAnalysis(
        userId: userId,
        imageFile: imageFile,
        aiAnalysis: aiAnalysis,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}

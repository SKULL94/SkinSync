import 'dart:io';
import 'package:skin_sync/core/error/exceptions.dart';
import 'package:skin_sync/features/skin_analysis/data/models/analysis_result_model.dart';
import 'package:skin_sync/core/models/skin_analysis_history.dart';
import 'package:skin_sync/core/services/sqflite_database.dart';
import 'package:skin_sync/core/services/supabase_services.dart';

abstract class SkinAnalysisRemoteDataSource {
  Future<void> saveAnalysis({
    required String userId,
    required File imageFile,
    required List<AnalysisResultModel> results,
  });
}

class SkinAnalysisRemoteDataSourceImpl implements SkinAnalysisRemoteDataSource {
  @override
  Future<void> saveAnalysis({
    required String userId,
    required File imageFile,
    required List<AnalysisResultModel> results,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'users/$userId/analysis/$timestamp.jpg';

      final placeholderHistory = SkinAnalysisHistory(
        imageUrl: '',
        results: results.map((r) => r.toMap()).toList(),
        date: DateTime.now(),
        id: userId,
      );

      final dbHelper = DatabaseHelper.instance;
      final localId = await dbHelper.insertAnalysis(placeholderHistory);

      final imageBytes = await imageFile.readAsBytes();
      await SupabaseService.client.storage
          .from('images')
          .uploadBinary(filePath, imageBytes);

      final imageUrl = SupabaseService.client.storage
          .from('images')
          .getPublicUrl(filePath);

      await dbHelper.updateAnalysis(localId, {'imageUrl': imageUrl});

      final completeHistory = SkinAnalysisHistory(
        imageUrl: imageUrl,
        results: placeholderHistory.results,
        date: placeholderHistory.date,
        id: userId,
      );

      await SupabaseService.client
          .from('images')
          .upsert(completeHistory.toMap());
    } catch (e) {
      throw ServerException(message: 'Failed to save analysis: $e');
    }
  }
}

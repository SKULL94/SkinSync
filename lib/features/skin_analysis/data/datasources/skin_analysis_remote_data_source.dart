import 'dart:io';
import 'package:skin_sync/core/config/api_config.dart';
import 'package:skin_sync/core/error/exceptions.dart';
import 'package:skin_sync/core/services/gemini_service.dart';
import 'package:skin_sync/features/skin_analysis/data/models/analysis_result_model.dart';
import 'package:skin_sync/features/skin_analysis/data/models/ai_analysis_model.dart';
import 'package:skin_sync/core/models/skin_analysis_history.dart';
import 'package:skin_sync/core/services/sqflite_database.dart';
import 'package:skin_sync/core/services/supabase_services.dart';

abstract class SkinAnalysisRemoteDataSource {
  Future<void> saveAnalysis({
    required String userId,
    required File imageFile,
    required List<AnalysisResultModel> results,
    AIAnalysisModel? aiAnalysis,
  });

  Future<AIAnalysisModel> analyzeWithAI(File imageFile);
}

class SkinAnalysisRemoteDataSourceImpl implements SkinAnalysisRemoteDataSource {
  GeminiService? _geminiService;

  GeminiService get geminiService {
    _geminiService ??= GeminiService(apiKey: ApiConfig.geminiApiKey);
    return _geminiService!;
  }

  @override
  Future<AIAnalysisModel> analyzeWithAI(File imageFile) async {
    if (!ApiConfig.isGeminiConfigured) {
      throw const ServerException(
        message: 'AI analysis not configured. Please add Gemini API key.',
      );
    }

    return await geminiService.analyzeSkinImage(imageFile);
  }

  @override
  Future<void> saveAnalysis({
    required String userId,
    required File imageFile,
    required List<AnalysisResultModel> results,
    AIAnalysisModel? aiAnalysis,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'users/$userId/analysis/$timestamp.jpg';

      // Combine local results with AI analysis
      final combinedResults = results.map((r) => r.toMap()).toList();

      final placeholderHistory = SkinAnalysisHistory(
        imageUrl: '',
        results: combinedResults,
        date: DateTime.now(),
        id: userId,
        aiAnalysis: aiAnalysis?.toJson(),
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
        aiAnalysis: aiAnalysis?.toJson(),
      );

      await SupabaseService.client
          .from('images')
          .upsert(completeHistory.toMap());
    } catch (e) {
      throw ServerException(message: 'Failed to save analysis: $e');
    }
  }
}

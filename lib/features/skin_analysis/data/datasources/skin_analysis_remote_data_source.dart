import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:skin_sync/core/config/api_config.dart';
import 'package:skin_sync/core/error/exceptions.dart';
import 'package:skin_sync/core/services/gemini_service.dart';
import 'package:skin_sync/features/skin_analysis/data/models/analysis_result_model.dart';
import 'package:skin_sync/features/skin_analysis/data/models/ai_analysis_model.dart';
import 'package:skin_sync/core/models/skin_analysis_history.dart';
import 'package:skin_sync/core/services/sqflite_database.dart';
import 'package:skin_sync/core/services/supabase_services.dart';

abstract class SkinAnalysisRemoteDataSource {
  /// Saves analysis locally first (fast), then syncs to cloud in background
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
      final localImagePath = imageFile.path;

      // Combine local results with AI analysis
      final combinedResults = results.map((r) => r.toMap()).toList();

      final placeholderHistory = SkinAnalysisHistory(
        imageUrl: localImagePath, // Use local path initially
        results: combinedResults,
        date: DateTime.now(),
        id: userId,
        aiAnalysis: aiAnalysis?.toJson(),
      );

      // Save to local DB first (fast) - this allows immediate success feedback
      final dbHelper = DatabaseHelper.instance;
      final localId = await dbHelper.insertAnalysis(placeholderHistory);

      // Sync to cloud in background (don't await)
      _syncToCloud(
        localId: localId,
        userId: userId,
        imageFile: imageFile,
        filePath: filePath,
        combinedResults: combinedResults,
        aiAnalysis: aiAnalysis,
        dbHelper: dbHelper,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to save analysis: $e');
    }
  }

  /// Background sync to Supabase - runs after local save completes
  Future<void> _syncToCloud({
    required int localId,
    required String userId,
    required File imageFile,
    required String filePath,
    required List<Map<String, dynamic>> combinedResults,
    required AIAnalysisModel? aiAnalysis,
    required DatabaseHelper dbHelper,
  }) async {
    try {
      // Upload image to Supabase Storage
      final imageBytes = await imageFile.readAsBytes();
      await SupabaseService.client.storage
          .from('images')
          .uploadBinary(filePath, imageBytes);

      // Get public URL
      final imageUrl = SupabaseService.client.storage
          .from('images')
          .getPublicUrl(filePath);

      // Update local DB with cloud URL and mark as synced
      await dbHelper.updateAnalysis(localId, {
        'imageUrl': imageUrl,
        'is_synced': 1,
      });

      // Insert to Supabase database
      final completeHistory = SkinAnalysisHistory(
        imageUrl: imageUrl,
        results: combinedResults,
        date: DateTime.now(),
        id: userId,
        aiAnalysis: aiAnalysis?.toJson(),
      );

      await SupabaseService.client.from('images').insert(completeHistory.toMap());
    } catch (e) {
      // Mark as not synced for retry later
      await dbHelper.updateAnalysis(localId, {'is_synced': 0});
      // Silently fail - data is safe locally
      debugPrint('Cloud sync failed: $e');
    }
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:skin_sync/core/config/api_config.dart';
import 'package:skin_sync/core/error/exceptions.dart';
import 'package:skin_sync/core/services/gemini_service.dart';
import 'package:skin_sync/core/services/skin_condition_classifier.dart';
import 'package:skin_sync/features/skin_analysis/data/models/ai_analysis_model.dart';
import 'package:skin_sync/core/models/skin_analysis_history.dart';
import 'package:skin_sync/core/services/sqflite_database.dart';
import 'package:skin_sync/core/services/supabase_services.dart';

abstract class SkinAnalysisRemoteDataSource {
  /// Saves analysis locally first (fast), then syncs to cloud in background
  Future<void> saveAnalysis({
    required String userId,
    required File imageFile,
    required AIAnalysisModel aiAnalysis,
  });

  Future<AIAnalysisModel> analyzeWithAI(File imageFile);

  /// Quick offline skin condition check using TFLite model
  Future<SkinConditionResult> checkSkinCondition(File imageFile);
}

class SkinAnalysisRemoteDataSourceImpl implements SkinAnalysisRemoteDataSource {
  GeminiService? _geminiService;
  final SkinConditionClassifier _skinConditionClassifier = SkinConditionClassifier();

  GeminiService get geminiService {
    _geminiService ??= GeminiService(apiKey: ApiConfig.geminiApiKey);
    return _geminiService!;
  }

  @override
  Future<SkinConditionResult> checkSkinCondition(File imageFile) async {
    try {
      return await _skinConditionClassifier.classify(imageFile);
    } catch (e) {
      debugPrint('Skin condition classification failed: $e');
      rethrow;
    }
  }

  @override
  Future<AIAnalysisModel> analyzeWithAI(File imageFile) async {
    if (!ApiConfig.isGeminiConfigured) {
      throw const ServerException(
        message: 'AI analysis not configured. Please add Gemini API key.',
      );
    }

    // First, get quick skin condition from TFLite model
    SkinConditionResult? conditionResult;
    try {
      conditionResult = await checkSkinCondition(imageFile);
      debugPrint('TFLite Skin Condition: $conditionResult');
    } catch (e) {
      debugPrint('TFLite classification skipped: $e');
    }

    // Then get detailed analysis from Gemini
    final geminiResult = await geminiService.analyzeSkinImage(imageFile);

    // If TFLite detected acne but Gemini didn't include it, add it
    if (conditionResult != null && conditionResult.hasAcne) {
      final concerns = List<String>.from(geminiResult.detectedConcerns);
      if (!concerns.any((c) => c.toLowerCase().contains('acne'))) {
        concerns.insert(0, 'Acne detected (${(conditionResult.confidence * 100).toStringAsFixed(0)}% confidence)');
      }
      return AIAnalysisModel(
        overallScore: geminiResult.overallScore,
        needsProfessionalAssessment: geminiResult.needsProfessionalAssessment,
        metrics: geminiResult.metrics,
        detectedConcerns: concerns,
        severity: conditionResult.confidence > 0.8 ? 'moderate' : geminiResult.severity,
        skinType: geminiResult.skinType,
        recommendations: geminiResult.recommendations,
        ingredientsToLookFor: geminiResult.ingredientsToLookFor,
        aiInsight: geminiResult.aiInsight,
        disclaimerRequired: geminiResult.disclaimerRequired,
      );
    }

    return geminiResult;
  }

  @override
  Future<void> saveAnalysis({
    required String userId,
    required File imageFile,
    required AIAnalysisModel aiAnalysis,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'users/$userId/analysis/$timestamp.jpg';
      final localImagePath = imageFile.path;

      // Convert AI analysis to results format for storage
      final resultsFromAI = _convertAIAnalysisToResults(aiAnalysis);

      final placeholderHistory = SkinAnalysisHistory(
        imageUrl: localImagePath,
        results: resultsFromAI,
        date: DateTime.now(),
        id: userId,
        aiAnalysis: aiAnalysis.toJson(),
      );

      // Save to local DB first (fast)
      final dbHelper = DatabaseHelper.instance;
      final localId = await dbHelper.insertAnalysis(placeholderHistory);

      // Sync to cloud in background (don't await)
      _syncToCloud(
        localId: localId,
        userId: userId,
        imageFile: imageFile,
        filePath: filePath,
        resultsFromAI: resultsFromAI,
        aiAnalysis: aiAnalysis,
        dbHelper: dbHelper,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to save analysis: $e');
    }
  }

  /// Converts AI analysis to a results list format for storage
  List<Map<String, dynamic>> _convertAIAnalysisToResults(AIAnalysisModel aiAnalysis) {
    return [
      {
        'displayLabel': 'Skin Health Score',
        'confidence': aiAnalysis.overallScore / 100.0,
        'riskLevel': _getSeverityLabel(aiAnalysis.severity),
        'riskColorValue': _getSeverityColor(aiAnalysis.severity),
      },
    ];
  }

  String _getSeverityLabel(String severity) {
    return switch (severity.toLowerCase()) {
      'mild' => 'Good',
      'moderate' => 'Fair',
      'severe' => 'Needs Attention',
      'needs_dermatologist' => 'Consult Professional',
      _ => 'Unknown',
    };
  }

  int _getSeverityColor(String severity) {
    return switch (severity.toLowerCase()) {
      'mild' => 0xFF4CAF50, // Green
      'moderate' => 0xFFFF9800, // Orange
      'severe' => 0xFFF44336, // Red
      'needs_dermatologist' => 0xFF9C27B0, // Purple
      _ => 0xFF9E9E9E, // Grey
    };
  }

  /// Background sync to Supabase
  Future<void> _syncToCloud({
    required int localId,
    required String userId,
    required File imageFile,
    required String filePath,
    required List<Map<String, dynamic>> resultsFromAI,
    required AIAnalysisModel aiAnalysis,
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
        results: resultsFromAI,
        date: DateTime.now(),
        id: userId,
        aiAnalysis: aiAnalysis.toJson(),
      );

      await SupabaseService.client.from('images').insert(completeHistory.toMap());
    } catch (e) {
      // Mark as not synced for retry later
      await dbHelper.updateAnalysis(localId, {'is_synced': 0});
      debugPrint('Cloud sync failed: $e');
    }
  }
}

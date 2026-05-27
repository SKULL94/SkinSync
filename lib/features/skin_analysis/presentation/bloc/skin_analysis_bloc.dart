import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skin_sync/core/config/api_config.dart';
import 'package:skin_sync/core/constants/app_constants.dart';
import 'package:skin_sync/core/services/storage_service.dart';
import 'package:skin_sync/features/skin_analysis/data/models/analysis_result_model.dart';
import 'package:skin_sync/features/skin_analysis/data/models/ai_analysis_model.dart';
import 'package:skin_sync/features/skin_analysis/domain/usecases/analyze_image.dart';
import 'package:skin_sync/features/skin_analysis/domain/usecases/analyze_with_ai.dart';
import 'package:skin_sync/features/skin_analysis/domain/usecases/save_analysis.dart';

part 'skin_analysis_event.dart';
part 'skin_analysis_state.dart';

class SkinAnalysisBloc extends Bloc<SkinAnalysisEvent, SkinAnalysisState> {
  final AnalyzeImage analyzeImage;
  final AnalyzeWithAI analyzeWithAI;
  final SaveAnalysis saveAnalysis;
  final StorageService storageService;

  static const double _minConfidenceForAI = 0.3;

  SkinAnalysisBloc({
    required this.analyzeImage,
    required this.analyzeWithAI,
    required this.saveAnalysis,
    required this.storageService,
  }) : super(const SkinAnalysisState()) {
    on<SkinAnalysisImageSelected>(_onImageSelected);
    on<SkinAnalysisSaveRequested>(_onSaveRequested);
    on<SkinAnalysisShareRequested>(_onShareRequested);
    on<SkinAnalysisReset>(_onReset);
    on<SkinAnalysisScanningStepChanged>(_onScanningStepChanged);
  }

  String? get _userId => storageService.fetch<String>(AppConstants.userId);

  Future<void> _onImageSelected(
    SkinAnalysisImageSelected event,
    Emitter<SkinAnalysisState> emit,
  ) async {
    emit(state.copyWith(
      status: SkinAnalysisStatus.validating,
      selectedImage: event.imageFile,
      clearResults: true,
      clearAIAnalysis: true,
    ));

    // Step 1: Local model validates image
    final localResult = await analyzeImage(
      AnalyzeImageParams(imageFile: event.imageFile),
    );

    final localAnalysis = localResult.fold(
      (failure) {
        emit(state.copyWith(
          status: SkinAnalysisStatus.failure,
          errorMessage: failure.message,
          clearImage: true,
          clearResults: true,
        ));
        return null;
      },
      (results) => results,
    );

    if (localAnalysis == null) return;

    // Check if local model has sufficient confidence
    final hasValidSkinImage = localAnalysis.isNotEmpty &&
        localAnalysis.first.confidence >= _minConfidenceForAI;

    if (!hasValidSkinImage) {
      emit(state.copyWith(
        status: SkinAnalysisStatus.failure,
        errorMessage: 'Please capture a clear image of your skin',
        clearImage: true,
        clearResults: true,
      ));
      return;
    }

    // Step 2: If Gemini is configured, send to AI for detailed analysis
    if (ApiConfig.isGeminiConfigured) {
      emit(state.copyWith(
        status: SkinAnalysisStatus.analyzingWithAI,
        results: localAnalysis,
      ));

      final aiResult = await analyzeWithAI(
        AnalyzeWithAIParams(imageFile: event.imageFile),
      );

      aiResult.fold(
        (failure) {
          // AI failed, but we still have local results
          emit(state.copyWith(
            status: SkinAnalysisStatus.analyzed,
            errorMessage: 'AI analysis unavailable: ${failure.message}',
          ));
        },
        (aiAnalysis) {
          emit(state.copyWith(
            status: SkinAnalysisStatus.analyzed,
            aiAnalysis: aiAnalysis,
          ));
        },
      );
    } else {
      // No AI configured, use local results only
      emit(state.copyWith(
        status: SkinAnalysisStatus.analyzed,
        results: localAnalysis,
      ));
    }
  }

  Future<void> _onSaveRequested(
    SkinAnalysisSaveRequested event,
    Emitter<SkinAnalysisState> emit,
  ) async {
    if (state.selectedImage == null ||
        (state.results.isEmpty && state.aiAnalysis == null)) {
      emit(state.copyWith(
        status: SkinAnalysisStatus.failure,
        errorMessage: 'No analysis to save',
      ));
      return;
    }

    if (_userId == null || _userId!.isEmpty) {
      emit(state.copyWith(
        status: SkinAnalysisStatus.failure,
        errorMessage: 'User not authenticated',
      ));
      return;
    }

    emit(state.copyWith(status: SkinAnalysisStatus.saving));

    final result = await saveAnalysis(SaveAnalysisParams(
      userId: _userId!,
      imageFile: state.selectedImage!,
      results: state.results,
      aiAnalysis: state.aiAnalysis,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: SkinAnalysisStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: SkinAnalysisStatus.saved)),
    );
  }

  Future<void> _onShareRequested(
    SkinAnalysisShareRequested event,
    Emitter<SkinAnalysisState> emit,
  ) async {
    if (state.aiAnalysis == null && state.results.isEmpty) return;

    String message;
    if (state.aiAnalysis != null) {
      final ai = state.aiAnalysis!;
      message = '''
SkinSync AI Analysis Report

Overall Score: ${ai.overallScore}/100
Skin Type: ${ai.skinType}
Severity: ${ai.severity}

Detected Concerns:
${ai.detectedConcerns.map((c) => '• $c').join('\n')}

Recommendations:
${ai.recommendations.map((r) => '• $r').join('\n')}

${ai.aiInsight ?? ''}

Download App: https://skinsync.app/download
''';
    } else {
      final topResult = state.results.first;
      message = '''
SkinSync Analysis Report

Top Result: ${topResult.displayLabel} (${(topResult.confidence * 100).toStringAsFixed(1)}%)
Risk Level: ${topResult.riskLevel}

Download App: https://skinsync.app/download
''';
    }

    await Share.share(message, subject: 'SkinSync Analysis Results');
  }

  void _onReset(
    SkinAnalysisReset event,
    Emitter<SkinAnalysisState> emit,
  ) {
    emit(const SkinAnalysisState());
  }

  void _onScanningStepChanged(
    SkinAnalysisScanningStepChanged event,
    Emitter<SkinAnalysisState> emit,
  ) {
    emit(state.copyWith(scanningStep: event.step));
  }
}

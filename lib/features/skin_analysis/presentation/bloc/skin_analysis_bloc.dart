import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skin_sync/core/config/api_config.dart';
import 'package:skin_sync/core/constants/app_constants.dart';
import 'package:skin_sync/core/services/storage_service.dart';
import 'package:skin_sync/features/skin_analysis/data/models/ai_analysis_model.dart';
import 'package:skin_sync/features/skin_analysis/domain/repositories/skin_analysis_repository.dart';

part 'skin_analysis_event.dart';
part 'skin_analysis_state.dart';

class SkinAnalysisBloc extends Bloc<SkinAnalysisEvent, SkinAnalysisState> {
  final SkinAnalysisRepository repository;
  final StorageService storageService;

  SkinAnalysisBloc({
    required this.repository,
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
      clearAIAnalysis: true,
    ));

    // Step 1: Validate image (is it a skin image?)
    final validationResult = await repository.validateImage(event.imageFile);

    final isValid = validationResult.fold(
      (failure) {
        emit(state.copyWith(
          status: SkinAnalysisStatus.failure,
          errorMessage: failure.message,
          clearImage: true,
        ));
        return false;
      },
      (valid) => valid,
    );

    if (!isValid) return;

    // Step 2: Check if Gemini is configured
    if (!ApiConfig.isGeminiConfigured) {
      emit(state.copyWith(
        status: SkinAnalysisStatus.failure,
        errorMessage: 'AI analysis not configured. Please add Gemini API key.',
        clearImage: true,
      ));
      return;
    }

    // Step 3: Analyze with Gemini AI
    emit(state.copyWith(status: SkinAnalysisStatus.analyzingWithAI));

    final aiResult = await repository.analyzeWithAI(event.imageFile);

    aiResult.fold(
      (failure) {
        emit(state.copyWith(
          status: SkinAnalysisStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (aiAnalysis) {
        emit(state.copyWith(
          status: SkinAnalysisStatus.analyzed,
          aiAnalysis: aiAnalysis,
        ));
      },
    );
  }

  Future<void> _onSaveRequested(
    SkinAnalysisSaveRequested event,
    Emitter<SkinAnalysisState> emit,
  ) async {
    if (state.selectedImage == null || state.aiAnalysis == null) {
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

    final result = await repository.saveAnalysis(
      userId: _userId!,
      imageFile: state.selectedImage!,
      aiAnalysis: state.aiAnalysis!,
    );

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
    if (state.aiAnalysis == null) return;

    final ai = state.aiAnalysis!;
    final message = '''
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

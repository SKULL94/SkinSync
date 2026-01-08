import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skin_sync/core/constants/app_constants.dart';
import 'package:skin_sync/core/services/storage_service.dart';
import 'package:skin_sync/features/skin_analysis/domain/entities/analysis_result_entity.dart';
import 'package:skin_sync/features/skin_analysis/domain/usecases/analyze_image.dart';
import 'package:skin_sync/features/skin_analysis/domain/usecases/save_analysis.dart';

part 'skin_analysis_event.dart';
part 'skin_analysis_state.dart';

class SkinAnalysisBloc extends Bloc<SkinAnalysisEvent, SkinAnalysisState> {
  final AnalyzeImage analyzeImage;
  final SaveAnalysis saveAnalysis;
  final StorageService storageService;

  SkinAnalysisBloc({
    required this.analyzeImage,
    required this.saveAnalysis,
    required this.storageService,
  }) : super(const SkinAnalysisState()) {
    on<SkinAnalysisImageSelected>(_onImageSelected);
    on<SkinAnalysisSaveRequested>(_onSaveRequested);
    on<SkinAnalysisShareRequested>(_onShareRequested);
    on<SkinAnalysisReset>(_onReset);
  }

  String? get _userId => storageService.fetch<String>(AppConstants.userId);

  Future<void> _onImageSelected(
    SkinAnalysisImageSelected event,
    Emitter<SkinAnalysisState> emit,
  ) async {
    emit(state.copyWith(
      status: SkinAnalysisStatus.analyzing,
      selectedImage: event.imageFile,
      clearResults: true,
    ));

    final result = await analyzeImage(
      AnalyzeImageParams(imageFile: event.imageFile),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: SkinAnalysisStatus.failure,
        errorMessage: failure.message,
        clearImage: true,
        clearResults: true,
      )),
      (results) => emit(state.copyWith(
        status: SkinAnalysisStatus.analyzed,
        results: results,
      )),
    );
  }

  Future<void> _onSaveRequested(
    SkinAnalysisSaveRequested event,
    Emitter<SkinAnalysisState> emit,
  ) async {
    if (state.selectedImage == null || state.results.isEmpty) {
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
    if (state.results.isEmpty) return;

    final topResult = state.results.first;
    final message = '''
SkinSync Analysis Report

Top Result: ${topResult.displayLabel} (${(topResult.confidence * 100).toStringAsFixed(1)}%)
Risk Level: ${topResult.riskLevel}

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
}

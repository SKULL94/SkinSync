part of 'skin_analysis_bloc.dart';

enum SkinAnalysisStatus {
  initial,
  validating,      // Local model validating image
  analyzingWithAI, // Gemini analyzing
  analyzed,
  saving,
  saved,
  failure,
}

final class SkinAnalysisState extends Equatable {
  final SkinAnalysisStatus status;
  final File? selectedImage;
  final List<AnalysisResultEntity> results;
  final AIAnalysisEntity? aiAnalysis;
  final String? errorMessage;

  const SkinAnalysisState({
    this.status = SkinAnalysisStatus.initial,
    this.selectedImage,
    this.results = const [],
    this.aiAnalysis,
    this.errorMessage,
  });

  bool get hasAIAnalysis => aiAnalysis != null;

  int get overallScore => aiAnalysis?.overallScore ?? 0;

  SkinAnalysisState copyWith({
    SkinAnalysisStatus? status,
    File? selectedImage,
    List<AnalysisResultEntity>? results,
    AIAnalysisEntity? aiAnalysis,
    String? errorMessage,
    bool clearImage = false,
    bool clearResults = false,
    bool clearAIAnalysis = false,
  }) {
    return SkinAnalysisState(
      status: status ?? this.status,
      selectedImage: clearImage ? null : (selectedImage ?? this.selectedImage),
      results: clearResults ? const [] : (results ?? this.results),
      aiAnalysis: clearAIAnalysis ? null : (aiAnalysis ?? this.aiAnalysis),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, selectedImage, results, aiAnalysis, errorMessage];
}

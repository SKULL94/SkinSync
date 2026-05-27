part of 'skin_analysis_bloc.dart';

enum SkinAnalysisStatus {
  initial,
  validating,      // Validating skin image
  analyzingWithAI, // Gemini analyzing
  analyzed,
  saving,
  saved,
  failure,
}

final class SkinAnalysisState extends Equatable {
  final SkinAnalysisStatus status;
  final File? selectedImage;
  final AIAnalysisModel? aiAnalysis;
  final String? errorMessage;
  final int scanningStep;

  const SkinAnalysisState({
    this.status = SkinAnalysisStatus.initial,
    this.selectedImage,
    this.aiAnalysis,
    this.errorMessage,
    this.scanningStep = 0,
  });

  bool get hasAIAnalysis => aiAnalysis != null;

  int get overallScore => aiAnalysis?.overallScore ?? 0;

  SkinAnalysisState copyWith({
    SkinAnalysisStatus? status,
    File? selectedImage,
    AIAnalysisModel? aiAnalysis,
    String? errorMessage,
    int? scanningStep,
    bool clearImage = false,
    bool clearAIAnalysis = false,
  }) {
    return SkinAnalysisState(
      status: status ?? this.status,
      selectedImage: clearImage ? null : (selectedImage ?? this.selectedImage),
      aiAnalysis: clearAIAnalysis ? null : (aiAnalysis ?? this.aiAnalysis),
      errorMessage: errorMessage,
      scanningStep: scanningStep ?? this.scanningStep,
    );
  }

  @override
  List<Object?> get props => [status, selectedImage, aiAnalysis, errorMessage, scanningStep];
}

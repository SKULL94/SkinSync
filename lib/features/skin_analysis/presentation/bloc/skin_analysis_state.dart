part of 'skin_analysis_bloc.dart';

enum SkinAnalysisStatus {
  initial,
  analyzing,
  analyzed,
  saving,
  saved,
  failure,
}

final class SkinAnalysisState extends Equatable {
  final SkinAnalysisStatus status;
  final File? selectedImage;
  final List<AnalysisResultEntity> results;
  final String? errorMessage;

  const SkinAnalysisState({
    this.status = SkinAnalysisStatus.initial,
    this.selectedImage,
    this.results = const [],
    this.errorMessage,
  });

  SkinAnalysisState copyWith({
    SkinAnalysisStatus? status,
    File? selectedImage,
    List<AnalysisResultEntity>? results,
    String? errorMessage,
    bool clearImage = false,
    bool clearResults = false,
  }) {
    return SkinAnalysisState(
      status: status ?? this.status,
      selectedImage: clearImage ? null : (selectedImage ?? this.selectedImage),
      results: clearResults ? const [] : (results ?? this.results),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, selectedImage, results, errorMessage];
}

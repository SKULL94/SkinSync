part of 'skin_analysis_bloc.dart';

sealed class SkinAnalysisEvent extends Equatable {
  const SkinAnalysisEvent();

  @override
  List<Object?> get props => [];
}

final class SkinAnalysisImageSelected extends SkinAnalysisEvent {
  final File imageFile;

  const SkinAnalysisImageSelected(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

final class SkinAnalysisSaveRequested extends SkinAnalysisEvent {
  const SkinAnalysisSaveRequested();
}

final class SkinAnalysisShareRequested extends SkinAnalysisEvent {
  const SkinAnalysisShareRequested();
}

final class SkinAnalysisReset extends SkinAnalysisEvent {
  const SkinAnalysisReset();
}

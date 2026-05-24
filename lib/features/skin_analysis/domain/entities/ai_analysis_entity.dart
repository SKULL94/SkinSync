import 'package:equatable/equatable.dart';

class AIAnalysisEntity extends Equatable {
  final int overallScore;
  final bool needsProfessionalAssessment;
  final SkinMetrics metrics;
  final List<String> detectedConcerns;
  final String severity;
  final String skinType;
  final List<String> recommendations;
  final List<String> ingredientsToLookFor;
  final String? aiInsight;
  final bool disclaimerRequired;

  const AIAnalysisEntity({
    required this.overallScore,
    required this.needsProfessionalAssessment,
    required this.metrics,
    required this.detectedConcerns,
    required this.severity,
    required this.skinType,
    required this.recommendations,
    required this.ingredientsToLookFor,
    this.aiInsight,
    required this.disclaimerRequired,
  });

  @override
  List<Object?> get props => [
        overallScore,
        needsProfessionalAssessment,
        metrics,
        detectedConcerns,
        severity,
        skinType,
        recommendations,
        ingredientsToLookFor,
        aiInsight,
        disclaimerRequired,
      ];
}

class SkinMetrics extends Equatable {
  final int texture;
  final int clarity;
  final int oiliness;
  final int hydration;
  final int poreVisibility;
  final int firmness;

  const SkinMetrics({
    required this.texture,
    required this.clarity,
    required this.oiliness,
    required this.hydration,
    required this.poreVisibility,
    required this.firmness,
  });

  int get average =>
      ((texture + clarity + oiliness + hydration + poreVisibility + firmness) /
              6)
          .round();

  @override
  List<Object?> get props => [
        texture,
        clarity,
        oiliness,
        hydration,
        poreVisibility,
        firmness,
      ];
}

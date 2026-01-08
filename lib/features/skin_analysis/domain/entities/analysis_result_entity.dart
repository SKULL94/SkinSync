import 'package:equatable/equatable.dart';

class AnalysisResultEntity extends Equatable {
  final String medicalLabel;
  final String displayLabel;
  final String riskLevel;
  final int riskColorValue;
  final double confidence;

  const AnalysisResultEntity({
    required this.medicalLabel,
    required this.displayLabel,
    required this.riskLevel,
    required this.riskColorValue,
    required this.confidence,
  });

  @override
  List<Object?> get props => [
        medicalLabel,
        displayLabel,
        riskLevel,
        riskColorValue,
        confidence,
      ];
}

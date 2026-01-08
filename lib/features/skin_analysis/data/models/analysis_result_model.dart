import 'package:skin_sync/features/skin_analysis/domain/entities/analysis_result_entity.dart';

class AnalysisResultModel extends AnalysisResultEntity {
  const AnalysisResultModel({
    required super.medicalLabel,
    required super.displayLabel,
    required super.riskLevel,
    required super.riskColorValue,
    required super.confidence,
  });

  factory AnalysisResultModel.fromMap(Map<String, dynamic> map) {
    return AnalysisResultModel(
      medicalLabel: map['medicalLabel'] as String,
      displayLabel: map['displayLabel'] as String,
      riskLevel: map['riskLevel'] as String,
      riskColorValue: map['riskColorValue'] as int,
      confidence: (map['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicalLabel': medicalLabel,
      'displayLabel': displayLabel,
      'riskLevel': riskLevel,
      'riskColorValue': riskColorValue,
      'confidence': confidence,
    };
  }

  factory AnalysisResultModel.fromEntity(AnalysisResultEntity entity) {
    return AnalysisResultModel(
      medicalLabel: entity.medicalLabel,
      displayLabel: entity.displayLabel,
      riskLevel: entity.riskLevel,
      riskColorValue: entity.riskColorValue,
      confidence: entity.confidence,
    );
  }
}

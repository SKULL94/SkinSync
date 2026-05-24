import 'dart:convert';
import 'package:skin_sync/features/skin_analysis/domain/entities/ai_analysis_entity.dart';

class AIAnalysisModel extends AIAnalysisEntity {
  const AIAnalysisModel({
    required super.overallScore,
    required super.needsProfessionalAssessment,
    required super.metrics,
    required super.detectedConcerns,
    required super.severity,
    required super.skinType,
    required super.recommendations,
    required super.ingredientsToLookFor,
    super.aiInsight,
    required super.disclaimerRequired,
  });

  factory AIAnalysisModel.fromJson(Map<String, dynamic> json) {
    final metricsJson = json['metrics'] as Map<String, dynamic>? ?? {};

    return AIAnalysisModel(
      overallScore: _parseScore(json['overall_score']),
      needsProfessionalAssessment:
          json['overall_score'] == 'needs_professional_assessment' ||
              json['needs_professional_assessment'] == true,
      metrics: SkinMetricsModel.fromJson(metricsJson),
      detectedConcerns: _parseStringList(json['detected_concerns']),
      severity: json['severity'] as String? ?? 'mild',
      skinType: json['skin_type'] as String? ?? 'unknown',
      recommendations: _parseStringList(json['recommendations']),
      ingredientsToLookFor: _parseStringList(json['ingredients_to_look_for']),
      aiInsight: json['ai_insight'] as String?,
      disclaimerRequired: json['disclaimer'] == true ||
          json['severity'] == 'severe' ||
          json['severity'] == 'needs_dermatologist',
    );
  }

  static int _parseScore(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  factory AIAnalysisModel.fromJsonString(String jsonString) {
    // Clean up the JSON string - remove markdown code blocks if present
    var cleaned = jsonString.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    }
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();

    final json = jsonDecode(cleaned) as Map<String, dynamic>;
    return AIAnalysisModel.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_score': overallScore,
      'needs_professional_assessment': needsProfessionalAssessment,
      'metrics': {
        'texture': metrics.texture,
        'clarity': metrics.clarity,
        'oiliness': metrics.oiliness,
        'hydration': metrics.hydration,
        'pore_visibility': metrics.poreVisibility,
        'firmness': metrics.firmness,
      },
      'detected_concerns': detectedConcerns,
      'severity': severity,
      'skin_type': skinType,
      'recommendations': recommendations,
      'ingredients_to_look_for': ingredientsToLookFor,
      'ai_insight': aiInsight,
      'disclaimer': disclaimerRequired,
    };
  }
}

class SkinMetricsModel extends SkinMetrics {
  const SkinMetricsModel({
    required super.texture,
    required super.clarity,
    required super.oiliness,
    required super.hydration,
    required super.poreVisibility,
    required super.firmness,
  });

  factory SkinMetricsModel.fromJson(Map<String, dynamic> json) {
    return SkinMetricsModel(
      texture: _parseMetric(json['texture']),
      clarity: _parseMetric(json['clarity']),
      oiliness: _parseMetric(json['oiliness']),
      hydration: _parseMetric(json['hydration']),
      poreVisibility: _parseMetric(json['pore_visibility']),
      firmness: _parseMetric(json['firmness']),
    );
  }

  static int _parseMetric(dynamic value) {
    if (value is int) return value.clamp(0, 100);
    if (value is double) return value.round().clamp(0, 100);
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed.clamp(0, 100);
    }
    return 50; // Default middle value
  }
}

import 'dart:convert';
import 'package:equatable/equatable.dart';

class AIAnalysisModel extends Equatable {
  final int overallScore;
  final bool needsProfessionalAssessment;
  final SkinMetricsModel metrics;
  final List<String> detectedConcerns;
  final String severity;
  final String skinType;
  final List<String> recommendations;
  final List<String> ingredientsToLookFor;
  final String? aiInsight;
  final bool disclaimerRequired;

  const AIAnalysisModel({
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

class SkinMetricsModel extends Equatable {
  final int texture;
  final int clarity;
  final int oiliness;
  final int hydration;
  final int poreVisibility;
  final int firmness;

  const SkinMetricsModel({
    required this.texture,
    required this.clarity,
    required this.oiliness,
    required this.hydration,
    required this.poreVisibility,
    required this.firmness,
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

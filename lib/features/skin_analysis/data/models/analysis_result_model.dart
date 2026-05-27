import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AnalysisResultModel extends Equatable {
  final String medicalLabel;
  final String displayLabel;
  final String riskLevel;
  final int riskColorValue;
  final double confidence;

  const AnalysisResultModel({
    required this.medicalLabel,
    required this.displayLabel,
    required this.riskLevel,
    required this.riskColorValue,
    required this.confidence,
  });

  Color get riskColor => Color(riskColorValue);

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

  @override
  List<Object?> get props => [
        medicalLabel,
        displayLabel,
        riskLevel,
        riskColorValue,
        confidence,
      ];
}

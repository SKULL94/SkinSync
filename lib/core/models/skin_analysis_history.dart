import 'dart:convert';

class SkinAnalysisHistory {
  final String id;
  final String imageUrl;
  final List<Map<String, dynamic>> results;
  final DateTime date;
  final Map<String, dynamic>? aiAnalysis;

  SkinAnalysisHistory({
    required this.id,
    required this.imageUrl,
    required this.results,
    required this.date,
    this.aiAnalysis,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': id,
      'imageUrl': imageUrl,
      'results': _encodeResults(results),
      'date': date.toIso8601String(),
      if (aiAnalysis != null) 'ai_analysis': jsonEncode(aiAnalysis),
    };
  }

  factory SkinAnalysisHistory.fromMap(Map<String, dynamic> map) {
    return SkinAnalysisHistory(
      id: map['user_id'] as String,
      imageUrl: map['imageUrl'] as String,
      results: _decodeResults(map['results'] as String),
      date: DateTime.parse(map['date'] as String),
      aiAnalysis: map['ai_analysis'] != null
          ? _decodeAiAnalysis(map['ai_analysis'])
          : null,
    );
  }

  static String _encodeResults(List<Map<String, dynamic>> results) {
    return jsonEncode(results);
  }

  static List<Map<String, dynamic>> _decodeResults(String results) {
    return (jsonDecode(results) as List).cast<Map<String, dynamic>>();
  }

  static Map<String, dynamic>? _decodeAiAnalysis(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is String) {
      return jsonDecode(value) as Map<String, dynamic>;
    }
    return null;
  }
}

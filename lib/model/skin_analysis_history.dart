import 'dart:convert';

class SkinAnalysisHistory {
  final int? id;
  final String imageUrl;
  final List<Map<String, dynamic>> results;
  final DateTime date;

  SkinAnalysisHistory({
    this.id,
    required this.imageUrl,
    required this.results,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'results': _encodeResults(results),
      'date': date.toIso8601String(),
    };
  }

  factory SkinAnalysisHistory.fromMap(Map<String, dynamic> map) {
    return SkinAnalysisHistory(
      id: map['id'] as int?,
      imageUrl: map['imageUrl'] as String,
      results: _decodeResults(map['results'] as String),
      date: DateTime.parse(map['date'] as String),
    );
  }

  static String _encodeResults(List<Map<String, dynamic>> results) {
    return jsonEncode(results);
  }

  static List<Map<String, dynamic>> _decodeResults(String results) {
    return (jsonDecode(results) as List).cast<Map<String, dynamic>>();
  }
}

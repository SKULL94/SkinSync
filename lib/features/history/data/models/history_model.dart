import 'dart:convert';
import 'package:skin_sync/features/history/domain/entities/history_entity.dart';

class HistoryModel extends HistoryEntity {
  const HistoryModel({
    required super.id,
    required super.imageUrl,
    required super.results,
    required super.date,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      id: map['user_id'] as String,
      imageUrl: map['imageUrl'] as String,
      results: _decodeResults(map['results'] as String),
      date: DateTime.parse(map['date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': id,
      'imageUrl': imageUrl,
      'results': jsonEncode(results),
      'date': date.toIso8601String(),
    };
  }

  static List<Map<String, dynamic>> _decodeResults(String results) {
    return (jsonDecode(results) as List).cast<Map<String, dynamic>>();
  }

  factory HistoryModel.fromEntity(HistoryEntity entity) {
    return HistoryModel(
      id: entity.id,
      imageUrl: entity.imageUrl,
      results: entity.results,
      date: entity.date,
    );
  }
}

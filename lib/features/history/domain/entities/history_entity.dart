import 'package:equatable/equatable.dart';

class HistoryEntity extends Equatable {
  final String id;
  final String imageUrl;
  final List<Map<String, dynamic>> results;
  final DateTime date;
  final Map<String, dynamic>? aiAnalysis;

  const HistoryEntity({
    required this.id,
    required this.imageUrl,
    required this.results,
    required this.date,
    this.aiAnalysis,
  });

  @override
  List<Object?> get props => [id, imageUrl, results, date, aiAnalysis];
}

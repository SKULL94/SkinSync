import 'package:skin_sync/core/error/exceptions.dart';
import 'package:skin_sync/features/history/data/models/history_model.dart';
import 'package:skin_sync/core/models/skin_analysis_history.dart';
import 'package:skin_sync/core/services/sqflite_database.dart';

abstract class HistoryLocalDataSource {
  Future<List<HistoryModel>> getHistories(String userId);
  Future<void> insertHistory(HistoryModel history);
  Future<void> deleteHistory(String id);
  Future<void> deleteAllHistories();
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  final DatabaseHelper databaseHelper;

  HistoryLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<HistoryModel>> getHistories(String userId) async {
    try {
      final histories = await databaseHelper.getUserAnalyses(userId);
      // Map with aiAnalysis and sort by date descending (latest first)
      final mapped = histories.map((h) => HistoryModel(
        id: h.id,
        imageUrl: h.imageUrl,
        results: h.results,
        date: h.date,
        aiAnalysis: h.aiAnalysis,
      )).toList();
      // Sort by date descending
      mapped.sort((a, b) => b.date.compareTo(a.date));
      return mapped;
    } catch (e) {
      throw CacheException(message: 'Failed to load histories: $e');
    }
  }

  @override
  Future<void> insertHistory(HistoryModel history) async {
    try {
      await databaseHelper.insertAnalysis(SkinAnalysisHistory(
        id: history.id,
        imageUrl: history.imageUrl,
        results: history.results,
        date: history.date,
      ));
    } catch (e) {
      throw CacheException(message: 'Failed to insert history: $e');
    }
  }

  @override
  Future<void> deleteHistory(String id) async {
    try {
      await databaseHelper.deleteAnalysis(id);
    } catch (e) {
      throw CacheException(message: 'Failed to delete history: $e');
    }
  }

  @override
  Future<void> deleteAllHistories() async {
    try {
      await databaseHelper.deleteAllAnalyses();
    } catch (e) {
      throw CacheException(message: 'Failed to delete all histories: $e');
    }
  }
}

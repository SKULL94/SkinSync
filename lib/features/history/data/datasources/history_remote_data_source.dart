import 'package:skin_sync/core/error/exceptions.dart';
import 'package:skin_sync/features/history/data/models/history_model.dart';
import 'package:skin_sync/core/services/supabase_services.dart';

abstract class HistoryRemoteDataSource {
  Future<List<HistoryModel>> getHistories(String userId);
  Future<void> deleteHistory(String id);
  Future<void> deleteAllHistories(String userId);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  @override
  Future<List<HistoryModel>> getHistories(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('images')
          .select()
          .eq('user_id', userId);

      return (response as List)
          .map((item) => HistoryModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch histories: $e');
    }
  }

  @override
  Future<void> deleteHistory(String id) async {
    try {
      await SupabaseService.client
          .from('images')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw ServerException(message: 'Failed to delete history: $e');
    }
  }

  @override
  Future<void> deleteAllHistories(String userId) async {
    try {
      await SupabaseService.client
          .from('images')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      throw ServerException(message: 'Failed to delete all histories: $e');
    }
  }
}

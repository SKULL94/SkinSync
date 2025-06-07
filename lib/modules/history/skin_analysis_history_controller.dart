import 'package:get/get.dart';
import 'package:skin_sync/services/supabase_services.dart';
import 'package:skin_sync/utils/app_constants.dart';
import 'package:skin_sync/utils/custom_snackbar.dart';
import 'package:skin_sync/model/skin_analysis_history.dart';
import 'package:skin_sync/services/sqflite_database.dart';
import 'package:skin_sync/services/storage.dart';

class HistoryController extends GetxController {
  final RxList<SkinAnalysisHistory> histories = <SkinAnalysisHistory>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistories();
  }

  Future<void> loadHistories() async {
    try {
      final userId = StorageService.instance.fetch(AppConstants.userId) ?? '';
      final dbHelper = DatabaseHelper.instance;
      histories.assignAll(await dbHelper.getUserAnalyses(userId));
      histories.assignAll(await dbHelper.getAllAnalyses());
      _syncWithSupabase();
    } catch (e) {
      showCustomSnackbar(
        'Error',
        'Failed to load history: ${e.toString()}',
      );
    }
  }

  Future<void> _syncWithSupabase() async {
    try {
      final userId = StorageService.instance.fetch(AppConstants.userId);
      if (userId == null || userId.isEmpty) return;

      final dbHelper = DatabaseHelper.instance;

      // Fetch remote data
      final response = await SupabaseService.client
          .from('images')
          .select()
          .eq('user_id', userId);

      // Merge remote data
      for (final item in response) {
        final remoteHistory = SkinAnalysisHistory.fromMap(item);
        final existsLocally = histories.any((h) => h.id == remoteHistory.id);

        if (!existsLocally) {
          await dbHelper.insertAnalysis(remoteHistory);
        }
      }

      histories.assignAll(await dbHelper.getAllAnalyses());
    } catch (e) {
      print('Supabase sync error: $e');
    }
  }

  Future<void> deleteHistory(String id) async {
    try {
      final dbHelper = DatabaseHelper.instance;

      await dbHelper.deleteAnalysis(id);

      await SupabaseService.client.from('images').delete().eq('id', id);

      histories.removeWhere((h) => h.id == id);
      showCustomSnackbar('Success', 'Analysis deleted');
    } catch (e) {
      showCustomSnackbar('Error', 'Failed to delete: ${e.toString()}');
    }
  }

  // Add this missing method
  Future<void> deleteAllHistories() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final userId = StorageService.instance.fetch(AppConstants.userId);

      // Delete all local records
      await dbHelper.deleteAllAnalyses();

      if (userId != null && userId.isNotEmpty) {
        // Delete all user's records from Supabase
        await SupabaseService.client
            .from('images')
            .delete()
            .eq('user_id', userId);
      }

      // Clear UI list
      histories.clear();

      showCustomSnackbar('Success', 'All history cleared');
    } catch (e) {
      showCustomSnackbar('Error', 'Failed to clear history: ${e.toString()}');
    }
  }
}

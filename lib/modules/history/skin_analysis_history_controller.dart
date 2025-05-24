import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:skin_sync/model/skin_analysis_history.dart';
import 'package:skin_sync/utils/sqflite_database.dart';
import 'package:skin_sync/utils/storage.dart';

class HistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<SkinAnalysisHistory> histories = <SkinAnalysisHistory>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistories();
  }

  Future<void> loadHistories() async {
    final dbHelper = DatabaseHelper.instance;
    histories.assignAll(await dbHelper.getAllAnalyses());
  }

  Future<void> deleteHistory(int id) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.deleteAnalysis(id);
      final userId = StorageService.instance.fetch('userId');
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('skinAnalysis')
          .doc(id.toString())
          .delete();
      histories.removeWhere((h) => h.id == id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete history: ${e.toString()}');
    }
  }

  Future<void> deleteAllHistories() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.deleteAllAnalyses();
      final userId = StorageService.instance.fetch('userId');
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('skinAnalysis')
          .get();

      final batch = _firestore.batch();
      for (final doc in query.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      histories.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear history: ${e.toString()}');
    }
  }
}

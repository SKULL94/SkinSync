import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skin_sync/core/error/exceptions.dart';

abstract class StreaksRemoteDataSource {
  Future<List<String>> getCompletedDays(String userId);
}

class StreaksRemoteDataSourceImpl implements StreaksRemoteDataSource {
  final FirebaseFirestore firestore;

  StreaksRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<String>> getCompletedDays(String userId) async {
    try {
      final userSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userSnapshot.exists) {
        return [];
      }

      final data = userSnapshot.data();
      if (data == null || !data.containsKey('completedDays')) {
        return [];
      }

      return List<String>.from(data['completedDays'] ?? []);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch completed days: $e');
    }
  }
}

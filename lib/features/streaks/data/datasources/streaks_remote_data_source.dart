import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
      final routineSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('routines')
          .get();

      if (routineSnapshot.docs.isEmpty) {
        return [];
      }

      // Count completions per date across all routines
      final Map<String, int> dateCompletionCount = {};
      final int totalRoutines = routineSnapshot.docs.length;
      final dateFormat = DateFormat('yyyy-MM-dd');

      for (final doc in routineSnapshot.docs) {
        final data = doc.data();
        final List<dynamic>? completionDates = data['completionDates'];

        if (completionDates != null) {
          for (final timestamp in completionDates) {
            final date = (timestamp as Timestamp).toDate();
            final dateKey = dateFormat.format(date);

            dateCompletionCount[dateKey] =
                (dateCompletionCount[dateKey] ?? 0) + 1;
          }
        }
      }

      // A day is "completed" only if ALL routines were done that day
      final completedDays = dateCompletionCount.entries
          .where((entry) => entry.value >= totalRoutines)
          .map((entry) => entry.key)
          .toList()
        ..sort();

      return completedDays;
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch completed days: $e',
      );
    }
  }
}

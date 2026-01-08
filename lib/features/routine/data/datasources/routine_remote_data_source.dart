import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skin_sync/core/error/exceptions.dart';
import 'package:skin_sync/features/routine/data/models/routine_model.dart';

abstract class RoutineRemoteDataSource {
  Future<List<RoutineModel>> getRoutines(String userId);
  Future<void> createRoutine(String userId, RoutineModel routine);
  Future<void> deleteRoutine(String userId, String routineId);
  Future<void> updateRoutineCompletion(
    String userId,
    String routineId,
    List<DateTime> completionDates,
  );
}

class RoutineRemoteDataSourceImpl implements RoutineRemoteDataSource {
  final FirebaseFirestore firestore;

  RoutineRemoteDataSourceImpl({required this.firestore});

  CollectionReference _userRoutines(String userId) =>
      firestore.collection('users').doc(userId).collection('routines');

  @override
  Future<List<RoutineModel>> getRoutines(String userId) async {
    try {
      final query = _userRoutines(userId).orderBy('createdDate');

      QuerySnapshot? snapshot;

      try {
        snapshot = await query.get(const GetOptions(source: Source.cache));
      } catch (_) {
        snapshot = null;
      }

      if (snapshot == null || snapshot.docs.isEmpty) {
        snapshot = await query.get(const GetOptions(source: Source.server));
      }

      return snapshot.docs.map((doc) {
        final data = doc.data()! as Map<String, dynamic>;
        return RoutineModel.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch routines: $e');
    }
  }

  @override
  Future<void> createRoutine(String userId, RoutineModel routine) async {
    try {
      await _userRoutines(userId).doc(routine.id).set(routine.toMap());
    } catch (e) {
      throw ServerException(message: 'Failed to create routine: $e');
    }
  }

  @override
  Future<void> deleteRoutine(String userId, String routineId) async {
    try {
      await _userRoutines(userId).doc(routineId).delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete routine: $e');
    }
  }

  @override
  Future<void> updateRoutineCompletion(
    String userId,
    String routineId,
    List<DateTime> completionDates,
  ) async {
    try {
      await _userRoutines(userId).doc(routineId).update({
        'completionDates':
            completionDates.map((d) => Timestamp.fromDate(d)).toList(),
      });
    } catch (e) {
      throw ServerException(message: 'Failed to update routine completion: $e');
    }
  }
}

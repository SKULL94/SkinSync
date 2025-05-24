// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:skin_sync/model/custom_routine.dart';

// class RoutineRepository {
//   final FirebaseFirestore _firestore;

//   RoutineRepository(this._firestore);

//   Future<List<CustomRoutine>> getRoutines(String userId) async {
//     final snapshot = await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('routines')
//         .orderBy('createdDate')
//         .get();

//     return snapshot.docs.map((d) => CustomRoutine.fromMap(d.data())).toList();
//   }

//   Future<void> saveRoutine(String userId, CustomRoutine routine) async {
//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('routines')
//         .doc(routine.id)
//         .set(routine.toMap());
//   }

//   Future<void> deleteRoutine(String userId, String routineId) async {
//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('routines')
//         .doc(routineId)
//         .delete();
//   }

//   Future<void> updateRoutineCompletion(
//     String userId,
//     String routineId,
//     List<DateTime> completionDates,
//     double completionProgress,
//   ) async {
//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('routines')
//         .doc(routineId)
//         .update({
//       'completionDates':
//           completionDates.map((d) => Timestamp.fromDate(d)).toList(),
//       'completionProgress': completionProgress,
//     });
//   }

//   Future<void> updateRoutine(String userId, CustomRoutine routine) async {
//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('routines')
//         .doc(routine.id)
//         .update(routine.toMap());
//   }
// }

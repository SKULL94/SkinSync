// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:uuid/uuid.dart';

// enum RoutineFrequency {
//   daily,
//   weekly,
//   custom
// }

// enum RoutineTime {
//   morning,
//   evening,
//   custom
// }

// enum StepStatus {
//   pending,
//   done,
//   skipped
// }

// class RoutineStep {
//   final String id;
//   final String name;
//   final String description;
//   final int order;
//   StepStatus status;
//   DateTime? completedAt;

//   RoutineStep({
//     String? id,
//     required this.name,
//     required this.description,
//     required this.order,
//     this.status = StepStatus.pending,
//     this.completedAt,
//   }) : id = id ?? const Uuid().v4();

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'description': description,
//       'order': order,
//       'status': status.toString(),
//       'completedAt': completedAt?.toIso8601String(),
//     };
//   }

//   factory RoutineStep.fromJson(Map<String, dynamic> json) {
//     return RoutineStep(
//       id: json['id'],
//       name: json['name'],
//       description: json['description'],
//       order: json['order'],
//       status: StepStatus.values.firstWhere(
//         (e) => e.toString() == json['status'],
//         orElse: () => StepStatus.pending,
//       ),
//       completedAt: json['completedAt'] != null
//           ? DateTime.parse(json['completedAt'])
//           : null,
//     );
//   }
// }

// class Routine {
//   final String id;
//   final String name;
//   final String description;
//   final RoutineFrequency frequency;
//   final RoutineTime time;
//   final List<RoutineStep> steps;
//   final DateTime createdAt;
//   final DateTime? lastCompleted;
//   final String userId;

//   Routine({
//     String? id,
//     required this.name,
//     required this.description,
//     required this.frequency,
//     required this.time,
//     required this.steps,
//     required this.userId,
//     DateTime? createdAt,
//     this.lastCompleted,
//   })  : id = id ?? const Uuid().v4(),
//         createdAt = createdAt ?? DateTime.now();

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'description': description,
//       'frequency': frequency.toString(),
//       'time': time.toString(),
//       'steps': steps.map((step) => step.toJson()).toList(),
//       'createdAt': createdAt.toIso8601String(),
//       'lastCompleted': lastCompleted?.toIso8601String(),
//       'userId': userId,
//     };
//   }

//   factory Routine.fromJson(Map<String, dynamic> json) {
//     return Routine(
//       id: json['id'],
//       name: json['name'],
//       description: json['description'],
//       frequency: RoutineFrequency.values.firstWhere(
//         (e) => e.toString() == json['frequency'],
//       ),
//       time: RoutineTime.values.firstWhere(
//         (e) => e.toString() == json['time'],
//       ),
//       steps: (json['steps'] as List)
//           .map((step) => RoutineStep.fromJson(step))
//           .toList(),
//       createdAt: DateTime.parse(json['createdAt']),
//       lastCompleted: json['lastCompleted'] != null
//           ? DateTime.parse(json['lastCompleted'])
//           : null,
//       userId: json['userId'],
//     );
//   }

//   factory Routine.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return Routine.fromJson({...data, 'id': doc.id});
//   }
// }

// class RoutineItem {
//   final String routineId;
//   final String completedDate;
//   final bool isRoutineDone;
//   final String imagePath;

//   RoutineItem({
//     required this.routineId,
//     required this.completedDate,
//     required this.isRoutineDone,
//     required this.imagePath,
//   });

//   factory RoutineItem.fromJson(Map<String, dynamic> json) => RoutineItem(
//         routineId: json['routineId'],
//         completedDate: json['completedDate'],
//         isRoutineDone: json['isRoutineDone'],
//         imagePath: json['imagePath'],
//       );

//   Map<String, dynamic> toJson() => {
//         'routineId': routineId,
//         'completedDate': completedDate,
//         'isRoutineDone': isRoutineDone,
//         'imagePath': imagePath,
//       };

//   factory RoutineItem.createNew(
//       {required String routineId,
//       required String completedDate,
//       required bool isRoutineDone,
//       required String imagePath}) {
//     return RoutineItem(
//       routineId: routineId,
//       completedDate: completedDate,
//       isRoutineDone: isRoutineDone,
//       imagePath: imagePath,
//     );
//   }
// }

// class RoutineStaticData {
//   String name = "";
//   String desc = "";

//   RoutineStaticData({required this.name, required this.desc});
// }

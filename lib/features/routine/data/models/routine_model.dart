import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skin_sync/features/routine/domain/entities/routine_entity.dart';

class RoutineModel extends RoutineEntity {
  const RoutineModel({
    required super.id,
    required super.name,
    required super.description,
    required super.time,
    required super.userId,
    required super.createdDate,
    super.localIconPath,
    super.completionDates,
    required super.startDate,
    super.endDate,
    super.imagePath,
  });

  factory RoutineModel.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.parse(date);
      return null;
    }

    TimeOfDay parseTime(dynamic time) {
      if (time is Map) {
        return TimeOfDay(
          hour: time['hour'] as int,
          minute: time['minute'] as int,
        );
      }
      return TimeOfDay.now();
    }

    return RoutineModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      time: parseTime(map['time']),
      userId: map['userId'] as String,
      localIconPath: map['localIconPath'] as String? ?? '',
      createdDate: parseDate(map['createdDate']) ?? DateTime.now(),
      startDate: parseDate(map['startDate']) ?? DateTime.now(),
      endDate: parseDate(map['endDate']),
      completionDates: (map['completionDates'] as List<dynamic>?)
              ?.map((d) => parseDate(d) ?? DateTime.now())
              .toList() ??
          [],
      imagePath: map['imagePath'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'time': {'hour': time.hour, 'minute': time.minute},
      'userId': userId,
      'localIconPath': localIconPath,
      'createdDate': Timestamp.fromDate(createdDate),
      'startDate': Timestamp.fromDate(startDate),
      'imagePath': imagePath,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'completionDates':
          completionDates.map((d) => Timestamp.fromDate(d)).toList(),
    };
  }

  factory RoutineModel.fromEntity(RoutineEntity entity) {
    return RoutineModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      time: entity.time,
      userId: entity.userId,
      createdDate: entity.createdDate,
      localIconPath: entity.localIconPath,
      completionDates: entity.completionDates,
      startDate: entity.startDate,
      endDate: entity.endDate,
      imagePath: entity.imagePath,
    );
  }
}

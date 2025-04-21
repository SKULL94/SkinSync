import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomRoutine {
  final String id;
  final String name;
  final String description;
  final TimeOfDay time;
  final String userId;
  final DateTime createdDate;
  final String imagePath;
  final String localIconPath;
  final bool isCompleted;
  final double completionProgress;
  final List<DateTime> completionDates;
  final DateTime startDate;
  final DateTime? endDate;

  CustomRoutine({
    required this.id,
    required this.name,
    required this.description,
    required this.time,
    required this.userId,
    required this.createdDate,
    this.imagePath = '',
    this.localIconPath = '',
    this.isCompleted = false,
    this.completionProgress = 0.0,
    this.completionDates = const [],
    required this.startDate,
    this.endDate,
  });

  factory CustomRoutine.fromMap(Map<String, dynamic> map) {
    return CustomRoutine(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      time: TimeOfDay(
        hour: (map['time'] as Map)['hour'],
        minute: (map['time'] as Map)['minute'],
      ),
      userId: map['userId'],
      createdDate: (map['createdDate'] as Timestamp).toDate(),
      imagePath: map['imagePath'] ?? '',
      localIconPath: map['localIconPath'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      completionProgress: (map['completionProgress'] ?? 0.0).toDouble(),
      completionDates: (map['completionDates'] as List<dynamic>?)
              ?.map((e) => (e as Timestamp).toDate())
              .toList() ??
          [],
      startDate: (map['startDate'] as Timestamp?)?.toDate() ??
          (map['createdDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'time': {'hour': time.hour, 'minute': time.minute},
      'userId': userId,
      'createdDate': Timestamp.fromDate(createdDate),
      'imagePath': imagePath,
      'localIconPath': localIconPath,
      'isCompleted': isCompleted,
      'completionProgress': completionProgress,
      'completionDates':
          completionDates.map((d) => Timestamp.fromDate(d)).toList(),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    };
  }

  CustomRoutine copyWith({
    String? id,
    String? name,
    String? description,
    TimeOfDay? time,
    String? userId,
    DateTime? createdDate,
    String? imagePath,
    String? localIconPath,
    bool? isCompleted,
    double? completionProgress,
    List<DateTime>? completionDates,
  }) {
    return CustomRoutine(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        time: time ?? this.time,
        userId: userId ?? this.userId,
        createdDate: createdDate ?? this.createdDate,
        imagePath: imagePath ?? this.imagePath,
        localIconPath: localIconPath ?? this.localIconPath,
        isCompleted: isCompleted ?? this.isCompleted,
        completionProgress: completionProgress ?? this.completionProgress,
        completionDates: completionDates ?? this.completionDates,
        startDate: startDate,
        endDate: endDate);
  }
}

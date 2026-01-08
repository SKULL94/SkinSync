import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomRoutine {
  final String id;
  final String name;
  final String description;
  final TimeOfDay time;
  final String userId;
  final DateTime createdDate;
  final String localIconPath;
  final List<DateTime> completionDates;
  final DateTime startDate;
  final DateTime? endDate;
  final String? imagePath;

  CustomRoutine({
    required this.id,
    required this.name,
    required this.description,
    required this.time,
    required this.userId,
    required this.createdDate,
    this.localIconPath = '',
    this.completionDates = const [],
    required this.startDate,
    this.imagePath,
    this.endDate,
  });

  factory CustomRoutine.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.parse(date);
      return null;
    }

    TimeOfDay parseTime(dynamic time) {
      if (time is Map) {
        return TimeOfDay(hour: time['hour'], minute: time['minute']);
      }
      return TimeOfDay.now();
    }

    return CustomRoutine(
        id: map['id'],
        name: map['name'],
        description: map['description'],
        time: parseTime(map['time']),
        userId: map['userId'],
        localIconPath: map['localIconPath'] ?? '',
        createdDate: parseDate(map['createdDate']) ?? DateTime.now(),
        startDate: parseDate(map['startDate']) ?? DateTime.now(),
        endDate: parseDate(map['endDate']),
        completionDates: (map['completionDates'] as List<dynamic>?)
                ?.map((d) => parseDate(d) ?? DateTime.now())
                .toList() ??
            [],
        imagePath: map['imagePath'] ?? '');
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

  CustomRoutine copyWith({
    String? id,
    String? name,
    String? description,
    TimeOfDay? time,
    String? userId,
    DateTime? createdDate,
    String? localIconPath,
    List<DateTime>? completionDates,
    DateTime? startDate,
    DateTime? endDate,
    String? imagePath,
  }) {
    return CustomRoutine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      time: time ?? this.time,
      userId: userId ?? this.userId,
      imagePath: imagePath ?? this.imagePath,
      createdDate: createdDate ?? this.createdDate,
      localIconPath: localIconPath ?? this.localIconPath,
      completionDates: completionDates ?? this.completionDates,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  double get completionProgress {
    final today = DateTime.now();
    final isCompletedToday = completionDates.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);

    return isCompletedToday ? 1.0 : 0.0;
  }

  bool isCompletedOnDate(DateTime date) {
    return completionDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  CustomRoutine toggleCompletion(DateTime date) {
    final newDates = List<DateTime>.from(completionDates);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (isCompletedOnDate(dateOnly)) {
      newDates.removeWhere((d) =>
          d.year == dateOnly.year &&
          d.month == dateOnly.month &&
          d.day == dateOnly.day);
    } else {
      newDates.add(dateOnly);
    }

    return copyWith(completionDates: newDates);
  }
}

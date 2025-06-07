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
      imagePath: map['imagePath'] ?? '',
      localIconPath: map['localIconPath'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      completionProgress: (map['completionProgress'] ?? 0.0).toDouble(),
      createdDate: parseDate(map['createdDate']) ?? DateTime.now(),
      startDate: parseDate(map['startDate']) ?? DateTime.now(),
      endDate: parseDate(map['endDate']),
      completionDates: (map['completionDates'] as List<dynamic>?)
              ?.map((d) => parseDate(d) ?? DateTime.now())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'time': {'hour': time.hour, 'minute': time.minute},
      'userId': userId,
      'imagePath': imagePath,
      'localIconPath': localIconPath,
      'isCompleted': isCompleted,
      'completionProgress': completionProgress,
      'createdDate': Timestamp.fromDate(createdDate),
      'startDate': Timestamp.fromDate(startDate),
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

  CustomRoutine toggleCompletion(DateTime date) {
    final dateDay = DateTime(date.year, date.month, date.day);
    final newDates = List<DateTime>.from(completionDates);

    if (newDates.any((d) => isSameDay(d, dateDay))) {
      newDates.removeWhere((d) => isSameDay(d, dateDay));
    } else {
      newDates.add(dateDay);
    }

    return copyWith(
      completionDates: newDates,
      completionProgress: completionDates.length / 30,
    );
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // double _calculateProgress(List<DateTime> dates) {
  //   if (dates.isEmpty) return 0.0;
  //   final DateTime now = DateTime.now();
  //   final int monthlyCount =
  //       dates.where((d) => d.month == now.month && d.year == now.year).length;
  //   return monthlyCount / DateUtils.getDaysInMonth(now.year, now.month);
  // }
}

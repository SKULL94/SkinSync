import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class RoutineEntity extends Equatable {
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

  const RoutineEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.time,
    required this.userId,
    required this.createdDate,
    this.localIconPath = '',
    this.completionDates = const [],
    required this.startDate,
    this.endDate,
    this.imagePath,
  });

  double get completionProgress {
    final today = DateTime.now();
    final isCompletedToday = completionDates.any(
      (date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day,
    );
    return isCompletedToday ? 1.0 : 0.0;
  }

  bool isCompletedOnDate(DateTime date) {
    return completionDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  RoutineEntity toggleCompletion(DateTime date) {
    final newDates = List<DateTime>.from(completionDates);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (isCompletedOnDate(dateOnly)) {
      newDates.removeWhere(
        (d) =>
            d.year == dateOnly.year &&
            d.month == dateOnly.month &&
            d.day == dateOnly.day,
      );
    } else {
      newDates.add(dateOnly);
    }

    return RoutineEntity(
      id: id,
      name: name,
      description: description,
      time: time,
      userId: userId,
      createdDate: createdDate,
      localIconPath: localIconPath,
      completionDates: newDates,
      startDate: startDate,
      endDate: endDate,
      imagePath: imagePath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        time,
        userId,
        createdDate,
        localIconPath,
        completionDates,
        startDate,
        endDate,
        imagePath,
      ];
}

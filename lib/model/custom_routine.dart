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

  CustomRoutine({
    required this.id,
    required this.name,
    required this.description,
    required this.time,
    required this.userId,
    required this.createdDate,
    this.imagePath = '',
    required this.localIconPath,
  });

  factory CustomRoutine.fromMap(Map<String, dynamic> map) {
    return CustomRoutine(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      time: TimeOfDay(hour: map['hour'], minute: map['minute']),
      userId: map['userId'],
      createdDate: DateTime.parse(map['createdDate']),
      imagePath: map['imagePath'] ?? '',
      localIconPath: map['localIconPath'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'hour': time.hour,
        'minute': time.minute,
        'userId': userId,
        'createdDate': createdDate.toIso8601String(),
        'imagePath': imagePath,
        'localIconPath': localIconPath,
      };

  CustomRoutine copyWith({String? imagePath}) {
    return CustomRoutine(
        id: id,
        name: name,
        description: description,
        time: time,
        userId: userId,
        createdDate: createdDate,
        imagePath: imagePath ?? this.imagePath,
        localIconPath: localIconPath);
  }
}

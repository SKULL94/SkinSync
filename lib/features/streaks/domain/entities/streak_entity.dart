import 'package:equatable/equatable.dart';

enum StreakType { daily, weekly, monthly }

class StreakEntity extends Equatable {
  final int currentStreak;
  final List<String> completedDays;
  final Map<String, int> dailyCompletion;
  final StreakType streakType;

  const StreakEntity({
    required this.currentStreak,
    required this.completedDays,
    required this.dailyCompletion,
    required this.streakType,
  });

  @override
  List<Object?> get props => [
        currentStreak,
        completedDays,
        dailyCompletion,
        streakType,
      ];
}

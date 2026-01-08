part of 'streaks_bloc.dart';

enum StreaksStatus { initial, loading, loaded, failure }

final class StreaksState extends Equatable {
  final StreaksStatus status;
  final int currentStreak;
  final List<String> completedDays;
  final Map<String, int> dailyCompletion;
  final StreakType streakType;
  final String? errorMessage;

  const StreaksState({
    this.status = StreaksStatus.initial,
    this.currentStreak = 0,
    this.completedDays = const [],
    this.dailyCompletion = const {},
    this.streakType = StreakType.daily,
    this.errorMessage,
  });

  StreaksState copyWith({
    StreaksStatus? status,
    int? currentStreak,
    List<String>? completedDays,
    Map<String, int>? dailyCompletion,
    StreakType? streakType,
    String? errorMessage,
  }) {
    return StreaksState(
      status: status ?? this.status,
      currentStreak: currentStreak ?? this.currentStreak,
      completedDays: completedDays ?? this.completedDays,
      dailyCompletion: dailyCompletion ?? this.dailyCompletion,
      streakType: streakType ?? this.streakType,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentStreak,
        completedDays,
        dailyCompletion,
        streakType,
        errorMessage,
      ];
}

import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/core/constants/app_constants.dart';
import 'package:skin_sync/core/services/storage_service.dart';
import 'package:skin_sync/features/streaks/domain/entities/streak_entity.dart';
import 'package:skin_sync/features/streaks/domain/usecases/get_completed_days.dart';

part 'streaks_event.dart';
part 'streaks_state.dart';

class StreaksBloc extends Bloc<StreaksEvent, StreaksState> {
  final GetCompletedDays getCompletedDays;
  final StorageService storageService;

  StreaksBloc({
    required this.getCompletedDays,
    required this.storageService,
  }) : super(const StreaksState()) {
    on<StreaksLoadRequested>(_onLoadRequested);
    on<StreaksTypeChanged>(_onTypeChanged);
  }

  String? get _userId => storageService.fetch<String>(AppConstants.userId);

  Future<void> _onLoadRequested(
    StreaksLoadRequested event,
    Emitter<StreaksState> emit,
  ) async {
    if (_userId == null) return;

    emit(state.copyWith(status: StreaksStatus.loading));

    final result = await getCompletedDays(
      GetCompletedDaysParams(userId: _userId!),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: StreaksStatus.failure,
        errorMessage: failure.message,
      )),
      (completedDays) {
        final dailyCompletion = _buildDailyCompletion(completedDays);
        final streak = _calculateStreak(
          completedDays,
          dailyCompletion,
          state.streakType,
        );
        emit(state.copyWith(
          status: StreaksStatus.loaded,
          completedDays: completedDays,
          dailyCompletion: dailyCompletion,
          currentStreak: streak,
        ));
      },
    );
  }

  void _onTypeChanged(
    StreaksTypeChanged event,
    Emitter<StreaksState> emit,
  ) {
    final streak = _calculateStreak(
      state.completedDays,
      state.dailyCompletion,
      event.type,
    );
    emit(state.copyWith(
      streakType: event.type,
      currentStreak: streak,
    ));
  }

  Map<String, int> _buildDailyCompletion(List<String> completedDays) {
    final completionMap = <String, int>{};
    for (final date in completedDays) {
      completionMap[date] = (completionMap[date] ?? 0) + 1;
    }
    return completionMap;
  }

  int _calculateStreak(
    List<String> completedDays,
    Map<String, int> dailyCompletion,
    StreakType type,
  ) {
    DateTime currentDate = DateTime.now();
    int streak = 0;

    while (true) {
      final meetsCriteria = switch (type) {
        StreakType.daily => _dailyCheck(currentDate, dailyCompletion),
        StreakType.weekly => _weeklyCheck(currentDate, dailyCompletion),
        StreakType.monthly => _monthlyCheck(currentDate, dailyCompletion),
      };

      if (!meetsCriteria) break;

      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  bool _dailyCheck(DateTime date, Map<String, int> dailyCompletion) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return (dailyCompletion[formattedDate] ?? 0) > 0;
  }

  bool _weeklyCheck(DateTime date, Map<String, int> dailyCompletion) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    int completedDays = 0;

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      if (_dailyCheck(day, dailyCompletion)) completedDays++;
    }

    return completedDays >= 3;
  }

  bool _monthlyCheck(DateTime date, Map<String, int> dailyCompletion) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    int completedDays = 0;

    for (int i = 0; i < lastDayOfMonth.day; i++) {
      final day = firstDayOfMonth.add(Duration(days: i));
      if (_dailyCheck(day, dailyCompletion)) completedDays++;
    }

    return completedDays >= 15;
  }
}

extension StreaksChartData on StreaksBloc {
  List<FlSpot> getDailyChartData(StreaksState state) {
    final formatter = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();
    final spots = <FlSpot>[];

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: 29 - i));
      final formattedDate = formatter.format(date);
      final completed = state.dailyCompletion[formattedDate] ?? 0;
      spots.add(FlSpot(i.toDouble(), completed > 0 ? 1 : 0));
    }

    return spots;
  }
}

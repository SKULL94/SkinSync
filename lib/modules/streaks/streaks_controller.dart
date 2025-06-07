import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' as dateutils;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/utils/app_constants.dart';
import 'package:skin_sync/services/storage.dart';

enum StreakType { daily, weekly, monthly }

class StreaksController extends GetxController {
  final RxBool _isFetchingStreaksData = RxBool(false);
  final RxInt _streaks = RxInt(0);
  final RxList<String> completedDays = <String>[].obs;
  final Rx<StreakType> currentStreakType = StreakType.daily.obs;
  final RxMap<String, int> dailyCompletion = <String, int>{}.obs;

  void changeStreakType(StreakType type) {
    currentStreakType.value = type;
    _streaks.value = calculateStreak(completedDays);
  }

  int get streaks => _streaks.value;
  bool get isFetchingStreaksData => _isFetchingStreaksData.value;

  @override
  void onInit() {
    fetchCompletedDays(StorageService.instance.fetch(AppConstants.userId));
    super.onInit();
  }

  Future<void> fetchCompletedDays(String userId) async {
    _isFetchingStreaksData.value = true;
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      List<String> days = List.from(userSnapshot['completedDays'] ?? []);
      completedDays.value = days;
      _streaks.value = calculateStreak(days);
    } finally {
      _isFetchingStreaksData.value = false;
    }

    Map<String, int> completionMap = {};
    for (var date in completedDays) {
      completionMap[date] = (completionMap[date] ?? 0) + 1;
    }
    dailyCompletion.value = completionMap;
  }

  List<FlSpot> getStreakChartData() {
    final formatter = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();
    final List<FlSpot> spots = [];

    List<int> dailyCompletion = List.generate(30, (index) => 0);

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: 29 - i));
      if (completedDays.contains(formatter.format(date))) {
        dailyCompletion[i] = 1;
      }
    }
    int currentStreak = 0;
    for (int i = 0; i < 30; i++) {
      currentStreak = dailyCompletion[i] == 1 ? currentStreak + 1 : 0;
      spots.add(FlSpot(i.toDouble(), currentStreak.toDouble()));
    }

    return spots;
  }

  int calculateStreak(List<String> completedDays) {
    DateTime currentDate = DateTime.now();
    int streak = 0;

    while (true) {
      final meetsCriteria = switch (currentStreakType.value) {
        StreakType.daily => _dailyCompletionCheck(currentDate),
        StreakType.weekly => _weeklyCompletionCheck(currentDate),
        StreakType.monthly => _monthlyCompletionCheck(currentDate),
      };

      if (!meetsCriteria) break;

      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  bool _dailyCompletionCheck(DateTime date) {
    final data = getDailyCompletion(date);
    return data['ratio'] > 0;
  }

  bool _weeklyCompletionCheck(DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    int completedDays = 0;

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      if (_dailyCompletionCheck(day)) completedDays++;
    }

    return completedDays >= 3;
  }

  bool _monthlyCompletionCheck(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    int completedDays = 0;

    for (int i = 0; i < lastDayOfMonth.day; i++) {
      final day = firstDayOfMonth.add(Duration(days: i));
      if (_dailyCompletionCheck(day)) completedDays++;
    }

    return completedDays >= 15;
  }

  Map<String, dynamic> getDailyCompletion(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final completed = dailyCompletion[formattedDate] ?? 0;
    final total = _getTotalRoutinesForDate(date);
    return {
      'completed': completed,
      'total': total,
      'ratio': total > 0 ? completed / total : 0,
    };
  }

  int _getTotalRoutinesForDate(DateTime date) {
    return Get.find<RoutineController>()
        .routines
        .where((r) => _isDateInRange(date, r.startDate, r.endDate))
        .length;
  }

  bool _isDateInRange(DateTime date, DateTime start, DateTime? end) {
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
        (end == null || date.isBefore(end.add(const Duration(days: 1))));
  }

  List<FlSpot> getDailyChartData() {
    final now = DateTime.now();
    final spots = <FlSpot>[];

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: 29 - i));
      final data = getDailyCompletion(date);
      spots.add(FlSpot(i.toDouble(), data['ratio']));
    }

    return spots;
  }

  List<FlSpot> getWeeklyChartData() {
    final now = DateTime.now();
    final spots = <FlSpot>[];

    for (int i = 0; i < 4; i++) {
      final weekStart = now.subtract(Duration(days: 7 * (3 - i)));
      double weeklyRatio = 0;

      for (int d = 0; d < 7; d++) {
        final date = weekStart.add(Duration(days: d));
        final data = getDailyCompletion(date);
        weeklyRatio += data['ratio'];
      }

      spots.add(FlSpot(i.toDouble(), weeklyRatio / 7));
    }

    return spots;
  }

  List<FlSpot> getMonthlyChartData() {
    final now = DateTime.now();
    final spots = <FlSpot>[];

    for (int i = 0; i < 12; i++) {
      final month = now.month - i;
      final year = now.year - (month <= 0 ? 1 : 0);
      final adjustedMonth = month <= 0 ? month + 12 : month;

      double monthlyRatio = 0;
      int daysInMonth = dateutils.DateUtils.getDaysInMonth(year, adjustedMonth);

      for (int d = 1; d <= daysInMonth; d++) {
        final date = DateTime(year, adjustedMonth, d);
        final data = getDailyCompletion(date);
        monthlyRatio += data['ratio'];
      }

      spots.add(FlSpot((11 - i).toDouble(), monthlyRatio / daysInMonth));
    }

    return spots.reversed.toList();
  }
}

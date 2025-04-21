// streaks_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/utils/app_utils.dart';
import 'package:skin_sync/utils/storage.dart';

class StreaksController extends GetxController {
  final RxBool _isFetchingStreaksData = RxBool(false);
  final RxInt _streaks = RxInt(0);
  final RxList<String> completedDays = <String>[].obs;

  int get streaks => _streaks.value;
  bool get isFetchingStreaksData => _isFetchingStreaksData.value;

  @override
  void onInit() {
    fetchCompletedDays(StorageService.instance.fetch(AppUtils.userId));
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
  }

  int calculateStreak(List<String> completedDays) {
    final formatter = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();
    DateTime currentDate = DateTime(now.year, now.month, now.day);
    int streak = 0;

    while (completedDays.contains(formatter.format(currentDate))) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  List<FlSpot> getStreakChartData() {
    final formatter = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();
    final List<FlSpot> spots = [];
    final Map<String, int> dailyStreaks = {};

    for (int i = 29; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      dailyStreaks[formatter.format(date)] = 0;
    }

    int currentStreak = 0;
    DateTime currentDate = now;
    while (currentDate.isAfter(now.subtract(const Duration(days: 30)))) {
      String dateKey = formatter.format(currentDate);
      if (completedDays.contains(dateKey)) {
        currentStreak++;
      } else {
        currentStreak = 0;
      }
      dailyStreaks[dateKey] = currentStreak;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    int index = 0;
    dailyStreaks.forEach((date, streak) {
      spots.add(FlSpot(index.toDouble(), streak.toDouble()));
      index++;
    });

    return spots;
  }
}

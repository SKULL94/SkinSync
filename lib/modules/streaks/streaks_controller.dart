import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/utils/app_utils.dart';
import 'package:skin_sync/utils/storage.dart';

class StreaksController extends GetxController {
  final RxBool _isFetchingStreaksData = RxBool(false);
  final RxInt _streaks = RxInt(0);
  int get streaks => _streaks.value;
  bool get isFetchingStreaksData => _isFetchingStreaksData.value;

  @override
  void onInit() {
    fetchCompletedRoutines(StorageService.instance.fetch(AppUtils.userId));
    super.onInit();
  }

  updateisFetchingStreaksData(bool value) {
    _isFetchingStreaksData.value = value;
    update();
  }

  fetchCompletedRoutines(String userId) async {
    updateisFetchingStreaksData(true);
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      _streaks.value = calculateStreak(userData['completedRoutines']);
      updateisFetchingStreaksData(false);
    } catch (e) {
      updateisFetchingStreaksData(false);
    }
  }

  int calculateStreak(Map<String, dynamic> completedRoutines) {
    int streak = 0;
    DateTime currentDate = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    while (completedRoutines.containsKey(formatter.format(currentDate)) &&
        hasCompletedFiveRoutines(completedRoutines, currentDate, formatter)) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  bool hasCompletedFiveRoutines(Map<String, dynamic> completedRoutines,
      DateTime date, DateFormat formatter) {
    return completedRoutines[formatter.format(date)]?.length == 5;
  }
}

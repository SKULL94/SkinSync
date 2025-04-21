import 'package:get/get.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/modules/routine/routine_screen.dart';
import 'package:skin_sync/modules/streaks/streaks_controller.dart';
import 'package:skin_sync/modules/streaks/streaks_screen.dart';

class LayoutController extends GetxController {
  final bodyPages = [RoutineScreen(), StreaksScreen()];
  final RxInt _currentIndex = RxInt(0);

  int get currentIndex => _currentIndex.value;

  changeIndex(int value) {
    _currentIndex.value = value;
    if (value == 0) {
      Get.delete<StreaksController>();
    } else {
      Get.delete<RoutineController>();
    }
    update();
  }
}

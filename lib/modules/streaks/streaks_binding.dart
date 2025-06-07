import 'package:get/get.dart';
import 'package:skin_sync/modules/streaks/streaks_controller.dart';

class StreaksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StreaksController(), fenix: true);
  }
}

import 'package:get/get.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';

class RoutineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RoutineController(), fenix: true);
    Get.find<RoutineController>().fetchRoutines();
  }
}

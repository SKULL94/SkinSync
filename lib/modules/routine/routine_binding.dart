import 'package:get/get.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/modules/skin-analysis/controller/camera_service_controller.dart';

class RoutineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RoutineController(), fenix: true);
    Get.lazyPut(() => CameraServiceController(), fenix: true);
  }
}

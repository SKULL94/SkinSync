import 'package:get/get.dart';
import 'package:skin_sync/modules/auth/auth_controller.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RoutineController(), fenix: true);
    Get.lazyPut(() => AuthController(), fenix: true);
  }
}

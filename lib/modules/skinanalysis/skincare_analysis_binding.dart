import 'package:get/get.dart';
import 'controller/skincare_analysis_controller.dart';

class SkincareAnalysisBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SkincareAnalysisController());
  }
}

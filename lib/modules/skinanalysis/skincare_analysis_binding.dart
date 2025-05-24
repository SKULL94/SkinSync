import 'package:get/get.dart';
import 'skincare_analysis_controller.dart';

class SkincareAnalysisBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SkincareAnalysisController());
  }
}

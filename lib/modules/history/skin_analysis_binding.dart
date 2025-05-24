import 'package:get/get.dart';
import 'package:skin_sync/modules/history/skin_analysis_history_controller.dart';

class SkinAnalysisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HistoryController(), fenix: true);
  }
}

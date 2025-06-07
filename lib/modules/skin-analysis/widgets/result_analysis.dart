import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:skin_sync/modules/skin-analysis/controller/skincare_analysis_controller.dart';
import 'package:skin_sync/modules/skin-analysis/widgets/skin_result.dart';

class AnalysisResultsSection extends GetView<SkincareAnalysisController> {
  const AnalysisResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        if (controller.results.isEmpty) {
          return const Center(
              child:
                  Text("Valid Skin Image Analysis results will appear here"));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.results.length,
          separatorBuilder: (_, __) => const Divider(height: 20),
          itemBuilder: (_, index) =>
              ResultTile(result: controller.results[index]),
        );
      }),
    );
  }
}

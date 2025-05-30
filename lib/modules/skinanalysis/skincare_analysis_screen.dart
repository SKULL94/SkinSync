import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/modules/skinanalysis/widgets/app_bar.dart';
import 'package:skin_sync/modules/skinanalysis/widgets/image_preview.dart';
import 'package:skin_sync/modules/skinanalysis/widgets/result_analysis.dart';
import 'package:skin_sync/utils/mediaquery.dart';
import 'controller/skincare_analysis_controller.dart';

class SkincareAnalysisScreen extends GetView<SkincareAnalysisController> {
  final RoutineController routineController = Get.find<RoutineController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SkincareAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.saveAnalysis(),
        elevation: 0,
        child: const Icon(Icons.save),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: getHeight(context, 20)),
                Text('Analyzing your skin...'),
              ],
            ),
          );
        }

        if (controller.selectedImage.value == null) {
          return const Center(child: Text("No image selected"));
        }

        return Column(
          children: [
            ImagePreviewSection(),
            AnalysisResultsSection(),
          ],
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/modules/skin-analysis/widgets/app_bar.dart';
import 'package:skin_sync/modules/skin-analysis/widgets/image_preview.dart';
import 'package:skin_sync/modules/skin-analysis/widgets/result_analysis.dart';
import 'controller/skincare_analysis_controller.dart';

class SkincareAnalysisScreen extends GetView<SkincareAnalysisController> {
  SkincareAnalysisScreen({super.key});
  final RoutineController routineController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SkincareAppBar(),
      floatingActionButton: Obx(() {
        return controller.selectedImage.value != null &&
                !controller.isLoading.value
            ? FloatingActionButton(
                onPressed: controller.saveAnalysis,
                elevation: 0,
                child: const Icon(Icons.save),
              )
            : const SizedBox.shrink();
      }),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Analyzing your skin...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }
        return Stack(
          children: [
            if (controller.selectedImage.value == null)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  ImagePreviewSection(),
                  AnalysisResultsSection(),
                ],
              ),
            if (controller.isSaving.value)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      // Text(
                      //   'Saving analysis...',
                      //   style: TextStyle(color: Colors.white),
                      // ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:skin_sync/modules/skin-analysis/controller/skincare_analysis_controller.dart';
import 'package:skin_sync/modules/skin-analysis/widgets/loading_indicator.dart';

class ImagePreviewSection extends GetView<SkincareAnalysisController> {
  const ImagePreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InteractiveViewer(
          child: Image.file(
            controller.selectedImage.value!,
            height: 300,
            fit: BoxFit.cover,
          ),
        ),
        if (controller.isImageLoading.value == true) const LoadingIndicator(),
      ],
    );
  }
}

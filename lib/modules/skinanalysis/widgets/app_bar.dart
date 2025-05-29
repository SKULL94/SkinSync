import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/skinanalysis/controller/skincare_analysis_controller.dart';

class SkincareAppBar extends GetView<SkincareAnalysisController>
    implements PreferredSizeWidget {
  const SkincareAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Skin Analysis'),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => controller.shareAnalysis(),
          tooltip: 'Share Results',
        ),
      ],
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_sync/modules/skin-analysis/controller/skincare_analysis_controller.dart';
import 'package:skin_sync/utils/app_bar.dart';

class SkincareAppBar extends GetView<SkincareAnalysisController>
    implements PreferredSizeWidget {
  const SkincareAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Skin Analysis',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: CustomAppBar.appBarFontSize,
        ),
      ),
      surfaceTintColor: Theme.of(context).colorScheme.surface,
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

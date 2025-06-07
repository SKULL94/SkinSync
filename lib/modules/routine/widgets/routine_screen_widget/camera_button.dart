import 'package:flutter/material.dart';
// import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/modules/skin-analysis/controller/camera_service_controller.dart';

class CameraButton extends StatelessWidget {
  final RoutineController controller;
  final CameraServiceController cameraService;

  const CameraButton({
    super.key,
    required this.controller,
    required this.cameraService,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.camera_alt),
      onPressed: () => cameraService.showImageSourceMenu(context),
      tooltip: 'Analyze Skin',
      splashRadius: 24,
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skin_sync/modules/skinanalysis/controller/camera_service_controller.dart';
import 'package:skin_sync/modules/skinanalysis/controller/skincare_analysis_controller.dart';
import 'package:skin_sync/routes/app_routes.dart';
import 'package:skin_sync/utils/custom_snackbar.dart';

class SkinAnalysisLoadingScreen extends StatefulWidget {
  final ImageSource source;

  const SkinAnalysisLoadingScreen({super.key, required this.source});

  @override
  State<SkinAnalysisLoadingScreen> createState() =>
      _SkinAnalysisLoadingScreenState();
}

class _SkinAnalysisLoadingScreenState extends State<SkinAnalysisLoadingScreen> {
  late final CameraServiceController _cameraService;
  late final SkincareAnalysisController _analysisController;
  bool _processing = true;

  @override
  void initState() {
    super.initState();
    _cameraService = Get.find<CameraServiceController>();
    _analysisController = Get.find<SkincareAnalysisController>();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      // Pick image from the specified source
      final pickedFile = await _cameraService.pickImage(widget.source);

      if (pickedFile != null) {
        // Set image and analyze
        await _analysisController.setImageAndAnalyze(File(pickedFile.path));

        // Navigate directly to analysis screen
        Get.offNamed(AppRoutes.skinAnalysisRoute);
      } else {
        // User canceled - go back to previous screen
        Get.back();
      }
    } catch (e) {
      // Handle errors - go back to previous screen with message
      Get.back();
      showCustomSnackbar("Error", "Image processing failed: ${e.toString()}");
    } finally {
      setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_processing) ...[
              const CircularProgressIndicator(strokeWidth: 2),
              const SizedBox(height: 20),
              Text(
                widget.source == ImageSource.camera
                    ? 'Processing your photo...'
                    : 'Analyzing your image...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ] else ...[
              const Text('Finishing up...'),
            ]
          ],
        ),
      ),
    );
  }
}

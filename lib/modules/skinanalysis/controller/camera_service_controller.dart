import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skin_sync/modules/skinanalysis/utils/menu_position_helper.dart';
import 'package:skin_sync/routes/app_routes.dart';
import 'package:skin_sync/utils/custom_snackbar.dart';
import 'skincare_analysis_controller.dart';

class CameraServiceController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final RxBool isImageLoading = false.obs;
  final GlobalKey cameraIconKey = GlobalKey();
  final SkincareAnalysisController controller = Get.find();

  void showImageSourceMenu(BuildContext context) {
    try {
      final position = MenuPositionHelper.calculatePosition(
        key: cameraIconKey,
        context: context,
      );

      showMenu(
        context: context,
        position: position,
        items: [
          _buildMenuButton(
            icon: Icons.camera_alt,
            label: "Take Photo",
            source: ImageSource.camera,
          ),
          _buildMenuButton(
            icon: Icons.photo_library,
            label: "Choose from Gallery",
            source: ImageSource.gallery,
          ),
        ],
      );
    } catch (e) {
      showCustomSnackbar("Error", "Failed to show menu: ${e.toString()}");
    }
  }

  PopupMenuItem<dynamic> _buildMenuButton({
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return PopupMenuItem(
      height: 40,
      onTap: () => _handleImageSelection(source),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);

    try {
      final pickedFile = await _pickImage(source);
      if (pickedFile != null) {
        controller.setImageAndAnalyze(File(pickedFile.path));
        Get.toNamed(AppRoutes.skinAnalysisRoute);
      }
    } finally {
      if (Get.isDialogOpen == true) Get.back();
    }
  }

  Future<XFile?> _pickImage(ImageSource source) async {
    try {
      isImageLoading.value = true;
      return await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1200,
        maxHeight: 1200,
      );
    } catch (e) {
      showCustomSnackbar("Error", "Image selection failed: ${e.toString()}");
      return null;
    } finally {
      isImageLoading.value = false;
    }
  }
}

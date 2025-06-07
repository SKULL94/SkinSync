import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skin_sync/modules/skin-analysis/utils/menu_position_helper.dart';
import 'package:skin_sync/routes/app_routes.dart';
import 'package:skin_sync/utils/custom_snackbar.dart';
import 'package:skin_sync/services/image_service.dart';
import 'skincare_analysis_controller.dart';

class CameraServiceController extends GetxController {
  final RxBool isImageLoading = false.obs;
  final SkincareAnalysisController controller = Get.find();
  final SkincareAnalysisController analysisController = Get.find();

  void showImageSourceMenu(BuildContext context) {
    try {
      final position = MenuPositionHelper.calculatePosition(
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
      showCustomSnackbar(
        "Error",
        "Failed to show menu: ${e.toString()}",
      );
    }
  }

  PopupMenuItem<dynamic> _buildMenuButton({
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return PopupMenuItem(
      height: 45,
      onTap: () {
        _handleImageSelection(source);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 15),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    Get.toNamed(AppRoutes.skinAnalysisRoute);
    try {
      isImageLoading.value = true;
      final pickedFile = await pickImage(source);

      if (pickedFile != null) {
        await analysisController.setImageAndAnalyze(File(pickedFile.path));
      }
    } catch (e) {
      showCustomSnackbar("Error", "Image processing failed: ${e.toString()}");
    } finally {
      isImageLoading.value = false;
    }
  }

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      isImageLoading.value = true;
      return await ImageService.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1200,
        maxHeight: 1200,
      );
    } catch (e) {
      rethrow;
    } finally {
      isImageLoading.value = false;
    }
  }
}

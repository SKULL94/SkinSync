import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skin_sync/modules/skinanalysis/skin_care_analysis_loading.dart';
import 'package:skin_sync/modules/skinanalysis/utils/menu_position_helper.dart';
import 'package:skin_sync/utils/custom_snackbar.dart';
import 'skincare_analysis_controller.dart';

class CameraServiceController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final RxBool isImageLoading = false.obs;
  final SkincareAnalysisController controller = Get.find();

  void showImageSourceMenu(BuildContext context, GlobalKey key) {
    try {
      final position = MenuPositionHelper.calculatePosition(
        key: key,
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
      height: 45,
      onTap: () async {
        Get.to(() => SkinAnalysisLoadingScreen(source: source));
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

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      isImageLoading.value = true;
      return await _picker.pickImage(
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

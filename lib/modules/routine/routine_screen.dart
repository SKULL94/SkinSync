import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:skin_sync/custom_snackbar.dart';
import 'package:skin_sync/modules/routine/custom_routine_screen.dart';
import 'package:skin_sync/modules/routine/routine_controller.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/build_routine_list.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/date_navigation.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/empty_state.dart';
import 'package:skin_sync/modules/routine/widgets/routine_screen_widget/loading_state.dart';
import 'package:skin_sync/modules/skinanalysis/skin_care_analysis_loading.dart';
import 'package:skin_sync/routes/app_routes.dart';
import 'package:skin_sync/utils/mediaquery.dart';
import 'package:skin_sync/utils/storage.dart';

class RoutineScreen extends GetView<RoutineController> {
  RoutineScreen({super.key});

  final DateFormat dateFormat = DateFormat('EEE, MMM d');
  final GlobalKey _cameraIconKey = GlobalKey();

  void _showImageSourceMenu(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final renderBox =
            _cameraIconKey.currentContext?.findRenderObject() as RenderBox?;

        if (renderBox == null || !renderBox.hasSize) return;

        final offset = renderBox.localToGlobal(Offset.zero);
        final screenSize = MediaQuery.of(context).size;
        final buttonSize = renderBox.size;

        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx - 30,
            offset.dy + buttonSize.height + 10,
            screenSize.width - (offset.dx + buttonSize.width + 30),
            screenSize.height - (offset.dy + buttonSize.height + 10),
          ),
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
        showErrorSnackbar("Error", "Failed to show menu: ${e.toString()}");
      }
    });
  }

  PopupMenuItem<dynamic> _buildMenuButton({
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return PopupMenuItem(
      height: 40,
      onTap: () async {
        Get.dialog(const SkinAnalysisLoadingScreen(),
            barrierDismissible: false);
        final pickedFile = await controller.pickImage(source);
        if (pickedFile != null) {
          if (Get.isDialogOpen == true) Get.back();
          Get.toNamed(
            AppRoutes.skinAnalysisRoute,
            parameters: {'imagePath': pickedFile.path},
          );
        } else {
          if (Get.isDialogOpen == true) Get.back();
        }
      },
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${StorageService.instance.fetch('userName') ?? 'Zeeshan'} 👋',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: getResponsiveFontSize(context, 16),
          ),
        ),
        actions: [
          IconButton(
            key: _cameraIconKey,
            icon: Obx(() => controller.isImageLoading.value
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  )
                : Icon(Icons.camera_alt)),
            onPressed: () => _showImageSourceMenu(context),
            tooltip: 'Analyze Skin',
            splashRadius: 24,
          ),
          SizedBox(width: getWidth(context, 8)),
          IconButton(
            icon: Icon(
              Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              final newTheme = Get.isDarkMode ? 'light' : 'dark';
              Get.changeThemeMode(
                  newTheme == 'dark' ? ThemeMode.dark : ThemeMode.light);
              StorageService.instance.save('theme', newTheme);
            },
            splashRadius: 24,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Get.toNamed(AppRoutes.historyRoute),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        final today = DateTime.now();
        final selectedDate = controller.selectedDate.value;
        final isPastDate =
            selectedDate.isBefore(DateTime(today.year, today.month, today.day));
        return FloatingActionButton.extended(
          icon: const Icon(Icons.add_task_rounded),
          label: const Text("New Routine"),
          onPressed:
              isPastDate ? null : () => Get.to(() => CreateRoutineScreen()),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      }),
      body: Column(
        children: [
          RoutineScreenDateNavigation(
              controller: controller, dateFormat: dateFormat),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const RoutineScreenLoadingState();
              }
              return controller.routines.isEmpty
                  ? const RoutineScreenEmptyState()
                  : RoutineScreenRoutineList(controller: controller);
            }),
          ),
        ],
      ),
    );
  }
}
